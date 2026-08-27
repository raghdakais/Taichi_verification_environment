
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
----------------------------------------------------------------------------

package AMS_pack is

------------------------------- REGISTER MAP ----------------------------------

-- According "AMS Register Descriptions"
--Device ID Registers
constant DEVICE_ID_0_ADDR      	   		: std_logic_vector(15 downto 0) := X"0000"; --RO, Chip ID Register 0
constant DEVICE_ID_1_ADDR    	  		: std_logic_vector(15 downto 0) := X"0001"; --RO, Chip ID Register 1
constant DEVICE_ID_2_ADDR         	   	: std_logic_vector(15 downto 0) := X"0002"; --RO, Chip ID Register 2

--Internal Test Registers
constant PWR_REF_CTRL_1_ADDR		  	: std_logic_vector(15 downto 0) := X"0003"; --RW, Do not overwrite register, for ams only
constant PWR_REF_CTRL_2_ADDR		   	: std_logic_vector(15 downto 0) := X"0004"; --RW, Do not overwrite register, for ams only
constant PWR_REF_CTRL_3_ADDR		   	: std_logic_vector(15 downto 0) := X"0005"; --RW, Do not overwrite register, for ams only
constant PWR_REF_CTRL_4_ADDR		   	: std_logic_vector(15 downto 0) := X"0006"; --RW, Do not overwrite register, for ams only
constant PWR_REF_CTRL_5_ADDR		   	: std_logic_vector(15 downto 0) := X"0007"; --RW, Do not overwrite register, for ams only

--Power and Reference Control Registers
constant EXT_VREF_CONFIG_ADDR			: std_logic_vector(15 downto 0) := X"000C"; --RW, External Reference Configuration Register

constant HEATER_CONFIG_ADDR			: std_logic_vector(15 downto 0) := X"000D"; --RW, Heater Configuration Register
constant POWER_MONITOR_ADDR			: std_logic_vector(15 downto 0) := X"000E"; --RC, Power Monitor Register

--Software Reset, Clock Control and Status Monitor Register
constant SW_RESET_ADDR				: std_logic_vector(15 downto 0) := X"000F"; --WO, Software Reset Register
constant CLOCK_CTRL_ADDR			: std_logic_vector(15 downto 0) := X"0010"; --RW, Clock Control Register
constant STATUS_MONITOR_ADDR			: std_logic_vector(15 downto 0) := X"0011"; --RC, Status Monitor Register

--LVDS Configuration Registers
constant LVDS_CONFIG_1_ADDR			: std_logic_vector(15 downto 0) := X"0012"; --RW, LVDS Configuration Register
constant LVDS_START_WORD_0_ADDR			: std_logic_vector(15 downto 0) := X"0013"; --RW, LVDS Start Word 0
constant LVDS_START_WORD_1_ADDR			: std_logic_vector(15 downto 0) := X"0014"; --RW, LVDS Start Word 1
constant LVDS_START_WORD_2_ADDR 		: std_logic_vector(15 downto 0) := X"0015"; --RW, LVDS Start Word 2
constant LVDS_CONFIG_2_ADDR			: std_logic_vector(15 downto 0) := X"0016"; --RW, LVDS Configuration Register 2
constant LVDS_CONFIG_3_ADDR	 		: std_logic_vector(15 downto 0) := X"0017"; --RW, LVDS Configuration Register 3

--LVDS Footer Registers
constant LVDS_FOOTER_1_ADDR			: std_logic_vector(15 downto 0) := X"0018"; --RO, LVDS Footer 1 Register
constant LVDS_FOOTER_2_ADDR			: std_logic_vector(15 downto 0) := X"0019"; --RO, LVDS Footer 2 Register
constant LVDS_FOOTER_3_ADDR	 		: std_logic_vector(15 downto 0) := X"001A"; --RO, LVDS Footer 3 Register
constant LVDS_FOOTER_4_ADDR	 		: std_logic_vector(15 downto 0) := X"001B"; --RO, LVDS Footer 4 Register
constant LVDS_FOOTER_5_ADDR	 		: std_logic_vector(15 downto 0) := X"001C"; --RO, LVDS Footer 5 Register
constant LVDS_FOOTER_6_ADDR	 		: std_logic_vector(15 downto 0) := X"001D"; --RO, LVDS Footer 6 Register

--Output and Input Pad Configuration Registers
constant PADS_CONFIG_1_ADDR	 		: std_logic_vector(15 downto 0) := X"001E"; --RW,Pads Configuration Register 1
constant PADS_CONFIG_2_ADDR 			: std_logic_vector(15 downto 0) := X"001F"; --RW, Pads Configuration Register 2

--Test Pattern Registers
constant TEST_PATTERN_0_ADDR	 		: std_logic_vector(15 downto 0) := X"0020"; --RW, Base for test pattern generator [14:0]
constant TEST_PATTERN_1_ADDR	 		: std_logic_vector(15 downto 0) := X"0021"; --RW, Base for test pattern generator [29:15]
constant TEST_PATTERN_2_ADDR	 		: std_logic_vector(15 downto 0) := X"0022"; --RW, Base for test pattern generator [33:30]

--Temperature Sensor Register
constant TEMP_SENSOR_ADDR	 		: std_logic_vector(15 downto 0) := X"0023"; --RO, Temperature Sensor Register

--Integration Period Read Register
constant IP_ACLK_COUNT_ADDR	 		: std_logic_vector(15 downto 0) := X"0024"; -- RO, Integration Period Read Register

--Dummy Registers
constant DUMMY_1_ADDR			 	 : std_logic_vector(15 downto 0) := X"0025"; --4 Dummy registers for future use
constant DUMMY_2_ADDR	 			 : std_logic_vector(15 downto 0) := X"0026"; --4 Dummy registers for future use
constant DUMMY_3_ADDR				 : std_logic_vector(15 downto 0) := X"0027"; --4 Dummy registers for future use
constant DUMMY_4_ADDR				 : std_logic_vector(15 downto 0) := X"0028"; --4 Dummy registers for future use

--Scan Mode Register
constant RESERVED_ADDR 				: std_logic_vector(15 downto 0) := X"0029"; --WO, RESERVED, Do not overwrite register, for ams only

--Photodiode Short Registers
constant TIE_0_ADDR	 			: std_logic_vector(15 downto 0) := X"002A"; --RW, Disable Channel Registers
constant TIE_1_ADDR	 			: std_logic_vector(15 downto 0) := X"002B"; --RW, Disable Channel Registers
constant TIE_2_ADDR	 			: std_logic_vector(15 downto 0) := X"002C"; --RW, Disable Channel Registers
constant TIE_3_ADDR	 			: std_logic_vector(15 downto 0) := X"002D"; --RW, Disable Channel Registers
constant TIE_4_ADDR	 			: std_logic_vector(15 downto 0) := X"002E"; --RW, Disable Channel Registers
constant TIE_5_ADDR	 			: std_logic_vector(15 downto 0) := X"002F"; --RW, Disable Channel Registers
constant TIE_6_ADDR	 			: std_logic_vector(15 downto 0) := X"0030"; --RW, Disable Channel Registers
constant TIE_7_ADDR	 			: std_logic_vector(15 downto 0) := X"0031"; --RW, Disable Channel Registers
constant TIE_8_ADDR	 			: std_logic_vector(15 downto 0) := X"0032"; --RW, Disable Channel Registers
constant TIE_9_ADDR	 			: std_logic_vector(15 downto 0) := X"0033"; --RW, Disable Channel Registers
constant TIE_10_ADDR		 		: std_logic_vector(15 downto 0) := X"0034"; --RW, Disable Channel Registers
constant TIE_11_ADDR	 			: std_logic_vector(15 downto 0) := X"0035"; --RW, Disable Channel Registers
constant TIE_12_ADDR	 			: std_logic_vector(15 downto 0) := X"0036"; --RW, Disable Channel Registers
constant TIE_13_ADDR	 			: std_logic_vector(15 downto 0) := X"0037"; --RW, Disable Channel Registers
constant TIE_14_ADDR	 			: std_logic_vector(15 downto 0) := X"0038"; --RW, Disable Channel Registers
constant TIE_15_ADDR	 			: std_logic_vector(15 downto 0) := X"0039"; --RW, Disable Channel Registers
constant TIE_16_ADDR	 			: std_logic_vector(15 downto 0) := X"003A"; --RW, Disable Channel Registers
constant TIE_17_ADDR	 			: std_logic_vector(15 downto 0) := X"003B"; --RW, Disable Channel Registers

--Enable Signals for Frontend Test Currents
constant EN_ITEST_0_ADDR	 		: std_logic_vector(15 downto 0) := X"003C"; --RW, Enable Test Current Registers
constant EN_ITEST_1_ADDR	 		: std_logic_vector(15 downto 0) := X"003D"; --RW, Enable Test Current Registers
constant EN_ITEST_2_ADDR	 		: std_logic_vector(15 downto 0) := X"003E"; --RW, Enable Test Current Registers
constant EN_ITEST_3_ADDR	 		: std_logic_vector(15 downto 0) := X"003F"; --RW, Enable Test Current Registers
constant EN_ITEST_4_ADDR	 		: std_logic_vector(15 downto 0) := X"0040"; --RW, Enable Test Current Registers
constant EN_ITEST_5_ADDR	 		: std_logic_vector(15 downto 0) := X"0041"; --RW, Enable Test Current Registers
constant EN_ITEST_6_ADDR	 		: std_logic_vector(15 downto 0) := X"0042"; --RW, Enable Test Current Registers
constant EN_ITEST_7_ADDR	 		: std_logic_vector(15 downto 0) := X"0043"; --RW, Enable Test Current Registers
constant EN_ITEST_8_ADDR	 		: std_logic_vector(15 downto 0) := X"0044"; --RW, Enable Test Current Registers
constant EN_ITEST_9_ADDR	 		: std_logic_vector(15 downto 0) := X"0045"; --RW, Enable Test Current Registers
constant EN_ITEST_10_ADDR	 		: std_logic_vector(15 downto 0) := X"0046"; --RW, Enable Test Current Registers
constant EN_ITEST_11_ADDR	 		: std_logic_vector(15 downto 0) := X"0047"; --RW, Enable Test Current Registers
constant EN_ITEST_12_ADDR 			: std_logic_vector(15 downto 0) := X"0048"; --RW, Enable Test Current Registers
constant EN_ITEST_13_ADDR	 		: std_logic_vector(15 downto 0) := X"0049"; --RW, Enable Test Current Registers
constant EN_ITEST_14_ADDR	 		: std_logic_vector(15 downto 0) := X"004A"; --RW, Enable Test Current Registers
constant EN_ITEST_15_ADDR	 		: std_logic_vector(15 downto 0) := X"004B"; --RW, Enable Test Current Registers
constant EN_ITEST_16_ADDR	 		: std_logic_vector(15 downto 0) := X"004C"; --RW, Enable Test Current Registers

--Selection of Input Test Current
constant ITEST_MODE_ADDR		 	: std_logic_vector(15 downto 0) := X"004D"; --RW, Input Test Current Mode Register

--ADC Configuration Register
constant COARSE_QUANTIZER_ADDR	 		: std_logic_vector(15 downto 0) := X"004E"; --RW, Coarse Quantizer Configuration Register

--ADC Test Registers
constant RESERVED_0_ADDR	 		: std_logic_vector(15 downto 0) := X"004F"; --RW, Do not overwrite register, for ams only
constant RESERVED_1_ADDR	 		: std_logic_vector(15 downto 0) := X"0050"; --RW, Do not overwrite register, for ams only
constant RESERVED_2_ADDR	 		: std_logic_vector(15 downto 0) := X"0051"; --RW, Do not overwrite register, for ams only

--Calibration Configuration Register
constant START_AUTO_CAL_ADDR	 		: std_logic_vector(15 downto 0) := X"0052"; --WO, Auto-Calibration Register
constant CALIB_CONFIG_0_ADDR	 		: std_logic_vector(15 downto 0) := X"0053"; --RW, Calibration Configuration Register 0
constant CALIB_CONFIG_1_ADDR	 		: std_logic_vector(15 downto 0) := X"0054"; --RW, Calibration Configuration Register 1

--Offset Voltage Calibration Result Register
constant OFFV_CAL_RESULTS_ADDR		 	: std_logic_vector(15 downto 0) := X"0055";--RO, Offset Voltage Calibration Result Register

--Calibration Configuration Register
constant CALIB_CONFIG_2_ADDR 			 : std_logic_vector(15 downto 0) := X"0056"; --RW,  CALIB_CONFIG_2 Register
constant CALIB_CONFIG_3_ADDR	 		 : std_logic_vector(15 downto 0) := X"0057"; --RW,  CALIB_CONFIG_3 Register

--Calibration Monitor Register
constant CALIB_MONITOR_ADDR			 : std_logic_vector(15 downto 0) := X"0058";--RO, Calibration Monitor Register

--Calibration Result Registers (Channel 0 upto 255)

constant Q_OFS_0_ADDR           : std_logic_vector(15 downto 0) := X"0400"; -- RW, Calibration Result Registers - Channel 0
constant Q_OSACLK_0_ADDR        : std_logic_vector(15 downto 0) := X"0401"; -- RW, Calibration Result Registers - Channel 0
constant LIN_CAL_QP1_0_ADDR     : std_logic_vector(15 downto 0) := X"0402"; -- RW, Calibration Result Registers - Channel 0
constant LIN_CAL_QP2_0_ADDR     : std_logic_vector(15 downto 0) := X"0403"; -- RW, Calibration Result Registers - Channel 0

constant Q_OFS_1_ADDR           : std_logic_vector(15 downto 0) := X"0404"; -- RW, Calibration Result Registers - Channel 1
constant Q_OSACLK_1_ADDR        : std_logic_vector(15 downto 0) := X"0405"; -- RW, Calibration Result Registers - Channel 1
constant LIN_CAL_QP1_1_ADDR     : std_logic_vector(15 downto 0) := X"0406"; -- RW, Calibration Result Registers - Channel 1
constant LIN_CAL_QP2_1_ADDR     : std_logic_vector(15 downto 0) := X"0407"; -- RW, Calibration Result Registers - Channel 1

constant Q_OFS_2_ADDR           : std_logic_vector(15 downto 0) := X"0408"; -- RW, Calibration Result Registers - Channel 2
constant Q_OSACLK_2_ADDR        : std_logic_vector(15 downto 0) := X"0409"; -- RW, Calibration Result Registers - Channel 2
constant LIN_CAL_QP1_2_ADDR     : std_logic_vector(15 downto 0) := X"040a"; -- RW, Calibration Result Registers - Channel 2
constant LIN_CAL_QP2_2_ADDR     : std_logic_vector(15 downto 0) := X"040b"; -- RW, Calibration Result Registers - Channel 2

constant Q_OFS_3_ADDR           : std_logic_vector(15 downto 0) := X"040c"; -- RW, Calibration Result Registers - Channel 3
constant Q_OSACLK_3_ADDR        : std_logic_vector(15 downto 0) := X"040d"; -- RW, Calibration Result Registers - Channel 3
constant LIN_CAL_QP1_3_ADDR     : std_logic_vector(15 downto 0) := X"040e"; -- RW, Calibration Result Registers - Channel 3
constant LIN_CAL_QP2_3_ADDR     : std_logic_vector(15 downto 0) := X"040f"; -- RW, Calibration Result Registers - Channel 3

constant Q_OFS_4_ADDR           : std_logic_vector(15 downto 0) := X"0410"; -- RW, Calibration Result Registers - Channel 4
constant Q_OSACLK_4_ADDR        : std_logic_vector(15 downto 0) := X"0411"; -- RW, Calibration Result Registers - Channel 4
constant LIN_CAL_QP1_4_ADDR     : std_logic_vector(15 downto 0) := X"0412"; -- RW, Calibration Result Registers - Channel 4
constant LIN_CAL_QP2_4_ADDR     : std_logic_vector(15 downto 0) := X"0413"; -- RW, Calibration Result Registers - Channel 4

constant Q_OFS_5_ADDR           : std_logic_vector(15 downto 0) := X"0414"; -- RW, Calibration Result Registers - Channel 5
constant Q_OSACLK_5_ADDR        : std_logic_vector(15 downto 0) := X"0415"; -- RW, Calibration Result Registers - Channel 5
constant LIN_CAL_QP1_5_ADDR     : std_logic_vector(15 downto 0) := X"0416"; -- RW, Calibration Result Registers - Channel 5
constant LIN_CAL_QP2_5_ADDR     : std_logic_vector(15 downto 0) := X"0417"; -- RW, Calibration Result Registers - Channel 5

constant Q_OFS_6_ADDR           : std_logic_vector(15 downto 0) := X"0418"; -- RW, Calibration Result Registers - Channel 6
constant Q_OSACLK_6_ADDR        : std_logic_vector(15 downto 0) := X"0419"; -- RW, Calibration Result Registers - Channel 6
constant LIN_CAL_QP1_6_ADDR     : std_logic_vector(15 downto 0) := X"041a"; -- RW, Calibration Result Registers - Channel 6
constant LIN_CAL_QP2_6_ADDR     : std_logic_vector(15 downto 0) := X"041b"; -- RW, Calibration Result Registers - Channel 6

constant Q_OFS_7_ADDR           : std_logic_vector(15 downto 0) := X"041c"; -- RW, Calibration Result Registers - Channel 7
constant Q_OSACLK_7_ADDR        : std_logic_vector(15 downto 0) := X"041d"; -- RW, Calibration Result Registers - Channel 7
constant LIN_CAL_QP1_7_ADDR     : std_logic_vector(15 downto 0) := X"041e"; -- RW, Calibration Result Registers - Channel 7
constant LIN_CAL_QP2_7_ADDR     : std_logic_vector(15 downto 0) := X"041f"; -- RW, Calibration Result Registers - Channel 7

constant Q_OFS_8_ADDR           : std_logic_vector(15 downto 0) := X"0420"; -- RW, Calibration Result Registers - Channel 8
constant Q_OSACLK_8_ADDR        : std_logic_vector(15 downto 0) := X"0421"; -- RW, Calibration Result Registers - Channel 8
constant LIN_CAL_QP1_8_ADDR     : std_logic_vector(15 downto 0) := X"0422"; -- RW, Calibration Result Registers - Channel 8
constant LIN_CAL_QP2_8_ADDR     : std_logic_vector(15 downto 0) := X"0423"; -- RW, Calibration Result Registers - Channel 8

constant Q_OFS_9_ADDR           : std_logic_vector(15 downto 0) := X"0424"; -- RW, Calibration Result Registers - Channel 9
constant Q_OSACLK_9_ADDR        : std_logic_vector(15 downto 0) := X"0425"; -- RW, Calibration Result Registers - Channel 9
constant LIN_CAL_QP1_9_ADDR     : std_logic_vector(15 downto 0) := X"0426"; -- RW, Calibration Result Registers - Channel 9
constant LIN_CAL_QP2_9_ADDR     : std_logic_vector(15 downto 0) := X"0427"; -- RW, Calibration Result Registers - Channel 9

constant Q_OFS_10_ADDR           : std_logic_vector(15 downto 0) := X"0428"; -- RW, Calibration Result Registers - Channel 10
constant Q_OSACLK_10_ADDR        : std_logic_vector(15 downto 0) := X"0429"; -- RW, Calibration Result Registers - Channel 10
constant LIN_CAL_QP1_10_ADDR     : std_logic_vector(15 downto 0) := X"042a"; -- RW, Calibration Result Registers - Channel 10
constant LIN_CAL_QP2_10_ADDR     : std_logic_vector(15 downto 0) := X"042b"; -- RW, Calibration Result Registers - Channel 10

constant Q_OFS_11_ADDR           : std_logic_vector(15 downto 0) := X"042c"; -- RW, Calibration Result Registers - Channel 11
constant Q_OSACLK_11_ADDR        : std_logic_vector(15 downto 0) := X"042d"; -- RW, Calibration Result Registers - Channel 11
constant LIN_CAL_QP1_11_ADDR     : std_logic_vector(15 downto 0) := X"042e"; -- RW, Calibration Result Registers - Channel 11
constant LIN_CAL_QP2_11_ADDR     : std_logic_vector(15 downto 0) := X"042f"; -- RW, Calibration Result Registers - Channel 11

constant Q_OFS_12_ADDR           : std_logic_vector(15 downto 0) := X"0430"; -- RW, Calibration Result Registers - Channel 12
constant Q_OSACLK_12_ADDR        : std_logic_vector(15 downto 0) := X"0431"; -- RW, Calibration Result Registers - Channel 12
constant LIN_CAL_QP1_12_ADDR     : std_logic_vector(15 downto 0) := X"0432"; -- RW, Calibration Result Registers - Channel 12
constant LIN_CAL_QP2_12_ADDR     : std_logic_vector(15 downto 0) := X"0433"; -- RW, Calibration Result Registers - Channel 12

constant Q_OFS_13_ADDR           : std_logic_vector(15 downto 0) := X"0434"; -- RW, Calibration Result Registers - Channel 13
constant Q_OSACLK_13_ADDR        : std_logic_vector(15 downto 0) := X"0435"; -- RW, Calibration Result Registers - Channel 13
constant LIN_CAL_QP1_13_ADDR     : std_logic_vector(15 downto 0) := X"0436"; -- RW, Calibration Result Registers - Channel 13
constant LIN_CAL_QP2_13_ADDR     : std_logic_vector(15 downto 0) := X"0437"; -- RW, Calibration Result Registers - Channel 13

constant Q_OFS_14_ADDR           : std_logic_vector(15 downto 0) := X"0438"; -- RW, Calibration Result Registers - Channel 14
constant Q_OSACLK_14_ADDR        : std_logic_vector(15 downto 0) := X"0439"; -- RW, Calibration Result Registers - Channel 14
constant LIN_CAL_QP1_14_ADDR     : std_logic_vector(15 downto 0) := X"043a"; -- RW, Calibration Result Registers - Channel 14
constant LIN_CAL_QP2_14_ADDR     : std_logic_vector(15 downto 0) := X"043b"; -- RW, Calibration Result Registers - Channel 14

constant Q_OFS_15_ADDR           : std_logic_vector(15 downto 0) := X"043c"; -- RW, Calibration Result Registers - Channel 15
constant Q_OSACLK_15_ADDR        : std_logic_vector(15 downto 0) := X"043d"; -- RW, Calibration Result Registers - Channel 15
constant LIN_CAL_QP1_15_ADDR     : std_logic_vector(15 downto 0) := X"043e"; -- RW, Calibration Result Registers - Channel 15
constant LIN_CAL_QP2_15_ADDR     : std_logic_vector(15 downto 0) := X"043f"; -- RW, Calibration Result Registers - Channel 15

constant Q_OFS_16_ADDR           : std_logic_vector(15 downto 0) := X"0440"; -- RW, Calibration Result Registers - Channel 16
constant Q_OSACLK_16_ADDR        : std_logic_vector(15 downto 0) := X"0441"; -- RW, Calibration Result Registers - Channel 16
constant LIN_CAL_QP1_16_ADDR     : std_logic_vector(15 downto 0) := X"0442"; -- RW, Calibration Result Registers - Channel 16
constant LIN_CAL_QP2_16_ADDR     : std_logic_vector(15 downto 0) := X"0443"; -- RW, Calibration Result Registers - Channel 16

constant Q_OFS_17_ADDR           : std_logic_vector(15 downto 0) := X"0444"; -- RW, Calibration Result Registers - Channel 17
constant Q_OSACLK_17_ADDR        : std_logic_vector(15 downto 0) := X"0445"; -- RW, Calibration Result Registers - Channel 17
constant LIN_CAL_QP1_17_ADDR     : std_logic_vector(15 downto 0) := X"0446"; -- RW, Calibration Result Registers - Channel 17
constant LIN_CAL_QP2_17_ADDR     : std_logic_vector(15 downto 0) := X"0447"; -- RW, Calibration Result Registers - Channel 17

