#---------------------------------------
# Lab 2 Program 2: Multiply Procedure
#---------------------------------------

# set the address for code segment
org 0x0000

# main procedure
    # run multiple mult's on stack of unsigned int's
main:

    # setup stack:
    ori $sp, $0, 0xfffc     # initialize stack pointer
    ori $s1, $0, 0x1        # 1 operand left means have full product

    # version 1
    ori $s0, $0, 0x4        # set number of operands
    ori $t0, $0, 0x7        # imm load operand1 value
    ori $t1, $0, 0x102      # imm load operand2 value
    ori $t2, $0, 0xe        # imm load operand3 value
    ori $t3, $0, 0x3        # imm load operand4 value
    
    push $t0                # store operand1 in stack
    push $t1                # store operand2 in stack
    push $t2                # store operand3 in stack
    push $t3                # store operand4 in stack
    # expected 0x0001284C

    # # version 2
    # ori $s0, $0, 0x5        # set number of operands
    # ori $t0, $0, 0x41       # imm load operand1 value
    # ori $t1, $0, 0xb2       # imm load operand2 value
    # ori $t2, $0, 0xa3       # imm load operand3 value
    # ori $t3, $0, 0x8f       # imm load operand4 value
    # ori $t4, $0, 0x9        # imm load operand5 value
    
    # push $t0                # store operand1 in stack
    # push $t1                # store operand2 in stack
    # push $t2                # store operand3 in stack
    # push $t3                # store operand4 in stack
    # push $t4                # store operand5 in stack
    # # expect 0x90AB9DDA

    # # version 3
    # ori $s0, $0, 0x3        # set number of operands
    # ori $t0, $0, 0x2        # imm load operand1 value
    # ori $t1, $0, 0x4        # imm load operand2 value
    # ori $t2, $0, 0x3        # imm load operand3 value

    # push $t0                # store operand1 in stack
    # push $t1                # store operand2 in stack
    # push $t2                # store operand3 in stack
    # # expect 0x00000018

    # loop through subproducts
    product_loop: 
        jal mult                    # call mult
        subu $s0, $s0, $s1          # decrement operands remaining
        bne $s0, $s1, product_loop  # check for 1 operand remaining


    # result already stored in stack

    halt                    # done asm program

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
        jr $ra          # return from mult function
