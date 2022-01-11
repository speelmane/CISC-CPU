library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;

entity gpio is
    generic (N : natural range 0 to 31 := 16);
  port (
    clk, reset : IN std_logic := '0';
    Din : IN std_logic_vector(N - 1 downto 0);
    Dout : OUT std_logic_vector (N -1 downto 0);
    IEn, OEn : IN std_logic := '1'
  ) ;
end entity ; 

architecture rtl of gpio is
    signal ff_in, ff_out, dout_sig : std_logic_vector(N - 1 downto 0);

    begin
    ff_in <= Din when (IEn = '1') else
             dout_sig;


    dout_sig <= ff_out when (OEn = '1') else
            (others => 'Z');

    Dout <= (others => '0') when (reset = '1') else
            dout_sig; 
            
process(clk)
    begin
        if(rising_edge(clk)) then
            ff_out <= ff_in;
        end if;
     end process;
end architecture ;