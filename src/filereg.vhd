library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity filereg is
generic(N : natural := 4;
		  M : natural := 2
		  );
port(WD : IN std_logic_vector (N-1 downto 0) := (others => '0');
	  WAddr : IN std_logic_vector (M-1 downto 0) := (others => '0');
	  WriteEn : IN std_logic := '0';
	  RA : IN std_logic_vector (M-1 downto 0) := (others => '0');
	  ReadAEn : IN std_logic := '0';
	  RB : IN std_logic_vector (M-1 downto 0) := (others => '0');
	  ReadBEn : IN std_logic := '0';
	  QA : OUT std_logic_vector (N-1 downto 0) := (others => '0');
	  QB : OUT std_logic_vector (N-1 downto 0) := (others => '0');
	  reset : IN  std_logic := '0';
	  clk : IN std_logic
);
end entity;

architecture rtl of filereg is
  type registerFile is array(0 to 2**(M)-1) of std_logic_vector(N-1 downto 0); --M registers each of N bits (2^M addresses)
  signal registers : registerFile := (others => (others => '0'));  
begin

	WR : process(clk, reset)
	begin
	if(reset = '1') then
	registers <= (others => (others => '0')); 
	
	elsif (rising_edge(clk)) then
	
		if (WriteEn = '1') then
		registers(to_integer(unsigned(WAddr))) <= WD;
		end if;
	
	end if;
	end process;
	
	QA <= registers(to_integer(unsigned(RA))) when (ReadAEn = '1') else (others => '0');
	QB <= registers(to_integer(unsigned(RB))) when (ReadBEn = '1') else (others => '0');
		
end architecture;