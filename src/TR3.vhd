library ieee;
use ieee.std_logic_1164.all;

entity TR3 is
    port (
        clk                     : in std_logic;
        opcode                  : in std_logic_vector(3 downto 0);
        ALU_output              : in std_logic_vector(15 downto 0);
        sw_data                 : in std_logic_vector(15 downto 0);
        regA_in                 : in std_logic_vector(2 downto 0);
        opcode_buffer_out       : out std_logic_vector(3 downto 0);
        ALU_output_buffer_out   : out std_logic_vector(15 downto 0);
        sw_data_buffered        : out std_logic_vector(15 downto 0);
        regA_buffer_out         : out std_logic_vector(2 downto 0)
    );
end entity TR3;

architecture Behavioral of TR3 is
    signal opcode_reg       : std_logic_vector(3 downto 0);
    signal ALU_output_reg   : std_logic_vector(15 downto 0);
    signal sw_data_reg      : std_logic_vector(15 downto 0);
    signal regA_reg         : std_logic_vector(2 downto 0);
begin
    -- Register stage (synchronous)
    process(clk)
    begin
        if falling_edge(clk) then
            opcode_reg     <= opcode;
            ALU_output_reg <= ALU_output;
            sw_data_reg    <= sw_data;
            regA_reg       <= regA_in;
        end if;
    end process;
    
    -- Output assignments (continuous)
    opcode_buffer_out     <= opcode_reg;
    ALU_output_buffer_out <= ALU_output_reg;
    sw_data_buffered      <= sw_data_reg;
    regA_buffer_out       <= regA_reg;
end architecture Behavioral;