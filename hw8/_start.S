.section .text
.global _start

_start:
    pushl $0x0812abcd   # 测试用例1
    call print_hex
    addl $4, %esp
    
    pushl $0x80001234   # 测试用例2
    call print_hex
    addl $4, %esp
    
    # 退出程序
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    