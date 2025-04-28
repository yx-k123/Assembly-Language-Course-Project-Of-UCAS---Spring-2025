.section .data
    filename:   .asciz "input.txt"      # 文件名，以0结尾
    txt_buffer:     .space 1024             # 数据缓冲区，1024字节
    bufsize =   . - txt_buffer              # 缓冲区大小
    
    # 错误信息
    error_open: .asciz "Failed to open file\n"
    error_open_len = . - error_open
    error_read: .asciz "Failed to read file\n"
    error_read_len = . - error_read

    size: .quad 16
    word_lim: .quad 20
    p_txt: .quad 0
    q_txt: .quad 0
    # txt_buffer: .asciz "    Hello world!\0"
    enter: .asciz "\n\0"
.section .bss
    word_buffer: .space 20
    output_buffer:  .space 1024          # 输出缓冲区，1024字节
.section .text
    .globl _start
_start:
    # open_file
    call open_file

    # initial p_txt 
    leaq txt_buffer(%rip), %rax
    movq %rax, p_txt(%rip)
    leaq output_buffer(%rip), %rax
    movq %rax, q_txt(%rip)

loop:
    # call getword
    call getword
    cmpq $0, %rax
    je end

    call write
    # as_put
    # leaq word_buffer(%rip), %rsi  # address
    # movq %rdx, %rdx               # length
    # call as_puts
    # call print_enter
    
    jmp loop

end:
    leaq output_buffer(%rip), %rsi  # address
    movq $50, %rdx               # length
    call as_puts

    call as_exit

# Use: %rax, %rbx
# Output: %al
.globl getword
    .type getword, @function
getword:
    leaq word_buffer(%rip), %rdx        # char* word
    movq p_txt(%rip), %rsi              # static char* p
    leaq txt_buffer(%rip), %rcx         # %rdx = $(filebuf + size)
    addq size(%rip), %rcx

L1:
    cmpq %rcx, %rsi
    jge L7

L7:
    cmpb $32, (%rsi)          # ' '
    jne L2
    incq %rsi
    jmp L1

L2: 
    cmpq %rsi, %rcx
    je L3
    cmpb $0, (%rsi)           # '\0'
    je L3

    movb (%rsi), %al
    call isalpha
    cmpq $-1, %rax            # compare %rax -1
    je L4

    movb (%rsi), %al
    movb %al, (%rdx)
    incq %rdx

    movq word_lim(%rip), %rbx
L5:
    incq %rsi
    cmpq %rdx, %rsi
    jge L6

    decq %rbx
    cmpq $0, %rbx
    jle L6

    movb (%rsi), %al
    movb %al, (%rdx)
    call isalpha
    cmpq $-1, %rax
    je L6
    
    incq %rdx
    jmp L5

L6:
    incq %rsi
    movb $0, (%rdx)            # add '\0'
    movq %rsi, p_txt(%rip)     # renew p_txt 
    ret

L3:
    movq $0, %rax
    ret

L4:
    incq %rsi                 
    jmp L1                   

# Input: %rax
.globl isalpha
    .type isalpha, @function
isalpha:
    cmpb $'z', %al           # Check if character <= 'z'
    jg not_alpha
    cmpb $'A', %al           # Check if character >= 'A'
    jl not_alpha

    cmpb $'Z', %al           # Check if character <= 'Z'
    jle is_alpha
    cmpb $'a', %al           # Check if character >= 'a'
    jge is_alpha

is_alpha:
    movq $1, %rax            # Return 1 (true)
    ret

not_alpha:
    movq $-1, %rax           # Return -1 (false)
    ret

# Input: %rsi = array, %rdx = length
.globl as_puts
    .type as_puts, @function
as_puts:

    movq $1, %rax              # syscall: write
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

.globl print_enter
    .type print_enter, @function    
print_enter:
    movq $1, %rax                # sys_write系统调用号
    movq $1, %rdi                # 标准输出
    leaq enter(%rip), %rsi       # 换行符地址
    movq $2, %rdx                # 换行符长度
    syscall
    ret

.globl open_file
    .type open_file, @function
open_file:
    # 打开文件
    mov $2, %rax                # sys_open系统调用号
    mov $filename, %rdi         # 文件名指针
    mov $0, %rsi                # 标志位 (O_RDONLY)
    mov $0, %rdx                # 模式 (不需要)
    syscall
    
    # 检查是否成功打开
    cmp $0, %rax
    jl open_error               # 如果返回值为负，表示错误
    
    mov %rax, %r8               # 保存文件描述符到%r8
    
    # 读取文件
    mov $0, %rax                # sys_read系统调用号
    mov %r8, %rdi               # 文件描述符
    mov $txt_buffer, %rsi           # 缓冲区地址
    mov $bufsize, %rdx          # 缓冲区大小
    syscall
    
    # 检查是否成功读取
    cmp $0, %rax
    jl read_error               # 如果返回值为负，表示错误
    
    # 此时%rax包含实际读取的字节数
    # 可以在这里处理读取的数据
    
    # 关闭文件
    mov $3, %rax                # sys_close系统调用号
    mov %r8, %rdi               # 文件描述符
    syscall
    ret

.globl open_error
    .type open_error, @function
open_error:
    # 打印错误信息
    mov $1, %rax                # sys_write系统调用号
    mov $1, %rdi                # 标准输出
    mov $error_open, %rsi       # 错误信息指针
    mov $error_open_len, %rdx   # 错误信息长度
    syscall
    
    # 退出程序
    mov $60, %rax
    mov $1, %rdi                # 退出状态码1
    syscall

.globl read_error
    .type read_error, @function
read_error:
    # 打印错误信息
    mov $1, %rax                # sys_write系统调用号
    mov $1, %rdi                # 标准输出
    mov $error_read, %rsi       # 错误信息指针
    mov $error_read_len, %rdx   # 错误信息长度
    syscall
    
    # 关闭文件
    mov $3, %rax
    mov %r8, %rdi
    syscall
    
    # 退出程序
    mov $60, %rax
    mov $1, %rdi                # 退出状态码1
    syscall

.globl write
    .type write, @function
write:
    leaq word_buffer(%rip), %rdi   # 源地址
    movq q_txt(%rip), %rsi         # 目标地址(假设q_txt存储当前写入位置)
    
write_loop:
    movb (%rdi), %al               # 读取源字节
    testb %al, %al                 # 检查是否为null字符
    jz write_end
    
    movb %al, (%rsi)               # 写入目标
    incq %rdi
    incq %rsi
    jmp write_loop
    
write_end:
    movb $0, (%rsi)               # 确保null终止
    incq %rsi
    movq %rsi, q_txt(%rip)         # 更新写入位置(指向null后)
    ret
