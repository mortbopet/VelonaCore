#!/usr/bin/env bash
###
# This script will build a C source file using the Leros toolchain,
# link it with the leros.ld linker script (outputting the .text
# at address 0x0), and convert it to a text file suitable for loading
# into a ROM, and place it in the source files folder
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