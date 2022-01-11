LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;

use work.uP_package.all;

ENTITY ram_memory IS
 	PORT
 	(
 		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
 		clock		: IN STD_LOGIC  := '1';
 		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
 		wren		: IN STD_LOGIC ;
 		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
 	);
 END ram_memory;

-- architecture fake of ram_memory is

-- 	signal RAM:program :=(
-- 		(iLDI & R5 & B"1_0000_0000"),
-- 		(iADD & R5 & R5 & R5 & Tail3),
-- 		(iADD & R5 & R5 & R5 & Tail3),
-- 		(iADD & R5 & R5 & R5 & Tail3),
-- 		(iADD & R5 & R5 & R5 & Tail3),
-- 		(iLDI & R6 & B"0_0010_0000"),
-- 		(iLDI & R3 & B"0_0000_0011"),
-- 		(iST & R6 & R3 & Tail3 & Tail3),
-- 		(iLDI & R1 & B"0_0000_0001"),
-- 		(iLDI & R0 & B"0_0000_1110"),
-- 		(iMOV & R2 & R0 & Tail3 & Tail3),
-- 		(iADD & R2 & R2 & R1 & Tail3),
-- 		(iSUB & R0 & R0 & R1 & Tail3),
-- 		(iBRZ & X"003"),
-- 		(iNOP & Tail3 & Tail3 & Tail3 & Tail3),
-- 		(iBRA & X"FFC"),
-- 		(iST & R6 & R2 & Tail3 & Tail3),
-- 		(iST & R5 & R2 & Tail3 & Tail3),
-- 		(iBRA & X"000"),
-- 		(iNOP & Tail3 & Tail3 & Tail3 & Tail3),
-- 		(iNOP & Tail3 & Tail3 & Tail3 & Tail3),
-- 		others=>(iNOP & R0 & R0 & R0 & Tail3));

-- 		signal wren_out : std_logic;

-- 	begin


-- 		process(clock)
-- 			begin
-- 			if (rising_edge(clock)  and wren_out = '1') then
-- 				RAM(to_integer(unsigned(address))) <= data;
-- 			end if;
-- 			if (rising_edge(clock)) then
-- 				wren_out <= wren;
-- 				q <= RAM(to_integer(unsigned(address)));
-- 			end if;
-- 		end process;

-- 	end architecture;

ARCHITECTURE SYN OF ram_memory IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (15 DOWNTO 0);



	COMPONENT altsyncram
	GENERIC (
		clock_enable_input_a		: STRING;
		clock_enable_output_a		: STRING;
		init_file		: STRING;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		numwords_a		: NATURAL;
		operation_mode		: STRING;
		outdata_aclr_a		: STRING;
		outdata_reg_a		: STRING;
		power_up_uninitialized		: STRING;
		widthad_a		: NATURAL;
		width_a		: NATURAL;
		width_byteena_a		: NATURAL
	);
	PORT (
			address_a	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			clock0	: IN STD_LOGIC ;
			data_a	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren_a	: IN STD_LOGIC ;
			q_a	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	q    <= sub_wire0(15 DOWNTO 0);

	altsyncram_component : altsyncram
	GENERIC MAP (
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "memory.mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 256,
		operation_mode => "SINGLE_PORT",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		power_up_uninitialized => "FALSE",
		widthad_a => 8,
		width_a => 16,
		width_byteena_a => 1
	)
	PORT MAP (
		address_a => address,
		clock0 => clock,
		data_a => data,
		wren_a => wren,
		q_a => sub_wire0
	);



END SYN;



-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
-- Retrieval info: PRIVATE: AclrAddr NUMERIC "0"
-- Retrieval info: PRIVATE: AclrByte NUMERIC "0"
-- Retrieval info: PRIVATE: AclrData NUMERIC "0"
-- Retrieval info: PRIVATE: AclrOutput NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_ENABLE NUMERIC "0"
-- Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "0"
-- Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0"
-- Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0"
-- Retrieval info: PRIVATE: Clken NUMERIC "0"
-- Retrieval info: PRIVATE: DataBusSeparated NUMERIC "1"
-- Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0"
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
-- Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone II"
-- Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
-- Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
-- Retrieval info: PRIVATE: MIFfilename STRING "memory.mif"
-- Retrieval info: PRIVATE: NUMWORDS_A NUMERIC "256"
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
-- Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_PORT_A NUMERIC "3"
-- Retrieval info: PRIVATE: RegAddr NUMERIC "1"
-- Retrieval info: PRIVATE: RegData NUMERIC "1"
-- Retrieval info: PRIVATE: RegOutput NUMERIC "0"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
-- Retrieval info: PRIVATE: SingleClock NUMERIC "1"
-- Retrieval info: PRIVATE: UseDQRAM NUMERIC "1"
-- Retrieval info: PRIVATE: WRCONTROL_ACLR_A NUMERIC "0"
-- Retrieval info: PRIVATE: WidthAddr NUMERIC "8"
-- Retrieval info: PRIVATE: WidthData NUMERIC "16"
-- Retrieval info: PRIVATE: rden NUMERIC "0"
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_A STRING "BYPASS"
-- Retrieval info: CONSTANT: CLOCK_ENABLE_OUTPUT_A STRING "BYPASS"
-- Retrieval info: CONSTANT: INIT_FILE STRING "memory.mif"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone II"
-- Retrieval info: CONSTANT: LPM_HINT STRING "ENABLE_RUNTIME_MOD=NO"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
-- Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "256"
-- Retrieval info: CONSTANT: OPERATION_MODE STRING "SINGLE_PORT"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "NONE"
-- Retrieval info: CONSTANT: OUTDATA_REG_A STRING "UNREGISTERED"
-- Retrieval info: CONSTANT: POWER_UP_UNINITIALIZED STRING "FALSE"
-- Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "8"
-- Retrieval info: CONSTANT: WIDTH_A NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
-- Retrieval info: USED_PORT: address 0 0 8 0 INPUT NODEFVAL "address[7..0]"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT VCC "clock"
-- Retrieval info: USED_PORT: data 0 0 16 0 INPUT NODEFVAL "data[15..0]"
-- Retrieval info: USED_PORT: q 0 0 16 0 OUTPUT NODEFVAL "q[15..0]"
-- Retrieval info: USED_PORT: wren 0 0 0 0 INPUT NODEFVAL "wren"
-- Retrieval info: CONNECT: @address_a 0 0 8 0 address 0 0 8 0
-- Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: @data_a 0 0 16 0 data 0 0 16 0
-- Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
-- Retrieval info: CONNECT: q 0 0 16 0 @q_a 0 0 16 0
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_memory.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_memory.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_memory.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_memory.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_memory_inst.vhd FALSE
-- Retrieval info: LIB_FILE: altera_mf
