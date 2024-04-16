org 0x0000

ori $2, $zero, 0x0200
ori $3, $zero, 0x0300
ori $4, $zero, 0x0400

##################################

# read way0, word0, with index 000
lw $5, 0($2)
sw $5, 0($4)

# read way1, word1, with index 000
lw $5, 0($3)
sw $5, 4($4)

# read way1, word0, with index 000
lw $5, 0($3)
sw $5, 8($4)

# read way0, word1, with index 000
lw $5, 4($2)
sw $5, 12($4)

##################################

# read way1, word1, with index 110
lw $5, 52($3)
sw $5, 16($4)

# read way0, word1, with index 110
lw $5, 52($2)
sw $5, 20($4)

# read way0, word0, with index 110
lw $5, 48($3)
sw $5, 24($4)

# read way1, word0, with index 110
lw $5, 48($2)
sw $5, 28($4)

##################################

# double check still have index 000
lw $5, 4($2)
sw $5, 32($4)
lw $5, 0($3)
sw $5, 36($4)

# double check still have index 110
lw $5, 52($3)
sw $5, 40($4)
lw $5, 48($2)
sw $5, 44($4)
halt

##################################

# first set index 000
org 0x0200
cfw 0x00a1
cfw 0x00a2

# first set index 110
org 0x0230
cfw 0x00b1
cfw 0x00b2

# first set index 000
org 0x0300
cfw 0x00a3
cfw 0x00a4

# second set index 110
org 0x0330
cfw 0x00b3
cfw 0x00b4
