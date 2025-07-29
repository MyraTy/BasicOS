[bits 32]
extern main

segment .text
call main
jmp $ ; Hang