constant Q_OFS_18_ADDR           : std_logic_vector(15 downto 0) := X"0448"; -- RW, Calibration Result Registers - Channel 18
constant Q_OSACLK_18_ADDR        : std_logic_vector(15 downto 0) := X"0449"; -- RW, Calibration Result Registers - Channel 18
constant LIN_CAL_QP1_18_ADDR     : std_logic_vector(15 downto 0) := X"044a"; -- RW, Calibration Result Registers - Channel 18
constant LIN_CAL_QP2_18_ADDR     : std_logic_vector(15 downto 0) := X"044b"; -- RW, Calibration Result Registers - Channel 18

constant Q_OFS_19_ADDR           : std_logic_vector(15 downto 0) := X"044c"; -- RW, Calibration Result Registers - Channel 19
constant Q_OSACLK_19_ADDR        : std_logic_vector(15 downto 0) := X"044d"; -- RW, Calibration Result Registers - Channel 19
constant LIN_CAL_QP1_19_ADDR     : std_logic_vector(15 downto 0) := X"044e"; -- RW, Calibration Result Registers - Channel 19
constant LIN_CAL_QP2_19_ADDR     : std_logic_vector(15 downto 0) := X"044f"; -- RW, Calibration Result Registers - Channel 19

constant Q_OFS_20_ADDR           : std_logic_vector(15 downto 0) := X"0450"; -- RW, Calibration Result Registers - Channel 20
constant Q_OSACLK_20_ADDR        : std_logic_vector(15 downto 0) := X"0451"; -- RW, Calibration Result Registers - Channel 20
constant LIN_CAL_QP1_20_ADDR     : std_logic_vector(15 downto 0) := X"0452"; -- RW, Calibration Result Registers - Channel 20
constant LIN_CAL_QP2_20_ADDR     : std_logic_vector(15 downto 0) := X"0453"; -- RW, Calibration Result Registers - Channel 20

constant Q_OFS_21_ADDR           : std_logic_vector(15 downto 0) := X"0454"; -- RW, Calibration Result Registers - Channel 21
constant Q_OSACLK_21_ADDR        : std_logic_vector(15 downto 0) := X"0455"; -- RW, Calibration Result Registers - Channel 21
constant LIN_CAL_QP1_21_ADDR     : std_logic_vector(15 downto 0) := X"0456"; -- RW, Calibration Result Registers - Channel 21
constant LIN_CAL_QP2_21_ADDR     : std_logic_vector(15 downto 0) := X"0457"; -- RW, Calibration Result Registers - Channel 21

constant Q_OFS_22_ADDR           : std_logic_vector(15 downto 0) := X"0458"; -- RW, Calibration Result Registers - Channel 22
constant Q_OSACLK_22_ADDR        : std_logic_vector(15 downto 0) := X"0459"; -- RW, Calibration Result Registers - Channel 22
constant LIN_CAL_QP1_22_ADDR     : std_logic_vector(15 downto 0) := X"045a"; -- RW, Calibration Result Registers - Channel 22
constant LIN_CAL_QP2_22_ADDR     : std_logic_vector(15 downto 0) := X"045b"; -- RW, Calibration Result Registers - Channel 22

constant Q_OFS_23_ADDR           : std_logic_vector(15 downto 0) := X"045c"; -- RW, Calibration Result Registers - Channel 23
constant Q_OSACLK_23_ADDR        : std_logic_vector(15 downto 0) := X"045d"; -- RW, Calibration Result Registers - Channel 23
constant LIN_CAL_QP1_23_ADDR     : std_logic_vector(15 downto 0) := X"045e"; -- RW, Calibration Result Registers - Channel 23
constant LIN_CAL_QP2_23_ADDR     : std_logic_vector(15 downto 0) := X"045f"; -- RW, Calibration Result Registers - Channel 23

constant Q_OFS_24_ADDR           : std_logic_vector(15 downto 0) := X"0460"; -- RW, Calibration Result Registers - Channel 24
constant Q_OSACLK_24_ADDR        : std_logic_vector(15 downto 0) := X"0461"; -- RW, Calibration Result Registers - Channel 24
constant LIN_CAL_QP1_24_ADDR     : std_logic_vector(15 downto 0) := X"0462"; -- RW, Calibration Result Registers - Channel 24
constant LIN_CAL_QP2_24_ADDR     : std_logic_vector(15 downto 0) := X"0463"; -- RW, Calibration Result Registers - Channel 24

constant Q_OFS_25_ADDR           : std_logic_vector(15 downto 0) := X"0464"; -- RW, Calibration Result Registers - Channel 25
constant Q_OSACLK_25_ADDR        : std_logic_vector(15 downto 0) := X"0465"; -- RW, Calibration Result Registers - Channel 25
constant LIN_CAL_QP1_25_ADDR     : std_logic_vector(15 downto 0) := X"0466"; -- RW, Calibration Result Registers - Channel 25
constant LIN_CAL_QP2_25_ADDR     : std_logic_vector(15 downto 0) := X"0467"; -- RW, Calibration Result Registers - Channel 25

constant Q_OFS_26_ADDR           : std_logic_vector(15 downto 0) := X"0468"; -- RW, Calibration Result Registers - Channel 26
constant Q_OSACLK_26_ADDR        : std_logic_vector(15 downto 0) := X"0469"; -- RW, Calibration Result Registers - Channel 26
constant LIN_CAL_QP1_26_ADDR     : std_logic_vector(15 downto 0) := X"046a"; -- RW, Calibration Result Registers - Channel 26
constant LIN_CAL_QP2_26_ADDR     : std_logic_vector(15 downto 0) := X"046b"; -- RW, Calibration Result Registers - Channel 26

constant Q_OFS_27_ADDR           : std_logic_vector(15 downto 0) := X"046c"; -- RW, Calibration Result Registers - Channel 27
constant Q_OSACLK_27_ADDR        : std_logic_vector(15 downto 0) := X"046d"; -- RW, Calibration Result Registers - Channel 27
constant LIN_CAL_QP1_27_ADDR     : std_logic_vector(15 downto 0) := X"046e"; -- RW, Calibration Result Registers - Channel 27
constant LIN_CAL_QP2_27_ADDR     : std_logic_vector(15 downto 0) := X"046f"; -- RW, Calibration Result Registers - Channel 27

constant Q_OFS_28_ADDR           : std_logic_vector(15 downto 0) := X"0470"; -- RW, Calibration Result Registers - Channel 28
constant Q_OSACLK_28_ADDR        : std_logic_vector(15 downto 0) := X"0471"; -- RW, Calibration Result Registers - Channel 28
constant LIN_CAL_QP1_28_ADDR     : std_logic_vector(15 downto 0) := X"0472"; -- RW, Calibration Result Registers - Channel 28
constant LIN_CAL_QP2_28_ADDR     : std_logic_vector(15 downto 0) := X"0473"; -- RW, Calibration Result Registers - Channel 28

constant Q_OFS_29_ADDR           : std_logic_vector(15 downto 0) := X"0474"; -- RW, Calibration Result Registers - Channel 29
constant Q_OSACLK_29_ADDR        : std_logic_vector(15 downto 0) := X"0475"; -- RW, Calibration Result Registers - Channel 29
constant LIN_CAL_QP1_29_ADDR     : std_logic_vector(15 downto 0) := X"0476"; -- RW, Calibration Result Registers - Channel 29
constant LIN_CAL_QP2_29_ADDR     : std_logic_vector(15 downto 0) := X"0477"; -- RW, Calibration Result Registers - Channel 29

constant Q_OFS_30_ADDR           : std_logic_vector(15 downto 0) := X"0478"; -- RW, Calibration Result Registers - Channel 30
constant Q_OSACLK_30_ADDR        : std_logic_vector(15 downto 0) := X"0479"; -- RW, Calibration Result Registers - Channel 30
constant LIN_CAL_QP1_30_ADDR     : std_logic_vector(15 downto 0) := X"047a"; -- RW, Calibration Result Registers - Channel 30
constant LIN_CAL_QP2_30_ADDR     : std_logic_vector(15 downto 0) := X"047b"; -- RW, Calibration Result Registers - Channel 30

constant Q_OFS_31_ADDR           : std_logic_vector(15 downto 0) := X"047c"; -- RW, Calibration Result Registers - Channel 31
constant Q_OSACLK_31_ADDR        : std_logic_vector(15 downto 0) := X"047d"; -- RW, Calibration Result Registers - Channel 31
constant LIN_CAL_QP1_31_ADDR     : std_logic_vector(15 downto 0) := X"047e"; -- RW, Calibration Result Registers - Channel 31
constant LIN_CAL_QP2_31_ADDR     : std_logic_vector(15 downto 0) := X"047f"; -- RW, Calibration Result Registers - Channel 31

constant Q_OFS_32_ADDR           : std_logic_vector(15 downto 0) := X"0480"; -- RW, Calibration Result Registers - Channel 32
constant Q_OSACLK_32_ADDR        : std_logic_vector(15 downto 0) := X"0481"; -- RW, Calibration Result Registers - Channel 32
constant LIN_CAL_QP1_32_ADDR     : std_logic_vector(15 downto 0) := X"0482"; -- RW, Calibration Result Registers - Channel 32
constant LIN_CAL_QP2_32_ADDR     : std_logic_vector(15 downto 0) := X"0483"; -- RW, Calibration Result Registers - Channel 32

constant Q_OFS_33_ADDR           : std_logic_vector(15 downto 0) := X"0484"; -- RW, Calibration Result Registers - Channel 33
constant Q_OSACLK_33_ADDR        : std_logic_vector(15 downto 0) := X"0485"; -- RW, Calibration Result Registers - Channel 33
constant LIN_CAL_QP1_33_ADDR     : std_logic_vector(15 downto 0) := X"0486"; -- RW, Calibration Result Registers - Channel 33
constant LIN_CAL_QP2_33_ADDR     : std_logic_vector(15 downto 0) := X"0487"; -- RW, Calibration Result Registers - Channel 33

constant Q_OFS_34_ADDR           : std_logic_vector(15 downto 0) := X"0488"; -- RW, Calibration Result Registers - Channel 34
constant Q_OSACLK_34_ADDR        : std_logic_vector(15 downto 0) := X"0489"; -- RW, Calibration Result Registers - Channel 34
constant LIN_CAL_QP1_34_ADDR     : std_logic_vector(15 downto 0) := X"048a"; -- RW, Calibration Result Registers - Channel 34
constant LIN_CAL_QP2_34_ADDR     : std_logic_vector(15 downto 0) := X"048b"; -- RW, Calibration Result Registers - Channel 34

constant Q_OFS_35_ADDR           : std_logic_vector(15 downto 0) := X"048c"; -- RW, Calibration Result Registers - Channel 35
constant Q_OSACLK_35_ADDR        : std_logic_vector(15 downto 0) := X"048d"; -- RW, Calibration Result Registers - Channel 35
constant LIN_CAL_QP1_35_ADDR     : std_logic_vector(15 downto 0) := X"048e"; -- RW, Calibration Result Registers - Channel 35
constant LIN_CAL_QP2_35_ADDR     : std_logic_vector(15 downto 0) := X"048f"; -- RW, Calibration Result Registers - Channel 35

constant Q_OFS_36_ADDR           : std_logic_vector(15 downto 0) := X"0490"; -- RW, Calibration Result Registers - Channel 36
constant Q_OSACLK_36_ADDR        : std_logic_vector(15 downto 0) := X"0491"; -- RW, Calibration Result Registers - Channel 36
constant LIN_CAL_QP1_36_ADDR     : std_logic_vector(15 downto 0) := X"0492"; -- RW, Calibration Result Registers - Channel 36
constant LIN_CAL_QP2_36_ADDR     : std_logic_vector(15 downto 0) := X"0493"; -- RW, Calibration Result Registers - Channel 36

constant Q_OFS_37_ADDR           : std_logic_vector(15 downto 0) := X"0494"; -- RW, Calibration Result Registers - Channel 37
constant Q_OSACLK_37_ADDR        : std_logic_vector(15 downto 0) := X"0495"; -- RW, Calibration Result Registers - Channel 37
constant LIN_CAL_QP1_37_ADDR     : std_logic_vector(15 downto 0) := X"0496"; -- RW, Calibration Result Registers - Channel 37
constant LIN_CAL_QP2_37_ADDR     : std_logic_vector(15 downto 0) := X"0497"; -- RW, Calibration Result Registers - Channel 37

constant Q_OFS_38_ADDR           : std_logic_vector(15 downto 0) := X"0498"; -- RW, Calibration Result Registers - Channel 38
constant Q_OSACLK_38_ADDR        : std_logic_vector(15 downto 0) := X"0499"; -- RW, Calibration Result Registers - Channel 38
constant LIN_CAL_QP1_38_ADDR     : std_logic_vector(15 downto 0) := X"049a"; -- RW, Calibration Result Registers - Channel 38
constant LIN_CAL_QP2_38_ADDR     : std_logic_vector(15 downto 0) := X"049b"; -- RW, Calibration Result Registers - Channel 38

constant Q_OFS_39_ADDR           : std_logic_vector(15 downto 0) := X"049c"; -- RW, Calibration Result Registers - Channel 39
constant Q_OSACLK_39_ADDR        : std_logic_vector(15 downto 0) := X"049d"; -- RW, Calibration Result Registers - Channel 39
constant LIN_CAL_QP1_39_ADDR     : std_logic_vector(15 downto 0) := X"049e"; -- RW, Calibration Result Registers - Channel 39
constant LIN_CAL_QP2_39_ADDR     : std_logic_vector(15 downto 0) := X"049f"; -- RW, Calibration Result Registers - Channel 39

constant Q_OFS_40_ADDR           : std_logic_vector(15 downto 0) := X"04a0"; -- RW, Calibration Result Registers - Channel 40
constant Q_OSACLK_40_ADDR        : std_logic_vector(15 downto 0) := X"04a1"; -- RW, Calibration Result Registers - Channel 40
constant LIN_CAL_QP1_40_ADDR     : std_logic_vector(15 downto 0) := X"04a2"; -- RW, Calibration Result Registers - Channel 40
constant LIN_CAL_QP2_40_ADDR     : std_logic_vector(15 downto 0) := X"04a3"; -- RW, Calibration Result Registers - Channel 40

constant Q_OFS_41_ADDR           : std_logic_vector(15 downto 0) := X"04a4"; -- RW, Calibration Result Registers - Channel 41
constant Q_OSACLK_41_ADDR        : std_logic_vector(15 downto 0) := X"04a5"; -- RW, Calibration Result Registers - Channel 41
constant LIN_CAL_QP1_41_ADDR     : std_logic_vector(15 downto 0) := X"04a6"; -- RW, Calibration Result Registers - Channel 41
constant LIN_CAL_QP2_41_ADDR     : std_logic_vector(15 downto 0) := X"04a7"; -- RW, Calibration Result Registers - Channel 41

constant Q_OFS_42_ADDR           : std_logic_vector(15 downto 0) := X"04a8"; -- RW, Calibration Result Registers - Channel 42
constant Q_OSACLK_42_ADDR        : std_logic_vector(15 downto 0) := X"04a9"; -- RW, Calibration Result Registers - Channel 42
constant LIN_CAL_QP1_42_ADDR     : std_logic_vector(15 downto 0) := X"04aa"; -- RW, Calibration Result Registers - Channel 42
constant LIN_CAL_QP2_42_ADDR     : std_logic_vector(15 downto 0) := X"04ab"; -- RW, Calibration Result Registers - Channel 42

constant Q_OFS_43_ADDR           : std_logic_vector(15 downto 0) := X"04ac"; -- RW, Calibration Result Registers - Channel 43
constant Q_OSACLK_43_ADDR        : std_logic_vector(15 downto 0) := X"04ad"; -- RW, Calibration Result Registers - Channel 43
constant LIN_CAL_QP1_43_ADDR     : std_logic_vector(15 downto 0) := X"04ae"; -- RW, Calibration Result Registers - Channel 43
constant LIN_CAL_QP2_43_ADDR     : std_logic_vector(15 downto 0) := X"04af"; -- RW, Calibration Result Registers - Channel 43

constant Q_OFS_44_ADDR           : std_logic_vector(15 downto 0) := X"04b0"; -- RW, Calibration Result Registers - Channel 44
constant Q_OSACLK_44_ADDR        : std_logic_vector(15 downto 0) := X"04b1"; -- RW, Calibration Result Registers - Channel 44
constant LIN_CAL_QP1_44_ADDR     : std_logic_vector(15 downto 0) := X"04b2"; -- RW, Calibration Result Registers - Channel 44
constant LIN_CAL_QP2_44_ADDR     : std_logic_vector(15 downto 0) := X"04b3"; -- RW, Calibration Result Registers - Channel 44

constant Q_OFS_45_ADDR           : std_logic_vector(15 downto 0) := X"04b4"; -- RW, Calibration Result Registers - Channel 45
constant Q_OSACLK_45_ADDR        : std_logic_vector(15 downto 0) := X"04b5"; -- RW, Calibration Result Registers - Channel 45
constant LIN_CAL_QP1_45_ADDR     : std_logic_vector(15 downto 0) := X"04b6"; -- RW, Calibration Result Registers - Channel 45
constant LIN_CAL_QP2_45_ADDR     : std_logic_vector(15 downto 0) := X"04b7"; -- RW, Calibration Result Registers - Channel 45

constant Q_OFS_46_ADDR           : std_logic_vector(15 downto 0) := X"04b8"; -- RW, Calibration Result Registers - Channel 46
constant Q_OSACLK_46_ADDR        : std_logic_vector(15 downto 0) := X"04b9"; -- RW, Calibration Result Registers - Channel 46
constant LIN_CAL_QP1_46_ADDR     : std_logic_vector(15 downto 0) := X"04ba"; -- RW, Calibration Result Registers - Channel 46
constant LIN_CAL_QP2_46_ADDR     : std_logic_vector(15 downto 0) := X"04bb"; -- RW, Calibration Result Registers - Channel 46

constant Q_OFS_47_ADDR           : std_logic_vector(15 downto 0) := X"04bc"; -- RW, Calibration Result Registers - Channel 47
constant Q_OSACLK_47_ADDR        : std_logic_vector(15 downto 0) := X"04bd"; -- RW, Calibration Result Registers - Channel 47
constant LIN_CAL_QP1_47_ADDR     : std_logic_vector(15 downto 0) := X"04be"; -- RW, Calibration Result Registers - Channel 47
constant LIN_CAL_QP2_47_ADDR     : std_logic_vector(15 downto 0) := X"04bf"; -- RW, Calibration Result Registers - Channel 47

constant Q_OFS_48_ADDR           : std_logic_vector(15 downto 0) := X"04c0"; -- RW, Calibration Result Registers - Channel 48
constant Q_OSACLK_48_ADDR        : std_logic_vector(15 downto 0) := X"04c1"; -- RW, Calibration Result Registers - Channel 48
constant LIN_CAL_QP1_48_ADDR     : std_logic_vector(15 downto 0) := X"04c2"; -- RW, Calibration Result Registers - Channel 48
constant LIN_CAL_QP2_48_ADDR     : std_logic_vector(15 downto 0) := X"04c3"; -- RW, Calibration Result Registers - Channel 48

constant Q_OFS_49_ADDR           : std_logic_vector(15 downto 0) := X"04c4"; -- RW, Calibration Result Registers - Channel 49
constant Q_OSACLK_49_ADDR        : std_logic_vector(15 downto 0) := X"04c5"; -- RW, Calibration Result Registers - Channel 49
constant LIN_CAL_QP1_49_ADDR     : std_logic_vector(15 downto 0) := X"04c6"; -- RW, Calibration Result Registers - Channel 49
constant LIN_CAL_QP2_49_ADDR     : std_logic_vector(15 downto 0) := X"04c7"; -- RW, Calibration Result Registers - Channel 49

constant Q_OFS_50_ADDR           : std_logic_vector(15 downto 0) := X"04c8"; -- RW, Calibration Result Registers - Channel 50
constant Q_OSACLK_50_ADDR        : std_logic_vector(15 downto 0) := X"04c9"; -- RW, Calibration Result Registers - Channel 50
constant LIN_CAL_QP1_50_ADDR     : std_logic_vector(15 downto 0) := X"04ca"; -- RW, Calibration Result Registers - Channel 50
constant LIN_CAL_QP2_50_ADDR     : std_logic_vector(15 downto 0) := X"04cb"; -- RW, Calibration Result Registers - Channel 50

constant Q_OFS_51_ADDR           : std_logic_vector(15 downto 0) := X"04cc"; -- RW, Calibration Result Registers - Channel 51
constant Q_OSACLK_51_ADDR        : std_logic_vector(15 downto 0) := X"04cd"; -- RW, Calibration Result Registers - Channel 51
constant LIN_CAL_QP1_51_ADDR     : std_logic_vector(15 downto 0) := X"04ce"; -- RW, Calibration Result Registers - Channel 51
constant LIN_CAL_QP2_51_ADDR     : std_logic_vector(15 downto 0) := X"04cf"; -- RW, Calibration Result Registers - Channel 51

constant Q_OFS_52_ADDR           : std_logic_vector(15 downto 0) := X"04d0"; -- RW, Calibration Result Registers - Channel 52
constant Q_OSACLK_52_ADDR        : std_logic_vector(15 downto 0) := X"04d1"; -- RW, Calibration Result Registers - Channel 52
constant LIN_CAL_QP1_52_ADDR     : std_logic_vector(15 downto 0) := X"04d2"; -- RW, Calibration Result Registers - Channel 52
constant LIN_CAL_QP2_52_ADDR     : std_logic_vector(15 downto 0) := X"04d3"; -- RW, Calibration Result Registers - Channel 52

constant Q_OFS_53_ADDR           : std_logic_vector(15 downto 0) := X"04d4"; -- RW, Calibration Result Registers - Channel 53
constant Q_OSACLK_53_ADDR        : std_logic_vector(15 downto 0) := X"04d5"; -- RW, Calibration Result Registers - Channel 53
constant LIN_CAL_QP1_53_ADDR     : std_logic_vector(15 downto 0) := X"04d6"; -- RW, Calibration Result Registers - Channel 53
constant LIN_CAL_QP2_53_ADDR     : std_logic_vector(15 downto 0) := X"04d7"; -- RW, Calibration Result Registers - Channel 53

constant Q_OFS_54_ADDR           : std_logic_vector(15 downto 0) := X"04d8"; -- RW, Calibration Result Registers - Channel 54
constant Q_OSACLK_54_ADDR        : std_logic_vector(15 downto 0) := X"04d9"; -- RW, Calibration Result Registers - Channel 54
constant LIN_CAL_QP1_54_ADDR     : std_logic_vector(15 downto 0) := X"04da"; -- RW, Calibration Result Registers - Channel 54
constant LIN_CAL_QP2_54_ADDR     : std_logic_vector(15 downto 0) := X"04db"; -- RW, Calibration Result Registers - Channel 54

constant Q_OFS_55_ADDR           : std_logic_vector(15 downto 0) := X"04dc"; -- RW, Calibration Result Registers - Channel 55
constant Q_OSACLK_55_ADDR        : std_logic_vector(15 downto 0) := X"04dd"; -- RW, Calibration Result Registers - Channel 55
constant LIN_CAL_QP1_55_ADDR     : std_logic_vector(15 downto 0) := X"04de"; -- RW, Calibration Result Registers - Channel 55
constant LIN_CAL_QP2_55_ADDR     : std_logic_vector(15 downto 0) := X"04df"; -- RW, Calibration Result Registers - Channel 55

constant Q_OFS_56_ADDR           : std_logic_vector(15 downto 0) := X"04e0"; -- RW, Calibration Result Registers - Channel 56
constant Q_OSACLK_56_ADDR        : std_logic_vector(15 downto 0) := X"04e1"; -- RW, Calibration Result Registers - Channel 56
constant LIN_CAL_QP1_56_ADDR     : std_logic_vector(15 downto 0) := X"04e2"; -- RW, Calibration Result Registers - Channel 56
constant LIN_CAL_QP2_56_ADDR     : std_logic_vector(15 downto 0) := X"04e3"; -- RW, Calibration Result Registers - Channel 56

