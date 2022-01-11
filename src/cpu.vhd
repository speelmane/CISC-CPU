library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cpu is
	generic (
				N : natural := 16;
				M : natural := 3
				);
	port (
			-- clk and reset
			clk, reset : IN std_logic;
			-- Data in
			Din : IN std_logic_vector(N-1 downto 0);
			Addr : OUT std_logic_vector(N-1 downto 0); --maybe M?
			Dout : OUT std_logic_vector(N-1 downto 0);
			--enable to external memory
			R_nW : OUT std_logic := '1' 				
	);
	
end entity;

architecture rtl of cpu is

--register file material
signal z_flag, n_flag, o_flag : std_logic;

-- datapath addresses
signal WA : std_logic_vector(M -1 downto 0) := (others => '0');
signal RA : std_logic_vector(M -1 downto 0) := (others => '0');
signal RB : std_logic_vector(M - 1 downto 0) := (others => '0');
signal offset : std_logic_vector(11 downto 0) := (others => '0');
signal bypass : std_logic_vector(1 downto 0) := "00";          --MSB - bypass to B, LSB - force PC

-- datapath enables
signal WAen : std_logic := '0';
signal RAen : std_logic := '0';
signal RBen : std_logic := '0';
signal IE : std_logic := '0';
signal OE : std_logic := '0';
signal FlagEn : std_logic := '0';
signal DataEn : std_logic := '0';
signal AddrEn : std_logic := '0';

--alu specific matters
signal op : std_logic_vector(2 downto 0) := "000";                 --for the sum default operation
signal AluEn: std_logic := '1';   

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
signal cpu_clk : std_logic; --derived clock via the divider 


begin

	ROM: entity work.rom
	port map (
		-- clk and reset
		clk => clk,
		reset => reset,
		-- Data in
		Din => Din,
		z_flag => z_flag,
		n_flag => n_flag,
		o_flag => o_flag,

		-- datapath addresses
		WA => WA,
		RA => RA,
		RB => RB,
		offset => offset,
		bypass => bypass,
		--MSB - bypass to B, LSB - force PC

		-- datapath enables
		WAen => WAen,
		RAen => RAen,
		RBen => RBen,
		IE => IE,
		OE => OE,
		FlagEn => FlagEn,
		DataEn => DataEn,
		AddrEn => AddrEn,

		--enable to external memory
		R_nW => R_nW,

		--alu specific matters
		op => op,              
		AluEn => AluEn     
		);
	
	DATAPATH: entity work.datapath
	generic map(N => N, M => M)
	port map(
		-- clk and reset
		reset => reset,
		clk => clk,

		--inputs
		offset => offset,
		bypass => bypass,				--default no bypass
		inputData => Din,

		-- addresses
		WAddr => WA,
		RA => RA,
		RB => RB,

		-- input enables
		WriteEn => WAEn,
		ReadAEn => RAEn,
		ReadBEn => RBEn,
		IE => IE,
		OE => OE,

		flag_en => FlagEn,
		DataOutEn => DataEn,
		AddrEn => AddrEn,

		--outputs
		DataOut => Dout,
		Addr => Addr,

		--flags
		z_flag => z_flag,
		n_flag => n_flag,
		o_flag => o_flag,

		--alu specific matters
		op => op,
		en => AluEn		
		);


		
end architecture;