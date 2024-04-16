org 0x0000

# Mem to 1st
ori $1, $zero, 0x0100
nop
nop
lw $2, 0($1)
or $3, $zero, $2
nop
nop
sw $3, 4($1)

# Mem to 2nd
lw $4, 0($1)
ori $5, $zero, 0xa0b0c0d0
sub $6, $1, $4
nop
nop
sw $6, 8($1)

halt

org 0x0100
cfw 0x1234567
