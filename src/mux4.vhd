library ieee;
use ieee.std_logic_1164.all;

entity mux4 is
    port (
        input0, input1, input2, input3 : in std_logic_vector(15 downto 0);
        sel                           : in std_logic_vector(1 downto 0);
        output                        : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of mux4 is
begin
    process(input0, input1, input2, input3, sel)
    begin
        case sel is
            when "00" =>
                output <= input0;
            when "01" =>
                output <= input1;
            when "10" =>
                output <= input2;
            when "11" =>
                output <= input3;
            when others =>
                output <= (others => '0'); -- safe default
        end case;
    end process;
end architecture;
