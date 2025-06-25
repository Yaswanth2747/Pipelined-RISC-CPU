library ieee;
use ieee.std_logic_1164.all;

entity TR1 is
    port (
        clk       : in std_logic;
        instr     : in std_logic_vector(15 downto 0);
        opcode    : out std_logic_vector(3 downto 0);
        regA      : out std_logic_vector(2 downto 0);
        regB      : out std_logic_vector(2 downto 0);
        regC      : out std_logic_vector(2 downto 0);
        addi_imm  : out std_logic_vector(5 downto 0);
        jri_imm   : out std_logic_vector(8 downto 0)
    );
end entity TR1;

architecture Behavioral of TR1 is
    signal instr_reg : std_logic_vector(15 downto 0);
begin
    -- Register stage (synchronous)
    process(clk)
    begin
        if falling_edge(clk) then
            instr_reg <= instr;
        end if;
    end process;
    
    -- Instruction decoding (combinational)
    opcode   <= instr_reg(15 downto 12);
    regA     <= instr_reg(11 downto 9);
    regB     <= instr_reg(8 downto 6);
    regC     <= instr_reg(5 downto 3);
    addi_imm <= instr_reg(5 downto 0);
    jri_imm  <= instr_reg(8 downto 0);
end architecture Behavioral;