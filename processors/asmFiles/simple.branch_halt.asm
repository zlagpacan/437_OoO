org 0x0000

ori $2, $zero, 2
ori $1, $zero, 1
beq $1, $0, after_halt
halt
sw $1, 0x0104($0)
sw $2, 0x0100($0)

after_halt:
sw $1, 0x0100($0)
sw $2, 0x0104($0)
halt
