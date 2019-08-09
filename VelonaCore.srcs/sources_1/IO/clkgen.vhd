library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ClkGen is
    generic(
        clk_freq : integer;
        target_freq : integer
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        clk_out : out std_logic
    );
end ClkGen;

architecture Behavioral of ClkGen is

    constant target : integer := clk_freq / (target_freq * 2);
    signal counter_reg : integer range 0 to target;
    signal clk_out_reg : std_logic := '0';

begin
    clk_out <= '1' when counter_reg = target else '0';

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter_reg <= 0;
            else
                if counter_reg = target then
                    counter_reg <= 0;
                else
                    counter_reg <= counter_reg + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;