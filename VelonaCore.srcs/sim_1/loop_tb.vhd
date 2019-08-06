library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity loop_tb is
end loop_tb;

use work.Common.all;

architecture Behavioral of loop_tb is

    signal clk, rst : std_logic;
    constant clk_period : time := 1 ns;
    
    signal mem_tocore : Velona_Mem_in;
    signal mem_fromcore : Velona_Mem_Out;

    signal sw : std_logic_vector(15 downto 0) := X"0005";

begin

    Core_ent :  entity work.VelonaCore
    port map (
        mem_out => mem_fromcore,
        mem_in => mem_tocore,
        clk => clk,
        rst => rst
    );

    MemorySystem : entity work.VelonaB3Mem
        generic  map (
            rom_init_file => "triangle.c.txt"
        )
        port map (
            clk => clk,
            rst => rst,
            mem_out => mem_tocore,
            mem_in => mem_fromcore,
            sw => sw
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
