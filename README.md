# BasicOS

A basic hobby OS for the x86_32 and x86_64 architectures.

It is currently in development, so it is expected for the OS to give errors.

It consists of two parts:
1. The bootloader, bootable via legacy BIOS booting. It occupies two sectors: cyl 0 head 0 sector 1 (boot sector) and cyl 0 head 0 sector 2 for the Global Descriptor Table (GDT) used when switching to Protected Mode (32-bit)
2. The kernel, which basically does nothing except being loaded onto address 0x9000 from sectors 3 up right now.


  
## Requirements

- Binutils and GCC (Cross-compiler)
- NASM (Assembler)
- Some sort of emulator to run the OS


  
## Project layout

    .  
    ├── src/  
    │   ├── bootloader/  
    │   │   ├── boot.asm  
    │   │   ├── bootprint.asm (contains utilities to print text to screen for the bootloader)  
    │   │   └── gdt.asm  
    │   └── kernel/  
    │       ├── kernel_entry.asm  
    │       └── kernel.cpp  
    ├── Makefile  
    ├── LICENSE  
    └── README.md  

>NOTE: When building the project, there will be generated two directories in the root folder, called `build` and `dist`. The `dist` folder will contain the .bin file resulting of the compilation and assembling.


  
## RAM layout

0x0 - 0x7c00: BIOS stuff  
0x7c00 - 0x7e00: Main bootloader  
0x7e00 - 0x8000: GDT  
0x8000 - 0x9000: Stack  
0x9000 - 0x90000: Kernel  
0x90000 - 0xB0000: Code segments (for future ASM extensions, each of 0x4000 bytes, or 16Kb, in size)  
0xB0000 - 0xD0000: Data segments (for future ASM extensions, each of 0x4000 bytes, or 16Kb, in size)  

  
## Build commands

To build: `make build OS_ROOT=/path/to/project/root/ GCC=/path/to/gcc LD=/path/to/linker` or `make OS_ROOT=/path/to/project/root GCC=/path/to/gcc LD=/path/to/linker`  
To clean: `make clean OS_ROOT=/path/to/project/root/` or `rm -rf /path/to/project/root/build`

  
## Notice

Some code of this project is partially AI-generated and then adapted and rewritten.
