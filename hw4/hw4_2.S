#hw4_2.S

.section .text
    .global _start
_start:

    movq 0x100(%r8, %r9, 8), %rax
    leaq 0x1234(%rip), %rdx
