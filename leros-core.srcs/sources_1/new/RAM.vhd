library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAM is
    generic (
        data_width  : integer;
        addr_width : integer
    );
    Port (
        clk : in std_logic;
        data_in : in std_logic_vector(data_width - 1 downto 0);
        addr : in unsigned(addr_width - 1 downto 0);
        wr_en : in std_logic;
        data_out : out std_logic_vector(data_width - 1 downto 0)
    );
end RAM;

architecture Behavioral of RAM is

    type mem_arr is array((2**addr_width) downto 0) of std_logic_vector(data_width - 1 downto 0);
    signal mem : mem_arr;

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                mem(to_integer(addr)) <= data_in;
            end if;
        end if;
    end process;

    data_out <= mem(to_integer(addr));

end Behavioral;
