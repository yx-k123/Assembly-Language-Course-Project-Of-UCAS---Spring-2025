#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <immintrin.h>

void matrix_multiply(int **a, int **b, int **c, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            c[i][j] = 0;
            for (int k = 0; k < n; k++) {
                c[i][j] += a[i][k] * b[k][j];
            }
        }
    }
}

int main() {
    int n = 1024;

    // 动态分配二维数组
    int **a = malloc(n * sizeof(int *));
    int **b = malloc(n * sizeof(int *));
    int **c = malloc(n * sizeof(int *));
    for (int i = 0; i < n; i++) {
        a[i] = malloc(n * sizeof(int));
        b[i] = malloc(n * sizeof(int));
        c[i] = malloc(n * sizeof(int));
    }

    // 初始化矩阵
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            a[i][j] = i + j;
            b[i][j] = i - j;
        }
    }


    clock_t start = clock();
    matrix_multiply(a, b, c, n);
    clock_t end = clock();

    double time_spent = (double)(end - start) / CLOCKS_PER_SEC;
    printf("Time taken for matrix multiplication: %f seconds\n", time_spent);

    // 释放内存
    for (int i = 0; i < n; i++) {
        free(a[i]);
        free(b[i]);
        free(c[i]);
    }
    free(a);
    free(b);
    free(c);

    return 0;
}