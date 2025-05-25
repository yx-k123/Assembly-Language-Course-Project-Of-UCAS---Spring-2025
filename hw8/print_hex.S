.section .text
.global print_hex

print_hex:
    pushl %ebp
    movl %esp, %ebp
    
    # 保存寄存器
    pushl %ebx
    pushl %esi
    pushl %edi
    
    # 获取输入参数
    movl 8(%ebp), %eax
    
    # 检查是否为负数
    testl %eax, %eax
    jns positive
    
    # 如果是负数，输出负号
    pushl $0x2D       # '-'
    movl $4, %eax     # sys_write
    movl $1, %ebx     # stdout
    movl %esp, %ecx   # buffer
    movl $1, %edx     # length
    int $0x80
    addl $4, %esp     # 清理栈
    
    # 取绝对值
    negl 8(%ebp)
    
positive:
    # 输出"0x"
    pushl $0x7830     # "0x" 
    movl $4, %eax     # sys_write
    movl $1, %ebx     # stdout
    movl %esp, %ecx   # buffer
    movl $2, %edx     # length
    int $0x80
    addl $4, %esp     # 清理栈
    
    # 转换数字
    movl 8(%ebp), %eax
    movl $8, %ecx     # 最多8个16进制数字
    movl $0, %edi      # 标记是否遇到非零数字
    
    # 分配空间存储16进制字符串
    subl $12, %esp
    movl %esp, %esi
    
convert_loop:
    # 获取当前4位
    roll $4, %eax
    movl %eax, %ebx
    andl $0xF, %ebx
    
    # 检查是否为前导零
    testl %edi, %edi
    jnz not_leading_zero
    
    cmpl $0, %ebx
    jz skip_digit
    
    movl $1, %edi      # 遇到非零数字
    
not_leading_zero:
    # 转换为ASCII字符
    cmpl $10, %ebx
    jb is_digit
    addl $0x57, %ebx   # 'a' - 10
    jmp store_digit
    
is_digit:
    addl $0x30, %ebx   # '0'
    
store_digit:
    movb %bl, (%esi)
    incl %esi
    
skip_digit:
    loop convert_loop
    
    # 如果所有数字都是0，至少输出一个0
    testl %edi, %edi
    jnz not_all_zero
    movb $0x30, (%esi) # '0'
    incl %esi
    
not_all_zero:
    # 计算字符串长度
    movl %esi, %edx
    subl %esp, %edx
    
    # 输出字符串
    movl $4, %eax     # sys_write
    movl $1, %ebx     # stdout
    movl %esp, %ecx   # buffer
    int $0x80
    
    # 输出换行符
    pushl $0x0A      # '\n'
    movl $4, %eax
    movl $1, %ebx
    movl %esp, %ecx
    movl $1, %edx
    int $0x80
    addl $4, %esp
    
    # 清理栈
    addl $12, %esp
    
    # 恢复寄存器
    popl %edi
    popl %esi
    popl %ebx
    
    movl %ebp, %esp
    popl %ebp
    ret
