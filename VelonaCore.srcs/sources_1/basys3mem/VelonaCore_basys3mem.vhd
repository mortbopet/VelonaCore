----------------------------------------------------------------------------------
-- A simple memory system implementing instruction- and data memory as well as
-- memory mapping for board peripherals on a basys3 board

-- Memory map:
--            ________
--            |   sw  |
-- 0x9FFF0004 |_______|
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

entity VelonaB3Mem is
  generic (
      rom_init_file : string := ""
  );
  Port (
      clk, rst : in std_logic;
      mem_out : out Velona_Mem_in;
      mem_in : in Velona_Mem_Out;
      leds : out std_logic_vector(15 downto 0);
      sw : in std_logic_vector(15 downto 0)
  );
end VelonaB3Mem;

architecture Behavioral of VelonaB3Mem is

    -- Add any peripherals as a memory destination
    type mem_dest_t is (invalid, ram, reg, led, switches);
    signal mem_dest : mem_dest_t := invalid;

    constant led_addr : unsigned(REG_WIDTH - 1 downto 0) := X"9FFF0000";
    constant sw_addr : unsigned(REG_WIDTH - 1 downto 0) := X"9FFF0004";

    -- RAM size is specified in words, but ibyte indexed
    -- 2**(11 - 2) * 4 B = 2kB RAM
    constant ram_address_width : integer := 11;
    -- 2**8 * 2 B = 512B ROM
    constant rom_address_width : integer := 8;


    signal ram_data_out : std_logic_vector(REG_WIDTH-1 downto 0);
    signal ram_data_out_valid : std_logic;
    signal ram_addr : unsigned(ram_address_width - 1 downto 0);
    signal ram_wr_en : std_logic;
    signal ram_rd_en : std_logic;
    
    signal rom_addr : unsigned(rom_address_width - 1 downto 0);

    signal access_size : ACCESS_SIZE_op;
    signal ram_data_in : std_logic_vector(REG_WIDTH - 1 downto 0);

    signal leds_reg : std_logic_vector(15 downto 0);
    signal sw_reg : std_logic_vector(15 downto 0);

begin

    access_size_proc : process(mem_in.reg_op, mem_in.dm_op)
    begin
        -- Given the registers being mapped to RAM, access size from dm
        -- is overridden to a full word access if register access is requested
        if mem_in.reg_op /= nop then
            access_size <= word;
        else
            access_size <= mem_in.dm_access_size;
        end if;
    end process;

    -- ROM
    rom_addr <= mem_in.im_addr(rom_address_width downto 1);
    Instr_mem : entity work.ROM
    generic map (
        data_width => INSTR_WIDTH,
        addr_width => rom_address_width, -- ensure address space is large enough for the loaded binary file
        init_file => rom_init_file
    )
    port map (
        -- ROM is half-word aligned access, mem_in.im_addr is byte-aligned
        addr => rom_addr,
        data_out => mem_out.im_data,
        data_valid => mem_out.im_data_valid
    );

    -- 1kB RAM
    Data_mem : entity work.RAM
    generic map (
        size => (ram_address_width - 2) -- size specified in words, ram_address_width is byte aligned
    )
    port map (
        clk => clk,
        data_in => ram_data_in,
        data_out => ram_data_out,
        addr => ram_addr,
        wr_en => ram_wr_en,
        rd_en => ram_rd_en,
        data_out_valid => ram_data_out_valid,
        access_size => access_size
    );

    -- Determine access
    determine_access : process(mem_in.dm_addr, ram_data_out, mem_in.dm_op, mem_in.reg_op)
    begin
        -- Memory access (RAM)
        if mem_in.dm_op /= nop and mem_in.dm_addr < 2**ram_address_width then
            mem_dest <= ram;
        -- Register acces - mapped to top 256 32-bit words of RAM
        elsif mem_in.reg_op /= nop then
            mem_dest <= reg;
        -- Peripheral access through memory mapping
        elsif (mem_in.dm_addr = led_addr) and (mem_in.dm_op = wr) then
            mem_dest <= led;
        elsif (mem_in.dm_addr = sw_addr) and (mem_in.dm_op = rd) then
            mem_dest <= switches;
        else
            mem_dest <= invalid;
        end if;
    end process;

    -- Assign memory access signals to RAM/Registers
    assign_memsigs : process(ram_data_out, mem_dest, mem_in.dm_data,
        mem_in.reg_data, mem_in.dm_op, mem_in.reg_op, ram_data_out_valid,
        mem_in.dm_addr, mem_in.reg_addr)
    begin
        ram_addr <=  (others => '-');
        mem_out.dm_data_valid <= '0';
        mem_out.reg_data_valid <= '0';
        ram_wr_en <= '0';
        ram_rd_en <= '0';

        mem_out.dm_data <= (others => '-');
        mem_out.reg_data <= (others => '-');
        ram_data_in <= (others => '-');

        -- Memory access (RAM)
        if mem_dest = ram then
            ram_addr <= mem_in.dm_addr(ram_address_width - 1 downto 0);
            if mem_in.dm_op = rd then
                mem_out.dm_data_valid <= ram_data_out_valid;
                mem_out.dm_data <= ram_data_out;
                ram_rd_en <= '1';
            else
                ram_data_in <= mem_in.dm_data;
                ram_wr_en <= '1';
            end if;
        
        -- Register acces - mapped to top 256 32-bit words of RAM
        elsif mem_dest = reg then
            -- Register number is shifted left twice, given that RAM is byte-addressable
            -- NLOG_REGS + 2, given that registers take up 2**(NLOG_REGS + 2) bytes.
            ram_addr <=  (mem_in.reg_addr sll 2)
                + to_unsigned((2**(ram_address_width) - 2**(NLOG_REGS + 2)), ram_address_width);
            if mem_in.reg_op = rd then
                mem_out.reg_data <= ram_data_out;
                mem_out.reg_data_valid <= ram_data_out_valid;
                ram_rd_en <= '1';
            else
                ram_data_in <= mem_in.reg_data;
                ram_wr_en <= '1';
            end if;

        -- Peripheral reads
        elsif mem_dest = switches then
            mem_out.dm_data <= X"0000" & sw_reg;
            mem_out.dm_data_valid <= '1';
        end if;
    end process;

    -- Each memory mapped peripheral will have a set of registers assigned to the memory
    -- addresses. These peripherals shall be assigned in the following clocked process
    peripherals : process(clk, mem_dest)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                leds_reg <= (others => '0');
                sw_reg <= (others => '0');
            else
                sw_reg <= sw;
                if mem_dest = led then
                    leds_reg <= mem_in.dm_data(15 downto 0);
                end if;
            end if;
        end if;
    end process;
    leds <= leds_reg;

end Behavioral;
