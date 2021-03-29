.global _boot
.section .boot

_boot:
  add x0,  x0, x0
  add x1,  x0, x0
  add x2,  x0, x0
  add x3,  x0, x0
  add x4,  x0, x0
  add x5,  x0, x0
  add x6,  x0, x0
  add x7,  x0, x0
  add x8,  x0, x0
  add x9,  x0, x0
  add x10, x0, x0
  add x11, x0, x0
  add x12, x0, x0
  add x13, x0, x0
  add x14, x0, x0
  add x15, x0, x0
  
  lui x2, %hi(_sstack)
  addi x2, x2, %lo(_sstack)
  j boot

; .text
; .globl bitbanger
; .type bitbanger, @function
; bitbanger:
;   /* Prepare Address 0xF0000008 */
;   addi x1,x0,8
;   lui x5, 0xf0000
;   add x5, x1, x5

;   /* Prepare led enabled */
;   addi x1, x0, 1

; ledloop:
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   sw   x0, 0(x5)
;   sw   x1, 0(x5)
;   j ledloop
