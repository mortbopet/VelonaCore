library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity Branch is
    Port (
        acc : in signed(REG_WIDTH-1 downto 0);
        op : in BR_OP;
        do_branch : out std_logic
    );
end Branch;

architecture Behavioral of Branch is

begin

    branch_proc : process(acc, op)
    begin
        do_branch <= '0';

        if op = br then
            do_branch <= '1';
        elsif op = brp and acc >= 0 then
            do_branch <= '1';
        elsif op = brn and acc < 0 then
            do_branch <= '1';
        elsif op = brz and acc = 0 then
            do_branch <= '1';
        elsif op = brnz and acc /= 0 then
            do_branch <= '1';
        end if;
    end process;

end Behavioral;
