[org 0x7c00]
[bits 16]
print_16:
        pusha ; save all registers
    .next16_char:
        mov al, [bx] ; load byte
        cmp al, 0 ; null terminator?
        je .done16
        mov ah, 0Eh ; BIOS teletype function
        int 0x10 ; BIOS interrupt
        inc bx ; next char
        jmp .next16_char
    .done16:
        popa ; restore all registers
        ret

[bits 32]
print_32:
    pusha ; save all registers

    mov edi, 0xB8000 ; VGA text memory segment (physical address)
    mov ecx, 0 ; column counter

    .next32_char:
        mov al, [ebx] ; load char
        cmp al, 0 ; null terminator?
        je .done32
        mov bl, 0x07 ; attribute byte (color)

        mov [edi], al ; write character
        mov [edi+1], bl ; write attribute

        add edi, 2 ; move to next character cell
        inc ebx ; next character in string
        jmp .next32_char

    .done32:
        popa ; restore all registers
        ret