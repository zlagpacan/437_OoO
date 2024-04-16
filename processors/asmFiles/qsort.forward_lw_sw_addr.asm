org 0x0000

# forward to lw addr
ori $2, $zero, 0x00fc
addi $2, $2, 4
lw $s0, 0($2)
addi $s0, $s0, 83
xori $s0, $s0, 0x1234
sw $s0, 0($2)

# forward to sw addr
ori $t0, $zero, 0xabcd
addi $2, $2, 4
sw $t0, 0($2)

# forward to lw addr then sw addr
addi $2, $2, 4
lw $s0, 0($2)
sw $s0, 4($2)
halt

org 0x0100
cfw 0x0123
cfw 0x4567
cfw 0x89ab
cfw 0xcdef
