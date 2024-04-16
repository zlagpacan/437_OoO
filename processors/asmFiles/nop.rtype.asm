
  #------------------------------------------------------------------
  # R-type Instruction (ALU) Test Program
  #------------------------------------------------------------------

  org 0x0000
  ori   $1,$zero,0xD269
  nop   # need
  nop   # need
  nop   # need
  ori   $2,$zero,0x37F1
  nop   # need
  nop   # need
  nop   # need

  ori   $21,$zero,0x80
  nop   # need
  nop   # need
  nop   # need
  ori   $22,$zero,0xF0
  nop   # need
  nop   # need
  nop   # need

# Now running all R type instructions
  or    $3,$1,$2
  nop   # need
  nop   # need
  nop   # need
  and   $4,$1,$2
  nop   # need
  nop   # need
  nop   # need
  andi  $5,$1,0xF
  nop   # need
  nop   # need
  nop   # need
  addu  $6,$1,$2
  nop   # need
  nop   # need
  nop   # need
  addiu $7,$3,0x8740
  nop   # need
  nop   # need
  nop   # need
  subu  $8,$4,$2
  nop   # need
  nop   # need
  nop   # need
  xor   $9,$5,$2
  nop   # need
  nop   # need
  nop   # need
  xori  $10,$1,0xf33f
  nop   # need
  nop   # need
  nop   # need
  ori   $14,$0,4 
  nop   # need
  nop   # need
  nop   # need
  sllv  $11,$14,$1
  nop   # need
  nop   # need
  nop   # need
  ori   $14,$0,5
  nop   # need
  nop   # need
  srlv  $12,$14,$1
  nop   # need
  nop   # need
  nop   # need
  nor   $13,$1,$2
  nop   # need
  nop   # need
  nop   # need
# Store them to verify the results
  sw    $13,0($22)
  nop   # need
  nop   # need
  nop   # need
  sw    $3,0($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $4,4($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $5,8($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $6,12($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $7,16($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $8,20($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $9,24($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $10,28($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $11,32($21)
  nop   # need
  nop   # need
  nop   # need
  sw    $12,36($21)
  nop   # need
  nop   # need
  nop   # need
  halt  # that's all
