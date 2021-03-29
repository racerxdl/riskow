.global _boot
.text

_boot:
  lui x1, %hi(data0)
  addi x1, x1, %lo(data0)
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
  addi x1, x1, %lo(data1)

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

teststorebyte:
  lui x1, %hi(data1)
  addi x1, x1, %lo(data1)
  lw x12, 0(x1)             /* x11      = 0x84838281 */

  lui x1, %hi(data2)
  addi x1, x1, %lo(data2)

  sb x12, 0(x1)             /* data2[0] = 0x00000081 */
  sh x12, 4(x1)             /* data2[1] = 0x00008281 */
  sw x12, 8(x1)             /* data2[2] = 0x84838281 */
  nop

testunalignedstore:
  sw x0, 0(x1)
  sw x0, 4(x1)
  sw x0, 8(x1)
  sw x0, 16(x1)
  
  sb x12, 0(x1)              /* data2[0] = 0x00000081 */
  sb x12, 5(x1)              /* data2[1] = 0x00008100 */
  sb x12, 10(x1)             /* data2[2] = 0x00810000 */
  sb x12, 15(x1)             /* data2[3] = 0x81000000 */

  sw x0, 16(x1)
  sw x0, 20(x1)
  sw x0, 24(x1)

  sh x12, 16(x1)             /* data2[4] = 0x00008281 */
  sh x12, 21(x1)             /* data2[5] = 0x00828100 */
  sh x12, 26(x1)             /* data2[6] = 0x82810000 */
  nop
  nop
  nop
  nop


.align 4
data0:
  .word 0xDEADBEEF

data1:
  .word 0x84838281

.section .data
data2:
  .word 0x00000000 /* data2[0] => data2 + 0 */
  .word 0x00000000 /* data2[1] => data2 + 4 */
  .word 0x00000000 /* data2[2] => data2 + 8 */
  .word 0x00000000 /* data2[3] => data2 + 12 */

  .word 0x00000000 /* data2[4] => data2 + 16 */
  .word 0x00000000 /* data2[5] => data2 + 20 */
  .word 0x00000000 /* data2[6] => data2 + 24 */
  .word 0x00000000 /* data2[7] => data2 + 28 */

