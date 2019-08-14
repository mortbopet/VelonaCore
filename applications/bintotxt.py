from array import array
import sys
import binascii
import os

"""
Script for converting a flat, Little endian binary file into a text
file containing 0's and 1's, more easily read by VHDL.

Example file format:

file.txt with (bytesPerLine = 4):

00100001111111000010100100001011
00101010000000000010101100000000
00110000000000010010000100000000
...
"""

def doBinToTxt(in_fn, out_fn, bytesPerLine = 4):
    out = ""

    # Read little endian binary file and convert to lines of text
    with open(in_fn, 'rb') as f:
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
    with open(out_fn, 'w') as fo:
        fo.write(out)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print('usage: python bintotxt.py $binfile $outfile')
        quit()

    doBinToTxt(sys.argv[1], sys.argv[2])
