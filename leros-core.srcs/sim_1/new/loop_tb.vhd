library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity loop_tb is
end loop_tb;

use work.Common.all;

architecture Behavioral of loop_tb is

    signal clk : std_logic;
    constant clk_period : time := 1 ns;
    
    signal mem_tocore : LEROS_MEM_IN;
    signal mem_fromcore : LEROS_MEM_OUT;

begin
    
    mem_tocore.dm_data_in <= (others => '0');
    mem_tocore.dm_data_in_valid <= '0';
    mem_tocore.reg_data_in <= (others => '0');
    mem_tocore.im_data_in_valid <= '1';

    Core_ent :  entity work.Leros_core
    port map (
        mem_out => mem_fromcore,
        mem_in => mem_tocore,
        clk => clk,
        rst => '0'
    );

    Instr_mem : entity work.ROM
    generic map (
        data_width => INSTR_WIDTH,
        addr_width => 4,
        init_file => "loop_data.txt"
    )
    port map (
        addr => mem_fromcore.im_addr(3 downto 0),
        data_out => mem_tocore.im_data_in
    );
    
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

end Behavioral;
