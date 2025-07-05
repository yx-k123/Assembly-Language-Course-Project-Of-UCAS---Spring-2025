#include <stdio.h>
#include <cuda_runtime.h>

#define N 4096  // 矩阵大小
#define BLOCK_SIZE 32  // 每个线程块的大小

// GPU 核函数：使用共享内存优化的矩阵乘法
__global__ void matmul_shared(const float *A, const float *B, float *C, int n) {
    __shared__ float Asub[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float Bsub[BLOCK_SIZE][BLOCK_SIZE];

    int row = blockIdx.y * blockDim.y + threadIdx.y; // 当前线程对应的行
    int col = blockIdx.x * blockDim.x + threadIdx.x; // 当前线程对应的列

    float sum = 0.0f;

    for (int t = 0; t < (n + BLOCK_SIZE - 1) / BLOCK_SIZE; ++t) {
        // 加载 A 和 B 的子块到共享内存
        if (row < n && t * BLOCK_SIZE + threadIdx.x < n) {
            Asub[threadIdx.y][threadIdx.x] = A[row * n + t * BLOCK_SIZE + threadIdx.x];
        } else {
            Asub[threadIdx.y][threadIdx.x] = 0.0f;
        }

        if (col < n && t * BLOCK_SIZE + threadIdx.y < n) {
            Bsub[threadIdx.y][threadIdx.x] = B[(t * BLOCK_SIZE + threadIdx.y) * n + col];
        } else {
            Bsub[threadIdx.y][threadIdx.x] = 0.0f;
        }

        __syncthreads(); // 确保所有线程加载完成

        // 计算子块的结果
        for (int k = 0; k < BLOCK_SIZE; ++k) {
            sum += Asub[threadIdx.y][k] * Bsub[k][threadIdx.x];
        }

        __syncthreads(); // 确保所有线程完成计算
    }

    // 写入结果矩阵
    if (row < n && col < n) {
        C[row * n + col] = sum;
    }
}

int main() {
    int size = N * N * sizeof(float);

    // 分配主机内存
    float *h_A = (float *)malloc(size);
    float *h_B = (float *)malloc(size);
    float *h_C = (float *)malloc(size);

    // 初始化矩阵 A 和 B
    for (int i = 0; i < N * N; ++i) {
        h_A[i] = (float)(rand() % 100);
        h_B[i] = (float)(rand() % 100);
    }

    // 分配设备内存
    float *d_A, *d_B, *d_C;
    cudaMalloc((void **)&d_A, size);
    cudaMalloc((void **)&d_B, size);
    cudaMalloc((void **)&d_C, size);

    // 将数据从主机复制到设备
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size, cudaMemcpyHostToDevice);

    // 定义线程块和网格大小
    dim3 blockDim(BLOCK_SIZE, BLOCK_SIZE); // 每个线程块 BLOCK_SIZE x BLOCK_SIZE 个线程
    dim3 gridDim((N + blockDim.x - 1) / blockDim.x, (N + blockDim.y - 1) / blockDim.y);

    // 启动计时器
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);

    // 启动 GPU 核函数
    matmul_shared<<<gridDim, blockDim>>>(d_A, d_B, d_C, N);

    // 停止计时器
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    printf("Matrix multiplication took %.6f seconds.\n", elapsedTime/1000.0f);

    // 将结果从设备复制回主机
    cudaMemcpy(h_C, d_C, size, cudaMemcpyDeviceToHost);

    // 释放设备内存
    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    // 释放主机内存
    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}