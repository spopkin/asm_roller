BIN=dice_roller

all: $(BIN)
clean:
	rm $(BIN)

dice_roller: dice_roller.asm
	nasm -o $@ $<

