#hw4_1.S

.section .text
    .global _start
_start:

    movl 0x10(%ebx, %ecx, 4), %eax       
    addl $0x30, 0x20(%esi, %eax, 2)      
    pushl %ebx
