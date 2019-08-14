#ifndef MEMORY_ZONES_H
#define MEMORY_ZONES_H

/*
 * We denote the memory zones as ROM and RAM - however, in the VelonaCore FPGA
 * system both of these memory segments are implemented with BRAM.
 * Furthermore, ROM is only accessible through instruction fetch reading, and
 * thus the two address spaces (instruction memory (ROM) and data memory (RAM))
 * are separate.
 */

/* Instruction memory */
#define ROM_START  0x0
#define ROM_SIZE   0x1000 /* 4 KiB */

/* Data memory */
#define RAM_START  0x20000000
#define RAM_SIZE   0x1000 /* 4 KiB */

/* Max stack size */
#define STACK_SIZE (RAM_SIZE / 4)

#endif /* MEMORY_ZONES_H */