library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A byte addressable RAM with variable read- and write width
-- The ram is synthesized of 32-bit words. Unaligned access is illegal.
-- Ie. half-word access must be half word aligned, etc.

use work.Common.all;

entity RAM is
    generic (
        size : integer -- 2^$size words
    );
    Port (
        clk : in std_logic;
        data_in : in std_logic_vector(31 downto 0);
        addr : in unsigned((size + 2) - 1 downto 0); -- byte addressable
        access_size : in ACCESS_SIZE_op;
        wr_en : in std_logic;
        data_out : out std_logic_vector(31 downto 0)
    );
end RAM;

architecture Behavioral of RAM is

    type mem_arr is array((2**size) downto 0) of std_logic_vector(31 downto 0);
    signal mem : mem_arr := (others => (others => '0'));
    signal word_addr : unsigned(size - 1 downto 0);

    signal data_read, data_write : std_logic_vector(31 downto 0);

begin

    word_addr <= addr(addr'left downto 2);
    data_read <= mem(to_integer(word_addr));

    with access_size select
        data_write <= data_in when word,
                      data_read(31 downto 16) & data_in(15 downto 0) when half,
                      data_read(31 downto 8) & data_in(7 downto 0) when byte;

    read_out : process(access_size, addr)
    begin
        if access_size = word then
            data_out <= data_read;
        elsif access_size = half and addr(1 downto 0) = "10" then
            data_out <= X"0000" & data_read(31 downto 16);
        elsif access_size = half and addr(1 downto 0) = "00" then
            data_out <= X"0000" & data_read(15 downto 0);
        elsif access_size = byte and addr(1 downto 0) = "00" then
            data_out <= X"000000" & data_read(7 downto 0);
        elsif access_size = byte and addr(1 downto 0) = "01" then
            data_out <= X"000000" & data_read(15 downto 8);
        elsif access_size = byte and addr(1 downto 0) = "10" then
            data_out <= X"000000" & data_read(23 downto 16);
        elsif access_size = byte and addr(1 downto 0) = "11" then
            data_out <= X"000000" & data_read(31 downto 24);
        else
            data_out <= (others => '-');
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if wr_en = '1' then
                mem(to_integer(word_addr)) <= data_write;
            end if;
        end if;
    end process;

end Behavioral;
