.section .text
    .global findfirst1
findfirst1:
    movq $32, %rax
    movq $0, %rcx

loop_start:  
    movb (%rdi, %rcx, 1), %dl  

    cmpb $0, %dl              
    je end_loop             

    cmpb $49, %dl           
    je found                

    addq $1, %rcx          
    jmp loop_start         

found:  
    movq %rcx, %rax         
    ret                     

end_loop:  
    ret  

.section .note.GNU-stack,"",@progbits
