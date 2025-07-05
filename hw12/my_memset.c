#include <stdio.h>
#include <stdlib.h>
#include <x86intrin.h>
#include <immintrin.h>
#include <pthread.h>

typedef struct {
    unsigned char *start;
    int c;
    size_t size;
} memset_args;

void *basic_memset(void *s, int c, size_t n)
{
    size_t cnt;
    unsigned char *p = s;
    while (cnt < n)
    {
        p[cnt] = (unsigned char)c;
        cnt++;
    }
    return s;
}

void *optimized_memset_simd(void *s, int c, size_t n)
{
    size_t cnt = 0;
    unsigned char *p = (unsigned char *)s;

    // 构造 32 字节的填充值（AVX寄存器宽度）
    __m256i fill_value = _mm256_set1_epi8((unsigned char)c);

    // 使用 AVX 指令进行块填充
    for (; cnt + 32 <= n; cnt += 32) {
        _mm256_storeu_si256((__m256i *)(p + cnt), fill_value);
    }

    // 处理剩余字节
    for (; cnt < n; cnt++) {
        p[cnt] = (unsigned char)c;
    }

    return s;
}

void clear_cache(void *ptr, size_t size) {
    unsigned char *p = (unsigned char *)ptr;
    for (size_t i = 0; i < size; i += 64) {
        _mm_clflush(p + i);
    }
    _mm_sfence();
}

void *threaded_memset(void *args) {
    memset_args *data = (memset_args *)args;
    unsigned char *p = data->start;
    size_t cnt = 0;

    // 构造 32 字节的填充值（AVX寄存器宽度）
    __m256i fill_value = _mm256_set1_epi8((unsigned char)data->c);

    // 使用 AVX 指令进行块填充
    for (; cnt + 32 <= data->size; cnt += 32) {
        _mm256_storeu_si256((__m256i *)(p + cnt), fill_value);
    }

    // 处理剩余字节
    for (; cnt < data->size; cnt++) {
        p[cnt] = (unsigned char)data->c;
    }

    return NULL;
}

void *optimized_memset_multithreaded(void *s, int c, size_t n) {
    size_t num_threads = 32; // 使用 32 个线程
    pthread_t threads[num_threads];
    memset_args args[num_threads];

    size_t chunk_size = n / num_threads;
    for (size_t i = 0; i < num_threads; i++) {
        args[i].start = (unsigned char *)s + i * chunk_size;
        args[i].c = c;
        args[i].size = (i == num_threads - 1) ? (n - i * chunk_size) : chunk_size;
        pthread_create(&threads[i], NULL, threaded_memset, &args[i]);
    }

    for (size_t i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    return s;
}

int main() {
    size_t n = 1000000000; // 测试数组大小
    int itens = 100;

    volatile unsigned char *array = malloc(n); // 使用 volatile 防止优化
    if (!array) {
        perror("malloc failed");
        return 1;
    }

    unsigned long long start, end;
    // clear_cache((void *)array, n); // 清除缓存
    // start = __rdtsc(); // 开始计时
    // optimized_memset_multithreaded((void *)array, 0xFF, n); // 使用多线程优化的 memset
    // end = __rdtsc(); // 结束计时

    unsigned long long total_time = 0;

    for (int i = 0; i < itens; i++) {
        clear_cache((void *)array, n); // 清除缓存
        start = __rdtsc(); // 开始计时
        optimized_memset_multithreaded((void *)array, 0xFF, n); // 使用 SIMD 优化的 memset
        end = __rdtsc(); // 结束计时

        total_time += (end - start);
    }


    double cpe = (double)(total_time) / (n * itens);
    printf("time: %llu cycles\n", total_time);
    printf("CPE: %.5f\n", cpe);

    free((void *)array);
    return 0;
}