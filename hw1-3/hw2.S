.section .data

	stringvar:  .ascii "0123456789abcdef"

.section .text

	.global _start
_start:
	#reverse
	movl $stringvar, %eax
	movl $8, %ecx

loop_start:
	movl %ecx, %esi
	subl $1, %esi
	movb (%eax,%esi,2), %bl     # 取第2i个字符
	movb 1(%eax,%esi,2), %dl    # 取第2i+1个字符
	movb %dl, (%eax,%esi,2)     # 交换位置
	movb %bl, 1(%eax,%esi,2)

	loop loop_start
	
	#output
	movl $4, %eax
	movl $1, %ebx
	movl $stringvar, %ecx
	movl $16, %edx
	int $0x80

	#exit
	movl $1, %eax
	movl $0, %ebx
	int $0x80
