#------------------------------------------
# Originally Test and Set example by Eric Villasenor
# Modified to be LL and SC example by Yue Du
#------------------------------------------

#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
  org   0x0000              # first processor p0
  ori   $sp, $zero, 0x3ffc  # stack
  jal   mainp0              # go to program
  halt

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
  ll    $t0, 0($a0)         # load lock location
  bne   $t0, $0, aquire     # wait on lock to be open
  addiu $t0, $t0, 1
  sc    $t0, 0($a0)
  beq   $t0, $0, lock       # if sc failed retry
  jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
  sw    $0, 0($a0)
  jr    $ra

# main function does something ugly but demonstrates beautifully
mainp0:
  push  $ra                 # save return address
  ori   $a0, $zero, l1      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # critical code segment
  ori   $t2, $zero, res
  lw    $t0, 0($t2)
  addiu $t1, $t0, 2
  sw    $t1, 0($t2)
  # critical code segment
  ori   $a0, $zero, l1      # move lock to arguement register
  jal   unlock              # release the lock
  pop   $ra                 # get return address
  jr    $ra                 # return to caller
l1:
  cfw 0x0


#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
  org   0x200               # second processor p1
  ori   $sp, $zero, 0x7ffc  # stack
  jal   mainp1              # go to program
  halt

# main function does something ugly but demonstrates beautifully
mainp1:
  push  $ra                 # save return address
  ori   $a0, $zero, l1      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # critical code segment
  ori   $t2, $zero, res
  lw    $t0, 0($t2)
  addiu $t1, $t0, 1
  sw    $t1, 0($t2)
  # critical code segment
  ori   $a0, $zero, l1      # move lock to arguement register
  jal   unlock              # release the lock
  pop   $ra                 # get return address
  jr    $ra                 # return to caller

res:
  cfw 0x0                   # end result should be 3
