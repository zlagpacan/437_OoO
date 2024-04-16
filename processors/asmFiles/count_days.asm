#---------------------------------------
# Lab 2 Program 3: Calculate Days
#---------------------------------------

# set the address for code segment
org 0x0000

# main procedure
main:

    # initialize today's date
    ori $s0, $0, 11         # initialize CurrentDay
    ori $s1, $0, 1          # initialize CurrentMonth
    ori $s2, $0, 2023       # initialize CurrentYear

    # initialize coefficients
    ori $s3, $0, 30         
    ori $s4, $0, 365

    # do parentheses calculations
    addi $s2, $s2, -2000    # CurrentYear - 2000
    addi $s1, $s1, -1       # CurrentMonth - 1 

    # setup stack for first mult:
    ori $sp, $0, 0xfffc     # initialize stack pointer
    push $s4                # store operand1 in stack
    push $s2                # store operand2 in stack

    # retrieve val from first mult
    jal mult                # call mult
    pop $s2                 # load product from stack

    # setup stack for second mult:
    push $s3                # store operand1 in stack
    push $s1                # store operand2 in stack

    # retrieve val from second mult
    jal mult                # call mult
    pop $s1                 # load product from stack

    # do overall calculation
    add $2, $s0, $s1        # CurrentDay + 30 * (CurrentMonth - 1)
    add $2, $2, $s2         # CurrentDay + 30 * (CurrentMonth - 1) + 365 * (CurrentYear - 2000)

    # store result in stack
    push $2

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
