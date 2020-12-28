.global _boot
.text

_boot:
  lui x1, 0xFFFFF   /*  x1 = 0xFFFFF000 */
  nop
  nop
  nop
  nop
  nop
  auipc x2, 0xFFFFF /*  x2 = 0xFFFFF018 */
  nop
  nop
  nop
