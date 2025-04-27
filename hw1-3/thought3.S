.section .data
    sum: .long 0
    message: .string "The sum of prime numbers from 1 to 1000: " 
    sum_str: .space 7

.section .text
    .globl _start

_start:
    movl $0, %eax
    movl $1000, %ecx

loop1:
    movl %ecx, %ebx
    push %ecx
    call is_or_not_p
    pop %ecx
    loop loop1

    # 输出  
    movl $4, %eax
    movl $1, %ebx 
    leal message, %ecx
    movl $41, %edx
    int $0x80

    movl sum, %eax
    call print

    # 退出   
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

is_or_not_p:
    movl %ebx, %eax

    cmpl $1, %eax
    je not_q

    decl %eax
    movl %eax, %ecx
loop2:  
    cmpl $1, %ecx
    je is_p

    movl %ebx, %eax
    movl $0, %edx
    divl %ecx

    cmpl $0, %edx
    je not_q

    loop loop2
is_p:
    addl %ebx, sum
    # movl %ebx, %eax
    # call print
not_q:
    ret


print:
    leal sum_str+6, %edi
    movl $0, (%edi) 
    decl %edi
    movl $'\n', (%edi)
    movl $5, %ecx

loop3:
    movl $0, %edx
    movl $10, %ebx
    divl %ebx
    addb $'0', %dl
    decl %edi
    movb %dl, (%edi)
    loop loop3

    leal sum_str+6, %edi

    # 输出  
    movl $4, %eax
    movl $1, %ebx 
    leal sum_str, %ecx
    movl $7, %edx
    int $0x80 

    ret
