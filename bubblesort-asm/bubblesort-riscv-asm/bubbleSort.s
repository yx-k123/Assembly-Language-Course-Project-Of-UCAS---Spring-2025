	.global bubblesort
bubblesort:

outer_loop:
	addi t0, a1,-1		# n-1
	mv t1, zero		# j

inner_loop:
	slli t2, t1, 2		
	add t3, a0, t2		# &arr[j]
	lw t4, 0(t3)
	addi t5, t1, 1
	slli t2, t5, 2
	add t6, a0, t2		# &arr[j+1]
	lw t5,0(t6)	
	slt t2, t5, t4	
	beqz t2, skip_swap
	sw t5, 0(t3)
	sw t4, 0(t6)
skip_swap:
	addi t1, t1, 1		# j++
	blt t1, t0, inner_loop	# n-i-1
	addi a1, a1, -1
	bgtz a1, outer_loop

	jalr zero, ra, 0	
	
