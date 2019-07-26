library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;

entity ROM is
    generic (
        init_file : string := "empty.txt";
        data_width  : integer;
        addr_width : integer
    );
    Port (
        addr : in unsigned(addr_width - 1 downto 0);
        data_out : out std_logic_vector(data_width - 1 downto 0)
    );
end ROM;

architecture Behavioral of ROM is
    type mem_arr is array((2**addr_width) downto 0) of std_logic_vector(data_width - 1 downto 0);

    --Read from file function--
    impure function initRom (RomFileName : in string) return mem_arr is                            
    file RomFile : text is in RomFileName;                                                              
    variable RomFileLine : line;               
    variable linedata : bit_vector(data_width - 1 downto 0);                                                   
    variable outrom : mem_arr;                                                                            
                                                                                                   
    begin             
        if RomFileName = "empty.txt" then
            outrom := (others => (others => '0'));
        else                                                                       
            for i in outrom'range loop                                                                        
                readline (RomFile, RomFileLine);
                read(RomFileLine, linedata);      
                outrom(2**addr_width - i) := to_stdlogicvector(linedata);                                             
            end loop;                                  
        end if;                                              
        return outrom;                                                                                         
    end function;

    signal mem : mem_arr := initRom(init_file);

begin

    data_out <= mem(to_integer(addr));

end Behavioral;
