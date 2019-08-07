# VelonaCore
A single-cycle VHDL implementation of the 32-bit Leros instruction set.


## Building & Running a Program
**Note**: The build system has been tested on a Ubuntu 18.04 machine.

1. Build the Leros toolchain (https://github.com/leros-dev/leros-llvm) by executing the bundled `build.sh` script. The build script will check out the`leros-lib` repository, where the VelonaCore board header files are placed.
2. Build your program using the [BuildApp.py](https://github.com/mortbopet/Leros32-Core/blob/master/applications/BuildApp.py) script. Example usage:
```
cd applications
python3 BuildApp.py trianglenumber --sp 0x3FC
```
This will output a .txt file in the [rom-init](https://github.com/mortbopet/VelonaCore/tree/master/VelonaCore.srcs/sources_1/rom_init) folder. This is a text file containing a binary version of the just compiled program, which will be used to initialize a ROM in the design.  

4. Ensure that the `rom_init_file` generic of the `MemorySystem` in [VelonaCore_top.vhd](VelonaCore.srcs/sources_1/new/VelonaCore_top.vhd) points to the program which you've just compiled.  
5. It might also be a good idea to check whether your program fits into the currently configured ROM size. The build script has placed a `.bin` file in the directory where your source program was present. This flat binary file may be inspected for its size, and compared to the ROM size. The ROM size may be configured as the `rom_address_width` constant in the [VelonaCore_basys3mem.vhd](VelonaCore.srcs/sources_1/new/VelonaCore_basys3mem.vhd) file.
6. Synthesize you're design and test it out!
