library ieee;
USE IEEE.STD_LOGIC_1164.ALL;

USE work.AMS_pack.ALL;

ENTITY Register_IF IS
Port(
	SCLK		: IN STD_LOGIC;
	SDO		: IN STD_LOGIC; --FPGA to ASIC
	SCn		: IN STD_LOGIC;
	RST		: IN STD_LOGIC;
	SDI		: OUT STD_LOGIC; -- ASIC to FPGA
	CALIBRATION	: OUT STD_LOGIC;	
	OPERATIONMODE	: OUT STD_LOGIC;		
	SET_UP		: OUT STD_LOGIC;		
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
END Register_IF;

ARCHITECTURE Register_IF_arc OF Register_IF IS

--COMPONENTS

Component SPIIFDecoderSM
PORT(
	SCLK: IN STD_LOGIC;
	SDO: IN STD_LOGIC;--FPGA to ASIC
	SCn: IN STD_LOGIC;
	rst: IN STD_LOGIC;
	SDI : OUT STD_LOGIC; -- ASIC to FPGA
	RD_WR: OUT STD_LOGIC;--'1' Read
	ADDR_SPI: OUT STD_LOGIC_VECTOR (13 DOWNTO 0); --SPI_Bank_Vector(1-14) -Address
	DATA_WR: OUT STD_LOGIC_VECTOR (15 DOWNTO 0); ----SPI_Bank_Vector(16-31)- Data	
	DATA_READ: IN STD_LOGIC_VECTOR (15 DOWNTO 0) ----SPI_Bank_Vector(16-31)- Data	
	);
End component;


Component R_W_Bank_Reg
PORT(
	CLK	: IN STD_LOGIC;	
	RST	: IN STD_LOGIC;	
	RD_WR	: IN STD_LOGIC; --'1' Read/'0' Write
	ADDR	: IN STD_LOGIC_VECTOR (13 DOWNTO 0); --SPI_Bank_Vector(1-14) -Address
	DATA_WR	: IN STD_LOGIC_VECTOR (15 DOWNTO 0) ;----SPI_Bank_Vector(16-31)- Data	
	DATA_READ	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0) ;----SPI_Bank_Vector(16-31)- Data	
	DONE_WRITE	: OUT STD_LOGIC ;--'0' while reading/'1' done reading
	Calibration_done: OUT STD_LOGIC ;--0 not calibrated, 1 calibrated
	--ControlSignals : OUT STD_LOGIC;
--outputs:
--Device ID Registers
	DEVICE_ID_0		: OUT std_logic_vector(15 downto 0) ; --RO, Chip ID Register
	DEVICE_ID_1		: OUT std_logic_vector(15 downto 0) ; --RO, Chip ID Register
	DEVICE_ID_2		: OUT std_logic_vector(15 downto 0) ; --RO, Chip ID Register

--Internal Test Registers
--Do not overwrite register, for ams only

--Power and Reference Control Registers
	EXT_VREF_CONFIG		: OUT std_logic_vector(15 downto 0) ; --RW, External Reference Configuration Register
	HEATER_CONFIG		: OUT std_logic_vector(15 downto 0) ; --RW, Heater Configuration Register
	POWER_MONITOR		: OUT std_logic_vector(15 downto 0) ; --RC, Power Monitor Register

--Software Reset, Clock Control and Status Monitor Register
	SW_RESET		: OUT std_logic_vector(15 downto 0) ; --WO, Software Reset Register
	CLOCK_CTRL		: OUT std_logic_vector(15 downto 0) ; --RW, Clock Control Register
	STATUS_MONITOR		: OUT std_logic_vector(15 downto 0) ; --RC, Status Monitor Register

--LVDS Configuration Registers
	LVDS_CONFIG_1		: OUT std_logic_vector(15 downto 0); --RW, LVDS Configuration Register
	LVDS_START_WORD_0	: OUT std_logic_vector(15 downto 0); --RW, LVDS Start Word 0
	LVDS_START_WORD_1	: OUT std_logic_vector(15 downto 0); --RW, LVDS Start Word 1
	LVDS_START_WORD_2	: OUT std_logic_vector(15 downto 0); --RW, LVDS Start Word 2
	LVDS_CONFIG_2		: OUT std_logic_vector(15 downto 0); --RW, LVDS Configuration Register 2
	LVDS_CONFIG_3		: OUT std_logic_vector(15 downto 0); --RW, LVDS Configuration Register 3

--LVDS Footer Registers
	LVDS_FOOTER_1		: OUT std_logic_vector(15 downto 0) ; --RO, LVDS Footer 1 Register
	LVDS_FOOTER_2		: OUT std_logic_vector(15 downto 0) ; --RO, LVDS Footer 2 Register	
	LVDS_FOOTER_3 		: OUT std_logic_vector(15 downto 0) ; --RO, LVDS Footer 3 Register
	LVDS_FOOTER_4	 	: OUT std_logic_vector(15 downto 0) ; --RO, LVDS Footer 4 Register
	LVDS_FOOTER_5	 	: OUT std_logic_vector(15 downto 0) ; --RO, LVDS Footer 5 Register
	LVDS_FOOTER_6	 	: OUT std_logic_vector(15 downto 0) ; --RO, LVDS Footer 6 Register

--Output and Input Pad Configuration Registers
	PADS_CONFIG_1		 : OUT std_logic_vector(15 downto 0); --RW,Pads Configuration Register 1
	PADS_CONFIG_2	 	 : OUT std_logic_vector(15 downto 0); --RW, Pads Configuration Register 2

--Test Pattern Registers
	TEST_PATTERN_0	  	 : OUT std_logic_vector(15 downto 0) ; --RW, Base for test pattern generator [14:0]
	TEST_PATTERN_1		 : OUT std_logic_vector(15 downto 0) ; --RW, Base for test pattern generator [29:15]
	TEST_PATTERN_2		 : OUT std_logic_vector(15 downto 0) ; --RW, Base for test pattern generator [33:30

--Temperature Sensor Register
	TEMP_SENSOR	 	: OUT std_logic_vector(15 downto 0) ; --RO, Temperature Sensor Register

--Integration Period Read Register
	-- !debug: 04/05/2021 commented  IP_ACLK_COUNT	 	: OUT std_logic_vector(15 downto 0) ; -- RO, Integration Period Read Register

--Dummy Registers
--4 Dummy registers for future use

--Scan Mode Register
--WO, RESERVED, Do not overwrite register, for ams only

--Photodiode Short Registers
	TIE_0	 			: OUT std_logic_vector(15 downto 0); --RW, Disable Channel Registers
	TIE_1	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_2	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_3	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_4	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_5	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_6	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_7	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_8	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_9	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_10	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_11	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_12	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_13	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_14	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_15	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_16	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers
	TIE_17	 			: OUT std_logic_vector(15 downto 0) ; --RW, Disable Channel Registers

--Enable Signals for Frontend Test Currents
	EN_ITEST_0                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_1                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_2                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_3                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_4                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_5                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_6                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_7                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_8                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_9                     : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_10                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_11                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_12                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_13                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_14                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_15                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers
	EN_ITEST_16                    : OUT std_logic_vector(15 downto 0); --RW, Enable Test Current Registers

--Selection of Input Test Current
	ITEST_MODE		 	: OUT std_logic_vector(15 downto 0) ; --RW, Input Test Current Mode Register

--ADC Configuration Register
	COARSE_QUANTIZER	 	: OUT std_logic_vector(15 downto 0) ; --RW, Coarse Quantizer Configuration Register

--ADC Test Registers
--RW, Do not overwrite register, for ams only

 --CALIBRATION Configuration Register
	START_AUTO_CAL	 		: OUT std_logic_vector(15 downto 0) ; --WO, Auto-CALIBRATION Register
	CALIB_CONFIG_0	 		: OUT std_logic_vector(15 downto 0) ; --RW, CALIBRATION Configuration Register 0
	CALIB_CONFIG_1	 		: OUT std_logic_vector(15 downto 0) ; --RW, CALIBRATION Configuration Register 1

--Offset Voltage CALIBRATION Result Register
	OFFV_CAL_RESULTS		 : OUT std_logic_vector(15 downto 0) ;--RO, Offset Voltage CALIBRATION Result Register

--CALIBRATION Configuration Register
	CALIB_CONFIG_2 			: OUT std_logic_vector(15 downto 0) ; --RW,  CALIB_CONFIG_2 Register
	CALIB_CONFIG_3	 		: OUT std_logic_vector(15 downto 0) ; --RW,  CALIB_CONFIG_3 Register

--CALIBRATION Monitor Register
	CALIB_MONITOR			: OUT std_logic_vector(15 downto 0);--RO, CALIBRATION Monitor Register

--ADC Configuration Registers
	ADC_OSR 			: OUT std_logic_vector(15 downto 0) ; --RW, Do not overwrite register, for ams only
	ADC_OSR_GAIN 			: OUT std_logic_vector(15 downto 0) ; --RW, Do not overwrite register, for ams only

--ADC Test Registers
--RESERVED- Do not overwrite register, for ams only



--CALIBRATION Result Registers

       Q_OFS_0              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 0
       Q_OSACLK_0           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 0
       LIN_CAL_QP1_0        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 0
       LIN_CAL_QP2_0        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 0

       Q_OFS_1              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 1
       Q_OSACLK_1           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 1
       LIN_CAL_QP1_1        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 1
       LIN_CAL_QP2_1        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 1

       Q_OFS_2              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 2
       Q_OSACLK_2           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 2
       LIN_CAL_QP1_2        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 2
       LIN_CAL_QP2_2        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 2

       Q_OFS_3              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 3
       Q_OSACLK_3           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 3
       LIN_CAL_QP1_3        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 3
       LIN_CAL_QP2_3        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 3

       Q_OFS_4              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 4
       Q_OSACLK_4           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 4
       LIN_CAL_QP1_4        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 4
       LIN_CAL_QP2_4        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 4

       Q_OFS_5              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 5
       Q_OSACLK_5           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 5
       LIN_CAL_QP1_5        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 5
       LIN_CAL_QP2_5        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 5

       Q_OFS_6              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 6
       Q_OSACLK_6           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 6
       LIN_CAL_QP1_6        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 6
       LIN_CAL_QP2_6        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 6

       Q_OFS_7              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 7
       Q_OSACLK_7           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 7
       LIN_CAL_QP1_7        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 7
       LIN_CAL_QP2_7        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 7

       Q_OFS_8              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 8
       Q_OSACLK_8           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 8
       LIN_CAL_QP1_8        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 8
       LIN_CAL_QP2_8        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 8

       Q_OFS_9              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 9
       Q_OSACLK_9           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 9
       LIN_CAL_QP1_9        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 9
       LIN_CAL_QP2_9        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 9

       Q_OFS_10              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 10
       Q_OSACLK_10           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 10
       LIN_CAL_QP1_10        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 10
       LIN_CAL_QP2_10        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 10

       Q_OFS_11              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 11
       Q_OSACLK_11           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 11
       LIN_CAL_QP1_11        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 11
       LIN_CAL_QP2_11        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 11

       Q_OFS_12              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 12
       Q_OSACLK_12           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 12
       LIN_CAL_QP1_12        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 12
       LIN_CAL_QP2_12        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 12

       Q_OFS_13              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 13
       Q_OSACLK_13           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 13
       LIN_CAL_QP1_13        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 13
       LIN_CAL_QP2_13        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 13

       Q_OFS_14              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 14
       Q_OSACLK_14           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 14
       LIN_CAL_QP1_14        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 14
       LIN_CAL_QP2_14        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 14

       Q_OFS_15              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 15
       Q_OSACLK_15           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 15
       LIN_CAL_QP1_15        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 15
       LIN_CAL_QP2_15        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 15

       Q_OFS_16              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 16
       Q_OSACLK_16           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 16
       LIN_CAL_QP1_16        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 16
       LIN_CAL_QP2_16        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 16

       Q_OFS_17              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 17
       Q_OSACLK_17           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 17
       LIN_CAL_QP1_17        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 17
       LIN_CAL_QP2_17        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 17

       Q_OFS_18              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 18
       Q_OSACLK_18           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 18
       LIN_CAL_QP1_18        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 18
       LIN_CAL_QP2_18        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 18

       Q_OFS_19              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 19
       Q_OSACLK_19           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 19
       LIN_CAL_QP1_19        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 19
       LIN_CAL_QP2_19        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 19

       Q_OFS_20              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 20
       Q_OSACLK_20           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 20
       LIN_CAL_QP1_20        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 20
       LIN_CAL_QP2_20        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 20

       Q_OFS_21              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 21
       Q_OSACLK_21           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 21
       LIN_CAL_QP1_21        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 21
       LIN_CAL_QP2_21        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 21

       Q_OFS_22              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 22
       Q_OSACLK_22           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 22
       LIN_CAL_QP1_22        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 22
       LIN_CAL_QP2_22        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 22

       Q_OFS_23              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 23
       Q_OSACLK_23           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 23
       LIN_CAL_QP1_23        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 23
       LIN_CAL_QP2_23        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 23

       Q_OFS_24              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 24
       Q_OSACLK_24           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 24
       LIN_CAL_QP1_24        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 24
       LIN_CAL_QP2_24        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 24

       Q_OFS_25              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 25
       Q_OSACLK_25           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 25
       LIN_CAL_QP1_25        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 25
       LIN_CAL_QP2_25        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 25

       Q_OFS_26              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 26
       Q_OSACLK_26           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 26
       LIN_CAL_QP1_26        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 26
       LIN_CAL_QP2_26        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 26

       Q_OFS_27              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 27
       Q_OSACLK_27           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 27
       LIN_CAL_QP1_27        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 27
       LIN_CAL_QP2_27        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 27

       Q_OFS_28              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 28
       Q_OSACLK_28           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 28
       LIN_CAL_QP1_28        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 28
       LIN_CAL_QP2_28        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 28

       Q_OFS_29              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 29
       Q_OSACLK_29           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 29
       LIN_CAL_QP1_29        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 29
       LIN_CAL_QP2_29        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 29

       Q_OFS_30              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 30
       Q_OSACLK_30           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 30
       LIN_CAL_QP1_30        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 30
       LIN_CAL_QP2_30        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 30

       Q_OFS_31              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 31
       Q_OSACLK_31           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 31
       LIN_CAL_QP1_31        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 31
       LIN_CAL_QP2_31        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 31

       Q_OFS_32              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 32
       Q_OSACLK_32           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 32
       LIN_CAL_QP1_32        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 32
       LIN_CAL_QP2_32        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 32

       Q_OFS_33              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 33
       Q_OSACLK_33           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 33
       LIN_CAL_QP1_33        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 33
       LIN_CAL_QP2_33        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 33

       Q_OFS_34              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 34
       Q_OSACLK_34           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 34
       LIN_CAL_QP1_34        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 34
       LIN_CAL_QP2_34        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 34

       Q_OFS_35              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 35
       Q_OSACLK_35           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 35
       LIN_CAL_QP1_35        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 35
       LIN_CAL_QP2_35        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 35

       Q_OFS_36              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 36
       Q_OSACLK_36           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 36
       LIN_CAL_QP1_36        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 36
       LIN_CAL_QP2_36        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 36

       Q_OFS_37              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 37
       Q_OSACLK_37           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 37
       LIN_CAL_QP1_37        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 37
       LIN_CAL_QP2_37        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 37

       Q_OFS_38              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 38
       Q_OSACLK_38           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 38
       LIN_CAL_QP1_38        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 38
       LIN_CAL_QP2_38        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 38

       Q_OFS_39              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 39
       Q_OSACLK_39           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 39
       LIN_CAL_QP1_39        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 39
       LIN_CAL_QP2_39        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 39

       Q_OFS_40              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 40
       Q_OSACLK_40           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 40
       LIN_CAL_QP1_40        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 40
       LIN_CAL_QP2_40        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 40

       Q_OFS_41              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 41
       Q_OSACLK_41           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 41
       LIN_CAL_QP1_41        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 41
       LIN_CAL_QP2_41        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 41

       Q_OFS_42              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 42
       Q_OSACLK_42           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 42
       LIN_CAL_QP1_42        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 42
       LIN_CAL_QP2_42        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 42

       Q_OFS_43              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 43
       Q_OSACLK_43           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 43
       LIN_CAL_QP1_43        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 43
       LIN_CAL_QP2_43        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 43

       Q_OFS_44              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 44
       Q_OSACLK_44           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 44
       LIN_CAL_QP1_44        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 44
       LIN_CAL_QP2_44        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 44

       Q_OFS_45              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 45
       Q_OSACLK_45           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 45
       LIN_CAL_QP1_45        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 45
       LIN_CAL_QP2_45        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 45

       Q_OFS_46              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 46
       Q_OSACLK_46           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 46
       LIN_CAL_QP1_46        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 46
       LIN_CAL_QP2_46        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 46

       Q_OFS_47              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 47
       Q_OSACLK_47           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 47
       LIN_CAL_QP1_47        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 47
       LIN_CAL_QP2_47        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 47

       Q_OFS_48              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 48
       Q_OSACLK_48           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 48
       LIN_CAL_QP1_48        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 48
       LIN_CAL_QP2_48        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 48

       Q_OFS_49              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 49
       Q_OSACLK_49           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 49
       LIN_CAL_QP1_49        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 49
       LIN_CAL_QP2_49        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 49

       Q_OFS_50              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 50
       Q_OSACLK_50           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 50
       LIN_CAL_QP1_50        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 50
       LIN_CAL_QP2_50        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 50

       Q_OFS_51              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 51
       Q_OSACLK_51           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 51
       LIN_CAL_QP1_51        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 51
       LIN_CAL_QP2_51        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 51

       Q_OFS_52              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 52
       Q_OSACLK_52           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 52
       LIN_CAL_QP1_52        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 52
       LIN_CAL_QP2_52        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 52

       Q_OFS_53              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 53
       Q_OSACLK_53           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 53
       LIN_CAL_QP1_53        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 53
       LIN_CAL_QP2_53        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 53

       Q_OFS_54              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 54
       Q_OSACLK_54           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 54
       LIN_CAL_QP1_54        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 54
       LIN_CAL_QP2_54        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 54

       Q_OFS_55              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 55
       Q_OSACLK_55           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 55
       LIN_CAL_QP1_55        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 55
       LIN_CAL_QP2_55        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 55

       Q_OFS_56              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 56
       Q_OSACLK_56           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 56
       LIN_CAL_QP1_56        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 56
       LIN_CAL_QP2_56        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 56

       Q_OFS_57              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 57
       Q_OSACLK_57           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 57
       LIN_CAL_QP1_57        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 57
       LIN_CAL_QP2_57        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 57

       Q_OFS_58              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 58
       Q_OSACLK_58           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 58
       LIN_CAL_QP1_58        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 58
       LIN_CAL_QP2_58        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 58

       Q_OFS_59              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 59
       Q_OSACLK_59           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 59
       LIN_CAL_QP1_59        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 59
       LIN_CAL_QP2_59        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 59

       Q_OFS_60              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 60
       Q_OSACLK_60           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 60
       LIN_CAL_QP1_60        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 60
       LIN_CAL_QP2_60        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 60

       Q_OFS_61              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 61
       Q_OSACLK_61           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 61
       LIN_CAL_QP1_61        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 61
       LIN_CAL_QP2_61        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 61

       Q_OFS_62              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 62
       Q_OSACLK_62           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 62
       LIN_CAL_QP1_62        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 62
       LIN_CAL_QP2_62        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 62

       Q_OFS_63              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 63
       Q_OSACLK_63           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 63
       LIN_CAL_QP1_63        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 63
       LIN_CAL_QP2_63        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 63

       Q_OFS_64              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 64
       Q_OSACLK_64           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 64
       LIN_CAL_QP1_64        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 64
       LIN_CAL_QP2_64        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 64

       Q_OFS_65              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 65
       Q_OSACLK_65           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 65
       LIN_CAL_QP1_65        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 65
       LIN_CAL_QP2_65        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 65

       Q_OFS_66              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 66
       Q_OSACLK_66           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 66
       LIN_CAL_QP1_66        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 66
       LIN_CAL_QP2_66        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 66

       Q_OFS_67              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 67
       Q_OSACLK_67           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 67
       LIN_CAL_QP1_67        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 67
       LIN_CAL_QP2_67        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 67

       Q_OFS_68              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 68
       Q_OSACLK_68           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 68
       LIN_CAL_QP1_68        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 68
       LIN_CAL_QP2_68        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 68

       Q_OFS_69              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 69
       Q_OSACLK_69           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 69
       LIN_CAL_QP1_69        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 69
       LIN_CAL_QP2_69        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 69

       Q_OFS_70              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 70
       Q_OSACLK_70           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 70
       LIN_CAL_QP1_70        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 70
       LIN_CAL_QP2_70        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 70

       Q_OFS_71              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 71
       Q_OSACLK_71           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 71
       LIN_CAL_QP1_71        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 71
       LIN_CAL_QP2_71        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 71

       Q_OFS_72              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 72
       Q_OSACLK_72           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 72
       LIN_CAL_QP1_72        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 72
       LIN_CAL_QP2_72        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 72

       Q_OFS_73              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 73
       Q_OSACLK_73           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 73
       LIN_CAL_QP1_73        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 73
       LIN_CAL_QP2_73        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 73

       Q_OFS_74              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 74
       Q_OSACLK_74           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 74
       LIN_CAL_QP1_74        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 74
       LIN_CAL_QP2_74        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 74

       Q_OFS_75              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 75
       Q_OSACLK_75           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 75
       LIN_CAL_QP1_75        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 75
       LIN_CAL_QP2_75        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 75

       Q_OFS_76              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 76
       Q_OSACLK_76           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 76
       LIN_CAL_QP1_76        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 76
       LIN_CAL_QP2_76        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 76

       Q_OFS_77              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 77
       Q_OSACLK_77           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 77
       LIN_CAL_QP1_77        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 77
       LIN_CAL_QP2_77        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 77

       Q_OFS_78              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 78
       Q_OSACLK_78           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 78
       LIN_CAL_QP1_78        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 78
       LIN_CAL_QP2_78        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 78

       Q_OFS_79              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 79
       Q_OSACLK_79           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 79
       LIN_CAL_QP1_79        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 79
       LIN_CAL_QP2_79        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 79

       Q_OFS_80              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 80
       Q_OSACLK_80           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 80
       LIN_CAL_QP1_80        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 80
       LIN_CAL_QP2_80        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 80

       Q_OFS_81              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 81
       Q_OSACLK_81           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 81
       LIN_CAL_QP1_81        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 81
       LIN_CAL_QP2_81        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 81

       Q_OFS_82              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 82
       Q_OSACLK_82           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 82
       LIN_CAL_QP1_82        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 82
       LIN_CAL_QP2_82        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 82

       Q_OFS_83              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 83
       Q_OSACLK_83           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 83
       LIN_CAL_QP1_83        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 83
       LIN_CAL_QP2_83        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 83

       Q_OFS_84              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 84
       Q_OSACLK_84           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 84
       LIN_CAL_QP1_84        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 84
       LIN_CAL_QP2_84        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 84

       Q_OFS_85              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 85
       Q_OSACLK_85           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 85
       LIN_CAL_QP1_85        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 85
       LIN_CAL_QP2_85        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 85

       Q_OFS_86              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 86
       Q_OSACLK_86           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 86
       LIN_CAL_QP1_86        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 86
       LIN_CAL_QP2_86        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 86

       Q_OFS_87              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 87
       Q_OSACLK_87           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 87
       LIN_CAL_QP1_87        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 87
       LIN_CAL_QP2_87        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 87

       Q_OFS_88              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 88
       Q_OSACLK_88           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 88
       LIN_CAL_QP1_88        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 88
       LIN_CAL_QP2_88        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 88

       Q_OFS_89              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 89
       Q_OSACLK_89           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 89
       LIN_CAL_QP1_89        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 89
       LIN_CAL_QP2_89        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 89

       Q_OFS_90              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 90
       Q_OSACLK_90           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 90
       LIN_CAL_QP1_90        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 90
       LIN_CAL_QP2_90        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 90

       Q_OFS_91              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 91
       Q_OSACLK_91           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 91
       LIN_CAL_QP1_91        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 91
       LIN_CAL_QP2_91        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 91

       Q_OFS_92              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 92
       Q_OSACLK_92           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 92
       LIN_CAL_QP1_92        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 92
       LIN_CAL_QP2_92        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 92

       Q_OFS_93              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 93
       Q_OSACLK_93           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 93
       LIN_CAL_QP1_93        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 93
       LIN_CAL_QP2_93        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 93

       Q_OFS_94              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 94
       Q_OSACLK_94           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 94
       LIN_CAL_QP1_94        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 94
       LIN_CAL_QP2_94        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 94

       Q_OFS_95              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 95
       Q_OSACLK_95           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 95
       LIN_CAL_QP1_95        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 95
       LIN_CAL_QP2_95        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 95

       Q_OFS_96              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 96
       Q_OSACLK_96           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 96
       LIN_CAL_QP1_96        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 96
       LIN_CAL_QP2_96        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 96

       Q_OFS_97              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 97
       Q_OSACLK_97           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 97
       LIN_CAL_QP1_97        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 97
       LIN_CAL_QP2_97        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 97

       Q_OFS_98              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 98
       Q_OSACLK_98           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 98
       LIN_CAL_QP1_98        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 98
       LIN_CAL_QP2_98        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 98

       Q_OFS_99              : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 99
       Q_OSACLK_99           : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 99
       LIN_CAL_QP1_99        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 99
       LIN_CAL_QP2_99        : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 99

       Q_OFS_100            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 100
       Q_OSACLK_100         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 100
       LIN_CAL_QP1_100      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 100
       LIN_CAL_QP2_100      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 100

       Q_OFS_101            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 101
       Q_OSACLK_101         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 101
       LIN_CAL_QP1_101      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 101
       LIN_CAL_QP2_101      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 101

       Q_OFS_102            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 102
       Q_OSACLK_102         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 102
       LIN_CAL_QP1_102      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 102
       LIN_CAL_QP2_102      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 102

       Q_OFS_103            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 103
       Q_OSACLK_103         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 103
       LIN_CAL_QP1_103      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 103
       LIN_CAL_QP2_103      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 103

       Q_OFS_104            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 104
       Q_OSACLK_104         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 104
       LIN_CAL_QP1_104      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 104
       LIN_CAL_QP2_104      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 104

       Q_OFS_105            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 105
       Q_OSACLK_105         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 105
       LIN_CAL_QP1_105      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 105
       LIN_CAL_QP2_105      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 105

       Q_OFS_106            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 106
       Q_OSACLK_106         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 106
       LIN_CAL_QP1_106      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 106
       LIN_CAL_QP2_106      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 106

       Q_OFS_107            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 107
       Q_OSACLK_107         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 107
       LIN_CAL_QP1_107      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 107
       LIN_CAL_QP2_107      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 107

       Q_OFS_108            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 108
       Q_OSACLK_108         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 108
       LIN_CAL_QP1_108      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 108
       LIN_CAL_QP2_108      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 108

       Q_OFS_109            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 109
       Q_OSACLK_109         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 109
       LIN_CAL_QP1_109      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 109
       LIN_CAL_QP2_109      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 109

       Q_OFS_110            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 110
       Q_OSACLK_110         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 110
       LIN_CAL_QP1_110      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 110
       LIN_CAL_QP2_110      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 110

       Q_OFS_111            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 111
       Q_OSACLK_111         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 111
       LIN_CAL_QP1_111      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 111
       LIN_CAL_QP2_111      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 111

       Q_OFS_112            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 112
       Q_OSACLK_112         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 112
       LIN_CAL_QP1_112      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 112
       LIN_CAL_QP2_112      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 112

       Q_OFS_113            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 113
       Q_OSACLK_113         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 113
       LIN_CAL_QP1_113      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 113
       LIN_CAL_QP2_113      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 113

       Q_OFS_114            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 114
       Q_OSACLK_114         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 114
       LIN_CAL_QP1_114      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 114
       LIN_CAL_QP2_114      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 114

       Q_OFS_115            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 115
       Q_OSACLK_115         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 115
       LIN_CAL_QP1_115      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 115
       LIN_CAL_QP2_115      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 115

       Q_OFS_116            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 116
       Q_OSACLK_116         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 116
       LIN_CAL_QP1_116      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 116
       LIN_CAL_QP2_116      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 116

       Q_OFS_117            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 117
       Q_OSACLK_117         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 117
       LIN_CAL_QP1_117      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 117
       LIN_CAL_QP2_117      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 117

       Q_OFS_118            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 118
       Q_OSACLK_118         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 118
       LIN_CAL_QP1_118      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 118
       LIN_CAL_QP2_118      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 118

       Q_OFS_119            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 119
       Q_OSACLK_119         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 119
       LIN_CAL_QP1_119      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 119
       LIN_CAL_QP2_119      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 119

       Q_OFS_120            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 120
       Q_OSACLK_120         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 120
       LIN_CAL_QP1_120      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 120
       LIN_CAL_QP2_120      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 120

       Q_OFS_121            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 121
       Q_OSACLK_121         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 121
       LIN_CAL_QP1_121      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 121
       LIN_CAL_QP2_121      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 121

       Q_OFS_122            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 122
       Q_OSACLK_122         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 122
       LIN_CAL_QP1_122      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 122
       LIN_CAL_QP2_122      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 122

       Q_OFS_123            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 123
       Q_OSACLK_123         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 123
       LIN_CAL_QP1_123      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 123
       LIN_CAL_QP2_123      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 123

       Q_OFS_124            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 124
       Q_OSACLK_124         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 124
       LIN_CAL_QP1_124      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 124
       LIN_CAL_QP2_124      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 124

       Q_OFS_125            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 125
       Q_OSACLK_125         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 125
       LIN_CAL_QP1_125      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 125
       LIN_CAL_QP2_125      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 125

       Q_OFS_126            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 126
       Q_OSACLK_126         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 126
       LIN_CAL_QP1_126      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 126
       LIN_CAL_QP2_126      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 126

       Q_OFS_127            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 127
       Q_OSACLK_127         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 127
       LIN_CAL_QP1_127      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 127
       LIN_CAL_QP2_127      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 127

       Q_OFS_128            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 128
       Q_OSACLK_128         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 128
       LIN_CAL_QP1_128      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 128
       LIN_CAL_QP2_128      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 128

       Q_OFS_129            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 129
       Q_OSACLK_129         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 129
       LIN_CAL_QP1_129      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 129
       LIN_CAL_QP2_129      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 129

       Q_OFS_130            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 130
       Q_OSACLK_130         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 130
       LIN_CAL_QP1_130      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 130
       LIN_CAL_QP2_130      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 130

       Q_OFS_131            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 131
       Q_OSACLK_131         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 131
       LIN_CAL_QP1_131      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 131
       LIN_CAL_QP2_131      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 131

       Q_OFS_132            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 132
       Q_OSACLK_132         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 132
       LIN_CAL_QP1_132      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 132
       LIN_CAL_QP2_132      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 132

       Q_OFS_133            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 133
       Q_OSACLK_133         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 133
       LIN_CAL_QP1_133      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 133
       LIN_CAL_QP2_133      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 133

       Q_OFS_134            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 134
       Q_OSACLK_134         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 134
       LIN_CAL_QP1_134      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 134
       LIN_CAL_QP2_134      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 134

       Q_OFS_135            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 135
       Q_OSACLK_135         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 135
       LIN_CAL_QP1_135      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 135
       LIN_CAL_QP2_135      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 135

       Q_OFS_136            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 136
       Q_OSACLK_136         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 136
       LIN_CAL_QP1_136      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 136
       LIN_CAL_QP2_136      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 136

       Q_OFS_137            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 137
       Q_OSACLK_137         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 137
       LIN_CAL_QP1_137      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 137
       LIN_CAL_QP2_137      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 137

       Q_OFS_138            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 138
       Q_OSACLK_138         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 138
       LIN_CAL_QP1_138      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 138
       LIN_CAL_QP2_138      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 138

       Q_OFS_139            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 139
       Q_OSACLK_139         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 139
       LIN_CAL_QP1_139      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 139
       LIN_CAL_QP2_139      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 139

       Q_OFS_140            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 140
       Q_OSACLK_140         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 140
       LIN_CAL_QP1_140      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 140
       LIN_CAL_QP2_140      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 140

       Q_OFS_141            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 141
       Q_OSACLK_141         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 141
       LIN_CAL_QP1_141      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 141
       LIN_CAL_QP2_141      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 141

       Q_OFS_142            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 142
       Q_OSACLK_142         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 142
       LIN_CAL_QP1_142      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 142
       LIN_CAL_QP2_142      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 142

       Q_OFS_143            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 143
       Q_OSACLK_143         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 143
       LIN_CAL_QP1_143      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 143
       LIN_CAL_QP2_143      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 143

       Q_OFS_144            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 144
       Q_OSACLK_144         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 144
       LIN_CAL_QP1_144      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 144
       LIN_CAL_QP2_144      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 144

       Q_OFS_145            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 145
       Q_OSACLK_145         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 145
       LIN_CAL_QP1_145      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 145
       LIN_CAL_QP2_145      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 145

       Q_OFS_146            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 146
       Q_OSACLK_146         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 146
       LIN_CAL_QP1_146      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 146
       LIN_CAL_QP2_146      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 146

       Q_OFS_147            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 147
       Q_OSACLK_147         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 147
       LIN_CAL_QP1_147      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 147
       LIN_CAL_QP2_147      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 147

       Q_OFS_148            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 148
       Q_OSACLK_148         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 148
       LIN_CAL_QP1_148      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 148
       LIN_CAL_QP2_148      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 148

       Q_OFS_149            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 149
       Q_OSACLK_149         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 149
       LIN_CAL_QP1_149      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 149
       LIN_CAL_QP2_149      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 149

       Q_OFS_150            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 150
       Q_OSACLK_150         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 150
       LIN_CAL_QP1_150      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 150
       LIN_CAL_QP2_150      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 150

       Q_OFS_151            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 151
       Q_OSACLK_151         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 151
       LIN_CAL_QP1_151      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 151
       LIN_CAL_QP2_151      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 151

       Q_OFS_152            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 152
       Q_OSACLK_152         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 152
       LIN_CAL_QP1_152      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 152
       LIN_CAL_QP2_152      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 152

       Q_OFS_153            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 153
       Q_OSACLK_153         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 153
       LIN_CAL_QP1_153      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 153
       LIN_CAL_QP2_153      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 153

       Q_OFS_154            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 154
       Q_OSACLK_154         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 154
       LIN_CAL_QP1_154      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 154
       LIN_CAL_QP2_154      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 154

       Q_OFS_155            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 155
       Q_OSACLK_155         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 155
       LIN_CAL_QP1_155      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 155
       LIN_CAL_QP2_155      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 155

       Q_OFS_156            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 156
       Q_OSACLK_156         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 156
       LIN_CAL_QP1_156      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 156
       LIN_CAL_QP2_156      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 156

       Q_OFS_157            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 157
       Q_OSACLK_157         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 157
       LIN_CAL_QP1_157      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 157
       LIN_CAL_QP2_157      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 157

       Q_OFS_158            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 158
       Q_OSACLK_158         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 158
       LIN_CAL_QP1_158      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 158
       LIN_CAL_QP2_158      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 158

       Q_OFS_159            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 159
       Q_OSACLK_159         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 159
       LIN_CAL_QP1_159      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 159
       LIN_CAL_QP2_159      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 159

       Q_OFS_160            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 160
       Q_OSACLK_160         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 160
       LIN_CAL_QP1_160      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 160
       LIN_CAL_QP2_160      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 160

       Q_OFS_161            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 161
       Q_OSACLK_161         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 161
       LIN_CAL_QP1_161      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 161
       LIN_CAL_QP2_161      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 161

       Q_OFS_162            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 162
       Q_OSACLK_162         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 162
       LIN_CAL_QP1_162      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 162
       LIN_CAL_QP2_162      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 162

       Q_OFS_163            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 163
       Q_OSACLK_163         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 163
       LIN_CAL_QP1_163      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 163
       LIN_CAL_QP2_163      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 163

       Q_OFS_164            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 164
       Q_OSACLK_164         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 164
       LIN_CAL_QP1_164      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 164
       LIN_CAL_QP2_164      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 164

       Q_OFS_165            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 165
       Q_OSACLK_165         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 165
       LIN_CAL_QP1_165      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 165
       LIN_CAL_QP2_165      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 165

       Q_OFS_166            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 166
       Q_OSACLK_166         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 166
       LIN_CAL_QP1_166      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 166
       LIN_CAL_QP2_166      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 166

       Q_OFS_167            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 167
       Q_OSACLK_167         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 167
       LIN_CAL_QP1_167      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 167
       LIN_CAL_QP2_167      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 167

       Q_OFS_168            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 168
       Q_OSACLK_168         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 168
       LIN_CAL_QP1_168      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 168
       LIN_CAL_QP2_168      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 168

       Q_OFS_169            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 169
       Q_OSACLK_169         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 169
       LIN_CAL_QP1_169      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 169
       LIN_CAL_QP2_169      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 169

       Q_OFS_170            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 170
       Q_OSACLK_170         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 170
       LIN_CAL_QP1_170      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 170
       LIN_CAL_QP2_170      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 170

       Q_OFS_171            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 171
       Q_OSACLK_171         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 171
       LIN_CAL_QP1_171      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 171
       LIN_CAL_QP2_171      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 171

       Q_OFS_172            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 172
       Q_OSACLK_172         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 172
       LIN_CAL_QP1_172      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 172
       LIN_CAL_QP2_172      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 172

       Q_OFS_173            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 173
       Q_OSACLK_173         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 173
       LIN_CAL_QP1_173      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 173
       LIN_CAL_QP2_173      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 173

       Q_OFS_174            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 174
       Q_OSACLK_174         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 174
       LIN_CAL_QP1_174      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 174
       LIN_CAL_QP2_174      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 174

       Q_OFS_175            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 175
       Q_OSACLK_175         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 175
       LIN_CAL_QP1_175      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 175
       LIN_CAL_QP2_175      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 175

       Q_OFS_176            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 176
       Q_OSACLK_176         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 176
       LIN_CAL_QP1_176      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 176
       LIN_CAL_QP2_176      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 176

       Q_OFS_177            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 177
       Q_OSACLK_177         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 177
       LIN_CAL_QP1_177      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 177
       LIN_CAL_QP2_177      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 177

       Q_OFS_178            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 178
       Q_OSACLK_178         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 178
       LIN_CAL_QP1_178      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 178
       LIN_CAL_QP2_178      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 178

       Q_OFS_179            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 179
       Q_OSACLK_179         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 179
       LIN_CAL_QP1_179      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 179
       LIN_CAL_QP2_179      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 179

       Q_OFS_180            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 180
       Q_OSACLK_180         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 180
       LIN_CAL_QP1_180      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 180
       LIN_CAL_QP2_180      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 180

       Q_OFS_181            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 181
       Q_OSACLK_181         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 181
       LIN_CAL_QP1_181      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 181
       LIN_CAL_QP2_181      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 181

       Q_OFS_182            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 182
       Q_OSACLK_182         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 182
       LIN_CAL_QP1_182      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 182
       LIN_CAL_QP2_182      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 182

       Q_OFS_183            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 183
       Q_OSACLK_183         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 183
       LIN_CAL_QP1_183      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 183
       LIN_CAL_QP2_183      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 183

       Q_OFS_184            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 184
       Q_OSACLK_184         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 184
       LIN_CAL_QP1_184      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 184
       LIN_CAL_QP2_184      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 184

       Q_OFS_185            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 185
       Q_OSACLK_185         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 185
       LIN_CAL_QP1_185      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 185
       LIN_CAL_QP2_185      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 185

       Q_OFS_186            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 186
       Q_OSACLK_186         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 186
       LIN_CAL_QP1_186      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 186
       LIN_CAL_QP2_186      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 186

       Q_OFS_187            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 187
       Q_OSACLK_187         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 187
       LIN_CAL_QP1_187      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 187
       LIN_CAL_QP2_187      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 187

       Q_OFS_188            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 188
       Q_OSACLK_188         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 188
       LIN_CAL_QP1_188      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 188
       LIN_CAL_QP2_188      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 188

       Q_OFS_189            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 189
       Q_OSACLK_189         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 189
       LIN_CAL_QP1_189      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 189
       LIN_CAL_QP2_189      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 189

       Q_OFS_190            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 190
       Q_OSACLK_190         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 190
       LIN_CAL_QP1_190      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 190
       LIN_CAL_QP2_190      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 190

       Q_OFS_191            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 191
       Q_OSACLK_191         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 191
       LIN_CAL_QP1_191      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 191
       LIN_CAL_QP2_191      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 191

       Q_OFS_192            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 192
       Q_OSACLK_192         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 192
       LIN_CAL_QP1_192      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 192
       LIN_CAL_QP2_192      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 192

       Q_OFS_193            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 193
       Q_OSACLK_193         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 193
       LIN_CAL_QP1_193      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 193
       LIN_CAL_QP2_193      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 193

       Q_OFS_194            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 194
       Q_OSACLK_194         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 194
       LIN_CAL_QP1_194      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 194
       LIN_CAL_QP2_194      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 194

       Q_OFS_195            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 195
       Q_OSACLK_195         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 195
       LIN_CAL_QP1_195      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 195
       LIN_CAL_QP2_195      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 195

       Q_OFS_196            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 196
       Q_OSACLK_196         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 196
       LIN_CAL_QP1_196      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 196
       LIN_CAL_QP2_196      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 196

       Q_OFS_197            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 197
       Q_OSACLK_197         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 197
       LIN_CAL_QP1_197      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 197
       LIN_CAL_QP2_197      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 197

       Q_OFS_198            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 198
       Q_OSACLK_198         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 198
       LIN_CAL_QP1_198      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 198
       LIN_CAL_QP2_198      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 198

       Q_OFS_199            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 199
       Q_OSACLK_199         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 199
       LIN_CAL_QP1_199      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 199
       LIN_CAL_QP2_199      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 199

       Q_OFS_200            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 200
       Q_OSACLK_200         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 200
       LIN_CAL_QP1_200      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 200
       LIN_CAL_QP2_200      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 200

       Q_OFS_201            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 201
       Q_OSACLK_201         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 201
       LIN_CAL_QP1_201      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 201
       LIN_CAL_QP2_201      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 201

       Q_OFS_202            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 202
       Q_OSACLK_202         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 202
       LIN_CAL_QP1_202      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 202
       LIN_CAL_QP2_202      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 202

       Q_OFS_203            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 203
       Q_OSACLK_203         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 203
       LIN_CAL_QP1_203      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 203
       LIN_CAL_QP2_203      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 203

       Q_OFS_204            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 204
       Q_OSACLK_204         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 204
       LIN_CAL_QP1_204      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 204
       LIN_CAL_QP2_204      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 204

       Q_OFS_205            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 205
       Q_OSACLK_205         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 205
       LIN_CAL_QP1_205      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 205
       LIN_CAL_QP2_205      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 205

       Q_OFS_206            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 206
       Q_OSACLK_206         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 206
       LIN_CAL_QP1_206      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 206
       LIN_CAL_QP2_206      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 206

       Q_OFS_207            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 207
       Q_OSACLK_207         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 207
       LIN_CAL_QP1_207      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 207
       LIN_CAL_QP2_207      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 207

       Q_OFS_208            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 208
       Q_OSACLK_208         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 208
       LIN_CAL_QP1_208      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 208
       LIN_CAL_QP2_208      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 208

       Q_OFS_209            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 209
       Q_OSACLK_209         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 209
       LIN_CAL_QP1_209      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 209
       LIN_CAL_QP2_209      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 209

       Q_OFS_210            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 210
       Q_OSACLK_210         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 210
       LIN_CAL_QP1_210      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 210
       LIN_CAL_QP2_210      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 210

       Q_OFS_211            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 211
       Q_OSACLK_211         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 211
       LIN_CAL_QP1_211      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 211
       LIN_CAL_QP2_211      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 211

       Q_OFS_212            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 212
       Q_OSACLK_212         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 212
       LIN_CAL_QP1_212      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 212
       LIN_CAL_QP2_212      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 212

       Q_OFS_213            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 213
       Q_OSACLK_213         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 213
       LIN_CAL_QP1_213      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 213
       LIN_CAL_QP2_213      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 213

       Q_OFS_214            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 214
       Q_OSACLK_214         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 214
       LIN_CAL_QP1_214      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 214
       LIN_CAL_QP2_214      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 214

       Q_OFS_215            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 215
       Q_OSACLK_215         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 215
       LIN_CAL_QP1_215      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 215
       LIN_CAL_QP2_215      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 215

       Q_OFS_216            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 216
       Q_OSACLK_216         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 216
       LIN_CAL_QP1_216      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 216
       LIN_CAL_QP2_216      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 216

       Q_OFS_217            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 217
       Q_OSACLK_217         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 217
       LIN_CAL_QP1_217      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 217
       LIN_CAL_QP2_217      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 217

       Q_OFS_218            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 218
       Q_OSACLK_218         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 218
       LIN_CAL_QP1_218      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 218
       LIN_CAL_QP2_218      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 218

       Q_OFS_219            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 219
       Q_OSACLK_219         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 219
       LIN_CAL_QP1_219      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 219
       LIN_CAL_QP2_219      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 219

       Q_OFS_220            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 220
       Q_OSACLK_220         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 220
       LIN_CAL_QP1_220      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 220
       LIN_CAL_QP2_220      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 220

       Q_OFS_221            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 221
       Q_OSACLK_221         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 221
       LIN_CAL_QP1_221      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 221
       LIN_CAL_QP2_221      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 221

       Q_OFS_222            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 222
       Q_OSACLK_222         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 222
       LIN_CAL_QP1_222      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 222
       LIN_CAL_QP2_222      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 222

       Q_OFS_223            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 223
       Q_OSACLK_223         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 223
       LIN_CAL_QP1_223      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 223
       LIN_CAL_QP2_223      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 223

       Q_OFS_224            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 224
       Q_OSACLK_224         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 224
       LIN_CAL_QP1_224      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 224
       LIN_CAL_QP2_224      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 224

       Q_OFS_225            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 225
       Q_OSACLK_225         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 225
       LIN_CAL_QP1_225      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 225
       LIN_CAL_QP2_225      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 225

       Q_OFS_226            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 226
       Q_OSACLK_226         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 226
       LIN_CAL_QP1_226      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 226
       LIN_CAL_QP2_226      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 226

       Q_OFS_227            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 227
       Q_OSACLK_227         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 227
       LIN_CAL_QP1_227      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 227
       LIN_CAL_QP2_227      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 227

       Q_OFS_228            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 228
       Q_OSACLK_228         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 228
       LIN_CAL_QP1_228      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 228
       LIN_CAL_QP2_228      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 228

       Q_OFS_229            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 229
       Q_OSACLK_229         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 229
       LIN_CAL_QP1_229      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 229
       LIN_CAL_QP2_229      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 229

       Q_OFS_230            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 230
       Q_OSACLK_230         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 230
       LIN_CAL_QP1_230      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 230
       LIN_CAL_QP2_230      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 230

       Q_OFS_231            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 231
       Q_OSACLK_231         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 231
       LIN_CAL_QP1_231      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 231
       LIN_CAL_QP2_231      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 231

       Q_OFS_232            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 232
       Q_OSACLK_232         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 232
       LIN_CAL_QP1_232      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 232
       LIN_CAL_QP2_232      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 232

       Q_OFS_233            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 233
       Q_OSACLK_233         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 233
       LIN_CAL_QP1_233      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 233
       LIN_CAL_QP2_233      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 233

       Q_OFS_234            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 234
       Q_OSACLK_234         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 234
       LIN_CAL_QP1_234      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 234
       LIN_CAL_QP2_234      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 234

       Q_OFS_235            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 235
       Q_OSACLK_235         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 235
       LIN_CAL_QP1_235      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 235
       LIN_CAL_QP2_235      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 235

       Q_OFS_236            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 236
       Q_OSACLK_236         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 236
       LIN_CAL_QP1_236      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 236
       LIN_CAL_QP2_236      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 236

       Q_OFS_237            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 237
       Q_OSACLK_237         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 237
       LIN_CAL_QP1_237      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 237
       LIN_CAL_QP2_237      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 237

       Q_OFS_238            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 238
       Q_OSACLK_238         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 238
       LIN_CAL_QP1_238      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 238
       LIN_CAL_QP2_238      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 238

       Q_OFS_239            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 239
       Q_OSACLK_239         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 239
       LIN_CAL_QP1_239      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 239
       LIN_CAL_QP2_239      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 239

       Q_OFS_240            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 240
       Q_OSACLK_240         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 240
       LIN_CAL_QP1_240      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 240
       LIN_CAL_QP2_240      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 240

       Q_OFS_241            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 241
       Q_OSACLK_241         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 241
       LIN_CAL_QP1_241      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 241
       LIN_CAL_QP2_241      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 241

       Q_OFS_242            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 242
       Q_OSACLK_242         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 242
       LIN_CAL_QP1_242      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 242
       LIN_CAL_QP2_242      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 242

       Q_OFS_243            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 243
       Q_OSACLK_243         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 243
       LIN_CAL_QP1_243      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 243
       LIN_CAL_QP2_243      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 243

       Q_OFS_244            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 244
       Q_OSACLK_244         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 244
       LIN_CAL_QP1_244      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 244
       LIN_CAL_QP2_244      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 244

       Q_OFS_245            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 245
       Q_OSACLK_245         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 245
       LIN_CAL_QP1_245      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 245
       LIN_CAL_QP2_245      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 245

       Q_OFS_246            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 246
       Q_OSACLK_246         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 246
       LIN_CAL_QP1_246      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 246
       LIN_CAL_QP2_246      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 246

       Q_OFS_247            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 247
       Q_OSACLK_247         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 247
       LIN_CAL_QP1_247      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 247
       LIN_CAL_QP2_247      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 247

       Q_OFS_248            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 248
       Q_OSACLK_248         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 248
       LIN_CAL_QP1_248      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 248
       LIN_CAL_QP2_248      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 248

       Q_OFS_249            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 249
       Q_OSACLK_249         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 249
       LIN_CAL_QP1_249      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 249
       LIN_CAL_QP2_249      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 249

       Q_OFS_250            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 250
       Q_OSACLK_250         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 250
       LIN_CAL_QP1_250      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 250
       LIN_CAL_QP2_250      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 250

       Q_OFS_251            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 251
       Q_OSACLK_251         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 251
       LIN_CAL_QP1_251      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 251
       LIN_CAL_QP2_251      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 251

       Q_OFS_252            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 252
       Q_OSACLK_252         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 252
       LIN_CAL_QP1_252      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 252
       LIN_CAL_QP2_252      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 252

       Q_OFS_253            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 253
       Q_OSACLK_253         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 253
       LIN_CAL_QP1_253      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 253
       LIN_CAL_QP2_253      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 253

       Q_OFS_254            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 254
       Q_OSACLK_254         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 254
       LIN_CAL_QP1_254      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 254
       LIN_CAL_QP2_254      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 254

       Q_OFS_255            : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 255
       Q_OSACLK_255         : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 255
       LIN_CAL_QP1_255      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 255
       LIN_CAL_QP2_255      : OUT std_logic_vector(15 downto 0); -- RW, CALIBRATION Result Registers - Channel 255


--Array Delta CALIBRATION Result Registers
       ARRAY_DELTA_0  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_1  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_2  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_3  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_4  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_5  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_6  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_7  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_8  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_9  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_10  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_11  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_12  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_13  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_14  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_15  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_16  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_17  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_18  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_19  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_20  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_21  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_22  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_23  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_24  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_25  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_26  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_27  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_28  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_29  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_30  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_31  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_32  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_33  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_34  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_35  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_36  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_37  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_38  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_39  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_40  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_41  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_42  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_43  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_44  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_45  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_46  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_47  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_48  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_49  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_50  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_51  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_52  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_53  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_54  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_55  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_56  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_57  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_58  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_59  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_60  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_61  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_62  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_63  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_64  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_65  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_66  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_67  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_68  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_69  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_70  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_71  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_72  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_73  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_74  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_75  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_76  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_77  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_78  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_79  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_80  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_81  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_82  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_83  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_84  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_85  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_86  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_87  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_88  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_89  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_90  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_91  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_92  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_93  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_94  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_95  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_96  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_97  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_98  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_99  			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_100 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_101 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_102 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_103 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_104 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_105 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_106 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_107 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_108 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_109 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_110 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_111 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_112 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_113 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_114 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_115 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_116 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_117 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_118 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_119 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_120 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_121 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_122 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_123 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_124 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_125 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_126 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_127 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_128 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_129 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_130 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_131 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_132 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_133 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_134 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_135 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_136 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_137 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_138 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_139 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_140 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_141 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_142 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_143 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_144 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_145 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_146 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_147 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_148 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_149 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_150 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_151 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_152 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_153 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_154 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_155 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_156 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_157 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_158 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_159 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_160 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_161 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_162 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_163 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_164 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_165 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_166 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_167 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_168 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_169 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_170 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_171 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_172 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_173 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_174 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_175 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_176 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_177 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_178 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_179 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_180 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_181 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_182 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_183 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_184 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_185 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_186 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_187 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_188 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_189 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_190 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_191 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_192 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_193 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_194 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_195 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_196 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_197 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_198 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_199 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_200 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_201 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_202 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_203 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_204 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_205 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_206 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_207 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_208 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_209 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_210 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_211 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_212 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_213 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_214 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_215 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_216 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_217 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_218 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_219 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_220 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_221 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_222 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_223 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_224 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_225 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_226 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_227 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_228 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_229 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_230 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_231 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_232 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_233 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_234 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_235 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_236 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_237 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_238 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_239 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_240 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_241 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_242 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_243 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_244 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_245 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_246 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_247 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_248 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_249 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_250 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_251 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_252 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_253 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_254 			: OUT std_logic_vector(15 downto 0) ; -- RW, Array Delta Result Registers
       ARRAY_DELTA_255 			: OUT std_logic_vector(15 downto 0)   -- RW, Array Delta Result Registers

--OTP - One Time Programmable Memory
--0x0900 to 0x0942  OTP  RW - Do not overwrite register, for AMS only

	);
End component;

Component Configuration_Registers
PORT(
	RST			: IN STD_LOGIC;
	SCLK			: IN STD_LOGIC;
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
	CALIBRATION	: OUT STD_LOGIC; 
	OPERATIONMODE	: OUT STD_LOGIC; 
	SET_UP		: OUT STD_LOGIC;

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
	LVDS_start_word_14DownTo0	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--LVDS_START_WORD_1
	LVDS_start_word_29DownTo15	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--LVDS_START_WORD_2
	LVDS_start_word_39DownTo30	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0) --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>
	

	
	);
