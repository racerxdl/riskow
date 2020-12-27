SOURCES       := $(shell find . -name '*.s')
OBJECTS       := $(SOURCES:%.s=%.o)
TESTDATA      := $(SOURCES:%.s=%.elf)
HEXDATA       := $(SOURCES:%.s=%.hex)
MEMDATA       := $(SOURCES:%.s=%.mem)

CFLAGS=-mabi=ilp32e -march=rv32e
LDFLAGS=-T ../gcc/riskow.ld -m elf32lriscv -O binary

OC=riscv64-linux-gnu-objcopy
CC=riscv64-linux-gnu-gcc-10
LD=riscv64-linux-gnu-ld

all: clean $(TESTDATA)

%.elf: %.s
	@echo "Building $< -> $@"
	@$(CC) -c $(CFLAGS) -o $(@:%.elf=%.o) $<
	@$(LD) $(LDFLAGS) $(@:%.elf=%.o) -o $@

%.hex: %.elf
	@echo "Building $< -> $@"
	@$(OC) -O ihex $(@:%.hex=%.elf) $@ --only-section .text\*

%.mem: %.elf
	@echo "Building $< -> $@"
	@$(OC) -O binary $(@:%.mem=%.elf) $(@:%.mem=%.bin) --only-section .text\*
	@hexdump -ve '1/4 "%08x\n"' $(@:%.mem=%.bin) > $@

simhex: $(HEXDATA)
	@echo "Building prog.hex for http://tice.sea.eseo.fr/riscv/"

testmem: $(MEMDATA)
	@echo "Building memdata for unit tests"

clean:
	@echo "Cleaning build files"
	@rm -f $(OBJECTS) *.elf *.hex *.mem *.bin
