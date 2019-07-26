library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity Leros_core is
    port (
        -- outputs
        pc_sig : out unsigned(REG_WIDTH-1 downto 0);
        dm_addr : out unsigned(REG_WIDTH-1 downto 0);
        dm_wr_en : out std_logic;
        dm_data_out : out std_logic_vector(REG_WIDTH-1 downto 0);
        dm_data_in : in std_logic_vector(REG_WIDTH-1 downto 0);
        acc_sig : out std_logic_vector(REG_WIDTH - 1 downto 0);

        -- inputs
        clk : in std_logic;
        rst : in std_logic;
        instr : in std_logic_vector(INSTR_WIDTH - 1 downto 0)
    );
end Leros_core;

architecture Behavioral of Leros_core is

    -- Control signals
    signal alu_ctrl : ALU_op;
    signal acc_ctrl : MEM_op;
    signal br_ctrl : BR_op;
    signal imm_ctrl : IMM_op;
    signal alu_op1_ctrl : ALU_OP1_op;
    signal alu_op2_ctrl : ALU_OP2_op;
    signal do_branch : std_logic;
    signal dm_addr_sel : DM_sel;

    -- Entity output signals
    signal alu_op1 : signed(REG_WIDTH - 1 downto 0);
    signal alu_op2 : signed(REG_WIDTH - 1 downto 0);
    signal alu_res : signed(REG_WIDTH - 1 downto 0);
    signal immediate : signed(REG_WIDTH-1 downto 0);
    signal instr_op : LEROS_op;

    -- Registers
    signal acc_reg : std_logic_vector(REG_WIDTH - 1 downto 0) := (others => '0');
    signal addr_reg : unsigned(REG_WIDTH - 1 downto 0) := (others => '0');
    signal pc_reg : unsigned(REG_WIDTH - 1 downto 0) := (others => '0');

begin

    acc_sig <= acc_reg;

    CONTROL_ent : entity work.Control
    port map (
        instr => instr_op,
        alu_ctrl => alu_ctrl,
        acc_ctrl => acc_ctrl,
        imm_ctrl => imm_ctrl,
        alu_op1_ctrl => alu_op1_ctrl,
        alu_op2_ctrl => alu_op2_ctrl,
        br_ctrl => br_ctrl
    );

    ALU_ent : entity work.ALU
    generic map (
        width => REG_WIDTH
    )
    port map (
        ctrl => alu_ctrl,
        op1 => alu_op1,
        op2 => alu_op2,
        res => alu_res
    );

    BRANCH_ent : entity work.Branch
    port map (
        acc => signed(acc_reg),
        op => br_ctrl,
        do_branch => do_branch
    );

    IMM_ent : entity work.IMM
    port map (
        instr => instr,
        ctrl => imm_ctrl,
        imm => immediate
    );

    DECODE_ent : entity work.InstrDecoder
    port map (
        instr => instr,
        op => instr_op
    );

    -- ALU logic
    with alu_op1_ctrl select
        alu_op1 <= signed(pc_reg) when pc,
                   signed(acc_reg) when acc;

    with alu_op2_ctrl select
        alu_op2 <= signed(dm_data_in) when reg,
                   immediate when imm;


    -- Memory I/O logic
    dm_data_out <= acc_reg;
    pc_sig <= pc_reg;

    with dm_addr_sel select
            dm_addr <= resize(unsigned(instr(7 downto 0)), dm_addr'length) when reg,
                       addr_reg when mem;

    -- Clocking logic
    process(clk, do_branch, instr_op) is
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    pc_reg <= (others => '0');
                    acc_reg <= (others => '0');
                    addr_reg <= (others => '0');
                else
                    -- Next cycle PC logic
                    if do_branch = '1' then
                        pc_reg <= unsigned(alu_res);
                    elsif instr_op = jal then
                        pc_reg <= unsigned(acc_reg);
                    else
                        pc_reg <= pc_reg + 1;
                    end if;

                    -- Next cycle accumulator logic
                    if acc_ctrl = wr then
                        acc_reg <= std_logic_vector(alu_res);
                    end if;
                    
                    -- Next cycle address register logic
                    if instr_op = ldaddr then
                        addr_reg <= unsigned(acc_reg);
                    end if;
                end if;
            end if;
        end process;

end Behavioral;
