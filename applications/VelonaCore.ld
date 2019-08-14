
#include "memory_zones.h"

ENTRY(_start)

MEMORY
{
    ROM (rx)    : ORIGIN = ROM_START, LENGTH = ROM_SIZE
    RAM (rwx)   : ORIGIN = RAM_START, LENGTH = RAM_SIZE
}

SECTIONS
{
    .text :
    {
       *(.text*)
    } > ROM

    .data :
    {
        *(.rodata*)
        *(.data)
        *(.data*)
        __data_end__ = .;
    } > RAM

    .bss :
    {
        // Ensure that .bss is word-aligned, allowing for zero'ing
        // by stind instructions.
        __bss_start__ = .;
        *(.bss)
        *(.bss*)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    __bss_size = __bss_end__ - __bss_start__;

    /* Stack pointer */
    __stack_top = ORIGIN(RAM) + LENGTH(RAM);
    __stack_init = __stack_top - 4;
    __stack_limit = __stack_top - STACK_SIZE;

    /* Assert that stack will not grow into data */
    ASSERT(__stack_limit >= __bss_end__, "Stack pointer may grow into data segment")

}