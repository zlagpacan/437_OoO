org 0x0000

# do multiple data-dependent sw's before halt
ori $2, $zero, 0x0200
ori $s0, $zero, 0xa1a1
sw $s0, 0($2)
ori $s1, $zero, 0xb2b2
sw $s1, 4($2)
ori $s2, $zero, 0xc3c3
sw $s2, 8($2)
halt
