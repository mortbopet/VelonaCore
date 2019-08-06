library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.Common.all;

entity State is
    Port (
        instr : LEROS_op;
        mem_in : in Velona_Mem_in;
        ready : out std_logic
    );
end State;

architecture Behavioral of State is

    signal mem_ready, reg_ready : std_logic;

begin

    with instr select
        mem_ready <= mem_in.dm_data_valid when ldind | ldindb | ldindh,
                     '1' when others;
    
    with instr select
        reg_ready <= mem_in.reg_data_valid when add | sub | andr | orr | xorr | load | ldaddr,
                    '1' when others;

    ready <= mem_ready and reg_ready and mem_in.im_data_valid;



end Behavioral;
