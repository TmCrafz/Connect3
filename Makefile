APP= connect3
NASM = nasm
NASMFLAGS = -f elf32 -g
LD = ld
LDFLAGS = -m elf_i386 -s -o

all: $(APP)

$(APP): main.o console.o game.o utils.o debug.o
	$(LD) $(LDFLAGS) $(APP) main.o console.o game.o utils.o debug.o

main.o: main.asm
	$(NASM) $(NASMFLAGS) main.asm

console.o: console.asm
	$(NASM) $(NASMFLAGS) console.asm

game.o: game.asm
	$(NASM) $(NASMFLAGS) game.asm

utils.o: utils.asm
	$(NASM) $(NASMFLAGS) utils.asm

debug.o: debug.asm
	$(NASM) $(NASMFLAGS) debug.asm


clean:
	rm -rf *.o *~