end component;

--connection between modules
--U1 to U2
Signal S_RD_WR 				: std_logic; --'1' Read/'0' Write
Signal S_ADDR_BUS 			: STD_LOGIC_VECTOR (13 DOWNTO 0);
Signal S_DATA_BUS_SDI_WR 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_DATA_BUS_SDI_READ 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
--U2 to U3
Signal S_Calibration_done		:STD_LOGIC:='0';
Signal S_DONE_WRITE			:STD_LOGIC:='0';
Signal S_LVDS_CONFIG_1	 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_LVDS_CONFIG_2	 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_LVDS_CONFIG_3	 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_Clock_CTRL	 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_PADS_CONFIG_2	 		: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_LVDS_START_WORD_0	 	: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_LVDS_START_WORD_1	 	: STD_LOGIC_VECTOR (15 DOWNTO 0);
Signal S_LVDS_START_WORD_2	 	: STD_LOGIC_VECTOR (15 DOWNTO 0);


BEGIN
U1_SPIIFDecoderSM: SPIIFDecoderSM
Port Map(
	SCLK		=> SCLK,
	SDO		=>SDO,
	SCn		=>SCn,
	rst		=>rst,
	SDI		=>SDI,
	RD_WR		=>S_RD_WR, --'1' Read/'0' Write
	ADDR_SPI	=>S_ADDR_BUS,
	DATA_WR		=>S_DATA_BUS_SDI_WR,
	DATA_READ	=>S_DATA_BUS_SDI_READ
);

