	.file	"cread_alt.c"
	.text
	.globl	cread_alt
	.type	cread_alt, @function
cread_alt:
	endbr64
	pushq	%rbp
	movq	%rsp, %rbp
	movq	%rdi, -24(%rbp)
	cmpq	$0, -24(%rbp)
	je	.L2
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	jmp	.L3
.L2:
	movl	$0, %eax
.L3:
	movq	%rax, -8(%rbp)
	movq	-8(%rbp), %rax
	popq	%rbp
	ret
	.size	cread_alt, .-cread_alt
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
