# insert_sort.S
.section .data
    testdata: .byte 'A', '0', 'z', 'P', '8', 'r', 'Z', '2', 'f', 'H' # , '\n'
.section .text
    .globl _start

_start:
    movq $10, %rdx
    leaq testdata, %rsi
    call insert_sort
    # Output
    leaq testdata, %rsi          
    movq $10, %rdx        
    call as_puts
    # Exit
    call as_exit

# Insert_sort
# Input: %rsi = array, %rdx = length

.globl insert_sort
    .type insert_sort, @function
insert_sort:
    # Initialize
    movq $1, %rbx   # i
    movq $0, %rcx   # j
    movb $0, %al   # temp1
    movb $0, %dil  # temp2
    # Loop
L1:
    movb (%rsi, %rbx), %al  # temp = array[i]
    movq %rbx, %rcx     
    decq %rcx               # j = i - 1
    
L2:
    cmpq $0, %rcx           # if j < 0
    jl L3                   # jump to L3

    cmpb (%rsi, %rcx), %al  # if array[j] <= temp
    jge L3                   # jump to L3

    movb (%rsi, %rcx), %dil  
    movb %dil, 1(%rsi, %rcx) # array[j + 1] = array[j]
    decq %rcx               # j--
    jmp L2               
L3:
    movb %al, 1(%rsi, %rcx)  # array[j + 1] = temp
    incq %rbx               # i++
    # call as_puts
    cmpq %rdx, %rbx         # if i < length
    jl L1                   # jump to L1

    ret                     # Return to caller
    # End of insert_sort

# Output
.globl as_puts
    .type as_puts, @function
as_puts:
    movq $1, %rax                # syscall: write
    movq $1, %rdi                       
    syscall
    ret
# Exit
.globl as_exit
    .type as_exit, @function
as_exit:
    movq $60, %rax               # syscall: exit
    xorq %rdi, %rdi              
    syscall

