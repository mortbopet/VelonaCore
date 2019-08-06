# VelonaCore
A single-cycle VHDL implementation of the 32-bit Leros instruction set.


## Building & Running a Program
Although convoluted, a development process *does* exist for getting a C program compiled and executing on the core:

1. Build the Leros toolchain (https://github.com/leros-dev/leros-llvm)
2. Build your program using the [buildTestProgram.sh](https://github.com/mortbopet/Leros32-Core/blob/master/testprograms/buildTestProgram.sh) script. Example usage:
```
./buildTestProgram.sh ~/work/build-leros-llvm/bin/ blink.c
```
This will output a .txt file in the sources folder within the project. This is a text file containing the binary program data, which will be used to initialize a ROM in the design.
3. Modify the stack pointer. As explained in the buildTestProgram.sh script:
```
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
```
The build script will output the following files:
ELF (${yourprogram}.out), Flat binary ((${yourprogram}.bin), Disassembled executable (${yourprogram}.dis) and Text version of the flat binary file ((${yourprogram}.txt, inside the vhdl sources folder). These files may be inspected using the tools available from the Leros toolchain (readelf, llvm-objdump, llvm-objcopy) to aid in development/debugging.

4. Ensure that the `rom_init_file` generic of the `MemorySystem`in [https://github.com/mortbopet/VelonaCore/blob/master/leros-core.srcs/sources_1/new/Leros_top.vhd](Leros_top.vhd) points to the program which you've just compiled.
5. It might also be a good idea to check whether your program fits into the currently configured ROM size. The build script has placed a `.bin` file in the directory where your source program was present. This flat binary file may be inspected for its size, and compared to the ROM size. The ROM size may be configured as the `rom_address_width` constant in the [https://github.com/mortbopet/VelonaCore/blob/master/leros-core.srcs/sources_1/new/leros_basys3mem.vhd](leros_basys3mem.vhd) file.
6. Synthesize you're design and test it out!
