org 0x0000

ori $4, $0, 0x0010
addi $3, $3, 0x0000

before:
beq $4, $0, after
addi $4, $4, -1
j before

after:
sw $3, 0x0100($0)
halt
