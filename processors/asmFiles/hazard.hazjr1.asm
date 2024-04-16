org 0x0000

ori $1, $0, 0xf0
ori $31, $0, 0x24
nop
nop
nop
jal test1
sw $1, 0($1)
halt
test1:
    jr $31
halt
