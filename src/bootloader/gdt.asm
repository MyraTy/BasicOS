; GDT is in head 0 cyl 0 sector 2
GDT32_start:
    GDT32_null:
        dq 0x0000000000000000

    GDT32_kernel_code:
        dq 0x00409A0900000FFF

    GDT32_kernel_data:
        dq 0x0040920B00000FFF

    GDT32_user_code:
        dq 0x0040FA0A00000FFF

    GDT32_user_data:
        dq 0x0040F20C00000FFF
GDT32_end:

GDT32_descriptor:
    dw GDT32_end - GDT32_start - 1
    dd GDT32_start

times 512-($-GDT32_start) db 0 ; pad to 512 bytes
