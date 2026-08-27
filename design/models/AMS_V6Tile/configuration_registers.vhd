
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY Configuration_Registers  IS

PORT(
	
	RST			: IN STD_LOGIC;
	SClk			: IN STD_LOGIC;
	LVDS_CONFIG_1		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	LVDS_CONFIG_2		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	LVDS_CONFIG_3		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	Clock_CTRL		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	PADS_CONFIG_2		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	LVDS_START_WORD_0	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	LVDS_START_WORD_1	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	LVDS_START_WORD_2	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	DONE_WRITE		: IN STD_LOGIC ;--'0' while reading/'1' done reading
	Calibration_done 	: IN STD_LOGIC ;--0 not calibrated, 1 calibrated
	Calibration	: OUT STD_LOGIC; 
	OperationMode	: OUT STD_LOGIC; 
	set_up		: OUT STD_LOGIC;

--LVDS_CONFIG_1
	num_data_lines	: OUT STD_LOGIC; --LVDS_CONFIG_1(0)
	legacy_mode	: OUT STD_LOGIC; --LVDS_CONFIG_1(1)
	data_word_length: OUT STD_LOGIC_VECTOR (3 DOWNTO 0); --LVDS_CONFIG_1(5 DOWNTO 2)
	idle_word	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); --LVDS_CONFIG_1(13 DOWNTO 6)
	--Not_Used	: OUT STD_LOGIC; --LVDS_CONFIG_1(14)

--LVDS_CONFIG_2 
	start_delay_14DownTo0	:OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3 
	start_delay_17DownTo15	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --LVDS_CONFIG_3(2 DOWNTO 0)
	scrambler_rst		: OUT STD_LOGIC; --LVDS_CONFIG_3(3)
	scrambler_en		: OUT STD_LOGIC; --LVDS_CONFIG_3(4)
	footer_disable		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0); --LVDS_CONFIG_3(10 DOWNTO 5)
	tm_aci_data		: OUT STD_LOGIC; --LVDS_CONFIG_3(11)
	raw_data_bypass		: OUT STD_LOGIC; --LVDS_CONFIG_3(12)
	--Not_used		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0); --LVDS_CONFIG_3(14 DOWNTO 13)

--Clock_CTRL
	hclk_div_cfg	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --Clock_CTRL(2 DOWNTO 0)
	--Not_used	: OUT STD_LOGIC_VECTOR (12 DOWNTO 0); --Clock_CTRL(14 DOWNTO 3)

--PADS_CONFIG_2
	itest_dis	: OUT STD_LOGIC; --PADS_CONFIG_2(0)
	d_start_oen	: OUT STD_LOGIC; --PADS_CONFIG_2(1)
	data1_en	: OUT STD_LOGIC; --PADS_CONFIG_2(2)
	data2_en	: OUT STD_LOGIC; --PADS_CONFIG_2(3)
	--cmos_pad_slew
	--cmos_pad_drv
	--cmos_pad_hyst
	clk_en 		: OUT STD_LOGIC; --PADS_CONFIG_2(9)
	daisy_chain	: OUT STD_LOGIC; --PADS_CONFIG_2(10)
	--reserved	: OUT STD_LOGIC_VECTOR (3 DOWNTO 0); --PADS_CONFIG_2(14 DOWNTO 11)

--LVDS_START_WORD_0
	LVDS_START_WORD_14DownTo0	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--LVDS_START_WORD_1
	LVDS_START_WORD_29DownTo15	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--LVDS_START_WORD_2
	LVDS_START_WORD_39DownTo30	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0) --LVDS_START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>
	--Not_used		: OUT STD_LOGIC_VECTOR (4 DOWNTO 0); --LVDS_START_WORD_2(14 DOWNTO 10)

	
	);
END Configuration_Registers ;

ARCHITECTURE Configuration_Registers_arc OF Configuration_Registers  IS

BEGIN
p1: process (RST,SCLK)


BEGIN
IF RST='1' THEN

--set_up is an indication of signal update status - 0 not updated, 1 updated	
	set_up<=DONE_WRITE;--'0' while reading/'1' done reading
--LVDS_CONFIG_1
	num_data_lines	<='0'; --LVDS_CONFIG_1(0)
	legacy_mode	<='0'; --LVDS_CONFIG_1(1)
	data_word_length<=(OTHERS=>'0'); --LVDS_CONFIG_1(5 DOWNTO 2)
	idle_word	<=(OTHERS=>'0'); --LVDS_CONFIG_1(13 DOWNTO 6)
	--Not_Used	<='0'; --LVDS_CONFIG_1(14)

