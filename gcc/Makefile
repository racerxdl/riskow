ASM_SOURCES   := $(shell find . -name '*.s')
SOURCES       := $(shell find . -name '*.c')
OBJECTS       := $(SOURCES:%.c=%.o)
ASM_OBJECTS   := $(ASM_SOURCES:%.s=%.s.o)

CFLAGS=-mabi=ilp32e -march=rv32e
LDFLAGS=-T riskow.ld -m elf32lriscv -O binary

OC=riscv64-linux-gnu-objcopy
CC=riscv64-linux-gnu-gcc-10
LD=riscv64-linux-gnu-ld

all: clean prog.elf rom.mem excp.mem

%.o: %.c
	@echo "Building $< -> $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

%.s.o: %.s
	@echo "Building $< -> $@"
	@$(CC) -c $(CFLAGS) -o $@ $<

prog.elf: $(OBJECTS) $(ASM_OBJECTS)
	@echo "Linking prog.elf $(OBJECTS) $(ASM_OBJECTS)"
	@$(LD) $(LDFLAGS) $(OBJECTS) $(ASM_OBJECTS) -o prog.elf

rom.mem: prog.elf
	@echo "Building $< -> $@"
	@$(OC) -O binary prog.elf rom.bin --only-section .text\*
	@hexdump -ve '1/4 "%08x\n"' rom.bin > rom.mem

excp.mem: prog.elf
	@echo "Building $< -> $@"
	@$(OC) -O binary prog.elf excp.bin --only-section .exception\*
	@hexdump -ve '1/4 "%08x\n"' excp.bin > excp.mem

simhex: all
	@echo "Building prog.hex for http://tice.sea.eseo.fr/riscv/"
	@$(OC) -O ihex prog.elf prog.hex --only-section .text\*

clean:
	@echo "Cleaning build files"
	@rm -f $(OBJECTS) prog.elf prog.hex *.bin *.mem
