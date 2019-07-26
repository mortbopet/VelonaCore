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
                resize(signed(instr(7 downto 0)) sll 8, imm'length) when loadhi,
                resize(signed(instr(7 downto 0)) sll 16, imm'length) when loadh2i,
                resize(signed(instr(7 downto 0)) sll 24, imm'length) when loadh3i,
                resize(signed(instr(11 downto 0)), imm'length) when branch,
                to_signed(2, imm'length) when jal;

end Behavioral;
