#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <cublas_v2.h>
#include <cublasLt.h>
#include <math.h>
#include <chrono>
#include <vector>

// TexasSolver专用CUDA测试程序
// 模拟德州扑克求解器的并行计算需求

// 模拟扑克手牌评估内核
__global__ void evaluateHands(float* hands, float* results, int numHands) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < numHands) {
        // 模拟复杂的手牌评估计算
        float handValue = 0.0f;
        for (int i = 0; i < 100; i++) {
            handValue += sinf(hands[idx] + i) * cosf(hands[idx] * i);
        }
        results[idx] = handValue;
    }
}

// 模拟CFR算法中的策略更新
__global__ void updateStrategy(float* regrets, float* strategies, float* probabilities, int numActions) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < numActions) {
        // 模拟CFR策略更新计算
        float regret = regrets[idx];
        float prob = probabilities[idx];
        
        // 复杂的策略计算
        float newStrategy = 0.0f;
        for (int i = 0; i < 50; i++) {
            newStrategy += regret * prob * sinf(idx + i) * cosf(regret + i);
        }
        strategies[idx] = newStrategy;
    }
}

// 模拟游戏树节点计算
__global__ void computeGameTreeNode(float* nodeData, float* results, int numNodes) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < numNodes) {
        // 模拟游戏树节点的复杂计算
        float nodeValue = 0.0f;
        for (int i = 0; i < 200; i++) {
            nodeValue += nodeData[idx] * expf(-i * 0.1f) * sinf(idx * i);
        }
        results[idx] = nodeValue;
    }
}

// 测试内存带宽和延迟
__global__ void memoryBandwidthTest(float* data, int size) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < size) {
        // 模拟大量内存访问
        float sum = 0.0f;
        for (int i = 0; i < 1000; i++) {
            sum += data[(idx + i) % size];
        }
        data[idx] = sum;
    }
}

