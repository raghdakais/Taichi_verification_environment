lIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE std.STANDARD.BOOLEAN;
use STD.textio.all;
use ieee.std_logic_textio.all;
USE work.AMS_pack.ALL;
USE work.PCK_CRC16_D16.ALL;

ENTITY DATA_IF IS
Port(
	SCLK  		:IN STD_LOGIC;
	RST		:IN STD_LOGIC;
	SYNC  		:IN STD_LOGIC;
	ACLK		:IN STD_LOGIC;
	D_START		:IN STD_LOGIC;
	DISCARD		:IN STD_LOGIC;
	OPERATIONMODE	:IN STD_LOGIC;
	SET_UP		:IN STD_LOGIC;
	CALIBRATION	:IN STD_LOGIC;

--Configuration Registers outputs
--LVDS_CONFIG_1
	num_data_lines	: IN STD_LOGIC; --LVDS_CONFIG_1(0) -- 0 -Single, 1- Parallel
	legacy_mode	: IN STD_LOGIC; --LVDS_CONFIG_1(1)
	data_word_length: IN STD_LOGIC_VECTOR (3 DOWNTO 0); --LVDS_CONFIG_1(5 DOWNTO 2)
	idle_word	: IN STD_LOGIC_VECTOR (7 DOWNTO 0); --LVDS_CONFIG_1(13 DOWNTO 6)

--LVDS_CONFIG_2
	start_delay_14DownTo0	:IN STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3
	start_delay_17DownTo15	: IN STD_LOGIC_VECTOR (2 DOWNTO 0); --LVDS_CONFIG_3(2 DOWNTO 0)
	scrambler_rst		: IN STD_LOGIC; --LVDS_CONFIG_3(3)
	scrambler_en		: IN STD_LOGIC; --LVDS_CONFIG_3(4)
	footer_disable		: IN STD_LOGIC_VECTOR (5 DOWNTO 0); --LVDS_CONFIG_3(10 DOWNTO 5)
	tm_aci_data		: IN STD_LOGIC; --LVDS_CONFIG_3(11)
	raw_data_bypass		: IN STD_LOGIC; --LVDS_CONFIG_3(12)

--Clock_CTRL
	hclk_div_cfg	: IN STD_LOGIC_VECTOR (2 DOWNTO 0); --Clock_CTRL(2 DOWNTO 0)

--PADS_CONFIG_2
	itest_dis	: IN STD_LOGIC; --PADS_CONFIG_2(0)
	d_start_oen	: IN STD_LOGIC; --PADS_CONFIG_2(1)
	data1_en	: IN STD_LOGIC; --PADS_CONFIG_2(2)
	data2_en	: IN STD_LOGIC; --PADS_CONFIG_2(3)
	clk_en 		: IN STD_LOGIC; --PADS_CONFIG_2(9)
	daisy_chain	: IN STD_LOGIC; --PADS_CONFIG_2(10)

--START_WORD_0
	LVDS_start_word_14DownTo0	: IN STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--START_WORD_1
	LVDS_start_word_29DownTo15	: IN STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--START_WORD_2
	LVDS_start_word_39DownTo30	: IN STD_LOGIC_VECTOR (9 DOWNTO 0); --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>
----

	Operation_Mode_Initialized 	:OUT STD_LOGIC;
	Data_Out_en  			:OUT STD_LOGIC;
	DATA1_OUT  			:OUT STD_LOGIC;
	DATA2_OUT  			:OUT STD_LOGIC

	);
END DATA_IF;

ARCHITECTURE DATA_IF_arc OF DATA_IF IS
--state machion declearation--
TYPE state_type is (Idle, D_START_DLY,Send_Idles_word_and_Sync_Pulse_Detector,complete_Idle_word, send_idle,Send_START_WORD,Send_XRAY_DATA_One_Line,Send_XRAY_DATA_Two_Lines, Send_FOOTER_One_Line,Send_FOOTER_Two_Lines,Send_CRC_word_One_Line,Send_CRC_word_Two_Lines);

--Signals declearation--
SIGNAL Data_IF_Cur_state_type: state_type;


SIGNAL Data_word_length_bits_amount 	: INTEGER RANGE 24 TO 40:=32;  --Number of Data's bits


--SIGNAL Send_XRAY_DATA_One_Line_word :INTEGER RANGE 0 TO 40:=0;  --Number of Data's words

SIGNAL CLK_RATE 	: INTEGER RANGE 80 TO 320:=320;
------Signal Clks Declaration-------
SIGNAL CLK_COUNTER	: STD_LOGIC_VECTOR(3 DOWNTO 0):=(OTHERS=>'0');
SIGNAL S_CLK_Rate	: STD_LOGIC:='0';

SIGNAL S_Clk_Rate_Last_Sample	: STD_LOGIC:='0';--identifiy rising S_CLK_Rate signal

SIGNAL Sync_Last_sample	: STD_LOGIC:='0';--identifiy rising Sync signal

SIGNAL Idles_Word_Sent_Counter	:INTEGER RANGE 0 TO 5:=0;  --Number of Idles that sent
SIGNAL Idle_Bit_Counter		:INTEGER RANGE 0 TO 8:=0;  --Number of Data's bits
SIGNAL Idle_word_completed 	:BOOLEAN:=FALSE;

SIGNAL S_tDSTART_DLY 		:INTEGER RANGE 0 TO 15:=0;  --Define clks delay amount before Start word will be sent

SIGNAL Start_Word_Bit_Counter	: INTEGER RANGE 0 TO 40:=0;  --Number of Data's bits
SIGNAL S_LVDS_start_word	: STD_LOGIC_VECTOR (39 DOWNTO 0):=(others=>'0');
SIGNAL S_LVDS_start_word_completed :BOOLEAN:=FALSE;

SIGNAL Data1_out_Vec	: STD_LOGIC_VECTOR (39 downto 0):=(others=>'0');
SIGNAL channel_number 	: INTEGER RANGE 0 TO 256:=0;
SIGNAL Xray_res_Counter	: INTEGER RANGE 0 TO 40:=0;
SIGNAL S_Xray_Data1	: STD_LOGIC_VECTOR (39 downto 0):=(others=>'0');
SIGNAL S_Xray_Data2	: STD_LOGIC_VECTOR (39 downto 0):=(others=>'0');

SIGNAL LVDS_FOOTER_Bit_Pointer : INTEGER RANGE 0 TO 13:=0;
SIGNAL LVDS_FOOTER_Bit_Max_Bit : INTEGER RANGE 0 TO 13:=13;
SIGNAL LVDS_FOOTER_1_Completed : BOOLEAN:=FALSE;
SIGNAL LVDS_FOOTER_2_Completed : BOOLEAN:=FALSE;
SIGNAL LVDS_FOOTER_3_Completed : BOOLEAN:=FALSE;
SIGNAL LVDS_FOOTER_4_Completed : BOOLEAN:=FALSE;
SIGNAL LVDS_FOOTER_5_Completed : BOOLEAN:=FALSE;
SIGNAL LVDS_FOOTER_6_Completed : BOOLEAN:=FALSE;

