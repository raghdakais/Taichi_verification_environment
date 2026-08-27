
---------------------------------------------
-- Date : 28/03/2022
-- Company : Philips Medical
---------------------------------------------
-- Aothor  : Tzvika Sweetkin
---------------------------------------------
-- Block Name:scan_flow_tb
---------------------------------------------
-- simulation tool : Vivado Simulator
-- Synthesis&PnR tool : Vivado 2021.2
-- Versions :
-- 10/05/22 : changed reset to be synchronous.
-- 13/06/22 : changed crc data in length from 1 to 8 bit and it changed also sr length
-- 07/07/22 : Added delay process for debug,case delay_axi_debug_proc for getting delay length from registers
--              and changed interrupts reset for nested ifs to lower number of luts used.
---------------------------------------------
---------------------------------------------
-- Block description:
-- Masters : CPU,RHOST
---------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity wr_req_rd_req_tb is
end entity;

architecture wr_req_rd_req_tb_arch of wr_req_rd_req_tb is
----- components ------

  component tx_ctrl_serdes_wrap is
    generic(
      G_PARAMS_LEN            : integer range 0 to 64           := 16;  --ip default 3msec +/-1.5usec (its count res is ACLK freq)
      G_TX_DATA_PACKET_SIZE   : std_logic_vector(32-1 downto 0) := x"00000020";  --header data packet bytes size is : 64*16 bits => 64*2Bytes => 128B
      G_TX_HEADER_PACKET_SIZE : std_logic_vector(8-1 downto 0)  := x"08";  --header bytes number is : 8 bytes
      G_TX_FOOTER_PACKET_SIZE : std_logic_vector(8-1 downto 0)  := x"08";  --footer bytes number is : 8 bytes
      G_HEADERS               : std_logic                       := '1';    -- sync or buffer signal
      G_RESET_POLARITY        : std_logic                       := '1'  --ip default 3msec +/-1.5usec (its count res is ACLK freq)
      );
    port(
      CLK_50M                        : in  std_logic := '0';
      CLK_100M                       : in  std_logic := '0';
      CLK_200M                       : in  std_logic := '0';
      ACLK                           : in  std_logic := '0';
      INIT_DONE                      : in  std_logic := '0';
      RESET                          : in  std_logic := '0';
      SYNC_DEBUG_REG                 : in  std_logic_vector(31 downto 0);
      NUMBER_OF_SLICES               : in  std_logic_vector(16-1 downto 0);
      MAKE_DATA                      : in  std_logic := '0';
      IP_LONG                        : in  std_logic := '0';
      DFS                            : in  std_logic := '0';
      TX_TRI_IN                      : in  std_logic := '0';
      TX_TRI_O                       : out std_logic := '0';
      TX_DATA_O                      : out std_logic := '0';
      CT_TYPE                        : in  std_logic_vector(31 downto 0);
      DMS_STATUS_REG                 : in  std_logic_vector(31 downto 0);
      DMS_ERROR                      : in  std_logic_vector(31 downto 0);
      INTEGRATION_TIME_IN_REG        : in  std_logic_vector(31 downto 0);
      REF_CONVERTOR                  : in  std_logic_vector(31 downto 0);
      L_DMS_TEMP                     : in  std_logic_vector(31 downto 0);
      R_DMS_TEMP                     : in  std_logic_vector(31 downto 0);
      FANS_SPEED_DMS_TROUBLESHOOTING : in  std_logic_vector(31 downto 0);
      READING_NUMBER_REG             : in  std_logic_vector(31 downto 0);
      DETECTION_SETTING_1            : in  std_logic_vector(31 downto 0);
      DETECTION_SETTING_2            : in  std_logic_vector(31 downto 0);
      DETECTION_SETTING_3            : in  std_logic_vector(31 downto 0);
      DETECTION_SETTING_4            : in  std_logic_vector(31 downto 0);
      RESEND_COUNTER                 : in  std_logic_vector(31 downto 0);
      VERTICAL_COUCH_POSITION        : in  std_logic_vector(31 downto 0);
      HORIZONTAL_COUCH_POSITION      : in  std_logic_vector(31 downto 0);
      GANTRY_TILT                    : in  std_logic_vector(31 downto 0);
      ROTOR_ANGLE_ACQUISITION        : in  std_logic_vector(31 downto 0);
      ROTOR_ANGLE_DATA_SENDING       : in  std_logic_vector(31 downto 0);
      HW_LINES_1                     : in  std_logic_vector(31 downto 0);
      HW_LINES_2                     : in  std_logic_vector(31 downto 0);
      BAD_READING_DETAILS            : in  std_logic_vector(31 downto 0);
      UID_REG                        : in  std_logic_vector(31 downto 0);
      SHOT_COUNTER                   : in  std_logic_vector(31 downto 0);
      ANGULAR_DENOMINATOR            : in  std_logic_vector(31 downto 0);
      TIME_STAMP_LOW                 : in  std_logic_vector(31 downto 0);
      TIME_STAMP_HIGH                : in  std_logic_vector(31 downto 0);
      NUMBER_OF_DETECTORS            : in  std_logic_vector(31 downto 0);
      UTC_TIME_LSB                   : in  std_logic_vector(31 downto 0);
      UTC_TIME_MSB                   : in  std_logic_vector(31 downto 0);
      ADDR_DMS_TYPE_REG              : in  std_logic_vector(31 downto 0);
      CAPABILITY_BITS_H              : in  std_logic_vector(31 downto 0);
      TUBE_MA_COMMAND                : in  std_logic_vector(31 downto 0);
      ACTUAL_TUBE_MA                 : in  std_logic_vector(31 downto 0);
      COLLIMATOR_1_REAR_BLADE        : in  std_logic_vector(31 downto 0);
      GRID_VOLTAGE_1                 : in  std_logic_vector(31 downto 0);
      GRID_VOLTAGE_2                 : in  std_logic_vector(31 downto 0);
      COLLIMATOR_2_FRONT_BLADE       : in  std_logic_vector(31 downto 0);
      CAPABILITY_BITS_M              : in  std_logic_vector(31 downto 0);
      DMS_TROUBLESHOOTING_1          : in  std_logic_vector(31 downto 0);
      DMS_TROUBLESHOOTING_2          : in  std_logic_vector(31 downto 0);
      FILAMENT_CURRENT               : in  std_logic_vector(31 downto 0);
      MA                             : in  std_logic_vector(31 downto 0);
      KV                             : in  std_logic_vector(31 downto 0);
      COLLIMATOR_3                   : in  std_logic_vector(31 downto 0);
      CAPABILITY_BITS_L              : in  std_logic_vector(31 downto 0);
      COLLIMATOR_4                   : in  std_logic_vector(31 downto 0);
      ECG                            : in  std_logic_vector(31 downto 0);
      DOM                            : in  std_logic_vector(31 downto 0);
      DATA_POINTER_0                 : in  std_logic_vector(31 downto 0);
      DATA_POINTER_1                 : in  std_logic_vector(31 downto 0);
      STAMP                          : in  std_logic_vector(31 downto 0);
      ----------------------------------------------------------------------
      RLT_ADDRESS_REG                : in  std_logic_vector(31 downto 0);
      HD_PTR_ADDRESS_REG             : in  std_logic_vector(31 downto 0);
      BUF_PTR_ADDRESS                : in  std_logic_vector(31 downto 0);
      STREAM_CTRL                    : in  std_logic_vector(31 downto 0);
      -- RLT_SLICE_MERGE_FACTOR             :in std_logic_vector(31 downto 0);
      -- FQ_STREAM                                          :in std_logic_vector(31 downto 0);
      --------------------------------------------------------------------
      HEADERS_CTRL_REG               : in  std_logic_vector(31 downto 0);
      HEADERS_SAMP_TIME_REG          : in  std_logic_vector(31 downto 0);
      DBG_READING_CNT                : in  std_logic_vector(15-1 downto 0);

      --------------------------------------------------------------------
      MASTERn_SLAVE : in std_logic
      );
  end component;
