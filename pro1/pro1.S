.section .data
    point: .quad 0

    max_word: .asciz "The word that appears most frequently is: "
    max_word_len = . - max_word

.section .text
.global _start

.extern output_buffer

_start:
    # get output_buffer
    call read_to_buffer
    leaq output_buffer(%rip), %rax
    movq %rax, point(%rip)

    # initial link
    call link_initial

    movq point(%rip), %rdi
    call add_node

add_loop:
    incq point(%rip)
    movq point(%rip), %rcx
    movb (%rcx), %al
    testb %al, %al
    jnz add_loop
    
    incq point(%rip)
    movq point(%rip), %rcx
    movb (%rcx), %al
    testb %al, %al
    jz add_end

    movq point(%rip), %rdi
    call add_node
    jmp add_loop

add_end:
    call print_node
    call maxword
    call find_max

    movq %rcx, %rdi      # 字符串地址
    movq %rax, %rsi     # 字符串长度
    call print_with_length
    call as_exit

.globl maxword
    .type maxword, @function
maxword:
    push %rax
    push %rdi
    push %rsi 
    push %rdx

    mov $1, %rax                # sys_write系统调用号
    mov $1, %rdi                # 标准输出
    mov $max_word, %rsi       
    mov $max_word_len, %rdx   
    syscall
    
    pop %rdx
    pop %rsi 
    pop %rdi
    pop %rax
    ret

