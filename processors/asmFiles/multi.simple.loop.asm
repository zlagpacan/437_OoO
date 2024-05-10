org 0x0000

ori $s0, $zero, 0x0200
lw $t0, 0x1000($zero)

loop_p0:
    addi $t0, $t0, 1
    addi $s0, $s0, -1
    bne $s0, $zero, loop_p0

sw $t0, 0x1004($zero)
halt

org 0x0200

ori $s0, $zero, 0x0100
lw $t0, 0x2000($zero)

loop_p1:
    addi $t0, $t0, 1
    addi $s0, $s0, -1
    bne $s0, $zero, loop_p1

sw $t0, 0x2004($zero)
halt

org 0x1000
cfw 0x0123

org 0x2000
cfw 0x4567