constant Q_OFS_57_ADDR           : std_logic_vector(15 downto 0) := X"04e4"; -- RW, Calibration Result Registers - Channel 57
constant Q_OSACLK_57_ADDR        : std_logic_vector(15 downto 0) := X"04e5"; -- RW, Calibration Result Registers - Channel 57
constant LIN_CAL_QP1_57_ADDR     : std_logic_vector(15 downto 0) := X"04e6"; -- RW, Calibration Result Registers - Channel 57
constant LIN_CAL_QP2_57_ADDR     : std_logic_vector(15 downto 0) := X"04e7"; -- RW, Calibration Result Registers - Channel 57

constant Q_OFS_58_ADDR           : std_logic_vector(15 downto 0) := X"04e8"; -- RW, Calibration Result Registers - Channel 58
constant Q_OSACLK_58_ADDR        : std_logic_vector(15 downto 0) := X"04e9"; -- RW, Calibration Result Registers - Channel 58
constant LIN_CAL_QP1_58_ADDR     : std_logic_vector(15 downto 0) := X"04ea"; -- RW, Calibration Result Registers - Channel 58
constant LIN_CAL_QP2_58_ADDR     : std_logic_vector(15 downto 0) := X"04eb"; -- RW, Calibration Result Registers - Channel 58

constant Q_OFS_59_ADDR           : std_logic_vector(15 downto 0) := X"04ec"; -- RW, Calibration Result Registers - Channel 59
constant Q_OSACLK_59_ADDR        : std_logic_vector(15 downto 0) := X"04ed"; -- RW, Calibration Result Registers - Channel 59
constant LIN_CAL_QP1_59_ADDR     : std_logic_vector(15 downto 0) := X"04ee"; -- RW, Calibration Result Registers - Channel 59
constant LIN_CAL_QP2_59_ADDR     : std_logic_vector(15 downto 0) := X"04ef"; -- RW, Calibration Result Registers - Channel 59

constant Q_OFS_60_ADDR           : std_logic_vector(15 downto 0) := X"04f0"; -- RW, Calibration Result Registers - Channel 60
constant Q_OSACLK_60_ADDR        : std_logic_vector(15 downto 0) := X"04f1"; -- RW, Calibration Result Registers - Channel 60
constant LIN_CAL_QP1_60_ADDR     : std_logic_vector(15 downto 0) := X"04f2"; -- RW, Calibration Result Registers - Channel 60
constant LIN_CAL_QP2_60_ADDR     : std_logic_vector(15 downto 0) := X"04f3"; -- RW, Calibration Result Registers - Channel 60

constant Q_OFS_61_ADDR           : std_logic_vector(15 downto 0) := X"04f4"; -- RW, Calibration Result Registers - Channel 61
constant Q_OSACLK_61_ADDR        : std_logic_vector(15 downto 0) := X"04f5"; -- RW, Calibration Result Registers - Channel 61
constant LIN_CAL_QP1_61_ADDR     : std_logic_vector(15 downto 0) := X"04f6"; -- RW, Calibration Result Registers - Channel 61
constant LIN_CAL_QP2_61_ADDR     : std_logic_vector(15 downto 0) := X"04f7"; -- RW, Calibration Result Registers - Channel 61

constant Q_OFS_62_ADDR           : std_logic_vector(15 downto 0) := X"04f8"; -- RW, Calibration Result Registers - Channel 62
constant Q_OSACLK_62_ADDR        : std_logic_vector(15 downto 0) := X"04f9"; -- RW, Calibration Result Registers - Channel 62
constant LIN_CAL_QP1_62_ADDR     : std_logic_vector(15 downto 0) := X"04fa"; -- RW, Calibration Result Registers - Channel 62
constant LIN_CAL_QP2_62_ADDR     : std_logic_vector(15 downto 0) := X"04fb"; -- RW, Calibration Result Registers - Channel 62

constant Q_OFS_63_ADDR           : std_logic_vector(15 downto 0) := X"04fc"; -- RW, Calibration Result Registers - Channel 63
constant Q_OSACLK_63_ADDR        : std_logic_vector(15 downto 0) := X"04fd"; -- RW, Calibration Result Registers - Channel 63
constant LIN_CAL_QP1_63_ADDR     : std_logic_vector(15 downto 0) := X"04fe"; -- RW, Calibration Result Registers - Channel 63
constant LIN_CAL_QP2_63_ADDR     : std_logic_vector(15 downto 0) := X"04ff"; -- RW, Calibration Result Registers - Channel 63

constant Q_OFS_64_ADDR           : std_logic_vector(15 downto 0) := X"0500"; -- RW, Calibration Result Registers - Channel 64
constant Q_OSACLK_64_ADDR        : std_logic_vector(15 downto 0) := X"0501"; -- RW, Calibration Result Registers - Channel 64
constant LIN_CAL_QP1_64_ADDR     : std_logic_vector(15 downto 0) := X"0502"; -- RW, Calibration Result Registers - Channel 64
constant LIN_CAL_QP2_64_ADDR     : std_logic_vector(15 downto 0) := X"0503"; -- RW, Calibration Result Registers - Channel 64

constant Q_OFS_65_ADDR           : std_logic_vector(15 downto 0) := X"0504"; -- RW, Calibration Result Registers - Channel 65
constant Q_OSACLK_65_ADDR        : std_logic_vector(15 downto 0) := X"0505"; -- RW, Calibration Result Registers - Channel 65
constant LIN_CAL_QP1_65_ADDR     : std_logic_vector(15 downto 0) := X"0506"; -- RW, Calibration Result Registers - Channel 65
constant LIN_CAL_QP2_65_ADDR     : std_logic_vector(15 downto 0) := X"0507"; -- RW, Calibration Result Registers - Channel 65

constant Q_OFS_66_ADDR           : std_logic_vector(15 downto 0) := X"0508"; -- RW, Calibration Result Registers - Channel 66
constant Q_OSACLK_66_ADDR        : std_logic_vector(15 downto 0) := X"0509"; -- RW, Calibration Result Registers - Channel 66
constant LIN_CAL_QP1_66_ADDR     : std_logic_vector(15 downto 0) := X"050a"; -- RW, Calibration Result Registers - Channel 66
constant LIN_CAL_QP2_66_ADDR     : std_logic_vector(15 downto 0) := X"050b"; -- RW, Calibration Result Registers - Channel 66

constant Q_OFS_67_ADDR           : std_logic_vector(15 downto 0) := X"050c"; -- RW, Calibration Result Registers - Channel 67
constant Q_OSACLK_67_ADDR        : std_logic_vector(15 downto 0) := X"050d"; -- RW, Calibration Result Registers - Channel 67
constant LIN_CAL_QP1_67_ADDR     : std_logic_vector(15 downto 0) := X"050e"; -- RW, Calibration Result Registers - Channel 67
constant LIN_CAL_QP2_67_ADDR     : std_logic_vector(15 downto 0) := X"050f"; -- RW, Calibration Result Registers - Channel 67

constant Q_OFS_68_ADDR           : std_logic_vector(15 downto 0) := X"0510"; -- RW, Calibration Result Registers - Channel 68
constant Q_OSACLK_68_ADDR        : std_logic_vector(15 downto 0) := X"0511"; -- RW, Calibration Result Registers - Channel 68
constant LIN_CAL_QP1_68_ADDR     : std_logic_vector(15 downto 0) := X"0512"; -- RW, Calibration Result Registers - Channel 68
constant LIN_CAL_QP2_68_ADDR     : std_logic_vector(15 downto 0) := X"0513"; -- RW, Calibration Result Registers - Channel 68

constant Q_OFS_69_ADDR           : std_logic_vector(15 downto 0) := X"0514"; -- RW, Calibration Result Registers - Channel 69
constant Q_OSACLK_69_ADDR        : std_logic_vector(15 downto 0) := X"0515"; -- RW, Calibration Result Registers - Channel 69
constant LIN_CAL_QP1_69_ADDR     : std_logic_vector(15 downto 0) := X"0516"; -- RW, Calibration Result Registers - Channel 69
constant LIN_CAL_QP2_69_ADDR     : std_logic_vector(15 downto 0) := X"0517"; -- RW, Calibration Result Registers - Channel 69

constant Q_OFS_70_ADDR           : std_logic_vector(15 downto 0) := X"0518"; -- RW, Calibration Result Registers - Channel 70
constant Q_OSACLK_70_ADDR        : std_logic_vector(15 downto 0) := X"0519"; -- RW, Calibration Result Registers - Channel 70
constant LIN_CAL_QP1_70_ADDR     : std_logic_vector(15 downto 0) := X"051a"; -- RW, Calibration Result Registers - Channel 70
constant LIN_CAL_QP2_70_ADDR     : std_logic_vector(15 downto 0) := X"051b"; -- RW, Calibration Result Registers - Channel 70

constant Q_OFS_71_ADDR           : std_logic_vector(15 downto 0) := X"051c"; -- RW, Calibration Result Registers - Channel 71
constant Q_OSACLK_71_ADDR        : std_logic_vector(15 downto 0) := X"051d"; -- RW, Calibration Result Registers - Channel 71
constant LIN_CAL_QP1_71_ADDR     : std_logic_vector(15 downto 0) := X"051e"; -- RW, Calibration Result Registers - Channel 71
constant LIN_CAL_QP2_71_ADDR     : std_logic_vector(15 downto 0) := X"051f"; -- RW, Calibration Result Registers - Channel 71

constant Q_OFS_72_ADDR           : std_logic_vector(15 downto 0) := X"0520"; -- RW, Calibration Result Registers - Channel 72
constant Q_OSACLK_72_ADDR        : std_logic_vector(15 downto 0) := X"0521"; -- RW, Calibration Result Registers - Channel 72
constant LIN_CAL_QP1_72_ADDR     : std_logic_vector(15 downto 0) := X"0522"; -- RW, Calibration Result Registers - Channel 72
constant LIN_CAL_QP2_72_ADDR     : std_logic_vector(15 downto 0) := X"0523"; -- RW, Calibration Result Registers - Channel 72

constant Q_OFS_73_ADDR           : std_logic_vector(15 downto 0) := X"0524"; -- RW, Calibration Result Registers - Channel 73
constant Q_OSACLK_73_ADDR        : std_logic_vector(15 downto 0) := X"0525"; -- RW, Calibration Result Registers - Channel 73
constant LIN_CAL_QP1_73_ADDR     : std_logic_vector(15 downto 0) := X"0526"; -- RW, Calibration Result Registers - Channel 73
constant LIN_CAL_QP2_73_ADDR     : std_logic_vector(15 downto 0) := X"0527"; -- RW, Calibration Result Registers - Channel 73

constant Q_OFS_74_ADDR           : std_logic_vector(15 downto 0) := X"0528"; -- RW, Calibration Result Registers - Channel 74
constant Q_OSACLK_74_ADDR        : std_logic_vector(15 downto 0) := X"0529"; -- RW, Calibration Result Registers - Channel 74
constant LIN_CAL_QP1_74_ADDR     : std_logic_vector(15 downto 0) := X"052a"; -- RW, Calibration Result Registers - Channel 74
constant LIN_CAL_QP2_74_ADDR     : std_logic_vector(15 downto 0) := X"052b"; -- RW, Calibration Result Registers - Channel 74

constant Q_OFS_75_ADDR           : std_logic_vector(15 downto 0) := X"052c"; -- RW, Calibration Result Registers - Channel 75
constant Q_OSACLK_75_ADDR        : std_logic_vector(15 downto 0) := X"052d"; -- RW, Calibration Result Registers - Channel 75
constant LIN_CAL_QP1_75_ADDR     : std_logic_vector(15 downto 0) := X"052e"; -- RW, Calibration Result Registers - Channel 75
constant LIN_CAL_QP2_75_ADDR     : std_logic_vector(15 downto 0) := X"052f"; -- RW, Calibration Result Registers - Channel 75

constant Q_OFS_76_ADDR           : std_logic_vector(15 downto 0) := X"0530"; -- RW, Calibration Result Registers - Channel 76
constant Q_OSACLK_76_ADDR        : std_logic_vector(15 downto 0) := X"0531"; -- RW, Calibration Result Registers - Channel 76
constant LIN_CAL_QP1_76_ADDR     : std_logic_vector(15 downto 0) := X"0532"; -- RW, Calibration Result Registers - Channel 76
constant LIN_CAL_QP2_76_ADDR     : std_logic_vector(15 downto 0) := X"0533"; -- RW, Calibration Result Registers - Channel 76

constant Q_OFS_77_ADDR           : std_logic_vector(15 downto 0) := X"0534"; -- RW, Calibration Result Registers - Channel 77
constant Q_OSACLK_77_ADDR        : std_logic_vector(15 downto 0) := X"0535"; -- RW, Calibration Result Registers - Channel 77
constant LIN_CAL_QP1_77_ADDR     : std_logic_vector(15 downto 0) := X"0536"; -- RW, Calibration Result Registers - Channel 77
constant LIN_CAL_QP2_77_ADDR     : std_logic_vector(15 downto 0) := X"0537"; -- RW, Calibration Result Registers - Channel 77

constant Q_OFS_78_ADDR           : std_logic_vector(15 downto 0) := X"0538"; -- RW, Calibration Result Registers - Channel 78
constant Q_OSACLK_78_ADDR        : std_logic_vector(15 downto 0) := X"0539"; -- RW, Calibration Result Registers - Channel 78
constant LIN_CAL_QP1_78_ADDR     : std_logic_vector(15 downto 0) := X"053a"; -- RW, Calibration Result Registers - Channel 78
constant LIN_CAL_QP2_78_ADDR     : std_logic_vector(15 downto 0) := X"053b"; -- RW, Calibration Result Registers - Channel 78

constant Q_OFS_79_ADDR           : std_logic_vector(15 downto 0) := X"053c"; -- RW, Calibration Result Registers - Channel 79
constant Q_OSACLK_79_ADDR        : std_logic_vector(15 downto 0) := X"053d"; -- RW, Calibration Result Registers - Channel 79
constant LIN_CAL_QP1_79_ADDR     : std_logic_vector(15 downto 0) := X"053e"; -- RW, Calibration Result Registers - Channel 79
constant LIN_CAL_QP2_79_ADDR     : std_logic_vector(15 downto 0) := X"053f"; -- RW, Calibration Result Registers - Channel 79

constant Q_OFS_80_ADDR           : std_logic_vector(15 downto 0) := X"0540"; -- RW, Calibration Result Registers - Channel 80
constant Q_OSACLK_80_ADDR        : std_logic_vector(15 downto 0) := X"0541"; -- RW, Calibration Result Registers - Channel 80
constant LIN_CAL_QP1_80_ADDR     : std_logic_vector(15 downto 0) := X"0542"; -- RW, Calibration Result Registers - Channel 80
constant LIN_CAL_QP2_80_ADDR     : std_logic_vector(15 downto 0) := X"0543"; -- RW, Calibration Result Registers - Channel 80

constant Q_OFS_81_ADDR           : std_logic_vector(15 downto 0) := X"0544"; -- RW, Calibration Result Registers - Channel 81
constant Q_OSACLK_81_ADDR        : std_logic_vector(15 downto 0) := X"0545"; -- RW, Calibration Result Registers - Channel 81
constant LIN_CAL_QP1_81_ADDR     : std_logic_vector(15 downto 0) := X"0546"; -- RW, Calibration Result Registers - Channel 81
constant LIN_CAL_QP2_81_ADDR     : std_logic_vector(15 downto 0) := X"0547"; -- RW, Calibration Result Registers - Channel 81

constant Q_OFS_82_ADDR           : std_logic_vector(15 downto 0) := X"0548"; -- RW, Calibration Result Registers - Channel 82
constant Q_OSACLK_82_ADDR        : std_logic_vector(15 downto 0) := X"0549"; -- RW, Calibration Result Registers - Channel 82
constant LIN_CAL_QP1_82_ADDR     : std_logic_vector(15 downto 0) := X"054a"; -- RW, Calibration Result Registers - Channel 82
constant LIN_CAL_QP2_82_ADDR     : std_logic_vector(15 downto 0) := X"054b"; -- RW, Calibration Result Registers - Channel 82

constant Q_OFS_83_ADDR           : std_logic_vector(15 downto 0) := X"054c"; -- RW, Calibration Result Registers - Channel 83
constant Q_OSACLK_83_ADDR        : std_logic_vector(15 downto 0) := X"054d"; -- RW, Calibration Result Registers - Channel 83
constant LIN_CAL_QP1_83_ADDR     : std_logic_vector(15 downto 0) := X"054e"; -- RW, Calibration Result Registers - Channel 83
constant LIN_CAL_QP2_83_ADDR     : std_logic_vector(15 downto 0) := X"054f"; -- RW, Calibration Result Registers - Channel 83

constant Q_OFS_84_ADDR           : std_logic_vector(15 downto 0) := X"0550"; -- RW, Calibration Result Registers - Channel 84
constant Q_OSACLK_84_ADDR        : std_logic_vector(15 downto 0) := X"0551"; -- RW, Calibration Result Registers - Channel 84
constant LIN_CAL_QP1_84_ADDR     : std_logic_vector(15 downto 0) := X"0552"; -- RW, Calibration Result Registers - Channel 84
constant LIN_CAL_QP2_84_ADDR     : std_logic_vector(15 downto 0) := X"0553"; -- RW, Calibration Result Registers - Channel 84

constant Q_OFS_85_ADDR           : std_logic_vector(15 downto 0) := X"0554"; -- RW, Calibration Result Registers - Channel 85
constant Q_OSACLK_85_ADDR        : std_logic_vector(15 downto 0) := X"0555"; -- RW, Calibration Result Registers - Channel 85
constant LIN_CAL_QP1_85_ADDR     : std_logic_vector(15 downto 0) := X"0556"; -- RW, Calibration Result Registers - Channel 85
constant LIN_CAL_QP2_85_ADDR     : std_logic_vector(15 downto 0) := X"0557"; -- RW, Calibration Result Registers - Channel 85

constant Q_OFS_86_ADDR           : std_logic_vector(15 downto 0) := X"0558"; -- RW, Calibration Result Registers - Channel 86
constant Q_OSACLK_86_ADDR        : std_logic_vector(15 downto 0) := X"0559"; -- RW, Calibration Result Registers - Channel 86
constant LIN_CAL_QP1_86_ADDR     : std_logic_vector(15 downto 0) := X"055a"; -- RW, Calibration Result Registers - Channel 86
constant LIN_CAL_QP2_86_ADDR     : std_logic_vector(15 downto 0) := X"055b"; -- RW, Calibration Result Registers - Channel 86

constant Q_OFS_87_ADDR           : std_logic_vector(15 downto 0) := X"055c"; -- RW, Calibration Result Registers - Channel 87
constant Q_OSACLK_87_ADDR        : std_logic_vector(15 downto 0) := X"055d"; -- RW, Calibration Result Registers - Channel 87
constant LIN_CAL_QP1_87_ADDR     : std_logic_vector(15 downto 0) := X"055e"; -- RW, Calibration Result Registers - Channel 87
constant LIN_CAL_QP2_87_ADDR     : std_logic_vector(15 downto 0) := X"055f"; -- RW, Calibration Result Registers - Channel 87

constant Q_OFS_88_ADDR           : std_logic_vector(15 downto 0) := X"0560"; -- RW, Calibration Result Registers - Channel 88
constant Q_OSACLK_88_ADDR        : std_logic_vector(15 downto 0) := X"0561"; -- RW, Calibration Result Registers - Channel 88
constant LIN_CAL_QP1_88_ADDR     : std_logic_vector(15 downto 0) := X"0562"; -- RW, Calibration Result Registers - Channel 88
constant LIN_CAL_QP2_88_ADDR     : std_logic_vector(15 downto 0) := X"0563"; -- RW, Calibration Result Registers - Channel 88

constant Q_OFS_89_ADDR           : std_logic_vector(15 downto 0) := X"0564"; -- RW, Calibration Result Registers - Channel 89
constant Q_OSACLK_89_ADDR        : std_logic_vector(15 downto 0) := X"0565"; -- RW, Calibration Result Registers - Channel 89
constant LIN_CAL_QP1_89_ADDR     : std_logic_vector(15 downto 0) := X"0566"; -- RW, Calibration Result Registers - Channel 89
constant LIN_CAL_QP2_89_ADDR     : std_logic_vector(15 downto 0) := X"0567"; -- RW, Calibration Result Registers - Channel 89

constant Q_OFS_90_ADDR           : std_logic_vector(15 downto 0) := X"0568"; -- RW, Calibration Result Registers - Channel 90
constant Q_OSACLK_90_ADDR        : std_logic_vector(15 downto 0) := X"0569"; -- RW, Calibration Result Registers - Channel 90
constant LIN_CAL_QP1_90_ADDR     : std_logic_vector(15 downto 0) := X"056a"; -- RW, Calibration Result Registers - Channel 90
constant LIN_CAL_QP2_90_ADDR     : std_logic_vector(15 downto 0) := X"056b"; -- RW, Calibration Result Registers - Channel 90

constant Q_OFS_91_ADDR           : std_logic_vector(15 downto 0) := X"056c"; -- RW, Calibration Result Registers - Channel 91
constant Q_OSACLK_91_ADDR        : std_logic_vector(15 downto 0) := X"056d"; -- RW, Calibration Result Registers - Channel 91
constant LIN_CAL_QP1_91_ADDR     : std_logic_vector(15 downto 0) := X"056e"; -- RW, Calibration Result Registers - Channel 91
constant LIN_CAL_QP2_91_ADDR     : std_logic_vector(15 downto 0) := X"056f"; -- RW, Calibration Result Registers - Channel 91

constant Q_OFS_92_ADDR           : std_logic_vector(15 downto 0) := X"0570"; -- RW, Calibration Result Registers - Channel 92
constant Q_OSACLK_92_ADDR        : std_logic_vector(15 downto 0) := X"0571"; -- RW, Calibration Result Registers - Channel 92
constant LIN_CAL_QP1_92_ADDR     : std_logic_vector(15 downto 0) := X"0572"; -- RW, Calibration Result Registers - Channel 92
constant LIN_CAL_QP2_92_ADDR     : std_logic_vector(15 downto 0) := X"0573"; -- RW, Calibration Result Registers - Channel 92

constant Q_OFS_93_ADDR           : std_logic_vector(15 downto 0) := X"0574"; -- RW, Calibration Result Registers - Channel 93
constant Q_OSACLK_93_ADDR        : std_logic_vector(15 downto 0) := X"0575"; -- RW, Calibration Result Registers - Channel 93
constant LIN_CAL_QP1_93_ADDR     : std_logic_vector(15 downto 0) := X"0576"; -- RW, Calibration Result Registers - Channel 93
constant LIN_CAL_QP2_93_ADDR     : std_logic_vector(15 downto 0) := X"0577"; -- RW, Calibration Result Registers - Channel 93

constant Q_OFS_94_ADDR           : std_logic_vector(15 downto 0) := X"0578"; -- RW, Calibration Result Registers - Channel 94
constant Q_OSACLK_94_ADDR        : std_logic_vector(15 downto 0) := X"0579"; -- RW, Calibration Result Registers - Channel 94
constant LIN_CAL_QP1_94_ADDR     : std_logic_vector(15 downto 0) := X"057a"; -- RW, Calibration Result Registers - Channel 94
constant LIN_CAL_QP2_94_ADDR     : std_logic_vector(15 downto 0) := X"057b"; -- RW, Calibration Result Registers - Channel 94

constant Q_OFS_95_ADDR           : std_logic_vector(15 downto 0) := X"057c"; -- RW, Calibration Result Registers - Channel 95
constant Q_OSACLK_95_ADDR        : std_logic_vector(15 downto 0) := X"057d"; -- RW, Calibration Result Registers - Channel 95
constant LIN_CAL_QP1_95_ADDR     : std_logic_vector(15 downto 0) := X"057e"; -- RW, Calibration Result Registers - Channel 95
constant LIN_CAL_QP2_95_ADDR     : std_logic_vector(15 downto 0) := X"057f"; -- RW, Calibration Result Registers - Channel 95

