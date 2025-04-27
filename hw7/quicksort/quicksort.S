.section .text
    .globl quicksort
quicksort:
    pushq %rbp                 
    movq %rsp, %rbp            
    pushq %rdi              
    pushq %rsi              
    pushq %rdx                

    cmpq %rdx, %rsi                     # if i >= j
    jge .done                   

    # partition(arr, low, high)
    movq -8(%rbp), %rdi   
    movq -16(%rbp), %rsi  
    movq -24(%rbp), %rdx 
    call partition          
    movq %rax, %rcx                     # return %rax

    # quicksort(arr, low, pi - 1)
    movq -8(%rbp), %rdi             
    movq -16(%rbp), %rsi             
    movq %rcx, %rdx           
    decq %rdx                           # pi - 1
    call quicksort              

    # quicksort(arr, pivot + 1, high)
    movq -8(%rbp), %rdi            
    movq %rcx, %rsi             
    incq %rsi                           # pi + 1
    movq -24(%rbp), %rdx             
    call quicksort              

.done:
    popq %rdx                   
    popq %rsi                   
    popq %rdi                   
    movq %rbp, %rsp            
    popq %rbp                   
    ret                        

# partition
# %rdi = point, %rsi = low, %rdx = high
# %rax = return
partition:
    pushq %rbp                  
    movq %rsp, %rbp             
    pushq %rdi                  
    pushq %rsi                  
    pushq %rdx      

    movq -8(%rbp), %rdi   
    movq -16(%rbp), %rsi  
    movq -24(%rbp), %rdx            

    # pivot
    movq %rdx, %rcx                     # %rcx = high
    movl (%rdi, %rcx, 4), %r8d          # r8d = arr[high] = pivot

    # i = low - 1
    movq %rsi, %rax                     # %rax = low
    decq %rax                           # i = low - 1

.partition_loop:
    movq %rsi, %rbx                     # %rbx = j
    cmpq %rdx, %rbx                     # if j < high
    jge .partition_done         

    movl (%rdi, %rbx, 4), %r9d          # r9d = arr[j]
    cmpl %r8d, %r9d                     # if (arr[j] < pivot)
    jg .partition_skip        

    # exchange arr[++i] and arr[j]
    incq %rax                           # i++
    movl (%rdi, %rax, 4), %r10d         # r10d = temp = arr[i]
    movl %r9d, (%rdi, %rax, 4)          # arr[i] = arr[j]
    movl %r10d, (%rdi, %rbx, 4)         # arr[j] = temp

.partition_skip:
    incq %rsi                           # j++
    jmp .partition_loop         

.partition_done:
    # exchange arr[i + 1] and arr[high]
    incq %rax                           # i++
    movl (%rdi, %rax, 4), %r10d         # r10d = arr[i + 1]
    movl (%rdi, %rcx, 4), %r11d         # r11d = arr[high]
    movl %r11d, (%rdi, %rax, 4)         # arr[i + 1] = arr[high]
    movl %r10d, (%rdi, %rcx, 4)         # arr[high] = arr[i + 1]

    # return
    movq %rax, %rax                     # return i + 1

    popq %rdx                 
    popq %rsi                  
    popq %rdi                   
    movq %rbp, %rsp           
    popq %rbp                 
    ret                        

# .note.GNU-stack
.section .note.GNU-stack,"",@progbits
