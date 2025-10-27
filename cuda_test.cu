#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

// CUDA内核函数 - 简单的向量加法
__global__ void vectorAdd(float *a, float *b, float *c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        c[i] = a[i] + b[i];
    }
}

int main() {
    printf("CUDA Batch Parallel Computing Test\n");
    printf("==================================\n\n");
    
    // Check CUDA devices
    int deviceCount;
    cudaError_t error = cudaGetDeviceCount(&deviceCount);
    
    if (error != cudaSuccess) {
        printf("Error: Unable to get CUDA device count\n");
        printf("CUDA Error: %s\n", cudaGetErrorString(error));
        return 1;
    }
    
    printf("Detected %d CUDA devices\n\n", deviceCount);
    
    if (deviceCount == 0) {
        printf("Error: No CUDA devices detected\n");
        return 1;
    }
    
    // Get device information
    for (int i = 0; i < deviceCount; i++) {
        cudaDeviceProp prop;
        cudaGetDeviceProperties(&prop, i);
        
        printf("Device %d: %s\n", i, prop.name);
        printf("  Compute Capability: %d.%d\n", prop.major, prop.minor);
        printf("  Global Memory: %.2f GB\n", prop.totalGlobalMem / (1024.0 * 1024.0 * 1024.0));
        printf("  Shared Memory: %zu KB\n", prop.sharedMemPerBlock / 1024);
        printf("  Max Threads per Block: %d\n", prop.maxThreadsPerBlock);
        printf("  Max Grid Size: %d x %d x %d\n", 
               prop.maxGridSize[0], prop.maxGridSize[1], prop.maxGridSize[2]);
        printf("  Multiprocessor Count: %d\n", prop.multiProcessorCount);
        printf("  Clock Rate: %.2f MHz\n", prop.clockRate / 1000.0);
        printf("  Memory Clock Rate: %.2f MHz\n", prop.memoryClockRate / 1000.0);
        printf("  Memory Bus Width: %d bits\n", prop.memoryBusWidth);
        printf("\n");
    }
    
    // Set current device
    cudaSetDevice(0);
    
    // Test data size
    const int n = 1024 * 1024; // 1M元素
    const size_t size = n * sizeof(float);
    
    printf("Testing vector addition (size: %d elements)\n", n);
    printf("==============================\n");
    
    // Allocate host memory
    float *h_a = (float*)malloc(size);
    float *h_b = (float*)malloc(size);
    float *h_c = (float*)malloc(size);
    
    // Initialize data
    for (int i = 0; i < n; i++) {
        h_a[i] = (float)i;
        h_b[i] = (float)(i * 2);
    }
    
    // Allocate device memory
    float *d_a, *d_b, *d_c;
    cudaMalloc(&d_a, size);
    cudaMalloc(&d_b, size);
    cudaMalloc(&d_c, size);
    
    // Copy data to device
    cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);
    
    // Configure kernel parameters
    int blockSize = 256;
    int gridSize = (n + blockSize - 1) / blockSize;
    
    printf("Grid Size: %d blocks\n", gridSize);
    printf("Block Size: %d threads\n", blockSize);
    printf("Total Threads: %d\n\n", gridSize * blockSize);
    
    // Create CUDA events for timing
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    
    // Warm up
    vectorAdd<<<gridSize, blockSize>>>(d_a, d_b, d_c, n);
    cudaDeviceSynchronize();
    
    // Time CUDA computation
    cudaEventRecord(start);
    
    // Execute multiple calculations to test batch processing capability
    const int iterations = 100;
    for (int i = 0; i < iterations; i++) {
        vectorAdd<<<gridSize, blockSize>>>(d_a, d_b, d_c, n);
    }
    
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    // Calculate time
    float milliseconds = 0;
    cudaEventElapsedTime(&milliseconds, start, stop);
    
    // Copy results back to host
    cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);
    
    // Verify results
    bool correct = true;
    for (int i = 0; i < n; i++) {
        if (fabs(h_c[i] - (h_a[i] + h_b[i])) > 1e-5) {
            correct = false;
            break;
        }
    }
    
    // Output results
    printf("Calculation Result: %s\n", correct ? "Correct" : "Incorrect");
    printf("Execution Time: %.3f milliseconds (%d iterations)\n", milliseconds, iterations);
    printf("Average per iteration: %.6f milliseconds\n", milliseconds / iterations);
    printf("Throughput: %.2f GFLOPS\n", 
           (2.0 * n * iterations) / (milliseconds / 1000.0) / 1e9);
    
    // 测试内存带宽
    printf("\nMemory Bandwidth Test\n");
    printf("============\n");
    
    cudaEventRecord(start);
    for (int i = 0; i < iterations; i++) {
        cudaMemcpy(d_c, d_a, size, cudaMemcpyDeviceToDevice);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    
    cudaEventElapsedTime(&milliseconds, start, stop);
    float bandwidth = (size * iterations) / (milliseconds / 1000.0) / (1024.0 * 1024.0 * 1024.0);
    printf("Memory Bandwidth: %.2f GB/s\n", bandwidth);
    
    // Cleanup
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    free(h_a);
    free(h_b);
    free(h_c);
    
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    
    printf("\nCUDA batch parallel computing test completed!\n");
    
    return 0;
}
