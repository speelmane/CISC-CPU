library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
    
    library modelsim_lib;
use modelsim_lib.util.all;  

entity test_comp is
end entity; 

architecture test of test_comp is
    signal clock, reset, IEn, OEn, clk_led : std_logic := '0';
    signal address : std_logic_vector(15 downto 0);
    type rf_type is array(0 to 7) of std_logic_vector(15 downto 0);
    signal rf_mem : rf_type;
    type ram_mem_type is array(0 to 255) of std_logic_vector(15 downto 0);
    signal ram_mem : ram_mem_type;
    signal t_z,t_n,t_o, r_nW:std_logic;
    signal t_uPC : std_logic_vector(1 downto 0);

    

begin
     -- Clock and reset generation
   clock<=not(clock) after 10 ns;


SPY_PROC: process
    begin

        init_signal_spy("/dut/cpu/datapath/fr/registers","/rf_mem",1);
        init_signal_spy("/dut/RAM/RAM","/ram_mem",1);
        init_signal_spy("/dut/cpu/z_flag","/t_z",1);
       init_signal_spy("/dut/cpu/n_flag","/t_n",1);
       init_signal_spy("/dut/cpu/o_flag","/t_o",1);
       init_signal_spy("/dut/cpu/R_nW","/r_nW",1);
       init_signal_spy("/dut/cpu/ROM/pres_state","/t_uPC" ,1);




        wait;
    end process;

DUT:   entity work.computer
    port map(
    clk => clock, 
    reset => reset,
    IEn => IEn,
    OEn =>  OEn,
    led_out => address,
	   clk_led => clk_led
  ) ;

  process
  begin
    IEn <= '1';
    OEn <= '1';
    reset <= '0';
    wait;
    end process;
    
end architecture ;