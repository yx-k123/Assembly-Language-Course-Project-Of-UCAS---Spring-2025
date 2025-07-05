#hw1.S
.section .data 
	  output: .ascii "University of CAS\n"
	  output_len = . - output
.section .text
.global _start
_start:
/* output like printf*/
	movq $1, %rax
	movq $1, %rdi
	movq $output, %rsi
	movq $output_len, %rdx
	syscall
/*exit*/
	movq $60, %rax
	movq $0, %rdi
	syscall