--------------------------------------------------------------------
component RX_Zynq IS
Generic (
    IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
    StartWord      : std_logic_vector (7 downto 0):=x"21";
    Stream_type1   : std_logic_vector (7 downto 0):=x"43";
    Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
    TapWidth       : natural := 9;
    ParallelWidth  : natural := 8;
    NumHeaderBytes : natural := 8;
    NumDataBytes   : natural := 32;
    NumFooterBytes : natural := 8

    );
PORT(
    RESET       		    : IN    std_logic;
    CLKDIV          	    : IN    std_logic;
    FCLK      		        : in    std_logic;   --serial clock input side
    Channel_RDY   	        : in    std_logic;
    sDataIn                 : in    std_logic;
    IDLY_CNT  		        : out   std_logic_vector(TapWidth-1 downto 0);  --IDELAYE3 Current Tap Count
    RX_det_o       	        : OUT   std_logic_vector (7 downto 0);
    start_valid             : OUT   std_logic;
    Headers_valid           : OUT   std_logic;
    data_valid              : OUT   std_logic;
    Footers_valid           : OUT   std_logic;
    IP_pckt_valid           : OUT   std_logic;
    packet_received         : OUT   std_logic;
    good_packet_received    : OUT   std_logic;
    bad_packet_received     : OUT   std_logic;
    crc_error               : OUT   std_logic;
    std_error               : OUT   std_logic

    );
