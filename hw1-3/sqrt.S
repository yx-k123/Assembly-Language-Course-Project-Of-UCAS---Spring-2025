.section .data  
    x:      .double 16.0          # 要计算平方根的数  
    y:      .double 1.0           # 初始值 y0  
    epsilon: .double 0.00001       # 精度  
    y_temp: .double 0.0            # 存放计算出的新 y 值  

.section .text  
    .globl _start  
_start:  
    # 加载 x 和 y 的初始值  
    movsd x(%rip), %xmm0           # 将 x 加载到 xmm0  
    movsd y(%rip), %xmm1           # 将初始 y 加载到 xmm1  
    movsd epsilon(%rip), %xmm2     # 将 epsilon 加载到 xmm2  

iteration:  
    # 计算 1/2 * (y + x/y)  
    movsd %xmm1, %xmm3             # 复制 y 到 xmm3  
    divsd %xmm1, %xmm0             # xmm0 = x / y  
    addsd %xmm3, %xmm0             # xmm0 = x / y + y  
    mulsd .half_two, %xmm0         # xmm0 = 0.5 * (x / y + y)  
    movsd %xmm0, y_temp(%rip)      # 存储新的 y 值  

    # 计算 |y_new - y_old| 的值  
    movsd y_temp(%rip), %xmm4      # 将新的 y 加载到 xmm4  
    subsd %xmm1, %xmm4              # xmm4 = y_new - y_old  
    ucomisd %xmm4, %xmm2            # 比较新旧 y 是否小于 epsilon  
    ja iteration                    # 如果大于 epsilon，继续迭代  

    # 最终结果存放在 y_temp 中  
    movsd y_temp(%rip), %xmm1      # 将最终结果存入 y  

    # 退出程序  
    movl $60, %eax                  # sys_exit = 60  
    xor %edi, %edi                  # 返回 0  
    syscall  

.section .data  
.half_two:  
    .double 0.5                     # 常数 0.5  
