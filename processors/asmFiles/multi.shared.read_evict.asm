org 0x0000

lw $t0, 0x1000($zero)
lw $t1, 0x2000($zero)
add $t0, $t0, $t1
lw $t1, 0x2004($zero)
add $t0, $t0, $t1
lw $t1, 0x2100($zero)
add $t0, $t0, $t1
lw $t1, 0x2104($zero)
add $t0, $t0, $t1
sw $t1, 0x2200($zero)
sw $t0, 0x2204($zero)
halt

org 0x0200

lw $t0, 0x1000($zero)
lw $t1, 0x3000($zero)
add $t0, $t0, $t1
lw $t1, 0x3004($zero)
add $t0, $t0, $t1
lw $t1, 0x3100($zero)
add $t0, $t0, $t1
lw $t1, 0x3104($zero)
add $t0, $t0, $t1
sw $t1, 0x3200($zero)
sw $t0, 0x3204($zero)
halt

org 0x1000
cfw 0x0001

org 0x2000
cfw 0x0002
cfw 0x0002

org 0x2100
cfw 0x0002
cfw 0x0002

org 0x2200
# writes

org 0x3000
cfw 0x0003
cfw 0x0003

org 0x3100
cfw 0x0003
cfw 0x0003

org 0x3200
# writes
