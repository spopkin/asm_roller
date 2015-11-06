BIN=dice_roller 
ASFLAGS=-f elf 

all: $(BIN)
clean:
	rm $(BIN)

dice_roller.o: dice_roller.asm
	nasm $(ASFLAGS) $<
	
	
dice_roller: dice_roller.o	
	ld -s -o $@ $< 
	chmod 0777 $@
