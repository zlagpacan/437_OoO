org 0x0000

lw $2, 0x0100($0)
sw $2, 0x0104($0)
halt

org 0x0100
cfw 0xabcd
