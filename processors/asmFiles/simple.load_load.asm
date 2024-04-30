org 0x0000

ori $s0, $zero, 0x0400

lw $t0, 0($s0)
lw $t1, 4($s0)

or $t2, $t0, $t1
and $t3, $t0, $t1

sw $t2, 8($s0)
sw $t3, 12($s0)

halt

org 0x0400
cfw 0x01234567
cfw 0x89abcdef
