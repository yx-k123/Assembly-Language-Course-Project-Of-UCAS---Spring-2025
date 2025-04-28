.section .data
    size: .quad 16
    word_lim: .quad 20
    p_txt: .quad 0
    txt_buffer: .asciz "    Hello world!\0"
    enter: .asciz "\n\0"
.section .bss
    word_buffer: .space 20
.section .text
    .globl _start
_start:
    # initial p_txt 
    leaq txt_buffer(%rip), %rax
    movq %rax, p_txt(%rip)

loop:
    # call getword
    call getword
    cmpq $0, %rax
    je end

    # as_put
    leaq word_buffer(%rip), %rsi  # address
    movq %rdx, %rdx               # length
    call as_puts

    jmp loop

end:
    call as_exit

# Use: %rax, %rbx
# Output: %al
.globl getword
    .type getword, @function
getword:
    leaq word_buffer(%rip), %rdx        # char* word
    movq p_txt(%rip), %rsi              # static char* p
    leaq txt_buffer(%rip), %rcx         # %rdx = $(filebuf + size)
    addq size(%rip), %rcx

L1:
    cmpq %rcx, %rsi
    jge L2
    cmpb $32, (%rsi)          # ' '
    jne L2
    incq %rsi
    jmp L1

L2:
    cmpq %rsi, %rcx
    je L3
    cmpb $0, (%rsi)           # '\0'
    je L3

    movb (%rsi), %al
    movb %al, (%rdx)
    incq %rdx

    movb (%rsi), %al
    call isalpha
    cmpq $-1, %rax            # compare %rax -1
    je L4

    movq word_lim(%rip), %rbx
L5:
    incq %rsi
    cmpq %rdx, %rsi
    jge L6

    decq %rbx
    cmpq $0, %rbx
    jle L6

    movb (%rsi), %al
    movb %al, (%rdx)
    call isalpha
    cmpq $-1, %rax
    je L6
    
    incq %rdx
    jmp L5

L6:
    movb $0, (%rdx)            # add '\0'
    movq %rsi, p_txt(%rip)     # renew p_txt 
    ret

L3:
    movq $0, %rax
    ret

L4:
    incq %rsi                 
    jmp L1                   

# Input: %rax
.globl isalpha
    .type isalpha, @function
isalpha:
    cmpb $'a', %al           # Check if character >= 'a'
    jl not_alpha
    cmpb $'z', %al           # Check if character <= 'z'
    jle is_alpha
    cmpb $'A', %al           # Check if character >= 'A'
    jl not_alpha
    cmpb $'Z', %al           # Check if character <= 'Z'
    jg not_alpha

is_alpha:
    movq $1, %rax            # Return 1 (true)
    ret

not_alpha:
    movq $-1, %rax           # Return -1 (false)
    ret

# Input: %rsi = array, %rdx = length
.globl as_puts
    .type as_puts, @function
as_puts:

    movq $1, %rax              # syscall: write
    movq $1, %rdi              
    syscall

    ret

.globl as_exit
    .type as_exit, @function
as_exit:
    movq $60, %rax
    xor %rdi, %rdi
    syscall
    ret
