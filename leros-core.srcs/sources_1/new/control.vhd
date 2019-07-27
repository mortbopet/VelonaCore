library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.Common.all;

entity Control is
    port (
        instr : LEROS_op;

        -- Control outputs
        alu_ctrl : out ALU_op;
        acc_ctrl : out MEM_op;
        dm_ctrl : out MEM_op;
        imm_ctrl : out IMM_op;
        alu_op1_ctrl : out ALU_OP1_op;
        alu_op2_ctrl : out ALU_OP2_op;
        br_ctrl : out BR_op;
        dm_access_size : out ACCESS_SIZE_op;
        dm_op : out MEM_op;
        reg_op : out MEM_op
    );
end Control;

architecture Behavioral of Control is

begin

    -- The following could be optimised for using less ROMs if
    -- all control signals are asserted in a single process.
    -- But the following is more readable and less code.

    -- ALU control
    with instr select
        alu_ctrl <= add when add | addi | br | brz | brnz | brp | brn | jal |
                             ldind | ldindb | ldindh | stind | stindb | stindh,
                    sub when sub | subi,
                    shra when shra,
                    alu_and when andr | andi,
                    alu_or when orr | ori,
                    alu_xor when xorr | xori,
                    loadi when loadi,
                    loadhi when loadhi,
                    loadh2i when loadh2i,
                    loadh3i when loadh3i,
                    nop when others;

    -- Accumulator control
    with instr select
        acc_ctrl <= wr when add | addi | sub | subi | shra | load | loadi |
                            andr | andi | orr | ori | xorr | xori | loadhi |
                            loadh2i | loadh3i | ldind | ldindb | ldindh,
                    nop when others;

    -- Data memory control
    with instr select
        dm_op <= rd when ldind | ldindb | ldindh,
                 wr when stind | stindb | stindh,
                 nop when others;

    with instr select
        dm_access_size <= byte when ldindb | stindb,
                          half when ldindh | stindh,
                          word when ldind | stind,
                          byte when others;

    -- Register control
    with instr select
        reg_op <= rd when add | sub | andr | orr | xorr | load,
                  wr when store | jal,
                  nop when others;

    -- Immediate control
    with instr select
        imm_ctrl <= loadi when addi | subi | andi | ori | xori | loadi,
                    loadhi when loadhi,
                    loadh2i when loadh2i,
                    loadh3i when loadh3i,
                    branch when br | brz | brp | brn | brnz,
                    jal when jal,
                    loadi when stindb | ldindb,
                    shl1 when stindh | ldindh,
                    shl2 when stind | ldind,
                    nop when others;

    -- ALU Operand selection
    with instr select
        alu_op1_ctrl <= pc when jal | br | brz | brnz | brp | brn,
                        addr when ldind | ldindh | ldindb | stind | stindh | stindb,
                        acc when others;

    with instr select
        alu_op2_ctrl <= imm when addi | subi | andi | xori | jal |
                           br | brz | brnz | brp | brn |
                           ldind | ldindh | ldindb | stind | stindh | stindb |
                           loadi | loadhi | loadh2i | loadh3i,
                        reg when others;

    -- Branch unit control
    with instr select
        br_ctrl <= br when br,
                   brz when brz,
                   brnz when brnz,
                   brp when brp,
                   brn when brn,
                   nop when others;
end Behavioral;
