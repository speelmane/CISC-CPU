library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity datapath is
	generic (
				N : natural := 16;
				M : natural := 3
				);
	port (
				-- clk and reset
				reset : IN std_logic := '0';
				clk : IN std_logic := '1';

				--inputs
				offset : IN std_logic_vector(11 downto 0) := (others => '0');
				bypass : IN std_logic_vector(1 downto 0) := "00";					--default no bypass
				inputData : IN std_logic_vector (N -1 downto 0) := (others => '0');

				-- addresses
				WAddr : IN std_logic_vector (M -1 downto 0) := (others => '0');
				RA : IN std_logic_vector(M-1 downto 0) := (others => '0');
				RB : IN std_logic_vector(M-1 downto 0) := (others => '0');

				-- input enables
				WriteEn : IN std_logic := '0';
				ReadAEn : IN std_logic := '0';
				ReadBEn : IN std_logic := '0';
				IE : IN std_logic := '0'; --input enable
				OE : IN std_logic := '0'; --output enable

				-- ADDITIONS !!!!!!
				--to enable latch flags and address and data output enables
				flag_en, DataOutEn, AddrEn: IN std_logic := '0';

				--outputs
				DataOut : OUT std_logic_vector (N -1 downto 0);
				Addr : OUT std_logic_vector (N -1 downto 0);

				-- END OF ADDITIONS !!!!

				z_flag, n_flag, o_flag : OUT std_logic ;

				--alu specific matters
				op : IN std_logic_vector(2 downto 0) := "000"; --for the sum default operation
        		en : IN std_logic := '1' --alu enable by default
				
	);
	
end entity;

architecture rtl of datapath is
--register file material
signal data_input : std_logic_vector (N -1 downto 0) := (others => '0');
signal data_output : std_logic_vector (N -1 downto 0) := (others => '0');

signal offset_se : std_logic_vector (N -1 downto 0) := (others => '0');

signal AluDataOut : std_logic_vector (N -1 downto 0) := (others => '0');


-- intermediates for MUXing
signal QA : std_logic_vector (N -1 downto 0) := (others => '0');
signal rf_B_output, alu_B_input : std_logic_vector (N -1 downto 0) := (others => '0');
signal ReadAEn_input : std_logic;
signal RA_input : std_logic_vector (M -1 downto 0);

-- intermediate flags
signal z_out_flag, n_out_flag, o_out_flag : std_logic := '0';

begin

	FR: entity work.filereg
	generic map(N => N, M => M)
	port map (
		WD => data_input,
		WAddr => WAddr,
		WriteEn => WriteEn,
		RA => RA_input,
		ReadAEn => ReadAEn_input,
		RB => RB,
		ReadBEn => ReadBEn,
		QA => QA,
		QB => rf_B_output,
		reset => reset,
		clk => clk
		);
	
	ALU: entity work.alu_fr
	generic map(Nbits => N)
	port map(
		a => QA,
		b => alu_B_input,
		op => op,
		en => en,
		reset => reset,
		y => AluDataOut,
		z => z_out_flag,
		n => n_out_flag,
		o => o_out_flag
		);





	SE12 : entity work.sign_extender_12_16
	generic map (N => N)
	port map (
		input => offset,
		output => offset_se
	);
		
		

	data_output <= AluDataOut when (OE = '1') else
			 (others => 'Z');
			 
	data_input <= inputData when (IE = '1') else
				  AluDataOut;
	

	--bypass B = forwarding offset to input A
	alu_B_input <= rf_B_output when (bypass(1) = '0') else
				   offset_se; 

	-- bypass B = force setting read address to the last register and enabling the read enable
	RA_input <= RA when (bypass(0) = '0') else
				"111";

	ReadAEn_input <= ReadAEn when (bypass(0) = '0') else
					 '1';
	

	process(clk, reset)
	begin

		if (reset = '1') then
			Addr <= (others => '0');
			DataOut <= (others => '0');
			z_flag <= '0';
			o_flag <= '0';
			n_flag <= '0';
	
		elsif(rising_edge(clk)) then

			-- latch flags
			if (flag_en = '1') then
			z_flag <= z_out_flag;
			n_flag <= n_out_flag;
			o_flag <= o_out_flag;
			end if;
			
			-- latch data_output to Memory Data Output reg
			if(DataOutEn = '1') then
				DataOut <= data_output;
			end if;

			-- latch data_output to Memory Address reg
			if(AddrEn = '1') then
				Addr <= data_output;
			end if;



		end if;
	end process;
		
end architecture;