--LVDS_CONFIG_2 
	start_delay_14DownTo0 	<=(OTHERS=>'0'); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3 
	start_delay_17DownTo15 	<=(OTHERS=>'0'); --LVDS_CONFIG_3(2 DOWNTO 0)
	scrambler_rst		<='0'; --LVDS_CONFIG_3(3)
	scrambler_en		<='0'; --LVDS_CONFIG_3(4)
	footer_disable		<=(OTHERS=>'0'); --LVDS_CONFIG_3(10 DOWNTO 5)
	tm_aci_data		<='0'; --LVDS_CONFIG_3(11)
	raw_data_bypass		<='0'; --LVDS_CONFIG_3(12)
	--Not_used		<=(OTHERS=>'0'); --LVDS_CONFIG_3(14 DOWNTO 13)

--Clock_CTRL
	hclk_div_cfg	<=(OTHERS=>'0'); --Clock_CTRL(2 DOWNTO 0)
	--Not_used	<=(OTHERS=>'0'); --Clock_CTRL(14 DOWNTO 3)

--PADS_CONFIG_2
	itest_dis	<='0'; --PADS_CONFIG_2(0)
	d_start_oen	<='0'; --PADS_CONFIG_2(1)
	data1_en	<='0'; --PADS_CONFIG_2(2)
	data2_en	<='0'; --PADS_CONFIG_2(3)
	--cmos_pad_slew
	--cmos_pad_drv
	--cmos_pad_hyst
	clk_en 		<='0'; --PADS_CONFIG_2(9)
	daisy_chain	<='0'; --PADS_CONFIG_2(10)
	--reserved	<=(OTHERS=>'0');--PADS_CONFIG_2(14 DOWNTO 11)

--LVDS_START_WORD_0
	LVDS_START_WORD_14DownTo0	<=(OTHERS=>'0'); --LVDS_START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--LVDS_START_WORD_1
	LVDS_START_WORD_29DownTo15	<=(OTHERS=>'0'); --LVDS_START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--LVDS_START_WORD_2
	LVDS_START_WORD_39DownTo30	<=(OTHERS=>'0'); --LVDS_START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>
	--Not_used		<=(OTHERS=>'0'); --LVDS_START_WORD_2(14 DOWNTO 10)
--calibration 
	Calibration<=Calibration_done;

ELSIF rising_edge(SClk)  THEN 
--calibration 
	Calibration<=Calibration_done;
--set_up is an indication of signal update status - 0 not updated, 1 updated	
	set_up<=DONE_WRITE ;--'0' while reading/'1' done reading
--LVDS_CONFIG_1
	num_data_lines	<=LVDS_CONFIG_1(0);
	legacy_mode	<=LVDS_CONFIG_1(1);
	data_word_length<=LVDS_CONFIG_1(5 DOWNTO 2);
	idle_word	<=LVDS_CONFIG_1(13 DOWNTO 6);
	--Not_Used	<=LVDS_CONFIG_1(14);

--LVDS_CONFIG_2 
	start_delay_14DownTo0 	<=LVDS_CONFIG_2(14 DOWNTO 0);

--LVDS_CONFIG_3 
	start_delay_17DownTo15	<=LVDS_CONFIG_3(2 DOWNTO 0);
	scrambler_rst		<=LVDS_CONFIG_3(3);
	scrambler_en		<=LVDS_CONFIG_3(4);
	footer_disable		<=LVDS_CONFIG_3(10 DOWNTO 5);
	tm_aci_data		<=LVDS_CONFIG_3(11);
	raw_data_bypass		<=LVDS_CONFIG_3(12);
	--Not_used		<=LVDS_CONFIG_3(14 DOWNTO 13);

--Clock_CTRL
	hclk_div_cfg	<=Clock_CTRL(2 DOWNTO 0);
	--Not_used	<=Clock_CTRL(14 DOWNTO 3);

--PADS_CONFIG_2
	itest_dis	<=PADS_CONFIG_2(0);
	d_start_oen	<=PADS_CONFIG_2(1);
	data1_en	<=PADS_CONFIG_2(2);
	data2_en	<=PADS_CONFIG_2(3);
	--cmos_pad_slew
	--cmos_pad_drv
	--cmos_pad_hyst
	clk_en 		<=PADS_CONFIG_2(9);
	daisy_chain	<=PADS_CONFIG_2(10);
	--reserved	<=PADS_CONFIG_2(14 DOWNTO 11);

--LVDS_START_WORD_0
	LVDS_START_WORD_14DownTo0	<=LVDS_START_WORD_0(14 DOWNTO 0);--, Start Word bits <14:0>

--LVDS_START_WORD_1
	LVDS_START_WORD_29DownTo15	<=LVDS_START_WORD_1(14 DOWNTO 0);--, Start Word bits <29:15>

--LVDS_START_WORD_2
	LVDS_START_WORD_39DownTo30	<=LVDS_START_WORD_2(9 DOWNTO 0);--, Start Word bits <39:30>
	--Not_used		<=LVDS_CONFIG_2(14 DOWNTO 10);


END IF;

END PROCESS;

OperationMode <= '1'; -- !debug: def value

END Configuration_Registers_arc;
 