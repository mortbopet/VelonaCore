library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Common.all;

entity ALU is
    generic(
        width: integer
    );
    port (
        ctrl:   in ALU_op;
        op1:    in signed(width-1 downto 0);
        op2:    in signed(width-1 downto 0);
        res:    out signed(width-1 downto 0)
    );
end ALU;

architecture Behavioral of ALU is

begin

    with ctrl select
        res <=  (others => '0') when nop,
                op1 + op2 when add,
                op1 - op2 when sub,
                op1(op1'left) & op1(op1'left downto 1) when shra, -- sra 1
                op1 and op2 when alu_and,
                op1 or op2 when alu_or,
                op1 xor op2 when alu_xor,
                op2 when loadi,
                op2(31 downto 8) & op1(7 downto 0) when loadhi,
                op2(31 downto 16) & op1(15 downto 0) when loadh2i,
                op2(31 downto 24) & op1(23 downto 0) when loadh3i;

end Behavioral;
