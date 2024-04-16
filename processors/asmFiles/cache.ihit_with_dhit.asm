org 0x0000

# need loop that refers to same data
ori $2, $zero, 0x0200 
ori $4, $zero, 0x4

loop:
addi $4, $4, -1         
sw $4, 0($2)        # store same $4 at same $2 address
bne $4, $zero, loop
halt
