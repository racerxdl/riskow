/* Thanks https://github.com/darklife/darkriscv */
MEMORY
{
    MEM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x2000
    MEM2 (rwx): ORIGIN = 0x00002000, LENGTH = 0x2000
}
SECTIONS
{
    .text :
    {
        *(.text.boot)
        *(.text)
    } > MEM
    .data :
    {
        *(.sbss)
        *(.rodata*)
        *(.data)
        *(.bss)
        *(.rela*)
        *(COMMON)
    } > MEM2
}
