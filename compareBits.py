control = open("bits.bin", 'rb')
test = open("output2.bin", 'rb')

diff = 0
total = 0

bites = control.read(1)
byte2 = test.read(1)


while bites != b"":
    bites = int.from_bytes(bites, "big")
    byte2 = int.from_bytes(byte2, "big")
    for i in range(0, 7):
        if ((bites & 1) is not (byte2 & 1)):
            diff += 1
        bites = bites >> 1
        byte2 >> 1
        total += 1

    # Do stuff with bites.
    bites = control.read(1)
    byte2 = test.read(1)

print(str(diff) + " out of " + str(total))