library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

    
--libraries for files read/write
use ieee.std_logic_textio.all;
library std;
use std.textio.all;
    
Entity Register_Data_IF_TB IS END;
ARCHITECTURE Register_Data_IF_TB_arc of Register_Data_IF_TB is 
------DUT Component Declaration-------
Component Register_Data_IF IS 
Port(

	--Register_IF INPUTS--
	SCLK	: IN STD_LOGIC;
	RST	: IN STD_LOGIC;
	SDO	: IN STD_LOGIC; --FPGA to ASIC
	SCn	: IN STD_LOGIC;
	

	--DATA_IF INPUTS--
	SYNC 	: IN STD_LOGIC;
	ACLK 	: IN STD_LOGIC; --FPGA to ASIC
	D_START	: IN STD_LOGIC;
	DISCARD	: IN STD_LOGIC;
	

	--Register IF OUTPUT--
	SDI	: OUT STD_LOGIC; -- ASIC to FPGA

	--DATA IF OUTPUT--
	Operation_Mode_Initialized 	: OUT STD_LOGIC;
	Data_Out_en  			: OUT STD_LOGIC;	
	DATA1_OUT			: OUT STD_LOGIC;
	DATA2_OUT			: OUT STD_LOGIC

);

END component;

--State Machion Declearation--
TYPE state_type is (Idle, SPI_DATA_WR, SPI_DATA_READ, Update_ADDR ,clear_Wait,Calibration_process, Calibration_And_Read_Serial_Idles_Words_Without_Sync,Read_Serial_Idles_Words_Without_Sync, Read_Serial_Idles_Words_With_Sync,Read_Serial_Start_Words,Read_ASIC_data,Read_footer,Read_CRC);
------Signal Clks Declaration-------
SIGNAL CLK_COUNTER: STD_LOGIC_VECTOR(3 DOWNTO 0):=(OTHERS=>'0'); 
SIGNAL S_CLK_RATE: STD_LOGIC:='0';

------SIGNAL Declaration-------
SIGNAL S_SCLK: Std_logic:='0';
SIGNAL S_SDO : Std_logic:='0';--FPGA to ASIC (IN)
SIGNAL S_SCn : Std_logic:='1';
SIGNAL S_RST : Std_logic:='1';
SIGNAL S_SDI : Std_logic:='1';-- ASIC to FPGA

SIGNAL S_SYNC 	: STD_LOGIC:='0';
SIGNAL S_ACLK 	: STD_LOGIC; --FPGA to ASIC
SIGNAL S_D_START	: STD_LOGIC;
SIGNAL S_DISCARD	: STD_LOGIC;

SIGNAL S_Operation_Mode_Initialized: STD_LOGIC;
SIGNAL S_DATA1_OUT	: STD_LOGIC;
SIGNAL S_DATA2_OUT	: STD_LOGIC;

SIGNAL num_data_lines 	: STD_LOGIC:='0';
SIGNAL legacy_mode	: STD_LOGIC:='0';
SIGNAL data_word_length	: std_logic_vector (3 DOWNTO 0):=(OTHERS=>'0');


--Footer_disable--
SIGNAL Footer_disable	: std_logic_vector (5 DOWNTO 0):=(OTHERS=>'0');
--Showing serial data as vector--

SIGNAL Pres_Idle_Word_D1_Seial_In		: std_logic_vector (7 DOWNTO 0):=x"00";
SIGNAL Pres_Idle_Word_D2_Seial_In		: std_logic_vector (7 DOWNTO 0):=x"00";
SIGNAL Pres_Idle_Word_D1_As_Vec			: std_logic_vector (7 DOWNTO 0):=x"00";
SIGNAL Pres_Idle_Word_D2_As_Vec			: std_logic_vector (7 DOWNTO 0):=x"00";
SIGNAL Pres_Idle_Word_Bit_Counter		: Integer range 0 to 8:=0;
SIGNAL Local_Bit_Counter			: boolean :=false ;
SIGNAL Pres_Idles_Word_Counter			: Integer range -1 to 6:=0;
CONSTANT Max_Idle_Word_Amount 			: integer := 5;
SIGNAL Idles_Word_Completed			: boolean :=false ;


SIGNAL Data_word_length_bits_amount: Integer range 24 to 40:=32;


