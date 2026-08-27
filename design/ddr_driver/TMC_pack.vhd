-- Ran Finsterbush 22-2-2005
--
-- This package is intended for the Peripheral FPGA
-- Of the Anthem Ovation project.
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
-- use IEEE.STD_LOGIC_ARITH.all;
use IEEE.NUMERIC_STD.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
----------------------------------------------------------------------------

----------------------------------------------------------------------------
package TMC_pack is

-----------------------------------------------------------------------------
	CONSTANT MY_VERSION_NUMBER	: std_logic_vector(15 DOWNTO 0) := X"9804"; -- PERIPH FIRMWARE VERSION NUMBER--8921
		
-------------------------------- GENERAL  -----------------------------------
	CONSTANT CLK_64MHZ_PERIOD 		: time := 15.625 ns;
	CONSTANT MIN_INTEGRATION_PERIOD : integer := 6200; -- Clocks 64 MHz         96.875 us
	
	TYPE   header_type IS ARRAY (3 downto 0) of std_logic_vector(31 downto 0); 
	
	TYPE INTEGER_ARRAY_TYPE IS ARRAY(INTEGER RANGE <>) OF INTEGER;
	TYPE BOOLEAN_ARRAY_TYPE IS ARRAY(INTEGER RANGE <>) OF BOOLEAN;
	TYPE BYTE_ARRAY_TYPE IS ARRAY(INTEGER RANGE <>) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
	TYPE WORD_ARRAY_TYPE IS ARRAY(INTEGER RANGE <>) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
	TYPE DWORD_ARRAY_TYPE IS ARRAY(INTEGER RANGE <>) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL VCC							: STD_LOGIC := '1';
	SIGNAL GND							: STD_LOGIC := '0';
	
	SIGNAL GND2							: STD_LOGIC_VECTOR(1 downto 0) := "00";
	SIGNAL GND11						: STD_LOGIC_VECTOR(10 downto 0) := "000" & X"00";
	
	CONSTANT DATA_TO_PERIPH_IP_DELAY	: natural := 3;
	
-- LOCAL_HEADER
	CONSTANT READING_NUM_LOC_H		 	: natural := 63;
	CONSTANT READING_NUM_LOC_L 			: natural := 40;
	CONSTANT SHOT_NUM_LOC_H		 		: natural := 39;
	CONSTANT SHOT_NUM_LOC_L 			: natural := 32;
	CONSTANT NUMBER_OF_SLICES_LOC_H		: natural := 31;
	CONSTANT NUMBER_OF_SLICES_LOC_L		: natural := 24;
	CONSTANT BYTES_PER_DETECTOR_LOC_H 	: natural := 23;
	CONSTANT BYTES_PER_DETECTOR_LOC_L 	: natural := 21;
	CONSTANT READING_TYPE_LOC_H		 	: natural := 20;
	CONSTANT READING_TYPE_LOC_L 		: natural := 19;
	CONSTANT MAKE_DATA_LOC			 	: natural := 18;
	CONSTANT SETUP_VALID_LOC		 	: natural := 17;
	CONSTANT TMC_CRC_ERROR_LOC		 	: natural := 16;
	CONSTANT ECC_ERROR_LOC		 		: natural := 15;
	CONSTANT SLICE_MERGE_LOC_H		 	: natural := 14;
	CONSTANT SLICE_MERGE_LOC_L 			: natural := 13;
	CONSTANT FS_MERGE_LOC_H		 		: natural := 12;
	CONSTANT FS_MERGE_LOC_L 			: natural := 11;
	CONSTANT RESERVED_BITS_LOC_H		: natural := 10;
	CONSTANT RESERVED_BITS_LOC_L 		: natural := 0;
	
	CONSTANT HEADER_DEFAULT				: std_logic_vector(63 downto 0) := X"000000" & X"00" & X"40" &
																		   "010" & "00" & '0' & '0' & '0' & '0' & "10" & "10" & "00000000000";
	
-- LOCO_HEADER
	CONSTANT LH_PACKET_NUMBER_H		 	: natural := 63;
	CONSTANT LH_PACKET_NUMBER_L 		: natural := 60;
	CONSTANT LH_PACKET_PER_READING_H	: natural := 59;
	CONSTANT LH_PACKET_PER_READING_L	: natural := 56;
	CONSTANT LH_NUMBER_OF_SLICES_LOC_H	: natural := 55;
	CONSTANT LH_NUMBER_OF_SLICES_LOC_L	: natural := 48;
	CONSTANT LH_BUFFER_WRITTEN_L		: natural := 47;
	CONSTANT LH_BUFFER_FULL_L			: natural := 46;
	CONSTANT LH_COMPRESSED_READING		: natural := 45;
	CONSTANT LH_RESERVED_BITS_LOC_H		: natural := 44;
	CONSTANT LH_RESERVED_BITS_LOC_L 	: natural := 32;
	CONSTANT LH_MARKER_H				: natural := 31;
	CONSTANT LH_MARKER_L			 	: natural := 0;
	
	CONSTANT LOCO_HEADER_MARKER			: STD_LOGIC_VECTOR(31 downto 0) := X"01234567";
	CONSTANT LOCO_HEADER_DEFAULT		: std_logic_vector(63 downto 0) := X"1" & X"1" & X"40" & '0' & '0' & '0' & '0' & X"000" & LOCO_HEADER_MARKER;

-- LOCO_FOOTER
	CONSTANT LF_CRC_H					: natural := 63;
	CONSTANT LF_CRC_L			 		: natural := 48;
	CONSTANT LF_RESERVED_BITS_LOC_H		: natural := 47;
	CONSTANT LF_RESERVED_BITS_LOC_L 	: natural := 32;
	CONSTANT LF_MARKER_H				: natural := 31;
	CONSTANT LF_MARKER_L 				: natural := 0;

	CONSTANT LOCO_FOOTER_MARKER			: STD_LOGIC_VECTOR(31 downto 0) := X"FEDCBA98";
----------------------------------------------------------------------------
-- MOSAIC CTL SIGNAL DEFINITIONS
	CONSTANT MOSAIC_IDLE				: STD_LOGIC_VECTOR(1 downto 0) := "00";
	CONSTANT MOSAIC_XFR					: STD_LOGIC_VECTOR(1 downto 0) := "01";
	CONSTANT MOSAIC_CRST				: STD_LOGIC_VECTOR(1 downto 0) := "10";
	CONSTANT MOSAIC_RST					: STD_LOGIC_VECTOR(1 downto 0) := "11";
	
