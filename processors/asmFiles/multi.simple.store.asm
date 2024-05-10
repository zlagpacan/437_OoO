org 0x0000
ori $t0, $zero, 0x0123
sw $t0, 0x1000($zero)
halt

org 0x0200
ori $t0, $zero, 0x4567
sw $t0, 0x2000($zero)
halt
