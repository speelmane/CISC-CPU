library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity computer is
    generic (N : natural := 16; M : natural := 3);
  port (
    clk, reset, IEn, OEn : IN std_logic := '0';
    led_out : OUT std_logic_vector(N - 1  downto 0) := (others => '0');
	clk_led : OUT std_logic
  ) ;
end entity; 


architecture rtl of computer is
    signal addressCPU : STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
	  signal addressRAM : std_logic_vector (7 DOWNTO 0);
    signal DinCPU, DoutCPU : std_logic_vector(N - 1 downto 0);
    signal R_nW : std_logic := '1';
    signal cpu_clk : std_logic;

begin

	clk_led <= cpu_clk;
   addressRAM <= addressCPU(7 downto 0);
	
   	--IMPORTANT! IF SLOWER CLOCK IS NEEDED, THE PORTS CONNECT TO cpu_clk RATHER THAN clk SIGNAL!!!!!!!!!!!!!!!!!!!!!!!!
	--CURRENT IMPLEMENTATION: normal clk
	CLK_DIV: entity work.CLK_DIV
	port map(
		clk => clk,
		clk_divd => cpu_clk
		);

    CPU:entity work.cpu
    generic map(N=>16,M=>3)
    port map(clk => cpu_clk,
             reset => reset,
             Din => DinCPU, --ch
             Addr => addressCPU, --ch
             Dout => DoutCPU, --ch
             R_nW => R_nW); --ch

    RAM : entity work.ram_memory
    port map(
		address	=> addressRAM,
		clock => cpu_clk,
		data => DoutCPU,
		wren => "not"(R_nW),
		q => DinCPU
	);

    GPIO : entity work.gpio
    generic map(N => 16)
    port map(
        clk => cpu_clk,
        reset => reset,
        --Din => DoutCPU,
        Din => addressCPU,
        Dout => led_out,
        IEn => IEn,
        OEn => OEn
    );

end architecture ;