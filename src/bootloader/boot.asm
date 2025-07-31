[org 0x7c00]
[bits 16]

GDT_LOCATION equ 0x7E00  
KERNEL_LOCATION equ 0x9000
STACK_START_LOCATION equ 0x9000
KERNEL_NSECTORS equ 20 ; Number of sectors to read for the kernel

CODE_SEG_BASE_ADDR equ 0x90000
DATA_SEG_BASE_ADDR equ 0xB0000

CODE_SEG_MAXSIZE equ 0x4000
DATA_SEG_MAXSIZE equ 0x4000   

init:                       
    xor ax, ax ; Zero ax                  
    mov es, ax
    mov ds, ax
    mov bp, STACK_START_LOCATION
    mov sp, bp

mov bx, initmsg
call print_16

loadgdt:
    mov ax, GDT_LOCATION ; Load the GDT from the disk
    shr ax, 4 ; GDT is at 0x7E00/16 = 0x7E0
    mov es, ax ; Set ES to the GDT segment
    mov bx, 0 ; with an offset 0 within that segment.
    mov ah, 2 ; Mandatory
    mov al, 1 ; Read 1 sector
    mov dl, 0x80 ; from the C:/ disk, starting from
    mov ch, 0x00 ; cylinder 0, 
    mov dh, 0x00 ; head 0
    mov cl, 0x02 ; and sector 2.
    int 0x13
mov cx, gdt_str
jc diskerr ; Carry flag set to 1 after disk read means there's an error.

loadk:
    mov ax, KERNEL_LOCATION ; Load the kernel from the disk
    shr ax, 4 ; Kernel is at 0x9000/16 = 0x900
    mov es, ax ; Set ES to the GDT segment
    mov bx, 0 ; with an offset 0 within that segment.
    mov ah, 2 ; Mandatory
    mov al, KERNEL_NSECTORS ; Read 20 sectors
    mov dl, 0x80 ; from the C:/ disk, starting from
    mov ch, 0x00 ; cylinder 0, 
    mov dh, 0x00 ; head 0
    mov cl, 0x03 ; and sector 3
    int 0x13

mov cx, kernel_str
jc diskerr ; Carry flag set to 1 after disk read means there's an error.

init_protected_mode:
    CODE_SEG32 equ GDT32_kernel_code - GDT32_start
    DATA_SEG32 equ GDT32_kernel_data - GDT32_start

    mov bx, before32msg
    call print_16 ; Print the message before switching to 32-bit mode

    cli ; Disable BIOS interrupts
    lgdt [GDT32_descriptor] ; Load GDT
    mov eax, cr0 ; Zero out the CR0 register
    or al, 1
    mov cr0, eax ; Set the PE (Protection Enable) bit in CR0. Now officially in protected mode.
    call print_32
    jmp CODE_SEG32:start_protected_mode ; Far jump

[bits 32]
start_protected_mode:

    mov ax, DATA_SEG32
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, STACK_START_LOCATION
	mov esp, ebp

    mov ebx, init32msg
    mov ecx, 0 ; Column number
    mov edx, 2 ; Line number
    call print_32

    jmp KERNEL_LOCATION         

diskerr:
    mov bx, disk_crash_first
    call print_16

    mov bx, cx; In theory, cx contains the thing it was being loaded when the error occured
    call print_16

    mov bx, disk_crash_second
    call print_16

    add al, '0' ; Convert the number of sectors read to ASCII (0-9)
    mov [nsectors], al ; Store the number of sectors read in nsectors
    mov bx, nsectors
    call print_16

    mov bx, disk_crash_third
    call print_16

    mov [errcode], ah ; Store the error code in errcode]
    mov bx, errcode
    call print_16

    mov bx, crlf
    call print_16

    jmp exit

exit:
    jmp exit ; Emergency hang

%include "./src/bootloader/bootprint.asm"

initmsg:
    db "Bootloader started!", 13, 10, 0

disk_crash_first:
    db "Fatal (tried to load the ", 0

disk_crash_second:
    db " ): Could only read ", 0

disk_crash_third:
    db " disk sectors. Error char: ", 0

crlf:
    db 13, 10, 0

gdt_str:
    db "GDT", 0

kernel_str:
    db "kernel", 0

nsectors:
    db 0

errcode:
    db 0

before32msg:
    db "Loads sucessful. Starting 32-bit mode...", 13, 10, 0

init32msg:
    db "Now in 32-bit mode. Starting kernel...", 13, 10, 0

times 510-($-$$) db 0 ; Pad up to 510 bytes         
dw 0xaa55 ; Last two bytes are the bootloader sign

%include "./src/bootloader/gdt.asm" ; Next sector is GDT