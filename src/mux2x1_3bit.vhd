library ieee;
use ieee.std_logic_1164.all;

entity mux2x1_3bit is
    port (
        a    : in  std_logic_vector(2 downto 0);  -- input 0
        b    : in  std_logic_vector(2 downto 0);  -- input 1
        sel  : in  std_logic;                     -- select signal
        y    : out std_logic_vector(2 downto 0)   -- output
    );
end entity mux2x1_3bit;

architecture behavioral of mux2x1_3bit is
begin
    process(a, b, sel)
    begin
        if sel = '0' then
            y <= a;
        else
            y <= b;
        end if;
    end process;
end architecture behavioral;
