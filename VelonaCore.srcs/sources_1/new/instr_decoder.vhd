library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity InstrDecoder is
    port (
        instr : in std_logic_vector(INSTR_WIDTH - 1 downto 0);
        op : out LEROS_op
    );
end InstrDecoder;

architecture Behavioral of InstrDecoder is

begin

    decode_proc : process(instr)
    begin
        if std_match(instr(15 downto 8), NOP_OPC) then op <= nop;
        elsif std_match(instr(15 downto 8), ADD_OPC) then op <= add;
        elsif std_match(instr(15 downto 8), ADDI_OPC) then op <= addi;
        elsif std_match(instr(15 downto 8), SUB_OPC) then op <= sub;
        elsif std_match(instr(15 downto 8), SUBI_OPC) then op <= subi;
        elsif std_match(instr(15 downto 8), SRA_OPC) then op <= shra;
        elsif std_match(instr(15 downto 8), LOAD_OPC) then op <= load;
        elsif std_match(instr(15 downto 8), LOADI_OPC) then op <= loadi;
        elsif std_match(instr(15 downto 8), AND_OPC) then op <= andr;
        elsif std_match(instr(15 downto 8), ANDI_OPC) then op <= andi;
        elsif std_match(instr(15 downto 8), OR_OPC) then op <= orr;
        elsif std_match(instr(15 downto 8), ORI_OPC) then op <= ori;
        elsif std_match(instr(15 downto 8), XOR_OPC) then op <= xorr;
        elsif std_match(instr(15 downto 8), XORI_OPC) then op <= xori;
        elsif std_match(instr(15 downto 8), LOADHI_OPC) then op <= loadhi;
        elsif std_match(instr(15 downto 8), LOADH2I_OPC) then op <= loadh2i;
        elsif std_match(instr(15 downto 8), LOADH3I_OPC) then op <= loadh3i;
        elsif std_match(instr(15 downto 8), STORE_OPC) then op <= store;
        elsif std_match(instr(15 downto 8), OUT_OPC) then op <= ioout;
        elsif std_match(instr(15 downto 8), IN_OPC) then op <= ioin;
        elsif std_match(instr(15 downto 8), JAL_OPC) then op <= jal;
        elsif std_match(instr(15 downto 8), LDADDR_OPC) then op <= ldaddr;
        elsif std_match(instr(15 downto 8), LDIND_OPC) then op <= ldind;
        elsif std_match(instr(15 downto 8), LDINDB_OPC) then op <= ldindb;
        elsif std_match(instr(15 downto 8), LDINDH_OPC) then op <= ldindh;
        elsif std_match(instr(15 downto 8), STIND_OPC) then op <= stind;
        elsif std_match(instr(15 downto 8), STINDB_OPC) then op <= stindb;
        elsif std_match(instr(15 downto 8), STINDH_OPC) then op <= stindh;
        elsif std_match(instr(15 downto 8), BR_OPC) then op <= br;
        elsif std_match(instr(15 downto 8), BRZ_OPC) then op <= brz;
        elsif std_match(instr(15 downto 8), BRNZ_OPC) then op <= brnz;
        elsif std_match(instr(15 downto 8), BRP_OPC) then op <= brp;
        elsif std_match(instr(15 downto 8), BRN_OPC) then op <= brn;
        else op <= nop;
        end if;
    end process;

end Behavioral;
