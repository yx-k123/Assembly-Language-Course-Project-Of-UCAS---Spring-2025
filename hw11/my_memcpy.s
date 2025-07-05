.file	"my_memcpy.c"           # 源文件名
    .text                       # 代码段
    .globl	my_memcpy           # 全局符号声明
    .type	my_memcpy, @function # 声明为函数类型

my_memcpy:                      # 函数入口点
.LFB0:                          # 函数开始标签
    .cfi_startproc              # CFI指令：过程开始
    
    # === 函数序言：保存被调用者保存寄存器 ===
    pushl	%edi                # 保存%edi到栈
    .cfi_def_cfa_offset 8       # 栈偏移增加4字节
    .cfi_offset 7, -8           # 记录%edi保存位置
    pushl	%esi                # 保存%esi到栈
    .cfi_def_cfa_offset 12      # 栈偏移增加4字节
    .cfi_offset 6, -12          # 记录%esi保存位置
    pushl	%ebx                # 保存%ebx到栈
    .cfi_def_cfa_offset 16      # 栈偏移增加4字节
    .cfi_offset 3, -16          # 记录%ebx保存位置
    
    # === 加载函数参数 ===
    # 栈布局：[返回地址][%edi][%esi][%ebx] + 参数
    movl	16(%esp), %eax      # 加载dest参数到%eax
    movl	20(%esp), %edx      # 加载src参数到%edx
    movl	24(%esp), %ebx      # 加载n参数到%ebx
    
    # === 检查是否为小数据 (n <= 8) ===
    cmpl	$8, %ebx            # 比较n和8
    jbe	.L7                     # 如果n <= 8，跳转到简单复制
    
    # === 大数据块处理准备 ===
    movl	%ebx, %esi          # %esi = n
    shrl	$3, %esi            # %esi = n / 8 (块数)
    andl	$7, %ebx            # %ebx = n % 8 (剩余字节)
    movl	%eax, %ecx          # %ecx = dest指针
    movl	%edx, %edi          # %edi = src指针
    
    # === 内联汇编开始 ===
#APP
# 16 "my_memcpy.c" 1           # 标记来自源文件第16行
    1:                          # 8字节块复制循环
    movl (%edi), %eax           # 从src加载4字节到%eax
    movl 4(%edi), %edx          # 从src+4加载4字节到%edx
    movl %eax, (%ecx)           # 存储4字节到dest
    movl %edx, 4(%ecx)          # 存储4字节到dest+4
    add $8, %edi                # src指针前进8字节
    add $8, %ecx                # dest指针前进8字节
    dec %esi                    # 块计数器减1
    jnz 1b                      # 如果不为零，跳回标签1
    
    test %ebx, %ebx             # 测试剩余字节数
    jz 3f                       # 如果为零，跳到结束
    
    2:                          # 剩余字节处理循环
    movb (%edi), %al            # 从src加载1字节到%al
    movb %al, (%ecx)            # 存储1字节到dest
    inc %edi                    # src指针+1
    inc %ecx                    # dest指针+1
    dec %ebx                    # 剩余计数器-1
    jnz 2b                      # 如果不为零，跳回标签2
    
    3:                          # 内联汇编结束
# 0 "" 2
#NO_APP
    # === 内联汇编结束 ===

.L1:                            # 函数返回标签
    # === 函数尾声：恢复寄存器 ===
    popl	%ebx                # 恢复%ebx
    .cfi_remember_state         # 记住当前CFI状态
    .cfi_restore 3              # %ebx已恢复
    .cfi_def_cfa_offset 12      # 栈偏移减少4字节
    popl	%esi                # 恢复%esi
    .cfi_restore 6              # %esi已恢复
    .cfi_def_cfa_offset 8       # 栈偏移减少4字节
    popl	%edi                # 恢复%edi
    .cfi_restore 7              # %edi已恢复
    .cfi_def_cfa_offset 4       # 栈偏移减少4字节
    ret                         # 返回

# === 小数据处理分支 (n <= 8) ===
.L7:
    .cfi_restore_state          # 恢复CFI状态
    testl	%ebx, %ebx          # 测试n是否为0
    je	.L1                     # 如果为0，直接返回
    addl	%eax, %ebx          # %ebx = dest + n (结束地址)

.L4:                            # 逐字节复制循环
    addl	$1, %edx            # src指针+1
    addl	$1, %eax            # dest指针+1
    movzbl	-1(%edx), %ecx      # 从src-1加载1字节到%ecx
    movb	%cl, -1(%eax)       # 存储1字节到dest-1
    cmpl	%eax, %ebx          # 比较当前dest和结束地址
    jne	.L4                     # 如果未到结束，继续循环
    jmp	.L1                     # 跳转到返回

    .cfi_endproc                # CFI指令：过程结束
.LFE0:                          # 函数结束标签
    .size	my_memcpy, .-my_memcpy  # 函数大小
    .ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"  # 编译器信息
    .section	.note.GNU-stack,"",@progbits  # GNU栈标记
