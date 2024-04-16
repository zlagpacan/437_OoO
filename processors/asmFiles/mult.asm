#---------------------------------------
# Lab 2 Program 1: Multiply Algorithm
#---------------------------------------

# set the address for code segment
org 0x0000

# setup stack for mult
ori $sp, $0, 0xfffc     # initialize stack pointer
ori $t0, $0, 0x21       # imm load operand1 value
ori $t1, $0, 0x4        # imm load operand2 value
push $t0                # store operand1 in stack
push $t1                # store operand2 in stack

# multiply algorithm
    # $4: operand1
    # $5: operand2
    # $6: 1
    # $2: product
mult: 

    pop $4              # get first mult operand
    pop $5              # get second mult operand
    ori $6, $0, 0x1     # will want to subu - 1
    or $2, $0, $0       # product = 0
    
    mult_loop:
        beq $5, $0, mult_end    # check operand2 == 0
        addu $2, $2, $4         # product += operand1
        subu $5, $5, $6         # operand2--
        j mult_loop             # loop
        
    mult_end:
        push $2         # store product
        # jr $ra          # return from mult function

# result already stored in stack

halt                # done asm program

# operand1:
#     cfw 0x21

# operand2:
#     cfw 0x4