int main() {
    printf("========================================\n");
    printf("TexasSolver CUDA 11 专用性能测试\n");
    printf("========================================\n\n");
    
    // 检查CUDA设备
    int deviceCount;
    cudaError_t error = cudaGetDeviceCount(&deviceCount);
    
    if (error != cudaSuccess) {
        printf("错误: 无法获取CUDA设备数量\n");
        printf("CUDA错误: %s\n", cudaGetErrorString(error));
        return 1;
    }
    
    printf("检测到 %d 个CUDA设备\n\n", deviceCount);
    
    if (deviceCount == 0) {
        printf("错误: 未检测到CUDA设备\n");
        return 1;
    }
    
    // 获取设备信息
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);
    
    printf("设备信息:\n");
    printf("  名称: %s\n", prop.name);
    printf("  计算能力: %d.%d\n", prop.major, prop.minor);
    printf("  全局内存: %.2f GB\n", prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0));
    printf("  共享内存: %zu KB\n", prop.sharedMemPerBlock / 1024);
    printf("  每块最大线程数: %d\n", prop.maxThreadsPerBlock);
    printf("  多处理器数量: %d\n", prop.multiProcessorCount);
    printf("  时钟频率: %.2f MHz\n", prop.clockRate / 1000.0);
    printf("  内存时钟频率: %.2f MHz\n", prop.memoryClockRate / 1000.0);
    printf("  内存总线宽度: %d bits\n", prop.memoryBusWidth);
    printf("\n");
    
    // 检查计算能力是否满足TexasSolver要求
    if (prop.major < 6) {
        printf("警告: GPU计算能力 %d.%d 可能不满足TexasSolver要求\n", prop.major, prop.minor);
        printf("TexasSolver推荐使用计算能力6.0以上的GPU\n\n");
    } else {
        printf("✓ GPU计算能力满足TexasSolver要求\n\n");
    }
    
    // 检查内存是否充足
    float totalMemoryGB = prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0);
    if (totalMemoryGB < 4.0f) {
        printf("警告: GPU内存 %.2f GB 可能不足以处理大型TexasSolver问题\n", totalMemoryGB);
        printf("TexasSolver推荐至少4GB GPU内存\n\n");
    } else {
        printf("✓ GPU内存充足 (%.2f GB)\n\n", totalMemoryGB);
    }
    
    // 设置当前设备
    cudaSetDevice(0);
    
    // 初始化cuBLAS
    cublasHandle_t cublasHandle;
    cublasStatus_t cublasStatus = cublasCreate(&cublasHandle);
    if (cublasStatus != CUBLAS_STATUS_SUCCESS) {
        printf("错误: cuBLAS初始化失败\n");
        return 1;
    }
    printf("✓ cuBLAS库初始化成功\n\n");
    
    // 测试1: 手牌评估性能
    printf("测试1: 手牌评估并行计算性能\n");
    printf("==============================\n");
    
    const int numHands = 1024 * 1024; // 1M手牌
    const size_t handSize = numHands * sizeof(float);
    
    float *h_hands = (float*)malloc(handSize);
    float *h_results = (float*)malloc(handSize);
    float *d_hands, *d_results;
    
    // 初始化测试数据
    for (int i = 0; i < numHands; i++) {
        h_hands[i] = (float)(i % 1000) / 1000.0f;
    }
    
    // 分配GPU内存
    cudaMalloc(&d_hands, handSize);
    cudaMalloc(&d_results, handSize);
    
    // 复制数据到GPU
    cudaMemcpy(d_hands, h_hands, handSize, cudaMemcpyHostToDevice);
    
    // 配置内核参数
    int blockSize = 256;
    int gridSize = (numHands + blockSize - 1) / blockSize;
    
    printf("网格大小: %d 块\n", gridSize);
    printf("块大小: %d 线程\n", blockSize);
    printf("总线程数: %d\n", gridSize * blockSize);
    
    // 创建CUDA事件用于计时
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    // 预热
    evaluateHands<<<gridSize, blockSize>>>(d_hands, d_results, numHands);
    cudaDeviceSynchronize();
    
    // 计时手牌评估
    cudaEventRecord(start);
    
    const int iterations = 100;
    for (int i = 0; i < iterations; i++) {
        evaluateHands<<<gridSize, blockSize>>>(d_hands, d_results, numHands);
    }
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    printf("执行时间: %.3f 毫秒 (%d 次迭代)\n", milliseconds, iterations);
    printf("平均每次迭代: %.6f 毫秒\n", milliseconds / iterations);
    printf("吞吐量: %.2f 百万手牌/秒\n", (numHands * iterations) / (milliseconds / 1000.0) / 1e6);
    
    // 测试2: CFR策略更新性能
    printf("\n测试2: CFR策略更新并行计算性能\n");
    printf("================================\n");
    
    const int numActions = 512 * 1024; // 512K动作
    const size_t actionSize = numActions * sizeof(float);
    
    float *d_regrets, *d_strategies, *d_probabilities;
    cudaMalloc(&d_regrets, actionSize);
    cudaMalloc(&d_strategies, actionSize);
    cudaMalloc(&d_probabilities, actionSize);
    
    // 初始化策略数据
    float *h_regrets = (float*)malloc(actionSize);
    float *h_probabilities = (float*)malloc(actionSize);
    
    for (int i = 0; i < numActions; i++) {
        h_regrets[i] = (float)(i % 100) / 100.0f;
        h_probabilities[i] = 1.0f / numActions;
    }
    
    cudaMemcpy(d_regrets, h_regrets, actionSize, cudaMemcpyHostToDevice);
    cudaMemcpy(d_probabilities, h_probabilities, actionSize, cudaMemcpyHostToDevice);
    
    // 配置内核参数
    int actionBlockSize = 256;
    int actionGridSize = (numActions + actionBlockSize - 1) / actionBlockSize;
    
    // 计时CFR策略更新
    cudaEventRecord(start);
    
    for (int i = 0; i < iterations; i++) {
        updateStrategy<<<actionGridSize, actionBlockSize>>>(d_regrets, d_strategies, d_probabilities, numActions);
    }
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    printf("执行时间: %.3f 毫秒 (%d 次迭代)\n", milliseconds, iterations);
    printf("平均每次迭代: %.6f 毫秒\n", milliseconds / iterations);
    printf("吞吐量: %.2f 百万动作/秒\n", (numActions * iterations) / (milliseconds / 1000.0) / 1e6);
    
    // 测试3: 游戏树节点计算性能
    printf("\n测试3: 游戏树节点计算性能\n");
    printf("==========================\n");
    
    const int numNodes = 256 * 1024; // 256K节点
    const size_t nodeSize = numNodes * sizeof(float);
    
    float *d_nodeData, *d_nodeResults;
    cudaMalloc(&d_nodeData, nodeSize);
    cudaMalloc(&d_nodeResults, nodeSize);
    
    // 初始化节点数据
    float *h_nodeData = (float*)malloc(nodeSize);
    for (int i = 0; i < numNodes; i++) {
        h_nodeData[i] = (float)(i % 50) / 50.0f;
    }
    
    cudaMemcpy(d_nodeData, h_nodeData, nodeSize, cudaMemcpyHostToDevice);
    
    // 配置内核参数
    int nodeBlockSize = 256;
    int nodeGridSize = (numNodes + nodeBlockSize - 1) / nodeBlockSize;
    
    // 计时游戏树节点计算
    cudaEventRecord(start);
    
    for (int i = 0; i < iterations; i++) {
        computeGameTreeNode<<<nodeGridSize, nodeBlockSize>>>(d_nodeData, d_nodeResults, numNodes);
    }
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    printf("执行时间: %.3f 毫秒 (%d 次迭代)\n", milliseconds, iterations);
    printf("平均每次迭代: %.6f 毫秒\n", milliseconds / iterations);
    printf("吞吐量: %.2f 百万节点/秒\n", (numNodes * iterations) / (milliseconds / 1000.0) / 1e6);
    
    // 测试4: 内存带宽测试
    printf("\n测试4: GPU内存带宽测试\n");
    printf("======================\n");
    
    const int memTestSize = 1024 * 1024; // 1M元素
    const size_t memTestBytes = memTestSize * sizeof(float);
    
    float *d_memTest;
    cudaMalloc(&d_memTest, memTestBytes);
    
    // 初始化内存测试数据
    float *h_memTest = (float*)malloc(memTestBytes);
    for (int i = 0; i < memTestSize; i++) {
        h_memTest[i] = (float)i;
    }
    cudaMemcpy(d_memTest, h_memTest, memTestBytes, cudaMemcpyHostToDevice);
    
    // 配置内核参数
    int memBlockSize = 256;
    int memGridSize = (memTestSize + memBlockSize - 1) / memBlockSize;
    
    // 计时内存带宽测试
    cudaEventRecord(start);
    
    for (int i = 0; i < iterations; i++) {
        memoryBandwidthTest<<<memGridSize, memBlockSize>>>(d_memTest, memTestSize);
    }
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    float bandwidth = (memTestBytes * iterations) / (milliseconds / 1000.0) / (1024.0 * 1024.0 * 1024.0);
    printf("内存带宽: %.2f GB/s\n", bandwidth);
    
    // 测试5: cuBLAS矩阵运算性能
    printf("\n测试5: cuBLAS矩阵运算性能\n");
    printf("==========================\n");
    
    const int matrixSize = 1024;
    const size_t matrixBytes = matrixSize * matrixSize * sizeof(float);
    
    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, matrixBytes);
    cudaMalloc(&d_B, matrixBytes);
    cudaMalloc(&d_C, matrixBytes);
    
    // 初始化矩阵数据
    float *h_A = (float*)malloc(matrixBytes);
    float *h_B = (float*)malloc(matrixBytes);
    
    for (int i = 0; i < matrixSize * matrixSize; i++) {
        h_A[i] = (float)(i % 100) / 100.0f;
        h_B[i] = (float)((i + 1) % 100) / 100.0f;
    }
    
    cudaMemcpy(d_A, h_A, matrixBytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, matrixBytes, cudaMemcpyHostToDevice);
    
    // 计时矩阵乘法
    cudaEventRecord(start);
    
    const float alpha = 1.0f, beta = 0.0f;
    for (int i = 0; i < iterations; i++) {
        cublasSgemm(cublasHandle, CUBLAS_OP_N, CUBLAS_OP_N,
                    matrixSize, matrixSize, matrixSize,
                    &alpha, d_A, matrixSize, d_B, matrixSize,
                    &beta, d_C, matrixSize);
    }
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    printf("矩阵大小: %dx%d\n", matrixSize, matrixSize);
    printf("执行时间: %.3f 毫秒 (%d 次迭代)\n", milliseconds, iterations);
    printf("平均每次迭代: %.6f 毫秒\n", milliseconds / iterations);
    printf("计算性能: %.2f GFLOPS\n", 
           (2.0 * matrixSize * matrixSize * matrixSize * iterations) / (milliseconds / 1000.0) / 1e9);
    
    // 清理资源
    cudaFree(d_hands);
    cudaFree(d_results);
    cudaFree(d_regrets);
    cudaFree(d_strategies);
    cudaFree(d_probabilities);
    cudaFree(d_nodeData);
    cudaFree(d_nodeResults);
    cudaFree(d_memTest);
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    
    free(h_hands);
    free(h_results);
    free(h_regrets);
    free(h_probabilities);
    free(h_nodeData);
    free(h_memTest);
    free(h_A);
    free(h_B);
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    cublasDestroy(cublasHandle);
    
    printf("\n========================================\n");
    printf("TexasSolver CUDA 11 性能测试完成\n");
    printf("========================================\n");
    
    printf("\n性能评估:\n");
    if (bandwidth > 100.0f) {
        printf("✓ 内存带宽优秀 (%.2f GB/s)\n", bandwidth);
    } else if (bandwidth > 50.0f) {
        printf("✓ 内存带宽良好 (%.2f GB/s)\n", bandwidth);
    } else {
        printf("⚠ 内存带宽较低 (%.2f GB/s)\n", bandwidth);
    }
    
    if (totalMemoryGB >= 8.0f) {
        printf("✓ GPU内存充足，适合大型TexasSolver问题\n");
    } else if (totalMemoryGB >= 4.0f) {
        printf("✓ GPU内存基本充足，适合中等规模TexasSolver问题\n");
    } else {
        printf("⚠ GPU内存不足，可能限制TexasSolver问题规模\n");
    }
    
    if (prop.multiProcessorCount >= 20) {
        printf("✓ 多处理器数量充足，并行计算能力强\n");
    } else if (prop.multiProcessorCount >= 10) {
        printf("✓ 多处理器数量适中，并行计算能力良好\n");
    } else {
        printf("⚠ 多处理器数量较少，并行计算能力有限\n");
    }
    
    printf("\n建议:\n");
    printf("1. 您的CUDA 11环境%s满足TexasSolver项目需求\n", 
           (prop.major >= 6 && totalMemoryGB >= 4.0f) ? "完全" : "基本");
    printf("2. 建议使用最新的NVIDIA驱动以获得最佳性能\n");
    printf("3. 对于大型问题，建议使用8GB以上GPU内存\n");
    printf("4. 可以考虑安装cuDNN以获得更好的深度学习性能\n");
    
    return 0;
}
