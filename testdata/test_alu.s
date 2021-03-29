.global _boot
.text

_boot:                  /* x0  = 0    0x000 */
  /* Test ADDI */
  addi x1 , x0,   1000  /* x1  = 1000 0x3E8 */
  addi x2 , x1,   2000  /* x2  = 3000 0xBB8 */
  addi x3 , x2,  -1000  /* x3  = 2000 0x7D0 */
  addi x4 , x3,  -2000  /* x4  = 0    0x000 */
  addi x5 , x4,   1000  /* x5  = 1000 0x3E8 */
  addi x6 , x5,   2000  /* x6  = 3000 0xBB8 */
  addi x7 , x6,  -1000  /* x7  = 2000 0x7D0 */
  addi x8 , x7,  -2000  /* x8  = 0    0x000 */
  addi x9 , x8,   1000  /* x9  = 1000 0x3E8 */
  addi x10, x9,   2000  /* x10 = 3000 0xBB8 */
  addi x11, x10, -1000  /* x11 = 2000 0x7D0 */
  addi x12, x11, -2000  /* x12 = 0    0x000 */
  addi x13, x12,  1000  /* x13 = 1000 0x3E8 */
  addi x14, x13,  2000  /* x14 = 3000 0xBB8 */
  addi x15, x14, -1000  /* x15 = 2000 0x7D0 */

  /* Test Positive numbers */
  slti x15, x1,  1200   /* x15 = 1 */
  slti x14, x2,  1200   /* x14 = 0 */

  /* Test Negative numbers */
  addi x3,  x0, -1000
  slti x13, x3, -1200   /* x13 = 0 */
  slti x12, x3, -900    /* x12 = 1 */

  /* Test Unsigned */
  sltiu x11, x1,  1200   /* x11 = 1 */
  sltiu x10, x2,  1200   /* x10 = 0 */

  /* Test XOR */
  addi x1, x0, 0x7FF
  addi x2, x0, 0x70F
  addi x3, x0, 0x0F0

  xori x15, x1, -1      /*  x15 = 0xFFFFF800 */
  xori x14, x2, -1      /*  x14 = 0xFFFFF8F0 */
  xori x13, x3, -1      /*  x13 = 0xFFFFFF0F */

  /* Test OR */
  addi x1, x0, 0x7FF
  addi x2, x0, 0x70F
  addi x3, x0, 0x0F0

  ori x15, x1, -1      /*  x15 = 0xFFFFFFFF */
  ori x14, x2, -1      /*  x14 = 0xFFFFFFFF */
  ori x13, x3, -1      /*  x13 = 0xFFFFFFFF */
  ori x12, x1,  0      /*  x12 = 0x000007FF */
  ori x11, x2,  0      /*  x11 = 0x0000070F */
  ori x10, x3,  0      /*  x10 = 0x000000F0 */

  /* Test AND */
  addi x1, x0, 0x7FF
  addi x2, x0, 0x70F
  addi x3, x0, 0x0F0

  andi x15, x1, -1      /*  x15 = 0x000007FF */
  andi x14, x2, -1      /*  x14 = 0x0000070F */
  andi x13, x3, -1      /*  x13 = 0x000000F0 */
  andi x12, x1, 341     /*  x12 = 0x00000155 */
  andi x11, x2, 341     /*  x11 = 0x00000105 */
  andi x10, x3, 341     /*  x10 = 0x00000050 */

  /* Test Shift Left */
  addi x1, x0, 0x7FF
  slli x15, x1, 0       /* x15 = 0x000007FF */
  slli x14, x1, 1       /* x14 = 0x00000FFE */
  slli x13, x1, 2       /* x13 = 0x00001FFC */
  slli x12, x1, 3       /* x12 = 0x00003FF8 */
  slli x11, x1, 8       /* x11 = 0x0007FF00 */
  slli x10, x1, 16      /* x10 = 0x07FF0000 */
  slli x9, x1,  24      /* x9  = 0xFF000000 */

  /* Test Shift Right */
  addi x6,  x9, 0       /* Backup X9 with 0xFF000000 */
  addi x1,  x9, 0
  srli x15, x1, 0       /* x15 = 0xFF000000 */
  srli x14, x1, 1       /* x14 = 0x7F800000 */
  srli x13, x1, 2       /* x13 = 0x3FC00000 */
  srli x12, x1, 3       /* x12 = 0x1FE00000 */
  srli x11, x1, 8       /* x11 = 0x00FF0000 */
  srli x10, x1, 16      /* x10 = 0x0000FF00 */
  srli x9,  x1, 24      /* x9  = 0x000000FF */

  /* Test Shift Right */
  addi x1,  x6, 0
  srai x15, x1, 0       /* x15 = 0xFF000000 */
  srai x14, x1, 1       /* x14 = 0xFF800000 */
  srai x13, x1, 2       /* x13 = 0xFFC00000 */
  srai x12, x1, 3       /* x12 = 0xFFE00000 */
  srai x11, x1, 8       /* x11 = 0xFFFF0000 */
  srai x10, x1, 16      /* x10 = 0xFFFFFF00 */
  srai x9,  x1, 24      /* x9  = 0xFFFFFFFF */

  /* Test ADD */
  addi x1, x6, 0        /* x1  = 0xFF000000 */
  add  x15, x1, x1      /* x15 = 0xFE000000 */
  add  x14, x1, x9      /* x14 = 0xFEFFFFFF */
  add  x13, x0, x1      /* x13 = 0xFF000000 */

  /* Test SUB */
  addi x1, x6, 0        /* x1  = 0xFF000000 */
  sub  x15, x1, x1      /* x15 = 0x00000000 */
  sub  x14, x1, x9      /* x14 = 0xFF000001 */
  sub  x13, x0, x1      /* x13 = 0x01000000 */

  /* NOPs */
  nop
  nop
  nop
