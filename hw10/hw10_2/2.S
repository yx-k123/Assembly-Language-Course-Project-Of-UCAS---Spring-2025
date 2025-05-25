.abicalls
.text
.globl reverse
.type reverse, @function

reverse:
    addiu $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    beqz $a1, restore_and_return     # if length == 0, return
    li $t9, 1
    beq $a1, $t9, restore_and_return # if length == 1, return

    move $s0, $a0    # a0 = int* a
    move $s1, $a1    # a1 = int length

    move $t0, $s0       # p = a
    addiu $t1, $s0, -4   
    sll $t8, $s1, 2     # length * 4
    add $t1, $t1, $t8   # q = a + (length-1)*4

reverse_loop:
    bge $t0, $t1, restore_and_return

    lw $t2, 0($t0)      # t2 = *p
    lw $t3, 0($t1)      # t3 = *q
    sw $t3, 0($t0)      # *p = *q
    sw $t2, 0($t1)      # *q = t2

    addiu $t0, $t0, 4   # p++
    addiu $t1, $t1, -4  # q--

    j reverse_loop

restore_and_return:
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addiu $sp, $sp, 12
    jr $ra