SIGNAL XRAY_DATA : INTEGER RANGE 0 TO 6143:=0;  --Xray data counter


--LVDS_CONFIG_1
	SIGNAL lines_amount 		: INTEGER RANGE 1 TO 2:=1;  --Number of Data's bits
	SIGNAL S_num_data_lines		: STD_LOGIC; --LVDS_CONFIG_1(0) -- 0 -Single, 1- Parallel
	SIGNAL S_legacy_mode		: STD_LOGIC; --LVDS_CONFIG_1(1)
	SIGNAL S_data_word_length	: STD_LOGIC_VECTOR (3 DOWNTO 0); --LVDS_CONFIG_1(5 DOWNTO 2)
	SIGNAL S_idle_word		: STD_LOGIC_VECTOR (7 DOWNTO 0); --LVDS_CONFIG_1(13 DOWNTO 6)
	SIGNAL S_idle_word_static	: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_1(13 DOWNTO 6)
--LVDS_CONFIG_2
	SIGNAL S_start_delay_14DownTo0	:STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3
	SIGNAL S_start_delay_17DownTo15	: STD_LOGIC_VECTOR (2 DOWNTO 0); --LVDS_CONFIG_3(2 DOWNTO 0)
	SIGNAL S_scrambler_rst		: STD_LOGIC; --LVDS_CONFIG_3(3)
	SIGNAL S_scrambler_en		: STD_LOGIC; --LVDS_CONFIG_3(4)
	SIGNAL S_footer_disable		: STD_LOGIC_VECTOR (5 DOWNTO 0); --LVDS_CONFIG_3(10 DOWNTO 5)
	SIGNAL S_tm_aci_data		: STD_LOGIC; --LVDS_CONFIG_3(11)
	SIGNAL S_raw_data_bypass	: STD_LOGIC; --LVDS_CONFIG_3(12)

--Clock_CTRL
	SIGNAL S_hclk_div_cfg	: STD_LOGIC_VECTOR (2 DOWNTO 0); --Clock_CTRL(2 DOWNTO 0)

--PADS_CONFIG_2
	SIGNAL S_itest_dis	: STD_LOGIC; --PADS_CONFIG_2(0)
	SIGNAL S_d_start_oen	: STD_LOGIC; --PADS_CONFIG_2(1)
	SIGNAL S_data1_en	: STD_LOGIC; --PADS_CONFIG_2(2)
	SIGNAL S_data2_en	: STD_LOGIC; --PADS_CONFIG_2(3)
	SIGNAL S_clk_en 	: STD_LOGIC; --PADS_CONFIG_2(9)
	SIGNAL S_daisy_chain	: STD_LOGIC; --PADS_CONFIG_2(10)

--START_WORD_0
	SIGNAL S_LVDS_start_word_14DownTo0	: STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--START_WORD_1
	SIGNAL S_LVDS_start_word_29DownTo15	: STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--START_WORD_2
	SIGNAL S_LVDS_start_word_39DownTo30	: STD_LOGIC_VECTOR (9 DOWNTO 0); --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>


--Footer register examples
	SIGNAL S_footer_1_reg_addr: STD_LOGIC_VECTOR (15 DOWNTO 0):= X"0023";--RO
	SIGNAL S_footer_2_reg_addr: STD_LOGIC_VECTOR (15 DOWNTO 0):= X"0024";--RO
	SIGNAL S_footer_3_reg_addr: STD_LOGIC_VECTOR (15 DOWNTO 0):= X"0555";--RW
	SIGNAL S_footer_4_reg_addr: STD_LOGIC_VECTOR (15 DOWNTO 0):= X"0555";--RW
	SIGNAL S_footer_5_reg_addr: STD_LOGIC_VECTOR (15 DOWNTO 0):= X"0555";--RW
	SIGNAL S_footer_6_reg_addr: STD_LOGIC_VECTOR (15 DOWNTO 0):= X"0555";--RW

--xray data

SIGNAL S_Xray_Data1_From_File : STD_LOGIC_VECTOR ((40*256) downto 0):=(others=>'0');
SIGNAL S_Xray_Line_Data1_From_File : STD_LOGIC_VECTOR (39 downto 0):=(others=>'0');
SIGNAL S_Xray_Line_Data2_From_File : STD_LOGIC_VECTOR (39 downto 0):=(others=>'0');

--CRC
SIGNAL crc_calc_1                : std_logic_vector (15 downto 0):=x"FFFF";
SIGNAL crc_calc_2                : std_logic_vector (15 downto 0):=x"FFFF";
SIGNAL CRC_Bit_Counter		 : INTEGER RANGE 0 TO 40:=0;


--state machion declearation--
TYPE EN_state_type is (EN_OFF, EN_ON);

--Signals declearation--
SIGNAL EN_clk_counter 		: INTEGER RANGE 0 TO 4:=0;
SIGNAL EN_PULSE 		: STD_LOGIC:='0';
SIGNAL EN_Cur_state_type	: EN_state_type;
SIGNAL S_Clk_DIV		: INTEGER RANGE 0 TO 4:=0;--Beeing used for changing clk rate value
SIGNAL Calibration_flag		: STD_LOGIC:='0';--0 data full sequence before calibration. '1' data sequence before calibration

BEGIN

P1: PROCESS (SClk,rst)--,S_Clk_Rate)
CONSTANT Highest_Bits_Val	: integer :=39;
CONSTANT Max_Bits_Val		: integer :=40;

--Data files
FILE F_before_cal_40b: text open READ_MODE is "./src/models/AMS_V6Tile/40_bit_1data_0to255.txt";
FILE F_after_cal_40b: text open READ_MODE is "./src/models/AMS_V6Tile/40_bit_1data_256to512_after_cal.txt";

VARIABLE V_Xray_Data_From_File 		: STD_LOGIC_VECTOR ((Max_Bits_Val*256) downto 0):=(others=>'0');

VARIABLE current_read_line_1Data	: line ; -- read line from the file
VARIABLE current_read_field_1Data 	: STD_LOGIC_VECTOR ((Max_Bits_Val*256) downto 0):=(others=>'0') ;--read from the read line, the same type as we would like to use
VARIABLE current_write_line_1Data 	:line;
VARIABLE V_Xray_Line_Data1_From_File 	: STD_LOGIC_VECTOR (Highest_Bits_Val downto 0):=(others=>'0');

VARIABLE current_read_line_2Data 	: line ; -- read line from the file
VARIABLE current_read_field_2Data 	: STD_LOGIC_VECTOR ((Max_Bits_Val*256) downto 0):=(others=>'0') ;--read from the read line, the same type as we would like to use
VARIABLE current_write_line_2Data 	:line;
VARIABLE v_Xray_Line_Data2_From_File 	: STD_LOGIC_VECTOR (Highest_Bits_Val downto 0):=(others=>'0');

VARIABLE V_channel_number 		: INTEGER RANGE 0 TO 256:=0;
BEGIN
Operation_Mode_Initialized<=SET_UP;
IF RST='1' THEN
	Calibration_flag<='0';
	DATA1_OUT 		<='0';
	DATA2_OUT		<='0';
	Data_IF_Cur_state_type	<=Idle;
