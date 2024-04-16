org 0x0000

ori $2, $zero, 0x0400

lw $3, 0($2)
lw $4, 4($2)
andi $3, $3, 0x00ff
sw $3, 8($2)
halt

org 0x0400
cfw 0xa0a0
cfw 0xb1b1
cfw 0xdead
