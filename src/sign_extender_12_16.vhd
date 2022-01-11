library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sign_extender_12_16 is
	generic (N : natural := 16);
    port ( input : in  STD_LOGIC_VECTOR (11 downto 0);
           output : out  STD_LOGIC_VECTOR ( N -1  downto 0));
end entity;

architecture rtl of sign_extender_12_16 is
begin

    process (input)
	begin
		output (N - 1 downto 12) <= (others => input(11));
		output (11 downto 0) <= input; 
	end process;
end architecture;