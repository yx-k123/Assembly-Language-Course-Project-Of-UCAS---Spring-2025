	.section .text
	.global bubblesort
	.type bubblesort, @function
bubblesort:
	pushl %ebp
	movl %esp, %ebp
	pushl %esi				# callee saved
	pushl %edi
	pushl %ebx
	
	movl 8(%ebp), %esi		# arr[]
	movl 12(%ebp), %ecx		# n

	cmpl $1, %ecx			# n<=1 ?
	jle end_sort

outer_loop:
	movl %ecx, %edx			# save the n to edx
	dec %edx
	movl $0, %ebx			# index j

inner_loop:
	movl (%esi, %ebx, 4), %eax		# array[j]
	movl 4(%esi, %ebx, 4), %edi		# array[j+1]
	cmp %eax, %edi
	jge no_swap
	
	movl %edi, (%esi, %ebx, 4)		# swap array[j] and array[j+1]
	movl %eax, 4(%esi, %ebx, 4)

no_swap:
	inc %ebx
	cmp %ebx, %edx			# compare j with n-i-1
	jg inner_loop			# loop from 0 to n-i-1

	dec %ecx
	cmp $1, %ecx			# loop n~2, n-1 times.
	jg outer_loop

end_sort:

	popl %ebx
	popl %edi
	popl %esi
	
	leave
	ret
