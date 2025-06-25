library ieee;
use ieee.std_logic_1164.all;

entity mux2 is
    port (
        input0, input1 : in std_logic_vector(15 downto 0);
        sel            : in std_logic;
        output         : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of mux2 is
begin
    process(input0, input1, sel)
    begin
        if sel = '0' then
            output <= input0;
        else
            output <= input1;
        end if;
    end process;
end architecture;
