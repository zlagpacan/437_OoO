#--------------------------------------
# Test branch and jumps
#--------------------------------------
  org 0x0000
  ori   $1, $zero, 0xBA5C
  ori   $2, $zero, 0x0080
  ori   $15, $zero, jmpR
  beq   $zero, $zero, braZ
  nop   # need
  nop   # need
  nop   # need
  sw    $1, 0($2)
braZ:
  jal   braR
  nop   # need
  sw    $1, 4($2)
end:
  sw    $ra, 16($2)
  HALT
braR:
  or    $3, $zero, $ra
  sw    $ra, 8($2)
  jal   jmpR
  nop   # need
  sw    $1, 12($2)
jmpR:
  bne   $ra, $3, end
  nop   # need
  nop   # need
  nop   # need
  halt