-- TMC REGISTERS ADDRESSES
--------------------------- TMC REGISTER MAP ------------------------------
	CONSTANT TMC_FIRMWARE_REVISION_ADDR			: integer := 16#200#;
	CONSTANT TMC_HARDWARE_BOARD_REVISION_ADDR	: integer := 16#201#;--TMC addresses registers
	CONSTANT TMC_NUMBER_OF_SLICES_REG_ADDR 		: NATURAL := 16#202#;
	CONSTANT TMC_TEMPERATURE_SENSOR_ADDR		: integer := 16#203#;
	CONSTANT TMC_TEST_PATTERNS_ADDR				: integer := 16#204#;
	CONSTANT TMC_TMC_ERRORS_ADDR				: integer := 16#205#;
	CONSTANT TMC_SYSTEM_DIAGNOSTICS_ADDR		: integer := 16#206#;
	CONSTANT TMC_BYTES_PER_DETECTOR_REG_ADDR 	: NATURAL := 16#207#;
		
	CONSTANT RESERVED1						 	: NATURAL := 16#208#;
	CONSTANT RESERVED2						 	: NATURAL := 16#209#;
	CONSTANT RESERVED3						 	: NATURAL := 16#20A#;
	CONSTANT RESERVED4						 	: NATURAL := 16#20B#;
	CONSTANT RESERVED5						 	: NATURAL := 16#20C#;
	CONSTANT RESERVED6						 	: NATURAL := 16#20D#;
	CONSTANT RESERVED7						 	: NATURAL := 16#20E#;
	CONSTANT RESERVED8						 	: NATURAL := 16#20F#;
	CONSTANT TMC_DATA_ERR_1					 	: NATURAL := 16#210#;
	CONSTANT TMC_DATA_ERR_2						: NATURAL := 16#211#;
	CONSTANT TMC_DATA_ERR_3					 	: NATURAL := 16#212#;
	CONSTANT TMC_DATA_ERR_4					 	: NATURAL := 16#213#;
	CONSTANT TMC_DATA_ERR_5					 	: NATURAL := 16#214#;
	CONSTANT TMC_DATA_ERR_6					 	: NATURAL := 16#215#;
	CONSTANT TMC_DATA_ERR_7					 	: NATURAL := 16#216#;
	CONSTANT TMC_DATA_ERR_8					 	: NATURAL := 16#217#;
	CONSTANT RESERVED9						 	: NATURAL := 16#218#;
	CONSTANT RESERVED10						 	: NATURAL := 16#219#;
	CONSTANT RESERVED11						 	: NATURAL := 16#21A#;
	CONSTANT RESERVED12						 	: NATURAL := 16#21B#;
	CONSTANT RESERVED13						 	: NATURAL := 16#21C#;
	CONSTANT RESERVED14						 	: NATURAL := 16#21D#;
	CONSTANT RESERVED15						 	: NATURAL := 16#21E#;
	CONSTANT RESERVED16						 	: NATURAL := 16#21F#;
	
	CONSTANT TMC_X_SECTOR				: INTEGER RANGE 0 TO 31 := 16;
	
	CONSTANT REGBUS_END_COMMAND			: STD_LOGIC_VECTOR(7 downto 0) := X"FF";
	
-- GENERAL SCAN PARAMETERS
	CONSTANT BYTES_PER_DETECTOR_16		: STD_LOGIC_VECTOR(2 downto 0) := "010";
	CONSTANT BYTES_PER_DETECTOR_24		: STD_LOGIC_VECTOR(2 downto 0) := "011";
	CONSTANT BYTES_PER_DETECTOR_48		: STD_LOGIC_VECTOR(2 downto 0) := "110";
	CONSTANT DATA_REPRESENTATION_DEFAULT : STD_LOGIC_VECTOR(2 downto 0) := BYTES_PER_DETECTOR_16;
	CONSTANT NUMBER_OF_SLICES_DEFAULT 	: STD_LOGIC_VECTOR(7 downto 0) := STD_LOGIC_VECTOR( TO_UNSIGNED(64, 8) );
	
	CONSTANT TMC_PER_PERIPH				: integer := 4;

	CONSTANT IPS_PER_BIAS				: integer := 8;
	
-- LOCAL HEADER PARAMETERS
	CONSTANT RAW_READING_TYPE			: STD_LOGIC_VECTOR(1 downto 0) := "00";
	CONSTANT EV_READING_TYPE			: STD_LOGIC_VECTOR(1 downto 0) := "01";
	CONSTANT OFFSET_READING_TYPE		: STD_LOGIC_VECTOR(1 downto 0) := "10";
	
-- TMC_INTERFACE
	CONSTANT HUNDRED_US_AT64M			: natural := 100*64;
	CONSTANT FIFTY_US_AT64M				: natural := 50*64;

-- DATA_SORTER
	CONSTANT LOCAL_HEADER_SIZE			: integer := 64/32;
	CONSTANT BYTE_BLOCK_OFFSET			: integer := 512;
	CONSTANT PRE_FRAME_START_TO_DATA_DELAY : integer := 7;
																		
-- CENTRAL_INTERFACE
	CONSTANT SYNC_DATA 					: STD_LOGIC_VECTOR(31 downto 0) := X"BCBCBCBC";
	CONSTANT SYNCN_DATA 				: STD_LOGIC_VECTOR(31 downto 0) := X"43434343";
	CONSTANT SLICE_DATA_START			: STD_LOGIC_VECTOR(31 downto 0) := X"1C1C1C1C";
	CONSTANT SLICE_DATA_END				: STD_LOGIC_VECTOR(31 downto 0) := X"5C5C5C5C";
	
	CONSTANT FAN_SIZE					: natural := 672;
	
----------------------------------------------------------------------------

	CONSTANT PORT_DATA_BUS_WIDTH		: POSITIVE := 16;	
	CONSTANT REG_BANK_WIDTH				: POSITIVE := 16;
	CONSTANT PORT_BUS_DEPTH				: POSITIVE := 12;
	
	SUBTYPE REGISTER_BANK_TYPE IS WORD_ARRAY_TYPE;
		
	CONSTANT PERIPH2TMC_CTRL_WR_RD_N		: integer := 0;
	CONSTANT PERIPH2TMC_CTRL_PAYLOAD_SIZE_L	: integer := 7;
	CONSTANT PERIPH2TMC_CTRL_PAYLOAD_SIZE_H	: integer := 14;
	CONSTANT PERIPH2TMC_CTRL_ADDRESS_L		: integer := 15;
	CONSTANT PERIPH2TMC_CTRL_ADDRESS_H		: integer := 26;
	CONSTANT PERIPH2TMC_CTRL_DATA_L			: integer := 31;

	CONSTANT TMC2PERIPH_CTRL_ACK			: integer := 0;
	CONSTANT TMC2PERIPH_CTRL_TX_CRC_INTR	: integer := 2;
	CONSTANT TMC2PERIPH_CTRL_RESERVED_L		: integer := 3;
	CONSTANT TMC2PERIPH_CTRL_RESERVED_H		: integer := 7;
	CONSTANT TMC2PERIPH_CTRL_PAYLOAD_SIZE_L	: integer := 8;
	CONSTANT TMC2PERIPH_CTRL_PAYLOAD_SIZE_H	: integer := 15;
	CONSTANT TMC2PERIPH_CTRL_ADDRESS_L		: integer := 16;
	CONSTANT TMC2PERIPH_CTRL_ADDRESS_H		: integer := 27;
	CONSTANT TMC2PERIPH_CTRL_DATA_L			: integer := 36;
	
	CONSTANT DOM_INFO_TMC_CRC_ERROR_BIT		: integer := 2;
	CONSTANT DOM_INFO_SETUP_VALID_BIT		: integer := 1;
	CONSTANT DOM_INFO_MAKE_DATA_BIT			: integer := 0;
