[org 0x7c00]
bits 16

KERNEL_LOCATION equ 0x9000
STACK_START_LOCATION equ 0x8000
KERNEL_NSECTORS equ 1

CODE_SEG_BASE_ADDR equ 0x900000
DATA_SEG_BASE_ADDR equ 0xA00000

CODE_SEG_MAXSIZE equ 0x4000
DATA_SEG_MAXSIZE equ 0x4000   

init:    
	mov [diskno], dl ; Store the disk number
	xor ax, ax ; Zero ax                  
	mov es, ax
	mov ds, ax
	mov bp, STACK_START_LOCATION
	mov sp, bp

mov bx, initmsg
call print_16

loadk:
	mov ax, KERNEL_LOCATION ; Load the kernel from the disk
	shr ax, 4 ; Kernel is at 0x9000/16 = 0x900
	mov es, ax ; Set ES to the GDT segment
	mov bx, 0 ; with an offset 0 within that segment.
	mov ah, 2 ; Mandatory
	mov al, KERNEL_NSECTORS ; Number of sectors to read, starting from
	mov ch, 0x00 ; cylinder 0, 
	mov dh, 0x00 ; head 0
	mov cl, 0x03 ; and sector 3
	int 0x13

mov cx, kernel_str
jc diskerr ; Carry flag set to 1 after disk read means there's an error.

init_protected_mode:

	mov bx, before32msg
	call print_16 ; Print the message before switching to 32-bit mode

	cli ; Disable BIOS interrupts
	lgdt [GDT32_descriptor] ; Load GDT

	bits 32
	mov eax, cr0 ; Zero out the CR0 register
	or eax, 1
	mov cr0, eax ; Set the PE (Protection Enable) bit in CR0. Now officially in protected mode.
	
	; Set up segment registers before far jump
	mov ax, 0x10
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, STACK_START_LOCATION
	mov esp, ebp

	jmp far [start_protected_mode_desc]

start_protected_mode:
	mov ebx, init32msg
	mov ecx, 0 ; Column number
	mov edx, 2 ; Line number
	call print_32
	jmp KERNEL_LOCATION
end_start_protected_mode:

bits 16
exit:
	hlt
	jmp exit ; Hang when needed

%include "./src/bootloader/utilities.asm"
%include "./src/bootloader/data.asm"

times 510-($-$$) db 0 ; Pad up to 510 bytes         
dw 0xaa55 ; Last two bytes are the bootloader sign