--CRC
	crc_calc_1		<=x"FFFF";--first crc calc as defined

--LVDS_CONFIG_1
	lines_amount		<=1;
	S_num_data_lines	<='0'; --LVDS_CONFIG_1(0)
	S_legacy_mode		<='0'; --LVDS_CONFIG_1(1)
	S_data_word_length	<=(OTHERS=>'0'); --LVDS_CONFIG_1(5 DOWNTO 2)
	S_idle_word		<=(OTHERS=>'0'); --LVDS_CONFIG_1(13 DOWNTO 6)
	S_idle_word_static	<=(OTHERS=>'0'); --LVDS_CONFIG_1(13 DOWNTO 6)
	--Not_Used		<='0'; --LVDS_CONFIG_1(14)

--LVDS_CONFIG_2
	S_start_delay_14DownTo0 	<=(OTHERS=>'0'); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3
	S_start_delay_17DownTo15 	<=(OTHERS=>'0'); --LVDS_CONFIG_3(2 DOWNTO 0)
	S_scrambler_rst			<='0'; --LVDS_CONFIG_3(3)
	S_scrambler_en			<='0'; --LVDS_CONFIG_3(4)
	S_footer_disable		<=(OTHERS=>'0'); --LVDS_CONFIG_3(10 DOWNTO 5)
	S_tm_aci_data			<='0'; --LVDS_CONFIG_3(11)
	S_raw_data_bypass		<='0'; --LVDS_CONFIG_3(12)
	--Not_used			<=(OTHERS=>'0'); --LVDS_CONFIG_3(14 DOWNTO 13)

--Clock_CTRL
	S_hclk_div_cfg		<=(OTHERS=>'0'); --Clock_CTRL(2 DOWNTO 0)
	--Not_used		<=(OTHERS=>'0'); --Clock_CTRL(14 DOWNTO 3)

--PADS_CONFIG_2
	S_itest_dis		<='0'; --PADS_CONFIG_2(0)
	S_d_start_oen		<='0'; --PADS_CONFIG_2(1)
	S_data1_en		<='0'; --PADS_CONFIG_2(2)
	S_data2_en		<='0'; --PADS_CONFIG_2(3)
	--cmos_pad_slew
	--cmos_pad_drv
	--cmos_pad_hyst
	S_clk_en 		<='0'; --PADS_CONFIG_2(9)
	S_daisy_chain		<='0'; --PADS_CONFIG_2(10)
	--reserved		<=(OTHERS=>'0');--PADS_CONFIG_2(14 DOWNTO 11)

--LVDS_START_WORD_0
	S_LVDS_START_WORD_14DownTo0	<=(OTHERS=>'0'); --LVDS_START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--LVDS_START_WORD_1
	S_LVDS_START_WORD_29DownTo15	<=(OTHERS=>'0'); --LVDS_START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--LVDS_START_WORD_2
	S_LVDS_START_WORD_39DownTo30	<=(OTHERS=>'0'); --LVDS_START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>
	--Not_used			<=(OTHERS=>'0'); --LVDS_START_WORD_2(14 DOWNTO 10)
--CRC
	Idle_Bit_Counter<=0;--counts bit number of Idle word
	crc_calc_1<=(others=>'0');
	crc_calc_2<=(others=>'0');

--FOOTER
	LVDS_FOOTER_Bit_Pointer <=0;
	LVDS_FOOTER_Bit_Max_Bit <=13;
	LVDS_FOOTER_1_Completed <=FALSE;
	LVDS_FOOTER_2_Completed <=FALSE;
	LVDS_FOOTER_3_Completed <=FALSE;
	LVDS_FOOTER_4_Completed <=FALSE;
	LVDS_FOOTER_5_Completed <=FALSE;
	LVDS_FOOTER_6_Completed <=FALSE;

Data_IF_Cur_state_type<=Idle;

ELSIF rising_edge (SCLK) then
	CASE Data_IF_Cur_state_type IS

		WHEN Idle=>
			Sync_Last_sample<=Sync;
			Calibration_flag<=calibration;
			V_channel_number:=0;
			--If SET_UP high ->Load operation mode from Register IF
			IF SET_UP='1' THEN
				S_LVDS_start_word_14DownTo0<=LVDS_start_word_14DownTo0;
				S_LVDS_start_word_29DownTo15<=LVDS_start_word_29DownTo15;
				S_LVDS_start_word_39DownTo30<=LVDS_start_word_39DownTo30;

				--Load the data to one vector S_LVDS_start_word(39 DOWNTO 0)
				S_LVDS_start_word(14 DOWNTO 0)<=LVDS_start_word_14DownTo0;
				S_LVDS_start_word(29 DOWNTO 15)<=LVDS_start_word_29DownTo15;
				S_LVDS_start_word(39 DOWNTO 30)<=LVDS_start_word_39DownTo30;

				S_Data_word_length<=Data_word_length;
				CASE Data_word_length IS
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
				S_idle_word<=idle_word;
				S_idle_word_static<=idle_word;
				S_Legacy_mode<=Legacy_mode;
				S_Hclk_div_cfg<=Hclk_div_cfg;
				CASE Hclk_div_cfg IS
				--Define CLK rate
					WHEN "111" =>
						CLK_RATE<=320;
					WHEN "101" =>
						CLK_RATE<=240;
					WHEN "011" =>
						CLK_RATE<=160;
					WHEN "001" =>
						CLK_RATE<=80;
					WHEN OTHERS => NULL;
				END CASE;

				S_Num_data_Lines<=Num_data_Lines;
				CASE Num_data_Lines IS
				--Define numbers of data lines
					WHEN '0' =>
						lines_amount<=1;
					WHEN '1' =>
						lines_amount<=2;
					WHEN OTHERS => NULL;
				END CASE;

				S_D_start_oen<=D_start_oen;
				S_Data1_en<=Data1_en;
				S_Data2_en<=Data2_en;
				S_Clk_en<=Clk_en;
				S_Start_delay_14DownTo0<=Start_delay_14DownTo0;
				S_Start_delay_17DownTo15<=Start_delay_17DownTo15;
				S_Footer_disable<=Footer_disable;

				--Configuration set, sent data out every SYNC
				IF Legacy_mode='0' THEN --SYNC MODE -- with Idle words
					Data_IF_Cur_state_type<=Send_Idles_word_and_Sync_Pulse_Detector;
				ELSIF Legacy_mode='1'AND D_START ='1' AND D_start_oen ='0' THEN  --D_START MODE -- without Idle words
					Data_IF_Cur_state_type<=D_START_DLY;
				END IF;
			END IF;

			--FOOTER
			LVDS_FOOTER_Bit_Pointer <=0;
			LVDS_FOOTER_Bit_Max_Bit <=13;
			LVDS_FOOTER_1_Completed <=FALSE;
			LVDS_FOOTER_2_Completed <=FALSE;
			LVDS_FOOTER_3_Completed <=FALSE;
			LVDS_FOOTER_4_Completed <=FALSE;
			LVDS_FOOTER_5_Completed <=FALSE;
			LVDS_FOOTER_6_Completed <=FALSE;
			--CRC
			CRC_Bit_Counter <=0;
			crc_calc_1<=(others=>'0');
			crc_calc_2<=(others=>'0');

		WHEN D_START_DLY=>
			IF S_tDSTART_DLY<=15 THEN
				S_tDSTART_DLY<=S_tDSTART_DLY+1;
			ELSE
				Data_IF_Cur_state_type<=Send_START_WORD;
				S_tDSTART_DLY<=0;
			END IF;

		WHEN Send_Idles_word_and_Sync_Pulse_Detector=>
