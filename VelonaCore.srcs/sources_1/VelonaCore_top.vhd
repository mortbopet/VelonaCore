library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Common.all;

entity VelonaCore_top is
    Port (
        clk : in std_logic;

        -- Basys3 I/O
        sw  : in std_logic_vector(15 downto 0);
        led : out std_logic_vector(15 downto 0);

        -- 7 Segment Display
        seg : out std_logic_vector(6 downto 0);
        dp  : out std_logic;
        an  : out std_logic_vector(3 downto 0)

    );
end VelonaCore_top;

architecture Behavioral of VelonaCore_top is

    signal mem_tocore : Velona_Mem_in;
    signal mem_fromcore : Velona_Mem_Out;

begin

    Core_ent :  entity work.VelonaCore
    port map (
        mem_out => mem_fromcore,
        mem_in => mem_tocore,
        clk => clk,
        rst => '0'
    );

    MemorySystem : entity work.VelonaB3Mem
        generic  map (
            rom_init_file => "../rom_init/sevensegment.txt"
        )
        port map (
            clk => clk,
            rst => '0',
            mem_out => mem_tocore,
            mem_in => mem_fromcore,
            leds => led,
            sw => sw,
            seg => seg,
            dp => dp,
            an => an
        );

end Behavioral;