-------------
U2_R_W_Bank_Reg: R_W_Bank_Reg

port map(
	CLK			=>SCLK,
	RST			=>RST,
	Calibration_done	=>s_Calibration_done,
	RD_WR			=>S_RD_WR, --'1' Read/'0' Write
	ADDR			=>S_ADDR_BUS,
	DATA_WR			=>S_DATA_BUS_SDI_WR,
	DATA_READ		=>S_DATA_BUS_SDI_READ,
	DONE_WRITE		=>S_DONE_WRITE,--'0' while reading/'1' done reading
	LVDS_CONFIG_1		=>S_LVDS_CONFIG_1,
	LVDS_CONFIG_2		=>S_LVDS_CONFIG_2,
	LVDS_CONFIG_3		=>S_LVDS_CONFIG_3,
	Clock_CTRL		=>S_Clock_CTRL,
	PADS_CONFIG_2		=>S_PADS_CONFIG_2,
	LVDS_START_WORD_0	=>S_LVDS_START_WORD_0,
	LVDS_START_WORD_1	=>S_LVDS_START_WORD_1,
	LVDS_START_WORD_2	=>S_LVDS_START_WORD_2
	
	
);

-------------

U3_Configuration_Registers: Configuration_Registers
	port map(
	SCLK			=>SCLK,	
	RST			=>RST,
	Calibration_done	=>s_Calibration_done,
	CALIBRATION		=>CALIBRATION,
	OPERATIONMODE		=>OPERATIONMODE,
	SET_UP			=>SET_UP,--'0' while reading/'1' done reading
--
	LVDS_CONFIG_1		=>S_LVDS_CONFIG_1,
	LVDS_CONFIG_2		=>S_LVDS_CONFIG_2,
	LVDS_CONFIG_3		=>S_LVDS_CONFIG_3,
	Clock_CTRL		=>S_Clock_CTRL,
	PADS_CONFIG_2		=>S_PADS_CONFIG_2,
	LVDS_START_WORD_0	=>S_LVDS_START_WORD_0,
	LVDS_START_WORD_1	=>S_LVDS_START_WORD_1,
	LVDS_START_WORD_2	=>S_LVDS_START_WORD_2,
	DONE_WRITE		=>S_DONE_WRITE,--'0' while reading/'1' done reading
--LVDS_CONFIG_1
	num_data_lines		=>num_data_lines,
	legacy_mode		=>legacy_mode,
	data_word_length	=>data_word_length,
	idle_word		=>idle_word,
	

--LVDS_CONFIG_2 
	start_delay_14DownTo0	=>start_delay_14DownTo0,

--LVDS_CONFIG_3 
	start_delay_17DownTo15	=>start_delay_17DownTo15,
	scrambler_rst		=>scrambler_rst,
	scrambler_en		=>scrambler_en,
	footer_disable		=>footer_disable,
	tm_aci_data		=>tm_aci_data,
	raw_data_bypass		=>raw_data_bypass,

--Clock_CTRL
	hclk_div_cfg		=>hclk_div_cfg,
	

--PADS_CONFIG_2
	itest_dis		=>itest_dis,
	d_start_oen		=>d_start_oen,
	data1_en		=>data1_en,
	data2_en		=>data2_en,
	clk_en			=>clk_en,
	daisy_chain		=>daisy_chain,
	

--LVDS_START_WORD_0
	LVDS_start_word_14DownTo0	=>LVDS_start_word_14DownTo0,

--LVDS_START_WORD_1
	LVDS_start_word_29DownTo15	=>LVDS_start_word_29DownTo15,

--LVDS_START_WORD_2
	LVDS_start_word_39DownTo30	=>LVDS_start_word_39DownTo30
	
);

end Register_IF_arc;