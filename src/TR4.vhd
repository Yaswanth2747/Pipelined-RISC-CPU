library ieee;
use ieee.std_logic_1164.all;

entity TR4 is
    port (
        clk                     : in std_logic;
        DMEM_READ_DATA          : in std_logic_vector(15 downto 0);
        ALU_output_t3           : in std_logic_vector(15 downto 0);
        regA_addr               : in std_logic_vector(2 downto 0);
        DMEM_READ_DATA_buffer   : out std_logic_vector(15 downto 0);
        regA_addr_buffer        : out std_logic_vector(2 downto 0);
        ALU_output_buffer_out   : out std_logic_vector(15 downto 0)
    );
end entity TR4;

architecture Behavioral of TR4 is
    signal DMEM_READ_DATA_reg : std_logic_vector(15 downto 0);
    signal ALU_output_reg     : std_logic_vector(15 downto 0);
    signal regA_addr_reg      : std_logic_vector(2 downto 0);
begin
    -- Register stage (synchronous)
    process(clk)
    begin
        if falling_edge(clk) then
            DMEM_READ_DATA_reg <= DMEM_READ_DATA;
            ALU_output_reg     <= ALU_output_t3;
            regA_addr_reg      <= regA_addr;
        end if;
    end process;
    
    -- Output assignments (continuous)
    DMEM_READ_DATA_buffer <= DMEM_READ_DATA_reg;
    regA_addr_buffer <= regA_addr_reg;
    ALU_output_buffer_out <= ALU_output_reg;
end architecture Behavioral;

