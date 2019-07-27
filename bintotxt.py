from array import array
import sys
import binascii
import os

"""
Script for converting a flat, Little endian binary file into a text
file containing 0's and 1's, more easily read by VHDL.
"""


out = ""
bytesPerLine = 2

if len(sys.argv) != 2:
    print('usage: python bintotxt.py $binfile')
    quit()

# Read little endian binary file and convert to lines of text
with open(sys.argv[1], 'rb') as f:
    data = array('B', f.read())
    bytecnt = 0
    line = ""
    for byte in data:
        line = str(bin(byte)[2:].rjust(8, '0')) + line
        bytecnt += 1
        if bytecnt == bytesPerLine:
            bytecnt = 0
            line += '\n'
            out += line
            line = ""

# Write
filename = os.path.splitext(sys.argv[1])[0] + ".txt"
with open(filename, 'w') as fo:
    fo.write(out)