----------------------------------------------------------------------------
     
	CONSTANT MEM_ADDR_BUS_WIDTH			: POSITIVE := 27;

----------------------------------------------------------------------------
-- Internal Definitions -- Ran

	CONSTANT	RESET_POLARITY 					: STD_LOGIC := '0';
	CONSTANT	DATA_EN_POLARITY				: STD_LOGIC := '1';
	CONSTANT	LOCAL_REGBUS_WRITE_EN_POLARITY	: STD_LOGIC := '0';
	CONSTANT	LOCAL_BUS_CS_POLARITY			: STD_LOGIC := '0';

-------------------------------------------------------------------------------
------------------------------- REGISTER MAP ----------------------------------

	CONSTANT ALL_PERIPH_BROADCAST				: STD_LOGIC_VECTOR(3 downto 0) := X"F";
	CONSTANT ALL_PERIPH_BROADCAST_INT			: INTEGER := TO_INTEGER( UNSIGNED( ALL_PERIPH_BROADCAST ) );
	CONSTANT ALL_TMC_BROADCAST					: STD_LOGIC_VECTOR(3 downto 0) := X"5";

-- Regions:
	CONSTANT LOCAL_CONTROLLER_BOTTOM_ADDR		: NATURAL := 16#0#;
	CONSTANT LOCAL_CONTROLLER_TOP_ADDR			: NATURAL := 16#3F#;
	CONSTANT EVOLVING_BOTTOM_ADDR				: NATURAL := 16#40#;
	CONSTANT EVOLVING_TOP_ADDR					: NATURAL := 16#5F#;
	CONSTANT TMC_INTERFACE_BOTTOM_ADDR			: NATURAL := 16#60#;
	CONSTANT TMC_INTERFACE_TOP_ADDR				: NATURAL := 16#8F#;
	CONSTANT CENTRAL_INTERFACE_BOTTOM_ADDR		: NATURAL := 16#90#;
	CONSTANT CENTRAL_INTERFACE_TOP_ADDR			: NATURAL := 16#9F#;
	CONSTANT BUFFER_CONTROL_BOTTOM_ADDR			: NATURAL := 16#A0#;
	CONSTANT BUFFER_CONTROL_TOP_ADDR			: NATURAL := 16#FF#;
	CONSTANT TMC_CONTROL_REGS_BOTTOM_ADDR		: NATURAL := 16#100#;
	CONSTANT TMC_CONTROL_REGS_TOP_ADDR			: NATURAL := 16#1FF#;
	CONSTANT TMC_CONTROL_MEM_BOTTOM_ADDR		: NATURAL := 16#200#;
	CONSTANT TMC_CONTROL_MEM_TOP_ADDR			: NATURAL := 16#3FF#;
	CONSTANT DATA_SORTER_BOTTOM_ADDR			: NATURAL := 16#600#;
	CONSTANT DATA_SORTER_TOP_ADDR				: NATURAL := 16#61F#;
	CONSTANT DOM_EXTRACT_BOTTOM_ADDR			: NATURAL := 16#620#;
	CONSTANT DOM_EXTRACT_TOP_ADDR				: NATURAL := 16#63F#;
	CONSTANT CENTRAL_INTERFACE_EXTRA_BOTTOM_ADDR : NATURAL := 16#640#;	
	CONSTANT CENTRAL_INTERFACE_EXTRA_TOP_ADDR 	: NATURAL := 16#66F#;
	CONSTANT EVENT_FIFO_BOTTOM_ADDR				: NATURAL := 16#AFC#;
	CONSTANT EVENT_FIFO_TOP_ADDR				: NATURAL := 16#F00#;

-- Scan Parameters (Local Controller)
	CONSTANT 	BOARD_ASSEMBLY_VERSION_ADDR						: NATURAL := 16#0#;
	CONSTANT    PERIPH_LED_CONTROL_ADDR                         : NATURAL := 16#1#; --MeitalR added on 16/12/07
	CONSTANT 	BOARD_REVISION_ADDR								: NATURAL := 16#2#;
	CONSTANT    RESET_CONTROL_REGISTER_ADDR                     : NATURAL := 16#3#;
	CONSTANT 	PERIPHERAL_FPGA_VERSION_ADDR					: NATURAL := 16#4#;
-- I2C Commands	
	CONSTANT    I2C_COMMAND_ADDR                                : NATURAL := 16#5#;--MeitalR added on 17/03/08
	CONSTANT    I2C_DATA2_WRITE_ADDR                            : NATURAL := 16#6#;--MeitalR added on 17/03/08
	CONSTANT    I2C_DATA2_READ_ADDR                             : NATURAL := 16#7#;--MeitalR added on 17/03/08
-- Scan Parameters (Local Controller)
	CONSTANT 	TMC_EXISTS_ADDR									: NATURAL := 16#8#;
	CONSTANT 	ACCESS_PASSWORD_I2C_ADDR  						: NATURAL := 16#9#;	--MeitalR added on 17/03/08
	CONSTANT 	SHOT_NUM_ADDR									: NATURAL := 16#A#;	
	
