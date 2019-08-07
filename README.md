# VelonaCore
A single-cycle VHDL implementation of the 32-bit Leros instruction set.


## Building & Running a Program
**Note**: The build system has been tested on a Ubuntu 18.04 machine.

1. Build the Leros toolchain (https://github.com/leros-dev/leros-llvm) by executing the bundled `build.sh` script. The build script will check out the`leros-lib` repository, where the VelonaCore board header files are placed.
2. Build your program using the [BuildApp.py](https://github.com/mortbopet/Leros32-Core/blob/master/applications/BuildApp.py) script. Example usage:
```sh
cd VelonaCore/applications
python3 BuildApp.py trianglenumber --sp 0x3FC
```
This will output a .txt file in the `VelonaCore.srcs/sources_1/rom-init` folder. This file contains a binary version of the program which you've just compiled, and will be used to initialize a ROM in the design with the program.

4. Ensure that the `rom_init_file` generic of the `MemorySystem` in [VelonaCore_top.vhd](VelonaCore.srcs/sources_1/new/VelonaCore_top.vhd) points to the program which you've just compiled, ie:
```VHDL
...
MemorySystem : entity work.VelonaB3Mem
    generic  map (
        rom_init_file => "../rom_init/trianglenumber.txt"
    )
...
```
5. It might also be a good idea to check whether your program fits into the currently configured ROM size. The build script has placed a `.bin` file in the directory where your source program was present. This flat binary file may be inspected for its size, and compared to the ROM size. The ROM size may be configured as the `rom_address_width` constant in the [VelonaCore_basys3mem.vhd](VelonaCore.srcs/sources_1/new/VelonaCore_basys3mem.vhd) file.
6. Synthesize you're design and test it out!

## Adding Programs
Source files for a given program should be placed in a subdirectory within the `VelonaCore/applications/` folder.
The name of this subdirectory will be the `target` used in either the `BuildApp.py` script or as a parameter to the Makefile.  
Example:
```sh
cd VelonaCore/applications
mkdir foo
touch foo/main.c
# write a program in foo/main.c
python3 BuildApp.py foo
```

### Limitations
Currently, program- and data memory are separated into two different memories.
As such, if the compiler places a variable in the .data segment of the elf,
the program will not be able to execute (given that an attempt will be made
to read from program memory through the RAM).
To avoid this, ensure that all variables are placed on the stack (ie. declared
inside a function, no global variables).

To verify that no .data sections has been emitted, one may use
`readelf -S ${program}` and ensure that no DATA segments are present.
