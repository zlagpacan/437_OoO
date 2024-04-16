org 0x0000

ori $1, $0, 0x0001

branch_start:
addi $1, $1, 0x0001
ori $3, $0, 0x0100
bne $3, $1, branch_start
sw $3, 0($3)
halt
