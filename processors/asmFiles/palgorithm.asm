###########################################################################################################
# palgorithm.asm
#   synchronized dual-core program to generate 256 crc values starting from seed (producer, processor 0)
#       and calculate statistics based on the crc values (consumer, processor 1)

###########################################################################################################
# processor 0 instruction segment 
org 0x0000
main_p0:

    # # private stack init
    # ori $sp, $zero, a_stack_p0

    # shared stack pointer init
    ori $s7, $zero, a_shared_sp

    # shared stack size pointer init
    ori $s6, $zero, a_shared_stack_size

    # # done crc production flag pointer init
    # ori $s5, $zero, a_done_crc_production_flag

    # shared lock init
    ori $s4, $zero, a_lock

    # seed input init
    ori $s3, $zero, a_input_seed

    # array init
    ori $s2, $zero, a_array

    ######################################################
    # producer: generate 256 crc values from starting seed

    # loop control var to stop after 256 iterations
    ori $s0, $zero, 256

    # get input seed
    lw $a0, 0($s3)

    # loop through 256 values
    crc_production_loop:

        # decrement loop control var
        addi $s0, $s0, -1

        # get random number (from given subroutine_crc.asm)
        #------------------------------------------------------
        # $v0 = crc32($a0)
        crc32:
            lui $t1, 0x04C1
            ori $t1, $t1, 0x1DB7
            or $t2, $0, $0
            ori $t3, $0, 32

        l1:
            slt $t4, $t2, $t3
            beq $t4, $zero, l2

            ori $t5, $0, 31
            srlv $t4, $t5, $a0
            ori $t5, $0, 1
            sllv $a0, $t5, $a0
            beq $t4, $0, l3
            xor $a0, $a0, $t1
        l3:
            addiu $t2, $t2, 1
            j l1
        l2:
            or $v0, $a0, $0
            # jr $ra
        #------------------------------------------------------

        # store generated crc val in array
        sw $v0, 0($s2)      # store crc val in next array slot
        addi $s2, $s2, 4    # increment array pointer for next iteration

        ############################################
        # atomic RMW segment --> access shared stack

        # get lock to access stack
        jal get_lock

        # push val to stack
        jal shared_push

        # # release stack access lock
        # jal release_lock
        sw $zero, 0($s4)   # store 0 to lock, signalling lock now released

        ############################################

        # make this generated crc val the seed to the next crc val
        or $a0, $zero, $v0

        # loop if loop control var not back to 0
        bne $s0, $zero, crc_production_loop

    ######################################################

    # # done producing, set done crc production flag
    # ori $t1, $zero, 1   # get 1
    # sw $t1, 0($s5)      # set flag --> store 1

    # ori $t5, $zero, 100
    # flush_wait:
    #     addi $t5, $t5, -1
    #     bne $t5, $zero, flush_wait

    # done production part of program
    halt

###########################################################################################################
# processor 1 instruction segment
org 0x0200
main_p1:

    # # private stack init
    # ori $sp, $zero, a_stack_p0

    # shared stack pointer init
    ori $s7, $zero, a_shared_sp

    # shared stack size pointer init
    ori $s6, $zero, a_shared_stack_size

    # # done crc production flag pointer init
    # ori $s5, $zero, a_done_crc_production_flag

    # shared lock init
    ori $s4, $zero, a_lock

    # statistics mem store init
    ori $s3, $zero, a_stats

    # max init
    ori $s0, $zero, 0x0     # start at 16-bit min

    # min init 
    ori $s1, $zero, 0xffff  # start at 16-bit max

    # accumulation init
    ori $s2, $zero, 0x0     # start at 0

    # loop control var
    ori $s5, $zero, 256     # do 256 iterations

    # test array
    ori $t7, $zero, 0x3000

    ####################################################
    # consumer: calculate statistics based on crc values

    # infinitely loop as long as done crc production flag not set
    crc_consumption_loop:

        recheck_stack:

        # check for shared stack empty ($s6)
        lw $t0, 0($s6)
        beq $t0, $zero, recheck_stack   # if shared stack empty, keep waiting until not empty

        ############################################
        # atomic RMW segment --> access shared stack

        # get lock
        jal get_lock

        # pop val from stack
        jal shared_pop

        # # release lock
        # jal release_lock
        sw $zero, 0($s4)   # store 0 to lock, signalling lock now released

        ############################################

        # do consumption:

        # only use lower 16 bits
        sw $v0, 0($t7)
        addi $t7, $t7, 4
        andi $v0, $v0, 0xffff

        # update max (inspired by subroutine_mm.asm)
        update_max:
            sltu $t0, $s0, $v0          # check old max less than this val
            beq $t0, $zero, update_min  # if old max not less than this val, continue
            or $s0, $zero, $v0          # update max to this val

        # update min (inspired by subroutine_mm.asm)
        update_min:
            sltu $t0, $v0, $s1              # check this val less than old min
            beq $t0, $zero, update_accum    # if this val not less than old min, continue
            or $s1, $zero, $v0              # update min to this val

        # update accumulation
        update_accum:
            addu $s2, $s2, $v0  # accumulate old accum by this val

        # determine if should loop again:

        # decrement loop control var
        addi $s5, $s5, -1

        # check if should loop again
        bne $s5, $zero, crc_consumption_loop

    # done consuming, generate and output final statistics
    done_consumption:

    # get final average (accum / 256 = accum / 2^8 = accum >> 8)
    ori $t8, $zero, 8       # get 8
    srlv $s2, $t8, $s2      # accum >> 8

    # store max, min, and average
    sw $s0, 0($s3)  # MAX
    sw $s1, 4($s3)  # MIN
    sw $s2, 8($s3)  # AVG

    # done consumption part of program
    halt

