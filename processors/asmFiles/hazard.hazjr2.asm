org 0x0000

ori $1, $zero, 0x0200

pt1: # passes
lw $2, 0($1)
jr $2
halt

pt2: # passes
ori $3, $zero, 0x00c0
jr $3

org 0x0080
sw $2, 16($1)
jal pt2

org 0x00c0
sw $3, 20($1)

pt3: # passes
lw $4, 4($1)
ori $4, $4, 0x0040
jr $4

org 0x0100
halt

org 0x0140
sw $4, 24($1)
halt

org 0x0200
cfw 0x0080
cfw 0x0100
