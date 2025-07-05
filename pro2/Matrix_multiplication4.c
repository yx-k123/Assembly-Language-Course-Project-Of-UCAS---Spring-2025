#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <immintrin.h>

#define N 1024  // 矩阵大小

void random_init(float *mat, int n) {
    for (int i = 0; i < n * n; ++i) {
        mat[i] = (float)(rand() % 100);
    }
}

void matmul_simd(const float *A, const float *B, float *C, int n) {
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            __m128 sum = _mm_setzero_ps();
            int k;
            for (k = 0; k <= n - 4; k += 4) {
                __m128 a = _mm_loadu_ps(&A[i * n + k]);
                __m128 b = _mm_set_ps(B[(k+3)*n + j], B[(k+2)*n + j], B[(k+1)*n + j], B[k*n + j]);
                sum = _mm_add_ps(sum, _mm_mul_ps(a, b));
            }
            float temp[4];
            _mm_storeu_ps(temp, sum);
            float csum = temp[0] + temp[1] + temp[2] + temp[3];
            // 处理剩余部分
            for (; k < n; ++k) {
                csum += A[i * n + k] * B[k * n + j];
            }
            C[i * n + j] = csum;
        }
    }
}

int main() {
    float *A = (float*)aligned_alloc(16, N * N * sizeof(float));
    float *B = (float*)aligned_alloc(16, N * N * sizeof(float));
    float *C = (float*)aligned_alloc(16, N * N * sizeof(float));

    srand((unsigned)time(NULL));
    random_init(A, N);
    random_init(B, N);

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    matmul_simd(A, B, C, N);

    clock_gettime(CLOCK_MONOTONIC, &end);
    double duration = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    printf("Matrix multiplication took %.6f seconds.\n", duration);

    free(A);
    free(B);
    free(C);
    return 0;
}