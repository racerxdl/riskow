
SOURCES       := $(shell find . -name '*.c')
OBJECTS       := $(SOURCES:%.c=%.o)

CFLAGS=-mabi=ilp32e -march=rv32e
LDFLAGS=-T riskow.ld -m elf32lriscv -O binary

OC=riscv64-linux-gnu-objcopy
CC=riscv64-linux-gnu-gcc-10
LD=riscv64-linux-gnu-ld

all: clean prog.elf

%.o: %.c
	@echo "Building $< -> $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

prog.elf: $(OBJECTS)
	@echo "Linking prog.elf $(OBJECTS)"
	@$(LD) $(LDFLAGS) $(OBJECTS) -o prog.elf

simhex: all
	@echo "Building prog.hex for http://tice.sea.eseo.fr/riscv/"
	@$(OC) -O ihex prog.elf prog.hex --only-section .text\*

clean:
	@echo "Cleaning build files"
	@rm -f $(OBJECTS) prog.elf prog.hex
