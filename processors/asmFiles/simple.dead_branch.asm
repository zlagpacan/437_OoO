org 0x0000

ori $0, $5, 0x1024
ori $1, $7, 0x1024

bne $0, $1, after

sw $0, 0x0104($0)
sw $1, 0x0104($0)

after:
halt

org 0x0100