IF EN_PULSE ='1' THEN
			Sync_Last_sample<=Sync;
			--Send I0-I7 :Idle Word
			--Counts 8 bits for one Idle word
			--If Idle_Bit_Counter =0 -> a new idle word started
			Idle_Bit_Counter <= Idle_Bit_Counter+1;
			--send data via one or two data lines
			IF num_data_lines='0' AND S_Data1_en='1'THEN--One data lines
				DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
			ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN --num_data_lines='1'--Two data lines
				DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
				DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
			END IF;
			S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right
			IF Idle_Bit_Counter = 7 THEN
			--set Idle_Bit_Counter = 0 every 8 bits
				Idle_Bit_Counter<=0;
			END IF;
			--Identifiy new rising SYNC signal
			IF Sync_Last_sample='0' AND Sync = '1' THEN
				--SYNC rising identified, change cur ctate type
				Idles_Word_Sent_Counter<=0;
				IF Idle_Bit_Counter = 0 THEN
					Data_IF_Cur_state_type<=Send_Idle;
				ELSE
					Data_IF_Cur_state_type<=complete_Idle_word;
				END IF;
			END IF;
END IF;
		WHEN complete_Idle_word=>
IF EN_PULSE='1' THEN
			--complete the idle word that sent before the Sync identified
			IF Idle_Bit_Counter < 7  THEN
				Idle_Bit_Counter<=Idle_Bit_Counter+1;
				--send data via one or two data lines
				IF num_data_lines='0' AND S_Data1_en='1' THEN--One data lines
					DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
				ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN --num_data_lines='1'--Two data lines
					DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
					DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
				END IF;

				S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right

			ELSIF Idle_Bit_Counter = 7 THEN
				--send data via one or two data lines
				IF num_data_lines='0' AND S_Data1_en='1' THEN--One data lines
					DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
				ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN --num_data_lines='1'--Two data lines
					DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
					DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
				END IF;

				S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right
				Idles_Word_Sent_Counter<=0;
				Idle_Bit_Counter <= 0;

				Data_IF_Cur_state_type<=Send_Idle;
			END IF;
END IF;
		WHEN Send_Idle=>
IF EN_PULSE ='1' THEN
			--send new 4 idle word
			--Send I0-I7 :Idle Word
			--Counts "Idle_word" words(according to Datasheet must be less than 5)
			IF Idles_Word_Sent_Counter <= 3  THEN
				CASE Idle_Bit_Counter IS
					WHEN 0 TO 6 =>
					Idle_Bit_Counter<=Idle_Bit_Counter+1;

					--send data via one or two data lines
					IF num_data_lines='0' AND S_Data1_en='1' THEN--One data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
					ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN --num_data_lines='1'--Two data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
						DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
					END IF;

					S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right

					WHEN 7 =>
					--send data via one or two data lines
					IF num_data_lines='0' AND S_Data1_en='1' THEN--One data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
					ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN  --num_data_lines='1'--Two data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
						DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
					END IF;

					S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right
					Idle_Bit_Counter <= 0;
					Idles_Word_Sent_Counter<=Idles_Word_Sent_Counter+1;

					WHEN OTHERS => NULL;
				END CASE;


			ELSIF Idles_Word_Sent_Counter = 4  THEN
			--4 Idle_Words sent
				CASE Idle_Bit_Counter IS
					WHEN 0 TO 6 =>
					Idle_Bit_Counter<=Idle_Bit_Counter+1;
					--send data via one or two data lines
					IF num_data_lines='0' AND S_Data1_en='1' THEN--One data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
					ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN  --num_data_lines='1'--Two data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
						DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
					END IF;
					S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right


					WHEN 7 =>
					--send data via one or two data lines
					IF num_data_lines='0' AND S_Data1_en='1' THEN--One data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
					ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN  --num_data_lines='1'--Two data lines
						DATA1_OUT<=S_idle_word(0);--send serialy Idle word via DATA1_OUT
						DATA2_OUT<=S_idle_word(0);--send serialy Idle word via DATA2_OUT
					END IF;

					S_idle_word<=S_idle_word(0)& S_idle_word(7 downto 1);--shift right
					Idle_Bit_Counter <= 0;

					--Idle_word_completed, sent 5 Idle words
					Idles_Word_Sent_Counter<=0;
					Start_Word_Bit_Counter<= 0;
					Data_IF_Cur_state_type<=Send_START_WORD;--Send_START_WORD;
					--Idle_word_completed = true;
					WHEN OTHERS => NULL;
				END CASE;
			END IF;

END IF;
		WHEN Send_START_WORD=>
