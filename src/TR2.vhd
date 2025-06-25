library ieee;
use ieee.std_logic_1164.all;

entity TR2 is
    port (
        clk                 : in std_logic;
        opcode_in           : in std_logic_vector(3 downto 0);
        ALU_A               : in std_logic_vector(15 downto 0);
        ALU_B               : in std_logic_vector(15 downto 0);
        regA_in             : in std_logic_vector(2 downto 0);
        opcode_buffer_out   : out std_logic_vector(3 downto 0);
        ALU_IN_A            : out std_logic_vector(15 downto 0);
        ALU_IN_B            : out std_logic_vector(15 downto 0);
        regA_buffer_out     : out std_logic_vector(2 downto 0)
    );
end entity TR2;

architecture Behavioral of TR2 is
    signal opcode_reg   : std_logic_vector(3 downto 0);
    signal ALU_A_reg    : std_logic_vector(15 downto 0);
    signal ALU_B_reg    : std_logic_vector(15 downto 0);
    signal regA_reg     : std_logic_vector(2 downto 0);
begin
    -- Register stage (synchronous)
    process(clk)
    begin
        if rising_edge(clk) then
            opcode_reg <= opcode_in;
            ALU_A_reg  <= ALU_A;
            ALU_B_reg  <= ALU_B;
            regA_reg   <= regA_in;
        end if;
    end process;
    
    -- Output assignments (continuous)
    opcode_buffer_out <= opcode_reg;
    ALU_IN_A          <= ALU_A_reg;
    ALU_IN_B          <= ALU_B_reg;
    regA_buffer_out   <= regA_reg;
end architecture Behavioral;