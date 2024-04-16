org 0x0000

ori $8, $zero, 0x0100

# EX to 1st
ori $1, $zero, 0xa1b2
ori $2, $zero, 0x1a2b
add $3, $2, $zero

# EX to 2nd
ori $1, $zero, 0xc3d4
ori $2, $zero, 0x3c4d
sub $4, $1, $zero

# store val
nop
nop
sw $3, 0($8)
sw $4, 4($8)

halt
