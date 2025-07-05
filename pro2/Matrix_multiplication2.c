#define _POSIX_C_SOURCE 199309L
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

#define N 4096  // 矩阵大小
#define NUM_THREADS 32  // 线程数

double A[N][N], B[N][N], C[N][N];

typedef struct {
    int row_start;
    int row_end;
} ThreadData;

void* multiply(void* arg) {
    ThreadData* data = (ThreadData*)arg;
    for (int i = data->row_start; i < data->row_end; ++i) {
        for (int j = 0; j < N; ++j) {
            double sum = 0;
            for (int k = 0; k < N; ++k) {
                sum += A[i][k] * B[k][j];
            }
            C[i][j] = sum;
        }
    }
    return NULL;
}

int main() {
    // 初始化矩阵
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j) {
            A[i][j] = rand() % 10;
            B[i][j] = rand() % 10;
            C[i][j] = 0;
        }

    pthread_t threads[NUM_THREADS];
    ThreadData thread_data[NUM_THREADS];

    int rows_per_thread = N / NUM_THREADS;
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    // 创建线程
    for (int t = 0; t < NUM_THREADS; ++t) {
        thread_data[t].row_start = t * rows_per_thread;
        thread_data[t].row_end = (t == NUM_THREADS - 1) ? N : (t + 1) * rows_per_thread;
        pthread_create(&threads[t], NULL, multiply, &thread_data[t]);
    }

    // 等待线程结束
    for (int t = 0; t < NUM_THREADS; ++t) {
        pthread_join(threads[t], NULL);
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double elapsed = (end.tv_sec - start.tv_sec) + 
                     (end.tv_nsec - start.tv_nsec) / 1e9;
    printf("Time taken: %.6f seconds\n", elapsed);

    return 0;
}