.data
    buffer: .space 12          
    input_buffer: .space 32    
    newline: .asciiz "\n"      

.text
.globl __start

__start:
    
    li $v0, 4003               # sys_read
    li $a0, 0                  # stdin
    la $a1, input_buffer       
    li $a2, 32                 
    syscall
    
    la $a0, input_buffer
    jal hex_string_to_int
    
    move $a0, $v0
    jal uint_to_string         
    
    la $t0, buffer
    li $t1, 0
strlen_loop:
    lb $t2, 0($t0)
    beqz $t2, output_result
    addiu $t0, $t0, 1
    addiu $t1, $t1, 1
    j strlen_loop

output_result:
    li $v0, 4004               # sys_write
    li $a0, 1                  # stdout
    la $a1, buffer            
    move $a2, $t1            
    syscall
    
    li $v0, 4004               # sys_write
    li $a0, 1                  # stdout
    la $a1, newline            
    li $a2, 1                  
    syscall
    
    li $v0, 4001
    li $a0, 0                 
    syscall

hex_string_to_int:
    addiu $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)
    
    move $s0, $a0              # $s0 = 字符串地址
    li $v0, 0                  # $v0 = 结果（初始化为0）
    
    # skip "0x" 
    lb $t0, 0($s0)
    bne $t0, '0', hex_convert_loop
    lb $t1, 1($s0)
    bne $t1, 'x', check_upper_x
    addiu $s0, $s0, 2          
    j hex_convert_loop

check_upper_x:
    bne $t1, 'X', hex_convert_loop
    addiu $s0, $s0, 2          
    
hex_convert_loop:
    lb $t0, 0($s0)             
    
    beq $t0, 10, end_hex_convert   
    beqz $t0, end_hex_convert      
    beq $t0, 32, end_hex_convert   
    
    li $t1, -1                
    
    blt $t0, '0', check_hex_alpha
    ble $t0, '9', is_digit
    j check_hex_alpha

is_digit:
    subu $t1, $t0, '0'         
    j valid_hex_char

check_hex_alpha:
    blt $t0, 'a', check_upper_alpha
    ble $t0, 'f', is_lower_hex
    j check_upper_alpha

is_lower_hex:
    subu $t1, $t0, 'a'         
    addiu $t1, $t1, 10         
    j valid_hex_char

check_upper_alpha:
    blt $t0, 'A', end_hex_convert
    bgt $t0, 'F', end_hex_convert
    subu $t1, $t0, 'A'         
    addiu $t1, $t1, 10         

valid_hex_char:
    sll $v0, $v0, 4            
    add $v0, $v0, $t1          
    
    addiu $s0, $s0, 1
    j hex_convert_loop
    
end_hex_convert:
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addiu $sp, $sp, 8
    jr $ra

uint_to_string:
    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0              # $s0 = 输入的数字
    la $s1, buffer             # $s1 = 缓冲区地址
    li $s2, 0                  # $s2 = 字符串长度计数器
    
    # 0
    bnez $s0, convert_loop
    li $t0, '0'                # '0'
    sb $t0, 0($s1)           
    sb $zero, 1($s1)          
    j restore_and_return
    
convert_loop:
    beqz $s0, reverse_string   
    
    # $s0 % 10
    li $t1, 10
    divu $s0, $t1             # $s0 / 10
    mfhi $t0                  # $t0 = $s0 % 10 
    mflo $s0                  # $s0 = $s0 / 10 
    
    addiu $t0, $t0, '0'       
    
    add $t2, $s1, $s2         
    sb $t0, 0($t2)            
    addiu $s2, $s2, 1         
    
    j convert_loop

reverse_string:
    add $t0, $s1, $s2
    sb $zero, 0($t0)
    
    move $t0, $s1             # $t0 = 字符串开始位置
    add $t1, $s1, $s2         # $t1 = 字符串结束位置
    addiu $t1, $t1, -1        
    
reverse_loop:
    bge $t0, $t1, restore_and_return  
    
    lb $t2, 0($t0)            
    lb $t3, 0($t1)            
    sb $t3, 0($t0)           
    sb $t2, 0($t1)            
    
    addiu $t0, $t0, 1         
    addiu $t1, $t1, -1        
    
    j reverse_loop

restore_and_return:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16
    
    jr $ra                    
