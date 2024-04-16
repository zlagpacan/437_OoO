
  #------------------------------------------------------------------
  # R-type Instruction (ALU) Test Program
  #------------------------------------------------------------------

  org 0x0000
  ori   $1,$zero,0xD269
  ori   $2,$zero,0x37F1

  ori   $21,$zero,0x80
  ori   $22,$zero,0xF0

# Now running all R type instructions
  or    $3,$1,$2
  and   $4,$1,$2
  andi  $5,$1,0xF
  addu  $6,$1,$2
  addiu $7,$3,0x8740
  subu  $8,$4,$2
  xor   $9,$5,$2
  xori  $10,$1,0xf33f
  ori   $14,$0,4 
  sllv  $11,$14,$1
  ori   $14,$0,5
  srlv  $12,$14,$1
  nor   $13,$1,$2
# Store them to verify the results
  sw    $13,0($22)
  sw    $3,0($21)
  sw    $4,4($21)
  sw    $5,8($21)
  sw    $6,12($21)
  sw    $7,16($21)
  sw    $8,20($21)
  sw    $9,24($21)
  sw    $10,28($21)
  sw    $11,32($21)
  sw    $12,36($21)
  halt  # that's all
