org 0x0000

ori $2, $zero, 0x0123
sw $2, 0x0100($0)
lw $2, 0x0100($0)
addi $2, $2, 2
sw $2, 0x0104($0)
halt
