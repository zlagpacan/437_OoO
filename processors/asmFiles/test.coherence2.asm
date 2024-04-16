# Multicore coherence test
# stores 0xDEADBEEF to value

#core 1
org 0x0000
  ori $t0, $0, word1
  lw  $t1, 0($t0)
  ori $t2, $0, 16
  sllv $t1, $t2, $t1
  ori $t4, $0, value
  ori $t2, $0, flag

# wait for core 2 to finish
wait1:
  lw  $t3, 0($t2)
  beq $t3, $0, wait1

# complete store
  lw  $t0, 0($t4)
  or  $t0, $t0, $t1
  sw  $t0, 0($t4)

  halt

# core 2
org 0x0200
  ori $t0, $0, word2
  lw  $t1, 0($t0)
  ori $t2, $0, value
  sw  $t1, 0($t2)

# set flag
  ori $t1, $0, flag
  ori $t2, $0, 1

  sw  $t2, 0($t1)
  halt

org 0x0400
flag:
  cfw 0

org 0x0408
value:
  cfw 0

word1:
  cfw 0x0000DEAD
  cfw 0
word2:
  cfw 0x0000BEEF

