
  #------------------------------------------------------------------
  # Tests lui lw sw
  #------------------------------------------------------------------

  org   0x0000
  ori   $1,$zero,0xF0
  ori   $2,$zero,0x80
  lui   $7,0xdead
  nop   # need
  nop   # need
  ori   $7,$7,0xbeef
  lw    $3,0($1)
  lw    $4,4($1)
  lw    $5,8($1)
  
  sw    $3,0($2)
  sw    $4,4($2)
  sw    $5,8($2)
  sw    $7,12($2)
  halt      # that's all

  org   0x00F0
  cfw   0x7337
  cfw   0x2701
  cfw   0x1337
