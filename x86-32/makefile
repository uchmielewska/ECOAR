CC=gcc
ASMBIN=nasm

all : asm cc link
asm : 
	$(ASMBIN) -o reduce_contrast.o -f elf -g -l reduce_contrast.lst reduce_contrast.asm
cc :
	$(CC) -m32 -c -g -O0 main.c
link :
	$(CC) -m32 -g -o program main.o reduce_contrast.o
clean :
	rm *.o
	rm program.exe
	rm reduce_contrast.lst
