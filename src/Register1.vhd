library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Fixed Register (synchronous reset and consistent timing)
entity Register1 is
    port (
        input         : in std_logic_vector(15 downto 0);
        write_en, clk : in std_logic;
        output        : out std_logic_vector(15 downto 0)
    );
end entity Register1;

architecture Behavioral of Register1 is
    signal reg_data : std_logic_vector(15 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if write_en = '1' then
                reg_data <= input;
            end if;
        end if;
    end process;
    
    output <= reg_data;
end architecture Behavioral;