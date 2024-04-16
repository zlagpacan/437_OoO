org 0x0000

# tricky jr's

# lw-jr
ori $2, $zero, 0x8000
lw $t0, 0($2)
jr $t0
halt

# regwr-jr
org 0x0100
ori $t1, $zero, 0x0200
jr $t1
halt

org 0x0200
ori $t2, $zero, 0xabcd
sw $t2, 4($2)
halt

org 0x8000
cfw 0x0100
