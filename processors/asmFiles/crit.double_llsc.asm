org 0x0000

ori $t1, $zero, 1
ll $t0, 0x1000($zero)
sc $t1, 0x1000($zero)
sw $t1, 0x1004($zero)
halt

org 0x0200

ori $t1, $zero, 1
ll $t0, 0x2000($zero)
sc $t1, 0x2000($zero)
sw $t1, 0x2004($zero)
halt
