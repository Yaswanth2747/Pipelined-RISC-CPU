library ieee;
use ieee.std_logic_1164.all;

entity SE6 is
	port (input: in std_logic_vector(5 downto 0);
			output: out std_logic_vector(15 downto 0));
end entity SE6;

architecture str of SE6 is
	constant pad_pos : std_logic_vector(9 downto 0) := (others => '0');
	constant pad_neg   : std_logic_vector(9 downto 0) := (others => '1');
begin
	proc: process(input)
	begin
		if (input(5) = '0') then 
			output <= pad_pos & input;
		else 
			output <= pad_neg & input;
		end if;
	end process;
end str;