.section .data  
    sum_str: .space 7

.section .text  
    .globl _start  

_start:   
    movl $0, %eax
    movl $100, %ecx

loop1:  
    addl %ecx, %eax      
    addl %ecx, %eax      
    decl %eax              
    loop loop1                

    leal sum_str+6, %edi
    movl $0, (%edi) 
    decl %edi
    movl $'\n', (%edi)
    movl $5, %ecx

loop2:
    movl $0, %edx
    movl $10, %ebx
    divl %ebx
    addb $'0', %dl
    decl %edi
    movb %dl, (%edi)
    loop loop2

    # 输出  
    movl $4, %eax
    movl $1, %ebx 
    leal sum_str, %ecx
    movl $7, %edx
    int $0x80 

    # 退出   
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

    
