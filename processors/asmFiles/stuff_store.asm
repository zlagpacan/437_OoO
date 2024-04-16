org 0x0000
ori $1, $zero, 0xabcd
ori $2, $zero, 0x1234
ori $3, $zero, 0x5678
ori $4, $zero, 0x90ef

nop

add $5, $1, $2
sub $6, $3, $4
slt $7, $1, $2
sltu $8, $1, $2
xor $9, $5, $6
nop
nop
sw $9, 0($2)
halt
