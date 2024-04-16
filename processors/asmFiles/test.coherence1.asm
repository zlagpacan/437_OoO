# Multicore coherence test
# Each core stores to values that exist on the same block in the cache

# core 1
org 0x0000
  ori $t0, $0, data1
  lui $t1, 0xDEAD
  ori $t1, $t1, 0xBEEF
  sw  $t1, 0($t0)
  ori $t0, $0, data4
  lui $t1, 0xCAB1
  ori $t1, $t1, 0xFEED
  sw  $t1, 0($t0)
  halt

# core 2
org 0x0200
  ori $t0, $0, data2
  lui $t1, 0x89AB
  ori $t1, $t1, 0xCDEF
  sw  $t1, 0($t0)
  ori $t0, $0, data3
  lui $t1, 0x0123
  ori $t1, $t1, 0x4567
  sw  $t1, 0($t0)
  halt

org 0x0400
data1:
  cfw 0xBAD0BAD0
data2:
  cfw 0xBAD0BAD0
data3:
  cfw 0xBAD0BAD0
data4:
  cfw 0xBAD0BAD0