IF EN_PULSE ='1' THEN
		--send Start words via one or two data lines
		--Start words are equals at data1_out and data2_out
		--During this state CRC value is calculates as part of the last action (during ELSIF Start_Word_Bit_Counter =(Data_word_length_bits_amount -1))
			IF num_data_lines='0' AND S_Data1_en='1' THEN--one line
				IF Start_Word_Bit_Counter <=(Data_word_length_bits_amount-2) THEN
					Start_Word_Bit_Counter<=Start_Word_Bit_Counter+1;
					DATA1_OUT<=S_LVDS_start_word(0);--send serialy start word via DATA1_OUT
					S_LVDS_start_word((Data_word_length_bits_amount -1) downto 0)<=S_LVDS_start_word(0)& S_LVDS_start_word((Data_word_length_bits_amount -1) downto 1);--shift right

				ELSIF Start_Word_Bit_Counter =(Data_word_length_bits_amount -1) THEN
					Start_Word_Bit_Counter<=Start_Word_Bit_Counter+1;
					DATA1_OUT<=S_LVDS_start_word(0);--send serialy start word via DATA1_OUT
					S_LVDS_start_word((Data_word_length_bits_amount -1) downto 0)<=S_LVDS_start_word(0)& S_LVDS_start_word((Data_word_length_bits_amount -1) downto 1);--shift right


			--read file data, read file that contains xray data
			if Calibration_flag ='0' then
					while (not endfile(F_before_cal_40b)) loop
						readline(F_before_cal_40b,current_read_line_1Data);-- read line from the file
   						read(current_read_line_1Data,current_read_field_1Data(39 downto 0));--read from the txt line and put the info at the pleased type (vector (2..0))
    						--S_Xray_Data1_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						--V_Xray_Data_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						S_Xray_Data1_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						V_Xray_Data_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);

						V_channel_number:=V_channel_number+1;
					end loop;
			elsif Calibration_flag ='1' then
					while (not endfile(F_after_cal_40b)) loop
						readline(F_after_cal_40b,current_read_line_1Data);-- read line from the file
   						read(current_read_line_1Data,current_read_field_1Data(39 downto 0));--read from the txt line and put the info at the pleased type (vector (2..0))
    						--S_Xray_Data1_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						--V_Xray_Data_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						S_Xray_Data1_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						V_Xray_Data_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);

						V_channel_number:=V_channel_number+1;
					end loop;

			END IF;

					Data_IF_Cur_state_type<=Send_XRAY_DATA_One_Line;
					--Calc CRC, one data line
					crc_calc_1		<=	nextCRC16_D16(S_LVDS_start_word(15 DOWNTO 0),crc_calc_1);


				END IF;
			ELSIF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN  --nun_data_lines ='1' --two lines

				IF Start_Word_Bit_Counter <=(Data_word_length_bits_amount-2) THEN
					Start_Word_Bit_Counter<=Start_Word_Bit_Counter+1;
					DATA1_OUT<=S_LVDS_start_word(0);--send serialy start word via DATA1_OUT
					DATA2_OUT<=S_LVDS_start_word(0);--send serialy start word via DATA2_OUT
					S_LVDS_start_word((Data_word_length_bits_amount -1) downto 0)<=S_LVDS_start_word(0)& S_LVDS_start_word((Data_word_length_bits_amount -1) downto 1);--shift right

				ELSIF Start_Word_Bit_Counter =(Data_word_length_bits_amount -1) THEN
					Start_Word_Bit_Counter<=Start_Word_Bit_Counter+1;
					DATA1_OUT<=S_LVDS_start_word(0);--send serialy start word via DATA1_OUT
					DATA2_OUT<=S_LVDS_start_word(0);--send serialy start word via DATA1_OUT
					S_LVDS_start_word((Data_word_length_bits_amount -1) downto 0)<=S_LVDS_start_word(0)& S_LVDS_start_word((Data_word_length_bits_amount -1) downto 1);--shift right

					--read file data, read file that contains xray data
			if Calibration_flag ='0' then
					while (not endfile(F_before_cal_40b)) loop
						readline(F_before_cal_40b,current_read_line_1Data);-- read line from the file
   						read(current_read_line_1Data,current_read_field_1Data(39 downto 0));--read from the txt line and put the info at the pleased type (vector (2..0))
    						--S_Xray_Data1_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						--V_Xray_Data_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						S_Xray_Data1_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						V_Xray_Data_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);

						V_channel_number:=V_channel_number+1;
					end loop;
			elsif Calibration_flag ='1' then
					while (not endfile(F_after_cal_40b)) loop
						readline(F_after_cal_40b,current_read_line_1Data);-- read line from the file
   						read(current_read_line_1Data,current_read_field_1Data(39 downto 0));--read from the txt line and put the info at the pleased type (vector (2..0))
    						--S_Xray_Data1_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						--V_Xray_Data_From_File(((V_channel_number*(Highest_Bits_Val))+Highest_Bits_Val+V_channel_number) downto (V_channel_number*(Highest_Bits_Val)+V_channel_number))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						S_Xray_Data1_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	<=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);
						V_Xray_Data_From_File(((V_channel_number*(MAX_Bits_Val))+Highest_Bits_Val) downto (V_channel_number*(MAX_Bits_Val)))	:=current_read_field_1Data(Highest_Bits_Val DOWNTO 0);

						V_channel_number:=V_channel_number+1;
					end loop;

			END IF;
					Data_IF_Cur_state_type<=Send_XRAY_DATA_Two_Lines;

					--Calc CRC, two data line
					crc_calc_1<=	nextCRC16_D16(S_LVDS_start_word(15 DOWNTO 0),crc_calc_1);
					crc_calc_2<=	nextCRC16_D16(S_LVDS_start_word(15 DOWNTO 0),crc_calc_2);
				END IF;
			END IF;


	END IF;

		WHEN Send_XRAY_DATA_One_Line=>
IF EN_PULSE ='1' THEN
			--Send 256 channels, each channel determined as "channel_number" (0:255)
			--Send data bits resolulion according to "Data_word_length_bits_amount" the defined (24 to 40 bits), represented as S_Xray_Data1
			--During this state CRC value is calculates as part of the last action (during ELSIF Xray_res_Counter=Data_word_length_bits_amount-1)
			IF num_data_lines ='0' AND S_Data1_en='1' THEN--one line

					IF channel_number<=255 THEN--Represent channel number

						IF Xray_res_Counter=0 THEN

							--set data into variable
							V_Xray_Line_Data1_From_File
							(
								(Data_word_length_bits_amount -1) downto 0)
							:=
							V_Xray_Data_From_File
							 	 (
									(
										(channel_number*MAX_BITS_VAL)+(Data_word_length_bits_amount-1)
									 )
									 downto
									(channel_number*MAX_BITS_VAL)
								  );

							--V_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 0):=V_Xray_Data_From_File(((channel_number*MAX_BITS_VAL)+(Data_word_length_bits_amount-1))downto (channel_number*MAX_BITS_VAL));

							--update S_Xray_Line_Data1_From_File only at first bit
							S_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 0)<=
							V_Xray_Data_From_File
							 	 (
									(
										(channel_number*MAX_BITS_VAL)+(Data_word_length_bits_amount-1)
									 )
									 downto
									(channel_number*MAX_BITS_VAL)
								  );

							DATA1_OUT<=V_Xray_Line_Data1_From_File(0);

							--Shift rigeter + inc counter
							Xray_res_Counter<=Xray_res_Counter+1;


						ELSIF Xray_res_Counter<=(Data_word_length_bits_amount-2) THEN  --<30
							V_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 0):=V_Xray_Line_Data1_From_File(0)& V_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 1);--shift right
							DATA1_OUT<=V_Xray_Line_Data1_From_File(0);
							-- inc counter
							Xray_res_Counter<=Xray_res_Counter+1;

						ELSIF Xray_res_Counter=((Data_word_length_bits_amount-1)) THEN  --=31
							--during this state CRC value is caclucate
							Xray_res_Counter<=0;
							channel_number<=channel_number+1;
							DATA1_OUT<=V_Xray_Line_Data1_From_File(0);
							crc_calc_1<=nextCRC16_D16(V_Xray_Line_Data1_From_File(15 DOWNTO 0),crc_calc_1);


							IF channel_number=255 then
								channel_number<=0;
								LVDS_FOOTER_Bit_Pointer<=0;
								Data_IF_Cur_state_type<=Send_FOOTER_One_Line;

							END IF;


						END IF;

					END IF;


			END IF;

END IF;
			WHEN Send_XRAY_DATA_Two_Lines=>
