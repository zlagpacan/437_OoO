print(f"org 0x4000")
for i in range(0x800):
    print(f"cfw 0x{i:08X}")

print()

print(f"org 0x8000")
for i in range(0x800):
    print(f"cfw 0x{i:08X}")