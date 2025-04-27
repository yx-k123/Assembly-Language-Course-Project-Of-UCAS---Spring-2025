.section .data
iostring:
    .asciz "ab1g2hA0H56po9wK78nB"
.section .text
.globl _start
_start:

#change
    movl $iostring, %eax
    movl $20, %ecx

loop1:
    decl %ecx
    movb (%eax, %ecx, 1), %dl
    cmpb $97, %dl
    jb loop2
    cmpb $122, %dl
    ja loop2
    subb $32, %dl
    movb %dl, (%eax, %ecx, 1)

loop2:
    cmpl $0, %ecx
    ja loop1

#output
    movl $4, %eax
    movl $1, %ebx
    movl $iostring, %ecx
    movl $20, %edx
    int $0x80

#exit
    movl $1, %eax
    movl $0, %ebx
    int $0x80