-- Periph and Board Parameters (Local Controller)
	 
	CONSTANT 	TMCS_INTERRUPT_STATUS_REGISTER_ADDR				: NATURAL := 16#10#;	
			CONSTANT 	PERIPH2TMC_4_CONTROL_CHANNEL_CRC_ERROR_BIT		: NATURAL := 3;	
			CONSTANT 	PERIPH2TMC_3_CONTROL_CHANNEL_CRC_ERROR_BIT		: NATURAL := 2;	
			CONSTANT 	PERIPH2TMC_2_CONTROL_CHANNEL_CRC_ERROR_BIT		: NATURAL := 1;	
			CONSTANT 	PERIPH2TMC_1_CONTROL_CHANNEL_CRC_ERROR_BIT		: NATURAL := 0;	

	CONSTANT    MB_ASSEMBLY_VERSION_ADDR                             :  NATURAL := 16#11#;
	CONSTANT 	TMCS_INTERRUPT_MASKED_ADDR						: NATURAL := 16#12#;
	CONSTANT 	SERVICE_DIAGNOSTIC_REGISTER_ADDR				: NATURAL := 16#13#;		
	CONSTANT 	TMCS_INTERRUPT_MASK_REGISTER_ADDR				: NATURAL := 16#14#;	
	
	CONSTANT 	LOCAL_CONTROLLER_INTERRUPT_REG_ADDR				: NATURAL := 16#20#;	
			CONSTANT 	ACK_SIGNAL_TIMEOUT_BIT							: NATURAL := 15;	
			CONSTANT 	LC_FSM_ERROR_BIT								: NATURAL := 9;	
			CONSTANT 	NEIGHBORING_FPGA_CRC_ERROR_BIT					: NATURAL := 8;	
			CONSTANT 	TMC_4_DETECTION_FAILED_BIT						: NATURAL := 7;	
			CONSTANT 	TMC_3_DETECTION_FAILED_BIT						: NATURAL := 6;	
			CONSTANT 	TMC_2_DETECTION_FAILED_BIT						: NATURAL := 5;	
			CONSTANT 	TMC_1_DETECTION_FAILED_BIT						: NATURAL := 4;	
			CONSTANT 	TMC_4_CONTROL_CHANNEL_CRC_ERROR_BIT				: NATURAL := 3;	
			CONSTANT 	TMC_3_CONTROL_CHANNEL_CRC_ERROR_BIT				: NATURAL := 2;	
			CONSTANT 	TMC_2_CONTROL_CHANNEL_CRC_ERROR_BIT				: NATURAL := 1;	
			CONSTANT 	TMC_1_CONTROL_CHANNEL_CRC_ERROR_BIT				: NATURAL := 0;	

	CONSTANT 	LOCAL_CONTROLLER_INTERRUPT_MASKED_ADDR			: NATURAL := 16#22#;	
	CONSTANT 	LOCAL_CONTROLLER_INTERRUPT_MASK_REGISTER_ADDR	: NATURAL := 16#24#;	
	
	CONSTANT 	INTERRUPT_CONCENTRATED_INDICATION_REGISTER_ADDR	: NATURAL := 16#30#;
			CONSTANT 	PERIPH_INTR_BIT									: NATURAL := 15;	
			CONSTANT 	TMCS_INTR_BIT									: NATURAL := 8;	
			CONSTANT 	DDR_DRIVER_INTR_BIT								: NATURAL := 7;	
			CONSTANT 	CENTRAL_INTERFACE_INTR_BIT						: NATURAL := 6;	
			CONSTANT 	DOM_EXTRACT_INTR_BIT							: NATURAL := 5;	
			CONSTANT 	EVOLVING_CALC_INTR_BIT							: NATURAL := 4;	
			CONSTANT 	LOCAL_CONTROLLER_INTR_BIT						: NATURAL := 3;	
			CONSTANT 	DATA_SORTER_INTR_BIT							: NATURAL := 2;	
			CONSTANT 	TMC_INTERFACE_INTR_BIT							: NATURAL := 1;	
		                                                                             	
	CONSTANT 	STOP_SCAN_CONCENTRATED_INDICATION_REGISTER_ADDR	: NATURAL := 16#32#;
			CONSTANT 	PERIPH_STOP_SCAN_BIT							: NATURAL := 15;
			CONSTANT    PTR_BUFFER_STOP_SCAN_BIT                        : NATURAL := 8;	
			CONSTANT 	DDR_DRIVER_STOP_SCAN_BIT						: NATURAL := 7;	
			CONSTANT 	CENTRAL_INTERFACE_STOP_SCAN_BIT					: NATURAL := 6;	
			CONSTANT 	DOM_EXTRACT_STOP_SCAN_BIT						: NATURAL := 5;	
			CONSTANT 	EVOLVING_CALC_STOP_SCAN_BIT						: NATURAL := 4;	
			CONSTANT 	LOCAL_CONTROLLER_STOP_SCAN_BIT					: NATURAL := 3;	
			CONSTANT 	DATA_SORTER_STOP_SCAN_BIT						: NATURAL := 2;	
			CONSTANT 	TMC_INTERFACE_STOP_SCAN_BIT						: NATURAL := 1;	
			CONSTANT 	TMC_CNTRL_STOP_SCAN_BIT							: NATURAL := 0;	
		                                                                             	
	CONSTANT 	STOP_SCAN_ERRORS_REGISTER_ADDR					: NATURAL := 16#34#;	-- not in use!!!
	CONSTANT 	STOP_SCAN_ERROR_MASKS_ADDR						: NATURAL := 16#36#;	
	CONSTANT 	TMC_CONTROL_BUS_CRC_ERROR_COUNTER_ADDR			: NATURAL := 16#38#;
		
	CONSTANT 	TMC_CTRL_CONTROL_REG_ADDR						: NATURAL := 16#3A#;	
			CONSTANT 	INJECT_TMC4_CRC_ERROR_BIT						: NATURAL := 3;	
			CONSTANT 	INJECT_TMC3_CRC_ERROR_BIT						: NATURAL := 2;	
			CONSTANT 	INJECT_TMC2_CRC_ERROR_BIT						: NATURAL := 1;	
			CONSTANT 	INJECT_TMC1_CRC_ERROR_BIT						: NATURAL := 0;	
	
-- Evolving Parameters (Evolving Control)
	CONSTANT 	EV_INTERRUPT_REG_ADDR							: NATURAL := 16#40#;	
			CONSTANT 	EV_BUFF_OVERFLOW_BIT							: NATURAL := 0;	
	CONSTANT 	EV_INTERRUPT_MASKED_ADDR						: NATURAL := 16#42#;	
	CONSTANT 	EV_INTERRUPT_MASK_REGISTER_ADDR					: NATURAL := 16#44#;	
	
	CONSTANT 	EVOLVING_CONTROL_ADDR							: NATURAL := 16#46#;	
		CONSTANT EVOLVING_CONTROL_REG_DEFAULT						: STD_LOGIC_VECTOR(15 downto 0) := X"0200";
			CONSTANT 	EVOLVING_DISABLE_BIT							: NATURAL := 15;	
			CONSTANT 	SLICE_MERGE_SEL_BIT								: NATURAL := 8;	
			CONSTANT 	FS_MERGE_SEL_BIT								: NATURAL := 4;	
			CONSTANT 	MOSASIC_MERGE_BIT								: NATURAL := 0;	
			
	CONSTANT 	EV_READING_NUMBER_LSB_ADDR						: NATURAL := 16#48#;	
	CONSTANT 	EV_READING_NUMBER_MSB_ADDR						: NATURAL := 16#49#;	
	CONSTANT 	EV_READING_COUNTER_LSB_ADDR						: NATURAL := 16#4A#;	
	CONSTANT 	EV_READING_COUNTER_MSB_ADDR						: NATURAL := 16#4B#;
		
