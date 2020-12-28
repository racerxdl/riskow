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
  nop

branch1:
  nop
  nop
  nop
  jalr x2, x1, 4

