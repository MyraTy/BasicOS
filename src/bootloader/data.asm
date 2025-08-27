; ----- Boot progress messages -----
initmsg:
	db "Bootloader started!", 13, 10, 0

before32msg:
	db "Loads sucessful. Starting 32-bit mode...", 13, 10, 0

init32msg:
	db "Now in 32-bit mode. Starting kernel...", 13, 10, 0


; ----- Disk number and error handling -----
diskno:
	db 0

disk_crash_first:
	db "Fatal (tried to load the kernel): Could only read ", 0

nsectors:
	db 0

disk_crash_second:
	db " disk sectors. Error char: ", 0

errcode:
	dw 0

crlf:
	db 13, 10, 0

; ----- GDT-related data -----
GDT32_start:
	dq 0x0000000000000000 ; Null segment
	dq 0xFFFF0000909AF000 ; Code segment
	dq 0xFFFF0000A092F000 ; Data segment
GDT32_end:
GDT32_descriptor:
	dw GDT32_end - GDT32_start - 1
	dd GDT32_start
start_protected_mode_desc:
	dd CODE_SEG_BASE_ADDR
    dw 0x0008