IF EN_PULSE ='1' THEN
			--Send 256 channels, each channel determined as "channel_number" (0:255)
			--Send data bits resolulion according to "Data_word_length_bits_amount" the defined (24 to 40 bits), represented as S_Xray_Data1
			--During this state CRC value is calculates as part of the last action (during ELSIF Xray_res_Counter=Data_word_length_bits_amount-1)
			IF num_data_lines='1' AND S_Data1_en='1' AND S_Data2_en='1' THEN  --nun_data_lines ='1' --two lines

					IF channel_number<=128 THEN
					--channel_number represent the channel value of data 1 channal
					-- channel 2 represented value is according to next equation : data2 channel value = (channel_number+128)
						IF Xray_res_Counter=0 THEN

							--set data into variable
							V_Xray_Line_Data1_From_File
							(
								(Data_word_length_bits_amount -1) downto 0)
							:=
							V_Xray_Data_From_File
							 	 (
									(
										(channel_number*MAX_BITS_VAL)+(Data_word_length_bits_amount-1)
									 )
									 downto
									(channel_number*MAX_BITS_VAL)
								  );

							--V_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 0):=V_Xray_Data_From_File(((channel_number*MAX_BITS_VAL)+(Data_word_length_bits_amount-1))downto (channel_number*MAX_BITS_VAL));

							V_Xray_Line_Data2_From_File
							(
								(Data_word_length_bits_amount -1) downto 0)
							:=V_Xray_Data_From_File
							 	 (
									(
										((channel_number+128)*MAX_BITS_VAL)+(Data_word_length_bits_amount-1)
									 )
									 downto
									((channel_number+128)*MAX_BITS_VAL)
								  );






							--update S_Xray_Line_Data1_From_File only at first bit
							S_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 0)<=
							V_Xray_Data_From_File
							 	 (
									(
										(channel_number*MAX_BITS_VAL)+(Data_word_length_bits_amount-1)
									 )
									 downto
									(channel_number*MAX_BITS_VAL)
								  );

							S_Xray_Line_Data2_From_File((Data_word_length_bits_amount -1) downto 0)<=
							V_Xray_Data_From_File
							 	 (
									(
										((channel_number+128)*MAX_BITS_VAL)+(Data_word_length_bits_amount-1)
									 )
									 downto
									((channel_number+128)*MAX_BITS_VAL)
								  );


							DATA1_OUT<=v_Xray_Line_Data1_From_File(0);
							DATA2_OUT<=v_Xray_Line_Data2_From_File(0);
							--Shift rigeter + inc counter
							Xray_res_Counter<=Xray_res_Counter+1;


						ELSIF Xray_res_Counter<=(Data_word_length_bits_amount-2) THEN  --<30
							V_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 0):=V_Xray_Line_Data1_From_File(0)& V_Xray_Line_Data1_From_File((Data_word_length_bits_amount -1) downto 1);--shift right
							V_Xray_Line_Data2_From_File((Data_word_length_bits_amount -1) downto 0):=V_Xray_Line_Data2_From_File(0)& V_Xray_Line_Data2_From_File((Data_word_length_bits_amount -1) downto 1);--shift right--
							DATA1_OUT<=V_Xray_Line_Data1_From_File(0);
							DATA2_OUT<=V_Xray_Line_Data2_From_File(0);
							-- inc counter
							Xray_res_Counter<=Xray_res_Counter+1;

						ELSIF Xray_res_Counter=((Data_word_length_bits_amount-1)) THEN  --=31
							--during this state CRC value is caclucate
							Xray_res_Counter<=0;
							channel_number<=channel_number+1;

							DATA1_OUT<=V_Xray_Line_Data1_From_File(0);
							DATA2_OUT<=V_Xray_Line_Data2_From_File(0);

							crc_calc_1<=nextCRC16_D16(V_Xray_Line_Data1_From_File(15 DOWNTO 0),crc_calc_1);
							crc_calc_2<=nextCRC16_D16(V_Xray_Line_Data2_From_File(15 DOWNTO 0),crc_calc_2);
							IF channel_number=127 THEN
							--Data 1 channel_number value =127 (0..127 sent)
							--Data 2 channel_number value =255 (128..255 sent)
								channel_number<=0;
								Data_IF_Cur_state_type<=Send_FOOTER_Two_Lines;
							END IF;
						END IF;
					END IF;

			END IF;

END IF;

		WHEN Send_FOOTER_One_Line=>
