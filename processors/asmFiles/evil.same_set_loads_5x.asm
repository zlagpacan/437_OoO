org 0x0000

ori $s0, $zero, 0x1000

lw $t0, 0x00($s0)
lw $t1, 0x40($s0)
lw $t2, 0x80($s0)
lw $t3, 0xC0($s0)
lw $t4, 0x100($s0)

addi $t0, $t0, 1
addi $t1, $t1, 2
addi $t2, $t2, 3
addi $t3, $t3, 4
addi $t4, $t4, 5

sw $t4, 0x00($s0)
sw $t3, 0x40($s0)
sw $t2, 0x80($s0)
sw $t1, 0xC0($s0)
sw $t0, 0x100($s0)

halt

org 0x1000
cfw 0x1000

org 0x1040
cfw 0x1040

org 0x1080
cfw 0x1080

org 0x10C0
cfw 0x10C0
