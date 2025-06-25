library ieee;
use ieee.std_logic_1164.all;

entity SE9 is
		port ( input  : in  std_logic_vector(8 downto 0);
			    output : out std_logic_vector(15 downto 0));
end entity SE9;

architecture str of SE9 is
	constant pad_pos : std_logic_vector(6 downto 0) := (others => '0');
	constant pad_neg : std_logic_vector(6 downto 0) := (others => '1');
begin
	proc: process(input)
	begin
		if (input(8) = '0') then 
			output <= pad_pos & input;
		else 
			output <= pad_neg & input;
		end if;
	end process;
end str;