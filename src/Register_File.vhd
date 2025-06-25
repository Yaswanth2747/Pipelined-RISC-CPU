library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Register_File is
    port (
        RF_A1, RF_A2, RF_A3            : in std_logic_vector(2 downto 0);  -- A3 for Write
        RF_D3                          : in std_logic_vector(15 downto 0);  -- Write Data
        RF_D1, RF_D2                   : out std_logic_vector(15 downto 0); -- Read Data
        clk, RF_write                  : in std_logic;                      -- Active on Rising Edge
        R0, R1, R2, R3, R4, R5, R6, R7 : out std_logic_vector(15 downto 0)  -- for debugging purpose
    );
end entity Register_File;

architecture Behavioural of Register_File is
    type reg_array is array (7 downto 0) of std_logic_vector(15 downto 0);
    signal registers : reg_array := (
        0 => "0000000000001111", 
        1 => "1111000000000000", 
        2 => "0000000000000011", 
        3 => "0000000000000100", 
        4 => "0000000000000101", 
        5 => "0000000000000110", 
        6 => "0000000000000111", 
        7 => "0000001100000000"
    );
begin
    -- Register write process (synchronous)
    process(clk)
    begin
        if falling_edge(clk) then
            if RF_write = '1' then
                registers(to_integer(unsigned(RF_A3))) <= RF_D3;
            end if;
        end if;
    end process;
    
    -- Register read (asynchronous for combinational path)
    RF_D1 <= registers(to_integer(unsigned(RF_A1)));
    RF_D2 <= registers(to_integer(unsigned(RF_A2)));
    
    -- Debug outputs
    R0 <= registers(0);
    R1 <= registers(1);
    R2 <= registers(2);
    R3 <= registers(3);
    R4 <= registers(4);
    R5 <= registers(5);
    R6 <= registers(6);
    R7 <= registers(7);
end architecture Behavioural;