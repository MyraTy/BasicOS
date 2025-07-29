.PHONY: build clean

build:
	echo "Preparing everythng..."
	rm -rf $(OS_ROOT)/build
	rm -rf $(OS_ROOT)/dist
	mkdir -p $(OS_ROOT)/build
	mkdir -p $(OS_ROOT)/dist

	echo "Building bootloader..."
	nasm $(OS_ROOT)/src/bootloader/boot.asm -f bin -o $(OS_ROOT)/build/boot.bin

	echo "Building kernel..."
	$(GCC) -ffreestanding -m32 -g -c $(OS_ROOT)/src/kernel/kernel.cpp -o $(OS_ROOT)/build/kernel.o
	nasm $(OS_ROOT)/src/kernel/kernel_entry.asm -f elf -o $(OS_ROOT)/build/kernel_entry.o

	echo "Linking kernel..."
	$(LD) -o $(OS_ROOT)/build/full_kernel.bin $(OS_ROOT)/build/kernel_entry.o $(OS_ROOT)/build/kernel.o -Ttext 0x9000 --oformat binary

	echo "Building OS..."
	cat $(OS_ROOT)/build/boot.bin $(OS_ROOT)/build/full_kernel.bin > $(OS_ROOT)/dist/os.bin

clean:
	rm -rf $(OS_ROOT)/build
