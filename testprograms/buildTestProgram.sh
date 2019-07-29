#!/usr/bin/env bash
###
# This script will build a C source file using the Leros toolchain,
# link it with the leros.ld linker script (outputting the .text
# at address 0x0), and convert it to a text file suitable for loading
# into a ROM, and place this text file in the source files folder.
#
# 29/07/2019
# NOTE: This will use the default crt0.leros.c file, which assigns the
# stack pointer to 0x7FFFFFF0 - nowhere close to the RAM of the memory
# system. A tempory fix is to modify the first two instructions (loading
# the instruction pointer value) in the output .txt file to a stack
# pointer that points to a sensible location within the RAM.
#
# As an example, the first two instructions may be modified to initialize
# the stack pointer to 0x3FC:
#
# loadi      0xF0             loadi     0xFC
# loadh3i    0x7F             loadhi    0x03
# 0010000111110000            0010000101111100
# 0010101101111111    --->    0010100100000011
#
# 0x3FC is at time of writing a suitable choice, given that the RAM is
# synthesized as being 2K, wherein 0x3FC = U1020, pointing to just below
# the 256 memory mapped registers (the upper 1K of the RAM).
# A caveat of this approach is that the modified stack pointer _must_
# be initialized with 2 instructions, as seen above, given that
# messing with the number of instructions in the program will equally
# mess with jump targets.
#
###


# $1 = Leros toolchain bin folder
# $2 = program to build

LINKER_SCRIPT="leros.ld"

ELFFILE=${2}.out
BINFILE=${2}.bin
DISFILE=${2}.dis
DEST=../leros-core.srcs/sources_1/new/

# Compile
$1/clang -target leros32 -Xlinker $LINKER_SCRIPT $2 -o $ELFFILE

# Extract binary
$1/llvm-objcopy -O binary $ELFFILE $BINFILE

# Convert binary to text
python bintotxt.py $BINFILE

# Write a disassembled file for debugging purposes
$1/llvm-objdump --disassemble $ELFFILE > $DISFILE

# Move to source folder
mv $2.txt $DEST

# Cleanup
# rm $BINFILE
# rm $ELFFILE