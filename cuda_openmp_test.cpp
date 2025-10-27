//
// CUDA + OpenMP 混合并行计算测试程序
// 验证CPU和GPU并行计算的效果
//

#include <iostream>
#include <vector>
#include <chrono>
#include <omp.h>
#include <cuda_runtime.h>
#include <cublas_v2.h>
#include <cmath>
#include <algorithm>

// CUDA内核函数声明
extern "C" {
    __global__ void vectorAddKernel(float* a, float* b, float* c, int n);
    __global__ void complexComputationKernel(float* input, float* output, int n);
}

class CudaOpenMPTester {
private:
    cudaStream_t cudaStream_;
    cublasHandle_t cublasHandle_;
    int deviceCount_;
    int maxThreads_;
    
public:
    CudaOpenMPTester() : cudaStream_(nullptr), cublasHandle_(nullptr), deviceCount_(0), maxThreads_(0) {}
    
    ~CudaOpenMPTester() {
        if (cublasHandle_) cublasDestroy(cublasHandle_);
        if (cudaStream_) cudaStreamDestroy(cudaStream_);
    }
    
    bool initialize() {
        // 检查CUDA设备
        cudaError_t error = cudaGetDeviceCount(&deviceCount_);
        if (error != cudaSuccess || deviceCount_ == 0) {
            std::cerr << "Error: No CUDA devices detected" << std::endl;
            return false;
        }
        
        std::cout << "Detected " << deviceCount_ << " CUDA devices" << std::endl;
        
        // 设置设备
        cudaSetDevice(0);
        
        // 获取设备信息
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, 0);
        std::cout << "Using device: " << prop.name << std::endl;
        std::cout << "Compute capability: " << prop.major << "." << prop.minor << std::endl;
        std::cout << "Global memory: " << prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0) << " GB" << std::endl;
        
        // 创建CUDA流
        cudaStreamCreate(&cudaStream_);
        
        // 初始化cuBLAS
        cublasCreate(&cublasHandle_);
        cublasSetStream(cublasHandle_, cudaStream_);
        
        // 配置OpenMP
        maxThreads_ = omp_get_max_threads();
        omp_set_num_threads(maxThreads_);
        
        std::cout << "OpenMP max threads: " << maxThreads_ << std::endl;
        
        return true;
    }
    
    void testVectorAddition(int size) {
        std::cout << "\n=== Test 1: Vector Addition (size: " << size << ") ===" << std::endl;
        
        // 分配主机内存
        std::vector<float> h_a(size);
        std::vector<float> h_b(size);
        std::vector<float> h_c(size);
        
        // 初始化数据
        for (int i = 0; i < size; i++) {
            h_a[i] = static_cast<float>(i);
            h_b[i] = static_cast<float>(i * 2);
        }
        
        // 分配GPU内存
        float *d_a, *d_b, *d_c;
        cudaMalloc(&d_a, size * sizeof(float));
        cudaMalloc(&d_b, size * sizeof(float));
        cudaMalloc(&d_c, size * sizeof(float));
        
        // 复制数据到GPU
        cudaMemcpyAsync(d_a, h_a.data(), size * sizeof(float), cudaMemcpyHostToDevice, cudaStream_);
        cudaMemcpyAsync(d_b, h_b.data(), size * sizeof(float), cudaMemcpyHostToDevice, cudaStream_);
        
        // 配置内核参数
        int blockSize = 256;
        int gridSize = (size + blockSize - 1) / blockSize;
        
        // 创建CUDA事件用于计时
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        
        // 预热
        vectorAddKernel<<<gridSize, blockSize, 0, cudaStream_>>>(d_a, d_b, d_c, size);
        cudaStreamSynchronize(cudaStream_);
        
        // 计时
        cudaEventRecord(start);
        
        const int iterations = 1000;
        for (int i = 0; i < iterations; i++) {
            vectorAddKernel<<<gridSize, blockSize, 0, cudaStream_>>>(d_a, d_b, d_c, size);
        }
        
        cudaEventRecord(stop);
        cudaStreamSynchronize(cudaStream_);
        
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);
        
        // 复制结果回主机
        cudaMemcpyAsync(h_c.data(), d_c, size * sizeof(float), cudaMemcpyDeviceToHost, cudaStream_);
        cudaStreamSynchronize(cudaStream_);
        
        // 验证结果
        bool correct = true;
        for (int i = 0; i < size; i++) {
            if (std::abs(h_c[i] - (h_a[i] + h_b[i])) > 1e-5) {
                correct = false;
                break;
            }
        }
        
        std::cout << "CUDA vector addition result: " << (correct ? "Correct" : "Incorrect") << std::endl;
        std::cout << "Execution time: " << milliseconds << " ms (" << iterations << " iterations)" << std::endl;
        std::cout << "Average per iteration: " << milliseconds / iterations << " ms" << std::endl;
        std::cout << "Throughput: " << (size * iterations) / (milliseconds / 1000.0) / 1e6 << " million elements/sec" << std::endl;
        
        // 清理
        cudaFree(d_a);
        cudaFree(d_b);
        cudaFree(d_c);
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
    }
    
    void testComplexComputation(int size) {
        std::cout << "\n=== Test 2: Complex Computation (size: " << size << ") ===" << std::endl;
        
        // 分配主机内存
        std::vector<float> h_input(size);
        std::vector<float> h_output(size);
        
        // 初始化数据
        for (int i = 0; i < size; i++) {
            h_input[i] = static_cast<float>(i) / size;
        }
        
        // 分配GPU内存
        float *d_input, *d_output;
        cudaMalloc(&d_input, size * sizeof(float));
        cudaMalloc(&d_output, size * sizeof(float));
        
        // 复制数据到GPU
        cudaMemcpyAsync(d_input, h_input.data(), size * sizeof(float), cudaMemcpyHostToDevice, cudaStream_);
        
        // 配置内核参数
        int blockSize = 256;
        int gridSize = (size + blockSize - 1) / blockSize;
        
        // 创建CUDA事件用于计时
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        
        // 预热
        complexComputationKernel<<<gridSize, blockSize, 0, cudaStream_>>>(d_input, d_output, size);
        cudaStreamSynchronize(cudaStream_);
        
        // 计时
        cudaEventRecord(start);
        
        const int iterations = 100;
        for (int i = 0; i < iterations; i++) {
            complexComputationKernel<<<gridSize, blockSize, 0, cudaStream_>>>(d_input, d_output, size);
        }
        
        cudaEventRecord(stop);
        cudaStreamSynchronize(cudaStream_);
        
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);
        
        // 复制结果回主机
        cudaMemcpyAsync(h_output.data(), d_output, size * sizeof(float), cudaMemcpyDeviceToHost, cudaStream_);
        cudaStreamSynchronize(cudaStream_);
        
        std::cout << "CUDA complex computation result: Complete" << std::endl;
        std::cout << "Execution time: " << milliseconds << " ms (" << iterations << " iterations)" << std::endl;
        std::cout << "Average per iteration: " << milliseconds / iterations << " ms" << std::endl;
        std::cout << "Throughput: " << (size * iterations) / (milliseconds / 1000.0) / 1e6 << " million elements/sec" << std::endl;
        
        // 清理
        cudaFree(d_input);
        cudaFree(d_output);
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
    }
    
    void testOpenMPComputation(int size) {
        std::cout << "\n=== Test 3: OpenMP Parallel Computation (size: " << size << ") ===" << std::endl;
        
        // 分配内存
        std::vector<float> input(size);
        std::vector<float> output(size);
        
        // 初始化数据
        for (int i = 0; i < size; i++) {
            input[i] = static_cast<float>(i) / size;
        }
        
        // 计时
        auto start = std::chrono::high_resolution_clock::now();
        
        const int iterations = 100;
        for (int iter = 0; iter < iterations; iter++) {
            #pragma omp parallel for
            for (int i = 0; i < size; i++) {
                float result = 0.0f;
                for (int j = 0; j < 1000; j++) {
                    result += sinf(input[i] + j) * cosf(input[i] * j);
                }
                output[i] = result;
            }
        }
        
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
        
        std::cout << "OpenMP parallel computation result: Complete" << std::endl;
        std::cout << "Execution time: " << duration.count() << " ms (" << iterations << " iterations)" << std::endl;
        std::cout << "Average per iteration: " << duration.count() / iterations << " ms" << std::endl;
        std::cout << "Throughput: " << (size * iterations) / (duration.count() / 1000.0) / 1e6 << " million elements/sec" << std::endl;
    }
    
    void testHybridComputation(int size) {
        std::cout << "\n=== Test 4: CUDA + OpenMP Hybrid Computation (size: " << size << ") ===" << std::endl;
        
        // 分配主机内存
        std::vector<float> h_input(size);
        std::vector<float> h_output(size);
        
        // 初始化数据
        for (int i = 0; i < size; i++) {
            h_input[i] = static_cast<float>(i) / size;
        }
        
        // 分配GPU内存
        float *d_input, *d_output;
        cudaMalloc(&d_input, size * sizeof(float));
        cudaMalloc(&d_output, size * sizeof(float));
        
        // 复制数据到GPU
        cudaMemcpyAsync(d_input, h_input.data(), size * sizeof(float), cudaMemcpyHostToDevice, cudaStream_);
        
        // 配置内核参数
        int blockSize = 256;
        int gridSize = (size + blockSize - 1) / blockSize;
        
        // 创建CUDA事件用于计时
        cudaEvent_t start, stop;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        
        // 预热
        complexComputationKernel<<<gridSize, blockSize, 0, cudaStream_>>>(d_input, d_output, size);
        cudaStreamSynchronize(cudaStream_);
        
        // 计时
        cudaEventRecord(start);
        
        const int iterations = 100;
        for (int iter = 0; iter < iterations; iter++) {
            // CUDA计算
            complexComputationKernel<<<gridSize, blockSize, 0, cudaStream_>>>(d_input, d_output, size);
            
            // OpenMP计算 (与CUDA并行)
            #pragma omp parallel for
            for (int i = 0; i < size / 2; i++) {
                float result = 0.0f;
                for (int j = 0; j < 500; j++) {
                    result += sinf(h_input[i] + j) * cosf(h_input[i] * j);
                }
                h_output[i] = result;
            }
        }
        
        cudaEventRecord(stop);
        cudaStreamSynchronize(cudaStream_);
        
        float milliseconds = 0;
        cudaEventElapsedTime(&milliseconds, start, stop);
        
        // 复制结果回主机
        cudaMemcpyAsync(h_output.data() + size / 2, d_output + size / 2, 
                        (size - size / 2) * sizeof(float), cudaMemcpyDeviceToHost, cudaStream_);
        cudaStreamSynchronize(cudaStream_);
        
        std::cout << "CUDA + OpenMP hybrid computation result: Complete" << std::endl;
        std::cout << "Execution time: " << milliseconds << " ms (" << iterations << " iterations)" << std::endl;
        std::cout << "Average per iteration: " << milliseconds / iterations << " ms" << std::endl;
        std::cout << "Throughput: " << (size * iterations) / (milliseconds / 1000.0) / 1e6 << " million elements/sec" << std::endl;
        
        // 清理
        cudaFree(d_input);
        cudaFree(d_output);
        cudaEventDestroy(start);
        cudaEventDestroy(stop);
    }
};

int main() {
    std::cout << "========================================" << std::endl;
    std::cout << "CUDA + OpenMP Hybrid Parallel Computing Test" << std::endl;
    std::cout << "========================================" << std::endl;
    
    CudaOpenMPTester tester;
    
    if (!tester.initialize()) {
        std::cerr << "Initialization failed" << std::endl;
        return 1;
    }
    
    // 运行各种测试
    tester.testVectorAddition(1024 * 1024);        // 1M elements
    tester.testComplexComputation(1024 * 1024);     // 1M elements
    tester.testOpenMPComputation(1024 * 1024);     // 1M elements
    tester.testHybridComputation(1024 * 1024);     // 1M elements
    
    std::cout << "\n========================================" << std::endl;
    std::cout << "All tests completed!" << std::endl;
    std::cout << "========================================" << std::endl;
    
    return 0;
}