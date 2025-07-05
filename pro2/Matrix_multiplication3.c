#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define N 1024           // 矩阵大小
#define BLOCK_SIZE 384  // 分块大小

void block_matrix_multiply(double *A, double *B, double *C, int n, int block_size) {
    int i, j, k, ii, jj, kk;
    memset(C, 0, sizeof(double) * n * n);

    for (ii = 0; ii < n; ii += block_size) {
        for (jj = 0; jj < n; jj += block_size) {
            for (kk = 0; kk < n; kk += block_size) {
                for (i = ii; i < ii + block_size && i < n; ++i) {
                    for (j = jj; j < jj + block_size && j < n; ++j) {
                        double sum = C[i * n + j];
                        for (k = kk; k < kk + block_size && k < n; ++k) {
                            sum += A[i * n + k] * B[k * n + j];
                        }
                        C[i * n + j] = sum;
                    }
                }
            }
        }
    }
}

int main() {
    double *A = (double*)malloc(sizeof(double) * N * N);
    double *B = (double*)malloc(sizeof(double) * N * N);
    double *C = (double*)malloc(sizeof(double) * N * N);

    // 初始化A和B
    for (int i = 0; i < N * N; ++i) {
        A[i] = i % 100;
        B[i] = (i * 2) % 100;
    }

    clock_t start = clock();

    block_matrix_multiply(A, B, C, N, BLOCK_SIZE);

    clock_t end = clock();
    double elapsed = (double)(end - start) / CLOCKS_PER_SEC;

    printf("Matrix multiplication took %.3f seconds.\n", elapsed);

    free(A);
    free(B);
    free(C);
    return 0;
}