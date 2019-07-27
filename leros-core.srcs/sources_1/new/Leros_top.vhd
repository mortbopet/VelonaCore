library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity Leros_top is
    Port (
        led : out std_logic_vector(15 downto 0);
        clk : in std_logic
    );
end Leros_top;

architecture Behavioral of Leros_top is

    signal mem_tocore : LEROS_MEM_IN;
    signal mem_fromcore : LEROS_MEM_OUT;

begin

    Core_ent :  entity work.Leros_core
    port map (
        mem_out => mem_fromcore,
        mem_in => mem_tocore,
        clk => clk, 
        rst => '0'
    );

    MemorySystem : entity work.LEROSB3MEM
        generic  map (
            rom_init_file => ""
        )
        port map (
            clk => clk,
            rst => '0',
            mem_out => mem_tocore,
            mem_in => mem_fromcore,
            leds => led
        );

end Behavioral;
