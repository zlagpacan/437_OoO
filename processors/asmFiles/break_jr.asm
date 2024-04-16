org 0x0000
bne $5, $zero, end
ori $5, $zero, 0xabcd
ori $20, $zero, 0xf000
lui $20, 0x0000
jr $20

end:
sw $20, 8($20)
halt

org 0xf000
cfw 0x76543210
cfw 0x89abcdef
