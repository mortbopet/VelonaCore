library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Common is
    type ALU_op is (
        nop,
        add,
        sub,
        shra,
        alu_and,
        alu_or,
        alu_xor,
        loadi,
        loadhi,
        loadh2i,
        loadh3i
    );

    type DM_sel is (
        reg,
        mem
    );

    type MEM_op is (
        invalid,
        wr
    );

    type ALU_OP1_op is (
        acc,
        pc
    );

    type ALU_OP2_op is (
        reg,
        imm
    );

    type BR_op is (
        nop,
        br,
        brz,
        brnz,
        brp,
        brn
    );

    type IMM_op is (
        nop,
        branch,
        loadi,
        loadhi,
        loadh2i,
        loadh3i,
        jal
    );

    -- Instruction opcodes
    type LEROS_op is (
        nop,
        add,
        addi,
        sub,
        subi,
        shra,
        load,
        loadi,
        andr,
        andi,
        orr,
        ori,
        xorr,
        xori,
        loadhi,
        loadh2i,
        loadh3i,
        store,
        ioout,
        ioin,
        jal,
        ldaddr,
        ldind,
        ldindb,
        ldindh,
        stind,
        stindb,
        stindh,
        br,
        brz,
        brnz,
        brp,
        brn
    );

    constant NOP_OPC    : std_logic_vector(7 downto 0) := "00000---";
    constant ADD_OPC    : std_logic_vector(7 downto 0) := "000010-0";
    constant ADDI_OPC   : std_logic_vector(7 downto 0) := "000010-1";
    constant SUB_OPC    : std_logic_vector(7 downto 0) := "000011-0";
    constant SUBI_OPC   : std_logic_vector(7 downto 0) := "000011-1";
    constant SRA_OPC    : std_logic_vector(7 downto 0) := "00010---";
    constant LOAD_OPC   : std_logic_vector(7 downto 0) := "00100000";
    constant LOADI_OPC  : std_logic_vector(7 downto 0) := "00100001";
    constant AND_OPC    : std_logic_vector(7 downto 0) := "00100010";
    constant ANDI_OPC   : std_logic_vector(7 downto 0) := "00100011";
    constant OR_OPC     : std_logic_vector(7 downto 0) := "00100100";
    constant ORI_OPC    : std_logic_vector(7 downto 0) := "00100101";
    constant XOR_OPC    : std_logic_vector(7 downto 0) := "00100110";
    constant XORI_OPC   : std_logic_vector(7 downto 0) := "00100111";
    constant LOADHI_OPC : std_logic_vector(7 downto 0) := "00101001";
    constant LOADH2I_OPC : std_logic_vector(7 downto 0) := "00101010";
    constant LOADH3I_OPC : std_logic_vector(7 downto 0) := "00101011";
    constant STORE_OPC  : std_logic_vector(7 downto 0) := "00110---";
    constant OUT_OPC    : std_logic_vector(7 downto 0) := "001110--";
    constant IN_OPC     : std_logic_vector(7 downto 0) := "000001--";
    constant JAL_OPC    : std_logic_vector(7 downto 0) := "01000---";
    constant LDADDR_OPC : std_logic_vector(7 downto 0) := "01010---";
    constant LDIND_OPC  : std_logic_vector(7 downto 0) := "01100-00";
    constant LDINDB_OPC : std_logic_vector(7 downto 0) := "01100-01";
    constant LDINDH_OPC : std_logic_vector(7 downto 0) := "01100-10";
    constant STIND_OPC  : std_logic_vector(7 downto 0) := "01110-00";
    constant STINDB_OPC : std_logic_vector(7 downto 0) := "01110-01";
    constant STINDH_OPC : std_logic_vector(7 downto 0) := "01110-10";
    constant BR_OPC     : std_logic_vector(7 downto 0) := "1000----";
    constant BRZ_OPC    : std_logic_vector(7 downto 0) := "1001----";
    constant BRNZ_OPC   : std_logic_vector(7 downto 0) := "1010----";
    constant BRP_OPC    : std_logic_vector(7 downto 0) := "1011----";
    constant BRN_OPC    : std_logic_vector(7 downto 0) := "1100----";

    constant INSTR_WIDTH : integer := 16;
    constant REG_WIDTH : integer := 32;

end Common;