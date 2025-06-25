library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
    port (A, B: in std_logic_vector(15 downto 0);
          opcode: in std_logic_vector(3 downto 0);
          C: out std_logic_vector(15 downto 0);
          z_flag: out std_logic);
end entity ALU;

architecture Struct of ALU is
    signal result: std_logic_vector(15 downto 0);
begin
    process(A, B, opcode)
    begin
        case opcode(3 downto 0) is
            when "0010" => result <= std_logic_vector(signed(A) + signed(B));  -- ADD
            when "0011" => result <= std_logic_vector(signed(A) - signed(B));  -- SUB
            when "0100" => result <= std_logic_vector(resize(signed(A) * signed(B), 16));  -- MUL
            when "0101" => result <= std_logic_vector(signed(A) + signed(B));  -- ADDI
            when "0110" => result <= std_logic_vector(shift_left(unsigned(A), to_integer(unsigned(B(3 downto 0)))));  -- SLL
				when "0111" => result <= std_logic_vector(resize(unsigned(A) + resize((2*unsigned(B)),16),16));
            when others => result <= A;  -- Default case
        end case;
    end process;
     
    C <= result;
    z_flag <= '1' when result = "0000000000000000" else '0';
     
end architecture Struct;