constant Q_OFS_96_ADDR           : std_logic_vector(15 downto 0) := X"0580"; -- RW, Calibration Result Registers - Channel 96
constant Q_OSACLK_96_ADDR        : std_logic_vector(15 downto 0) := X"0581"; -- RW, Calibration Result Registers - Channel 96
constant LIN_CAL_QP1_96_ADDR     : std_logic_vector(15 downto 0) := X"0582"; -- RW, Calibration Result Registers - Channel 96
constant LIN_CAL_QP2_96_ADDR     : std_logic_vector(15 downto 0) := X"0583"; -- RW, Calibration Result Registers - Channel 96

constant Q_OFS_97_ADDR           : std_logic_vector(15 downto 0) := X"0584"; -- RW, Calibration Result Registers - Channel 97
constant Q_OSACLK_97_ADDR        : std_logic_vector(15 downto 0) := X"0585"; -- RW, Calibration Result Registers - Channel 97
constant LIN_CAL_QP1_97_ADDR     : std_logic_vector(15 downto 0) := X"0586"; -- RW, Calibration Result Registers - Channel 97
constant LIN_CAL_QP2_97_ADDR     : std_logic_vector(15 downto 0) := X"0587"; -- RW, Calibration Result Registers - Channel 97

constant Q_OFS_98_ADDR           : std_logic_vector(15 downto 0) := X"0588"; -- RW, Calibration Result Registers - Channel 98
constant Q_OSACLK_98_ADDR        : std_logic_vector(15 downto 0) := X"0589"; -- RW, Calibration Result Registers - Channel 98
constant LIN_CAL_QP1_98_ADDR     : std_logic_vector(15 downto 0) := X"058a"; -- RW, Calibration Result Registers - Channel 98
constant LIN_CAL_QP2_98_ADDR     : std_logic_vector(15 downto 0) := X"058b"; -- RW, Calibration Result Registers - Channel 98

constant Q_OFS_99_ADDR           : std_logic_vector(15 downto 0) := X"058c"; -- RW, Calibration Result Registers - Channel 99
constant Q_OSACLK_99_ADDR        : std_logic_vector(15 downto 0) := X"058d"; -- RW, Calibration Result Registers - Channel 99
constant LIN_CAL_QP1_99_ADDR     : std_logic_vector(15 downto 0) := X"058e"; -- RW, Calibration Result Registers - Channel 99
constant LIN_CAL_QP2_99_ADDR     : std_logic_vector(15 downto 0) := X"058f"; -- RW, Calibration Result Registers - Channel 99

constant Q_OFS_100_ADDR         : std_logic_vector(15 downto 0) := X"0590"; -- RW, Calibration Result Registers - Channel 100
constant Q_OSACLK_100_ADDR      : std_logic_vector(15 downto 0) := X"0591"; -- RW, Calibration Result Registers - Channel 100
constant LIN_CAL_QP1_100_ADDR   : std_logic_vector(15 downto 0) := X"0592"; -- RW, Calibration Result Registers - Channel 100
constant LIN_CAL_QP2_100_ADDR   : std_logic_vector(15 downto 0) := X"0593"; -- RW, Calibration Result Registers - Channel 100

constant Q_OFS_101_ADDR         : std_logic_vector(15 downto 0) := X"0594"; -- RW, Calibration Result Registers - Channel 101
constant Q_OSACLK_101_ADDR      : std_logic_vector(15 downto 0) := X"0595"; -- RW, Calibration Result Registers - Channel 101
constant LIN_CAL_QP1_101_ADDR   : std_logic_vector(15 downto 0) := X"0596"; -- RW, Calibration Result Registers - Channel 101
constant LIN_CAL_QP2_101_ADDR   : std_logic_vector(15 downto 0) := X"0597"; -- RW, Calibration Result Registers - Channel 101

constant Q_OFS_102_ADDR         : std_logic_vector(15 downto 0) := X"0598"; -- RW, Calibration Result Registers - Channel 102
constant Q_OSACLK_102_ADDR      : std_logic_vector(15 downto 0) := X"0599"; -- RW, Calibration Result Registers - Channel 102
constant LIN_CAL_QP1_102_ADDR   : std_logic_vector(15 downto 0) := X"059a"; -- RW, Calibration Result Registers - Channel 102
constant LIN_CAL_QP2_102_ADDR   : std_logic_vector(15 downto 0) := X"059b"; -- RW, Calibration Result Registers - Channel 102

constant Q_OFS_103_ADDR         : std_logic_vector(15 downto 0) := X"059c"; -- RW, Calibration Result Registers - Channel 103
constant Q_OSACLK_103_ADDR      : std_logic_vector(15 downto 0) := X"059d"; -- RW, Calibration Result Registers - Channel 103
constant LIN_CAL_QP1_103_ADDR   : std_logic_vector(15 downto 0) := X"059e"; -- RW, Calibration Result Registers - Channel 103
constant LIN_CAL_QP2_103_ADDR   : std_logic_vector(15 downto 0) := X"059f"; -- RW, Calibration Result Registers - Channel 103

constant Q_OFS_104_ADDR         : std_logic_vector(15 downto 0) := X"05a0"; -- RW, Calibration Result Registers - Channel 104
constant Q_OSACLK_104_ADDR      : std_logic_vector(15 downto 0) := X"05a1"; -- RW, Calibration Result Registers - Channel 104
constant LIN_CAL_QP1_104_ADDR   : std_logic_vector(15 downto 0) := X"05a2"; -- RW, Calibration Result Registers - Channel 104
constant LIN_CAL_QP2_104_ADDR   : std_logic_vector(15 downto 0) := X"05a3"; -- RW, Calibration Result Registers - Channel 104

constant Q_OFS_105_ADDR         : std_logic_vector(15 downto 0) := X"05a4"; -- RW, Calibration Result Registers - Channel 105
constant Q_OSACLK_105_ADDR      : std_logic_vector(15 downto 0) := X"05a5"; -- RW, Calibration Result Registers - Channel 105
constant LIN_CAL_QP1_105_ADDR   : std_logic_vector(15 downto 0) := X"05a6"; -- RW, Calibration Result Registers - Channel 105
constant LIN_CAL_QP2_105_ADDR   : std_logic_vector(15 downto 0) := X"05a7"; -- RW, Calibration Result Registers - Channel 105

constant Q_OFS_106_ADDR         : std_logic_vector(15 downto 0) := X"05a8"; -- RW, Calibration Result Registers - Channel 106
constant Q_OSACLK_106_ADDR      : std_logic_vector(15 downto 0) := X"05a9"; -- RW, Calibration Result Registers - Channel 106
constant LIN_CAL_QP1_106_ADDR   : std_logic_vector(15 downto 0) := X"05aa"; -- RW, Calibration Result Registers - Channel 106
constant LIN_CAL_QP2_106_ADDR   : std_logic_vector(15 downto 0) := X"05ab"; -- RW, Calibration Result Registers - Channel 106

constant Q_OFS_107_ADDR         : std_logic_vector(15 downto 0) := X"05ac"; -- RW, Calibration Result Registers - Channel 107
constant Q_OSACLK_107_ADDR      : std_logic_vector(15 downto 0) := X"05ad"; -- RW, Calibration Result Registers - Channel 107
constant LIN_CAL_QP1_107_ADDR   : std_logic_vector(15 downto 0) := X"05ae"; -- RW, Calibration Result Registers - Channel 107
constant LIN_CAL_QP2_107_ADDR   : std_logic_vector(15 downto 0) := X"05af"; -- RW, Calibration Result Registers - Channel 107

constant Q_OFS_108_ADDR         : std_logic_vector(15 downto 0) := X"05b0"; -- RW, Calibration Result Registers - Channel 108
constant Q_OSACLK_108_ADDR      : std_logic_vector(15 downto 0) := X"05b1"; -- RW, Calibration Result Registers - Channel 108
constant LIN_CAL_QP1_108_ADDR   : std_logic_vector(15 downto 0) := X"05b2"; -- RW, Calibration Result Registers - Channel 108
constant LIN_CAL_QP2_108_ADDR   : std_logic_vector(15 downto 0) := X"05b3"; -- RW, Calibration Result Registers - Channel 108

constant Q_OFS_109_ADDR         : std_logic_vector(15 downto 0) := X"05b4"; -- RW, Calibration Result Registers - Channel 109
constant Q_OSACLK_109_ADDR      : std_logic_vector(15 downto 0) := X"05b5"; -- RW, Calibration Result Registers - Channel 109
constant LIN_CAL_QP1_109_ADDR   : std_logic_vector(15 downto 0) := X"05b6"; -- RW, Calibration Result Registers - Channel 109
constant LIN_CAL_QP2_109_ADDR   : std_logic_vector(15 downto 0) := X"05b7"; -- RW, Calibration Result Registers - Channel 109

constant Q_OFS_110_ADDR         : std_logic_vector(15 downto 0) := X"05b8"; -- RW, Calibration Result Registers - Channel 110
constant Q_OSACLK_110_ADDR      : std_logic_vector(15 downto 0) := X"05b9"; -- RW, Calibration Result Registers - Channel 110
constant LIN_CAL_QP1_110_ADDR   : std_logic_vector(15 downto 0) := X"05ba"; -- RW, Calibration Result Registers - Channel 110
constant LIN_CAL_QP2_110_ADDR   : std_logic_vector(15 downto 0) := X"05bb"; -- RW, Calibration Result Registers - Channel 110

constant Q_OFS_111_ADDR         : std_logic_vector(15 downto 0) := X"05bc"; -- RW, Calibration Result Registers - Channel 111
constant Q_OSACLK_111_ADDR      : std_logic_vector(15 downto 0) := X"05bd"; -- RW, Calibration Result Registers - Channel 111
constant LIN_CAL_QP1_111_ADDR   : std_logic_vector(15 downto 0) := X"05be"; -- RW, Calibration Result Registers - Channel 111
constant LIN_CAL_QP2_111_ADDR   : std_logic_vector(15 downto 0) := X"05bf"; -- RW, Calibration Result Registers - Channel 111

constant Q_OFS_112_ADDR         : std_logic_vector(15 downto 0) := X"05c0"; -- RW, Calibration Result Registers - Channel 112
constant Q_OSACLK_112_ADDR      : std_logic_vector(15 downto 0) := X"05c1"; -- RW, Calibration Result Registers - Channel 112
constant LIN_CAL_QP1_112_ADDR   : std_logic_vector(15 downto 0) := X"05c2"; -- RW, Calibration Result Registers - Channel 112
constant LIN_CAL_QP2_112_ADDR   : std_logic_vector(15 downto 0) := X"05c3"; -- RW, Calibration Result Registers - Channel 112

constant Q_OFS_113_ADDR         : std_logic_vector(15 downto 0) := X"05c4"; -- RW, Calibration Result Registers - Channel 113
constant Q_OSACLK_113_ADDR      : std_logic_vector(15 downto 0) := X"05c5"; -- RW, Calibration Result Registers - Channel 113
constant LIN_CAL_QP1_113_ADDR   : std_logic_vector(15 downto 0) := X"05c6"; -- RW, Calibration Result Registers - Channel 113
constant LIN_CAL_QP2_113_ADDR   : std_logic_vector(15 downto 0) := X"05c7"; -- RW, Calibration Result Registers - Channel 113

constant Q_OFS_114_ADDR         : std_logic_vector(15 downto 0) := X"05c8"; -- RW, Calibration Result Registers - Channel 114
constant Q_OSACLK_114_ADDR      : std_logic_vector(15 downto 0) := X"05c9"; -- RW, Calibration Result Registers - Channel 114
constant LIN_CAL_QP1_114_ADDR   : std_logic_vector(15 downto 0) := X"05ca"; -- RW, Calibration Result Registers - Channel 114
constant LIN_CAL_QP2_114_ADDR   : std_logic_vector(15 downto 0) := X"05cb"; -- RW, Calibration Result Registers - Channel 114

constant Q_OFS_115_ADDR         : std_logic_vector(15 downto 0) := X"05cc"; -- RW, Calibration Result Registers - Channel 115
constant Q_OSACLK_115_ADDR      : std_logic_vector(15 downto 0) := X"05cd"; -- RW, Calibration Result Registers - Channel 115
constant LIN_CAL_QP1_115_ADDR   : std_logic_vector(15 downto 0) := X"05ce"; -- RW, Calibration Result Registers - Channel 115
constant LIN_CAL_QP2_115_ADDR   : std_logic_vector(15 downto 0) := X"05cf"; -- RW, Calibration Result Registers - Channel 115

constant Q_OFS_116_ADDR         : std_logic_vector(15 downto 0) := X"05d0"; -- RW, Calibration Result Registers - Channel 116
constant Q_OSACLK_116_ADDR      : std_logic_vector(15 downto 0) := X"05d1"; -- RW, Calibration Result Registers - Channel 116
constant LIN_CAL_QP1_116_ADDR   : std_logic_vector(15 downto 0) := X"05d2"; -- RW, Calibration Result Registers - Channel 116
constant LIN_CAL_QP2_116_ADDR   : std_logic_vector(15 downto 0) := X"05d3"; -- RW, Calibration Result Registers - Channel 116

constant Q_OFS_117_ADDR         : std_logic_vector(15 downto 0) := X"05d4"; -- RW, Calibration Result Registers - Channel 117
constant Q_OSACLK_117_ADDR      : std_logic_vector(15 downto 0) := X"05d5"; -- RW, Calibration Result Registers - Channel 117
constant LIN_CAL_QP1_117_ADDR   : std_logic_vector(15 downto 0) := X"05d6"; -- RW, Calibration Result Registers - Channel 117
constant LIN_CAL_QP2_117_ADDR   : std_logic_vector(15 downto 0) := X"05d7"; -- RW, Calibration Result Registers - Channel 117

constant Q_OFS_118_ADDR         : std_logic_vector(15 downto 0) := X"05d8"; -- RW, Calibration Result Registers - Channel 118
constant Q_OSACLK_118_ADDR      : std_logic_vector(15 downto 0) := X"05d9"; -- RW, Calibration Result Registers - Channel 118
constant LIN_CAL_QP1_118_ADDR   : std_logic_vector(15 downto 0) := X"05da"; -- RW, Calibration Result Registers - Channel 118
constant LIN_CAL_QP2_118_ADDR   : std_logic_vector(15 downto 0) := X"05db"; -- RW, Calibration Result Registers - Channel 118

constant Q_OFS_119_ADDR         : std_logic_vector(15 downto 0) := X"05dc"; -- RW, Calibration Result Registers - Channel 119
constant Q_OSACLK_119_ADDR      : std_logic_vector(15 downto 0) := X"05dd"; -- RW, Calibration Result Registers - Channel 119
constant LIN_CAL_QP1_119_ADDR   : std_logic_vector(15 downto 0) := X"05de"; -- RW, Calibration Result Registers - Channel 119
constant LIN_CAL_QP2_119_ADDR   : std_logic_vector(15 downto 0) := X"05df"; -- RW, Calibration Result Registers - Channel 119

constant Q_OFS_120_ADDR         : std_logic_vector(15 downto 0) := X"05e0"; -- RW, Calibration Result Registers - Channel 120
constant Q_OSACLK_120_ADDR      : std_logic_vector(15 downto 0) := X"05e1"; -- RW, Calibration Result Registers - Channel 120
constant LIN_CAL_QP1_120_ADDR   : std_logic_vector(15 downto 0) := X"05e2"; -- RW, Calibration Result Registers - Channel 120
constant LIN_CAL_QP2_120_ADDR   : std_logic_vector(15 downto 0) := X"05e3"; -- RW, Calibration Result Registers - Channel 120

constant Q_OFS_121_ADDR         : std_logic_vector(15 downto 0) := X"05e4"; -- RW, Calibration Result Registers - Channel 121
constant Q_OSACLK_121_ADDR      : std_logic_vector(15 downto 0) := X"05e5"; -- RW, Calibration Result Registers - Channel 121
constant LIN_CAL_QP1_121_ADDR   : std_logic_vector(15 downto 0) := X"05e6"; -- RW, Calibration Result Registers - Channel 121
constant LIN_CAL_QP2_121_ADDR   : std_logic_vector(15 downto 0) := X"05e7"; -- RW, Calibration Result Registers - Channel 121

constant Q_OFS_122_ADDR         : std_logic_vector(15 downto 0) := X"05e8"; -- RW, Calibration Result Registers - Channel 122
constant Q_OSACLK_122_ADDR      : std_logic_vector(15 downto 0) := X"05e9"; -- RW, Calibration Result Registers - Channel 122
constant LIN_CAL_QP1_122_ADDR   : std_logic_vector(15 downto 0) := X"05ea"; -- RW, Calibration Result Registers - Channel 122
constant LIN_CAL_QP2_122_ADDR   : std_logic_vector(15 downto 0) := X"05eb"; -- RW, Calibration Result Registers - Channel 122

constant Q_OFS_123_ADDR         : std_logic_vector(15 downto 0) := X"05ec"; -- RW, Calibration Result Registers - Channel 123
constant Q_OSACLK_123_ADDR      : std_logic_vector(15 downto 0) := X"05ed"; -- RW, Calibration Result Registers - Channel 123
constant LIN_CAL_QP1_123_ADDR   : std_logic_vector(15 downto 0) := X"05ee"; -- RW, Calibration Result Registers - Channel 123
constant LIN_CAL_QP2_123_ADDR   : std_logic_vector(15 downto 0) := X"05ef"; -- RW, Calibration Result Registers - Channel 123

constant Q_OFS_124_ADDR         : std_logic_vector(15 downto 0) := X"05f0"; -- RW, Calibration Result Registers - Channel 124
constant Q_OSACLK_124_ADDR      : std_logic_vector(15 downto 0) := X"05f1"; -- RW, Calibration Result Registers - Channel 124
constant LIN_CAL_QP1_124_ADDR   : std_logic_vector(15 downto 0) := X"05f2"; -- RW, Calibration Result Registers - Channel 124
constant LIN_CAL_QP2_124_ADDR   : std_logic_vector(15 downto 0) := X"05f3"; -- RW, Calibration Result Registers - Channel 124

constant Q_OFS_125_ADDR         : std_logic_vector(15 downto 0) := X"05f4"; -- RW, Calibration Result Registers - Channel 125
constant Q_OSACLK_125_ADDR      : std_logic_vector(15 downto 0) := X"05f5"; -- RW, Calibration Result Registers - Channel 125
constant LIN_CAL_QP1_125_ADDR   : std_logic_vector(15 downto 0) := X"05f6"; -- RW, Calibration Result Registers - Channel 125
constant LIN_CAL_QP2_125_ADDR   : std_logic_vector(15 downto 0) := X"05f7"; -- RW, Calibration Result Registers - Channel 125

constant Q_OFS_126_ADDR         : std_logic_vector(15 downto 0) := X"05f8"; -- RW, Calibration Result Registers - Channel 126
constant Q_OSACLK_126_ADDR      : std_logic_vector(15 downto 0) := X"05f9"; -- RW, Calibration Result Registers - Channel 126
constant LIN_CAL_QP1_126_ADDR   : std_logic_vector(15 downto 0) := X"05fa"; -- RW, Calibration Result Registers - Channel 126
constant LIN_CAL_QP2_126_ADDR   : std_logic_vector(15 downto 0) := X"05fb"; -- RW, Calibration Result Registers - Channel 126

constant Q_OFS_127_ADDR         : std_logic_vector(15 downto 0) := X"05fc"; -- RW, Calibration Result Registers - Channel 127
constant Q_OSACLK_127_ADDR      : std_logic_vector(15 downto 0) := X"05fd"; -- RW, Calibration Result Registers - Channel 127
constant LIN_CAL_QP1_127_ADDR   : std_logic_vector(15 downto 0) := X"05fe"; -- RW, Calibration Result Registers - Channel 127
constant LIN_CAL_QP2_127_ADDR   : std_logic_vector(15 downto 0) := X"05ff"; -- RW, Calibration Result Registers - Channel 127

constant Q_OFS_128_ADDR         : std_logic_vector(15 downto 0) := X"0600"; -- RW, Calibration Result Registers - Channel 128
constant Q_OSACLK_128_ADDR      : std_logic_vector(15 downto 0) := X"0601"; -- RW, Calibration Result Registers - Channel 128
constant LIN_CAL_QP1_128_ADDR   : std_logic_vector(15 downto 0) := X"0602"; -- RW, Calibration Result Registers - Channel 128
constant LIN_CAL_QP2_128_ADDR   : std_logic_vector(15 downto 0) := X"0603"; -- RW, Calibration Result Registers - Channel 128

constant Q_OFS_129_ADDR         : std_logic_vector(15 downto 0) := X"0604"; -- RW, Calibration Result Registers - Channel 129
constant Q_OSACLK_129_ADDR      : std_logic_vector(15 downto 0) := X"0605"; -- RW, Calibration Result Registers - Channel 129
constant LIN_CAL_QP1_129_ADDR   : std_logic_vector(15 downto 0) := X"0606"; -- RW, Calibration Result Registers - Channel 129
constant LIN_CAL_QP2_129_ADDR   : std_logic_vector(15 downto 0) := X"0607"; -- RW, Calibration Result Registers - Channel 129

constant Q_OFS_130_ADDR         : std_logic_vector(15 downto 0) := X"0608"; -- RW, Calibration Result Registers - Channel 130
constant Q_OSACLK_130_ADDR      : std_logic_vector(15 downto 0) := X"0609"; -- RW, Calibration Result Registers - Channel 130
constant LIN_CAL_QP1_130_ADDR   : std_logic_vector(15 downto 0) := X"060a"; -- RW, Calibration Result Registers - Channel 130
constant LIN_CAL_QP2_130_ADDR   : std_logic_vector(15 downto 0) := X"060b"; -- RW, Calibration Result Registers - Channel 130

constant Q_OFS_131_ADDR         : std_logic_vector(15 downto 0) := X"060c"; -- RW, Calibration Result Registers - Channel 131
constant Q_OSACLK_131_ADDR      : std_logic_vector(15 downto 0) := X"060d"; -- RW, Calibration Result Registers - Channel 131
constant LIN_CAL_QP1_131_ADDR   : std_logic_vector(15 downto 0) := X"060e"; -- RW, Calibration Result Registers - Channel 131
constant LIN_CAL_QP2_131_ADDR   : std_logic_vector(15 downto 0) := X"060f"; -- RW, Calibration Result Registers - Channel 131

constant Q_OFS_132_ADDR         : std_logic_vector(15 downto 0) := X"0610"; -- RW, Calibration Result Registers - Channel 132
constant Q_OSACLK_132_ADDR      : std_logic_vector(15 downto 0) := X"0611"; -- RW, Calibration Result Registers - Channel 132
constant LIN_CAL_QP1_132_ADDR   : std_logic_vector(15 downto 0) := X"0612"; -- RW, Calibration Result Registers - Channel 132
constant LIN_CAL_QP2_132_ADDR   : std_logic_vector(15 downto 0) := X"0613"; -- RW, Calibration Result Registers - Channel 132

constant Q_OFS_133_ADDR         : std_logic_vector(15 downto 0) := X"0614"; -- RW, Calibration Result Registers - Channel 133
constant Q_OSACLK_133_ADDR      : std_logic_vector(15 downto 0) := X"0615"; -- RW, Calibration Result Registers - Channel 133
constant LIN_CAL_QP1_133_ADDR   : std_logic_vector(15 downto 0) := X"0616"; -- RW, Calibration Result Registers - Channel 133
constant LIN_CAL_QP2_133_ADDR   : std_logic_vector(15 downto 0) := X"0617"; -- RW, Calibration Result Registers - Channel 133

