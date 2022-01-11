library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sign_extender_9_12 is
    Port ( input : in  STD_LOGIC_VECTOR (8 downto 0);
           output : out  STD_LOGIC_VECTOR (11 downto 0));
end entity;

architecture rtl of sign_extender_9_12 is
begin

    process (input)
	begin
		output (11 downto 9) <= (others => input(8));
		output (8 downto 0) <= input; 
	end process;
end architecture;