library ieee;
USE IEEE.STD_LOGIC_1164.ALL;

USE work.AMS_pack.ALL;

ENTITY Register_Data_IF IS

port(
	--Register_IF INPUTS--
	SCLK	: IN STD_LOGIC;
	RST	: IN STD_LOGIC;
	SDO	: IN STD_LOGIC; --FPGA to ASIC
	SCn	: IN STD_LOGIC;


	--DATA_IF INPUTS--
	SYNC 	: IN STD_LOGIC;
	ACLK 	:IN STD_LOGIC; --FPGA to ASIC
	D_START	: IN STD_LOGIC;
	DISCARD	: IN STD_LOGIC;


	--Register IF OUTPUT--
	SDI	: OUT STD_LOGIC; -- ASIC to FPGA

	--DATA IF OUTPUT--
	Operation_Mode_Initialized 	:OUT STD_LOGIC;
	Data_Out_en  			:OUT STD_LOGIC;
	DATA1_OUT: OUT STD_LOGIC;
	DATA2_OUT: OUT STD_LOGIC
);


END Register_Data_IF;



ARCHITECTURE Register_DATA_IF_arc OF Register_DATA_IF IS

--COMPONENTS

Component Register_IF

Port(
	SCLK		: IN STD_LOGIC;
	SDO		: IN STD_LOGIC; --FPGA to ASIC
	SCn		: IN STD_LOGIC;
	RST		: IN STD_LOGIC;
	SDI		: OUT STD_LOGIC; -- ASIC to FPGA
	CALIBRATION	: OUT STD_LOGIC;
	OPERATIONMODE	: OUT STD_LOGIC;
	SET_UP		: OUT STD_LOGIC;	--DONE_WRITE: '0' while reading/'1' done reading
--Configuration Registers outputs
--LVDS_CONFIG_1
	num_data_lines	: OUT STD_LOGIC; --LVDS_CONFIG_1(0)
	legacy_mode	: OUT STD_LOGIC; --LVDS_CONFIG_1(1)
	data_word_length: OUT STD_LOGIC_VECTOR (3 DOWNTO 0); --LVDS_CONFIG_1(5 DOWNTO 2)
	idle_word	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); --LVDS_CONFIG_1(13 DOWNTO 6)

--LVDS_CONFIG_2
	start_delay_14DownTo0	:OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3
	start_delay_17DownTo15	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --LVDS_CONFIG_3(2 DOWNTO 0)
	scrambler_rst		: OUT STD_LOGIC; --LVDS_CONFIG_3(3)
	scrambler_en		: OUT STD_LOGIC; --LVDS_CONFIG_3(4)
	footer_disable		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0); --LVDS_CONFIG_3(10 DOWNTO 5)
	tm_aci_data		: OUT STD_LOGIC; --LVDS_CONFIG_3(11)
	raw_data_bypass		: OUT STD_LOGIC; --LVDS_CONFIG_3(12)

--Clock_CTRL
	hclk_div_cfg	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --Clock_CTRL(2 DOWNTO 0)

--PADS_CONFIG_2
	itest_dis	: OUT STD_LOGIC; --PADS_CONFIG_2(0)
	d_start_oen	: OUT STD_LOGIC; --PADS_CONFIG_2(1)
	data1_en	: OUT STD_LOGIC; --PADS_CONFIG_2(2)
	data2_en	: OUT STD_LOGIC; --PADS_CONFIG_2(3)
	clk_en 		: OUT STD_LOGIC; --PADS_CONFIG_2(9)
	daisy_chain	: OUT STD_LOGIC; --PADS_CONFIG_2(10)

--START_WORD_0
	LVDS_start_word_14DownTo0	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--START_WORD_1
	LVDS_start_word_29DownTo15	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--START_WORD_2
	LVDS_start_word_39DownTo30	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0) --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>


);
End component;