-- TMC Parameters (TMC Interface)
	CONSTANT 	TMC_INTERFACE_INTERRUPT_REG_ADDR				: NATURAL := 16#60#;
			CONSTANT TI_FSM_ERROR_BIT									: NATURAL := 15;
			CONSTANT COMPLETELY_UNNECESSARY_INTERRUPT_BIT				: NATURAL := 8;
			CONSTANT EXTRA_IP_BIT										: NATURAL := 7;
			CONSTANT MISSED_IP_BIT										: NATURAL := 6;
			CONSTANT PERIPH_LOSS_OF_SYNCH_BIT							: NATURAL := 5;
			CONSTANT IP_GLITCH_ERROR_BIT								: NATURAL := 4;
			CONSTANT TMC4_CRC_ERROR_BIT									: NATURAL := 3;
			CONSTANT TMC3_CRC_ERROR_BIT									: NATURAL := 2;
			CONSTANT TMC2_CRC_ERROR_BIT									: NATURAL := 1;
			CONSTANT TMC1_CRC_ERROR_BIT									: NATURAL := 0;
		
	CONSTANT 	TMC_INTERFACE_INTERRUPT_MASKED_ADDR				: NATURAL := 16#62#;	
	CONSTANT 	TMC_INTERFACE_INTERRUPT_MASK_REGISTER_ADDR		: NATURAL := 16#64#;	
	CONSTANT 	CONNECTED_MODULES_CRC_ERROR_COUNTER_ADDR		: NATURAL := 16#66#;	
	
	CONSTANT 	INSERT_READING_NUMBER_ERROR_ADDR				: NATURAL := 16#68#;	
			CONSTANT INSERT_READING_NUMBER_ERROR_BIT					: NATURAL := 0;
	
	CONSTANT 	READING_NUMBER_LSB_ADDR							: NATURAL := 16#6A#;	
	CONSTANT 	READING_NUMBER_MSB_ADDR							: NATURAL := 16#6B#;
		
	CONSTANT 	TMC_INTERFACE_CONTROL_REG_ADDR					: NATURAL := 16#6C#;	
		CONSTANT TMC_INTERFACE_CONTROL_REG_DEFAULT					: STD_LOGIC_VECTOR(15 downto 0) := X"0000";
			CONSTANT TMC_INTERFACE_TEST_PATTERN_ENABLE_BIT				: NATURAL := 3;
			CONSTANT TMC_INTERFACE_PATTERN_SELECT_LSBIT					: NATURAL := 0;
	
	CONSTANT 	TMC_INTERFACE_FIRMWARE_VERSION_NUM_ADDR			: NATURAL := 16#6E#;	

	CONSTANT 	TMC_INTERFACE_DEBUG_ADDR						: NATURAL := 16#70#;
	CONSTANT 	NUM_OF_SLICES_SHADOW_ADDR						: NATURAL := 16#72#;
			CONSTANT 	NUM_OF_SLICES_DEFAULT							: STD_LOGIC_VECTOR(7 DOWNTO 0) := STD_LOGIC_VECTOR( TO_UNSIGNED( 64, 8 ) );
	CONSTANT 	BYTES_PER_DETECTOR_SHADOW_ADDR					: NATURAL := 16#74#;

	CONSTANT	SAMPLING_DENSITY_LSB_ADDR 						: NATURAL := 16#76#;
	CONSTANT	SAMPLING_DENSITY_MSB_ADDR 						: NATURAL := 16#77#;
	CONSTANT 	CTL_IN_PERIOD_LSB_ADDR							: NATURAL := 16#78#;
	CONSTANT 	CTL_IN_PERIOD_MSB_ADDR							: NATURAL := 16#79#;
		
	CONSTANT 	TMC_INTERFACE_READING_COUNTER_LSB_ADDR			: NATURAL := 16#7A#;	
	CONSTANT 	TMC_INTERFACE_READING_COUNTER_MSB_ADDR			: NATURAL := 16#7B#;
	
-- Data Sorter Parameters (Data Sorter)	
	
	CONSTANT 	DATA_SORTER_INTERRUPT_REG_ADDR					: NATURAL := 16#600#;
			CONSTANT DATA_SORTER_FIFO_OVERFLOW_BIT					: NATURAL := 0;
			
	CONSTANT 	DATA_SORTER_INTERRUPT_MASKED_ADDR				: NATURAL := 16#602#;		
	CONSTANT 	DATA_SORTER_INTERRUPT_MASK_REGISTER_ADDR		: NATURAL := 16#604#;
	
	CONSTANT 	DATA_SORTER_CONTROL_REG_ADDR					: NATURAL := 16#606#;
			CONSTANT COMPRESSION_ENABLE_BIT							: NATURAL := 0;
			
	CONSTANT 	DATA_SORTER_READING_COUNTER_LSB_ADDR			: NATURAL := 16#60C#;	
	CONSTANT 	DATA_SORTER_READING_COUNTER_MSB_ADDR			: NATURAL := 16#60D#;
	
	CONSTANT 	DATA_SORTER_READING_NUMBER_LSB_ADDR				: NATURAL := 16#60E#;	
	CONSTANT 	DATA_SORTER_READING_NUMBER_MSB_ADDR				: NATURAL := 16#60F#;
	
--	DOM Parameters (DOM Extractor)
	CONSTANT 	DOM_EXTRACT_INTERRUPT_REG_ADDR					: NATURAL := 16#620#;	
			CONSTANT DE_EXTRA_READING_BIT								: NATURAL := 2;
			CONSTANT DE_MISSED_READING_BIT								: NATURAL := 1;
			CONSTANT DE_INTER_PERIPH_LOSS_OF_SYNCH_BIT					: NATURAL := 0;
	
	CONSTANT 	DOM_EXTRACT_INTERRUPT_MASKED_ADDR				: NATURAL := 16#622#;	
	CONSTANT 	DOM_EXTRACT_INTERRUPT_MASK_REGISTER_ADDR		: NATURAL := 16#624#;	
	
	CONSTANT 	DOM_SLICE1_SEL_ADDR								: NATURAL := 16#626#;	
	CONSTANT 	DOM_SLICE2_SEL_ADDR								: NATURAL := 16#628#;	
	CONSTANT 	DOM_SLICE3_SEL_ADDR								: NATURAL := 16#62A#;	
	CONSTANT 	DOM_SLICE4_SEL_ADDR								: NATURAL := 16#62C#;
		
	CONSTANT 	DOM_EXTRACT_CONTROL_REG_ADDR					: NATURAL := 16#636#;	
		CONSTANT DOM_EXTRACT_CONTROL_REG_DEFAULT					: STD_LOGIC_VECTOR(15 downto 0) := X"0001";
			CONSTANT DOM_INSERT_NUM_OF_SLICES_ERROR_BIT				: NATURAL := 10;
			CONSTANT DOM_INSERT_READ_NUM_ERROR_BIT					: NATURAL := 9;
			CONSTANT INSERT_CRC_ERROR_BIT							: NATURAL := 8;
			CONSTANT DOM_RESERVED_BIT								: NATURAL := 7;
			CONSTANT DOM_SLICE4_ENABLE_BIT							: NATURAL := 3;
			CONSTANT DOM_SLICE3_ENABLE_BIT							: NATURAL := 2;
			CONSTANT DOM_SLICE2_ENABLE_BIT							: NATURAL := 1;
			CONSTANT DOM_SLICE1_ENABLE_BIT							: NATURAL := 0;

