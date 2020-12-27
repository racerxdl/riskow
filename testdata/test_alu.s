.global _boot
.text

_boot:                  /* x0  = 0    0x000 */
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



/*
imm[11:0]                   rs1 000 rd          0010011 ||| I addi    || x[rd] = x[rs1] + sext(immediate)
imm[11:0]                   rs1 010 rd          0010011 ||| I slti    || x[rd] = x[rs1] < sext(immediate)    [  SIGNED  ]
imm[11:0]                   rs1 011 rd          0010011 ||| I sltiu   || x[rd] = x[rs1] < sext(immediate)    [ UNSIGNED ]
imm[11:0]                   rs1 100 rd          0010011 ||| I xori    || x[rd] = x[rs1] ˆ sext(immediate)
imm[11:0]                   rs1 110 rd          0010011 ||| I ori     || x[rd] = x[rs1] | sext(immediate)
imm[11:0]                   rs1 111 rd          0010011 ||| I andi    || x[rd] = x[rs1] & sext(immediate)
0000000               shamt rs1 001 rd          0010011 ||| I slli    || x[rd] = x[rs1] << shamt
0000000               shamt rs1 101 rd          0010011 ||| I srli    || x[rd] = x[rs1] >> shamt
0100000               shamt rs1 101 rd          0010011 ||| I srai    || x[rd] = x[rs1] >> shamt             [  SIGNED  ]
0000000               rs2   rs1 000 rd          0110011 ||| R add     || x[rd] = x[rs1] + x[rs2]
0100000               rs2   rs1 000 rd          0110011 ||| R sub     || x[rd] = x[rs1] - x[rs2]
0000000               rs2   rs1 001 rd          0110011 ||| R sll     || x[rd] = x[rs1] << x[rs2]
0000000               rs2   rs1 010 rd          0110011 ||| R slt     || x[rd] = x[rs1] < x[rs2]             [  SIGNED  ]
0000000               rs2   rs1 011 rd          0110011 ||| R sltu    || x[rd] = x[rs1] < x[rs2]             [ UNSIGNED ]
0000000               rs2   rs1 100 rd          0110011 ||| R xor     || x[rd] = x[rs1] ^ x[rs2]
0000000               rs2   rs1 101 rd          0110011 ||| R srl     || x[rd] = x[rs1] >> x[rs2]            [ UNSIGNED ]
0100000               rs2   rs1 101 rd          0110011 ||| R sra     || x[rd] = x[rs1] >> x[rs2]            [  SIGNED  ]
0000000               rs2   rs1 110 rd          0110011 ||| R or      || x[rd] = x[rs1] | x[rs2]
0000000               rs2   rs1 111 rd          0110011 ||| R and     || x[rd] = x[rs1] & x[rs2]

 */