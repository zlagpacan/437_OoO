org 0x0000

lw $t0, 0x1000($zero)
addi $t0, $t0, 1
sw $t0, 0x2000($zero)
halt

org 0x0200

lw $t0, 0x1000($zero)
addi $t0, $t0, 2
sw $t0, 0x3000($zero)
halt

org 0x1000
cfw 0x0123
