; GDT is in 2nd sector
GDT32_start:
    GDT32_null:
        dq 0x0000000000000000

    GDT32_kernel_code:
        dw 0x0001
        dw 0x0000
        db 0x09
        db 0b10011011
        db 0b11000000
        db 0x00

    GDT32_kernel_data:
        dw 0x0001
        dw 0x0000
        db 0x0B
        db 0b10010001
        db 0b11000000
        db 0x00
    
    GDT32_user_code:
        dw 0x0001
        dw 0x0000
        db 0x0D
        db 0b11111111
        db 0b11000000
        db 0x00

    GDT32_user_data:
        dw 0x0001
        dw 0x0000
        db 0x0F
        db 0b11110111
        db 0b11000000
        db 0x00

GDT32_end:

GDT32_descriptor:
    dw GDT32_end - GDT32_start - 1
    dw GDT32_start

BOOT_DISK: db 0

times 512-($-GDT32_start) db 0 ; Pad up to 512 bytess