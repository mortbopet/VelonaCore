library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.Common.all;

entity Leros_core is
    port ( 
        clk : in std_logic;
        rst : in std_logic;

        mem_in : in LEROS_MEM_IN;
        mem_out : out LEROS_MEM_OUT
    );
end Leros_core;

architecture Behavioral of Leros_core is

    -- Control signals
    signal alu_ctrl : ALU_op;
    signal acc_ctrl : ACC_SRC_op;
    signal br_ctrl : BR_op;
    signal imm_ctrl : IMM_op;
    signal alu_op1_ctrl : ALU_OP1_op; 
    signal alu_op2_ctrl : ALU_OP2_op;
    signal do_branch : std_logic;

    -- Entity output signals
    signal alu_op1 : signed(REG_WIDTH - 1 downto 0);
    signal alu_op2 : signed(REG_WIDTH - 1 downto 0);
    signal alu_res : signed(REG_WIDTH - 1 downto 0);
    signal immediate : signed(REG_WIDTH-1 downto 0);
    signal instr_op : LEROS_op;
    signal reg_op : MEM_op;
    signal dm_op : MEM_op;

    -- Registers
    signal acc_reg : std_logic_vector(REG_WIDTH - 1 downto 0) := (others => '0');
    signal addr_reg : unsigned(REG_WIDTH - 1 downto 0) := (others => '0');
    signal pc_reg : unsigned(REG_WIDTH - 1 downto 0) := (others => '0');

    -- ready signal: Indicates that next state may be taken
    signal ready : std_logic;

begin

    CONTROL_ent : entity work.Control
    port map (
        instr => instr_op,
        alu_ctrl => alu_ctrl,
        acc_ctrl => acc_ctrl,
        imm_ctrl => imm_ctrl,
        alu_op1_ctrl => alu_op1_ctrl,
        alu_op2_ctrl => alu_op2_ctrl,
        br_ctrl => br_ctrl,
        dm_access_size => mem_out.dm_access_size,
        dm_op => dm_op,
        reg_op => reg_op
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
        instr => mem_in.im_data,
        ctrl => imm_ctrl,
        imm => immediate
    );

    DECODE_ent : entity work.InstrDecoder
    port map (
        instr => mem_in.im_data,
        op => instr_op
    );

    STATE_ent : entity work.State
    port map (
        instr => instr_op,
        mem_in => mem_in,
        ready => ready
    );

    -- ALU logic
    with alu_op1_ctrl select
        alu_op1 <= signed(pc_reg) when pc,
                   signed(acc_reg) when acc,
                   signed(addr_reg) when addr;

    with alu_op2_ctrl select
        alu_op2 <= signed(mem_in.reg_data) when reg,
                   immediate when imm,
                   (others => '0') when unused;


    -- Memory I/O logic
    mem_out.dm_op <= dm_op;
    mem_out.im_addr <= pc_reg;
    with dm_op select
        mem_out.dm_data <= acc_reg when wr,
                           (others => '-') when others;
    with dm_op select
        mem_out.dm_addr <= unsigned(alu_res) when wr | rd,
                            (others => '-') when others;

    -- Register I/O logic
    mem_out.reg_op <= reg_op;
    with instr_op select
        mem_out.reg_data <= std_logic_vector(alu_res) when jal,
                            acc_reg when store,
                            (others => '-') when others;
    
    with reg_op select
        mem_out.reg_addr <= unsigned(mem_in.im_data(7 downto 0)) when rd | wr,
                            (others => '-') when others;

    -- Clocking logic
    process(clk, do_branch, instr_op) is
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    pc_reg <= (others => '0');
                    acc_reg <= (others => '0');
                    addr_reg <= (others => '0');
                elsif ready = '1' then 
                    -- Next cycle PC logic
                    if do_branch = '1' then
                        pc_reg <= unsigned(alu_res);
                    elsif instr_op = jal then
                        pc_reg <= unsigned(acc_reg);
                    else
                        pc_reg <= pc_reg + 2;
                    end if;

                    -- Next cycle accumulator logic
                    if acc_ctrl = alu then
                        acc_reg <= std_logic_vector(alu_res);
                    elsif acc_ctrl = reg then
                        acc_reg <= mem_in.reg_data;
                    elsif acc_ctrl = dm then
                        acc_reg <= mem_in.dm_data;
                    end if;
                    
                    -- Next cycle address register logic
                    if instr_op = ldaddr then
                        addr_reg <= unsigned(mem_in.reg_data);
                    end if;
                end if;
            end if;
        end process;

end Behavioral;