IF EN_PULSE ='1' THEN
-- Send footer
		-- The footer contains of six registers that may be added to the end of the channel data stream.
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
--during this state a CRC word calculates
		--Register 1
		IF S_footer_disable(0)='0' AND LVDS_FOOTER_1_Completed=FALSE THEN
		--Register enabled
		--TEMP_SENSOR (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_1_Completed=FALSE   THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_1_reg_addr(0);
				S_footer_1_reg_addr<=S_footer_1_reg_addr(0) & S_footer_1_reg_addr(15 downto 1);--shift right
			ELSIF LVDS_FOOTER_Bit_Pointer=LVDS_FOOTER_Bit_Max_Bit then --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_1_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_1_reg_addr(0);
				--Calc CRC,one data line
				crc_calc_1<=nextCRC16_D16(S_footer_1_reg_addr(15 DOWNTO 0),crc_calc_1);
				--complete the shift (more 3 steps)
				S_footer_1_reg_addr<=S_footer_1_reg_addr(2 downto 0) & S_footer_1_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(0)='1' AND LVDS_FOOTER_1_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_1_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 2
		ELSIF S_footer_disable(1)='0' AND LVDS_FOOTER_2_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_2_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_2_reg_addr(0);
				S_footer_2_reg_addr<=S_footer_2_reg_addr(0) & S_footer_2_reg_addr(15 downto 1);--shift right
			ELSIF LVDS_FOOTER_Bit_Pointer=LVDS_FOOTER_Bit_Max_Bit then --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_2_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_2_reg_addr(0);
				--Calc CRC,one data line
				crc_calc_1<=nextCRC16_D16(S_footer_2_reg_addr(15 DOWNTO 0),crc_calc_1);
				--complete the shift (more 3 steps)
				S_footer_2_reg_addr<=S_footer_2_reg_addr(2 downto 0) & S_footer_2_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(1)='1' AND LVDS_FOOTER_2_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_2_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 3
		ELSIF S_footer_disable(2)='0' AND LVDS_FOOTER_3_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_3_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_3_reg_addr(0);
				S_footer_3_reg_addr<=S_footer_3_reg_addr(0) & S_footer_3_reg_addr(15 downto 1);--shift right
			ELSIF LVDS_FOOTER_Bit_Pointer=LVDS_FOOTER_Bit_Max_Bit then --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_3_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_3_reg_addr(0);
				--Calc CRC,one data line
				crc_calc_1<=nextCRC16_D16(S_footer_3_reg_addr(15 DOWNTO 0),crc_calc_1);
				--complete the shift (more 3 steps)
				S_footer_3_reg_addr<=S_footer_3_reg_addr(2 downto 0) & S_footer_3_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(2)='1' AND LVDS_FOOTER_3_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_3_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;


		--Register 4
		ELSIF S_footer_disable(3)='0' AND LVDS_FOOTER_4_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_4_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_4_reg_addr(0);
				S_footer_4_reg_addr<=S_footer_4_reg_addr(0) & S_footer_4_reg_addr(15 downto 1);--shift right
			ELSIF LVDS_FOOTER_Bit_Pointer=LVDS_FOOTER_Bit_Max_Bit then --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_4_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_4_reg_addr(0);
				--Calc CRC,one data line
				crc_calc_1<=nextCRC16_D16(S_footer_4_reg_addr(15 DOWNTO 0),crc_calc_1);
				--complete the shift (more 3 steps)
				S_footer_4_reg_addr<=S_footer_4_reg_addr(2 downto 0) & S_footer_4_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(3)='1' AND LVDS_FOOTER_4_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_4_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 5
		ELSIF S_footer_disable(4)='0' AND LVDS_FOOTER_5_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_5_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_5_reg_addr(0);
				S_footer_5_reg_addr<=S_footer_5_reg_addr(0) & S_footer_5_reg_addr(15 downto 1);--shift right
			ELSIF LVDS_FOOTER_Bit_Pointer=LVDS_FOOTER_Bit_Max_Bit then --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_5_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_5_reg_addr(0);
				--Calc CRC,one data line
				crc_calc_1<=nextCRC16_D16(S_footer_5_reg_addr(15 DOWNTO 0),crc_calc_1);
				--complete the shift (more 3 steps)
				S_footer_5_reg_addr<=S_footer_5_reg_addr(2 downto 0) & S_footer_5_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(4)='1' AND LVDS_FOOTER_5_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_5_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 6
		ELSIF S_footer_disable(5)='0' AND LVDS_FOOTER_6_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_6_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_6_reg_addr(0);
				S_footer_6_reg_addr<=S_footer_6_reg_addr(0) & S_footer_6_reg_addr(15 downto 1);--shift right
			ELSIF LVDS_FOOTER_Bit_Pointer=LVDS_FOOTER_Bit_Max_Bit then --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_6_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_6_reg_addr(0);
				--Calc CRC,one data line
				crc_calc_1<=nextCRC16_D16(S_footer_6_reg_addr(15 downto 0),crc_calc_1);
				--complete the shift (more 3 steps)
				S_footer_6_reg_addr<=S_footer_6_reg_addr(2 downto 0) & S_footer_6_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(5)='1' AND LVDS_FOOTER_6_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_6_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;
		ELSE

			Data_IF_Cur_state_type<=Send_CRC_word_One_Line;
			--footer clear for next time
			LVDS_FOOTER_Bit_Pointer <=0;
			LVDS_FOOTER_Bit_Max_Bit <=13;
			LVDS_FOOTER_1_Completed <=FALSE;
			LVDS_FOOTER_2_Completed <=FALSE;
			LVDS_FOOTER_3_Completed <=FALSE;
			LVDS_FOOTER_4_Completed <=FALSE;
			LVDS_FOOTER_5_Completed <=FALSE;
			LVDS_FOOTER_6_Completed <=FALSE;

			--CRC_Bit_Counter<=0;

		END IF;
END IF;
WHEN Send_FOOTER_Two_Lines=>
IF EN_PULSE ='1' THEN
-- Send footer
		-- The footer contains of six registers that may be added to the end of the channel data stream.
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
--during this state a CRC word calculates
		--Register 1
		IF S_footer_disable(0)='0' AND LVDS_FOOTER_1_Completed=FALSE THEN
		--Register enabled
		--TEMP_SENSOR (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_1_Completed=FALSE   THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_1_reg_addr(0);
				Data2_out<=S_footer_1_reg_addr(0);
				S_footer_1_reg_addr<=S_footer_1_reg_addr(0) & S_footer_1_reg_addr(15 downto 1);--shift right
			ELSE --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_1_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_1_reg_addr(0);
				--Calc CRC,Two data lines
				crc_calc_1<=nextCRC16_D16(S_footer_1_reg_addr(15 DOWNTO 0),crc_calc_1);
				crc_calc_2<=nextCRC16_D16(S_footer_1_reg_addr(15 DOWNTO 0),crc_calc_2);
				--complete the shift (more 3 steps)
				S_footer_1_reg_addr<=S_footer_1_reg_addr(2 downto 0) & S_footer_1_reg_addr(15 downto 3);--shift right


			END IF;
		ELSIF S_footer_disable(0)='1' AND LVDS_FOOTER_1_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_1_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 2
		ELSIF S_footer_disable(1)='0' AND LVDS_FOOTER_2_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_2_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_2_reg_addr(0);
				Data2_out<=S_footer_2_reg_addr(0);
				S_footer_2_reg_addr<=S_footer_2_reg_addr(0) & S_footer_2_reg_addr(15 downto 1);--shift right
			ELSE --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_2_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_2_reg_addr(0);
				--Calc CRC,Two data lines
				crc_calc_1<=nextCRC16_D16(S_footer_2_reg_addr(15 DOWNTO 0),crc_calc_1);
				crc_calc_2<=nextCRC16_D16(S_footer_2_reg_addr(15 DOWNTO 0),crc_calc_2);
				--complete the shift (more 3 steps)
				S_footer_2_reg_addr<=S_footer_2_reg_addr(2 downto 0) & S_footer_2_reg_addr(15 downto 3);--shift right


			END IF;
		ELSIF S_footer_disable(1)='1' AND LVDS_FOOTER_2_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_2_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 3
		ELSIF S_footer_disable(2)='0' AND LVDS_FOOTER_3_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_3_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_3_reg_addr(0);
				Data2_out<=S_footer_3_reg_addr(0);
				S_footer_3_reg_addr<=S_footer_3_reg_addr(0) & S_footer_3_reg_addr(15 downto 1);--shift right
			ELSE --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_3_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_3_reg_addr(0);
				--Calc CRC,Two data lines
				crc_calc_1<=nextCRC16_D16(S_footer_3_reg_addr(15 DOWNTO 0),crc_calc_1);
				crc_calc_2<=nextCRC16_D16(S_footer_3_reg_addr(15 DOWNTO 0),crc_calc_2);
				--complete the shift (more 3 steps)
				S_footer_3_reg_addr<=S_footer_3_reg_addr(2 downto 0) & S_footer_3_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(2)='1' AND LVDS_FOOTER_3_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_3_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;


		--Register 4
		ELSIF S_footer_disable(3)='0' AND LVDS_FOOTER_4_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_4_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_4_reg_addr(0);
				Data2_out<=S_footer_4_reg_addr(0);
				S_footer_4_reg_addr<=S_footer_4_reg_addr(0) & S_footer_4_reg_addr(15 downto 1);--shift right
			ELSE --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_4_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_4_reg_addr(0);
				--Calc CRC,Two data lines
				crc_calc_1<=nextCRC16_D16(S_footer_4_reg_addr(15 DOWNTO 0),crc_calc_1);
				crc_calc_2<=nextCRC16_D16(S_footer_4_reg_addr(15 DOWNTO 0),crc_calc_2);
				--complete the shift (more 3 steps)
				S_footer_4_reg_addr<=S_footer_4_reg_addr(2 downto 0) & S_footer_4_reg_addr(15 downto 3);--shift right

			END IF;
		ELSIF S_footer_disable(3)='1' AND LVDS_FOOTER_4_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_4_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 5
		ELSIF S_footer_disable(4)='0' AND LVDS_FOOTER_5_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_5_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_5_reg_addr(0);
				Data2_out<=S_footer_5_reg_addr(0);
				S_footer_5_reg_addr<=S_footer_5_reg_addr(0) & S_footer_5_reg_addr(15 downto 1);--shift right
			ELSE --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_5_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_5_reg_addr(0);
				--Calc CRC,Two data lines
				crc_calc_1<=nextCRC16_D16(S_footer_5_reg_addr(15 DOWNTO 0),crc_calc_1);
				crc_calc_2<=nextCRC16_D16(S_footer_5_reg_addr(15 DOWNTO 0),crc_calc_2);
				--complete the shift (more 3 steps)
				S_footer_5_reg_addr<=S_footer_5_reg_addr(2 downto 0) & S_footer_5_reg_addr(15 downto 3);--shift right
			END IF;
		ELSIF S_footer_disable(4)='1' AND LVDS_FOOTER_5_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_5_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;

		--Register 6
		ELSIF S_footer_disable(5)='0' AND LVDS_FOOTER_6_Completed=FALSE THEN
		--Register enabled
		--IP (read only)
			IF LVDS_FOOTER_Bit_Pointer<LVDS_FOOTER_Bit_Max_Bit AND LVDS_FOOTER_6_Completed=FALSE THEN
				LVDS_FOOTER_Bit_Pointer<=LVDS_FOOTER_Bit_Pointer+1;
				Data1_out<=S_footer_6_reg_addr(0);
				Data2_out<=S_footer_6_reg_addr(0);
				S_footer_6_reg_addr<=S_footer_6_reg_addr(0) & S_footer_6_reg_addr(15 downto 1);--shift right
			ELSE --  LVDS_FOOTER_Bit_Pointer=13/last bit
--during the last bit crc word is calcluates
				LVDS_FOOTER_6_Completed<=True;
				LVDS_FOOTER_Bit_Pointer<=0;
				Data1_out<=S_footer_6_reg_addr(0);
				--Calc CRC,Two data lines
				crc_calc_1<=nextCRC16_D16(S_footer_6_reg_addr(15 DOWNTO 0),crc_calc_1);
				crc_calc_2<=nextCRC16_D16(S_footer_6_reg_addr(15 DOWNTO 0),crc_calc_2);
				--complete the shift (more 3 steps)
				S_footer_6_reg_addr<=S_footer_6_reg_addr(2 downto 0) & S_footer_6_reg_addr(15 downto 3);--shift right
			END IF;
		ELSIF S_footer_disable(5)='1' AND LVDS_FOOTER_6_Completed=FALSE THEN
		--Register disabled
			LVDS_FOOTER_6_Completed<=True;
			LVDS_FOOTER_Bit_Pointer<=0;
		ELSE
			Data_IF_Cur_state_type<=Send_CRC_word_Two_Lines;
			--footer clear for next time
			LVDS_FOOTER_Bit_Pointer <=0;
			LVDS_FOOTER_Bit_Max_Bit <=13;
			LVDS_FOOTER_1_Completed <=FALSE;
			LVDS_FOOTER_2_Completed <=FALSE;
			LVDS_FOOTER_3_Completed <=FALSE;
			LVDS_FOOTER_4_Completed <=FALSE;
			LVDS_FOOTER_5_Completed <=FALSE;
			LVDS_FOOTER_6_Completed <=FALSE;
			CRC_Bit_Counter<=0;
		END IF;
END IF;
WHEN Send_CRC_word_One_Line=>
IF EN_PULSE ='1' THEN
		IF CRC_Bit_Counter <= 15 THEN
			Data1_out<=crc_calc_1(0);
			crc_calc_1<=crc_calc_1(0) & crc_calc_1(15 downto 1);--shift right
			CRC_Bit_Counter<=CRC_Bit_Counter+1;
			IF CRC_Bit_Counter = 15 THEN
				IF Legacy_mode='0' THEN --SYNC MODE -- with Idle words
					Data_IF_Cur_state_type<=Idle;--Send_Idles_word_and_Sync_Pulse_Detector;
					crc_calc_1<=(others=>'0');
				ELSIF Legacy_mode='1'AND D_START ='1' AND D_start_oen ='0' THEN  --D_START MODE -- without Idle words
					Data_IF_Cur_state_type<=D_START_DLY;
					crc_calc_1<=(others=>'0');
				END IF;
				CRC_Bit_Counter <=0;
			END IF;

		END IF;
END IF;


WHEN Send_CRC_word_Two_Lines=>
IF EN_PULSE ='1' THEN
		IF CRC_Bit_Counter < 15 THEN
			Data1_out<=crc_calc_1(0);
			crc_calc_1<=crc_calc_1(0) & crc_calc_1(15 downto 1);--shift right
			Data2_out<=crc_calc_2(0);
			crc_calc_2<=crc_calc_2(0) & crc_calc_2(15 downto 1);--shift right
			CRC_Bit_Counter<=CRC_Bit_Counter+1;

		ELSIF CRC_Bit_Counter = 15 THEN
			IF Legacy_mode='0' THEN --SYNC MODE -- with Idle words
				Data_IF_Cur_state_type<=Idle;--Send_Idles_word_and_Sync_Pulse_Detector;
				crc_calc_1<=(others=>'0');
				crc_calc_2<=(others=>'0');
			ELSIF Legacy_mode='1'AND D_START ='1' AND D_start_oen ='0' THEN  --D_START MODE -- without Idle words
				Data_IF_Cur_state_type<=D_START_DLY;
				crc_calc_1<=(others=>'0');
				crc_calc_2<=(others=>'0');
			END IF;
				CRC_Bit_Counter <=0;


		END IF;


END IF;

	WHEN OTHERS=> NULL;
	END CASE;


END IF;

END PROCESS;



p1_COUNTER:PROCESS(SCLK,RST)


BEGIN
IF RST='1' THEN
	CLK_COUNTER<=(OTHERS=>'0');
ELSIF RISING_EDGE(SCLK) THEN

	IF CLK_COUNTER=X"3" THEN
		CLK_COUNTER<=(OTHERS=>'0');
	ELSE
		CLK_COUNTER<=CLK_COUNTER+1;

	END IF;

END IF;
END PROCESS;

P2_SEND_CLK_OUT: PROCESS (SCLK,rst)
BEGIN
IF RST='1' THEN
	S_Clk_DIV<=0;
ELSIF RISING_EDGE(SCLK) THEN
	CASE ('0' & Hclk_div_cfg) IS
		WHEN X"7"=>--320Mhz
			S_Clk_Rate<=SCLK;
			S_Clk_DIV<=0;
		WHEN X"5"=>NULL;
		WHEN X"3"=>--160Mhz
			S_Clk_Rate<=CLK_COUNTER(0);
			S_Clk_DIV<=1;

		WHEN X"1"=>--80MHz
			S_Clk_Rate<=CLK_COUNTER(1);
			S_Clk_DIV<=4;
		WHEN OTHERS=>--320Mhz
			S_Clk_DIV<=0;

		END CASE;
END IF;
END PROCESS;


EN_COUNTER: PROCESS (rst,S_Clk_Rate)
--this process creat enable flag that responsible for the enable flag
BEGIN
IF RST='1' THEN
	EN_PULSE<=S_Clk_Rate;
ELSIF RISING_EDGE(S_Clk_Rate) THEN
	EN_PULSE<='1';
ELSE
	EN_PULSE<='0';
END IF;
END PROCESS;




END DATA_IF_arc;
