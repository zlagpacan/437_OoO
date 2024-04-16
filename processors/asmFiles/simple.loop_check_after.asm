org 0x0000

ori $4, $0, 0x0010
addi $3, $3, 0x0000

before:
addi $4, $4, -1
bne $4, $0, before

after:
sw $3, 0x0100($0)
halt