-- Central Interface Registers
	CONSTANT 	CENTRAL_INTERFACE_INTERRUPT_REG_ADDR 			: NATURAL := 16#090#;	
			CONSTANT COMM_FPGA_LOSS_OF_SYNCH_BIT						: NATURAL := 5;
			CONSTANT INTER_PERIPH_LOSS_OF_SYNCH_BIT						: NATURAL := 4;
			CONSTANT MISSED_SLICE_BIT									: NATURAL := 3;
			CONSTANT SLICE_TIMEOUT_BIT									: NATURAL := 2;
			CONSTANT BAD_NUM_OF_SLICES_BIT								: NATURAL := 1;
			CONSTANT CI_FSM_ERROR_BIT									: NATURAL := 0;
	CONSTANT 	CENTRAL_INTERFACE_INTERRUPT_MASKED_ADDR 		: NATURAL := 16#092#;	
	CONSTANT 	CENTRAL_INTERFACE_INTERRUPT_MASK_REGISTER_ADDR	: NATURAL := 16#094#;	
	CONSTANT 	CENTRAL_INTERFACE_CONTROL_REGISTER_ADDR			: NATURAL := 16#096#;
		CONSTANT CENTRAL_INTERFACE_CONTROL_REG_DEFAULT				: STD_LOGIC_VECTOR(15 downto 0) := X"0000";
		    CONSTANT CI_INSERT_READING_TYPE_ERROR_BIT                   : NATURAL := 5;
			CONSTANT CI_INSERT_SLICE_NUM_ERROR_BIT						: NATURAL := 4;
			CONSTANT CI_INSERT_READ_NUM_ERROR_BIT						: NATURAL := 3;
			CONSTANT CI_INSERT_UID_ERROR_BIT							: NATURAL := 2;
			CONSTANT CI_INSERT_CRC_ERROR_BIT							: NATURAL := 1;
			CONSTANT CENTRAL_INTERFACE_PATTERN_GEN_BIT					: NATURAL := 0;
	CONSTANT 	SLICE_BUNDLE_SIZE_ADDR							: NATURAL := 16#098#;	
		CONSTANT SLICE_BUNDLE_REG_DEFAULT							: STD_LOGIC_VECTOR(15 downto 0) := X"0001";

	CONSTANT 	CENTRAL_INTERFACE_READING_COUNTER_LSB_ADDR		: NATURAL := 16#9A#;	
	CONSTANT 	CENTRAL_INTERFACE_READING_COUNTER_MSB_ADDR		: NATURAL := 16#9B#;
	CONSTANT 	CENTRAL_INTERFACE_EV_READING_COUNTER_LSB_ADDR	: NATURAL := 16#9C#;	
	CONSTANT 	CENTRAL_INTERFACE_EV_READING_COUNTER_MSB_ADDR	: NATURAL := 16#9D#;
	CONSTANT 	CLOCK_160M_PERIOD_LSB_ADDR						: NATURAL := 16#9E#;
	CONSTANT 	CLOCK_160M_PERIOD_MSB_ADDR						: NATURAL := 16#9F#;

	CONSTANT 	CI_COMM_READING_NUMBER_SAMP_LSB_ADDR			: NATURAL := 16#650#;	
	CONSTANT 	CI_COMM_READING_NUMBER_SAMP_MSB_ADDR			: NATURAL := 16#651#;
	CONSTANT 	CENTRAL_INTERFACE_READING_NUMBER_SAMP_LSB_ADDR	: NATURAL := 16#652#;
	CONSTANT 	CENTRAL_INTERFACE_READING_NUMBER_SAMP_MSB_ADDR	: NATURAL := 16#653#;

-- Buffer Control Registers
	CONSTANT 	BUFFER_CONTROL_INTERRUPT_REG_LSB_ADDR			: NATURAL := 16#0A0#;	
-- 			CONSTANT SDRAM_EV_BUFFER_STOP_SCAN_BIT						: NATURAL := 15;
			CONSTANT SL_REQ_DURING_SLICE_TRANSMISSION_BIT				: NATURAL := 14;
			CONSTANT NEW_FRAME_WHILE_EV_FIFO_NOT_EMPTY_BIT				: NATURAL := 13;
			CONSTANT NEW_FRAME_WHILE_RAW_FIFO_NOT_EMPTY_BIT				: NATURAL := 12;
			CONSTANT COMM_TX_MODULE_DATA_BURST_FIFO_NOT_EMPTIED_BIT		: NATURAL := 11;
			CONSTANT ECC_UNRECOVERABLE_ERROR_BIT						: NATURAL := 10;
			CONSTANT COMM_TX_FSM_ERROR_BIT								: NATURAL := 9;
			CONSTANT EV_FSM_ERROR_BIT									: NATURAL := 8;
			CONSTANT RAW_FSM_ERROR_BIT									: NATURAL := 7;
			CONSTANT SDRAM_READING_POINTER_BUFFER_OVERFLOW_BIT			: NATURAL := 6;
			CONSTANT SDRAM_EV_BUFFER_OVERFLOW_BIT						: NATURAL := 5;
			CONSTANT SDRAM_RAW_BUFFER_OVERFLOW_BIT						: NATURAL := 4;
