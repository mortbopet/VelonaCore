.text
.globl _start

/* Entry point */
_start:

/* Constant register initialization */
init_constants:
    loadi      0x0
    store      r100

    loadi      0x1
    store      r101

    loadi      0x80
    loadhi     0x0
    store      r102

    loadi      0x0
    loadhi     0x80
    loadh2i    0x0
    store      r103

    loadi      0x0
    loadh3i    0x80
    store      r104

    loadi      0xFF
    loadhi     0x0
    store      r105

    loadhi     0xFF
    loadh2i    0x0
    store      r106

    loadi      0x0
    loadh2i    0xFF
    store      r107

    loadi      0xFF
    loadh3i    0x7F
    store      r108

/* Runtime function pointer initialization */
init_funct_ptrs:
    loadi      __ashlsi3
    loadhi     __ashlsi3
    loadh2i    __ashlsi3
    loadh3i    __ashlsi3
    store      r120

    loadi      __ashrsi3
    loadhi     __ashrsi3
    loadh2i    __ashrsi3
    loadh3i    __ashrsi3
    store      r121

    loadi      __lshrsi3
    loadhi     __lshrsi3
    loadh2i    __lshrsi3
    loadh3i    __lshrsi3
    store      r122

/* Initialize .bss */
init_bss:
    loadi      __bss_size
    loadhi     __bss_size
    loadh2i    __bss_size
    loadh3i    __bss_size
    brz        init_stack_ptr
    store r1

    loadi      __bss_start__
    loadhi     __bss_start__
    loadh2i    __bss_start__
    loadh3i    __bss_start__
    store      r2

zero:
    ldaddr  r2
    loadi   0
    stind   0
    load    r2
    addi    4
    store   r2
    load    r1
    subi    1
    store   r1
    brnz    zero


/* Stack pointer initialization */
init_stack_ptr:
    loadi       __stack_init
    loadhi      __stack_init
    loadh2i     __stack_init
    loadh3i     __stack_init
    store      r1

    // Jump to main
    loadi      main
    loadhi     main
    loadh2i    main
    loadh3i    main
    jal        r0

    // Loop once returned from main
    br         0