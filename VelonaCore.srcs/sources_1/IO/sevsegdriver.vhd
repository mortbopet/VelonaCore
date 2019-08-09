library ieee;
use ieee.std_logic_1164.all;
package sevsegdriver_pkg is
    type SevSeg is record
        dp  : std_logic;
        seg : std_logic_vector(6 downto 0);
    end record;

    constant SevSeg_zero : SevSeg := (
        seg => (others => '0'),
        dp => '0');

    type SevSeg_arr is array (natural range <>) of SevSeg;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.sevsegdriver_pkg.all;
use work.Common.all;

entity SevSegDriver is
    generic(
        segments : integer;
        clk_freq : integer
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        seg_data : in SevSeg;
        wr_en : in std_logic_vector(segments - 1 downto 0);

        seg : out std_logic_vector(6 downto 0);
        dp  : out std_logic;
        an  : out std_logic_vector(segments - 1 downto 0)
    );
end SevSegDriver;

architecture Behavioral of SevSegDriver is

    signal seg_reg : SevSeg_arr(segments - 1 downto 0);
    signal seg_clk : std_logic;
    signal seg_idx_reg : integer range 0 to segments - 1;

    begin

    clkgen_ent : entity work.ClkGen
    generic map(
        clk_freq => clk_freq,
        target_freq => 60*segments
    )
    port map (
        clk => clk,
        rst => rst,
        clk_out => seg_clk
    );

    process(seg_idx_reg)
    begin
        an <= (others => '1');
        an(seg_idx_reg) <= '0';
    end process;
    seg <= not seg_reg(seg_idx_reg).seg;
    dp <= not seg_reg(seg_idx_reg).dp;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                seg_reg <= (others => SevSeg_zero);
                seg_idx_reg <= 0;
            else
                if seg_clk = '1' then
                    if seg_idx_reg = (segments - 1) then
                        seg_idx_reg <= 0;
                    else
                        seg_idx_reg <= seg_idx_reg + 1;
                    end if;
                end if;

               for i in 0 to (segments - 1) loop
                    if wr_en(i) = '1' then
                        seg_reg(i) <= seg_data;
                    end if;
                end loop;
            end if;
        end if;
    end process;

end Behavioral;