end component;

----- Signals ------
signal clk_8M_sig                  :std_logic;
signal clk_50M_sig                  :std_logic;
signal clk_200M_sig                  :std_logic;
-- signal clk_250M_sig                  :std_logic;
signal clk_100M_sig                  :std_logic;
signal resetn_sig                :std_logic;
signal reset_sig                :std_logic;

signal ip_short_sig           :std_logic;
signal ip_long_sig           :std_logic;
signal dfs_sig           :std_logic;

-- signal ip_len_valid_sig           :std_logic;
-- signal ip_len_reg_sig           :std_logic_vector(31 downto 0);
-- signal ip_len_ack_sig           :std_logic;

-- signal t_ip_valid_reg_sig           :std_logic;
-- signal t_ip_reg_sig           :std_logic_vector(31 downto 0);
-- signal t_ip_ack_reg_sig           :std_logic;

signal integration_time_reg_sig           :std_logic_vector(31 downto 0);

 --------------------------------------------------------------------------
    signal aclk_sig : std_logic:='0';
    signal aclk_ph0_sig : std_logic:='0';
    signal aclk_ph90_sig : std_logic:='0';
    signal aclk_ph180_sig : std_logic:='0';
    signal aclk_ph180_ack_sig : std_logic:='0';
    signal aclk_ph270_sig : std_logic:='0';

	-----------------------------------------------
	-- signal init_done_sig: std_logic:='0';
    -----------------------------------------------
    signal make_data_sig : std_logic:='0';
    signal ser_data_o_sig : std_logic:='0';
    signal ser_data_o2_sig : std_logic:='0';
    signal rx_rgisters_data_i_sig : std_logic:='0';
    signal ser_tx_regs_data_o_sig : std_logic:='0';
    -- signal mod_en_sig : std_logic:='0';
    signal write_done_sig : std_logic:='0';
    signal read_done_sig : std_logic:='0';
    signal readdata_sig : std_logic_vector(31 downto 0):=(others => '0');
    signal rd_req_sig : std_logic:='0';
    signal cnt_sig  :integer;
    -----------------------------------------------

  -- 14/09/2023 ES
  constant IP_DATA_OUT_VAL : INTEGER :=8;
  constant HEADER_DATA_OUT_VAL: INTEGER :=16;
  constant ADDR_BIT_VAL : INTEGER :=6;
  constant DATA_BIT_VAL : INTEGER :=16;

  component IP_DATAVAL_HEADER_TOP is
    generic (
      IP_DATA_OUT_VAL     : INTEGER;
      HEADER_DATA_OUT_VAL : INTEGER;
      ADDR_BIT_VAL        : INTEGER;
      DATA_BIT_VAL        : INTEGER);
    port (
      CLK_200Mhz          : IN  STD_LOGIC;
      CLK_50Mhz           : IN  STD_LOGIC;
      RST                 : IN  STD_LOGIC;
      sDataIn             : IN  STD_LOGIC;
      Channel_RDY         : IN  STD_LOGIC;
      IP_READY            : OUT STD_LOGIC;
      IP_DATA_OUT         : OUT STD_LOGIC_VECTOR(IP_DATA_OUT_VAL-1 DOWNTO 0);
      HEADER_DATA_OUT     : OUT STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);
      clkb                : IN  STD_LOGIC;
      enb                 : IN  STD_LOGIC;
      web                 : IN  STD_LOGIC_VECTOR(0 DOWNTO 0);
      addrb               : IN  STD_LOGIC_VECTOR(ADDR_BIT_VAL-1 DOWNTO 0);
      dinb                : IN  STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);
      doutb               : OUT STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);
      bad_packet_received : OUT std_logic;
      crc_error           : OUT std_logic;
      std_error           : OUT std_logic);
  end component IP_DATAVAL_HEADER_TOP;

  signal IP_READY            : STD_LOGIC;
  signal IP_DATA_OUT         : STD_LOGIC_VECTOR(IP_DATA_OUT_VAL-1 DOWNTO 0);
  signal HEADER_DATA_OUT     : STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);
  signal header_dpr_addr : std_logic_vector(5 downto 0);

  signal buffer_data_valid, buffer_req_valid, buffer_good_packet_received, buffer_bad_packet_received : std_logic;
  signal buffer_byte : std_logic_vector(7 downto 0);
  signal buffer_payload : std_logic_vector(8*6-1 downto 0); -- as rx_serdes_buffer.NumDataBytes
  signal buf_ptr_address_from_buffer : std_logic_vector(31 downto 0);
  signal stream_ctrl_from_buffer : std_logic_vector(7 downto 0);

  component RX_series7 is
    generic (
      IDLE_word      : std_logic_vector (7 downto 0);
      StartWord      : std_logic_vector (7 downto 0);
      Stream_type1   : std_logic_vector (7 downto 0);
      Stream_type2   : std_logic_vector (7 downto 0);
      TapWidth       : natural;
      ParallelWidth  : natural;
      NumHeaderBytes : natural;
      NumDataBytes   : natural;
      NumFooterBytes : natural);
    port (
      RESET                : in  std_logic;
      CLKDIV               : in  std_logic;
      FCLK                 : in  std_logic;
      channel_RDY          : in  std_logic;
      sDataIn              : in  std_logic;
      IDLY_CNT             : out std_logic_vector(TapWidth-1 downto 0);
      RX_det_o             : out std_logic_vector (7 downto 0);
      start_valid          : out std_logic;
      Headers_valid        : out std_logic;
      data_valid           : out std_logic;
      Footers_valid        : out std_logic;
      IP_pckt_valid        : out std_logic;
      packet_received      : out std_logic;
      good_packet_received : out std_logic;
      bad_packet_received  : out std_logic;
      crc_error            : out std_logic;
      std_error            : out std_logic);
  end component RX_series7;

