org 0x0000

ori $2, $zero, 0x0400   # incorrect address
ori $3, $zero, 0x0400

# jump then jump then jump
j0:
j j2
halt

j1:
ori $2, $zero, 0x0100   # incorrect address
ori $2, $zero, 0x0200   # correct address
sw $2, 0($2)
j jal0

j2:
j j3
halt

j3:
j j1
halt

jal0:
jal jal1
jal jal2
jal jal3
halt

jal1:
jr $ra
ori $2, $zero, 0x0200   # incorrect address

jal2:
ori $2, $zero, 0x0204   # correct address
jr $ra
ori $2, $zero, 0x0208   # incorrect address

jal3:
sw $2, 0($2)    # should do
jr $ra
sw $2, 4($2)    # shouldn't do
