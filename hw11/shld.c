unsigned int shld5(unsigned int a, unsigned int b) {
    unsigned int result;
    // result = (a << 5) |( b>>(32-5));        此语句用嵌入式汇编编写
    asm (
        "shld $5, %1, %0"
        : "=r" (result)  // output operand
        : "r" (b), "0" (a)  // input operands
    );
    return result;
}