constant Q_OFS_134_ADDR         : std_logic_vector(15 downto 0) := X"0618"; -- RW, Calibration Result Registers - Channel 134
constant Q_OSACLK_134_ADDR      : std_logic_vector(15 downto 0) := X"0619"; -- RW, Calibration Result Registers - Channel 134
constant LIN_CAL_QP1_134_ADDR   : std_logic_vector(15 downto 0) := X"061a"; -- RW, Calibration Result Registers - Channel 134
constant LIN_CAL_QP2_134_ADDR   : std_logic_vector(15 downto 0) := X"061b"; -- RW, Calibration Result Registers - Channel 134

constant Q_OFS_135_ADDR         : std_logic_vector(15 downto 0) := X"061c"; -- RW, Calibration Result Registers - Channel 135
constant Q_OSACLK_135_ADDR      : std_logic_vector(15 downto 0) := X"061d"; -- RW, Calibration Result Registers - Channel 135
constant LIN_CAL_QP1_135_ADDR   : std_logic_vector(15 downto 0) := X"061e"; -- RW, Calibration Result Registers - Channel 135
constant LIN_CAL_QP2_135_ADDR   : std_logic_vector(15 downto 0) := X"061f"; -- RW, Calibration Result Registers - Channel 135

constant Q_OFS_136_ADDR         : std_logic_vector(15 downto 0) := X"0620"; -- RW, Calibration Result Registers - Channel 136
constant Q_OSACLK_136_ADDR      : std_logic_vector(15 downto 0) := X"0621"; -- RW, Calibration Result Registers - Channel 136
constant LIN_CAL_QP1_136_ADDR   : std_logic_vector(15 downto 0) := X"0622"; -- RW, Calibration Result Registers - Channel 136
constant LIN_CAL_QP2_136_ADDR   : std_logic_vector(15 downto 0) := X"0623"; -- RW, Calibration Result Registers - Channel 136

constant Q_OFS_137_ADDR         : std_logic_vector(15 downto 0) := X"0624"; -- RW, Calibration Result Registers - Channel 137
constant Q_OSACLK_137_ADDR      : std_logic_vector(15 downto 0) := X"0625"; -- RW, Calibration Result Registers - Channel 137
constant LIN_CAL_QP1_137_ADDR   : std_logic_vector(15 downto 0) := X"0626"; -- RW, Calibration Result Registers - Channel 137
constant LIN_CAL_QP2_137_ADDR   : std_logic_vector(15 downto 0) := X"0627"; -- RW, Calibration Result Registers - Channel 137

constant Q_OFS_138_ADDR         : std_logic_vector(15 downto 0) := X"0628"; -- RW, Calibration Result Registers - Channel 138
constant Q_OSACLK_138_ADDR      : std_logic_vector(15 downto 0) := X"0629"; -- RW, Calibration Result Registers - Channel 138
constant LIN_CAL_QP1_138_ADDR   : std_logic_vector(15 downto 0) := X"062a"; -- RW, Calibration Result Registers - Channel 138
constant LIN_CAL_QP2_138_ADDR   : std_logic_vector(15 downto 0) := X"062b"; -- RW, Calibration Result Registers - Channel 138

constant Q_OFS_139_ADDR         : std_logic_vector(15 downto 0) := X"062c"; -- RW, Calibration Result Registers - Channel 139
constant Q_OSACLK_139_ADDR      : std_logic_vector(15 downto 0) := X"062d"; -- RW, Calibration Result Registers - Channel 139
constant LIN_CAL_QP1_139_ADDR   : std_logic_vector(15 downto 0) := X"062e"; -- RW, Calibration Result Registers - Channel 139
constant LIN_CAL_QP2_139_ADDR   : std_logic_vector(15 downto 0) := X"062f"; -- RW, Calibration Result Registers - Channel 139

constant Q_OFS_140_ADDR         : std_logic_vector(15 downto 0) := X"0630"; -- RW, Calibration Result Registers - Channel 140
constant Q_OSACLK_140_ADDR      : std_logic_vector(15 downto 0) := X"0631"; -- RW, Calibration Result Registers - Channel 140
constant LIN_CAL_QP1_140_ADDR   : std_logic_vector(15 downto 0) := X"0632"; -- RW, Calibration Result Registers - Channel 140
constant LIN_CAL_QP2_140_ADDR   : std_logic_vector(15 downto 0) := X"0633"; -- RW, Calibration Result Registers - Channel 140

constant Q_OFS_141_ADDR         : std_logic_vector(15 downto 0) := X"0634"; -- RW, Calibration Result Registers - Channel 141
constant Q_OSACLK_141_ADDR      : std_logic_vector(15 downto 0) := X"0635"; -- RW, Calibration Result Registers - Channel 141
constant LIN_CAL_QP1_141_ADDR   : std_logic_vector(15 downto 0) := X"0636"; -- RW, Calibration Result Registers - Channel 141
constant LIN_CAL_QP2_141_ADDR   : std_logic_vector(15 downto 0) := X"0637"; -- RW, Calibration Result Registers - Channel 141

constant Q_OFS_142_ADDR         : std_logic_vector(15 downto 0) := X"0638"; -- RW, Calibration Result Registers - Channel 142
constant Q_OSACLK_142_ADDR      : std_logic_vector(15 downto 0) := X"0639"; -- RW, Calibration Result Registers - Channel 142
constant LIN_CAL_QP1_142_ADDR   : std_logic_vector(15 downto 0) := X"063a"; -- RW, Calibration Result Registers - Channel 142
constant LIN_CAL_QP2_142_ADDR   : std_logic_vector(15 downto 0) := X"063b"; -- RW, Calibration Result Registers - Channel 142

constant Q_OFS_143_ADDR         : std_logic_vector(15 downto 0) := X"063c"; -- RW, Calibration Result Registers - Channel 143
constant Q_OSACLK_143_ADDR      : std_logic_vector(15 downto 0) := X"063d"; -- RW, Calibration Result Registers - Channel 143
constant LIN_CAL_QP1_143_ADDR   : std_logic_vector(15 downto 0) := X"063e"; -- RW, Calibration Result Registers - Channel 143
constant LIN_CAL_QP2_143_ADDR   : std_logic_vector(15 downto 0) := X"063f"; -- RW, Calibration Result Registers - Channel 143

constant Q_OFS_144_ADDR         : std_logic_vector(15 downto 0) := X"0640"; -- RW, Calibration Result Registers - Channel 144
constant Q_OSACLK_144_ADDR      : std_logic_vector(15 downto 0) := X"0641"; -- RW, Calibration Result Registers - Channel 144
constant LIN_CAL_QP1_144_ADDR   : std_logic_vector(15 downto 0) := X"0642"; -- RW, Calibration Result Registers - Channel 144
constant LIN_CAL_QP2_144_ADDR   : std_logic_vector(15 downto 0) := X"0643"; -- RW, Calibration Result Registers - Channel 144

constant Q_OFS_145_ADDR         : std_logic_vector(15 downto 0) := X"0644"; -- RW, Calibration Result Registers - Channel 145
constant Q_OSACLK_145_ADDR      : std_logic_vector(15 downto 0) := X"0645"; -- RW, Calibration Result Registers - Channel 145
constant LIN_CAL_QP1_145_ADDR   : std_logic_vector(15 downto 0) := X"0646"; -- RW, Calibration Result Registers - Channel 145
constant LIN_CAL_QP2_145_ADDR   : std_logic_vector(15 downto 0) := X"0647"; -- RW, Calibration Result Registers - Channel 145

constant Q_OFS_146_ADDR         : std_logic_vector(15 downto 0) := X"0648"; -- RW, Calibration Result Registers - Channel 146
constant Q_OSACLK_146_ADDR      : std_logic_vector(15 downto 0) := X"0649"; -- RW, Calibration Result Registers - Channel 146
constant LIN_CAL_QP1_146_ADDR   : std_logic_vector(15 downto 0) := X"064a"; -- RW, Calibration Result Registers - Channel 146
constant LIN_CAL_QP2_146_ADDR   : std_logic_vector(15 downto 0) := X"064b"; -- RW, Calibration Result Registers - Channel 146

constant Q_OFS_147_ADDR         : std_logic_vector(15 downto 0) := X"064c"; -- RW, Calibration Result Registers - Channel 147
constant Q_OSACLK_147_ADDR      : std_logic_vector(15 downto 0) := X"064d"; -- RW, Calibration Result Registers - Channel 147
constant LIN_CAL_QP1_147_ADDR   : std_logic_vector(15 downto 0) := X"064e"; -- RW, Calibration Result Registers - Channel 147
constant LIN_CAL_QP2_147_ADDR   : std_logic_vector(15 downto 0) := X"064f"; -- RW, Calibration Result Registers - Channel 147

constant Q_OFS_148_ADDR         : std_logic_vector(15 downto 0) := X"0650"; -- RW, Calibration Result Registers - Channel 148
constant Q_OSACLK_148_ADDR      : std_logic_vector(15 downto 0) := X"0651"; -- RW, Calibration Result Registers - Channel 148
constant LIN_CAL_QP1_148_ADDR   : std_logic_vector(15 downto 0) := X"0652"; -- RW, Calibration Result Registers - Channel 148
constant LIN_CAL_QP2_148_ADDR   : std_logic_vector(15 downto 0) := X"0653"; -- RW, Calibration Result Registers - Channel 148

constant Q_OFS_149_ADDR         : std_logic_vector(15 downto 0) := X"0654"; -- RW, Calibration Result Registers - Channel 149
constant Q_OSACLK_149_ADDR      : std_logic_vector(15 downto 0) := X"0655"; -- RW, Calibration Result Registers - Channel 149
constant LIN_CAL_QP1_149_ADDR   : std_logic_vector(15 downto 0) := X"0656"; -- RW, Calibration Result Registers - Channel 149
constant LIN_CAL_QP2_149_ADDR   : std_logic_vector(15 downto 0) := X"0657"; -- RW, Calibration Result Registers - Channel 149

constant Q_OFS_150_ADDR         : std_logic_vector(15 downto 0) := X"0658"; -- RW, Calibration Result Registers - Channel 150
constant Q_OSACLK_150_ADDR      : std_logic_vector(15 downto 0) := X"0659"; -- RW, Calibration Result Registers - Channel 150
constant LIN_CAL_QP1_150_ADDR   : std_logic_vector(15 downto 0) := X"065a"; -- RW, Calibration Result Registers - Channel 150
constant LIN_CAL_QP2_150_ADDR   : std_logic_vector(15 downto 0) := X"065b"; -- RW, Calibration Result Registers - Channel 150

constant Q_OFS_151_ADDR         : std_logic_vector(15 downto 0) := X"065c"; -- RW, Calibration Result Registers - Channel 151
constant Q_OSACLK_151_ADDR      : std_logic_vector(15 downto 0) := X"065d"; -- RW, Calibration Result Registers - Channel 151
constant LIN_CAL_QP1_151_ADDR   : std_logic_vector(15 downto 0) := X"065e"; -- RW, Calibration Result Registers - Channel 151
constant LIN_CAL_QP2_151_ADDR   : std_logic_vector(15 downto 0) := X"065f"; -- RW, Calibration Result Registers - Channel 151

constant Q_OFS_152_ADDR         : std_logic_vector(15 downto 0) := X"0660"; -- RW, Calibration Result Registers - Channel 152
constant Q_OSACLK_152_ADDR      : std_logic_vector(15 downto 0) := X"0661"; -- RW, Calibration Result Registers - Channel 152
constant LIN_CAL_QP1_152_ADDR   : std_logic_vector(15 downto 0) := X"0662"; -- RW, Calibration Result Registers - Channel 152
constant LIN_CAL_QP2_152_ADDR   : std_logic_vector(15 downto 0) := X"0663"; -- RW, Calibration Result Registers - Channel 152

constant Q_OFS_153_ADDR         : std_logic_vector(15 downto 0) := X"0664"; -- RW, Calibration Result Registers - Channel 153
constant Q_OSACLK_153_ADDR      : std_logic_vector(15 downto 0) := X"0665"; -- RW, Calibration Result Registers - Channel 153
constant LIN_CAL_QP1_153_ADDR   : std_logic_vector(15 downto 0) := X"0666"; -- RW, Calibration Result Registers - Channel 153
constant LIN_CAL_QP2_153_ADDR   : std_logic_vector(15 downto 0) := X"0667"; -- RW, Calibration Result Registers - Channel 153

constant Q_OFS_154_ADDR         : std_logic_vector(15 downto 0) := X"0668"; -- RW, Calibration Result Registers - Channel 154
constant Q_OSACLK_154_ADDR      : std_logic_vector(15 downto 0) := X"0669"; -- RW, Calibration Result Registers - Channel 154
constant LIN_CAL_QP1_154_ADDR   : std_logic_vector(15 downto 0) := X"066a"; -- RW, Calibration Result Registers - Channel 154
constant LIN_CAL_QP2_154_ADDR   : std_logic_vector(15 downto 0) := X"066b"; -- RW, Calibration Result Registers - Channel 154

constant Q_OFS_155_ADDR         : std_logic_vector(15 downto 0) := X"066c"; -- RW, Calibration Result Registers - Channel 155
constant Q_OSACLK_155_ADDR      : std_logic_vector(15 downto 0) := X"066d"; -- RW, Calibration Result Registers - Channel 155
constant LIN_CAL_QP1_155_ADDR   : std_logic_vector(15 downto 0) := X"066e"; -- RW, Calibration Result Registers - Channel 155
constant LIN_CAL_QP2_155_ADDR   : std_logic_vector(15 downto 0) := X"066f"; -- RW, Calibration Result Registers - Channel 155

constant Q_OFS_156_ADDR         : std_logic_vector(15 downto 0) := X"0670"; -- RW, Calibration Result Registers - Channel 156
constant Q_OSACLK_156_ADDR      : std_logic_vector(15 downto 0) := X"0671"; -- RW, Calibration Result Registers - Channel 156
constant LIN_CAL_QP1_156_ADDR   : std_logic_vector(15 downto 0) := X"0672"; -- RW, Calibration Result Registers - Channel 156
constant LIN_CAL_QP2_156_ADDR   : std_logic_vector(15 downto 0) := X"0673"; -- RW, Calibration Result Registers - Channel 156

constant Q_OFS_157_ADDR         : std_logic_vector(15 downto 0) := X"0674"; -- RW, Calibration Result Registers - Channel 157
constant Q_OSACLK_157_ADDR      : std_logic_vector(15 downto 0) := X"0675"; -- RW, Calibration Result Registers - Channel 157
constant LIN_CAL_QP1_157_ADDR   : std_logic_vector(15 downto 0) := X"0676"; -- RW, Calibration Result Registers - Channel 157
constant LIN_CAL_QP2_157_ADDR   : std_logic_vector(15 downto 0) := X"0677"; -- RW, Calibration Result Registers - Channel 157

constant Q_OFS_158_ADDR         : std_logic_vector(15 downto 0) := X"0678"; -- RW, Calibration Result Registers - Channel 158
constant Q_OSACLK_158_ADDR      : std_logic_vector(15 downto 0) := X"0679"; -- RW, Calibration Result Registers - Channel 158
constant LIN_CAL_QP1_158_ADDR   : std_logic_vector(15 downto 0) := X"067a"; -- RW, Calibration Result Registers - Channel 158
constant LIN_CAL_QP2_158_ADDR   : std_logic_vector(15 downto 0) := X"067b"; -- RW, Calibration Result Registers - Channel 158

constant Q_OFS_159_ADDR         : std_logic_vector(15 downto 0) := X"067c"; -- RW, Calibration Result Registers - Channel 159
constant Q_OSACLK_159_ADDR      : std_logic_vector(15 downto 0) := X"067d"; -- RW, Calibration Result Registers - Channel 159
constant LIN_CAL_QP1_159_ADDR   : std_logic_vector(15 downto 0) := X"067e"; -- RW, Calibration Result Registers - Channel 159
constant LIN_CAL_QP2_159_ADDR   : std_logic_vector(15 downto 0) := X"067f"; -- RW, Calibration Result Registers - Channel 159

constant Q_OFS_160_ADDR         : std_logic_vector(15 downto 0) := X"0680"; -- RW, Calibration Result Registers - Channel 160
constant Q_OSACLK_160_ADDR      : std_logic_vector(15 downto 0) := X"0681"; -- RW, Calibration Result Registers - Channel 160
constant LIN_CAL_QP1_160_ADDR   : std_logic_vector(15 downto 0) := X"0682"; -- RW, Calibration Result Registers - Channel 160
constant LIN_CAL_QP2_160_ADDR   : std_logic_vector(15 downto 0) := X"0683"; -- RW, Calibration Result Registers - Channel 160

constant Q_OFS_161_ADDR         : std_logic_vector(15 downto 0) := X"0684"; -- RW, Calibration Result Registers - Channel 161
constant Q_OSACLK_161_ADDR      : std_logic_vector(15 downto 0) := X"0685"; -- RW, Calibration Result Registers - Channel 161
constant LIN_CAL_QP1_161_ADDR   : std_logic_vector(15 downto 0) := X"0686"; -- RW, Calibration Result Registers - Channel 161
constant LIN_CAL_QP2_161_ADDR   : std_logic_vector(15 downto 0) := X"0687"; -- RW, Calibration Result Registers - Channel 161

constant Q_OFS_162_ADDR         : std_logic_vector(15 downto 0) := X"0688"; -- RW, Calibration Result Registers - Channel 162
constant Q_OSACLK_162_ADDR      : std_logic_vector(15 downto 0) := X"0689"; -- RW, Calibration Result Registers - Channel 162
constant LIN_CAL_QP1_162_ADDR   : std_logic_vector(15 downto 0) := X"068a"; -- RW, Calibration Result Registers - Channel 162
constant LIN_CAL_QP2_162_ADDR   : std_logic_vector(15 downto 0) := X"068b"; -- RW, Calibration Result Registers - Channel 162

constant Q_OFS_163_ADDR         : std_logic_vector(15 downto 0) := X"068c"; -- RW, Calibration Result Registers - Channel 163
constant Q_OSACLK_163_ADDR      : std_logic_vector(15 downto 0) := X"068d"; -- RW, Calibration Result Registers - Channel 163
constant LIN_CAL_QP1_163_ADDR   : std_logic_vector(15 downto 0) := X"068e"; -- RW, Calibration Result Registers - Channel 163
constant LIN_CAL_QP2_163_ADDR   : std_logic_vector(15 downto 0) := X"068f"; -- RW, Calibration Result Registers - Channel 163

constant Q_OFS_164_ADDR         : std_logic_vector(15 downto 0) := X"0690"; -- RW, Calibration Result Registers - Channel 164
constant Q_OSACLK_164_ADDR      : std_logic_vector(15 downto 0) := X"0691"; -- RW, Calibration Result Registers - Channel 164
constant LIN_CAL_QP1_164_ADDR   : std_logic_vector(15 downto 0) := X"0692"; -- RW, Calibration Result Registers - Channel 164
constant LIN_CAL_QP2_164_ADDR   : std_logic_vector(15 downto 0) := X"0693"; -- RW, Calibration Result Registers - Channel 164

constant Q_OFS_165_ADDR         : std_logic_vector(15 downto 0) := X"0694"; -- RW, Calibration Result Registers - Channel 165
constant Q_OSACLK_165_ADDR      : std_logic_vector(15 downto 0) := X"0695"; -- RW, Calibration Result Registers - Channel 165
constant LIN_CAL_QP1_165_ADDR   : std_logic_vector(15 downto 0) := X"0696"; -- RW, Calibration Result Registers - Channel 165
constant LIN_CAL_QP2_165_ADDR   : std_logic_vector(15 downto 0) := X"0697"; -- RW, Calibration Result Registers - Channel 165

constant Q_OFS_166_ADDR         : std_logic_vector(15 downto 0) := X"0698"; -- RW, Calibration Result Registers - Channel 166
constant Q_OSACLK_166_ADDR      : std_logic_vector(15 downto 0) := X"0699"; -- RW, Calibration Result Registers - Channel 166
constant LIN_CAL_QP1_166_ADDR   : std_logic_vector(15 downto 0) := X"069a"; -- RW, Calibration Result Registers - Channel 166
constant LIN_CAL_QP2_166_ADDR   : std_logic_vector(15 downto 0) := X"069b"; -- RW, Calibration Result Registers - Channel 166

constant Q_OFS_167_ADDR         : std_logic_vector(15 downto 0) := X"069c"; -- RW, Calibration Result Registers - Channel 167
constant Q_OSACLK_167_ADDR      : std_logic_vector(15 downto 0) := X"069d"; -- RW, Calibration Result Registers - Channel 167
constant LIN_CAL_QP1_167_ADDR   : std_logic_vector(15 downto 0) := X"069e"; -- RW, Calibration Result Registers - Channel 167
constant LIN_CAL_QP2_167_ADDR   : std_logic_vector(15 downto 0) := X"069f"; -- RW, Calibration Result Registers - Channel 167

constant Q_OFS_168_ADDR         : std_logic_vector(15 downto 0) := X"06a0"; -- RW, Calibration Result Registers - Channel 168
constant Q_OSACLK_168_ADDR      : std_logic_vector(15 downto 0) := X"06a1"; -- RW, Calibration Result Registers - Channel 168
constant LIN_CAL_QP1_168_ADDR   : std_logic_vector(15 downto 0) := X"06a2"; -- RW, Calibration Result Registers - Channel 168
constant LIN_CAL_QP2_168_ADDR   : std_logic_vector(15 downto 0) := X"06a3"; -- RW, Calibration Result Registers - Channel 168

constant Q_OFS_169_ADDR         : std_logic_vector(15 downto 0) := X"06a4"; -- RW, Calibration Result Registers - Channel 169
constant Q_OSACLK_169_ADDR      : std_logic_vector(15 downto 0) := X"06a5"; -- RW, Calibration Result Registers - Channel 169
constant LIN_CAL_QP1_169_ADDR   : std_logic_vector(15 downto 0) := X"06a6"; -- RW, Calibration Result Registers - Channel 169
constant LIN_CAL_QP2_169_ADDR   : std_logic_vector(15 downto 0) := X"06a7"; -- RW, Calibration Result Registers - Channel 169

constant Q_OFS_170_ADDR         : std_logic_vector(15 downto 0) := X"06a8"; -- RW, Calibration Result Registers - Channel 170
constant Q_OSACLK_170_ADDR      : std_logic_vector(15 downto 0) := X"06a9"; -- RW, Calibration Result Registers - Channel 170
constant LIN_CAL_QP1_170_ADDR   : std_logic_vector(15 downto 0) := X"06aa"; -- RW, Calibration Result Registers - Channel 170
constant LIN_CAL_QP2_170_ADDR   : std_logic_vector(15 downto 0) := X"06ab"; -- RW, Calibration Result Registers - Channel 170

constant Q_OFS_171_ADDR         : std_logic_vector(15 downto 0) := X"06ac"; -- RW, Calibration Result Registers - Channel 171
constant Q_OSACLK_171_ADDR      : std_logic_vector(15 downto 0) := X"06ad"; -- RW, Calibration Result Registers - Channel 171
constant LIN_CAL_QP1_171_ADDR   : std_logic_vector(15 downto 0) := X"06ae"; -- RW, Calibration Result Registers - Channel 171
constant LIN_CAL_QP2_171_ADDR   : std_logic_vector(15 downto 0) := X"06af"; -- RW, Calibration Result Registers - Channel 171

constant Q_OFS_172_ADDR         : std_logic_vector(15 downto 0) := X"06b0"; -- RW, Calibration Result Registers - Channel 172
constant Q_OSACLK_172_ADDR      : std_logic_vector(15 downto 0) := X"06b1"; -- RW, Calibration Result Registers - Channel 172
constant LIN_CAL_QP1_172_ADDR   : std_logic_vector(15 downto 0) := X"06b2"; -- RW, Calibration Result Registers - Channel 172
constant LIN_CAL_QP2_172_ADDR   : std_logic_vector(15 downto 0) := X"06b3"; -- RW, Calibration Result Registers - Channel 172

