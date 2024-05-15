org 0x0000

ori $s0, $zero, value0
ori $s1, $zero, result0
lw $t0, 0($s0)
sw $t0, 0($s1)
halt

org 0x0200

ori $s0, $zero, value1
ori $s1, $zero, result1
lw $t0, 0($s0)
sw $t0, 0($s1)
halt

org 0x1000

value0:
cfw 0x0123
cfw 0x4567

value1:
cfw 0x89ab
cfw 0xcdef

result0:
cfw 0
cfw 0

result1:
cfw 0
cfw 0
