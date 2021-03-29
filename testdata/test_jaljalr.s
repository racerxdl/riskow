.global _boot
.text

_boot:
  nop
  nop
  nop
  nop
  nop
  jal x1, branch1
branch2:

  beq x0, x0, branch2 /* Unreachable */
branch3:
  addi x0, x0, 1
  addi x0, x0, 2

branch1:
  addi x0, x0, 3
  jalr x2, x1, 4
  addi x0, x0, 4
  addi x0, x0, 5
  addi x0, x0, 6


  /* NOPs */
  nop
  nop
  nop
  nop
  nop
  nop
