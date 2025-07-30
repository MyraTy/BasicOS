[org 0x7c00]
[bits 16]

GDT_LOCATION equ 0x7E00    
KERNEL_LOCATION equ 0x9000                       
STACK_START_LOCATION equ 0x9000

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
mov ah, 2 ; Mandatory
mov al, 20 ; Read 1 sector
mov dl, 0x80 ; from the C:/ disk, starting from
mov ch, 0x00 ; cylinder 0, 
mov dh, 0x00 ; head 0
mov cl, 0x02 ; and sector 2
mov bx, GDT_LOCATION ; and dump the data into address 0xE00.
int 0x13

jnc loadk ; Carry flag set to 1 after disk read means there's an error. If no errors, continue

mov bx, disk_crash_cf_msg_gdt
call print_16
jmp exit ; If an error occurs, hang

loadk:
mov ah, 2 ; Mandatory
mov al, 20 ; Read 20 sectors
mov dl, 0x80 ; from the C:/ disk, starting from
mov ch, 0x00 ; cylinder 0, 
mov dh, 0x00 ; head 0
mov cl, 0x03 ; and sector 3
mov bx, KERNEL_LOCATION ; and dump the data into address 0x1000.
int 0x13


jc disk_crash_cf_kernel ; Carry flag set to 1 after disk read means there's an error

cmp dh, al
jne disk_crash_nsectors_kernel ; There's also an error if the number of sectors to read changes after disk read

jmp init_protected_mode ; If no errors occur while reading disk, continue

disk_crash_cf_kernel:
    mov bx, disk_crash_cf_msg_kernel
    call print_16
    jmp exit

disk_crash_nsectors_kernel:
    mov bx, disk_crash_nsectors_msg_kernel
    call print_16
    jmp exit

init_protected_mode:
CODE_SEG32 equ GDT32_kernel_code - GDT32_start
DATA_SEG32 equ GDT32_kernel_data - GDT32_start

cli
lgdt [GDT32_descriptor]
mov eax, cr0
or al, 1
mov cr0, eax
jmp CODE_SEG32:start_protected_mode

[bits 32]
start_protected_mode:

    mov esi, init32msg
    mov ebx, 0
    mov ecx, 2
    call print_32


    mov ax, DATA_SEG32
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	
	mov ebp, STACK_START_LOCATION
	mov esp, ebp

    jmp KERNEL_LOCATION         

exit:
    jmp exit ; Emergency hang

%include "./src/bootloader/bootprint.asm"

initmsg:
    db "Bootloader started without issues. Retrieving kernel and GDT...", 13, 10, 0

disk_crash_cf_msg_gdt:
    db "Fatal: Carry flag set when retrieving the GDT from disk.", 13, 10, 0

disk_crash_cf_msg_kernel:
    db "Fatal: Carry flag set when retrieving the kernel from disk.", 13, 10, 0

disk_crash_nsectors_msg_kernel:
    db "Fatal: Number of sectors to read too low when retrieving the kernel from disk.", 13, 10, 0

init32msg:
    db "Now in 32-bit mode. Loading kernel...", 13, 10, 0

times 510-($-$$) db 0 ; Pad up to 510 bytes         
dw 0xaa55 ; Last two bytes are the bootloader sign

%include "./src/bootloader/gdt.asm" ; Next sector is GDT