.section .data
    point: .quad 0

.section .text
.globa _start

.extern output_buffer

_start:
    call read_to_buffer
    leaq 
    call link_initial