//
// Simple CUDA + OpenMP Test Program
//

#include <iostream>
#include <vector>
#include <chrono>
#include <omp.h>
#include <cuda_runtime.h>
#include <cmath>

// CUDA kernel declarations
extern "C" {
    __global__ void vectorAddKernel(float* a, float* b, float* c, int n);
    __global__ void complexComputationKernel(float* input, float* output, int n);
}

int main() {
    std::cout << "========================================" << std::endl;
    std::cout << "CUDA + OpenMP Hybrid Parallel Computing Test" << std::endl;
    std::cout << "========================================" << std::endl;
    
    // Check CUDA devices
    int deviceCount;
    cudaError_t error = cudaGetDeviceCount(&deviceCount);
    if (error != cudaSuccess || deviceCount == 0) {
        std::cerr << "Error: No CUDA devices detected" << std::endl;
        return 1;
    }
    
    std::cout << "Detected " << deviceCount << " CUDA devices" << std::endl;
    
    // Set device
    cudaSetDevice(0);
    
    // Get device properties
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    std::cout << "Using device: " << prop.name << std::endl;
    std::cout << "Compute capability: " << prop.major << "." << prop.minor << std::endl;
    std::cout << "Global memory: " << prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0) << " GB" << std::endl;
    
    // Configure OpenMP
    int maxThreads = omp_get_max_threads();
    omp_set_num_threads(maxThreads);
    std::cout << "OpenMP max threads: " << maxThreads << std::endl;
    
    // Test 1: Vector Addition
    std::cout << "\n=== Test 1: Vector Addition ===" << std::endl;
    
    const int size = 1024 * 1024; // 1M elements
    
    // Allocate host memory
    std::vector<float> h_a(size);
    std::vector<float> h_b(size);
    std::vector<float> h_c(size);
    
    // Initialize data
    for (int i = 0; i < size; i++) {
        h_a[i] = static_cast<float>(i);
        h_b[i] = static_cast<float>(i * 2);
    }
    
    // Allocate GPU memory
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, size * sizeof(float));
    cudaMalloc(&d_b, size * sizeof(float));
    cudaMalloc(&d_c, size * sizeof(float));
    
    // Copy data to GPU
    cudaMemcpy(d_a, h_a.data(), size * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b.data(), size * sizeof(float), cudaMemcpyHostToDevice);
    
    // Configure kernel parameters
    int blockSize = 256;
    int gridSize = (size + blockSize - 1) / blockSize;
    
    // Create CUDA events for timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    // Warm up
    vectorAddKernel<<<gridSize, blockSize>>>(d_a, d_b, d_c, size);
    cudaDeviceSynchronize();
    
    // Time the computation
    cudaEventRecord(start);
    
    const int iterations = 1000;
    for (int i = 0; i < iterations; i++) {
        vectorAddKernel<<<gridSize, blockSize>>>(d_a, d_b, d_c, size);
    }
    
    cudaEventRecord(stop);
    cudaDeviceSynchronize();
    
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    // Copy result back to host
    cudaMemcpy(h_c.data(), d_c, size * sizeof(float), cudaMemcpyDeviceToHost);
    
    // Verify result
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
    
    // Clean up
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    
    // Test 2: OpenMP Computation
    std::cout << "\n=== Test 2: OpenMP Parallel Computation ===" << std::endl;
    
    std::vector<float> input(size);
    std::vector<float> output(size);
    
    // Initialize data
    for (int i = 0; i < size; i++) {
        input[i] = static_cast<float>(i) / size;
    }
    
    // Time the computation
    auto start_time = std::chrono::high_resolution_clock::now();
    
    const int omp_iterations = 100;
    for (int iter = 0; iter < omp_iterations; iter++) {
        #pragma omp parallel for
        for (int i = 0; i < size; i++) {
            float result = 0.0f;
            for (int j = 0; j < 1000; j++) {
                result += sinf(input[i] + j) * cosf(input[i] * j);
            }
            output[i] = result;
        }
    }
    
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);
    
    std::cout << "OpenMP parallel computation result: Complete" << std::endl;
    std::cout << "Execution time: " << duration.count() << " ms (" << omp_iterations << " iterations)" << std::endl;
    std::cout << "Average per iteration: " << duration.count() / omp_iterations << " ms" << std::endl;
    std::cout << "Throughput: " << (size * omp_iterations) / (duration.count() / 1000.0) / 1e6 << " million elements/sec" << std::endl;
    
    // Test 3: Hybrid Computation
    std::cout << "\n=== Test 3: CUDA + OpenMP Hybrid Computation ===" << std::endl;
    
    // Allocate GPU memory for hybrid test
    float *d_input, *d_output;
    cudaMalloc(&d_input, size * sizeof(float));
    cudaMalloc(&d_output, size * sizeof(float));
    
    // Copy data to GPU
    cudaMemcpy(d_input, input.data(), size * sizeof(float), cudaMemcpyHostToDevice);
    
    // Create CUDA events for timing
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    // Warm up
    complexComputationKernel<<<gridSize, blockSize>>>(d_input, d_output, size);
    cudaDeviceSynchronize();
    
    // Time the hybrid computation
    cudaEventRecord(start);
    
    const int hybrid_iterations = 100;
    for (int iter = 0; iter < hybrid_iterations; iter++) {
        // CUDA computation
        complexComputationKernel<<<gridSize, blockSize>>>(d_input, d_output, size);
        
        // OpenMP computation (parallel with CUDA)
        #pragma omp parallel for
        for (int i = 0; i < size / 2; i++) {
            float result = 0.0f;
            for (int j = 0; j < 500; j++) {
                result += sinf(input[i] + j) * cosf(input[i] * j);
            }
            output[i] = result;
        }
    }
    
    cudaEventRecord(stop);
    cudaDeviceSynchronize();
    
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    std::cout << "CUDA + OpenMP hybrid computation result: Complete" << std::endl;
    std::cout << "Execution time: " << milliseconds << " ms (" << hybrid_iterations << " iterations)" << std::endl;
    std::cout << "Average per iteration: " << milliseconds / hybrid_iterations << " ms" << std::endl;
    std::cout << "Throughput: " << (size * hybrid_iterations) / (milliseconds / 1000.0) / 1e6 << " million elements/sec" << std::endl;
    
    // Clean up
    cudaFree(d_input);
    cudaFree(d_output);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    
    std::cout << "\n========================================" << std::endl;
    std::cout << "All tests completed!" << std::endl;
    std::cout << "========================================" << std::endl;
    
    return 0;
}