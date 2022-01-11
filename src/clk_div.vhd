library ieee ;
    use ieee.std_logic_1164.all ;

entity clk_div is
    generic (
        COUNTER_MAX : natural := 400000
    );
    port (
        clk : IN std_logic;
        clk_divd : OUT std_logic
    ) ;
end clk_div ; 

architecture rtl of clk_div is

signal tmp : std_logic := '0';
signal clk_count: integer := 0;

begin
    --clock divider		
	process(clk)
    begin
    if(rising_edge(clk)) then
        clk_count <= clk_count+1;
        if (clk_count = COUNTER_MAX) then
            tmp <= NOT tmp;
            clk_count <= 0;
        end if;
    end if;
    clk_divd <= tmp;
end process;

end architecture ;