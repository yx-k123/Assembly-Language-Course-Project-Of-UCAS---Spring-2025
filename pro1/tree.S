.section .data
head: .quad 0                # 链表头指针，初始为 NULL
word1: .ascii "Hello, World!\n" # 字符串常量
word2: .ascii "hello, world!\n" # 字符串常量
point: .ascii "point\n" # 字符串常量

.section .text
.global _start
_start:

    # 创建第一个节点
    movq word1(%rip), %rdi   # 将字符串地址加载到 %rdi   
    call create_node         # 调用 create_node 函数
    movq %rax, head(%rip)    # 将返回的节点地址存储到 head

    # 创建第二个节点
    movq word2(%rip), %rdi           
    call create_node         # 调用 create_node 函数
    movq head(%rip), %rbx    # 加载链表头地址到 %rbx
    movq %rax, 8(%rbx)       # 将新节点地址存储到第一个节点的 next 指针

    movq $0, %rdi              # 将 %rdi 清零，准备遍历链表
    leaq head(%rip), %rdi      # 加载链表头地址到 %rdi
    call traverse_list       # 遍历链表并输出数据
   
    # 释放链表内存
    leaq head(%rip), %rdi    # 加载链表头地址到 %rdi
    call free_list           # 调用 free_list 函数释放链表内存

    # 退出程序
    movq $60, %rax           # syscall: exit
    xorq %rdi, %rdi          # 返回值: 0
    syscall

# create_node
create_node:
    # 使用 mmap 分配内存
    movq %rdi, %rbx
    xorq %rdi, %rdi            # 地址为 NULL（由内核选择）
    movq $16, %rsi             # 分配 16 字节（8 字节数据地址 + 8 字节指针）
    movq $3, %rdx              # 保护标志：读写（PROT_READ | PROT_WRITE）
    movq $34, %r10             # 映射标志：私有匿名映射（MAP_PRIVATE | MAP_ANONYMOUS）
    movq $-1, %r8              # 文件描述符：-1（匿名映射）
    xorq %r9, %r9              # 偏移量为 0
    movq $9, %rax              # 系统调用号：mmap
    syscall

    # 检查 mmap 是否成功
    cmpq $-1, %rax
    je mmap_failed

    # 初始化节点
    movq %rbx, %rdi
    movq %rdi, (%rax)          # 将数据值存储到节点的 data 域
    movq $0, 8(%rax)           # 将 next 指针初始化为 NULL
    ret                        # 返回新节点地址

mmap_failed:
    movq $60, %rax             # syscall: exit
    movq $1, %rdi              # 返回值: 1
    syscall

# 释放链表内存函数
# 输入: %rdi = 链表头地址
free_list:
    testq %rdi, %rdi           # 检查链表是否为空
    jz end_free                # 如果为空，结束释放

free_loop:
    movq 8(%rdi), %rbx         # 保存下一个节点地址
    movq $16, %rsi             # 节点大小（与 mmap 分配时一致）
    movq $11, %rax             # syscall: munmap
    syscall                    # 释放当前节点内存
    movq %rbx, %rdi            # 移动到下一个节点
    testq %rdi, %rdi           # 检查是否到达链表末尾
    jnz free_loop              # 如果未到末尾，继续释放

end_free:
    ret

# 遍历链表
# 输入: %rdi = 链表头地址
# 输出: %rdi = NULL
traverse_list:
    testq %rdi, %rdi           # 检查链表是否为空
    jz end_traverse            # 如果为空，结束遍历
    
    movq 8(%rdi), %rbx         # 保存下一个节点地址
    movq (%rdi), %rsi          # 获取当前节点数据
    movq $1, %rax              # syscall: write
    movq $1, %rdi              # 文件描述符: STDOUT
    movq $14, %rdx             # 字符串长度
    syscall                    # 输出当前节点数据
    
    movq %rbx, %rdi            # 移动到下一个节点
    testq %rdi, %rdi           # 检查是否到达链表末尾
    jz end_traverse            # 如果到达末尾，结束遍历
    jmp traverse_list          # 继续遍历
    
end_traverse:
    ret                        # 返回

pointing:
    pushq %rdi              # 保存当前节点地址
    pushq %rsi
    pushq %rax
    pushq %rdx

    leaq point(%rip), %rsi   # 将字符串地址加载到 %rsi
    movq $1, %rax              # syscall: write
    movq $1, %rdi              # 文件描述符: STDOUT
    movq $6, %rdx             # 字符串长度 (确保与字符串实际长度匹配)
    syscall                    # 输出当前节点数据

    popq %rdx
    popq %rax
    popq %rsi
    popq %rdi
    ret                        # 返回
    