-- 			CONSTANT SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT					: NATURAL := 3;
			CONSTANT COMM_TX_OUTPUT_FIFO_OVERFLOW_BIT					: NATURAL := 2;
			CONSTANT EV_INPUT_FIFO_OVERFLOW_BIT							: NATURAL := 1;
			CONSTANT RAW_INPUT_FIFO_OVERFLOW_BIT						: NATURAL := 0;
			
	CONSTANT 	BUFFER_CONTROL_INTERRUPT_REG_MSB_ADDR			: NATURAL := 16#0A1#;
		    CONSTANT SDRAM_EV_BUFFER_STOP_SCAN_BIT				: NATURAL := 5;
			CONSTANT SDRAM_RAW_OVERFLOW_STOP_SCAN_BIT           : NATURAL := 4;		
			CONSTANT SDRAM_PTR_BUFFER_OVERFLOW_STOP_SCAN_BIT    : NATURAL := 3;
			CONSTANT SDRAM_PTR_BUFFER_UNDERRUN_BIT				: NATURAL := 2;
			CONSTANT SDRAM_EV_BUFFER_UNDERRUN_BIT				: NATURAL := 1;			
			CONSTANT SDRAM_RAW_BUFFER_UNDERRUN_BIT				: NATURAL := 0;
	
	CONSTANT 	BUFFER_CONTROL_INTERRUPT_MASKED_LSB_ADDR		: NATURAL := 16#0A2#;	
	CONSTANT 	BUFFER_CONTROL_INTERRUPT_MASKED_MSB_ADDR		: NATURAL := 16#0A3#;	
	CONSTANT 	BUFFER_CONTROL_INTERRUPT_MASK_REGISTER_LSB_ADDR	: NATURAL := 16#0A4#;	
	CONSTANT 	BUFFER_CONTROL_INTERRUPT_MASK_REGISTER_MSB_ADDR	: NATURAL := 16#0A5#;	
	CONSTANT 	EVOLVING_STOP_IP_HIGH_LIMIT_ADDR				: NATURAL := 16#0A6#; --MeitalR added on 16/12/07
	CONSTANT 	EVOLVING_STOP_IP_LOW_LIMIT_ADDR					: NATURAL := 16#0A7#; --MeitalR added on 16/12/07

	CONSTANT 	BUFFER_STATUS_LSB_ADDR							: NATURAL := 16#0A8#;	
	CONSTANT 	BUFFER_STATUS_MSB_ADDR							: NATURAL := 16#0A9#;	
	
	CONSTANT 	EV_BUFFER_STATUS_ADDR							: NATURAL := 16#0AA#;	
	CONSTANT 	EVOLVING_STOP_SCAN_INTERRUPT_HIGH_LIMIT_ADDR	: NATURAL := 16#0AB#; --MeitalR added on 16/12/07	

	CONSTANT 	READING_POINTER_BUFFER_STATUS_LSB_ADDR			: NATURAL := 16#0AC#;	
	CONSTANT 	READING_POINTER_BUFFER_STATUS_MSB_ADDR			: NATURAL := 16#0AD#;	

	CONSTANT 	RAW_FIFO_STATUS_ADDR							: NATURAL := 16#0AE#;	
	CONSTANT 	EV_FIFO_STATUS_ADDR								: NATURAL := 16#0B0#;	
	
	CONSTANT 	COMM_TX_FIFO_STATUS_ADDR						: NATURAL := 16#0B2#;	
	
	CONSTANT 	RAW_WRITE_POINTER_LSB_ADDR						: NATURAL := 16#0B4#;	
	CONSTANT 	RAW_WRITE_POINTER_MSB_ADDR						: NATURAL := 16#0B5#;	

	CONSTANT 	EVOLVING_WRITE_POINTER_LSB_ADDR					: NATURAL := 16#0B6#;	
	CONSTANT 	EVOLVING_WRITE_POINTER_MSB_ADDR					: NATURAL := 16#0B7#;	
	
	CONSTANT 	COMM_TX_RAW_READ_POINTER_LSB_ADDR				: NATURAL := 16#0B8#;	
	CONSTANT 	COMM_TX_RAW_READ_POINTER_MSB_ADDR				: NATURAL := 16#0B9#;	
	
	CONSTANT 	COMM_TX_EV_READ_POINTER_LSB_ADDR				: NATURAL := 16#0BA#;	
	CONSTANT 	COMM_TX_EV_READ_POINTER_MSB_ADDR				: NATURAL := 16#0BB#;	

	CONSTANT 	DDR2_DEVICE_TEST_STATUS_ADDR					: NATURAL := 16#0C0#;	
	CONSTANT 	DDR2_ADDRESS_TEST_STATUS_LSB_ADDR				: NATURAL := 16#0C2#;	
	CONSTANT 	DDR2_ADDRESS_TEST_STATUS_MSB_ADDR				: NATURAL := 16#0C3#;	
	
	CONSTANT 	DDR_DRIVER_CONTROL_ADDR							: NATURAL := 16#0C4#;	
			CONSTANT DD_INJECT_DATA_OUTPUT_FIFO_BIT						: NATURAL := 3;
	
	CONSTANT 	ECC_ERROR_CHIP_NUMBER_ADDR						: NATURAL := 16#0C6#;	
	CONSTANT 	ECC_ERROR_ADDRESS_LSB_ADDR						: NATURAL := 16#0C8#;	
	CONSTANT 	ECC_ERROR_ADDRESS_MSB_ADDR						: NATURAL := 16#0C9#;	
	
	CONSTANT 	ECC_CORRECTED_ERRORS_COUNTER_ADDR				: NATURAL := 16#0CA#;
	CONSTANT 	ECC_ERRORS_COUNTER_ADDR							: NATURAL := 16#0CC#;

--	CONSTANT 	ECC_ALL_ERRORS_COUNTER_ADDR						: NATURAL := 16#0CA#;				-- all ECC erros corected and not 
--	CONSTANT 	ECC_DOUBLE_ERRORS_COUNTER_ADDR					: NATURAL := 16#0CC#;	
		
	CONSTANT 	ECC_ERROR_INJECTION_ADDR						: NATURAL := 16#0CE#;	

	CONSTANT 	RAW_WR_COUNTER_LSB_ADDR							: NATURAL := 16#0D2#;	
	CONSTANT 	RAW_WR_COUNTER_MSB_ADDR							: NATURAL := 16#0D3#;	
	CONSTANT 	EV_WR_COUNTER_LSB_ADDR							: NATURAL := 16#0D4#;	
	CONSTANT 	EV_WR_COUNTER_MSB_ADDR							: NATURAL := 16#0D5#;
		
	CONSTANT 	RAW_RD_COUNTER_LSB_ADDR							: NATURAL := 16#0D6#;	
	CONSTANT 	RAW_RD_COUNTER_MSB_ADDR							: NATURAL := 16#0D7#;	
	CONSTANT 	EV_RD_COUNTER_LSB_ADDR							: NATURAL := 16#0D8#;	
	CONSTANT 	EV_RD_COUNTER_MSB_ADDR							: NATURAL := 16#0D9#;	
	
	
	
	CONSTANT 	DDR_DRIVER_DATE_LSB_ADDR						: NATURAL := 16#0DE#;	
	CONSTANT 	DDR_DRIVER_DATE_MSB_ADDR						: NATURAL := 16#0DF#;	

-- TMC Register Control (Local Controller)            
	CONSTANT 	ALL_TMC_INSTRUCTION_BROADCAST_MODE_ADDR			: NATURAL := 16#100#;	
			CONSTANT ACTIVATE_INSTRUCTION								: NATURAL := 15;
			CONSTANT WRITE_READ_N										: NATURAL := 14;
			CONSTANT TMC_REG_SELECT_TOP									: NATURAL := 11;
			CONSTANT TMC_REG_SELECT_BOTTOM								: NATURAL := 0;
			CONSTANT MOSASIC_REG_SELECT_TOP								: NATURAL := 3;
			CONSTANT MOSASIC_REG_SELECT_BOTTOM							: NATURAL := 0;
			
	CONSTANT 	FIRST_TMC_INSTRUCTION_ADDR						: NATURAL := 16#102#;	
	CONSTANT 	SECOND_TMC_INSTRUCTION_ADDR						: NATURAL := 16#104#;	
	CONSTANT 	THIRD_TMC_INSTRUCTION_ADDR						: NATURAL := 16#106#;	
	CONSTANT 	FORTH_TMC_INSTRUCTION_ADDR						: NATURAL := 16#108#;	

	CONSTANT 	TMC_DATA_MEM_BASE_ADDR							: NATURAL := 16#200#;
	
	
	
-- Logging tool (Local Controller)
	CONSTANT 	EVENT_FIFO_RESET_ADDR							: NATURAL := 16#AFC#;	
	CONSTANT 	EVENT_FIFO_STATUS_ADDR							: NATURAL := 16#AFE#;	
	CONSTANT 	EVENT_FIFO_BASE_ADDR							: NATURAL := 16#B00#;	

----------------------------------------------------------------------------
-- functions and procedure
----------------------------------------------------------------------------

	function rise_detect ( INP_SIG : IN std_logic_vector ) return boolean;
----------------------------------------------------------------------------
	function fall_detect ( INP_SIG : IN std_logic_vector ) return boolean;
----------------------------------------------------------------------------
	function and_reduce (arg : std_logic_vector ) return std_logic;
