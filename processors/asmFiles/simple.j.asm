org 0x0000

ori $3, $0, 0x0001
j after

addi $3, $3, 1

after:
sw $3, 0x0100($2)
halt