###########################################################################################################
# shared instruction segment
org 0x0400

######################
# get_lock function: #
######################
    # works as repeated compare and set
    # used by P0 and P1

# parameters:
#       $s4 = lock address
# returns:
#       none
get_lock:
    # load lock:
    ll $t0, 0($s4)              # load in lock
    bne $t0, $zero, get_lock    # retry load if lock is held ($t0 = lock val != 0)

    # store lock:
    ori $t1, $zero, 1           # 1 val for setting lock
    sc $t1, 0($s4)              # attempt store to lock
    beq $t1, $zero, get_lock    # retry loading lock if got invalidated

    # got lock, return
    jr $ra

##########################
# release_lock function: #
##########################
    # simple store
    # used by P0 and P1
    # probably more efficient to just inline

# parameters:
#       $s4 = lock address
# returns:
#       none
release_lock:
    sw $zero, 0($s4)   # store 0 to lock, signalling lock now released

    # released lock, return
    jr $ra

#########################
# shared push function: #
#########################
    # decrement, store
    # increment stack size

# parameters:
#       $s7 = pointer to shared stack pointer
#       $s6 = pointer to shared stack size
#       $v0 = store val
# returns:
#       none
shared_push:

    # decrement
    lw $t0, 0($s7)      # load shared stack pointer
    addi $t0, $t0, -4   # decrement shared stack pointer by 4
    sw $t0, 0($s7)      # store shared stack pointer

    # store
    sw $a0, 0($t0)      # store shared stack val with no offset

    # increment stack size
    lw $t1, 0($s6)      # load shared stack size
    addi $t1, $t1, 1    # increment shared stack size by 1
    sw $t1, 0($s6)      # store shared stack size

    # return
    jr $ra    

########################
# shared pop function: #
########################
    # load, zero out, increment
    # decrement stack size

# parameters:
#       $s7 = pointer to shared stack pointer
#       $s6 = pointer to shared stack size
# returns:
#       $v0 = load val
shared_pop:

    # load
    lw $t0, 0($s7)      # load shared stack pointer
    lw $v0, 0($t0)      # load shared stack val with no offset (return)

    # zero out
    sw $zero, 0($t0)    # zero out shared stack val with no offset

    # increment
    addi $t0, $t0, 4    # increment shared stack pointer by 4
    sw $t0, 0($s7)      # store shared stack pointer

    # decrement stack size
    lw $t1, 0($s6)      # load shared stack size
    addi $t1, $t1, -1   # decrement shared stack size by 1
    sw $t1, 0($s6)      # store shared stack size

    # return
    jr $ra

###########################################################################################################
# input seed to start crc generation
org 0x0600
a_input_seed:

    ###############
    # INPUT SEED: #
    cfw 0xABCD
    ###############

###########################################################################################################
# lock to access shared stack of random numbers
org 0x0610
a_lock:
    cfw 0x0     # 0 = unlocked by default

###########################################################################################################
# shared stack size (flag to consumer to consume)
org 0x0620
a_shared_stack_size:
    cfw 0x0     # 0 = shared stack empty by default

###########################################################################################################
# flag to say done producing crc
org 0x0630
a_done_crc_production_flag:
    cfw 0x0     # 0 = not done producting crc by default

###########################################################################################################
# shared stack pointer
org 0x0800
a_shared_sp:
    cfw 0x1000

###########################################################################################################
# shared stack of random numbers
org 0x1000
a_shared_stack:
    cfw 0x0

###########################################################################################################
# array of random numbers
org 0x2000
a_array:
    cfw 0x0

##########################################################################################################
# test array of random numbers
org 0x3000
# a_array:
    cfw 0x0

###########################################################################################################
# statistics
org 0x4000
a_stats:
    cfw 0x0     # max
    cfw 0x0     # min
    cfw 0x0     # average

# ###########################################################################################################
# # processor 0 private stack
# org 0x3ffc
# a_stack_p0:
#     cfw 0x0

# ###########################################################################################################
# # processor 1 private stack
# org 0x7ffc
# a_stack_p1:
#     cfw 0x0
