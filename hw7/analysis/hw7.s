.file	"hw7.c"               # 源文件名
	.text                        # 代码段开始
	.globl	processStruct         # 声明全局符号 processStruct
	.type	processStruct, @function # 声明 processStruct 是一个函数
processStruct:
.LFB0:
	.cfi_startproc
	endbr64                   # 用于 CET（控制流增强技术）的指令，确保合法的函数入口
	pushq	%rbp              # 保存旧的栈帧指针
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp        # 设置新的栈帧指针
	.cfi_def_cfa_register 6
	pushq	%rbx              # 保存 %rbx 寄存器
	.cfi_offset 3, -24
	movq	%rdi, -16(%rbp)   # 将第一个参数（结构体指针）保存到栈中

	# 处理结构体字段 `a` (int 类型)
	movl	16(%rbp), %eax    # 加载结构体的 `a` 字段到 %eax
	addl	$1, %eax          # 将 `a` 加 1
	movl	%eax, 16(%rbp)    # 将结果存回结构体的 `a` 字段

	# 处理结构体字段 `b` (float 类型)
	movss	20(%rbp), %xmm1   # 加载结构体的 `b` 字段到 %xmm1
	movss	.LC0(%rip), %xmm0 # 加载常量 1.0f 到 %xmm0
	addss	%xmm1, %xmm0      # 将 `b` 加 1.0f
	movss	%xmm0, 20(%rbp)   # 将结果存回结构体的 `b` 字段

	# 处理结构体字段 `c` (double 类型)
	movsd	24(%rbp), %xmm1   # 加载结构体的 `c` 字段到 %xmm1
	movsd	.LC1(%rip), %xmm0 # 加载常量 1.0 到 %xmm0
	addsd	%xmm1, %xmm0      # 将 `c` 加 1.0
	movsd	%xmm0, 24(%rbp)   # 将结果存回结构体的 `c` 字段

	# 处理结构体字段 `d` (int 类型)
	movl	32(%rbp), %eax    # 加载结构体的 `d` 字段到 %eax
	addl	$1, %eax          # 将 `d` 加 1
	movl	%eax, 32(%rbp)    # 将结果存回结构体的 `d` 字段

	# 处理结构体字段 `e` (float 类型)
	movss	36(%rbp), %xmm1   # 加载结构体的 `e` 字段到 %xmm1
	movss	.LC0(%rip), %xmm0 # 加载常量 1.0f 到 %xmm0
	addss	%xmm1, %xmm0      # 将 `e` 加 1.0f
	movss	%xmm0, 36(%rbp)   # 将结果存回结构体的 `e` 字段

	# 处理结构体字段 `f` (double 类型)
	movsd	40(%rbp), %xmm1   # 加载结构体的 `f` 字段到 %xmm1
	movsd	.LC1(%rip), %xmm0 # 加载常量 1.0 到 %xmm0
	addsd	%xmm1, %xmm0      # 将 `f` 加 1.0
	movsd	%xmm0, 40(%rbp)   # 将结果存回结构体的 `f` 字段

	# 处理结构体字段 `j` (int 类型)
	movl	48(%rbp), %eax    # 加载结构体的 `j` 字段到 %eax
	addl	$1, %eax          # 将 `j` 加 1
	movl	%eax, 48(%rbp)    # 将结果存回结构体的 `j` 字段

	# 返回结构体
	movq	-16(%rbp), %rax   # 加载结构体指针到 %rax
	movq	16(%rbp), %rcx    # 加载结构体的前 8 字节
	movq	24(%rbp), %rbx    # 加载结构体的后 8 字节
	movq	%rcx, (%rax)      # 写回结构体的前 8 字节
	movq	%rbx, 8(%rax)     # 写回结构体的后 8 字节
	movq	32(%rbp), %rcx    # 加载结构体的中间 8 字节
	movq	40(%rbp), %rbx    # 加载结构体的中间 8 字节
	movq	%rcx, 16(%rax)    # 写回结构体的中间 8 字节
	movq	%rbx, 24(%rax)    # 写回结构体的中间 8 字节
	movq	48(%rbp), %rcx    # 加载结构体的最后 8 字节
	movq	%rcx, 32(%rax)    # 写回结构体的最后 8 字节
	movq	-16(%rbp), %rax   # 加载结构体指针到 %rax
	leave                     # 恢复栈帧
	ret                       # 返回
	.cfi_endproc
.LFE0:
	.size	processStruct, .-processStruct

	.globl	main               # 声明全局符号 main
	.type	main, @function    # 声明 main 是一个函数
main:
.LFB1:
	.cfi_startproc
	endbr64                   # CET 指令
	pushq	%rbp              # 保存旧的栈帧指针
	movq	%rsp, %rbp        # 设置新的栈帧指针
	subq	$136, %rsp        # 为局部变量分配栈空间

	# 初始化结构体字段
	movl	$1, -144(%rbp)    # cs.a = 1
	movss	.LC0(%rip), %xmm0 # cs.b = 1.0f
	movss	%xmm0, -140(%rbp)
	movsd	.LC1(%rip), %xmm0 # cs.c = 1.0
	movsd	%xmm0, -136(%rbp)
	movl	$2, -128(%rbp)    # cs.d = 2
	movss	.LC2(%rip), %xmm0 # cs.e = 2.0f
	movss	%xmm0, -124(%rbp)
	movsd	.LC3(%rip), %xmm0 # cs.f = 2.0
	movsd	%xmm0, -120(%rbp)
	movl	$3, -112(%rbp)    # cs.j = 3

	# 调用 processStruct
	leaq	-80(%rbp), %rdx   # 加载结构体地址到 %rdx
	movq	%rdx, %rdi        # 将结构体地址作为参数传递
	call	processStruct      # 调用 processStruct

	# 返回值处理
	movl	$0, %eax          # 返回值为 0
	leave                     # 恢复栈帧
	ret                       # 返回
	.cfi_endproc
.LFE1:
	.size	main, .-main

	.section	.rodata
.LC0:
	.long	1065353216         # 常量 1.0f 的 IEEE 754 表示
.LC1:
	.long	0
	.long	1072693248         # 常量 1.0 的 IEEE 754 表示
.LC2:
	.long	1073741824         # 常量 2.0f 的 IEEE 754 表示
.LC3:
	.long	0
	.long	1073741824         # 常量 2.0 的 IEEE 754 表示
