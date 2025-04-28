.section .bss
    .lcomm head_ptr, 4      # 链表头指针（4字节）
    .lcomm node_memory, 1024 # 256个节点×4字节

.section .data
next_node: .long 0         # 下一个可用节点的索引

.section .text
# 输入: %eax = 新字符串地址
process_string:
    pushl %ebx
    pushl %esi
    pushl %edi
    
    # 遍历链表查找字符串
    movl head_ptr, %ebx    # 获取头节点地址
    
search_loop:
    testl %ebx, %ebx       # 检查是否到达链表末尾(NULL)
    je add_new_node
    
    # 准备比较字符串
    movl %eax, %esi        # 新字符串地址 -> %esi
    movl (%ebx), %edi      # 节点中的字符串地址 -> %edi
    call compare_strings
    
    # 检查比较结果
    cmpl $1, %eax          # compare_strings返回1表示相同
    je increment_count
    
    # 移动到下一个节点
    movl 8(%ebx), %ebx     # 获取next指针
    jmp search_loop

increment_count:
    # 增加计数器
    incl 4(%ebx)           # node->count++
    jmp process_done

add_new_node:
    # 计算新节点地址 (每个节点12字节: str_ptr, count, next)
    movl $node_memory, %edx
    movl next_node, %edi
    imull $12, %edi        # 每个节点12字节
    addl %edx, %edi        # %edi = 新节点地址
    
    # 初始化新节点
    movl %eax, (%edi)      # node->str_ptr
    movl $1, 4(%edi)       # node->count = 1
    movl head_ptr, %eax
    movl %eax, 8(%edi)     # node->next = 原头节点
    
    # 更新链表头
    movl %edi, head_ptr    # head_ptr = 新节点地址
    incl next_node         # 增加节点计数器

process_done:
    popl %edi
    popl %esi
    popl %ebx
    ret

# ====================== 字符串比较函数 ======================
# 输入: %esi = 字符串1地址, %edi = 字符串2地址
# 输出: %eax = 比较结果(1:相同, 0:不同)
compare_strings:
    pushl %ebx
    
compare_loop:
    movb (%esi), %al
    movb (%edi), %bl

    # 检查字符串1是否结束
    testb %al, %al
    jz check_string2_end

    # 比较当前字符
    cmpb %al, %bl
    jne not_equal

    # 移动到下一个字符
    incl %esi
    incl %edi
    jmp compare_loop

check_string2_end:
    # 检查字符串2是否也结束
    testb %bl, %bl
    jnz not_equal

    # 字符串相同
    movl $1, %eax
    jmp compare_done

not_equal:
    # 字符串不同
    movl $0, %eax

compare_done:
    popl %ebx
    ret
