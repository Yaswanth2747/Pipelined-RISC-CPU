library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC_Component is
    port (
            clk             : in std_logic;
            rst             : in std_logic;
            is_jri          : in std_logic;
            regA_data       : in std_logic_vector(15 downto 0);
            jri_imm         : in std_logic_vector(8 downto 0);
				start				 : in std_logic;
            pc_current      : out std_logic_vector(15 downto 0);
            pc_next         : out std_logic_vector(15 downto 0)
        );
end entity PC_Component;

architecture rtl of PC_Component is
    signal pc_reg           : unsigned(15 downto 0) := (others => '0');
    signal pc_next_internal : unsigned(15 downto 0);
    signal jri_target       : unsigned(15 downto 0);
    signal pc_initialized   : std_logic;
begin
    -- Computing the JRI target address: regA_data + 2*sign_extended(jri_imm)
    jri_target <= unsigned(regA_data) + unsigned(shift_left(resize(signed(jri_imm), 16), 1));

    -- Calculating the next PC based on current instruction
    pc_next_internal <= jri_target when is_jri = '1' else pc_reg + 1;
    
	 
	 
	 process(start)
	 begin
	 if start ='1' then
	 pc_initialized <= '1';
	 end if;
	 end process;
    
	 -- process to update the PC
    process(clk, rst)
    begin
        if rst = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if pc_initialized = '1' then
				pc_reg <= pc_next_internal;
				end if;
        end if;
    end process;

    -- assignments
    pc_current <= std_logic_vector(pc_reg);
    pc_next    <= std_logic_vector(pc_next_internal);
end architecture rtl;
