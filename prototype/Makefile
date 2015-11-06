VFLAGS=-Wall -std=c11
BIN=dice_roller

all: $(BIN)
clean:
	rm $(BIN)

dice_roller: dice_roller.c
	gcc -g $(VFLAGS) -o $@ $<