constant Q_OFS_173_ADDR         : std_logic_vector(15 downto 0) := X"06b4"; -- RW, Calibration Result Registers - Channel 173
constant Q_OSACLK_173_ADDR      : std_logic_vector(15 downto 0) := X"06b5"; -- RW, Calibration Result Registers - Channel 173
constant LIN_CAL_QP1_173_ADDR   : std_logic_vector(15 downto 0) := X"06b6"; -- RW, Calibration Result Registers - Channel 173
constant LIN_CAL_QP2_173_ADDR   : std_logic_vector(15 downto 0) := X"06b7"; -- RW, Calibration Result Registers - Channel 173

constant Q_OFS_174_ADDR         : std_logic_vector(15 downto 0) := X"06b8"; -- RW, Calibration Result Registers - Channel 174
constant Q_OSACLK_174_ADDR      : std_logic_vector(15 downto 0) := X"06b9"; -- RW, Calibration Result Registers - Channel 174
constant LIN_CAL_QP1_174_ADDR   : std_logic_vector(15 downto 0) := X"06ba"; -- RW, Calibration Result Registers - Channel 174
constant LIN_CAL_QP2_174_ADDR   : std_logic_vector(15 downto 0) := X"06bb"; -- RW, Calibration Result Registers - Channel 174

constant Q_OFS_175_ADDR         : std_logic_vector(15 downto 0) := X"06bc"; -- RW, Calibration Result Registers - Channel 175
constant Q_OSACLK_175_ADDR      : std_logic_vector(15 downto 0) := X"06bd"; -- RW, Calibration Result Registers - Channel 175
constant LIN_CAL_QP1_175_ADDR   : std_logic_vector(15 downto 0) := X"06be"; -- RW, Calibration Result Registers - Channel 175
constant LIN_CAL_QP2_175_ADDR   : std_logic_vector(15 downto 0) := X"06bf"; -- RW, Calibration Result Registers - Channel 175

constant Q_OFS_176_ADDR         : std_logic_vector(15 downto 0) := X"06c0"; -- RW, Calibration Result Registers - Channel 176
constant Q_OSACLK_176_ADDR      : std_logic_vector(15 downto 0) := X"06c1"; -- RW, Calibration Result Registers - Channel 176
constant LIN_CAL_QP1_176_ADDR   : std_logic_vector(15 downto 0) := X"06c2"; -- RW, Calibration Result Registers - Channel 176
constant LIN_CAL_QP2_176_ADDR   : std_logic_vector(15 downto 0) := X"06c3"; -- RW, Calibration Result Registers - Channel 176

constant Q_OFS_177_ADDR         : std_logic_vector(15 downto 0) := X"06c4"; -- RW, Calibration Result Registers - Channel 177
constant Q_OSACLK_177_ADDR      : std_logic_vector(15 downto 0) := X"06c5"; -- RW, Calibration Result Registers - Channel 177
constant LIN_CAL_QP1_177_ADDR   : std_logic_vector(15 downto 0) := X"06c6"; -- RW, Calibration Result Registers - Channel 177
constant LIN_CAL_QP2_177_ADDR   : std_logic_vector(15 downto 0) := X"06c7"; -- RW, Calibration Result Registers - Channel 177

constant Q_OFS_178_ADDR         : std_logic_vector(15 downto 0) := X"06c8"; -- RW, Calibration Result Registers - Channel 178
constant Q_OSACLK_178_ADDR      : std_logic_vector(15 downto 0) := X"06c9"; -- RW, Calibration Result Registers - Channel 178
constant LIN_CAL_QP1_178_ADDR   : std_logic_vector(15 downto 0) := X"06ca"; -- RW, Calibration Result Registers - Channel 178
constant LIN_CAL_QP2_178_ADDR   : std_logic_vector(15 downto 0) := X"06cb"; -- RW, Calibration Result Registers - Channel 178

constant Q_OFS_179_ADDR         : std_logic_vector(15 downto 0) := X"06cc"; -- RW, Calibration Result Registers - Channel 179
constant Q_OSACLK_179_ADDR      : std_logic_vector(15 downto 0) := X"06cd"; -- RW, Calibration Result Registers - Channel 179
constant LIN_CAL_QP1_179_ADDR   : std_logic_vector(15 downto 0) := X"06ce"; -- RW, Calibration Result Registers - Channel 179
constant LIN_CAL_QP2_179_ADDR   : std_logic_vector(15 downto 0) := X"06cf"; -- RW, Calibration Result Registers - Channel 179

constant Q_OFS_180_ADDR         : std_logic_vector(15 downto 0) := X"06d0"; -- RW, Calibration Result Registers - Channel 180
constant Q_OSACLK_180_ADDR      : std_logic_vector(15 downto 0) := X"06d1"; -- RW, Calibration Result Registers - Channel 180
constant LIN_CAL_QP1_180_ADDR   : std_logic_vector(15 downto 0) := X"06d2"; -- RW, Calibration Result Registers - Channel 180
constant LIN_CAL_QP2_180_ADDR   : std_logic_vector(15 downto 0) := X"06d3"; -- RW, Calibration Result Registers - Channel 180

constant Q_OFS_181_ADDR         : std_logic_vector(15 downto 0) := X"06d4"; -- RW, Calibration Result Registers - Channel 181
constant Q_OSACLK_181_ADDR      : std_logic_vector(15 downto 0) := X"06d5"; -- RW, Calibration Result Registers - Channel 181
constant LIN_CAL_QP1_181_ADDR   : std_logic_vector(15 downto 0) := X"06d6"; -- RW, Calibration Result Registers - Channel 181
constant LIN_CAL_QP2_181_ADDR   : std_logic_vector(15 downto 0) := X"06d7"; -- RW, Calibration Result Registers - Channel 181

constant Q_OFS_182_ADDR         : std_logic_vector(15 downto 0) := X"06d8"; -- RW, Calibration Result Registers - Channel 182
constant Q_OSACLK_182_ADDR      : std_logic_vector(15 downto 0) := X"06d9"; -- RW, Calibration Result Registers - Channel 182
constant LIN_CAL_QP1_182_ADDR   : std_logic_vector(15 downto 0) := X"06da"; -- RW, Calibration Result Registers - Channel 182
constant LIN_CAL_QP2_182_ADDR   : std_logic_vector(15 downto 0) := X"06db"; -- RW, Calibration Result Registers - Channel 182

constant Q_OFS_183_ADDR         : std_logic_vector(15 downto 0) := X"06dc"; -- RW, Calibration Result Registers - Channel 183
constant Q_OSACLK_183_ADDR      : std_logic_vector(15 downto 0) := X"06dd"; -- RW, Calibration Result Registers - Channel 183
constant LIN_CAL_QP1_183_ADDR   : std_logic_vector(15 downto 0) := X"06de"; -- RW, Calibration Result Registers - Channel 183
constant LIN_CAL_QP2_183_ADDR   : std_logic_vector(15 downto 0) := X"06df"; -- RW, Calibration Result Registers - Channel 183

constant Q_OFS_184_ADDR         : std_logic_vector(15 downto 0) := X"06e0"; -- RW, Calibration Result Registers - Channel 184
constant Q_OSACLK_184_ADDR      : std_logic_vector(15 downto 0) := X"06e1"; -- RW, Calibration Result Registers - Channel 184
constant LIN_CAL_QP1_184_ADDR   : std_logic_vector(15 downto 0) := X"06e2"; -- RW, Calibration Result Registers - Channel 184
constant LIN_CAL_QP2_184_ADDR   : std_logic_vector(15 downto 0) := X"06e3"; -- RW, Calibration Result Registers - Channel 184

constant Q_OFS_185_ADDR         : std_logic_vector(15 downto 0) := X"06e4"; -- RW, Calibration Result Registers - Channel 185
constant Q_OSACLK_185_ADDR      : std_logic_vector(15 downto 0) := X"06e5"; -- RW, Calibration Result Registers - Channel 185
constant LIN_CAL_QP1_185_ADDR   : std_logic_vector(15 downto 0) := X"06e6"; -- RW, Calibration Result Registers - Channel 185
constant LIN_CAL_QP2_185_ADDR   : std_logic_vector(15 downto 0) := X"06e7"; -- RW, Calibration Result Registers - Channel 185

constant Q_OFS_186_ADDR         : std_logic_vector(15 downto 0) := X"06e8"; -- RW, Calibration Result Registers - Channel 186
constant Q_OSACLK_186_ADDR      : std_logic_vector(15 downto 0) := X"06e9"; -- RW, Calibration Result Registers - Channel 186
constant LIN_CAL_QP1_186_ADDR   : std_logic_vector(15 downto 0) := X"06ea"; -- RW, Calibration Result Registers - Channel 186
constant LIN_CAL_QP2_186_ADDR   : std_logic_vector(15 downto 0) := X"06eb"; -- RW, Calibration Result Registers - Channel 186

constant Q_OFS_187_ADDR         : std_logic_vector(15 downto 0) := X"06ec"; -- RW, Calibration Result Registers - Channel 187
constant Q_OSACLK_187_ADDR      : std_logic_vector(15 downto 0) := X"06ed"; -- RW, Calibration Result Registers - Channel 187
constant LIN_CAL_QP1_187_ADDR   : std_logic_vector(15 downto 0) := X"06ee"; -- RW, Calibration Result Registers - Channel 187
constant LIN_CAL_QP2_187_ADDR   : std_logic_vector(15 downto 0) := X"06ef"; -- RW, Calibration Result Registers - Channel 187

constant Q_OFS_188_ADDR         : std_logic_vector(15 downto 0) := X"06f0"; -- RW, Calibration Result Registers - Channel 188
constant Q_OSACLK_188_ADDR      : std_logic_vector(15 downto 0) := X"06f1"; -- RW, Calibration Result Registers - Channel 188
constant LIN_CAL_QP1_188_ADDR   : std_logic_vector(15 downto 0) := X"06f2"; -- RW, Calibration Result Registers - Channel 188
constant LIN_CAL_QP2_188_ADDR   : std_logic_vector(15 downto 0) := X"06f3"; -- RW, Calibration Result Registers - Channel 188

constant Q_OFS_189_ADDR         : std_logic_vector(15 downto 0) := X"06f4"; -- RW, Calibration Result Registers - Channel 189
constant Q_OSACLK_189_ADDR      : std_logic_vector(15 downto 0) := X"06f5"; -- RW, Calibration Result Registers - Channel 189
constant LIN_CAL_QP1_189_ADDR   : std_logic_vector(15 downto 0) := X"06f6"; -- RW, Calibration Result Registers - Channel 189
constant LIN_CAL_QP2_189_ADDR   : std_logic_vector(15 downto 0) := X"06f7"; -- RW, Calibration Result Registers - Channel 189

constant Q_OFS_190_ADDR         : std_logic_vector(15 downto 0) := X"06f8"; -- RW, Calibration Result Registers - Channel 190
constant Q_OSACLK_190_ADDR      : std_logic_vector(15 downto 0) := X"06f9"; -- RW, Calibration Result Registers - Channel 190
constant LIN_CAL_QP1_190_ADDR   : std_logic_vector(15 downto 0) := X"06fa"; -- RW, Calibration Result Registers - Channel 190
constant LIN_CAL_QP2_190_ADDR   : std_logic_vector(15 downto 0) := X"06fb"; -- RW, Calibration Result Registers - Channel 190

constant Q_OFS_191_ADDR         : std_logic_vector(15 downto 0) := X"06fc"; -- RW, Calibration Result Registers - Channel 191
constant Q_OSACLK_191_ADDR      : std_logic_vector(15 downto 0) := X"06fd"; -- RW, Calibration Result Registers - Channel 191
constant LIN_CAL_QP1_191_ADDR   : std_logic_vector(15 downto 0) := X"06fe"; -- RW, Calibration Result Registers - Channel 191
constant LIN_CAL_QP2_191_ADDR   : std_logic_vector(15 downto 0) := X"06ff"; -- RW, Calibration Result Registers - Channel 191

constant Q_OFS_192_ADDR         : std_logic_vector(15 downto 0) := X"0700"; -- RW, Calibration Result Registers - Channel 192
constant Q_OSACLK_192_ADDR      : std_logic_vector(15 downto 0) := X"0701"; -- RW, Calibration Result Registers - Channel 192
constant LIN_CAL_QP1_192_ADDR   : std_logic_vector(15 downto 0) := X"0702"; -- RW, Calibration Result Registers - Channel 192
constant LIN_CAL_QP2_192_ADDR   : std_logic_vector(15 downto 0) := X"0703"; -- RW, Calibration Result Registers - Channel 192

constant Q_OFS_193_ADDR         : std_logic_vector(15 downto 0) := X"0704"; -- RW, Calibration Result Registers - Channel 193
constant Q_OSACLK_193_ADDR      : std_logic_vector(15 downto 0) := X"0705"; -- RW, Calibration Result Registers - Channel 193
constant LIN_CAL_QP1_193_ADDR   : std_logic_vector(15 downto 0) := X"0706"; -- RW, Calibration Result Registers - Channel 193
constant LIN_CAL_QP2_193_ADDR   : std_logic_vector(15 downto 0) := X"0707"; -- RW, Calibration Result Registers - Channel 193

constant Q_OFS_194_ADDR         : std_logic_vector(15 downto 0) := X"0708"; -- RW, Calibration Result Registers - Channel 194
constant Q_OSACLK_194_ADDR      : std_logic_vector(15 downto 0) := X"0709"; -- RW, Calibration Result Registers - Channel 194
constant LIN_CAL_QP1_194_ADDR   : std_logic_vector(15 downto 0) := X"070a"; -- RW, Calibration Result Registers - Channel 194
constant LIN_CAL_QP2_194_ADDR   : std_logic_vector(15 downto 0) := X"070b"; -- RW, Calibration Result Registers - Channel 194

constant Q_OFS_195_ADDR         : std_logic_vector(15 downto 0) := X"070c"; -- RW, Calibration Result Registers - Channel 195
constant Q_OSACLK_195_ADDR      : std_logic_vector(15 downto 0) := X"070d"; -- RW, Calibration Result Registers - Channel 195
constant LIN_CAL_QP1_195_ADDR   : std_logic_vector(15 downto 0) := X"070e"; -- RW, Calibration Result Registers - Channel 195
constant LIN_CAL_QP2_195_ADDR   : std_logic_vector(15 downto 0) := X"070f"; -- RW, Calibration Result Registers - Channel 195

constant Q_OFS_196_ADDR         : std_logic_vector(15 downto 0) := X"0710"; -- RW, Calibration Result Registers - Channel 196
constant Q_OSACLK_196_ADDR      : std_logic_vector(15 downto 0) := X"0711"; -- RW, Calibration Result Registers - Channel 196
constant LIN_CAL_QP1_196_ADDR   : std_logic_vector(15 downto 0) := X"0712"; -- RW, Calibration Result Registers - Channel 196
constant LIN_CAL_QP2_196_ADDR   : std_logic_vector(15 downto 0) := X"0713"; -- RW, Calibration Result Registers - Channel 196

constant Q_OFS_197_ADDR         : std_logic_vector(15 downto 0) := X"0714"; -- RW, Calibration Result Registers - Channel 197
constant Q_OSACLK_197_ADDR      : std_logic_vector(15 downto 0) := X"0715"; -- RW, Calibration Result Registers - Channel 197
constant LIN_CAL_QP1_197_ADDR   : std_logic_vector(15 downto 0) := X"0716"; -- RW, Calibration Result Registers - Channel 197
constant LIN_CAL_QP2_197_ADDR   : std_logic_vector(15 downto 0) := X"0717"; -- RW, Calibration Result Registers - Channel 197

constant Q_OFS_198_ADDR         : std_logic_vector(15 downto 0) := X"0718"; -- RW, Calibration Result Registers - Channel 198
constant Q_OSACLK_198_ADDR      : std_logic_vector(15 downto 0) := X"0719"; -- RW, Calibration Result Registers - Channel 198
constant LIN_CAL_QP1_198_ADDR   : std_logic_vector(15 downto 0) := X"071a"; -- RW, Calibration Result Registers - Channel 198
constant LIN_CAL_QP2_198_ADDR   : std_logic_vector(15 downto 0) := X"071b"; -- RW, Calibration Result Registers - Channel 198

constant Q_OFS_199_ADDR         : std_logic_vector(15 downto 0) := X"071c"; -- RW, Calibration Result Registers - Channel 199
constant Q_OSACLK_199_ADDR      : std_logic_vector(15 downto 0) := X"071d"; -- RW, Calibration Result Registers - Channel 199
constant LIN_CAL_QP1_199_ADDR   : std_logic_vector(15 downto 0) := X"071e"; -- RW, Calibration Result Registers - Channel 199
constant LIN_CAL_QP2_199_ADDR   : std_logic_vector(15 downto 0) := X"071f"; -- RW, Calibration Result Registers - Channel 199

constant Q_OFS_200_ADDR         : std_logic_vector(15 downto 0) := X"0720"; -- RW, Calibration Result Registers - Channel 200
constant Q_OSACLK_200_ADDR      : std_logic_vector(15 downto 0) := X"0721"; -- RW, Calibration Result Registers - Channel 200
constant LIN_CAL_QP1_200_ADDR   : std_logic_vector(15 downto 0) := X"0722"; -- RW, Calibration Result Registers - Channel 200
constant LIN_CAL_QP2_200_ADDR   : std_logic_vector(15 downto 0) := X"0723"; -- RW, Calibration Result Registers - Channel 200

constant Q_OFS_201_ADDR         : std_logic_vector(15 downto 0) := X"0724"; -- RW, Calibration Result Registers - Channel 201
constant Q_OSACLK_201_ADDR      : std_logic_vector(15 downto 0) := X"0725"; -- RW, Calibration Result Registers - Channel 201
constant LIN_CAL_QP1_201_ADDR   : std_logic_vector(15 downto 0) := X"0726"; -- RW, Calibration Result Registers - Channel 201
constant LIN_CAL_QP2_201_ADDR   : std_logic_vector(15 downto 0) := X"0727"; -- RW, Calibration Result Registers - Channel 201

constant Q_OFS_202_ADDR         : std_logic_vector(15 downto 0) := X"0728"; -- RW, Calibration Result Registers - Channel 202
constant Q_OSACLK_202_ADDR      : std_logic_vector(15 downto 0) := X"0729"; -- RW, Calibration Result Registers - Channel 202
constant LIN_CAL_QP1_202_ADDR   : std_logic_vector(15 downto 0) := X"072a"; -- RW, Calibration Result Registers - Channel 202
constant LIN_CAL_QP2_202_ADDR   : std_logic_vector(15 downto 0) := X"072b"; -- RW, Calibration Result Registers - Channel 202

constant Q_OFS_203_ADDR         : std_logic_vector(15 downto 0) := X"072c"; -- RW, Calibration Result Registers - Channel 203
constant Q_OSACLK_203_ADDR      : std_logic_vector(15 downto 0) := X"072d"; -- RW, Calibration Result Registers - Channel 203
constant LIN_CAL_QP1_203_ADDR   : std_logic_vector(15 downto 0) := X"072e"; -- RW, Calibration Result Registers - Channel 203
constant LIN_CAL_QP2_203_ADDR   : std_logic_vector(15 downto 0) := X"072f"; -- RW, Calibration Result Registers - Channel 203

constant Q_OFS_204_ADDR         : std_logic_vector(15 downto 0) := X"0730"; -- RW, Calibration Result Registers - Channel 204
constant Q_OSACLK_204_ADDR      : std_logic_vector(15 downto 0) := X"0731"; -- RW, Calibration Result Registers - Channel 204
constant LIN_CAL_QP1_204_ADDR   : std_logic_vector(15 downto 0) := X"0732"; -- RW, Calibration Result Registers - Channel 204
constant LIN_CAL_QP2_204_ADDR   : std_logic_vector(15 downto 0) := X"0733"; -- RW, Calibration Result Registers - Channel 204

constant Q_OFS_205_ADDR         : std_logic_vector(15 downto 0) := X"0734"; -- RW, Calibration Result Registers - Channel 205
constant Q_OSACLK_205_ADDR      : std_logic_vector(15 downto 0) := X"0735"; -- RW, Calibration Result Registers - Channel 205
constant LIN_CAL_QP1_205_ADDR   : std_logic_vector(15 downto 0) := X"0736"; -- RW, Calibration Result Registers - Channel 205
constant LIN_CAL_QP2_205_ADDR   : std_logic_vector(15 downto 0) := X"0737"; -- RW, Calibration Result Registers - Channel 205

constant Q_OFS_206_ADDR         : std_logic_vector(15 downto 0) := X"0738"; -- RW, Calibration Result Registers - Channel 206
constant Q_OSACLK_206_ADDR      : std_logic_vector(15 downto 0) := X"0739"; -- RW, Calibration Result Registers - Channel 206
constant LIN_CAL_QP1_206_ADDR   : std_logic_vector(15 downto 0) := X"073a"; -- RW, Calibration Result Registers - Channel 206
constant LIN_CAL_QP2_206_ADDR   : std_logic_vector(15 downto 0) := X"073b"; -- RW, Calibration Result Registers - Channel 206

constant Q_OFS_207_ADDR         : std_logic_vector(15 downto 0) := X"073c"; -- RW, Calibration Result Registers - Channel 207
constant Q_OSACLK_207_ADDR      : std_logic_vector(15 downto 0) := X"073d"; -- RW, Calibration Result Registers - Channel 207
constant LIN_CAL_QP1_207_ADDR   : std_logic_vector(15 downto 0) := X"073e"; -- RW, Calibration Result Registers - Channel 207
constant LIN_CAL_QP2_207_ADDR   : std_logic_vector(15 downto 0) := X"073f"; -- RW, Calibration Result Registers - Channel 207

constant Q_OFS_208_ADDR         : std_logic_vector(15 downto 0) := X"0740"; -- RW, Calibration Result Registers - Channel 208
constant Q_OSACLK_208_ADDR      : std_logic_vector(15 downto 0) := X"0741"; -- RW, Calibration Result Registers - Channel 208
constant LIN_CAL_QP1_208_ADDR   : std_logic_vector(15 downto 0) := X"0742"; -- RW, Calibration Result Registers - Channel 208
constant LIN_CAL_QP2_208_ADDR   : std_logic_vector(15 downto 0) := X"0743"; -- RW, Calibration Result Registers - Channel 208

constant Q_OFS_209_ADDR         : std_logic_vector(15 downto 0) := X"0744"; -- RW, Calibration Result Registers - Channel 209
constant Q_OSACLK_209_ADDR      : std_logic_vector(15 downto 0) := X"0745"; -- RW, Calibration Result Registers - Channel 209
constant LIN_CAL_QP1_209_ADDR   : std_logic_vector(15 downto 0) := X"0746"; -- RW, Calibration Result Registers - Channel 209
constant LIN_CAL_QP2_209_ADDR   : std_logic_vector(15 downto 0) := X"0747"; -- RW, Calibration Result Registers - Channel 209

constant Q_OFS_210_ADDR         : std_logic_vector(15 downto 0) := X"0748"; -- RW, Calibration Result Registers - Channel 210
constant Q_OSACLK_210_ADDR      : std_logic_vector(15 downto 0) := X"0749"; -- RW, Calibration Result Registers - Channel 210
constant LIN_CAL_QP1_210_ADDR   : std_logic_vector(15 downto 0) := X"074a"; -- RW, Calibration Result Registers - Channel 210
constant LIN_CAL_QP2_210_ADDR   : std_logic_vector(15 downto 0) := X"074b"; -- RW, Calibration Result Registers - Channel 210

constant Q_OFS_211_ADDR         : std_logic_vector(15 downto 0) := X"074c"; -- RW, Calibration Result Registers - Channel 211
constant Q_OSACLK_211_ADDR      : std_logic_vector(15 downto 0) := X"074d"; -- RW, Calibration Result Registers - Channel 211
constant LIN_CAL_QP1_211_ADDR   : std_logic_vector(15 downto 0) := X"074e"; -- RW, Calibration Result Registers - Channel 211
constant LIN_CAL_QP2_211_ADDR   : std_logic_vector(15 downto 0) := X"074f"; -- RW, Calibration Result Registers - Channel 211

