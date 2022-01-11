library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uP_package.all;


entity rom is
  port (
    -- clks and resets
    clk, reset : IN std_logic;

    -- Data in
    Din : IN std_logic_vector(15 downto 0);
    z_flag, n_flag, o_flag : IN std_logic;

    -- datapath addresses
    WA : OUT std_logic_vector(2 downto 0) := (others => '0');
    RA : OUT std_logic_vector(2 downto 0) := (others => '0');
    RB : OUT std_logic_vector(2 downto 0) := (others => '0');
    offset : OUT std_logic_vector(11 downto 0) := (others => '0');
    bypass : OUT std_logic_vector(1 downto 0) := "00";          --MSB - bypass to B, LSB - force PC

    -- datapath enables
    WAen : OUT std_logic := '0';
    RAen : OUT std_logic := '0';
    RBen : OUT std_logic := '0';
    IE : OUT std_logic := '0';
    OE : OUT std_logic := '0';
    FlagEn : OUT std_logic := '0';
    DataEn : OUT std_logic := '0';
    AddrEn : OUT std_logic := '0';
    

    --enable to external memory
    R_nW : OUT std_logic := '1';

    --alu specific matters
    op : OUT std_logic_vector(2 downto 0) := "000";                 --for the sum default operation
    AluEn: OUT std_logic := '1'                       			    --alu enabled by default

  ) ;
end rom ; 

architecture rtl of rom is
    --state defines
    signal pres_state, next_state : uPC_state_type := uPC0;

    signal pres_substate, next_substate : uPC_substate_type := S_BASIC;

    signal operation : std_logic_vector(3 downto 0) := (others => '0');
    signal operand_1, operand_2, operand_3 : std_logic_vector(2 downto 0) := (others => '0');
    signal data_field : std_logic_vector(11 downto 0) := (others => '0');
    signal offset_se : std_logic_vector(11 downto 0) := (others => '0');

begin
    -- sets the offset according to
    SE9 : entity work.sign_extender_9_12
	port map (
		input => data_field(8 downto 0),
		output => offset_se
	);

    --concurrent material
    offset <= offset_se when (operation = iLDI) else
              data_field;

    --output updates only upon uPC state change
