	.global bubblesort
bubblesort:
	mov x9, x1	// n

outer_loop:
	sub w10, w9, #1		// n-1
	mov w11, #0			// j

inner_loop:
	ldr w12, [x0, x11, lsl 2]
	add w14, w11, #1
	ldr w13, [x0, x14, lsl 2]
	cmp w12, w13
	ble skip_swap
	str w13, [x0, x11, lsl 2]
	str w12, [x0, x14, lsl 2]
skip_swap:
	add w11, w11, #1
	cmp w11, w10	// n-i-1
	blt inner_loop

	sub w9, w9, #1
	cmp w9, #1
	bgt outer_loop

	ret
	