begin

  -- CDM TX -> TMB SYNC
  tx_serdes_ip:component tx_ctrl_serdes_wrap
    generic map (
        G_PARAMS_LEN            => 16,
        G_TX_DATA_PACKET_SIZE   => x"00000080", -- 128B
        G_TX_HEADER_PACKET_SIZE => x"02",
        G_TX_FOOTER_PACKET_SIZE => x"08", -- !debug: 14/09/2023 was 2
        G_HEADERS         => '1',
        G_RESET_POLARITY  => '1'
    )
    port map (
        CLK_50M              	    => clk_50M_sig,
        CLK_100M              	    => clk_100M_sig,
        CLK_200M              	    => clk_200M_sig,
        ACLK                  	    => aclk_sig,

        RESET           		    =>reset_sig,
		INIT_DONE 					=>'1',
		SYNC_DEBUG_REG             => x"00000000",
		MASTERn_SLAVE				=> '0',
        NUMBER_OF_SLICES            => x"0010", -- 16 slices
        MAKE_DATA        	        => make_data_sig,
        IP_LONG          	        => ip_long_sig,
        DFS              	        => dfs_sig,
        TX_TRI_IN                   => '1',
        TX_TRI_O                    => open,
        TX_DATA_O                   => ser_data_o_sig,

        CT_TYPE                                 => X"00000040", -- x"00000001",
        DMS_STATUS_REG                          => x"00000005",
        DMS_ERROR                               => x"00000009",
        INTEGRATION_TIME_IN_REG                 => x"0000000d",
        REF_CONVERTOR                           => x"00000011",
        L_DMS_TEMP                              => x"00000015",
        R_DMS_TEMP                              => x"00000019",
        FANS_SPEED_DMS_TROUBLESHOOTING          => x"0000001d",
        READING_NUMBER_REG                      => x"00000021",
        DETECTION_SETTING_1                     => x"00000025",
        DETECTION_SETTING_2                     => x"00000029",
        DETECTION_SETTING_3                     => x"0000002d",
        DETECTION_SETTING_4                     => x"00000031",
        RESEND_COUNTER                          => x"00000035",
        VERTICAL_COUCH_POSITION                 => x"00000039",
        HORIZONTAL_COUCH_POSITION               => x"0000003d",
        GANTRY_TILT                             => x"00000041",
        ROTOR_ANGLE_ACQUISITION                 => x"00000045",
        ROTOR_ANGLE_DATA_SENDING                => x"00000049",
        HW_LINES_1                              => x"0000004d",
        HW_LINES_2                              => x"00000800", -- [11..10] - Slice Merging (RLT_SLICE_MERGE_FACTOR ), 0 -	No Slice Merging, 1	- Merged 2 Slices, 2 - Merged 4 Slices   , was x"00000051",
        BAD_READING_DETAILS                     => x"00000055",
        UID_REG                                 => x"0000BEEF", -- x"00000059",
        SHOT_COUNTER                            => x"0000005d",
        ANGULAR_DENOMINATOR                     => x"00000061",
        TIME_STAMP_LOW                          => x"00000065",
        TIME_STAMP_HIGH                         => x"00000069",
        NUMBER_OF_DETECTORS                     => x"000004A0", -- x"0000006d",
        UTC_TIME_LSB                            => x"00000071",
        UTC_TIME_MSB                            => x"00000075",
        ADDR_DMS_TYPE_REG                       => x"00000079",
        CAPABILITY_BITS_H                       => x"0000007d",
        TUBE_MA_COMMAND                         => x"00000081",
        ACTUAL_TUBE_MA                          => x"00000085",
        COLLIMATOR_1_REAR_BLADE                 => x"00000089",
        GRID_VOLTAGE_1                          => x"0000008d",
        GRID_VOLTAGE_2                          => x"00000091",
        COLLIMATOR_2_FRONT_BLADE                => x"00000095",
        CAPABILITY_BITS_M                       => x"00000099",
        DMS_TROUBLESHOOTING_1                   => x"0000009d",
        DMS_TROUBLESHOOTING_2                   => x"000000a1",
        FILAMENT_CURRENT                        => x"000000a5",
        MA                                      => x"000000a9",
        KV    					                => x"000000ad",
        COLLIMATOR_3    					    => x"000000b1",
        CAPABILITY_BITS_L    					=> x"000000b5",
        COLLIMATOR_4    					    => x"000000b9",
        ECG    					                => x"000000bd",
        DOM    					                => x"000000c1",
        DATA_POINTER_0    					    => x"000000c5",
        DATA_POINTER_1    					    => x"000000c9",
        STAMP    					            => x"0000FACE", -- x"000000cd",
        RLT_ADDRESS_REG    					    => X"00042000", -- !TODO: check SYNC footer, was  x"000000d1"
        HD_PTR_ADDRESS_REG    					=> X"00108100", -- !TODO: check SYNC footer, was x"000000d5"
        BUF_PTR_ADDRESS    					    => x"000000d9",
        STREAM_CTRL    					        => x"000000dd",
        HEADERS_CTRL_REG    					=> x"000000e1",
        HEADERS_SAMP_TIME_REG    				=> x"0000001f",
        DBG_READING_CNT    					    => "000"&x"0e9"
    );


  -- CDM TX -> TMB BUFFER
  tx_serdes_buffer:component tx_ctrl_serdes_wrap
    generic map (
        G_PARAMS_LEN            => 16,
        G_TX_DATA_PACKET_SIZE   => x"00000006", -- 128B
        G_TX_HEADER_PACKET_SIZE => x"02",
        G_TX_FOOTER_PACKET_SIZE => x"02",
        G_HEADERS         => '0',
        G_RESET_POLARITY  => '1'
    )
    port map (
        CLK_50M              	    => clk_50M_sig,
        CLK_100M              	    => clk_100M_sig,
        CLK_200M              	    => clk_200M_sig,
        ACLK                  	    => aclk_sig,

        RESET           		    =>reset_sig,
		INIT_DONE 					=>'1',
		SYNC_DEBUG_REG             => x"00000000",
		MASTERn_SLAVE				=> '0',
        NUMBER_OF_SLICES            => x"0010", -- 16 slices
        MAKE_DATA        	        => make_data_sig,
        IP_LONG          	        => rd_req_sig,
        DFS              	        => dfs_sig,
        TX_TRI_IN                   => '1',
        TX_TRI_O                    => open,
        TX_DATA_O                   => ser_data_o2_sig,

        CT_TYPE                                 => X"00000040", -- x"00000001",
        DMS_STATUS_REG                          => x"00000005",
        DMS_ERROR                               => x"00000009",
        INTEGRATION_TIME_IN_REG                 => x"0000000d",
        REF_CONVERTOR                           => x"00000011",
        L_DMS_TEMP                              => x"00000015",
        R_DMS_TEMP                              => x"00000019",
        FANS_SPEED_DMS_TROUBLESHOOTING          => x"0000001d",
        READING_NUMBER_REG                      => x"00000021",
        DETECTION_SETTING_1                     => x"00000025",
        DETECTION_SETTING_2                     => x"00000029",
        DETECTION_SETTING_3                     => x"0000002d",
        DETECTION_SETTING_4                     => x"00000031",
        RESEND_COUNTER                          => x"00000035",
        VERTICAL_COUCH_POSITION                 => x"00000039",
        HORIZONTAL_COUCH_POSITION               => x"0000003d",
        GANTRY_TILT                             => x"00000041",
        ROTOR_ANGLE_ACQUISITION                 => x"00000045",
        ROTOR_ANGLE_DATA_SENDING                => x"00000049",
        HW_LINES_1                              => x"0000004d",
        HW_LINES_2                              => x"00000800", -- [11..10] - Slice Merging (RLT_SLICE_MERGE_FACTOR ), 0 -	No Slice Merging, 1	- Merged 2 Slices, 2 - Merged 4 Slices   , was x"00000051",
        BAD_READING_DETAILS                     => x"00000055",
        UID_REG                                 => x"0000BEEF", -- x"00000059",
        SHOT_COUNTER                            => x"0000005d",
        ANGULAR_DENOMINATOR                     => x"00000061",
        TIME_STAMP_LOW                          => x"00000065",
        TIME_STAMP_HIGH                         => x"00000069",
        NUMBER_OF_DETECTORS                     => x"000004A0", -- x"0000006d",
        UTC_TIME_LSB                            => x"00000071",
        UTC_TIME_MSB                            => x"00000075",
        ADDR_DMS_TYPE_REG                       => x"00000079",
        CAPABILITY_BITS_H                       => x"0000007d",
        TUBE_MA_COMMAND                         => x"00000081",
        ACTUAL_TUBE_MA                          => x"00000085",
        COLLIMATOR_1_REAR_BLADE                 => x"00000089",
        GRID_VOLTAGE_1                          => x"0000008d",
        GRID_VOLTAGE_2                          => x"00000091",
        COLLIMATOR_2_FRONT_BLADE                => x"00000095",
        CAPABILITY_BITS_M                       => x"00000099",
        DMS_TROUBLESHOOTING_1                   => x"0000009d",
        DMS_TROUBLESHOOTING_2                   => x"000000a1",
        FILAMENT_CURRENT                        => x"000000a5",
        MA                                      => x"000000a9",
        KV    					                => x"000000ad",
        COLLIMATOR_3    					    => x"000000b1",
        CAPABILITY_BITS_L    					=> x"000000b5",
        COLLIMATOR_4    					    => x"000000b9",
        ECG    					                => x"000000bd",
        DOM    					                => x"000000c1",
        DATA_POINTER_0    					    => x"000000c5",
        DATA_POINTER_1    					    => x"000000c9",
        STAMP    					            => x"0000FACE", -- x"000000cd",
        RLT_ADDRESS_REG    					    => x"000000d1",
        HD_PTR_ADDRESS_REG    					=> x"000000d5",
        BUF_PTR_ADDRESS    					    => X"00108800", -- !TODO: check BUFFER data, was x"000000d9"
        STREAM_CTRL    					        => X"00000002", -- !TODO: check BUFFER data, was x"000000dd"
        HEADERS_CTRL_REG    					=> x"000000e1",
        HEADERS_SAMP_TIME_REG    				=> x"000000e5",
        DBG_READING_CNT    					    => "000"&x"0e9"
    );

