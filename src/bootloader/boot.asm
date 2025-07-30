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
mov ax, GDT_LOCATION ; Load the GDT from the disk
shr ax, 4 ; GDT is at 0x7E00/16 = 0x7E0
mov es, ax ; Set ES to the GDT segment
mov bx, 0 ; with an offset 0 within that segment.
mov ah, 2 ; Mandatory
mov al, 20 ; Read 1 sector
mov dl, 0x80 ; from the C:/ disk, starting from
mov ch, 0x00 ; cylinder 0, 
mov dh, 0x00 ; head 0
mov cl, 0x02 ; and sector 2.
int 0x13

jnc loadk ; Carry flag set to 1 after disk read means there's an error. If no errors, continue

mov bx, disk_crash_cf_msg_gdt
call print_16
jmp exit ; If an error occurs, hang

loadk:
mov ax, KERNEL_LOCATION ; Load the kernel from the disk
shr ax, 4 ; Kernel is at 0x9000/16 = 0x900
mov es, ax ; Set ES to the GDT segment
mov bx, 0 ; with an offset 0 within that segment.
mov ah, 2 ; Mandatory
mov al, 20 ; Read 20 sectors
mov dl, 0x80 ; from the C:/ disk, starting from
mov ch, 0x00 ; cylinder 0, 
mov dh, 0x00 ; head 0
mov cl, 0x03 ; and sector 3
int 0x13

cmp dh, al
jne disk_crash_nsectors_kernel ; An error has occured if the number of sectors to read changes after disk read

jnc init_protected_mode ; Carry flag set to 1 after disk read means there's an error

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

    mov ebx, init32msg
    mov ecx, 0
    mov edx, 2
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
    db "Fatal: Carry flag set when loading the GDT.", 13, 10, 0

disk_crash_cf_msg_kernel:
    db "Fatal: Carry flag set when loading kernel.", 13, 10, 0

disk_crash_nsectors_msg_kernel:
    db "Fatal: Number of sectors read too low for the kernel to fit in.", 13, 10, 0

init32msg:
    db "Now in 32-bit mode. Starting kernel...", 13, 10, 0

times 510-($-$$) db 0 ; Pad up to 510 bytes         
dw 0xaa55 ; Last two bytes are the bootloader sign

%include "./src/bootloader/gdt.asm" ; Next sector is GDT