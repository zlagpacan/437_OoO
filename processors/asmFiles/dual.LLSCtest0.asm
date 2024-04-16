# core 0 instruction segment
org 0x0000
core0:
    ori $2, $zero, 0x1460

    # sw-ll-modify-sc


    halt

# core 1 instruction segment
org 0x0200
core1:
    ori $2, $zero, 0x1460

    # 

    halt

# data segment
org 0x1460
data:
    cfw 0xdead
    cfw 0xdead
    cfw 0xdead
    cfw 0xdead
