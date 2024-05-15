##########
# core0: #
##########
org 0x0000

# reg init
ori $s0, $zero, flag
ori $s1, $zero, 1
ori $s2, $zero, value
ori $s3, $zero, 0x2222

# core0_delay_loop_0
    # want so can guarantee old vals in snoop_dcache1
ori $t0, $zero, 0x0100
core0_delay_loop_0:
    addi $t0, $t0, -1
    bne $t0, $zero, core0_delay_loop_0
    
# write value
sw $s3, 0($s2)

# write flag
sw $s1, 0($s0)

# core0_delay_loop_1
    # want so can guarantee new vals in snoop_dcache0
ori $t0, $zero, 0x0100
core0_delay_loop_1:
    addi $t0, $t0, -1
    bne $t0, $zero, core0_delay_loop_1

# done
halt

##########
# core1: #
########## 
org 0x0200

# reg init
ori $s0, $zero, flag
ori $s2, $zero, value
ori $s4, $zero, result

# flag wait loop
flag_wait_loop:
    lw $t0, 0($s0)

    # load value
    lw $t1, 0($s4)
    
    beq $t0, $zero, flag_wait_loop

# # load value
# lw $t1, 0($s2)

# store value at result
sw $t1, 0($s4)

# done
halt

#########
# data: #
#########

org 0x1004
flag:
cfw 0x0

org 0x2020
value:
cfw 0x1111

org 0x2048
result:
cfw 0xffff
