library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity loop_tb is
end loop_tb;

use work.Common.all;

architecture Behavioral of loop_tb is

    signal clk, rst : std_logic;
    constant clk_period : time := 1 ns;
    
    signal mem_tocore : LEROS_MEM_IN;
    signal mem_fromcore : LEROS_MEM_OUT;

begin
    
    mem_tocore.dm_data <= (others => '0');
    mem_tocore.dm_data_valid <= '0';
    mem_tocore.reg_data <= (others => '0');
    mem_tocore.im_data_valid <= '1';

    Core_ent :  entity work.Leros_core
    port map (
        mem_out => mem_fromcore,
        mem_in => mem_tocore,
        clk => clk,
        rst => rst
    );

    MemorySystem : entity work.LEROSB3MEM
        generic  map (
            rom_init_file => "blink.c.txt"
        )
        port map (
            clk => clk,
            rst => rst,
            mem_out => mem_tocore,
            mem_in => mem_fromcore
        );
    
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    rst_process : process
    begin
        rst <= '1';
        wait for clk_period;
        rst <= '0';
        wait;
    end process;

end Behavioral;
