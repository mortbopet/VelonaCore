library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_tb is
end add_tb;

use work.Common.all;

architecture Behavioral of add_tb is

    signal clk : std_logic;
    constant clk_period : time := 1 ns;

    signal im_addr : unsigned(REG_WIDTH - 1 downto 0);
    signal im_data_in : std_logic_vector(INSTR_WIDTH - 1 downto 0);

begin

    Core_ent :  entity work.Leros_core
    port map (
        im_addr => im_addr,
        dm_data_in => (others => '0'),
        dm_data_in_valid => '0',
        reg_data_in => (others => '0'),
        clk => clk,
        rst => '0',
        im_data_in => im_data_in,
        im_data_in_valid => '1'
    );

    Instr_mem : entity work.ROM
    generic map (
        data_width => INSTR_WIDTH,
        addr_width => 4,
        init_file => "add_tb_data.txt"
    )
    port map (
        addr => im_addr(3 downto 0),
        data_out => im_data_in
    );
    
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

end Behavioral;