constant Q_OFS_212_ADDR         : std_logic_vector(15 downto 0) := X"0750"; -- RW, Calibration Result Registers - Channel 212
constant Q_OSACLK_212_ADDR      : std_logic_vector(15 downto 0) := X"0751"; -- RW, Calibration Result Registers - Channel 212
constant LIN_CAL_QP1_212_ADDR   : std_logic_vector(15 downto 0) := X"0752"; -- RW, Calibration Result Registers - Channel 212
constant LIN_CAL_QP2_212_ADDR   : std_logic_vector(15 downto 0) := X"0753"; -- RW, Calibration Result Registers - Channel 212

constant Q_OFS_213_ADDR         : std_logic_vector(15 downto 0) := X"0754"; -- RW, Calibration Result Registers - Channel 213
constant Q_OSACLK_213_ADDR      : std_logic_vector(15 downto 0) := X"0755"; -- RW, Calibration Result Registers - Channel 213
constant LIN_CAL_QP1_213_ADDR   : std_logic_vector(15 downto 0) := X"0756"; -- RW, Calibration Result Registers - Channel 213
constant LIN_CAL_QP2_213_ADDR   : std_logic_vector(15 downto 0) := X"0757"; -- RW, Calibration Result Registers - Channel 213

constant Q_OFS_214_ADDR         : std_logic_vector(15 downto 0) := X"0758"; -- RW, Calibration Result Registers - Channel 214
constant Q_OSACLK_214_ADDR      : std_logic_vector(15 downto 0) := X"0759"; -- RW, Calibration Result Registers - Channel 214
constant LIN_CAL_QP1_214_ADDR   : std_logic_vector(15 downto 0) := X"075a"; -- RW, Calibration Result Registers - Channel 214
constant LIN_CAL_QP2_214_ADDR   : std_logic_vector(15 downto 0) := X"075b"; -- RW, Calibration Result Registers - Channel 214

constant Q_OFS_215_ADDR         : std_logic_vector(15 downto 0) := X"075c"; -- RW, Calibration Result Registers - Channel 215
constant Q_OSACLK_215_ADDR      : std_logic_vector(15 downto 0) := X"075d"; -- RW, Calibration Result Registers - Channel 215
constant LIN_CAL_QP1_215_ADDR   : std_logic_vector(15 downto 0) := X"075e"; -- RW, Calibration Result Registers - Channel 215
constant LIN_CAL_QP2_215_ADDR   : std_logic_vector(15 downto 0) := X"075f"; -- RW, Calibration Result Registers - Channel 215

constant Q_OFS_216_ADDR         : std_logic_vector(15 downto 0) := X"0760"; -- RW, Calibration Result Registers - Channel 216
constant Q_OSACLK_216_ADDR      : std_logic_vector(15 downto 0) := X"0761"; -- RW, Calibration Result Registers - Channel 216
constant LIN_CAL_QP1_216_ADDR   : std_logic_vector(15 downto 0) := X"0762"; -- RW, Calibration Result Registers - Channel 216
constant LIN_CAL_QP2_216_ADDR   : std_logic_vector(15 downto 0) := X"0763"; -- RW, Calibration Result Registers - Channel 216

constant Q_OFS_217_ADDR         : std_logic_vector(15 downto 0) := X"0764"; -- RW, Calibration Result Registers - Channel 217
constant Q_OSACLK_217_ADDR      : std_logic_vector(15 downto 0) := X"0765"; -- RW, Calibration Result Registers - Channel 217
constant LIN_CAL_QP1_217_ADDR   : std_logic_vector(15 downto 0) := X"0766"; -- RW, Calibration Result Registers - Channel 217
constant LIN_CAL_QP2_217_ADDR   : std_logic_vector(15 downto 0) := X"0767"; -- RW, Calibration Result Registers - Channel 217

constant Q_OFS_218_ADDR         : std_logic_vector(15 downto 0) := X"0768"; -- RW, Calibration Result Registers - Channel 218
constant Q_OSACLK_218_ADDR      : std_logic_vector(15 downto 0) := X"0769"; -- RW, Calibration Result Registers - Channel 218
constant LIN_CAL_QP1_218_ADDR   : std_logic_vector(15 downto 0) := X"076a"; -- RW, Calibration Result Registers - Channel 218
constant LIN_CAL_QP2_218_ADDR   : std_logic_vector(15 downto 0) := X"076b"; -- RW, Calibration Result Registers - Channel 218

constant Q_OFS_219_ADDR         : std_logic_vector(15 downto 0) := X"076c"; -- RW, Calibration Result Registers - Channel 219
constant Q_OSACLK_219_ADDR      : std_logic_vector(15 downto 0) := X"076d"; -- RW, Calibration Result Registers - Channel 219
constant LIN_CAL_QP1_219_ADDR   : std_logic_vector(15 downto 0) := X"076e"; -- RW, Calibration Result Registers - Channel 219
constant LIN_CAL_QP2_219_ADDR   : std_logic_vector(15 downto 0) := X"076f"; -- RW, Calibration Result Registers - Channel 219

constant Q_OFS_220_ADDR         : std_logic_vector(15 downto 0) := X"0770"; -- RW, Calibration Result Registers - Channel 220
constant Q_OSACLK_220_ADDR      : std_logic_vector(15 downto 0) := X"0771"; -- RW, Calibration Result Registers - Channel 220
constant LIN_CAL_QP1_220_ADDR   : std_logic_vector(15 downto 0) := X"0772"; -- RW, Calibration Result Registers - Channel 220
constant LIN_CAL_QP2_220_ADDR   : std_logic_vector(15 downto 0) := X"0773"; -- RW, Calibration Result Registers - Channel 220

constant Q_OFS_221_ADDR         : std_logic_vector(15 downto 0) := X"0774"; -- RW, Calibration Result Registers - Channel 221
constant Q_OSACLK_221_ADDR      : std_logic_vector(15 downto 0) := X"0775"; -- RW, Calibration Result Registers - Channel 221
constant LIN_CAL_QP1_221_ADDR   : std_logic_vector(15 downto 0) := X"0776"; -- RW, Calibration Result Registers - Channel 221
constant LIN_CAL_QP2_221_ADDR   : std_logic_vector(15 downto 0) := X"0777"; -- RW, Calibration Result Registers - Channel 221

constant Q_OFS_222_ADDR         : std_logic_vector(15 downto 0) := X"0778"; -- RW, Calibration Result Registers - Channel 222
constant Q_OSACLK_222_ADDR      : std_logic_vector(15 downto 0) := X"0779"; -- RW, Calibration Result Registers - Channel 222
constant LIN_CAL_QP1_222_ADDR   : std_logic_vector(15 downto 0) := X"077a"; -- RW, Calibration Result Registers - Channel 222
constant LIN_CAL_QP2_222_ADDR   : std_logic_vector(15 downto 0) := X"077b"; -- RW, Calibration Result Registers - Channel 222

constant Q_OFS_223_ADDR         : std_logic_vector(15 downto 0) := X"077c"; -- RW, Calibration Result Registers - Channel 223
constant Q_OSACLK_223_ADDR      : std_logic_vector(15 downto 0) := X"077d"; -- RW, Calibration Result Registers - Channel 223
constant LIN_CAL_QP1_223_ADDR   : std_logic_vector(15 downto 0) := X"077e"; -- RW, Calibration Result Registers - Channel 223
constant LIN_CAL_QP2_223_ADDR   : std_logic_vector(15 downto 0) := X"077f"; -- RW, Calibration Result Registers - Channel 223

constant Q_OFS_224_ADDR         : std_logic_vector(15 downto 0) := X"0780"; -- RW, Calibration Result Registers - Channel 224
constant Q_OSACLK_224_ADDR      : std_logic_vector(15 downto 0) := X"0781"; -- RW, Calibration Result Registers - Channel 224
constant LIN_CAL_QP1_224_ADDR   : std_logic_vector(15 downto 0) := X"0782"; -- RW, Calibration Result Registers - Channel 224
constant LIN_CAL_QP2_224_ADDR   : std_logic_vector(15 downto 0) := X"0783"; -- RW, Calibration Result Registers - Channel 224

constant Q_OFS_225_ADDR         : std_logic_vector(15 downto 0) := X"0784"; -- RW, Calibration Result Registers - Channel 225
constant Q_OSACLK_225_ADDR      : std_logic_vector(15 downto 0) := X"0785"; -- RW, Calibration Result Registers - Channel 225
constant LIN_CAL_QP1_225_ADDR   : std_logic_vector(15 downto 0) := X"0786"; -- RW, Calibration Result Registers - Channel 225
constant LIN_CAL_QP2_225_ADDR   : std_logic_vector(15 downto 0) := X"0787"; -- RW, Calibration Result Registers - Channel 225

constant Q_OFS_226_ADDR         : std_logic_vector(15 downto 0) := X"0788"; -- RW, Calibration Result Registers - Channel 226
constant Q_OSACLK_226_ADDR      : std_logic_vector(15 downto 0) := X"0789"; -- RW, Calibration Result Registers - Channel 226
constant LIN_CAL_QP1_226_ADDR   : std_logic_vector(15 downto 0) := X"078a"; -- RW, Calibration Result Registers - Channel 226
constant LIN_CAL_QP2_226_ADDR   : std_logic_vector(15 downto 0) := X"078b"; -- RW, Calibration Result Registers - Channel 226

constant Q_OFS_227_ADDR         : std_logic_vector(15 downto 0) := X"078c"; -- RW, Calibration Result Registers - Channel 227
constant Q_OSACLK_227_ADDR      : std_logic_vector(15 downto 0) := X"078d"; -- RW, Calibration Result Registers - Channel 227
constant LIN_CAL_QP1_227_ADDR   : std_logic_vector(15 downto 0) := X"078e"; -- RW, Calibration Result Registers - Channel 227
constant LIN_CAL_QP2_227_ADDR   : std_logic_vector(15 downto 0) := X"078f"; -- RW, Calibration Result Registers - Channel 227

constant Q_OFS_228_ADDR         : std_logic_vector(15 downto 0) := X"0790"; -- RW, Calibration Result Registers - Channel 228
constant Q_OSACLK_228_ADDR      : std_logic_vector(15 downto 0) := X"0791"; -- RW, Calibration Result Registers - Channel 228
constant LIN_CAL_QP1_228_ADDR   : std_logic_vector(15 downto 0) := X"0792"; -- RW, Calibration Result Registers - Channel 228
constant LIN_CAL_QP2_228_ADDR   : std_logic_vector(15 downto 0) := X"0793"; -- RW, Calibration Result Registers - Channel 228

constant Q_OFS_229_ADDR         : std_logic_vector(15 downto 0) := X"0794"; -- RW, Calibration Result Registers - Channel 229
constant Q_OSACLK_229_ADDR      : std_logic_vector(15 downto 0) := X"0795"; -- RW, Calibration Result Registers - Channel 229
constant LIN_CAL_QP1_229_ADDR   : std_logic_vector(15 downto 0) := X"0796"; -- RW, Calibration Result Registers - Channel 229
constant LIN_CAL_QP2_229_ADDR   : std_logic_vector(15 downto 0) := X"0797"; -- RW, Calibration Result Registers - Channel 229

constant Q_OFS_230_ADDR         : std_logic_vector(15 downto 0) := X"0798"; -- RW, Calibration Result Registers - Channel 230
constant Q_OSACLK_230_ADDR      : std_logic_vector(15 downto 0) := X"0799"; -- RW, Calibration Result Registers - Channel 230
constant LIN_CAL_QP1_230_ADDR   : std_logic_vector(15 downto 0) := X"079a"; -- RW, Calibration Result Registers - Channel 230
constant LIN_CAL_QP2_230_ADDR   : std_logic_vector(15 downto 0) := X"079b"; -- RW, Calibration Result Registers - Channel 230

constant Q_OFS_231_ADDR         : std_logic_vector(15 downto 0) := X"079c"; -- RW, Calibration Result Registers - Channel 231
constant Q_OSACLK_231_ADDR      : std_logic_vector(15 downto 0) := X"079d"; -- RW, Calibration Result Registers - Channel 231
constant LIN_CAL_QP1_231_ADDR   : std_logic_vector(15 downto 0) := X"079e"; -- RW, Calibration Result Registers - Channel 231
constant LIN_CAL_QP2_231_ADDR   : std_logic_vector(15 downto 0) := X"079f"; -- RW, Calibration Result Registers - Channel 231

constant Q_OFS_232_ADDR         : std_logic_vector(15 downto 0) := X"07a0"; -- RW, Calibration Result Registers - Channel 232
constant Q_OSACLK_232_ADDR      : std_logic_vector(15 downto 0) := X"07a1"; -- RW, Calibration Result Registers - Channel 232
constant LIN_CAL_QP1_232_ADDR   : std_logic_vector(15 downto 0) := X"07a2"; -- RW, Calibration Result Registers - Channel 232
constant LIN_CAL_QP2_232_ADDR   : std_logic_vector(15 downto 0) := X"07a3"; -- RW, Calibration Result Registers - Channel 232

constant Q_OFS_233_ADDR         : std_logic_vector(15 downto 0) := X"07a4"; -- RW, Calibration Result Registers - Channel 233
constant Q_OSACLK_233_ADDR      : std_logic_vector(15 downto 0) := X"07a5"; -- RW, Calibration Result Registers - Channel 233
constant LIN_CAL_QP1_233_ADDR   : std_logic_vector(15 downto 0) := X"07a6"; -- RW, Calibration Result Registers - Channel 233
constant LIN_CAL_QP2_233_ADDR   : std_logic_vector(15 downto 0) := X"07a7"; -- RW, Calibration Result Registers - Channel 233

constant Q_OFS_234_ADDR         : std_logic_vector(15 downto 0) := X"07a8"; -- RW, Calibration Result Registers - Channel 234
constant Q_OSACLK_234_ADDR      : std_logic_vector(15 downto 0) := X"07a9"; -- RW, Calibration Result Registers - Channel 234
constant LIN_CAL_QP1_234_ADDR   : std_logic_vector(15 downto 0) := X"07aa"; -- RW, Calibration Result Registers - Channel 234
constant LIN_CAL_QP2_234_ADDR   : std_logic_vector(15 downto 0) := X"07ab"; -- RW, Calibration Result Registers - Channel 234

constant Q_OFS_235_ADDR         : std_logic_vector(15 downto 0) := X"07ac"; -- RW, Calibration Result Registers - Channel 235
constant Q_OSACLK_235_ADDR      : std_logic_vector(15 downto 0) := X"07ad"; -- RW, Calibration Result Registers - Channel 235
constant LIN_CAL_QP1_235_ADDR   : std_logic_vector(15 downto 0) := X"07ae"; -- RW, Calibration Result Registers - Channel 235
constant LIN_CAL_QP2_235_ADDR   : std_logic_vector(15 downto 0) := X"07af"; -- RW, Calibration Result Registers - Channel 235

constant Q_OFS_236_ADDR         : std_logic_vector(15 downto 0) := X"07b0"; -- RW, Calibration Result Registers - Channel 236
constant Q_OSACLK_236_ADDR      : std_logic_vector(15 downto 0) := X"07b1"; -- RW, Calibration Result Registers - Channel 236
constant LIN_CAL_QP1_236_ADDR   : std_logic_vector(15 downto 0) := X"07b2"; -- RW, Calibration Result Registers - Channel 236
constant LIN_CAL_QP2_236_ADDR   : std_logic_vector(15 downto 0) := X"07b3"; -- RW, Calibration Result Registers - Channel 236

constant Q_OFS_237_ADDR         : std_logic_vector(15 downto 0) := X"07b4"; -- RW, Calibration Result Registers - Channel 237
constant Q_OSACLK_237_ADDR      : std_logic_vector(15 downto 0) := X"07b5"; -- RW, Calibration Result Registers - Channel 237
constant LIN_CAL_QP1_237_ADDR   : std_logic_vector(15 downto 0) := X"07b6"; -- RW, Calibration Result Registers - Channel 237
constant LIN_CAL_QP2_237_ADDR   : std_logic_vector(15 downto 0) := X"07b7"; -- RW, Calibration Result Registers - Channel 237

constant Q_OFS_238_ADDR         : std_logic_vector(15 downto 0) := X"07b8"; -- RW, Calibration Result Registers - Channel 238
constant Q_OSACLK_238_ADDR      : std_logic_vector(15 downto 0) := X"07b9"; -- RW, Calibration Result Registers - Channel 238
constant LIN_CAL_QP1_238_ADDR   : std_logic_vector(15 downto 0) := X"07ba"; -- RW, Calibration Result Registers - Channel 238
constant LIN_CAL_QP2_238_ADDR   : std_logic_vector(15 downto 0) := X"07bb"; -- RW, Calibration Result Registers - Channel 238

constant Q_OFS_239_ADDR         : std_logic_vector(15 downto 0) := X"07bc"; -- RW, Calibration Result Registers - Channel 239
constant Q_OSACLK_239_ADDR      : std_logic_vector(15 downto 0) := X"07bd"; -- RW, Calibration Result Registers - Channel 239
constant LIN_CAL_QP1_239_ADDR   : std_logic_vector(15 downto 0) := X"07be"; -- RW, Calibration Result Registers - Channel 239
constant LIN_CAL_QP2_239_ADDR   : std_logic_vector(15 downto 0) := X"07bf"; -- RW, Calibration Result Registers - Channel 239

constant Q_OFS_240_ADDR         : std_logic_vector(15 downto 0) := X"07c0"; -- RW, Calibration Result Registers - Channel 240
constant Q_OSACLK_240_ADDR      : std_logic_vector(15 downto 0) := X"07c1"; -- RW, Calibration Result Registers - Channel 240
constant LIN_CAL_QP1_240_ADDR   : std_logic_vector(15 downto 0) := X"07c2"; -- RW, Calibration Result Registers - Channel 240
constant LIN_CAL_QP2_240_ADDR   : std_logic_vector(15 downto 0) := X"07c3"; -- RW, Calibration Result Registers - Channel 240

constant Q_OFS_241_ADDR         : std_logic_vector(15 downto 0) := X"07c4"; -- RW, Calibration Result Registers - Channel 241
constant Q_OSACLK_241_ADDR      : std_logic_vector(15 downto 0) := X"07c5"; -- RW, Calibration Result Registers - Channel 241
constant LIN_CAL_QP1_241_ADDR   : std_logic_vector(15 downto 0) := X"07c6"; -- RW, Calibration Result Registers - Channel 241
constant LIN_CAL_QP2_241_ADDR   : std_logic_vector(15 downto 0) := X"07c7"; -- RW, Calibration Result Registers - Channel 241

constant Q_OFS_242_ADDR         : std_logic_vector(15 downto 0) := X"07c8"; -- RW, Calibration Result Registers - Channel 242
constant Q_OSACLK_242_ADDR      : std_logic_vector(15 downto 0) := X"07c9"; -- RW, Calibration Result Registers - Channel 242
constant LIN_CAL_QP1_242_ADDR   : std_logic_vector(15 downto 0) := X"07ca"; -- RW, Calibration Result Registers - Channel 242
constant LIN_CAL_QP2_242_ADDR   : std_logic_vector(15 downto 0) := X"07cb"; -- RW, Calibration Result Registers - Channel 242

constant Q_OFS_243_ADDR         : std_logic_vector(15 downto 0) := X"07cc"; -- RW, Calibration Result Registers - Channel 243
constant Q_OSACLK_243_ADDR      : std_logic_vector(15 downto 0) := X"07cd"; -- RW, Calibration Result Registers - Channel 243
constant LIN_CAL_QP1_243_ADDR   : std_logic_vector(15 downto 0) := X"07ce"; -- RW, Calibration Result Registers - Channel 243
constant LIN_CAL_QP2_243_ADDR   : std_logic_vector(15 downto 0) := X"07cf"; -- RW, Calibration Result Registers - Channel 243

constant Q_OFS_244_ADDR         : std_logic_vector(15 downto 0) := X"07d0"; -- RW, Calibration Result Registers - Channel 244
constant Q_OSACLK_244_ADDR      : std_logic_vector(15 downto 0) := X"07d1"; -- RW, Calibration Result Registers - Channel 244
constant LIN_CAL_QP1_244_ADDR   : std_logic_vector(15 downto 0) := X"07d2"; -- RW, Calibration Result Registers - Channel 244
constant LIN_CAL_QP2_244_ADDR   : std_logic_vector(15 downto 0) := X"07d3"; -- RW, Calibration Result Registers - Channel 244

constant Q_OFS_245_ADDR         : std_logic_vector(15 downto 0) := X"07d4"; -- RW, Calibration Result Registers - Channel 245
constant Q_OSACLK_245_ADDR      : std_logic_vector(15 downto 0) := X"07d5"; -- RW, Calibration Result Registers - Channel 245
constant LIN_CAL_QP1_245_ADDR   : std_logic_vector(15 downto 0) := X"07d6"; -- RW, Calibration Result Registers - Channel 245
constant LIN_CAL_QP2_245_ADDR   : std_logic_vector(15 downto 0) := X"07d7"; -- RW, Calibration Result Registers - Channel 245

constant Q_OFS_246_ADDR         : std_logic_vector(15 downto 0) := X"07d8"; -- RW, Calibration Result Registers - Channel 246
constant Q_OSACLK_246_ADDR      : std_logic_vector(15 downto 0) := X"07d9"; -- RW, Calibration Result Registers - Channel 246
constant LIN_CAL_QP1_246_ADDR   : std_logic_vector(15 downto 0) := X"07da"; -- RW, Calibration Result Registers - Channel 246
constant LIN_CAL_QP2_246_ADDR   : std_logic_vector(15 downto 0) := X"07db"; -- RW, Calibration Result Registers - Channel 246

constant Q_OFS_247_ADDR         : std_logic_vector(15 downto 0) := X"07dc"; -- RW, Calibration Result Registers - Channel 247
constant Q_OSACLK_247_ADDR      : std_logic_vector(15 downto 0) := X"07dd"; -- RW, Calibration Result Registers - Channel 247
constant LIN_CAL_QP1_247_ADDR   : std_logic_vector(15 downto 0) := X"07de"; -- RW, Calibration Result Registers - Channel 247
constant LIN_CAL_QP2_247_ADDR   : std_logic_vector(15 downto 0) := X"07df"; -- RW, Calibration Result Registers - Channel 247

constant Q_OFS_248_ADDR         : std_logic_vector(15 downto 0) := X"07e0"; -- RW, Calibration Result Registers - Channel 248
constant Q_OSACLK_248_ADDR      : std_logic_vector(15 downto 0) := X"07e1"; -- RW, Calibration Result Registers - Channel 248
constant LIN_CAL_QP1_248_ADDR   : std_logic_vector(15 downto 0) := X"07e2"; -- RW, Calibration Result Registers - Channel 248
constant LIN_CAL_QP2_248_ADDR   : std_logic_vector(15 downto 0) := X"07e3"; -- RW, Calibration Result Registers - Channel 248

constant Q_OFS_249_ADDR         : std_logic_vector(15 downto 0) := X"07e4"; -- RW, Calibration Result Registers - Channel 249
constant Q_OSACLK_249_ADDR      : std_logic_vector(15 downto 0) := X"07e5"; -- RW, Calibration Result Registers - Channel 249
constant LIN_CAL_QP1_249_ADDR   : std_logic_vector(15 downto 0) := X"07e6"; -- RW, Calibration Result Registers - Channel 249
constant LIN_CAL_QP2_249_ADDR   : std_logic_vector(15 downto 0) := X"07e7"; -- RW, Calibration Result Registers - Channel 249

constant Q_OFS_250_ADDR         : std_logic_vector(15 downto 0) := X"07e8"; -- RW, Calibration Result Registers - Channel 250
constant Q_OSACLK_250_ADDR      : std_logic_vector(15 downto 0) := X"07e9"; -- RW, Calibration Result Registers - Channel 250
constant LIN_CAL_QP1_250_ADDR   : std_logic_vector(15 downto 0) := X"07ea"; -- RW, Calibration Result Registers - Channel 250
constant LIN_CAL_QP2_250_ADDR   : std_logic_vector(15 downto 0) := X"07eb"; -- RW, Calibration Result Registers - Channel 250

