org 0x0000

# need familiar instr's during mem stage sw to block that has been kicked out
ori $2, $zero, 0x0200 
ori $4, $zero, 0x64

loop:
addi $4, $4, -1
addi $2, $2, 8      # new block at 8         
sw $4, 0($2)        # store same $4 at same $2 address
bne $4, $zero, loop
halt
