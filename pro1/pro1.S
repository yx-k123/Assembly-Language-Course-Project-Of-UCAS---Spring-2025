.section .data
	size: .quad 0       # size of word read -> movq %rax, $size
	word_lim: .quad 20
	p_txt: .quad 0		# point in txt_buffer
	head: .quad 0  		# tree head
.section .bss
	txt_buffer: .space 1024
	word_buffer: .space 20
.section .text
	.global _start
_start:
	

# Use: %rax, %rbx
# Output: %rax
.globl getword
	.type getword, @function
getword:
	leaq word_buffer(%rip), %rdx        # char* word
	leap p_txt, %rsi					# static char* p
	leaq txt_buffer(%rip), %rcx         # %rdx = $(filebuf + size)
	addq size(%rip), %rcx
	
L1:
	cmpq %rcx, %rsi
	jge L2
	cmpq (%rsi), $' '
	jne L2
	incq %rsi
	jmp L1

L2:
	cmpq %rsi, %rcx
	je L3
	cmpq (%rsi), $0
	je L3

	movq (%rsi), %rax
	movq %rax, (%rdx)
	incq %rdx

	movq (%rsi), %rax
	call isalpha
	cmpq %rax, $-1
	je L4

	movq word_lim(%rip), %rbx
L5:
	incq %rsi
	cmpq %rdx, %rsi
	jge L6

	decq %rbx
	cmpq $0, %rbx
	jle L6

	movq (%rsi), %rax
	movq %rax, (%rdx)
	call is_alpha
	cmpq $-1, %rax
	je L6
	
	incq %rdx
	jmp L5

L6:
	movq $0, (%rdx)
	leaq word_buffer(%rip), %rdx
	movq (%rdx), %rax					# return word[0]
	ret

L3:
	movq $0, %rax
	ret

L4:
	movq $0, (%rdx)
	incq %rsi
	movq (%rsi), %rax					# return *p++
	ret

# Input: %rax
.globl isalpha
	.type isalpha, @function
isalpha:
	cmpq $'a', %rax          # Check if character >= 'a'
	jl not_alpha
	cmpq $'z', %rax          # Check if character <= 'z'
	jle is_alpha
	cmpq $'A', %rax          # Check if character >= 'A'
	jl not_alpha
	cmpq $'Z', %rax          # Check if character <= 'Z'
	jg not_alpha

is_alpha:
	movq $1, %rax            # Return 1 (true)
	ret

not_alpha:
	movq $-1, %rax            # Return -1 (false)
	ret

# Input: %rsi = array, %rdx = length
.globl as_puts
	.type as_puts, @function
as_puts:
	movq $1, %rax
	movq $1, %rdi
	syscall
	ret

.globl as_exit
	.type as_exit, @function
as_exit:
	movq $60, %rax
	xor %rdi, %rdi
	syscall
	ret

# Input: %rsi = array, %rdx = length
.globl read_txt
	.type read_txt, @function
read_txt:
	movq $0, %rax            
	movq $0, %rdi            
	syscall
	ret
	