SIGNAL Pres_Start_Word			: std_logic_vector (39 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_Start_Word0_As_Vec		: std_logic_vector (14 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_Start_Word1_As_Vec		: std_logic_vector (14 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_Start_Word2_As_Vec		: std_logic_vector (9 DOWNTO 0):=(OTHERS=>'0');

SIGNAL Pres_Start_Word_Counter		: Integer range 0 to 40:=0;
--Declaration for default values--
SIGNAL TestsTypes_ver : Integer range 0 to 32:=0;--define the version of the test plan
SIGNAL Word_test_0007: std_logic_vector (15 DOWNTO 0):=x"0007";--CLOCK_CTRL Register
SIGNAL Word_test_0ad3: std_logic_vector (15 DOWNTO 0):=x"0ad3";--LVDS_START_WORD_0 Register
SIGNAL Word_test_2d50: std_logic_vector (15 DOWNTO 0):=x"2d50";--LVDS_CONFIG_1 Register, 2d51 - 2 LINES, 2d50 - 1 line
SIGNAL Word_test_0062: std_logic_vector (15 DOWNTO 0):=x"0062";--LVDS_CONFIG_2 Register
SIGNAL Word_test_0351: std_logic_vector (15 DOWNTO 0):=x"0351";--PADS_CONFIG_2 
SIGNAL Word_test_0000: std_logic_vector (15 DOWNTO 0):=x"0000";--PADS_CONFIG_3 (Start_delay, scrambler, footers)
--State Machion Signals declearation--
SIGNAL TB_Cur_state		: state_type;
SIGNAL TB_BIT_COUNTER		: Integer range 0 to 32:=0;
SIGNAL ADDR_Pointer		: std_logic_vector(15 DOWNTO 0):= x"000C"; -- starts at ADDR=000C
SIGNAL TB_BANK_BUFFER 		: std_logic_vector(31 DOWNTO 0):=(OTHERS=>'0'); --32 Bits that have the current 32 bit data
SIGNAL ADDR_ODD_TEST		: std_logic :='0';
SIGNAL DATA_ODD_TEST		: std_logic :='0';
SIGNAL IDLE_Wait		: INTEGER:=0; -- start to sEND the data to SPI, WHEN '1' => current state=END TO_SPI
SIGNAL Time_counter		: Integer range 0 to 32:=0;
SIGNAL SPI_READ_WR_STATUS 	: std_logic:='0'; --=0 Write. 1 = Read --This SIGNAL is for changing between read mode and write mode

---FOR Sampling_SPI_In process
SIGNAL Sampling_SDI_In 		: std_logic_vector(31 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Sampling_SDI_In_ADDR	: std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Sampling_SDI_In_Data	: std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Sampling_ADDR		: std_logic_vector(13 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Sampling_Data		: std_logic_vector(14 DOWNTO 0):=(OTHERS=>'0');
----
SIGNAL  ASIC_DATA_line_1 : std_logic_vector(39 DOWNTO 0):=(OTHERS=>'0');
SIGNAL  ASIC_DATA_line_2 : std_logic_vector(39 DOWNTO 0):=(OTHERS=>'0');
SIGNAL 	bit_Data_counter		: Integer range 0 to 40:=0;
SIGNAL 	Word_Data_counter		: Integer range 0 to 256:=0;
SIGNAL  Pres_ASIC_DATA_line_1_As_Vec: std_logic_vector(39 DOWNTO 0):=(OTHERS=>'0');
SIGNAL  Pres_ASIC_DATA_line_2_As_Vec: std_logic_vector(39 DOWNTO 0):=(OTHERS=>'0');

--The footer has the same length as the channel data word defined in bits <data_word_length>

SIGNAL LVDS_FOOTER_1_Completed : BOOLEAN:=False;
SIGNAL LVDS_FOOTER_2_Completed : BOOLEAN:=False;
SIGNAL LVDS_FOOTER_3_Completed : BOOLEAN:=False;
SIGNAL LVDS_FOOTER_4_Completed : BOOLEAN:=False;
SIGNAL LVDS_FOOTER_5_Completed : BOOLEAN:=False;
SIGNAL LVDS_FOOTER_6_Completed : BOOLEAN:=False;

SIGNAL LVDS_FOOTER_line1 : std_logic_vector(13 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_LVDS_FOOTER_line1 : std_logic_vector(13 DOWNTO 0):=(OTHERS=>'0');
SIGNAL LVDS_FOOTER_line2 : std_logic_vector(13 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_LVDS_FOOTER_line2 : std_logic_vector(13 DOWNTO 0):=(OTHERS=>'0');

---crc
SIGNAL CRC_line1 : std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');
SIGNAL CRC_line2 : std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_CRC_line1_As_Vec : std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');
SIGNAL Pres_CRC_line2_As_Vec : std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');

--text file read
SIGNAL S_Test_Plan_Data_From_File : STD_LOGIC_VECTOR (((2*6*16)-1) downto 0):=(OTHERS=>'0');-- 2 test types* 6 WORD, EACH WORD 16 BITS

--state machion declearation--
TYPE EN_state_type is (EN_OFF, EN_ON);

--Signals declearation--
SIGNAL EN_clk_counter : INTEGER RANGE 0 TO 4:=0; 
SIGNAL EN_PULSE : STD_LOGIC:='0'; 
SIGNAL EN_Cur_state_type: EN_state_type;
SIGNAL S_Clk_DIV: INTEGER RANGE 0 TO 4:=0;--Beeing used for changing clk rate value 


--State machine Declearation for calibration--
TYPE cal_state_type is (Offset_voltage_calibration,Linearity_calibration,Offset_Charge_calibration,Offset_current_calibration,Cal_done);
--Calibration State machine Signals declearation--
SIGNAL cal_Cur_state		:cal_state_type;
--signals for calibration
SIGNAL Word_test_0011: std_logic_vector (15 DOWNTO 0):=x"0011";--Offset_voltage_calibration
SIGNAL Word_test_0111: std_logic_vector (15 DOWNTO 0):=x"0111";--Linearity_calibration
SIGNAL Word_test_1011: std_logic_vector (15 DOWNTO 0):=x"1011";--Offset_Charge_calibration
SIGNAL Word_test_1111: std_logic_vector (15 DOWNTO 0):=x"1111";--Offset_current_calibration
--Calc procsses
SIGNAL RUN_CAL_PRO			: BOOLEAN:=False;
SIGNAL Cal_BIT_COUNTER			: Integer range -1 to 32:=0;
SIGNAL Cal_ADDR_Pointer		: std_logic_vector(15 DOWNTO 0):= x"000C"; -- starts at ADDR=000c
SIGNAL Cal_BANK_BUFFER 		: std_logic_vector(31 DOWNTO 0):=(OTHERS=>'0'); --32 Bits that have the current 32 bit data
SIGNAL Cal_Pulse_counter 		: std_logic_vector(32 DOWNTO 0):=(OTHERS=>'0'); --32 Bits that have the current 32 bit data
SIGNAL Cal_ADDR_ODD_TEST		: std_logic :='0';
SIGNAL Cal_DATA_ODD_TEST		: std_logic :='0';


BEGIN
DUT: Register_DATA_IF
Port map(
	--Register_IF INPUTS--
	SCLK	=>S_SCLK,
	RST	=>S_Rst,
	SDO	=>S_SDO,
	SCn	=>S_SCn,
	
	--DATA_IF INPUTS--
	SYNC 	=>S_SYNC,
	ACLK 	=>S_ACLK,
	D_START=>S_D_START,
	DISCARD=>S_DISCARD,
	
	--Register IF OUTPUT--
	SDI	=>S_SDI,	

	--DATA IF OUTPUT--
	Operation_Mode_Initialized=>s_Operation_Mode_Initialized,
	DATA1_OUT=>S_DATA1_OUT,
	DATA2_OUT=>S_DATA2_OUT	
	);

------SIGNAL Wave Creation-------
S_SCLK<=NOT S_SCLK AFTER 20 ns;
S_RST<='1', '0' AFTER 200 ns;-- reset test


SYNC_PRO: PROCESS 
BEGIN

	S_SYNC<='0';
	WAIT FOR 42300 ns;
	S_SYNC<='1';
	WAIT FOR 300 ns;
	S_SYNC<='0';
	WAIT FOR 0.5 ms;


END PROCESS;

P1: PROCESS(s_rst, s_sclk)
CONSTANT ADDR_initialization: std_logic_vector(15 DOWNTO 0):= x"000C";--this is the first addr
CONSTANT Clk_wait_val: integer :=5;
CONSTANT TestsTypes: integer :=2;--define how much test types will appear in the test bench, every type contains amount of TestsWords
CONSTANT TestsWords: integer :=6;--define the amount of words that may change as part of the test bench

VARIABLE ADDR_EVEN_TEST: std_logic :='0';
VARIABLE DATA_EVEN_TEST: std_logic :='0';

--Text file for different tests plans
--data files
FILE Fin_TestPlan: text open READ_MODE is "D:/Users/EugeneS/MODEL/TMCOR_Chess_V6tiles/src/models/AMS_V6Tile/test_plan.txt";
--FILE Fin_TestPlan: text is in "Test_plan.txt";
VARIABLE V_Test_Plan_Data_From_File : STD_LOGIC_VECTOR (((TestsTypes*TestsWords*16)-1) downto 0):=(OTHERS=>'0'); -- TestsTypes*6 word, 16 bits each word
VARIABLE current_read_Data : line ; -- read line from the file
VARIABLE current_read_field_Data : STD_LOGIC_VECTOR (((TestsTypes*TestsWords*16)-1) downto 0):=(OTHERS=>'0') ;--read from the read line, the same type as we would like to use
VARIABLE str_input_v                   : string( ((TestsTypes*TestsWords*16)-1) downto 1);

VARIABLE V_Test_Plan 	: INTEGER RANGE 0 TO ((TestsTypes*TestsWords*16)-1):=0;

--Calibraion variables
VARIABLE Cal_EVEN_TEST: std_logic :='0';
VARIABLE Cal_DATA_EVEN_TEST: std_logic :='0';
VARIABLE Cal_ADDR_EVEN_TEST: std_logic :='0';

BEGIN
	IF s_rst = '1'  THEN 
		--CONFIGURATION
		Word_test_0007<=x"0007";--CLOCK_CTRL Register, 320MHz 
		Word_test_0ad3<=x"0ad3";--LVDS_START_WORD_0 Register
		Word_test_2d50<=x"2d50";--LVDS_CONFIG_1 Register, 2d51 - 2 LINES, 2d50 - 1 line
		Word_test_0062<=x"0062";--LVDS_CONFIG_2 Register
		Word_test_0351<=x"0351";--PADS_CONFIG_2 
		Word_test_0000<=x"0000";--PADS_CONFIG_3 (Start_delay, scrambler, footers)
		TestsTypes_ver<=0;
		--
		Local_Bit_Counter<=false;	
		Pres_Idle_Word_Bit_Counter<=0;
		Pres_Start_Word_Counter	<=0;
		TB_BIT_COUNTER<=0;
		bit_Data_counter<=0;
		Word_Data_counter<=0;
		TB_BIT_COUNTER<=0;
		ADDR_Pointer <=ADDR_initialization;
		TB_BANK_BUFFER <=(OTHERS=>'0');
		IDLE_Wait<=0;
		ADDR_ODD_TEST<='0';	
		DATA_ODD_TEST<='0';	
		ADDR_EVEN_TEST:='0';  	-- set_odd_test to 0
		DATA_EVEN_TEST:='0';	-- set_odd_test to 0	
		Time_counter<=0;		
		SPI_READ_WR_STATUS<='0'; --starts the state machine from SPI_DATA_WRITE 
		
		S_SCN<='1';
		
		--footer reset
		Pres_LVDS_FOOTER_line1 <=(OTHERS=>'0');
		Pres_LVDS_FOOTER_line2 <=(OTHERS=>'0');
		--footer
		LVDS_FOOTER_1_Completed <=False;
		LVDS_FOOTER_2_Completed <=False;
		LVDS_FOOTER_3_Completed <=False;
		LVDS_FOOTER_4_Completed <=False;
		LVDS_FOOTER_5_Completed <=False;
		LVDS_FOOTER_6_Completed <=False;

		--calibration signals decleartion
		Cal_ADDR_Pointer<=x"0052";
		Cal_EVEN_TEST:='0';
		Cal_DATA_EVEN_TEST:='0';
		Cal_ADDR_EVEN_TEST:='0';
		Cal_BIT_COUNTER<=0;
		RUN_CAL_PRO<=FALSE;
		Cal_BANK_BUFFER<=(OTHERS=>'0');
		Cal_Pulse_counter<=(OTHERS=>'0');
		cal_Cur_state<=Offset_voltage_calibration;
--
		TB_Cur_state<=Idle;	
	ELSIF rising_edge(S_SCLK)  THEN 
	
	CASE TB_Cur_state IS
		WHEN Idle=>

		--read data from file : test plan
		--read file data, read file that contains xray data
			while (not endfile(Fin_TestPlan)) loop
				readline(Fin_TestPlan,current_read_Data);-- read line from the file
   				read(current_read_Data,current_read_field_Data(15 downto 0));--read from the txt line and put the info at the pleased type (vector (2..0))
    						
				S_Test_Plan_Data_From_File(   (  (V_Test_Plan*16)   +15) downto (V_Test_Plan*16)    )	<=current_read_field_Data(15 DOWNTO 0);
				V_Test_Plan_Data_From_File(((V_Test_Plan*(16))+15) downto (V_Test_Plan*(16)))	:=current_read_field_Data(15 DOWNTO 0);

				V_Test_Plan:=V_Test_Plan+1;					
			end loop;
 
			V_Test_Plan:=0;
			Local_Bit_Counter	<=false;
			--Define tests words (configuration)
			--Get data from file, the data may change according to TestsTypes and TestsWords
			Word_test_0007<=S_Test_Plan_Data_From_File(   ( 15+ TestsTypes_ver*TestsWords*16) downto (0 + TestsTypes_ver*TestsWords*16)     );--CLOCK_CTRL Register  	
			Word_test_0ad3<=S_Test_Plan_Data_From_File(   ( 31+ TestsTypes_ver*TestsWords*16) downto (16 + TestsTypes_ver*TestsWords*16)     );--LVDS_START_WORD_0 Register
			Word_test_2d50<=S_Test_Plan_Data_From_File(   ( 47+ TestsTypes_ver*TestsWords*16) downto (32 + TestsTypes_ver*TestsWords*16)    );--LVDS_CONFIG_1 Register, 2d51 - 2 LINES, 2d50 - 1 line
			Word_test_0062<=S_Test_Plan_Data_From_File(   ( 63+ TestsTypes_ver*TestsWords*16) downto (48 + TestsTypes_ver*TestsWords*16)    );--LVDS_CONFIG_2 Register
			Word_test_0351<=S_Test_Plan_Data_From_File(   ( 79+ TestsTypes_ver*TestsWords*16) downto (64+ TestsTypes_ver*TestsWords*16)    );--PADS_CONFIG_2 
			Word_test_0000<=S_Test_Plan_Data_From_File(   ( 95+ TestsTypes_ver*TestsWords*16) downto (80 + TestsTypes_ver*TestsWords*16)    );--PADS_CONFIG_3 (Start_delay, scrambler, footers)
		
			--Clear all counters:
			Pres_Start_Word_Counter	<=0;
			Pres_Idle_Word_Bit_Counter<=0;
			Time_counter<=0;
			bit_Data_counter<=0;
			Word_Data_counter<=0;
		
			TB_BIT_COUNTER<=0;	--clear_Wait bit counter
			Time_counter<=0;	
			ADDR_ODD_TEST<='0';  	
			DATA_ODD_TEST<='0';	
			ADDR_EVEN_TEST:='0';  	
			DATA_EVEN_TEST:='0';	
			SPI_READ_WR_STATUS<='0'; --starts the state machine from SPI_DATA_WRITE 
			TB_BANK_BUFFER <=(OTHERS=>'0');
			ADDR_Pointer <=ADDR_initialization;
			Pres_Idle_Word_Bit_Counter <= 0;

			IF IDLE_Wait<Clk_wait_val THEN --Only at the first time 
				IDLE_Wait<=IDLE_Wait+1;
			ELSE
				IDLE_Wait<=0;
				S_SCN<='0';
				
				IF SPI_READ_WR_STATUS='0' THEN --WRITE
					IF TestsTypes_ver = TestsTypes-1 THEN
						TestsTypes_ver<=0;
					ELSE
						TestsTypes_ver<=TestsTypes_ver+1;
					END IF;
			
					TB_Cur_state<=SPI_DATA_WR;

				ELSIF SPI_READ_WR_STATUS='1' THEN--READ
					IF TestsTypes_ver = TestsTypes-1 THEN
						TestsTypes_ver<=0;
					ELSE
						TestsTypes_ver<=TestsTypes_ver+1;
					END IF;
					TB_Cur_state<=SPI_DATA_READ;
				END IF;						
			END IF;

		

		WHEN SPI_DATA_WR=> --'0'

		-- At this state for 32 Clks
		-- Collecting 32 bits, 
		-- 1bit(R/W)13bit(ADDR)1bit(P),15bit(Data)1bit(P)
		-- Calculate and create ADDR and DATA ODD parity value
		
			Time_counter<=0;		
			S_SCN<='0';
					
			CASE TB_BIT_COUNTER IS

			WHEN 0 =>
			TB_BANK_BUFFER(TB_BIT_COUNTER)<='0';--'0' write
			S_SDO<='0';
			
			WHEN 1 TO 14=>--Address pointer 
			--TB_BANK_BUFFER = 32 bit - lsb = R/W, 14 addr...
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-1);
			S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-1);
			ADDR_EVEN_TEST:=ADDR_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-1);
			ADDR_ODD_TEST<=NOT(ADDR_EVEN_TEST);

			WHEN 15=>--Address parity test
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_ODD_TEST;
			S_SDO<=ADDR_ODD_TEST;

			WHEN 16 TO 29=>--Data - 14 LSB Bits are equals to ADDR
			CASE ADDR_Pointer IS
				
				WHEN x"0010"  =>	
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=word_test_0007(TB_BIT_COUNTER-16);
				S_SDO<=word_test_0007(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR word_test_0007(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

				WHEN x"0012"  =>	--LVDS_CONFIG_1 Register
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=word_test_2d50(TB_BIT_COUNTER-16);
				S_SDO<=word_test_2d50(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR word_test_2d50(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);
					CASE (TB_BIT_COUNTER-16) IS
						WHEN 0=>	num_data_lines<=word_test_2d50(TB_BIT_COUNTER-16);
						WHEN 1=>	legacy_mode<=word_test_2d50(TB_BIT_COUNTER-16);
						WHEN 2 to 5=>	data_word_length(TB_BIT_COUNTER-16-2)<=word_test_2d50(TB_BIT_COUNTER-16);
						WHEN 6=>
							
							Case Data_word_length IS
							--Number of Data's bits
							--According to Data_word_length vector value
							WHEN "0000" => Data_word_length_bits_amount<=24;
							WHEN "0001" => Data_word_length_bits_amount<=26;
							WHEN "0010" => Data_word_length_bits_amount<=28;
							WHEN "0011" => Data_word_length_bits_amount<=30;
							WHEN "0100" => Data_word_length_bits_amount<=32;--Default
							WHEN "0101" => Data_word_length_bits_amount<=34;
							WHEN "0110" => Data_word_length_bits_amount<=36;
							WHEN "0111" => Data_word_length_bits_amount<=38;
							WHEN "1000" => Data_word_length_bits_amount<=40;
							WHEN OTHERS => Data_word_length_bits_amount<=32;--Default
							END CASE;			

						WHEN OTHERS=>NULL;
					END CASE;				

				WHEN x"0013"  =>	
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=word_test_0ad3(TB_BIT_COUNTER-16);
				S_SDO<=word_test_0ad3(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR word_test_0ad3(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

				WHEN x"0016"  =>
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=word_test_0062(TB_BIT_COUNTER-16);
				S_SDO<=word_test_0062(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR word_test_0062(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

				WHEN x"0017"  =>--LVDS_CONFIG_3 Register, footer (10..5)
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=word_test_2d50(TB_BIT_COUNTER-16);
				S_SDO<=word_test_0000(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR word_test_2d50(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);
					CASE (TB_BIT_COUNTER-16) IS
						
						WHEN 5 =>	footer_disable(0)<=word_test_0000(TB_BIT_COUNTER-16);
						WHEN 6 =>	footer_disable(1)<=word_test_0000(TB_BIT_COUNTER-16);	
						WHEN 7 =>	footer_disable(2)<=word_test_0000(TB_BIT_COUNTER-16);
						WHEN 8 =>	footer_disable(3)<=word_test_0000(TB_BIT_COUNTER-16);	
						WHEN 9 =>	footer_disable(4)<=word_test_0000(TB_BIT_COUNTER-16);
						WHEN 10 =>	footer_disable(5)<=word_test_0000(TB_BIT_COUNTER-16);		

						WHEN OTHERS=>NULL;
					END CASE;
				
				WHEN OTHERS=>
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-16);
				S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

				END CASE;
			WHEN 30=>--Data: 1 MSB Bit 
			TB_BANK_BUFFER(TB_BIT_COUNTER)<='0';
			S_SDO<='0';
			
			WHEN 31=>--Data parity test
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=DATA_ODD_TEST;
			S_SDO<=DATA_ODD_TEST;
			Pres_Idle_Word_Bit_Counter <= 0;
			TB_Cur_state<=Update_ADDR;
						
			WHEN OTHERS=> 
			S_SCN<='1';
			TB_Cur_state<=Idle;

		END CASE;
 			TB_BIT_COUNTER<=TB_BIT_COUNTER+1;
		--Showing Idle words, update idle_word_counter
		IF S_operation_Mode_Initialized  = '1' AND S_SYNC = '0' THEN
			Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
			Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
			Pres_Idle_Word_Bit_Counter<=Pres_Idle_Word_Bit_Counter+1;
			
			IF Pres_Idle_Word_Bit_Counter = 0 THEN		
				Pres_Idle_Word_D1_As_Vec<=(OTHERS=>'0');
			
			ELSIF Pres_Idle_Word_Bit_Counter = 7 THEN
				Pres_Idle_Word_Bit_Counter <= 0;
				Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
				Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
				Pres_Idle_Word_D1_As_Vec<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;
			END IF;		

		ELSIF S_operation_Mode_Initialized  = '1' AND S_SYNC = '1' AND Idles_Word_Completed =False THEN 
			--This operation will count idle word for Max_Idle_Word_Amount times
			Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
			Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
			Pres_Idle_Word_Bit_Counter<=Pres_Idle_Word_Bit_Counter+1;
			
			IF Pres_Idle_Word_Bit_Counter = 0 AND Pres_Idles_Word_Counter<Max_Idle_Word_Amount THEN 	
				Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In; 
				Pres_Idles_Word_Counter<=Pres_Idles_Word_Counter+1;

			ELSIF Pres_Idle_Word_Bit_Counter = 0 AND Pres_Idles_Word_Counter=Max_Idle_Word_Amount THEN
				Idles_Word_Completed <=True;

			ELSIF Pres_Idle_Word_Bit_Counter = 7 THEN
				Pres_Idle_Word_Bit_Counter <= 0;
				Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
				Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
				
			END IF;

		ELSIF S_operation_Mode_Initialized  = '1' AND S_SYNC = '1' AND Idles_Word_Completed =True THEN
		--This operation will send start_Word
		END IF;
	
		WHEN SPI_DATA_READ=> 
		-- Creating/Collecting 32 bits
		-- Only the first 16 bit are important, the rest are not relevant
		-- 1bit(R/W)13bit(ADDR)1bit(P),15bit(Data)1bit(P)
		-- Calculate and create ADDR and DATA ODD parity value
			Time_counter<=0;		
			S_SCN<='0';		
			CASE TB_BIT_COUNTER IS

				WHEN 0 =>
				TB_BANK_BUFFER(TB_BIT_COUNTER)<='1';--'1' Read
				S_SDO<='1';
					
				WHEN 1 TO 14=>--Address pointer 
				--TB_BANK_BUFFER = 32 bit - lsb = R/W, 14 addr...
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-1);
				S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-1);
				ADDR_EVEN_TEST:=ADDR_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-1);
				ADDR_ODD_TEST<=NOT(ADDR_EVEN_TEST);
			
				WHEN 15=>--Address parity test
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_ODD_TEST;
				S_SDO<=ADDR_ODD_TEST;
				
--All the data from bit 16 to 31 is not relevant according SPI READ protocol
				WHEN 16 TO 29=>--data - 14 LSB Bits are equals to ADDR
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-16);
				S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

--All the data from bit 16 to 31 is not relevant according SPI READ protocol
				WHEN 30=>--data: 1 MSB Bit 
				TB_BANK_BUFFER(TB_BIT_COUNTER)<='0';
				S_SDO<='0';

--All the data from bit 16 to 31 is not relevant according SPI READ protocol		
				WHEN 31=>--Data parity test
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=DATA_ODD_TEST;
				S_SDO<=DATA_ODD_TEST;
				--S_SCN<='1';
				TB_Cur_state<=Update_ADDR;		

				WHEN OTHERS=> -- WHEN BIT COUNTER =32
				S_SCN<='1';
				TB_Cur_state<=Idle;

			END CASE;
 			TB_BIT_COUNTER<=TB_BIT_COUNTER+1;

 
		WHEN Update_ADDR=>	
			--Update the next address
			--Verify that the address values are according to R/W allowed registers (page 64)
			IF ADDR_Pointer(15 DOWNTO 0)>= x"000C" AND ADDR_Pointer(15 DOWNTO 0)< x"001F"  THEN
				ADDR_Pointer(15 DOWNTO 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 DOWNTO 0)) + 1 );

			ELSIF ADDR_Pointer(15 DOWNTO 0)=  x"001F" THEN

				IF S_operation_Mode_Initialized  = '1' AND S_SYNC = '0' THEN
					IF cal_cur_state = Offset_voltage_calibration THEN
					--Before calibration
					TB_Cur_state<=Calibration_And_Read_Serial_Idles_Words_Without_Sync;
					S_SCN<='0';
					ELSE
					--After calibration
					TB_Cur_state<=Read_Serial_Idles_Words_Without_Sync;
					S_SCN<='0';
					END IF;
				END IF;
 
			
			ELSIF ADDR_Pointer=  x"08FF" THEN 
				--Completed all addresses
				ADDR_Pointer<=	x"000C";
				--Change status not(status) -- from data read to write and opposite
				SPI_READ_WR_STATUS<=NOT(SPI_READ_WR_STATUS);   

			END IF;
			
			IF ADDR_Pointer(15 DOWNTO 0)/=  x"001F" THEN
				S_SCN<='1';
				TB_Cur_state<=clear_Wait;

			END IF;


			WHEN Calibration_And_Read_Serial_Idles_Words_Without_Sync=>

IF EN_PULSE ='1' THEN
--Showing Idle words, update idle_word_counter
--Read data from one or two lines accoridng to num_data_lines
				IF num_data_lines ='0' THEN
					Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
					Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right			
				ELSE --num_data_lines ='1' 
					Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
					Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
					Pres_Idle_Word_D2_Seial_In(0)<=S_DATA2_OUT;
					Pres_Idle_Word_D2_Seial_In(7 DOWNTO 0)<=S_DATA2_OUT & Pres_Idle_Word_D2_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
				END IF;

				Pres_Idle_Word_Bit_Counter<=Pres_Idle_Word_Bit_Counter+1;

				IF Pres_Idle_Word_Bit_Counter = 1  THEN		
					IF num_data_lines ='0' THEN
						Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In;
					ELSE --num_data_lines ='1'
						Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In;
						Pres_Idle_Word_D2_As_Vec<=Pres_Idle_Word_D2_Seial_In;
					END IF;
					
				ELSIF Pres_Idle_Word_Bit_Counter = 7 THEN
					Pres_Idle_Word_Bit_Counter <= 0;
					IF num_data_lines ='0' THEN
						Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
						Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
					ELSE --num_data_lines ='1'
						Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
						Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
						Pres_Idle_Word_D2_Seial_In(0)<=S_DATA2_OUT;
						Pres_Idle_Word_D2_Seial_In(7 DOWNTO 0)<=S_DATA2_OUT & Pres_Idle_Word_D2_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right

					END IF;
				END IF;

				IF S_SYNC = '1' THEN
					TB_Cur_state<=Read_Serial_Idles_Words_With_Sync;
					IF Pres_Idle_Word_Bit_Counter=7 THEN
						Pres_Idles_Word_Counter<=-1;
					ELSE 
						Pres_Idles_Word_Counter<=0;
					END IF;

				END IF;




--Calibration_process
			CASE Cal_BIT_COUNTER IS

				WHEN 0 =>
				Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';--'0' write sign
				S_SDO<='0';
				Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;
				
				--Create a new S_SCN pulse during the calibration process
				IF time_counter= 1 THEN		 
					S_SCN<='0';	
					time_counter<=0;
					Cal_BIT_COUNTER<=0;
					IF cal_Cur_state=Offset_voltage_calibration THEN
						cal_Cur_state<=Linearity_calibration;
					ELSIF cal_Cur_state=Linearity_calibration THEN
						cal_Cur_state<=Offset_Charge_calibration;
					ELSIF cal_Cur_state=Offset_Charge_calibration THEN
						cal_Cur_state<=Offset_current_calibration;
					ELSIF cal_Cur_state=Offset_current_calibration THEN
						cal_Cur_state<=Cal_done;
					END IF;
				END IF;	



				WHEN 1 TO 14=>--Address pointer 
				--Cal_BANK_BUFFER = 32 bit - lsb = R/W, 14 addr...
				--Cal_ADDR_Pointer=  x"0052" --Auto-Calibration Register
				Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_ADDR_Pointer(Cal_BIT_COUNTER-1);
				S_SDO<=Cal_ADDR_Pointer(Cal_BIT_COUNTER-1);
				Cal_ADDR_EVEN_TEST:=Cal_ADDR_EVEN_TEST XOR Cal_ADDR_Pointer(Cal_BIT_COUNTER-1);
				Cal_ADDR_ODD_TEST<=NOT(Cal_ADDR_EVEN_TEST);
				Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

				WHEN 15=>--Address parity test
				Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_ADDR_ODD_TEST;
				S_SDO<=Cal_ADDR_ODD_TEST;
				Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

				WHEN 16 TO 31=>
					CASE cal_Cur_state is
						
					WHEN Offset_voltage_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_0011(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_0011(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_0011(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
							
							S_SCN<='1';
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;

							IF time_counter< 1 THEN		 
								time_counter<=time_counter+1;
								S_SCN<='1';
							ELSE
								S_SCN<='0';	
								time_counter<=0;
								cal_Cur_state<=Linearity_calibration;
							END IF;						
						END IF;

					WHEN Linearity_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_0111(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_0111(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_0111(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
							S_SCN<='1';
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							
							IF time_counter< 1 THEN		 
								time_counter<=time_counter+1;
								S_SCN<='1';
							ELSE
								S_SCN<='0';	
								time_counter<=0;
								cal_Cur_state<=Offset_Charge_calibration;
							END IF;	
						END IF;
					
					WHEN Offset_Charge_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_1011(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_1011(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_1011(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
							S_SCN<='1';
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							
							IF time_counter< 1 THEN		 
								time_counter<=time_counter+1;
								S_SCN<='1';
							ELSE --time_counter= 1
								S_SCN<='0';	
								time_counter<=0;
								cal_Cur_state<=Offset_current_calibration;
							END IF;	
						END IF;

					WHEN Offset_current_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_1111(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_1111(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_1111(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
							S_SCN<='1';
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							
							IF time_counter< 1 THEN		 
								time_counter<=time_counter+1;
								S_SCN<='1';
							ELSE
								S_SCN<='0';	
								time_counter<=0;
								cal_Cur_state<=cal_done;
							END IF;	
						
						END IF;
					WHEN cal_done=>NULL;

					WHEN OTHERS=>NULL;

					END CASE;
		
			WHEN OTHERS=> NULL;
			

		END CASE;
--End of calibration process

END IF;



			WHEN Read_Serial_Idles_Words_Without_Sync=>
-- Read_Serial_Idles_Words_Without_Sync **AFTER CALIBRATION**
IF EN_PULSE ='1' THEN
--Showing Idle words, update idle_word_counter
--Read data from one or two lines according to num_data_lines
				IF num_data_lines ='0' THEN
					Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
					Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right			
				ELSE --num_data_lines ='1' 
					Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
					Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
					Pres_Idle_Word_D2_Seial_In(0)<=S_DATA2_OUT;
					Pres_Idle_Word_D2_Seial_In(7 DOWNTO 0)<=S_DATA2_OUT & Pres_Idle_Word_D2_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
				END IF;

				Pres_Idle_Word_Bit_Counter<=Pres_Idle_Word_Bit_Counter+1;

				IF Pres_Idle_Word_Bit_Counter = 1  THEN		
					IF num_data_lines ='0' THEN
						Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In;
					ELSE --num_data_lines ='1'
						Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In;
						Pres_Idle_Word_D2_As_Vec<=Pres_Idle_Word_D2_Seial_In;
					END IF;
					
				ELSIF Pres_Idle_Word_Bit_Counter = 7 THEN
					Pres_Idle_Word_Bit_Counter <= 0;
					IF num_data_lines ='0' THEN
						Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
						Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
					ELSE --num_data_lines ='1'
						Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
						Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
						Pres_Idle_Word_D2_Seial_In(0)<=S_DATA2_OUT;
						Pres_Idle_Word_D2_Seial_In(7 DOWNTO 0)<=S_DATA2_OUT & Pres_Idle_Word_D2_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right

					END IF;
				END IF;

				IF S_SYNC = '1' THEN
					TB_Cur_state<=Read_Serial_Idles_Words_With_Sync;
					IF Pres_Idle_Word_Bit_Counter=7 THEN
						Pres_Idles_Word_Counter<=-1;
					ELSE 
						Pres_Idles_Word_Counter<=0;
					END IF;
				END IF;
END IF;





			WHEN Read_Serial_Idles_Words_With_Sync=>	
IF EN_PULSE ='1' THEN				
--Read data from one or two lines accoridng to num_data_lines
				IF num_data_lines ='0' THEN					
					Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right			
				ELSE --num_data_lines ='1' 
					Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
					Pres_Idle_Word_D2_Seial_In(7 DOWNTO 0)<=S_DATA2_OUT & Pres_Idle_Word_D2_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
				END IF;

					Pres_Idle_Word_Bit_Counter<=Pres_Idle_Word_Bit_Counter+1;
			
					IF Pres_Idle_Word_Bit_Counter = 1 AND Pres_Idles_Word_Counter<Max_Idle_Word_Amount  THEN 						

						IF num_data_lines ='0' THEN
							Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In;
							Pres_Idles_Word_Counter<=Pres_Idles_Word_Counter+1;
						ELSE --num_data_lines ='1
							Pres_Idle_Word_D1_As_Vec<=Pres_Idle_Word_D1_Seial_In;
							Pres_Idle_Word_D2_As_Vec<=Pres_Idle_Word_D2_Seial_In;
							Pres_Idles_Word_Counter<=Pres_Idles_Word_Counter+1;
						END IF;
															

					ELSIF Pres_Idle_Word_Bit_Counter = 7 AND Pres_Idles_Word_Counter=Max_Idle_Word_Amount THEN
						Pres_Idle_Word_Bit_Counter <= 0;
						TB_Cur_state<=Read_Serial_Start_Words;								

					ELSIF Pres_Idle_Word_Bit_Counter = 7 THEN

						Pres_Idle_Word_Bit_Counter <= 0;
						IF num_data_lines ='0' THEN
							Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
							Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right			
						ELSE --num_data_lines ='1' 
							Pres_Idle_Word_D1_Seial_In(0)<=S_DATA1_OUT;
							Pres_Idle_Word_D1_Seial_In(7 DOWNTO 0)<=S_DATA1_OUT & Pres_Idle_Word_D1_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
							Pres_Idle_Word_D2_Seial_In(0)<=S_DATA2_OUT;
							Pres_Idle_Word_D2_Seial_In(7 DOWNTO 0)<=S_DATA2_OUT & Pres_Idle_Word_D2_Seial_In(7 DOWNTO 1)  ;-- ShIFt register right
						END IF;
							
					END IF;
							
			
END IF;			
			WHEN Read_Serial_Start_Words=>		
IF EN_PULSE ='1' THEN			
					Pres_Start_Word(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA1_OUT & Pres_Start_Word(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right
					Pres_Start_Word_Counter<=Pres_Start_Word_Counter+1;
			
					IF Pres_Start_Word_Counter=Data_word_length_bits_amount-1 THEN 	
						
						Pres_Start_Word0_As_Vec	<=S_DATA1_OUT & Pres_Start_Word(14 DOWNTO 1)  ;
							CASE Data_word_length IS
							--Number of Data's bits
							--According to Data_word_length vector value
							WHEN "0000" =>Pres_Start_Word1_As_Vec(8 DOWNTO 0)	<= Pres_Start_Word(23 DOWNTO 15);--24
							WHEN "0001" =>Pres_Start_Word1_As_Vec(10 DOWNTO 0)	<= Pres_Start_Word(25 DOWNTO 15);--26
							WHEN "0010" =>Pres_Start_Word1_As_Vec(12 DOWNTO 0)	<= Pres_Start_Word(27 DOWNTO 15);--28
							WHEN "0011" =>Pres_Start_Word1_As_Vec(14 DOWNTO 0)	<= Pres_Start_Word(29 DOWNTO 15);--30
							WHEN "0100" =>Pres_Start_Word1_As_Vec(14 DOWNTO 0)	<= Pres_Start_Word(29 DOWNTO 15);
								      Pres_Start_Word2_As_Vec(1 DOWNTO 0)	<= Pres_Start_Word(31 DOWNTO 30);--32--Default
							WHEN "0101" =>Pres_Start_Word1_As_Vec(14 DOWNTO 0)	<= Pres_Start_Word(29 DOWNTO 15);
								      Pres_Start_Word2_As_Vec(3 DOWNTO 0)	<= Pres_Start_Word(33 DOWNTO 30);--34
							WHEN "0110" =>Pres_Start_Word1_As_Vec(14 DOWNTO 0)	<= Pres_Start_Word(29 DOWNTO 15);
								      Pres_Start_Word2_As_Vec(5 DOWNTO 0)	<= Pres_Start_Word(35 DOWNTO 30);--36
							WHEN "0111" =>Pres_Start_Word1_As_Vec(14 DOWNTO 0)	<= Pres_Start_Word(29 DOWNTO 15);
								      Pres_Start_Word2_As_Vec(7 DOWNTO 0)	<= Pres_Start_Word(37 DOWNTO 30);--38
							WHEN "1000" =>Pres_Start_Word1_As_Vec(14 DOWNTO 0)	<= Pres_Start_Word(29 DOWNTO 15);
								      Pres_Start_Word2_As_Vec(9 DOWNTO 0)	<= Pres_Start_Word(39 DOWNTO 30);--40
							WHEN OTHERS => NULL;
							END CASE;	

						TB_Cur_state<=Read_ASIC_data;
					END IF;
END IF;						

			WHEN Read_ASIC_data=>
IF EN_PULSE ='1' THEN
-- present ASIC data
--Read data from one or two lines accoriding to num_data_lines
				IF num_data_lines ='0' THEN
					ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA1_OUT & ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right			
				ELSIF num_data_lines ='1' THEN
					ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA1_OUT & ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right
					ASIC_DATA_line_2(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA2_OUT & ASIC_DATA_line_2(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;
				
				IF bit_Data_counter =1 AND num_data_lines ='0'THEN
				--The sample needs to be done one clk after the data sent from the uut
					Pres_ASIC_DATA_line_1_As_Vec<=ASIC_DATA_line_1;
				ELSIF bit_Data_counter =1 AND num_data_lines ='1'THEN
				--The sample needs to be done one clk after the data sent from the uut
					Pres_ASIC_DATA_line_1_As_Vec<=ASIC_DATA_line_1;
					Pres_ASIC_DATA_line_2_As_Vec<=ASIC_DATA_line_2;
				END IF;

				IF bit_Data_counter = (Data_word_length_bits_amount-1) THEN
					--Each time word completed						
					Word_Data_counter<=Word_Data_counter+1;
					bit_Data_counter<=0;

					IF num_data_lines ='0' THEN				
						ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA1_OUT & ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right				
						IF Word_Data_counter = 255 THEN
							bit_Data_counter <= 0;
							IF footer_disable /="111111"  THEN
								TB_Cur_state<=Read_footer;	
								LVDS_FOOTER_1_Completed<=False;	
								bit_Data_counter <= 0;					
							ELSE
								TB_Cur_state<=Read_CRC;	
							END IF;
						END IF;

					ELSIF num_data_lines ='1' THEN --num_data_lines ='1						
						ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA1_OUT & ASIC_DATA_line_1(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right						
						ASIC_DATA_line_2(Data_word_length_bits_amount-1 DOWNTO 0)<=S_DATA2_OUT & ASIC_DATA_line_2(Data_word_length_bits_amount-1 DOWNTO 1)  ;-- ShIFt register right

						IF Word_Data_counter = 127 THEN
							bit_Data_counter <= 0;
							IF footer_disable /="111111"  THEN
								TB_Cur_state<=Read_footer;	
								LVDS_FOOTER_1_Completed<=False;
								bit_Data_counter <= 0;
							ELSE
								TB_Cur_state<=Read_CRC;	
							END IF;
						END IF;

					END IF;
				END IF;

				

END IF;
			WHEN Read_footer=>
IF EN_PULSE ='1' THEN
--Read footer
		-- The footer contains of six registers that may be added to the END of the channel data stream.  
		-- Bits <footer_disable> in LVDS Configuration Register 3 (Address 0x0017) allow to individually disable the footers of the serial output data frame. 
		-- The following chapter describes the individual footers 
		
		--LVDS Configuration Register 3 (Address 0x0017)= footer_disable bits 
		--0: Footer is enabled
		--1: Footer is disabled
		--footer_disable(0): footer 1
		--footer_disable(1): footer 2
		--footer_disable(2): footer 3
		--footer_disable(3): footer 4
		--footer_disable(4): footer 5
		--footer_disable(5): footer 6

--The footer has the same length as the channel data word defined in bits <data_word_length>
		IF footer_disable /="111111"  and bit_Data_counter = 1 AND  num_data_lines='0' THEN
		--Presents the sampled value at one clk delay 
			Pres_LVDS_FOOTER_line1<=LVDS_FOOTER_line1;
		ELSIF footer_disable /="111111"  and bit_Data_counter = 1 AND  num_data_lines='1' THEN
		--Presents the sampled value at one clk delay 
			Pres_LVDS_FOOTER_line1<=LVDS_FOOTER_line1;			
			Pres_LVDS_FOOTER_line2<=LVDS_FOOTER_line2;	
		END IF;

		IF footer_disable(0)='0' AND LVDS_FOOTER_1_Completed=False THEN 
		--Register enabled
		--TEMP_SENSOR (read only)	
			IF bit_Data_counter<=13 AND LVDS_FOOTER_1_Completed=False   THEN
				bit_Data_counter<=bit_Data_counter+1;	

				IF num_data_lines ='0' THEN					
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right			
					
				ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'					
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right
					LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;

				IF bit_Data_counter = 13 THEN
					
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right										
						LVDS_FOOTER_1_Completed<=True;
						bit_Data_counter <= 0;
						
					ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right									
						
						LVDS_FOOTER_1_Completed<=True;
						bit_Data_counter <= 0;
											

					END IF;
				END IF;
			END IF;

		ELSIF bit_Data_counter<=13 AND LVDS_FOOTER_2_Completed=False   THEN

						Pres_LVDS_FOOTER_line2<=LVDS_FOOTER_line2;	
				IF num_data_lines ='0' THEN
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right			
				ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right
					LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;

				IF bit_Data_counter = 13 THEN
					
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						
						LVDS_FOOTER_2_Completed<=True;
						bit_Data_counter <= 0;
						
					ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right									
						
						LVDS_FOOTER_2_Completed<=True;
						bit_Data_counter <= 0;
										

					END IF;
				END IF;

			ELSIF bit_Data_counter<=13 AND LVDS_FOOTER_3_Completed=False   THEN
				bit_Data_counter<=bit_Data_counter+1;	

				IF num_data_lines ='0' THEN
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right			
				ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right
					LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;

				IF bit_Data_counter = 13 THEN
					
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						
						LVDS_FOOTER_3_Completed<=True;
						bit_Data_counter <= 0;
						
					ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right									
						
						LVDS_FOOTER_3_Completed<=True;
						bit_Data_counter <= 0;
											

					END IF;
				END IF;

			ELSIF bit_Data_counter<=13 AND LVDS_FOOTER_4_Completed=False   THEN
				bit_Data_counter<=bit_Data_counter+1;	

				IF num_data_lines ='0' THEN
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right			
				ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right
					LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;

				IF bit_Data_counter = 13 THEN
					
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right										
						LVDS_FOOTER_4_Completed<=True;
						bit_Data_counter <= 0;
						
					ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right									
						
						LVDS_FOOTER_4_Completed<=True;
						bit_Data_counter <= 0;
										

					END IF;
				END IF;

			ELSIF bit_Data_counter<=13 AND LVDS_FOOTER_5_Completed=False   THEN
				bit_Data_counter<=bit_Data_counter+1;	

				IF num_data_lines ='0' THEN
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right			
				ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right
					LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;

				IF bit_Data_counter = 13 THEN
					
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right										
						LVDS_FOOTER_5_Completed<=True;
						bit_Data_counter <= 0;
						
					ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right															
						LVDS_FOOTER_5_Completed<=True;
						bit_Data_counter <= 0;
										

					END IF;
				END IF;	
			ELSIF bit_Data_counter<=13 AND LVDS_FOOTER_6_Completed=False   THEN
				bit_Data_counter<=bit_Data_counter+1;	

				IF num_data_lines ='0' THEN
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right			
				ELSE --num_data_lines ='1' 
					LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right
					LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;

				IF bit_Data_counter = 13 THEN
					
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right										
						LVDS_FOOTER_6_Completed<=True;
						bit_Data_counter <= 0;
						
					ELSE --num_data_lines ='1
						LVDS_FOOTER_line1(13 DOWNTO 0)<=S_DATA1_OUT & LVDS_FOOTER_line1(13 DOWNTO 1)  ;-- ShIFt register right				
						LVDS_FOOTER_line2(13 DOWNTO 0)<=S_DATA2_OUT & LVDS_FOOTER_line2(13 DOWNTO 1)  ;-- ShIFt register right									
						
						LVDS_FOOTER_6_Completed<=True;
						bit_Data_counter <= 0;
										

					END IF;
				END IF;
	
			ELSE
			
			--footer
			 
			LVDS_FOOTER_1_Completed <=False;
			LVDS_FOOTER_2_Completed <=False;
			LVDS_FOOTER_3_Completed <=False;
			LVDS_FOOTER_4_Completed <=False;
			LVDS_FOOTER_5_Completed <=False;
			LVDS_FOOTER_6_Completed <=False;				
			TB_Cur_state<=Read_CRC;

			END IF;

END IF;
			WHEN Read_CRC=>
IF EN_PULSE ='1' THEN
				--16-bit word - CRC
				--IF bit_Data_counter = 1 AND num_data_lines ='0' THEN
				--	Pres_CRC_line1_As_Vec<=CRC_line1;
				--ELSIF bit_Data_counter = 1 AND num_data_lines ='1' THEN
				--	Pres_CRC_line1_As_Vec<=CRC_line1;					
				--	Pres_CRC_line2_As_Vec<=CRC_line2;	
				--END IF; 

				IF num_data_lines ='0' THEN
					CRC_line1(15 DOWNTO 0)<=S_DATA1_OUT & CRC_line1(15 DOWNTO 1)  ;-- ShIFt register right			
				ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
					CRC_line1(15 DOWNTO 0)<=S_DATA1_OUT & CRC_line1(15 DOWNTO 1)  ;-- ShIFt register right
					CRC_line2(15 DOWNTO 0)<=S_DATA2_OUT & CRC_line2(15 DOWNTO 1)  ;-- ShIFt register right
				END IF;
	
				bit_Data_counter<=bit_Data_counter+1;
				IF bit_Data_counter = 15 THEN
					bit_Data_counter<=0;
					IF num_data_lines ='0' THEN
						CRC_line1(15 DOWNTO 0)<=S_DATA1_OUT & CRC_line1(15 DOWNTO 1)  ;-- ShIFt register right				
						Pres_CRC_line1_As_Vec<=S_DATA1_OUT & CRC_line1(15 DOWNTO 1)  ;
						bit_Data_counter <= 0;
						TB_Cur_state<=IDLE;
					ELSIF num_data_lines ='1' THEN	 --num_data_lines ='1'	
						CRC_line1(15 DOWNTO 0)<=S_DATA1_OUT & CRC_line1(15 DOWNTO 1)  ;-- ShIFt register right				
						CRC_line2(15 DOWNTO 0)<=S_DATA2_OUT & CRC_line2(15 DOWNTO 1)  ;-- ShIFt register right		
						Pres_CRC_line1_As_Vec<=S_DATA1_OUT & CRC_line1(15 DOWNTO 1)  ;	
						Pres_CRC_line2_As_Vec<=S_DATA2_OUT & CRC_line2(15 DOWNTO 1)  ;		
						bit_Data_counter <= 0;		
						TB_Cur_state<=IDLE;								
					END IF;
				END IF;



END IF;

			WHEN clear_Wait=>
			--Clear all counters
			--Wait before send the next vector
			TB_BIT_COUNTER<=0;		--clear bit counter
			TB_BANK_BUFFER(31 DOWNTO 0)<=(OTHERS=>'0');
			ADDR_EVEN_TEST:='0';  	-- set_odd_test to 0
			DATA_EVEN_TEST:='0';	-- set_odd_test to 0	
			ADDR_ODD_TEST<='0';  	-- set_odd_test to 0
			DATA_ODD_TEST<='0';	-- set_odd_test to 0
			
			IDLE_Wait<=0;
			IF time_counter< (Clk_wait_val) THEN	
	 
				time_counter<=time_counter+1;
			ELSE
				S_SCN<='0';			
				IF SPI_READ_WR_STATUS='0' THEN --WRITE
				TB_Cur_state<=SPI_DATA_WR;
				ELSIF SPI_READ_WR_STATUS='1' THEN--READ
				TB_Cur_state<=SPI_DATA_READ;
				END IF;
				
			END IF;


			WHEN Calibration_process=>
			-- Collecting 32 bits 
			-- 1bit(R/W)13bit(ADDR)1bit(P),15bit(Data)1bit(P)
			-- Calculate and create ADDR and DATA ODD parity value
					
			CASE Cal_BIT_COUNTER IS

				WHEN 0 =>
			
				Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';--'0' write sign
				S_SDO<='0';
				Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;
			
				WHEN 1 TO 14=>--Address pointer 
				--Cal_BANK_BUFFER = 32 bit - lsb = R/W, 14 addr...
				--Cal_ADDR_Pointer=  x"0052" --Auto-Calibration Register
				Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_ADDR_Pointer(Cal_BIT_COUNTER-1);
				S_SDO<=Cal_ADDR_Pointer(Cal_BIT_COUNTER-1);
				Cal_ADDR_EVEN_TEST:=Cal_ADDR_EVEN_TEST XOR Cal_ADDR_Pointer(Cal_BIT_COUNTER-1);
				Cal_ADDR_ODD_TEST<=NOT(Cal_ADDR_EVEN_TEST);
				Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

				WHEN 15=>--Address parity test
				Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_ADDR_ODD_TEST;
				S_SDO<=Cal_ADDR_ODD_TEST;
				Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

				WHEN 16 TO 31=>
					CASE cal_Cur_state is
						
					WHEN Offset_voltage_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_0011(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_0011(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_0011(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
			
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							cal_Cur_state<=Linearity_calibration;
						
						END IF;

					WHEN Linearity_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_0111(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_0111(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_0111(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
	
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							cal_Cur_state<=Offset_Charge_calibration;
						
						END IF;
					
					WHEN Offset_Charge_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_1011(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_1011(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_1011(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
	
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							cal_Cur_state<=Offset_current_calibration;
						
						END IF;

					WHEN Offset_current_calibration=>
						IF Cal_BIT_COUNTER<30 THEN
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=word_test_1111(Cal_BIT_COUNTER-16);
							S_SDO<=word_test_1111(Cal_BIT_COUNTER-16);
							Cal_DATA_EVEN_TEST:=(Cal_DATA_EVEN_TEST XOR word_test_1111(Cal_BIT_COUNTER-16));
							Cal_DATA_ODD_TEST<=NOT(Cal_DATA_EVEN_TEST);
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;

						ELSIF Cal_BIT_COUNTER= 30 THEN--Data: 1 MSB Bit 
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<='0';
							S_SDO<='0';
							Cal_BIT_COUNTER<=Cal_BIT_COUNTER+1;	
	
						ELSIF Cal_BIT_COUNTER= 31 THEN--Data parity test
							Cal_BANK_BUFFER(Cal_BIT_COUNTER)<=Cal_DATA_ODD_TEST;
							S_SDO<=Cal_DATA_ODD_TEST;
							Cal_BIT_COUNTER<=0;
							cal_Cur_state<=cal_done;
						
						END IF;
					WHEN cal_done=>NULL;

					WHEN OTHERS=>NULL;

					END CASE;
		
			WHEN OTHERS=> NULL;		

		END CASE;

		--End of calibration_process

	END CASE;
	END IF;
END PROCESS;


Sampling_SPI_In:Process (s_rst, s_sclk)
begin
IF S_RST='1' THEN
--Clear signals
Sampling_SDI_In <=(OTHERS=>'0');
Sampling_SDI_In_ADDR<=(OTHERS=>'0');
Sampling_SDI_In_Data <=(OTHERS=>'0');
Sampling_ADDR<=(OTHERS=>'0');
Sampling_Data<=(OTHERS=>'0');

ELSIF SPI_READ_WR_STATUS='1' THEN --read mode	
	IF falling_edge(S_SCLK) AND (TB_CUR_STATE=SPI_DATA_READ or TB_CUR_STATE=UPDATE_ADDR)  THEN -- sample SDI input
		--Sample SDI at Falling edge (sclk) and the right states	
		--Sampling SDI SIGNAL snd shIFt right the selected data
		Sampling_SDI_In(0)<= S_SDI ;-- ShIFt register
		Sampling_SDI_In(31 DOWNTO 0)<=S_SDI & Sampling_SDI_In(31 DOWNTO 1)  ;-- ShIFt register right
	
	ELSIF TB_CUR_STATE=UPDATE_ADDR  THEN
		--Showing the collected signals as vectors
		Sampling_SDI_In_ADDR<=Sampling_SDI_In(15 DOWNTO 0);
		Sampling_SDI_In_Data<=Sampling_SDI_In(31 DOWNTO 16);
		Sampling_ADDR<=Sampling_SDI_In(14 DOWNTO 1);
		Sampling_Data<=Sampling_SDI_In(30 DOWNTO 16);

	ELSIF TB_CUR_STATE=clear_wait  THEN
		--Clear signals
		Sampling_SDI_In <=(OTHERS=>'0');
		Sampling_SDI_In_ADDR<=(OTHERS=>'0');
		Sampling_SDI_In_Data <=(OTHERS=>'0');
		Sampling_ADDR<=(OTHERS=>'0');
		Sampling_Data<=(OTHERS=>'0');

	END IF;
END IF;
END process;



p1_COUNTER:PROCESS(s_rst, s_sclk)
BEGIN
IF S_RST='1' THEN
	CLK_COUNTER<=(OTHERS=>'0'); 
ELSIF RISING_EDGE(S_SCLK) THEN
	
	IF CLK_COUNTER=X"3" THEN
		CLK_COUNTER<=(OTHERS=>'0');
	ELSE
		CLK_COUNTER<=CLK_COUNTER+1;
 
	END IF;
	
END IF;
END PROCESS;

P2_SEND_CLK_OUT: PROCESS (s_rst, s_sclk)
BEGIN 
IF S_RST='1' THEN
	S_Clk_DIV<=0;
ELSIF RISING_EDGE(S_SCLK) THEN	
	CASE Word_test_0007(3 downto 0) IS
		WHEN X"7"=>--320Mhz
			S_CLK_RATE<=S_SCLK;
			S_Clk_DIV<=0;
		WHEN X"5"=>NULL;
		WHEN X"3"=>--160Mhz
			S_CLK_RATE<=CLK_COUNTER(0);
			S_Clk_DIV<=1;		
		WHEN X"1"=>--80MHz
			S_CLK_RATE<=CLK_COUNTER(1);
			S_Clk_DIV<=4;
		WHEN OTHERS=>--320Mhz
			S_Clk_DIV<=0;

		END CASE;
END IF;
END PROCESS;



EN_COUNTER: PROCESS (s_rst,S_CLK_RATE)	
--This process creat enable flag that responsible on the enable flag
BEGIN 
IF S_RST='1' THEN
	EN_PULSE<='0';
ELSIF RISING_EDGE(S_CLK_RATE) THEN	
	EN_PULSE<='1';
ELSE
	EN_PULSE<='0';
END IF;
END PROCESS;




END Register_Data_IF_TB_arc;