constant Q_OFS_251_ADDR         : std_logic_vector(15 downto 0) := X"07ec"; -- RW, Calibration Result Registers - Channel 251
constant Q_OSACLK_251_ADDR      : std_logic_vector(15 downto 0) := X"07ed"; -- RW, Calibration Result Registers - Channel 251
constant LIN_CAL_QP1_251_ADDR   : std_logic_vector(15 downto 0) := X"07ee"; -- RW, Calibration Result Registers - Channel 251
constant LIN_CAL_QP2_251_ADDR   : std_logic_vector(15 downto 0) := X"07ef"; -- RW, Calibration Result Registers - Channel 251

constant Q_OFS_252_ADDR         : std_logic_vector(15 downto 0) := X"07f0"; -- RW, Calibration Result Registers - Channel 252
constant Q_OSACLK_252_ADDR      : std_logic_vector(15 downto 0) := X"07f1"; -- RW, Calibration Result Registers - Channel 252
constant LIN_CAL_QP1_252_ADDR   : std_logic_vector(15 downto 0) := X"07f2"; -- RW, Calibration Result Registers - Channel 252
constant LIN_CAL_QP2_252_ADDR   : std_logic_vector(15 downto 0) := X"07f3"; -- RW, Calibration Result Registers - Channel 252

constant Q_OFS_253_ADDR         : std_logic_vector(15 downto 0) := X"07f4"; -- RW, Calibration Result Registers - Channel 253
constant Q_OSACLK_253_ADDR      : std_logic_vector(15 downto 0) := X"07f5"; -- RW, Calibration Result Registers - Channel 253
constant LIN_CAL_QP1_253_ADDR   : std_logic_vector(15 downto 0) := X"07f6"; -- RW, Calibration Result Registers - Channel 253
constant LIN_CAL_QP2_253_ADDR   : std_logic_vector(15 downto 0) := X"07f7"; -- RW, Calibration Result Registers - Channel 253

constant Q_OFS_254_ADDR         : std_logic_vector(15 downto 0) := X"07f8"; -- RW, Calibration Result Registers - Channel 254
constant Q_OSACLK_254_ADDR      : std_logic_vector(15 downto 0) := X"07f9"; -- RW, Calibration Result Registers - Channel 254
constant LIN_CAL_QP1_254_ADDR   : std_logic_vector(15 downto 0) := X"07fa"; -- RW, Calibration Result Registers - Channel 254
constant LIN_CAL_QP2_254_ADDR   : std_logic_vector(15 downto 0) := X"07fb"; -- RW, Calibration Result Registers - Channel 254

constant Q_OFS_255_ADDR         : std_logic_vector(15 downto 0) := X"07fc"; -- RW, Calibration Result Registers - Channel 255
constant Q_OSACLK_255_ADDR      : std_logic_vector(15 downto 0) := X"07fd"; -- RW, Calibration Result Registers - Channel 255
constant LIN_CAL_QP1_255_ADDR   : std_logic_vector(15 downto 0) := X"07fe"; -- RW, Calibration Result Registers - Channel 255
constant LIN_CAL_QP2_255_ADDR   : std_logic_vector(15 downto 0) := X"07ff"; -- RW, Calibration Result Registers - Channel 255

--Array Delta Calibration Result Registers

constant ARRAY_DELTA_0_ADDR 	 : std_logic_vector(15 downto 0) := X"0800"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_1_ADDR 	 : std_logic_vector(15 downto 0) := X"0801"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_2_ADDR 	 : std_logic_vector(15 downto 0) := X"0802"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_3_ADDR 	 : std_logic_vector(15 downto 0) := X"0803"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_4_ADDR 	 : std_logic_vector(15 downto 0) := X"0804"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_5_ADDR 	 : std_logic_vector(15 downto 0) := X"0805"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_6_ADDR 	 : std_logic_vector(15 downto 0) := X"0806"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_7_ADDR 	 : std_logic_vector(15 downto 0) := X"0807"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_8_ADDR 	 : std_logic_vector(15 downto 0) := X"0808"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_9_ADDR 	 : std_logic_vector(15 downto 0) := X"0809"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_10_ADDR 	 : std_logic_vector(15 downto 0) := X"080a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_11_ADDR 	 : std_logic_vector(15 downto 0) := X"080b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_12_ADDR 	 : std_logic_vector(15 downto 0) := X"080c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_13_ADDR 	 : std_logic_vector(15 downto 0) := X"080d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_14_ADDR 	 : std_logic_vector(15 downto 0) := X"080e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_15_ADDR 	 : std_logic_vector(15 downto 0) := X"080f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_16_ADDR 	 : std_logic_vector(15 downto 0) := X"0810"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_17_ADDR 	 : std_logic_vector(15 downto 0) := X"0811"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_18_ADDR 	 : std_logic_vector(15 downto 0) := X"0812"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_19_ADDR 	 : std_logic_vector(15 downto 0) := X"0813"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_20_ADDR 	 : std_logic_vector(15 downto 0) := X"0814"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_21_ADDR 	 : std_logic_vector(15 downto 0) := X"0815"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_22_ADDR 	 : std_logic_vector(15 downto 0) := X"0816"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_23_ADDR 	 : std_logic_vector(15 downto 0) := X"0817"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_24_ADDR 	 : std_logic_vector(15 downto 0) := X"0818"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_25_ADDR 	 : std_logic_vector(15 downto 0) := X"0819"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_26_ADDR 	 : std_logic_vector(15 downto 0) := X"081a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_27_ADDR 	 : std_logic_vector(15 downto 0) := X"081b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_28_ADDR 	 : std_logic_vector(15 downto 0) := X"081c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_29_ADDR 	 : std_logic_vector(15 downto 0) := X"081d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_30_ADDR 	 : std_logic_vector(15 downto 0) := X"081e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_31_ADDR 	 : std_logic_vector(15 downto 0) := X"081f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_32_ADDR 	 : std_logic_vector(15 downto 0) := X"0820"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_33_ADDR 	 : std_logic_vector(15 downto 0) := X"0821"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_34_ADDR 	 : std_logic_vector(15 downto 0) := X"0822"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_35_ADDR 	 : std_logic_vector(15 downto 0) := X"0823"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_36_ADDR 	 : std_logic_vector(15 downto 0) := X"0824"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_37_ADDR 	 : std_logic_vector(15 downto 0) := X"0825"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_38_ADDR 	 : std_logic_vector(15 downto 0) := X"0826"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_39_ADDR 	 : std_logic_vector(15 downto 0) := X"0827"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_40_ADDR 	 : std_logic_vector(15 downto 0) := X"0828"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_41_ADDR 	 : std_logic_vector(15 downto 0) := X"0829"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_42_ADDR 	 : std_logic_vector(15 downto 0) := X"082a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_43_ADDR 	 : std_logic_vector(15 downto 0) := X"082b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_44_ADDR 	 : std_logic_vector(15 downto 0) := X"082c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_45_ADDR 	 : std_logic_vector(15 downto 0) := X"082d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_46_ADDR 	 : std_logic_vector(15 downto 0) := X"082e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_47_ADDR 	 : std_logic_vector(15 downto 0) := X"082f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_48_ADDR 	 : std_logic_vector(15 downto 0) := X"0830"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_49_ADDR 	 : std_logic_vector(15 downto 0) := X"0831"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_50_ADDR 	 : std_logic_vector(15 downto 0) := X"0832"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_51_ADDR 	 : std_logic_vector(15 downto 0) := X"0833"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_52_ADDR 	 : std_logic_vector(15 downto 0) := X"0834"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_53_ADDR 	 : std_logic_vector(15 downto 0) := X"0835"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_54_ADDR 	 : std_logic_vector(15 downto 0) := X"0836"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_55_ADDR 	 : std_logic_vector(15 downto 0) := X"0837"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_56_ADDR 	 : std_logic_vector(15 downto 0) := X"0838"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_57_ADDR 	 : std_logic_vector(15 downto 0) := X"0839"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_58_ADDR 	 : std_logic_vector(15 downto 0) := X"083a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_59_ADDR 	 : std_logic_vector(15 downto 0) := X"083b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_60_ADDR 	 : std_logic_vector(15 downto 0) := X"083c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_61_ADDR 	 : std_logic_vector(15 downto 0) := X"083d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_62_ADDR 	 : std_logic_vector(15 downto 0) := X"083e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_63_ADDR 	 : std_logic_vector(15 downto 0) := X"083f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_64_ADDR 	 : std_logic_vector(15 downto 0) := X"0840"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_65_ADDR 	 : std_logic_vector(15 downto 0) := X"0841"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_66_ADDR 	 : std_logic_vector(15 downto 0) := X"0842"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_67_ADDR 	 : std_logic_vector(15 downto 0) := X"0843"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_68_ADDR 	 : std_logic_vector(15 downto 0) := X"0844"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_69_ADDR 	 : std_logic_vector(15 downto 0) := X"0845"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_70_ADDR 	 : std_logic_vector(15 downto 0) := X"0846"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_71_ADDR 	 : std_logic_vector(15 downto 0) := X"0847"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_72_ADDR 	 : std_logic_vector(15 downto 0) := X"0848"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_73_ADDR 	 : std_logic_vector(15 downto 0) := X"0849"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_74_ADDR 	 : std_logic_vector(15 downto 0) := X"084a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_75_ADDR 	 : std_logic_vector(15 downto 0) := X"084b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_76_ADDR 	 : std_logic_vector(15 downto 0) := X"084c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_77_ADDR 	 : std_logic_vector(15 downto 0) := X"084d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_78_ADDR 	 : std_logic_vector(15 downto 0) := X"084e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_79_ADDR 	 : std_logic_vector(15 downto 0) := X"084f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_80_ADDR 	 : std_logic_vector(15 downto 0) := X"0850"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_81_ADDR 	 : std_logic_vector(15 downto 0) := X"0851"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_82_ADDR 	 : std_logic_vector(15 downto 0) := X"0852"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_83_ADDR 	 : std_logic_vector(15 downto 0) := X"0853"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_84_ADDR 	 : std_logic_vector(15 downto 0) := X"0854"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_85_ADDR 	 : std_logic_vector(15 downto 0) := X"0855"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_86_ADDR 	 : std_logic_vector(15 downto 0) := X"0856"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_87_ADDR 	 : std_logic_vector(15 downto 0) := X"0857"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_88_ADDR 	 : std_logic_vector(15 downto 0) := X"0858"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_89_ADDR 	 : std_logic_vector(15 downto 0) := X"0859"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_90_ADDR 	 : std_logic_vector(15 downto 0) := X"085a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_91_ADDR 	 : std_logic_vector(15 downto 0) := X"085b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_92_ADDR 	 : std_logic_vector(15 downto 0) := X"085c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_93_ADDR 	 : std_logic_vector(15 downto 0) := X"085d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_94_ADDR 	 : std_logic_vector(15 downto 0) := X"085e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_95_ADDR 	 : std_logic_vector(15 downto 0) := X"085f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_96_ADDR 	 : std_logic_vector(15 downto 0) := X"0860"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_97_ADDR 	 : std_logic_vector(15 downto 0) := X"0861"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_98_ADDR 	 : std_logic_vector(15 downto 0) := X"0862"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_99_ADDR 	 : std_logic_vector(15 downto 0) := X"0863"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_100_ADDR	 : std_logic_vector(15 downto 0) := X"0864"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_101_ADDR	 : std_logic_vector(15 downto 0) := X"0865"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_102_ADDR	 : std_logic_vector(15 downto 0) := X"0866"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_103_ADDR	 : std_logic_vector(15 downto 0) := X"0867"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_104_ADDR	 : std_logic_vector(15 downto 0) := X"0868"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_105_ADDR	 : std_logic_vector(15 downto 0) := X"0869"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_106_ADDR	 : std_logic_vector(15 downto 0) := X"086a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_107_ADDR	 : std_logic_vector(15 downto 0) := X"086b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_108_ADDR	 : std_logic_vector(15 downto 0) := X"086c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_109_ADDR	 : std_logic_vector(15 downto 0) := X"086d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_110_ADDR	 : std_logic_vector(15 downto 0) := X"086e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_111_ADDR	 : std_logic_vector(15 downto 0) := X"086f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_112_ADDR	 : std_logic_vector(15 downto 0) := X"0870"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_113_ADDR	 : std_logic_vector(15 downto 0) := X"0871"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_114_ADDR	 : std_logic_vector(15 downto 0) := X"0872"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_115_ADDR	 : std_logic_vector(15 downto 0) := X"0873"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_116_ADDR	 : std_logic_vector(15 downto 0) := X"0874"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_117_ADDR	 : std_logic_vector(15 downto 0) := X"0875"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_118_ADDR	 : std_logic_vector(15 downto 0) := X"0876"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_119_ADDR	 : std_logic_vector(15 downto 0) := X"0877"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_120_ADDR	 : std_logic_vector(15 downto 0) := X"0878"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_121_ADDR	 : std_logic_vector(15 downto 0) := X"0879"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_122_ADDR	 : std_logic_vector(15 downto 0) := X"087a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_123_ADDR	 : std_logic_vector(15 downto 0) := X"087b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_124_ADDR	 : std_logic_vector(15 downto 0) := X"087c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_125_ADDR	 : std_logic_vector(15 downto 0) := X"087d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_126_ADDR	 : std_logic_vector(15 downto 0) := X"087e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_127_ADDR	 : std_logic_vector(15 downto 0) := X"087f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_128_ADDR	 : std_logic_vector(15 downto 0) := X"0880"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_129_ADDR	 : std_logic_vector(15 downto 0) := X"0881"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_130_ADDR	 : std_logic_vector(15 downto 0) := X"0882"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_131_ADDR	 : std_logic_vector(15 downto 0) := X"0883"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_132_ADDR	 : std_logic_vector(15 downto 0) := X"0884"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_133_ADDR	 : std_logic_vector(15 downto 0) := X"0885"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_134_ADDR	 : std_logic_vector(15 downto 0) := X"0886"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_135_ADDR	 : std_logic_vector(15 downto 0) := X"0887"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_136_ADDR	 : std_logic_vector(15 downto 0) := X"0888"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_137_ADDR	 : std_logic_vector(15 downto 0) := X"0889"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_138_ADDR	 : std_logic_vector(15 downto 0) := X"088a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_139_ADDR	 : std_logic_vector(15 downto 0) := X"088b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_140_ADDR	 : std_logic_vector(15 downto 0) := X"088c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_141_ADDR	 : std_logic_vector(15 downto 0) := X"088d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_142_ADDR	 : std_logic_vector(15 downto 0) := X"088e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_143_ADDR	 : std_logic_vector(15 downto 0) := X"088f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_144_ADDR	 : std_logic_vector(15 downto 0) := X"0890"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_145_ADDR	 : std_logic_vector(15 downto 0) := X"0891"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_146_ADDR	 : std_logic_vector(15 downto 0) := X"0892"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_147_ADDR	 : std_logic_vector(15 downto 0) := X"0893"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_148_ADDR	 : std_logic_vector(15 downto 0) := X"0894"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_149_ADDR	 : std_logic_vector(15 downto 0) := X"0895"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_150_ADDR	 : std_logic_vector(15 downto 0) := X"0896"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_151_ADDR	 : std_logic_vector(15 downto 0) := X"0897"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_152_ADDR	 : std_logic_vector(15 downto 0) := X"0898"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_153_ADDR	 : std_logic_vector(15 downto 0) := X"0899"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_154_ADDR	 : std_logic_vector(15 downto 0) := X"089a"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_155_ADDR	 : std_logic_vector(15 downto 0) := X"089b"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_156_ADDR	 : std_logic_vector(15 downto 0) := X"089c"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_157_ADDR	 : std_logic_vector(15 downto 0) := X"089d"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_158_ADDR	 : std_logic_vector(15 downto 0) := X"089e"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_159_ADDR	 : std_logic_vector(15 downto 0) := X"089f"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_160_ADDR	 : std_logic_vector(15 downto 0) := X"08a0"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_161_ADDR	 : std_logic_vector(15 downto 0) := X"08a1"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_162_ADDR	 : std_logic_vector(15 downto 0) := X"08a2"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_163_ADDR	 : std_logic_vector(15 downto 0) := X"08a3"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_164_ADDR	 : std_logic_vector(15 downto 0) := X"08a4"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_165_ADDR	 : std_logic_vector(15 downto 0) := X"08a5"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_166_ADDR	 : std_logic_vector(15 downto 0) := X"08a6"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_167_ADDR	 : std_logic_vector(15 downto 0) := X"08a7"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_168_ADDR	 : std_logic_vector(15 downto 0) := X"08a8"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_169_ADDR	 : std_logic_vector(15 downto 0) := X"08a9"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_170_ADDR	 : std_logic_vector(15 downto 0) := X"08aa"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_171_ADDR	 : std_logic_vector(15 downto 0) := X"08ab"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_172_ADDR	 : std_logic_vector(15 downto 0) := X"08ac"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_173_ADDR	 : std_logic_vector(15 downto 0) := X"08ad"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_174_ADDR	 : std_logic_vector(15 downto 0) := X"08ae"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_175_ADDR	 : std_logic_vector(15 downto 0) := X"08af"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_176_ADDR	 : std_logic_vector(15 downto 0) := X"08b0"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_177_ADDR	 : std_logic_vector(15 downto 0) := X"08b1"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_178_ADDR	 : std_logic_vector(15 downto 0) := X"08b2"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_179_ADDR	 : std_logic_vector(15 downto 0) := X"08b3"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_180_ADDR	 : std_logic_vector(15 downto 0) := X"08b4"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_181_ADDR	 : std_logic_vector(15 downto 0) := X"08b5"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_182_ADDR	 : std_logic_vector(15 downto 0) := X"08b6"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_183_ADDR	 : std_logic_vector(15 downto 0) := X"08b7"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_184_ADDR	 : std_logic_vector(15 downto 0) := X"08b8"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_185_ADDR	 : std_logic_vector(15 downto 0) := X"08b9"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_186_ADDR	 : std_logic_vector(15 downto 0) := X"08ba"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_187_ADDR	 : std_logic_vector(15 downto 0) := X"08bb"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_188_ADDR	 : std_logic_vector(15 downto 0) := X"08bc"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_189_ADDR	 : std_logic_vector(15 downto 0) := X"08bd"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_190_ADDR	 : std_logic_vector(15 downto 0) := X"08be"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_191_ADDR	 : std_logic_vector(15 downto 0) := X"08bf"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_192_ADDR	 : std_logic_vector(15 downto 0) := X"08c0"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_193_ADDR	 : std_logic_vector(15 downto 0) := X"08c1"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_194_ADDR	 : std_logic_vector(15 downto 0) := X"08c2"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_195_ADDR	 : std_logic_vector(15 downto 0) := X"08c3"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_196_ADDR	 : std_logic_vector(15 downto 0) := X"08c4"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_197_ADDR	 : std_logic_vector(15 downto 0) := X"08c5"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_198_ADDR	 : std_logic_vector(15 downto 0) := X"08c6"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_199_ADDR	 : std_logic_vector(15 downto 0) := X"08c7"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_200_ADDR	 : std_logic_vector(15 downto 0) := X"08c8"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_201_ADDR	 : std_logic_vector(15 downto 0) := X"08c9"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_202_ADDR	 : std_logic_vector(15 downto 0) := X"08ca"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_203_ADDR	 : std_logic_vector(15 downto 0) := X"08cb"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_204_ADDR	 : std_logic_vector(15 downto 0) := X"08cc"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_205_ADDR	 : std_logic_vector(15 downto 0) := X"08cd"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_206_ADDR	 : std_logic_vector(15 downto 0) := X"08ce"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_207_ADDR	 : std_logic_vector(15 downto 0) := X"08cf"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_208_ADDR	 : std_logic_vector(15 downto 0) := X"08d0"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_209_ADDR	 : std_logic_vector(15 downto 0) := X"08d1"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_210_ADDR	 : std_logic_vector(15 downto 0) := X"08d2"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_211_ADDR	 : std_logic_vector(15 downto 0) := X"08d3"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_212_ADDR	 : std_logic_vector(15 downto 0) := X"08d4"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_213_ADDR	 : std_logic_vector(15 downto 0) := X"08d5"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_214_ADDR	 : std_logic_vector(15 downto 0) := X"08d6"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_215_ADDR	 : std_logic_vector(15 downto 0) := X"08d7"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_216_ADDR	 : std_logic_vector(15 downto 0) := X"08d8"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_217_ADDR	 : std_logic_vector(15 downto 0) := X"08d9"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_218_ADDR	 : std_logic_vector(15 downto 0) := X"08da"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_219_ADDR	 : std_logic_vector(15 downto 0) := X"08db"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_220_ADDR	 : std_logic_vector(15 downto 0) := X"08dc"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_221_ADDR	 : std_logic_vector(15 downto 0) := X"08dd"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_222_ADDR	 : std_logic_vector(15 downto 0) := X"08de"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_223_ADDR	 : std_logic_vector(15 downto 0) := X"08df"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_224_ADDR	 : std_logic_vector(15 downto 0) := X"08e0"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_225_ADDR	 : std_logic_vector(15 downto 0) := X"08e1"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_226_ADDR	 : std_logic_vector(15 downto 0) := X"08e2"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_227_ADDR	 : std_logic_vector(15 downto 0) := X"08e3"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_228_ADDR	 : std_logic_vector(15 downto 0) := X"08e4"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_229_ADDR	 : std_logic_vector(15 downto 0) := X"08e5"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_230_ADDR	 : std_logic_vector(15 downto 0) := X"08e6"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_231_ADDR	 : std_logic_vector(15 downto 0) := X"08e7"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_232_ADDR	 : std_logic_vector(15 downto 0) := X"08e8"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_233_ADDR	 : std_logic_vector(15 downto 0) := X"08e9"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_234_ADDR	 : std_logic_vector(15 downto 0) := X"08ea"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_235_ADDR	 : std_logic_vector(15 downto 0) := X"08eb"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_236_ADDR	 : std_logic_vector(15 downto 0) := X"08ec"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_237_ADDR	 : std_logic_vector(15 downto 0) := X"08ed"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_238_ADDR	 : std_logic_vector(15 downto 0) := X"08ee"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_239_ADDR	 : std_logic_vector(15 downto 0) := X"08ef"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_240_ADDR	 : std_logic_vector(15 downto 0) := X"08f0"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_241_ADDR	 : std_logic_vector(15 downto 0) := X"08f1"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_242_ADDR	 : std_logic_vector(15 downto 0) := X"08f2"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_243_ADDR	 : std_logic_vector(15 downto 0) := X"08f3"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_244_ADDR	 : std_logic_vector(15 downto 0) := X"08f4"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_245_ADDR	 : std_logic_vector(15 downto 0) := X"08f5"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_246_ADDR	 : std_logic_vector(15 downto 0) := X"08f6"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_247_ADDR	 : std_logic_vector(15 downto 0) := X"08f7"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_248_ADDR	 : std_logic_vector(15 downto 0) := X"08f8"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_249_ADDR	 : std_logic_vector(15 downto 0) := X"08f9"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_250_ADDR	 : std_logic_vector(15 downto 0) := X"08fa"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_251_ADDR	 : std_logic_vector(15 downto 0) := X"08fb"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_252_ADDR	 : std_logic_vector(15 downto 0) := X"08fc"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_253_ADDR	 : std_logic_vector(15 downto 0) := X"08fd"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_254_ADDR	 : std_logic_vector(15 downto 0) := X"08fe"; -- RW, Array Delta Result Registers
constant ARRAY_DELTA_255_ADDR	 : std_logic_vector(15 downto 0) := X"08ff"; -- RW, Array Delta Result Registers


--OTP - One Time Programmable Memory
--0x0900 to 0x0942  OTP  RW - Do not overwrite register, for AMS only


end AMS_pack;
