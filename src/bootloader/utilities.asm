[org 0x7c00]

; ----- Printing utilities, both in real and protected mode -----
[bits 16]
print_16:
    pusha ; Save all registers

    .next16_char:
        mov al, [bx] ; Load byte
        cmp al, 0 ; Null terminator?
        je .done16

        mov ah, 0Eh ; BIOS teletype function
        int 0x10 ; BIOS interrupt
        inc bx ; Next char
        jmp .next16_char ; Continue loop

    .done16:
        popa ; Restore all registers
        ret

[bits 32]
print_32:
    pusha ; Save all registers

    mov edi, 0xB8000 ; VGA text memory segment (physical address)

    mov eax, 160 ; Number of bytes per line in text mode (80 columns * 2 bytes per character cell)
    mul edx ; Starting position in text mode memory
    add edi, eax ; Add column offset

    mov eax, 2 ; Each character cell is 2 bytes (char + attribute)
    mul ecx ; As each character cell is 2 bytes (char + attribute), the starting column will also be duplicated
    add edi, eax ; Add line offset

    .next32_char:
        mov al, [ebx] ; Load char
        cmp al, 0 ; Null terminator?
        je .done32
        mov ah, 0x07 ; Attribute byte (color)

        mov [edi], ax ; Write character and attribute to video memory

        add edi, 2 ; Move to next character cell
        inc ebx ; Next character in string
        jmp .next32_char ; Continue loop

    .done32:
        popa ; Restore all registers
        ret

; ----- Disk error handling (must provide a hang mechanism called exit to jump to) -----
diskerr:
	mov bx, disk_crash_first
	call print_16

	add al, '0' ; Convert the number of sectors read to ASCII (0-9)
	mov [nsectors], al ; Store the number of sectors read in nsectors
	mov bx, nsectors
	call print_16

	mov bx, disk_crash_second
	call print_16

	add ah, ' ' ; Make the error character a printable one (later substract by 0x20)
	mov al, ah
	xor ah, ah ; As ax is [ah:al], this is a way to null-terminate the string (ah contains the error code)

	mov [errcode], ax ; Store the error code in errcode
	mov bx, errcode
	call print_16

	mov bx, crlf
	call print_16

	jmp exit