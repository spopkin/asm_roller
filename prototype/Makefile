VFLAGS=-Wall -std=c11
BIN=dice_roller intToString

all: $(BIN)
clean:
	rm $(BIN)

dice_roller: dice_roller.c
	gcc -g $(VFLAGS) -o $@ $<

intToString: intToString.c
	gcc -g $(VFLAGS) -o $@ $<