out_logic:  process (pres_state)
                begin

                next_state <= pres_state; 
                next_substate <= pres_substate; 
                
                WA <= (others => '0');
                RA <= (others => '0');
                RB <= (others => '0');

                op <= (others => '0');
                WAEn <= '0';
                RAEn <= '0';
                RBEn <= '0';

                AddrEn <= '0';
                DataEn <= '0';
                FlagEn <= '0';
                AluEn <= '1'; 

                IE <= '0';
                OE <= '1';
                R_nW <= '1';

                bypass <= "00";
                               
                case pres_state is
                    -- LATCHING THE INSTRUCTION AND DECODING IT
                    when uPC1 =>
                       --assign all operators to what could be the possible operands
						
                        -- state defaults
                        RAEn <= '1';
                        RBEn <= '1';
                        WAEn <= '1';

                        case operation is
                            when iADD =>
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;

                                FlagEn <= '1';
                                op <= opSUM;
                                next_substate <= S_PCinc;


                            when iSUB => 
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;

                                --set substate
                                FlagEn <= '1';
                                op <= opSUB;
                                next_substate <= S_PCinc;


                            when iAND =>
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;
        
                                FlagEn <= '1';
                                op <= opAND;
                                next_substate <= S_PCinc;

                            when iOR => 
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;

                                FlagEn <= '1';
                                op <= opOR;
                                next_substate <= S_PCinc;

                            when iXOR =>
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;

                                FlagEn <= '1';
                                op <= opXOR;
                                next_substate <= S_PCinc;

                            when iNOT => 
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;

                                FlagEn <= '1';
                                op <= opNOT;
                                next_substate <= S_PCinc;

                            when iMOV =>
                                --write to op reg
                                WA <= operand_1;
                                RA <= operand_2;
                                RB <= operand_3;

                                FlagEn <= '1';
                                op <= opA;    
                                next_substate <= S_PCinc;
                                
                            when iNOP => 
                                --literally do nothing
                                WAEn <= '0';
                                next_substate <= S_PCinc;

                            when iLD =>
                                --write to address the read register
                                WA <= operand_1;
                                RA <= operand_2;

                                WAEn <= '0'; --disable writing to regs
                                AddrEn <= '1';

                                op <= opA;
                                next_substate <= S_PCinc;

                            when iST => 
                                --write data to data latch
                                RA <= operand_2;

                                WAEn <= '0'; -- disable writing to regs
                                DataEn <= '1'; -- write the alu data to the data ff
                            
                                op <= opA;
                                next_substate <= S_PCinc;

                            when iLDI => 
                                -- offset passing in the input
                                WA <= operand_1;

                                bypass <= "10"; 
                                RAEn <= '0'; --dont read the A input, default to 0!!!!!

                                op <= opSUM;

                                next_substate <= S_PCinc;

                            when iNU => 
                                --literally do nothing
                                WAEn <= '0'; --disable the write
                                next_substate <= S_PCinc;
                            
                            when iBRZ =>

                                if(z_flag = '1') then
                                    --offset + pc
                                    bypass <= "11";
                                    op <= opSUM;
                                else
                                    -- pc + 1
                                    bypass <= "01";
                                    op <= opINC;
                                end if;

                                --set addresses of read and write
                                WA <= (others => '1'); --write to the pc reg
                                WAEn <= '1';
                                AddrEn <= '1';
                        
                                --set substate
                                next_substate <= S_PC;

                            when iBRN => 

                                if(n_flag = '1') then
                                    --offset + pc
                                    bypass <= "11";
                                    op <= opSUM;
                                else
                                    -- pc + 1
                                    bypass <= "01";
                                    op <= opINC;
                                end if;
                                --set addresses of read and write
                                WA <= (others => '1'); --write to the pc reg
                                WAEn <= '1';
                                AddrEn <= '1';
                                --set substate
                                next_substate <= S_PC;
                                                     
                            when iBRO =>

                                if(o_flag = '1') then
                                    --offset + pc
                                    bypass <= "11";
                                    op <= opSUM;
                                else
                                    -- pc + 1
                                    bypass <= "01";
                                    op <= opINC;
                                end if;
                                --set addresses of read and write
                                WA <= (others => '1'); --write to the pc reg
                                WAEn <= '1';
                                AddrEn <= '1';

                                --set substate
                                next_substate <= S_PC;

                            when iBRA => 
                            
                                --offset + pc
                                bypass <= "11";
                                op <= opSUM;
                      
                                --set addresses of read and write
                                WA <= (others => '1'); --write to the pc reg
                                WAEn <= '1';
                                AddrEn <= '1';
                        
                                --set substate
                                next_substate <= S_PC; 
                                
                          when others =>
                          
                                --do nothing                  
                                        
                        end case;

                        -- always transition to uPC2 state
                        next_state <= uPC2;

                    -- PERFORMING THE OUTPUT UPDATE, SETTING THE WRITE ENABLES
                    when uPC2 =>

                        case pres_substate is

                            -- important substate state specifics
                            when S_PC =>

                                WAEn <= '0';
                                AddrEn <= '0';
                                DataEn <= '0';
                              --basically do nothing

                            when S_PCinc =>
                                --increment for all
                                WA <= (others => '1');
                                WAEn <= '1';
                                bypass <= "01"; --force PC at read
                                op <= opINC; --inc
                                AddrEn <= '1';

                            when others =>

                                WAEn <= '0';

                        end case;
                        
                        -- set next substate
                        if (operation = iLD) then
                            next_substate <= S_LD;
                        elsif  (operation = iST) then
                            next_substate <= S_ST;
                        else next_substate <= S_NOP;
                        end if;

                        --set state
                        next_state <= uPC3;


                    when uPC3 =>

                        WAEn <= '0'; 
                               
                        case pres_substate is
                            when S_NOP =>

                                AddrEn <= '0';
                                DataEn <= '0';
        
                            when S_ST =>
                                --write address to the ff (write to the mem in the uPC0)
                                RA <= operand_1;
                                RAEn <= '1';
                                AddrEn <= '1';
                                op <= opA;


                            when S_LD =>

                                --write the stuff from the memory to the regs
                                IE <= '1';
                                WA <= operand_1;
                                WAEn <= '1';  
      
                            when others =>
                                WAEn <= '0';
                            
                        end case;

                        --!!! no change to the substates                       

    
                        next_state <= uPC0;

                    -- get ready for the inputs
                    when uPC0 =>

						next_substate <= S_BASIC;
                        
                        next_state <= uPC1;

                        if(operation = iST) then
                            --read/not write is latched
                            R_nW <= '0';
                        end if;

                    when others =>
                            -- keep it
                end case;
            
    end process;


 

regs: process(clk,reset)
        begin
            if (reset= '1') then
                --asynchronous reset
                pres_state <= uPC0;
                pres_substate <= S_BASIC;
                --pres_state <= do nothing for now
            elsif (rising_edge(clk)) then
                --fetch the instruction
                if (pres_state <= uPC0) then --Instruction register enable
                    operation <= Din(15 downto 12); --getting the first 4 bits of the Din
                    data_field <= Din(11 downto 0); --the rest are in the data_field
                    operand_1 <= Din(11 downto 9);
                    operand_2 <= Din(8 downto 6);
                    operand_3 <= Din(5 downto 3);
                end if;

                pres_state <= next_state;
                pres_substate <= next_substate;

            end if;
        end process;


end architecture ;