Component DATA_IF
PORT(
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
	Operation_Mode_Initialized 	: OUT STD_LOGIC;
	Data_Out_en  			: OUT STD_LOGIC;
	DATA1_OUT  			: OUT STD_LOGIC;
	DATA2_OUT  			: OUT STD_LOGIC

	);

	End component;




------SIGNAL Declaration-------

SIGNAL S_SDO : Std_logic:='0';--FPGA to ASIC (IN)
SIGNAL S_SCn : Std_logic:='1';
SIGNAL S_SDI : Std_logic:='1';
SIGNAL S_SET_UP : Std_logic:='1';
SIGNAL S_OPERATIONMODE : Std_logic:='1';
SIGNAL S_CALIBRATION: Std_logic:='0';



--SIGNAL S_SYNC	:  STD_LOGIC;
SIGNAL S_ACLK	:  STD_LOGIC; --FPGA to ASIC
SIGNAL S_D_START:  STD_LOGIC;
SIGNAL S_DISCARD:  STD_LOGIC;


--Connection between modules
--LVDS_CONFIG_1
SIGNAL S_num_data_lines		: STD_LOGIC:='0'; --LVDS_CONFIG_1(0)
SIGNAL S_legacy_mode		: STD_LOGIC:='0'; --LVDS_CONFIG_1(1)
SIGNAL S_data_word_length	: STD_LOGIC_VECTOR (3 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_1(5 DOWNTO 2)
SIGNAL S_idle_word		: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_1(13 DOWNTO 6)

--LVDS_CONFIG_2
SIGNAL S_start_delay_14DownTo0	:STD_LOGIC_VECTOR (14 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3
SIGNAL S_start_delay_17DownTo15	: STD_LOGIC_VECTOR (2 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_3(2 DOWNTO 0)
SIGNAL S_scrambler_rst		: STD_LOGIC:='0'; --LVDS_CONFIG_3(3)
SIGNAL S_scrambler_en		: STD_LOGIC:='0'; --LVDS_CONFIG_3(4)
SIGNAL S_footer_disable		: STD_LOGIC_VECTOR (5 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_3(10 DOWNTO 5)
SIGNAL S_tm_aci_data		: STD_LOGIC:='0'; --LVDS_CONFIG_3(11)
SIGNAL S_raw_data_bypass	: STD_LOGIC:='0'; --LVDS_CONFIG_3(12)

--Clock_CTRL
SIGNAL S_hclk_div_cfg		: STD_LOGIC_VECTOR (2 DOWNTO 0):=(others=>'0'); --Clock_CTRL(2 DOWNTO 0)

--PADS_CONFIG_2
SIGNAL S_itest_dis		: STD_LOGIC:='0'; --PADS_CONFIG_2(0)
SIGNAL S_d_start_oen		: STD_LOGIC:='0'; --PADS_CONFIG_2(1)
SIGNAL S_data1_en		: STD_LOGIC:='0'; --PADS_CONFIG_2(2)
SIGNAL S_data2_en		: STD_LOGIC:='0'; --PADS_CONFIG_2(3)
SIGNAL S_clk_en 		: STD_LOGIC:='0'; --PADS_CONFIG_2(9)
SIGNAL S_daisy_chain		: STD_LOGIC:='0'; --PADS_CONFIG_2(10)

--START_WORD_0
SIGNAL S_LVDS_start_word_14DownTo0	: STD_LOGIC_VECTOR (14 DOWNTO 0):=(others=>'0'); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--START_WORD_1
SIGNAL S_LVDS_start_word_29DownTo15	: STD_LOGIC_VECTOR (14 DOWNTO 0):=(others=>'0'); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--START_WORD_2
SIGNAL S_LVDS_start_word_39DownTo30	: STD_LOGIC_VECTOR (9 DOWNTO 0):=(others=>'0'); --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>



BEGIN
U1_Register_IF: Register_IF
Port map
	(SCLK=>SCLK,
	--SDO=>S_SDO,
	--SCn=>S_SCn,
	SDO=>SDO,
	SCn=>SCn,
	RST=>rst,
	--SDI=>S_SDI ,
	SDI=>SDI,
	CALIBRATION=>	S_CALIBRATION,
	--OPERATIONMODE=>	OPERATIONMODE
	SET_UP=>S_SET_UP,

--LVDS_CONFIG_1
	num_data_lines	=>S_num_data_lines,
	legacy_mode	=>S_legacy_mode,
	data_word_length=>S_data_word_length,
	idle_word	=>S_idle_word,


--LVDS_CONFIG_2
	start_delay_14DownTo0=>S_start_delay_14DownTo0,

--LVDS_CONFIG_3
	start_delay_17DownTo15	=>S_start_delay_17DownTo15,
	scrambler_rst		=>S_scrambler_rst,
	scrambler_en		=>S_scrambler_en,
	footer_disable		=>S_footer_disable,
	tm_aci_data		=>S_tm_aci_data,
	raw_data_bypass		=>S_raw_data_bypass,

--Clock_CTRL
	hclk_div_cfg		=>S_hclk_div_cfg,


--PADS_CONFIG_2
	itest_dis		=>S_itest_dis,
	d_start_oen		=>S_d_start_oen,
	data1_en		=>S_data1_en,
	data2_en		=>S_data2_en,
	clk_en			=>S_clk_en,
	daisy_chain		=>S_daisy_chain,


--LVDS_START_WORD_0
	LVDS_start_word_14DownTo0	=>S_LVDS_start_word_14DownTo0,

--LVDS_START_WORD_1
	LVDS_start_word_29DownTo15	=>S_LVDS_start_word_29DownTo15,

--LVDS_START_WORD_2
	LVDS_start_word_39DownTo30	=>S_LVDS_start_word_39DownTo30
);

-------------
U2_DATA_IF: DATA_IF
Port map(
	SCLK			=>SCLK,
	RST			=>RST,
	SYNC 			=>SYNC,
	ACLK 			=>S_Aclk,
	D_START			=>S_D_start,
	DISCARD			=>S_Discard,

	CALIBRATION		=>S_CALIBRATION,
	OPERATIONMODE		=>S_OPERATIONMODE,
	SET_UP			=>S_SET_UP,
--

--LVDS_CONFIG_1
	num_data_lines		=>S_num_data_lines,
	legacy_mode		=>S_legacy_mode,
	data_word_length	=>S_data_word_length,
	idle_word		=>S_idle_word,


--LVDS_CONFIG_2
	start_delay_14DownTo0	=>S_start_delay_14DownTo0,

--LVDS_CONFIG_3
	start_delay_17DownTo15	=>S_start_delay_17DownTo15,
	scrambler_rst		=>S_scrambler_rst,
	scrambler_en		=>S_scrambler_en,
	footer_disable		=>S_footer_disable,
	tm_aci_data		=>S_tm_aci_data,
	raw_data_bypass		=>S_raw_data_bypass,

--Clock_CTRL
	hclk_div_cfg		=>S_hclk_div_cfg,


--PADS_CONFIG_2
	itest_dis		=>S_itest_dis,
	d_start_oen		=>S_d_start_oen,
	data1_en		=>S_data1_en,
	data2_en		=>S_data2_en,
	clk_en			=>S_clk_en,
	daisy_chain		=>S_daisy_chain,


--LVDS_START_WORD_0
	LVDS_start_word_14DownTo0	=>S_LVDS_start_word_14DownTo0,

--LVDS_START_WORD_1
	LVDS_start_word_29DownTo15	=>S_LVDS_start_word_29DownTo15,

--LVDS_START_WORD_2
	LVDS_start_word_39DownTo30	=>S_LVDS_start_word_39DownTo30,
	Operation_Mode_Initialized 	=>Operation_Mode_Initialized,
	DATA1_OUT=>DATA1_OUT,
	DATA2_OUT=>DATA2_OUT
);

end Register_DATA_IF_arc;
