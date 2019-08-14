library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity ROM is
    generic (
        init_file : string := "";
        data_width  : integer;
        addr_width : integer
    );
    Port (
        addr : in unsigned(addr_width - 1 downto 0);
        data_out : out std_logic_vector(data_width - 1 downto 0);
        data_valid : out std_logic
    );
end ROM;

architecture Behavioral of ROM is
    type mem_arr is array((2**addr_width - 1) downto 0) of std_logic_vector(data_width - 1 downto 0);

    --Read from file function--
    impure function initRom (fn : in string) return mem_arr is
    file RomFile : text is in fn;
    variable RomFileLine : line;
    variable linedata : bit_vector(data_width - 1 downto 0);
    variable outrom : mem_arr;

    begin
        for i in outrom'range loop
            readline (RomFile, RomFileLine);
            read(RomFileLine, linedata);
            outrom(2**addr_width - 1 - i) := to_stdlogicvector(linedata);
        end loop;
        return outrom;
    end function;

    impure function initRomPrimer(fn : in string) return mem_arr is
    variable outrom : mem_arr;
    begin
        if fn = "" then
            outrom := (others => (others => '0'));
        else
            outrom := initRom(fn);
        end if;
        return outrom;
    end function;

    signal mem : mem_arr := initRomPrimer(init_file);

begin

    data_out <= mem(to_integer(addr));

    process(addr)
    begin
        if addr >= 2**addr_width then
            data_valid <= '0';
        else
            data_valid <= '1';
        end if;
    end process;

end Behavioral;
