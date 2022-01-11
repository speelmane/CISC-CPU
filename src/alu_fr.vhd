--libraries
library IEEE;

--package uses
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;
use work.uP_package.all;

entity alu_fr is
	generic(Nbits : positive := 16);
	port(
		-- clk and reset
		reset : IN std_logic;
		--inputs
		a : IN std_logic_vector(Nbits - 1 downto 0) := (others => '0');
		b : IN std_logic_vector(Nbits -1 downto 0):= (others => '0');
		--alu enable and opcode
		en : IN std_logic;
		op : IN std_logic_vector (2 downto 0) := (others => '0');
		--output
		y : OUT std_logic_vector (Nbits - 1 downto 0);
		--flags
		z : OUT std_logic := '0';
		n : OUT std_logic := '0';
		o : OUT std_logic := '0'
		);
end entity;

architecture rtl of alu_fr is
signal output : std_logic_vector (Nbits-1 downto 0);

begin

	--concurrent value updates
	output  <= std_logic_vector(signed(a) + signed(b)) when op = opSUM 
			else std_logic_vector(signed(a) - signed(b)) when op = opSUB
			else a and b when op = opAND
			else a or b when op = opOR
			else a xor b when op = opXOR
			else not a when op = opNOT
			else a when op = opA
			else std_logic_vector(signed(a) + 1); -- PC at A + 1
			
	z <= '0' when reset = '1' else not (or_reduce(output));
		
	n <= '0' when reset = '1' else output(Nbits-1);
		
	--update with xor ops
	o <= '0' when (reset = '1') else

			'1' when ((op = opSUM) and ((a(Nbits - 1) = '1' and (b(Nbits - 1)) = '1' and output(Nbits - 1) = '0') or (a(Nbits - 1) = '0' and (b(Nbits - 1)) = '0' and output(Nbits - 1) = '1'))) else
			
			'1' when ((op = opSUB) and ((a(Nbits - 1) = '1' and (b(Nbits - 1)) = '0' and output(Nbits - 1) = '0') or (a(Nbits - 1) = '0' and (b(Nbits - 1)) = '1' and output(Nbits - 1) = '1'))) else
				
			'1' when ((op = opINC) and (a(Nbits - 1) = '0'  and output(Nbits - 1) = '1')) else
			
			'0';

	y <= (others => '0') when (reset = '1') else output;

end architecture;