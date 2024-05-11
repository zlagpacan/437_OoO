org 0x0000

ori $s0, $zero, 0x0200
lw $t0, 0x1000($zero)
sw $t0, 0x1004($zero)

loop_p0:
    lw $t1, 0x1004($zero)
    addi $t2, $t1, 1
    sw $t2, 0x1004($zero)
    addi $s0, $s0, -1
    bne $s0, $zero, loop_p0

halt

org 0x0200

ori $s0, $zero, 0x0100
lw $t0, 0x2000($zero)
sw $t0, 0x2004($zero)

loop_p1:
    lw $t1, 0x2004($zero)
    addi $t2, $t1, 1
    sw $t2, 0x2004($zero)
    addi $s0, $s0, -1
    bne $s0, $zero, loop_p1

halt

org 0x1000
cfw 0x0123

org 0x2000
cfw 0x4567
