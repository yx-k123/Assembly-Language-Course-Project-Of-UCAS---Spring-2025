void my_memcpy(void *dest, const void *src, unsigned int n) {
    char *d = (char *)dest;
    const char *s = (const char *)src;
    
    // 小数据直接复制
    if (n <= 8) {
        while (n--) *d++ = *s++;
        return;
    }

    // 大块数据使用汇编优化（32位兼容版本）
    unsigned int chunks = n / 8;  // 改为8字节块
    unsigned int remainder = n % 8;
    
    // 使用32位寄存器进行优化复制
    asm volatile (
        "1:\n\t"                        // 循环标签
        "movl (%1), %%eax\n\t"          // 从源加载4字节到EAX
        "movl 4(%1), %%edx\n\t"         // 从源+4加载4字节到EDX
        "movl %%eax, (%0)\n\t"          // 存储4字节到目标
        "movl %%edx, 4(%0)\n\t"         // 存储4字节到目标+4
        "add $8, %1\n\t"               // 源指针前进8字节
        "add $8, %0\n\t"               // 目标指针前进8字节
        "dec %2\n\t"                   // 块计数器减1
        "jnz 1b\n\t"                   // 如果计数器不为零则跳回
        
        // 处理剩余字节
        "test %3, %3\n\t"              // 检查剩余字节数
        "jz 3f\n\t"                    // 如果为零则跳转到结束
        "2:\n\t"                       // 剩余字节处理标签
        "movb (%1), %%al\n\t"          // 加载1字节到AL
        "movb %%al, (%0)\n\t"          // 存储1字节到目标
        "inc %1\n\t"                   // 源指针+1
        "inc %0\n\t"                   // 目标指针+1
        "dec %3\n\t"                   // 剩余计数器减1
        "jnz 2b\n\t"                   // 如果剩余不为零则继续
        "3:\n"                         // 结束标签
        
        : "+r" (d), "+r" (s)           // 输入/输出：指针（会被修改）
        : "r" (chunks), "r" (remainder) // 输入：块数和剩余字节
        : "eax", "edx", "memory", "cc"  // 破坏声明（32位寄存器）
    );
}