-- rx_serdes_sync:component RX_Zynq
--     generic map (
--       IDLE_word    => x"B5",
--           StartWord    => x"21",
--           Stream_type1  => x"43",
--           Stream_type2 => x"DD",
--           TapWidth     => 9,
--           ParallelWidth  => 8,
--       NumHeaderBytes => 2,
--           NumDataBytes  => 128,
--           NumFooterBytes => 8
--     )
--     port map (
--
--         RESET       		   =>reset_sig,
--         CLKDIV          	    =>clk_50M_sig,
--         	FCLK      		        =>clk_200M_sig,  --serial clock input side
--         	Channel_RDY   	       => '1',
--         	sDataIn               => ser_data_o_sig,
--         	IDLY_CNT  		      => open,
--         	RX_det_o       	      => open,
--         	start_valid           => open,
--         	Headers_valid         => open,
--         	data_valid            => open,
--         	Footers_valid         => open,
--         	IP_pckt_valid         => open,
--         	packet_received       => open,
--         	good_packet_received  => open,
--         	bad_packet_received   => open,
--         	crc_error             => open,
--         std_error             => open
--     );

  -- 14/09/2023 ES: TMB RX SYNC
  rx_serdes_sync: IP_DATAVAL_HEADER_TOP
    generic map (
      IP_DATA_OUT_VAL => IP_DATA_OUT_VAL,
      HEADER_DATA_OUT_VAL => HEADER_DATA_OUT_VAL,
      ADDR_BIT_VAL => ADDR_BIT_VAL,
      DATA_BIT_VAL => DATA_BIT_VAL)
    port map (
      CLK_200Mhz          => clk_200M_sig,
      CLK_50Mhz           => clk_50M_sig,
      RST                 => reset_sig,
      sDataIn             => ser_data_o_sig,
      Channel_RDY         => '1',
      IP_READY            => IP_READY,
      IP_DATA_OUT         => IP_DATA_OUT,
      HEADER_DATA_OUT     => HEADER_DATA_OUT, -- data from DPR
      clkb                => '0',
      enb                 => '0',
      web(0)              => '0',
      addrb               => header_dpr_addr, -- read address from DPR
      dinb                => (others => '0'),
      doutb               => open,      -- NU
      bad_packet_received => open,
      crc_error           => open,
      std_error           => open
    );


  -- rx_serdes_buffer:component RX_Zynq
  --     generic map (
  --       IDLE_word    => x"B5",
  --           StartWord    => x"21",
  --           Stream_type1  => x"43",
  --           Stream_type2 => x"DD",
  --           TapWidth     => 9,
  --           ParallelWidth  => 8,
  --       NumHeaderBytes => 2,
  --           NumDataBytes  => 6,
  --           NumFooterBytes => 2
  --     )
  --     port map (
  --
  --         RESET       		   =>reset_sig,
  --         CLKDIV          	    =>clk_50M_sig,
  --         	FCLK      		        =>clk_200M_sig,  --serial clock input side
  --         	Channel_RDY   	       => '1',
  --         	sDataIn               => ser_data_o2_sig,
  --         	IDLY_CNT  		      => open,
  --         	RX_det_o       	      => open,
  --         	start_valid           => open,
  --         	Headers_valid         => open,
  --         	data_valid            => open,
  --         	Footers_valid         => open,
  --         	IP_pckt_valid         => open,
  --         	packet_received       => open,
  --         	good_packet_received  => open,
  --         	bad_packet_received   => open,
  --         	crc_error             => open,
  --         std_error             => open
  --     );

  -- 14/09/2023 TMB RX BUFFER
  rx_serdes_buffer : RX_series7
    generic map (
      IDLE_word      => x"B5",
      StartWord      => x"21",
      Stream_type1   => x"43",
      Stream_type2   => x"DD",
      TapWidth       => 5,
      ParallelWidth  => 8,
      NumHeaderBytes => 2,  -- !debug: 14/09/2023 was  0
      NumDataBytes   => 6,  -- !debug: 14/09/2023 was  4
      NumFooterBytes => 2)  -- !debug: 14/09/2023 was  0
    port map (
      RESET                => reset_sig,
      CLKDIV               => clk_50M_sig,
      FCLK                 => clk_200M_sig,
      channel_RDY          => '1',
      sDataIn              => ser_data_o2_sig,
      IDLY_CNT             => open,
      RX_det_o             => buffer_byte,         -- data
      start_valid          => open,
      Headers_valid        => open,
      data_valid           => buffer_data_valid,
      Footers_valid        => open,
      IP_pckt_valid        => open, -- in header detected X"1B" byte
                                                -- !debug: 24/07/2023 old: buffer_req_valid, new: open
      packet_received      => buffer_req_valid, -- !debug: 24/07/2023 old: open, new: buffer_req_valid
      good_packet_received => buffer_good_packet_received,
      bad_packet_received  => buffer_bad_packet_received,
      crc_error            => open,
      std_error            => open
      );


  misc_pr: process (clk_50M_sig, reset_sig) is
  begin  -- process misc_pr
    if (reset_sig = '1') then           -- asynchronous reset (active HIGH)
      buffer_payload <= (others => '0');
      buf_ptr_address_from_buffer <= (others => '0');
      stream_ctrl_from_buffer <= (others => '0');
    elsif (clk_50M_sig'event and clk_50M_sig = '1') then  -- rising clock edge

      if (buffer_data_valid = '1') then
        buffer_payload <= buffer_byte & buffer_payload(8*6-1 downto 8);
      elsif (buffer_req_valid = '1') then
        buf_ptr_address_from_buffer <= buffer_payload(31 downto 0);
        stream_ctrl_from_buffer <= buffer_payload(8*6-1 downto 40);
        buffer_payload <= (others => '0');
      end if;


    end if;
  end process misc_pr;


ip_cnt_process: process(clk_8M_sig)	is
begin
    if rising_edge(clk_8M_sig) then
        if (reset_sig = '1') then
            cnt_sig <= 0;
        else
            if (cnt_sig = 16000)  then  -- ES: IP period = 2mS
                cnt_sig <= 0;
            else
                cnt_sig <= cnt_sig+1;
            end if;
        end if;
    end if;
end process;

wr_rd_process: process(clk_8M_sig)	is
begin
    if rising_edge(clk_8M_sig) then
        if (reset_sig = '1') then
            ip_long_sig <= '0';
            rd_req_sig <= '0';
        else
            if (cnt_sig = 9500) then
                ip_long_sig <= '1';
            elsif (cnt_sig > 9500 and cnt_sig <= 9510 ) then
                ip_long_sig <= ip_long_sig;
            else
                ip_long_sig <= '0';
            end if;
            if (cnt_sig = 15000) then
                rd_req_sig <= '1';
            elsif (cnt_sig > 15000 and cnt_sig <= 15010 ) then
                rd_req_sig <= rd_req_sig;
            else
                rd_req_sig <= '0';
            end if;
        end if;
    end if;
end process;

clk_50M_proc:process
begin
    clk_50M_sig <= '0';
    wait for 10 ns;
    clk_50M_sig <= '1';
    wait for 10 ns;
end process;
clk_125M_proc:process
begin
    clk_100M_sig <= '0';
    wait for 5 ns;
    clk_100M_sig <= '1';
    wait for 5 ns;
end process;
clk_200M_proc:process
begin
    clk_200M_sig <= '0';
    wait for 2.5 ns;
    clk_200M_sig <= '1';
    wait for 2.5 ns;
end process;
-- clk_250M_proc:process
-- begin
--     clk_250M_sig <= '0';
--     wait for 2 ns;
--     clk_250M_sig <= '1';
--     wait for 2 ns;
-- end process;
clk_8M_proc:process
begin
    clk_8M_sig <= '0';
    wait for 62.5 ns;
    clk_8M_sig <= '1';
    wait for 62.5 ns;
end process;
-- ip_len_reg_proc:process
-- begin
--     ip_len_valid_sig <= '0';
--     ip_len_reg_sig <= x"00000100";
--     wait for 600 us;
--     ip_len_valid_sig <= '1';
--     ip_len_reg_sig <= x"00000700";
--     wait until (ip_len_ack_sig = '1') ;
--     ip_len_valid_sig <= '0';
--     wait for 600 us;
-- end process;
-- init_done_proc:process
-- begin
--     init_done_sig <= '0';
--     wait for 600 ns;
--     init_done_sig <= '1';
-- end process;
-- mod_en_reg_proc:process
-- begin
--     mod_en_sig <= '0';
--     wait for 600 us;
--     mod_en_sig <= '1';
--     wait for 600 us;
-- end process;
-- t_ip_len_reg_proc:process
-- begin
--     t_ip_valid_reg_sig <= '0';
--     t_ip_reg_sig <= x"00000300";
--     wait for 1000 us;
--     t_ip_valid_reg_sig <= '1';
--     t_ip_reg_sig <= x"00000a00";
--     wait until (t_ip_ack_reg_sig = '1') ;
--     t_ip_valid_reg_sig <= '0';
--     wait for 600 us;
-- end process;

cal_proc:process
begin

    make_data_sig <= '0';
    wait for 1000 us;
    make_data_sig <= '1';
    wait for 1000 us;
    make_data_sig <= '0';
    wait;
end process;

reset_proc:process
begin
    resetn_sig <= '0';
    reset_sig <= '1';
    wait for 500 ns;
    resetn_sig <= '1';
    reset_sig <= '0';
    wait;
end process;



end architecture;
