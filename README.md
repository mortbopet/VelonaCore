# VelonaCore
A single-cycle VHDL implementation of the 32-bit Leros instruction set.

**Supported boards**:
- Basys3: Memory map detailed in [memorymap.md](memorymap.md)

## Compiling & Executing a Program

### Prerequisites
The build scripts within the `applications` folder assumes a specific layout of the Leros-related repositories.
Therefore, when checking out this repository, it should be placed next to the other Leros repositories, such as:

```
.
├── leros-llvm
│   └─── runtime
├── leros-lib
│   └─── runtime
├── build-leros-llvm
|   ├─── bin
│   └─── ...
└── VelonaCore
```
A Leros toolchain must be available to build programs for VelonaCore.  
Build the Leros toolchain (https://github.com/leros-dev/leros-llvm) by executing the bundled `build.sh` script. The `leros-lib` repository (required for building applications for VelonaCore) will be checked out during building, and will be placed as seen above.

### Compiling a Program

Build your program using the [BuildApp.py](applications/BuildApp.py) script. Example usage:
```sh
cd VelonaCore/applications
python3 BuildApp.py sevensegment
```
This will output two text files in the `VelonaCore.srcs/sources_1/rom-init` folder:
- **app.text**: The `.text` segment of the just compiled application
- **app.data**: The `.data` segment of the just compiled application
 
These file contains a textual binary version of the program which you've just compiled, and will be used to initialize the instruction- and data memories within the core.

For now, the only precaution is to ensure that the [memory_zones.h](applications/memory_zones.h) header file contains the correct memory sizes as the design is being built with.  
Memory sizes are specified in the [VelonaCore_basys3mem.vhd](VelonaCore.srcs/sources_1/basys3mem/VelonaCore_basys3mem.vhd) file.


### Executing
The VelonaCore will, once out of reset, start executing from address `0x0`. Given successfull synthesis of the VelonaCore as well as the program, once the bitstream is written to the FPGA, the program should start executing.

**Note**: The build system has been tested on a Ubuntu 18.04 machine.

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

# Todo:
## Build system

- Include `.rodata` section into RAM initialization file (this involves linker script work + BuildApp.py modifications). `.rodata` may be placed after the `.data` section, possibly exchanging place with the `.bss` section.
- Remove `.bss` from the generated `app.data` file. the `.bss` section is per definition empty, and we need only to know the size and position of the section to zero it.

## Hardware

- Add support for the remainder of IO on the Basys3 board. Initial support should only include memory mapping of peripheral pins.
  - Pushbuttons (should be debounced)
  - PMOD connectors
  - VGA
  - RS232 uart  
- Start thinking about interrupts

