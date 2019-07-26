----------------------------------------------------------------------------------
-- A simple memory system implementing instruction- and data memory as well as
-- memory mapping for board peripherals on a basys3 board

-- Memory map:
-- 0x9FFF0004  _______
--            |  LEDs |
-- 0x9FFF0000 |_______|
--            |_______|
-- 0x3FF      |       | <- Registers mapped as topmost 2**8 addresses
--            |  RAM  |
-- 0x0        |_______|
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity LEROSB3MEM is
  generic (
      rom_init_file : string := ""
  );
  Port (
      clk, rst : in std_logic;
      mem_out : out LEROS_MEM_IN;
      mem_in : in LEROS_MEM_OUT;
      led : out std_logic_vector(15 downto 0)
  );
end LEROSB3MEM;

architecture Behavioral of LEROSB3MEM is

    constant led_addr : unsigned(REG_WIDTH - 1 downto 0) := X"9FFF0000";
    -- 2kB RAM: 2**9 * 32 bit
    constant ram_address_width : integer := 9;
    constant rom_address_width : integer := 5;


    signal ram_data_out : std_logic_vector(REG_WIDTH-1 downto 0);
    signal ram_addr : unsigned(ram_address_width - 1 downto 0);
    signal ram_wr_en : std_logic;

begin

    Instr_mem : entity work.ROM
    generic map (
        data_width => INSTR_WIDTH,
        addr_width => rom_address_width, -- ensure address space is large enough for the loaded binary file
        init_file => rom_init_file
    )
    port map (
        addr => mem_in.im_addr(rom_address_width - 1 downto 0),
        data_out => mem_out.im_data_in
    );

    -- 1kB RAM
    Data_mem : entity work.RAM
    generic map (
        size => ram_address_width
    )
    port map (
        clk => clk,
        data_in => mem_in.dm_data_out,
        data_out => ram_data_out,
        addr => ram_addr,
        wr_en => ram_wr_en,
        access_size => mem_in.dm_access_size
    );

    -- Memory mapped peripherals
    memory_mapping : process(mem_in.dm_addr, ram_data_out)
    begin
        led <= (others => '0');
        ram_addr <= (others => '0');
        mem_out.dm_data_in_valid <= '0';
        mem_out.reg_data_in_valid <= '0';
        mem_out.dm_data_in <= X"DEADBEEF";
        mem_out.reg_data_in <= X"DEADBEEF";
        ram_wr_en <= '0';

        -- Memory access (RAM)
        if mem_in.dm_op /= nop and mem_in.dm_addr < 2**ram_address_width then
            ram_addr <= mem_in.dm_addr(ram_addr'left downto 0);
            if mem_in.dm_op = rd then
                mem_out.dm_data_in_valid <= '1';
                mem_out.dm_data_in <= ram_data_out;
            else
                ram_wr_en <= '1';
            end if;
        
        -- Register acces - mapped to top 256 32-bit words of RAM
        elsif mem_in.reg_op /= nop then
            -- Register number is shifted left twice, given that RAM is byte-addressable
            ram_addr <= 
                (mem_in.reg_addr sll 2)
                + to_unsigned((2**ram_address_width - 1 - 2**NLOG_REGS), ram_address_width);
            if mem_in.reg_op = rd then
                mem_out.reg_data_in <= ram_data_out;
                mem_out.reg_data_in_valid <= '1';
            else
                ram_wr_en <= '1';
            end if;

        -- Peripheral access through memory mapping
        elsif (mem_in.dm_addr = led_addr) and (mem_in.dm_op = wr) then
            led <= mem_in.dm_data_out(15 downto 0);
        end if;
    end process;




end Behavioral;
