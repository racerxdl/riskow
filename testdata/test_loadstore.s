.global _boot
.text

_boot:
  lui x1, %hi(data0)
  addi x1, x0, %lo(data0)
  lw x15, 0(x1)            /* x15 = 0xDEADBEEF */
  nop

testhalf:
  lhu x14, 0(x1)            /* x14 = 0x0000BEEF */
  lhu x13, 1(x1)            /* x13 = 0x0000ADBE */
  lhu x12, 2(x1)            /* x12 = 0x0000DEAD */
  nop

testbyte:
  lbu x11, 0(x1)            /* x11 = 0x000000EF */
  lbu x10, 1(x1)            /* x10 = 0x000000BE */
  lbu x9, 2(x1)             /* x9  = 0x000000AD */
  lbu x8, 3(x1)             /* x8  = 0x000000DE */
  nop

  lui x1, %hi(data1)
  addi x1, x0, %lo(data1)

testhalfsign:
  lh x15, 0(x1)             /* x15 = 0xFFFF8281 */
  lh x14, 1(x1)             /* x14 = 0xFFFF8382 */
  lh x13, 2(x1)             /* x13 = 0xFFFF8483 */
  nop

testbytesign:
  lb x12, 0(x1)             /* x11 = 0xFFFFFF81 */
  lb x11, 1(x1)             /* x10 = 0xFFFFFF82 */
  lb x10, 2(x1)             /* x9  = 0xFFFFFF83 */
  lb x9,  3(x1)             /* x8  = 0xFFFFFF84 */
  nop


.align 4
data0:
  .word 0xDEADBEEF

data1:
  .word 0x84838281