----------------------------------------------------------------------------
	function xor_reduce (arg : std_logic_vector ) return std_logic;
----------------------------------------------------------------------------
	function or_reduce (arg : std_logic_vector ) return std_logic;
----------------------------------------------------------------------------
	function bool2std (arg : boolean ) return std_logic;
----------------------------------------------------------------------------
	function std2int (arg : std_logic ) return integer;
----------------------------------------------------------------------------
	function ufloat8_to_natural (arg : std_logic_vector ) return natural;
----------------------------------------------------------------------------
	function ufloat8_to_std16 (arg : std_logic_vector ) return std_logic_vector;
----------------------------------------------------------------------------
	function natural_to_ufloat8 (arg : natural ) return std_logic_vector;
----------------------------------------------------------------------------

end TMC_pack;
----------------------------------------------------------------------------
----------------------------------------------------------------------------

package body TMC_pack is
----------------------------------------------------------------------------

	function rise_detect ( INP_SIG : IN std_logic_vector ) return boolean is
		variable rise : BOOLEAN;
	begin

		IF ( INP_SIG(INP_SIG'left) = '0') AND ( INP_SIG(INP_SIG'left-1) = '1') THEN
			rise := TRUE;
		ELSE
			rise := FALSE;
		END IF;

		return(rise);

	end function rise_detect;
----------------------------------------------------------------------------

	function fall_detect ( INP_SIG : IN std_logic_vector ) return boolean is
		variable aux_std : std_logic_vector(INP_SIG'range);
		variable fall : BOOLEAN;
	begin

		aux_std := not INP_SIG;
		fall := rise_detect( aux_std );
		
		return(fall);

	end function fall_detect;
----------------------------------------------------------------------------

  -- purpose: AND all of the bits in a vector together
	function and_reduce (arg : std_logic_vector ) return std_logic is

	    variable count 			: integer;
		variable result			: std_logic;

	begin

		result := arg(0);

		for count in arg'low+1 to arg'high loop
			result := result AND arg(count);
		end loop;

	    return result;
	end function and_reduce;
----------------------------------------------------------------------------
  -- purpose: XOR all of the bits in a vector together
	function xor_reduce (arg : std_logic_vector ) return std_logic is

	    variable count 			: integer;
		variable result			: std_logic;

	begin

		result := arg(arg'low);

		for count in arg'low+1 to arg'high loop
			result := result XOR arg(count);
		end loop;

	    return result;
	end function xor_reduce;
----------------------------------------------------------------------------
  -- purpose: OR all of the bits in a vector together
	function or_reduce (arg : std_logic_vector ) return std_logic is

	    variable count 			: integer;
		variable result			: std_logic;

	begin

		result := arg(arg'low);

		for count in arg'low+1 to arg'high loop
			result := result OR arg(count);
		end loop;

	    return result;
	end function or_reduce;
----------------------------------------------------------------------------
	function bool2std (arg : boolean ) return std_logic is
		variable result : std_logic;
	begin
		if arg then
			result := '1';
		else
			result := '0';
		end if;
		
		return(result);
	end function bool2std;
----------------------------------------------------------------------------
	function std2int (arg : std_logic ) return integer is
--		variable result : integer;
	begin
		if arg = '1' then
			return(1);
		else
			return(0);
		end if;
		
--		return(result);
	end function std2int;
----------------------------------------------------------------------------

	function find_highest_one (arg : std_logic_vector ) return natural is
		variable ind : natural;
	begin
	
		ind := 0;
		
		for ind in arg'high downto arg'low loop
		
			if (arg(ind) = '1') then
				return ind;
			end if;
			
		end loop;
		
		return ind;
					
	end function find_highest_one;
----------------------------------------------------------------------------

	function ufloat8_to_natural (arg : std_logic_vector ) return natural is
		variable exp 		: integer range -16 to 15;
		variable aux_std 	: std_logic_vector(15 downto 0);
		variable result 	: natural range 0 to 2**16 - 1;
	begin
	
		if arg(7) = '0' then
			result := TO_INTEGER( UNSIGNED( arg(7 downto 0 ) ) );
		else
			exp := TO_INTEGER( UNSIGNED( arg(7 downto 5) ) ) - 2;
			aux_std := X"00" & "001" & arg(4 downto 0);
			result := TO_INTEGER( shift_left( UNSIGNED(aux_std), exp) );
		end if;
		
		return result;
					
	end function ufloat8_to_natural;
----------------------------------------------------------------------------

	function ufloat8_to_std16 (arg : std_logic_vector ) return std_logic_vector is
		variable exp 		: integer range -16 to 15;
		variable aux_std 	: std_logic_vector(15 downto 0);
		variable result 	: std_logic_vector(15 downto 0);
	begin
	
		if arg(7) = '0' then
			result := X"00" & arg(7 downto 0 ) ;
		else
			exp := TO_INTEGER( UNSIGNED( arg(7 downto 5) ) ) - 2;
			aux_std := X"00" & "001" & arg(4 downto 0);
			result :=  std_logic_vector(shift_left( UNSIGNED(aux_std), exp));
		end if;
		
		return result;
					
	end function ufloat8_to_std16;
----------------------------------------------------------------------------

	function natural_to_ufloat8 (arg : natural ) return std_logic_vector is
		variable aux_int	: integer range -16 to 15;
		variable aux_std 	: std_logic_vector(15 downto 0);
		variable result 	: std_logic_vector(7 downto 0);
	begin
			
		if arg <= 127 then
			result := STD_LOGIC_VECTOR( TO_UNSIGNED( arg, result'length ) );
		else
		
			aux_int := find_highest_one( STD_LOGIC_VECTOR( TO_UNSIGNED( arg, 16 ) ) ) - 5;
			aux_std := STD_LOGIC_VECTOR( shift_right( TO_UNSIGNED( arg, 16 ), aux_int ) );
			result(4 downto 0) := aux_std(4 downto 0);
			result(7 downto 5) := STD_LOGIC_VECTOR( TO_UNSIGNED( aux_int + 2, 3 ) );
			
		end if;
			
		return(result);
				
	end function natural_to_ufloat8;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
end TMC_pack;
----------------------------------------------------------------------------
----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
-- use IEEE.STD_LOGIC_UNSIGNED.all;
----------------------------------------------------------------------------
  -- Generate a pulse upon detection of rise of input signal, using input clock
	entity rising_pulse_gen is
	port(
		signal inp 			: in	std_logic;
	 	signal clk 			: in 	std_logic;
	 	signal pulse_out	: out	std_logic
	 	);
	end entity rising_pulse_gen;
	 	
	ARCHITECTURE rising_pulse_gen_a OF rising_pulse_gen IS
	
		signal inp_samp		: std_logic;

	begin

		inp_samp <= inp when rising_edge(clk);
		pulse_out <= '1' when ( inp_samp = '0' ) and ( inp = '1' ) else '0';

	end ARCHITECTURE rising_pulse_gen_a;
----------------------------------------------------------------------------
----------------------------------------------------------------------------



