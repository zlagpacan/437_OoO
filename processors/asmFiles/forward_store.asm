org 0x0000

ori $2, $zero, 0x0400
ori $3, $zero, 0xabcd
sw $3, 0($2)

ori $4, $zero, 0x0600
ori $5, $zero, 0xef01
sw $5, 8($4)
halt

org 0x0400
cfw 0xdead

org 0x0600
cfw 0xdead
