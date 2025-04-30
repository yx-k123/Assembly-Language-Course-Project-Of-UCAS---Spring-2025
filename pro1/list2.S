.section .data
str1:
    .asciz "Hello"
str2:
    .asciz "World"
str3:
    .asciz "Hello"
newline:
    .asciz "\n"
length_prefix:
    .asciz " ("
length_suffix:
    .asciz ") "

.section .bss
    .lcomm head, 8
    .lcomm tail, 8
    .lcomm num_buffer, 21  # 20 digits + null terminator

.section .text
.globl link_initial,add_node,head,tail,_start,print_node,print_with_length

link_initial:
    # 无需传参
    # 创建一个空节点，头尾指针指向它
    mov $0, %rdi
    call create_node
    mov %rax, head(%rip)
    mov %rax, tail(%rip)
    ret

add_node:
    # 需将 %rdi 指向字符串地址
    push %r12
    mov %rdi, %r12       # 保存字符串地址
    
    # 遍历链表查找相同字符串
    mov head(%rip), %rbx
    mov 16(%rbx), %rbx   # 跳过哑节点
    
.compare_loop:
    test %rbx, %rbx
    jz .add_new          # 未找到则添加新节点
    
    mov (%rbx), %rdi     # 节点字符串地址
    mov %r12, %rsi       # 新字符串地址
    push %r12
    push %rbx 
    call compare_strings
    pop %rbx
    pop %r12
    test %al, %al
    jnz .increment       # 找到相同字符串
    
    mov 16(%rbx), %rbx   # 移动到下一个节点
    jmp .compare_loop

.increment:
    # 增加计数器
    incq 8(%rbx)
    jmp .done

.add_new:
    # 创建新节点
    mov %r12, %rdi
    call create_node
    
    # 链接到链表尾部
    mov tail(%rip), %rbx
    mov %rax, 16(%rbx)
    mov %rax, tail(%rip)

.done:
    pop %r12
    ret

# 新增函数：字符串比较
# %rdi = str1, %rsi = str2
# 返回: %al = 1(相同)/0(不同)
compare_strings:
    mov %rdi, %r8
    mov %rsi, %r9 # new
.loop:
    movb (%r8), %al
    movb (%r9), %bl
    testb %al, %al
    jz .check_end
    cmpb %al, %bl
    jne .not_equal
    inc %r8
    inc %r9
    jmp .loop
.check_end:
    testb %bl, %bl
    jnz .not_equal
    movb $1, %al
    ret
.not_equal:
    movb $0, %al
    ret

.globl find_max
    .type find_max, @function
find_max:
    movq $0, %rax
    movq head(%rip), %rbx
    movq head(%rip), %rcx
    movq 16(%rbx), %rbx   # 跳过哑节点
    test %rbx, %rbx
    jz max_end

max_loop:
    cmpq 8(%rbx), %rax   # 比较 %rax 和 8(%rbx)
    jge .skip_update     # 如果 %rax >= 8(%rbx)，跳过更新
    movq 8(%rbx), %rax   # 否则，将 8(%rbx) 的值赋给 %rax
    movq (%rbx), %rcx

    .skip_update:
    movq 16(%rbx), %rbx
    test %rbx, %rbx
    jz max_end
    jmp max_loop

max_end:
    ret

create_node:
    push %rdi
    # 分配24字节内存
    mov $12, %rax        # brk系统调用
    xor %rdi, %rdi
    syscall
    mov %rax, %r8        # 当前堆顶
    add $24, %rax        # 分配24字节
    mov %rax, %rdi
    mov $12, %rax
    syscall

    # 初始化节点
    pop %rdi
    mov %rdi, (%r8)      # 存储字符串地址
    movq $1, 8(%r8)      # 初始化出现次数为1
    movq $0, 16(%r8)    # 初始化next指针
    mov %r8, %rax       # 返回节点地址
    ret

print_node:
    # 无需传参
    mov head(%rip), %rbx
    mov 16(%rbx), %rbx  # 直接访问第一个存储的节点
traverse_loop:
    test %rbx, %rbx
    jz exit_loop
    push %rbx
    mov (%rbx), %rdi      # 字符串地址
    mov 8(%rbx), %rsi     # 字符串长度
    call print_with_length
    pop %rbx
    mov 16(%rbx), %rbx    # 移动到下一个节点
    jmp traverse_loop
exit_loop:
    ret

print_with_length:
    mov %rsi, %r12      # 出现次数
    # 打印原字符串
    call print_string
    # 打印前缀
    mov $1, %rax
    mov $1, %rdi
    lea length_prefix(%rip), %rsi
    mov $2, %rdx
    syscall
    # 转换并打印长度
    mov %r12, %rdi
    call number_to_string
    mov %rdx, %r8       # 保存长度
    mov $1, %rax
    mov $1, %rdi
    lea num_buffer(%rip), %rsi
    mov %r8, %rdx
    syscall
    # 打印后缀
    mov $1, %rax
    mov $1, %rdi
    lea length_suffix(%rip), %rsi
    mov $2, %rdx
    syscall
    # 打印换行
    mov $1, %rax
    mov $1, %rdi
    lea newline(%rip), %rsi
    mov $1, %rdx
    syscall
    ret

print_string:
    # rdi存地址
    call strlen
    mov %rax, %rdx    # 传参 注意次序！ rdi地址，rsi长度
    mov %rdi, %rsi 
    mov $1, %rax
    mov $1, %rdi
    syscall
    ret

number_to_string:
    lea num_buffer(%rip), %r8
    mov %rdi, %rax
    mov $10, %rcx
    xor %r9, %r9         # 计数器清零
    test %rax, %rax
    jnz .convert
    movb $'0', (%r8)
    inc %r9
    jmp .terminate
.convert:
    xor %rdx, %rdx
    div %rcx             # rax=商, rdx=余数
    add $'0', %dl
    mov %dl, (%r8,%r9)
    inc %r9
    test %rax, %rax
    jnz .convert
    mov %r9, %rcx        # 字符串长度
    dec %rcx
    xor %rdx, %rdx       # 左指针
.reverse:
    cmp %rdx, %rcx
    jle .terminate
    mov (%r8,%rdx), %al
    mov (%r8,%rcx), %bl
    mov %al, (%r8,%rcx)
    mov %bl, (%r8,%rdx)
    inc %rdx
    dec %rcx
    jmp .reverse
.terminate:
    movb $0, (%r8,%r9)   # 添加null终止符
    mov %r9, %rdx        # 返回字符串长度
    ret

strlen:
    xor %rax, %rax
strlen_loop:
    cmpb $0, (%rdi,%rax)
    je strlen_end
    inc %rax
    jmp strlen_loop
strlen_end:
    ret
