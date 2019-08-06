library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity IMM is
    port (
        instr : in std_logic_vector(INSTR_WIDTH - 1 downto 0);
        ctrl : in IMM_op;
        imm : out signed(REG_WIDTH-1 downto 0)
    );
end IMM;

architecture Behavioral of IMM is

begin
    with ctrl select
        imm <=  (others => '0') when nop,
                resize(signed(instr(7 downto 0)), imm'length) when loadi,
                resize(signed(instr(7 downto 0)), imm'length) sll 1 when shl1,
                resize(signed(instr(7 downto 0)), imm'length) sll 2 when shl2,
                resize(signed(instr(7 downto 0)), imm'length) sll 8 when loadhi,
                resize(signed(instr(7 downto 0)), imm'length) sll 16 when loadh2i,
                resize(signed(instr(7 downto 0)), imm'length) sll 24 when loadh3i,
                resize(signed(instr(11 downto 0)), imm'length) sll 1 when branch,
                to_signed(2, imm'length) when jal;

end Behavioral;
