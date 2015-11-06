BIN=dice_roller
ASFLAGS=-f elf 

all: $(BIN)
clean:
	rm $(BIN)

dice_roller: dice_roller.asm
	nasm $(ASFLAGS) -o $@ $<

