-------------------------------------------------------------------------------
-- Title      : AMS tile 26bit data
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : rx_ams_tiles_tb.vhd
-- Author     : Shinderman Eugene  <evgene@hbtech.co.il>
-- Company    : Philips Medical
-- Created    : 24/03/2021
-- Last update: 06/11/2023
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: from rx_tiles_26bit_tb.vhd
-------------------------------------------------------------------------------
-- !TODO: 12/10/2022
--  - fix file re-load to align sequence: do_file_close -> Phoebe_data_locked rise -> packet_start_v
--  - change Tiles_managment for Taichi
--  - for 4x HD tiles change NumOfTiles 4->8
--    signals: tiles_data_i, ACLK, SYNC, SCLK, SCS1, SDI, SDO
--
-- problems:
--  - SYNC from Tiles_managment and SYNC from iladata_packet_40bit_dw.csv not synced
--    v1. fix packet_start_v
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
USE work.phoebe.all;
library UNISIM;
use UNISIM.VComponents.all;

use std.textio.all;

entity rx_ams_tiles_tb is
end entity rx_ams_tiles_tb;


architecture ar of rx_ams_tiles_tb is

  signal rx_clk160, rx_clk160_phased : std_logic := '0';
  signal rst_n : std_logic := '0';

  constant DW_WIDTH : natural := 26;
  signal data_dw : std_logic_vector(DW_WIDTH-1 downto 0);
  signal data0, data0_dly, idle_data0, sync_data0, data_data0 : std_logic;
  signal sync_tx_strobe, sync_tx_strobe_r : std_logic;
  signal idle_bits_cnt : natural range 0 to 7; -- idle_bits_cnt_r
  signal sync_bits_cnt, data_bits_cnt : natural range 0 to 25;
  -- signal sync_bits_cnt_r, data_bits_cnt_r : natural range 0 to 25;
  signal sync_tx_end, sync_tx_end_r, data_tx_end, data_tx_end_r : boolean; -- idle_tx_end

  type TILE_DATA_TYP is (IDLE_ST, SYNC_ST, DATAW_ST);
  signal tile_data_st : TILE_DATA_TYP;

  signal tile_words_cnt : natural range 0 to 255;
  -- signal tile_bit_cnt : natural range 0 to 255;


  signal clk_in : std_logic := '0'; -- @50MHz
  signal rx_clk20 : std_logic := '0';
  signal CLK_100M, CLK_200, MCLK  : std_logic := '0';

  signal start_align_reg : std_logic := '0';   -- 12/10/2022

  signal tiles_data_i, tiles_data_i_n : std_logic_vector (3 downto 0); -- 4x HD tiles
  signal IP, IP_i, buffer_go, buffer_go_r : std_logic;
  signal CTL : std_logic_vector (1 downto 0);

  signal ACLK_Master, ACLK_Master_i : std_logic := '0';

  SIGNAL clk_cnt               : integer range 0 to 127 := 0; -- moved from phoebe_controller

  signal do_file_close_pre, do_file_close : boolean;
  signal line_num_s : natural range 0 to 2**16 := 0;
  signal idle_bits_cnt_s : natural range 0 to 7 := 0;  -- help to monitor idle_word in data0
  signal do_file_close_s : std_logic_vector(2 downto 0);

  component Register_Data_IF is
    port(
      --Register_IF INPUTS--
      SCLK : in std_logic;
      RST  : in std_logic;
      SDO  : in std_logic;              --FPGA to ASIC
      SCn  : in std_logic;
      --DATA_IF INPUTS--
      SYNC    : in std_logic;
      ACLK    : in std_logic;           --FPGA to ASIC
      D_START : in std_logic;
      DISCARD : in std_logic;
      --Register IF OUTPUT--
      SDI : out std_logic;              -- ASIC to FPGA
      --DATA IF OUTPUT--
      Operation_Mode_Initialized : out std_logic;
      Data_Out_en                : out std_logic;
      DATA1_OUT                  : out std_logic;
      DATA2_OUT                  : out std_logic
      );
  end component;

  signal ACLK			: std_logic_vector (3 downto 0); -- 4x HD tiles
	signal SYNC			: std_logic_vector (3 downto 0);
	signal SCLK			: std_logic_vector (3 downto 0);
	signal SCS1			: std_logic_vector (3 downto 0);
	signal SCS2			: std_logic_vector (3 downto 0); -- !TODO: 12/10/2022 requires for Taichi
	signal SDI			: std_logic_vector (3 downto 0);
	signal SDO			: std_logic_vector (3 downto 0);
  -- signal ACO			: std_logic_vector (3 downto 0);
  -- signal ACO_N		: std_logic_vector (3 downto 0);

  component REAL_TILE IS
    Generic ( --Bytes_per_det  : IN     integer range 3 to 5;
      IDLE_WORD       : IN     std_logic_vector (7 downto 0);
      START_WORD      : IN     std_logic_vector (39 downto 0);
      optional_footer : IN     std_logic
    );
    PORT(
      Bytes_per_det : in  integer range 3 to 5;
      RESET         : in  std_logic;
      ACLK          : in  std_logic;
      SYNC          : in  std_logic;
      DISCARD       : in  std_logic;
      CLKDIV        : in  std_logic;
      FCLK          : in  std_logic;
      SCSn          : in  std_logic;
      SDI           : in  std_logic;
      SCLK          : in  std_logic;
      SDO           : out std_logic;
      DATA1         : out std_logic
    );
  END component;

  signal real_tile_data   : std_logic :='0';

  constant DATA_FROM_FILE : boolean := TRUE; -- when false data from REAL_TILE model

  signal IP50 : std_logic; -- 27/10/2022

  -- signal footer_bits      : std_logic_vector(16*8-1 downto 0);

  signal buffer_tx_data_in	 : std_logic_vector (7 downto 0);
  signal buffer_tx_rd_empty	 : std_logic := '0';
  signal buffer_tx_rd_req, buffer_tx_rd_req_r	 : std_logic;

  signal TMB_DATA_out, SYNC_DATA_out, Buffer_TX_DATA_out : std_logic;
  signal Sync_P : std_logic;
  signal Sync_N : std_logic;

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
      RX_ERRs              : out std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      );
  end component RX_series7;

  signal channel_RDY : std_logic;
  signal rx_comm_clk, rx_fclk : std_logic := '0';

  signal mem_buf_fifo_rdata : std_logic_vector(15 downto 0);
  signal mem_buf_fifo_empty : std_logic;
  signal mem_buf_fifo_rd    : std_logic;
  signal mem_buf_reading_ready : std_logic := '0';

  -- signal dummy_header_cnt : natural range 0 to 128; -- 128bytes = 64words header
  -- signal dummy_header_data : std_logic_vector(7 downto 0);
  -- signal dummy_header_valid : std_logic;

  component Taichi_TMB_top is
    generic (
      incr_num : std_logic_vector(31 downto 0) := X"00000000");  -- for tests
    port (
      RESET          : in    std_logic;
      MCLK           : in    std_logic_vector (6 downto 0);
      MCLK_N         : in    std_logic_vector (6 downto 0);
      ACLK_MASTER    : in    std_logic;
      ACLK_MASTER_N  : in    std_logic;
      Sync_P         : in    std_logic;
      Sync_N         : in    std_logic;
      Reg_in_P       : in    std_logic;
      Reg_in_N       : in    std_logic;
      Reg_out_P      : out   std_logic;
      Reg_out_N      : out   std_logic;
      DATA_OUT       : out   std_logic_vector (1 downto 0);
      DATA_OUT_N     : out   std_logic_vector (1 downto 0);
      Sig_2          : in    std_logic;
      Buffer_P       : in    std_logic;
      Buffer_N       : in    std_logic;
      Diag_out_P     : out   std_logic;
      Diag_out_N     : out   std_logic;
      Diag_in_P      : in    std_logic;
      Diag_in_N      : in    std_logic;
      Aux_Sync_P     : out   std_logic;
      Aux_Sync_N     : out   std_logic;
      Aux_Reg_out_P  : out   std_logic;
      Aux_Reg_out_N  : out   std_logic;
      Aux_Reg_in_P   : in    std_logic;
      Aux_Reg_in_N   : in    std_logic;
      AUX_DATA_IN    : in    std_logic_vector (1 downto 0);
      AUX_DATA_IN_N  : in    std_logic_vector (1 downto 0);
      Aux_Sig_2      : out   std_logic;
      Aux_Buffer_P   : out   std_logic;
      Aux_Buffer_N   : out   std_logic;
      Aux_Diag_in_P  : in    std_logic;
      Aux_Diag_in_N  : in    std_logic;
      Aux_Diag_out_P : out   std_logic;
      Aux_Diag_out_N : out   std_logic;
      RESETn         : out   std_logic_vector (3 downto 0);
      ACLK           : out   std_logic_vector (3 downto 0);
      SYNC           : out   std_logic_vector (3 downto 0);
      D_START        : out   std_logic_vector (3 downto 0);
      DISCARD        : out   std_logic_vector (3 downto 0);
      TILES_CLK      : out   std_logic;
      TILES_CLK_N    : out   std_logic;
      SCLK           : out   std_logic_vector (3 downto 0);
      SCS1           : out   std_logic_vector (3 downto 0);
      SCS2           : out   std_logic_vector (3 downto 0);
      SDI            : out   std_logic_vector (3 downto 0);
      SDO            : in    std_logic_vector (3 downto 0);
      ACO            : in    std_logic_vector (3 downto 0);
      ACO_N          : in    std_logic_vector (3 downto 0);
      DATA1          : in    std_logic_vector (3 downto 0);
      DATA1_N        : in    std_logic_vector (3 downto 0);
      DATA2          : in    std_logic_vector (3 downto 0);
      DATA2_N        : in    std_logic_vector (3 downto 0);
      DISABLE_CLK0n  : out   std_logic;
      DISABLE_CLK1n  : out   std_logic;
      DISABLE_SLAVEn : out   std_logic;
      DISABLE_APOSn  : out   std_logic;
      DISABLE_ANEGn  : out   std_logic;
      HW_REV         : in    std_logic_vector (3 downto 0);
      SCL            : inout std_logic_vector (1 downto 0);
      SDA            : inout std_logic_vector (1 downto 0);
      PGOOD_0_75V    : in    std_logic;
      PGOOD_1_0V     : in    std_logic;
      PGOOD_1_5V     : in    std_logic;
      PGOOD_1_8V     : in    std_logic;
      PGOOD_P1_5V    : in    std_logic;
      PGOOD_2_5V     : in    std_logic;
      STATUS_LEDS    : out   std_logic_vector(1 downto 0);
      HEATER_1       : out   std_logic;
      HEATER_2       : out   std_logic;
      SO_FLASH               : in  std_logic;   -- 01/02/2023
      SI_FLASH               : out std_logic;   -- 01/02/2023
      CS_FLASH               : out std_logic;   -- 01/02/2023
      DEBUG_TP       : out   std_logic_vector(7 downto 0));
  end component Taichi_TMB_top;

  signal DATA_OUT       : std_logic_vector (1 downto 0);
  signal DATA_OUT_N     : std_logic_vector (1 downto 0);

  -- component IBUFDS
  --   generic (
  --     CAPACITANCE      : string  := "DONT_CARE";
  --     -- CCIO_EN_M        : string  := "TRUE";
  --     -- CCIO_EN_S        : string  := "TRUE";
  --     DIFF_TERM        : boolean := FALSE;
  --     DQS_BIAS         : string  := "FALSE";
  --     IBUF_DELAY_VALUE : string  := "0";
  --     IBUF_LOW_PWR     : boolean := TRUE;
  --     IFD_DELAY_VALUE  : string  := "AUTO";
  --     IOSTANDARD       : string  := "DEFAULT"
  --     );
  --   port (
  --     O  : out std_ulogic;
  --     I  : in  std_ulogic;
  --     IB : in  std_ulogic
  --     );
  -- end component;
  --
  -- component OBUFDS
  --   generic (
  --     CAPACITANCE : string := "DONT_CARE";
  --     IOSTANDARD  : string := "DEFAULT";
  --     SLEW        : string := "SLOW"
  --     );
  --   port (
  --     O  : out std_ulogic;
  --     OB : out std_ulogic;
  --     I  : in  std_ulogic
  --     );
  -- end component;

  -- component TX_Zynq
  --   generic (
  --     IDLE_WORD      : std_logic_vector (7 downto 0)  := x"B5";
  --     StartWord      : std_logic_vector (7 downto 0)  := x"21";
  --     Stream_type1   : std_logic_vector (7 downto 0)  := x"43";
  --     Stream_type2   : std_logic_vector (7 downto 0)  := x"DD";
  --
  --     NumHeaderbytes : std_logic_vector (7 downto 0)  := x"00";
  --     NumDatabytes   : std_logic_vector (31 downto 0) := x"00000080";
  --     NumFooterbytes : std_logic_vector (7 downto 0)  := x"00"
  --     );
  --   port(
  --     RESET       : in  std_logic;
  --     CLKDIV      : in  std_logic;
  --     FCLK        : in  std_logic;
  --     STATn_DYN   : in  std_logic;
  --     GO          : in  std_logic;
  --     IP          : in  std_logic;
  --     PayloadSize : in  std_logic_vector (31 downto 0);
  --     TX_DATA_IN  : in  std_logic_vector (7 downto 0);
  --     RD_EMPTY    : in  std_logic;
  --     RD_CLK      : out std_logic;
  --     RD_REQ      : out std_logic;
  --     Tristate_i  : in  std_logic;
  --     Tristate_o  : out std_logic;
  --     TX_DATA_out : out std_logic
  --     );
  -- end component;
  component TX_series7
    generic (
      IDLE_WORD      : std_logic_vector (7 downto 0)  := x"B5";
      StartWord      : std_logic_vector (7 downto 0)  := x"21";
      Stream_type1   : std_logic_vector (7 downto 0)  := x"43";
      Stream_type2   : std_logic_vector (7 downto 0)  := x"DD";

      NumHeaderbytes : std_logic_vector (7 downto 0)  := x"02";
      NumDatabytes   : std_logic_vector (31 downto 0) := x"00000004";
      NumFooterbytes : std_logic_vector (7 downto 0)  := x"03"
      );
    port(
      RESET       : in  std_logic;
      CLKDIV      : in  std_logic;
      FCLK        : in  std_logic;
      STATn_DYN   : in  std_logic;
      GO          : in  std_logic;
      IP          : in  std_logic;
      PayloadSize : in  std_logic_vector (31 downto 0);
      DATA_IN     : in  std_logic_vector (7 downto 0);
      RD_EMPTY    : in  std_logic;
      RD_CLK      : out std_logic;
      RD_REQ      : out std_logic;
      DATA_out    : out std_logic
      );
  end component;

  signal Buffer_P       : std_logic;
  signal Buffer_N       : std_logic;

  signal Sig_2          : std_logic;

  component TX_serial is
    generic (
      NumDataBits : natural := 32;
      cnt_clk_max : natural := 4
      );
    port(
      RESET        : in  std_logic;
      CLK          : in  std_logic;
      serial_out   : out std_logic;
      valid_TX_VEC : in  std_logic_vector (NumDataBits-1 downto 0);
      TRIG         : in  std_logic
      );
  end component;

  signal   CLK1                  : std_logic := '0';
  signal   PCKT_start            : std_logic:='0';

  -- 22/01/2023 Tzvika's SYNC tester
  -- component tx_ctrl_serdes_wrap is
  --   generic (
  --     G_PARAMS_LEN            : integer range 0 to 64;
  --     G_TX_DATA_PACKET_SIZE   : std_logic_vector(32-1 downto 0);
  --     G_TX_HEADER_PACKET_SIZE : std_logic_vector(8-1 downto 0);
  --     G_TX_FOOTER_PACKET_SIZE : std_logic_vector(8-1 downto 0);
  --     G_RESET_ACTIVE_POLARITY : std_logic);
  --   port (
  --     CLK_50M                        : in  std_logic := '0';
  --     CLK_100M                       : in  std_logic := '0';
  --     CLK_200M                       : in  std_logic := '0';
  --     ACLK                           : in  std_logic := '0';
  --     INIT_DONE                      : in  std_logic := '0';
  --     RESET                          : in  std_logic := '0';
  --     SYNC_DEBUG_REG                 : in  std_logic_vector(31 downto 0);
  --     NUMBER_OF_SLICES               : in  std_logic_vector(16-1 downto 0);
  --     MAKE_DATA                      : in  std_logic := '0';
  --     IP_LONG                        : in  std_logic := '0';
  --     DFS                            : in  std_logic := '0';
  --     TX_TRI_IN                      : in  std_logic := '0';
  --     TX_TRI_O                       : out std_logic := '0';
  --     TX_DATA_O                      : out std_logic := '0';
  --     CT_TYPE                        : in  std_logic_vector(31 downto 0);
  --     DMS_STATUS_REG                 : in  std_logic_vector(31 downto 0);
  --     DMS_ERROR                      : in  std_logic_vector(31 downto 0);
  --     INTEGRATION_TIME_IN_REG        : in  std_logic_vector(31 downto 0);
  --     REF_CONVERTOR                  : in  std_logic_vector(31 downto 0);
  --     L_DMS_TEMP                     : in  std_logic_vector(31 downto 0);
  --     R_DMS_TEMP                     : in  std_logic_vector(31 downto 0);
  --     FANS_SPEED_DMS_TROUBLESHOOTING : in  std_logic_vector(31 downto 0);
  --     READING_NUMBER_REG             : in  std_logic_vector(31 downto 0);
  --     DETECTION_SETTING_1            : in  std_logic_vector(31 downto 0);
  --     DETECTION_SETTING_2            : in  std_logic_vector(31 downto 0);
  --     DETECTION_SETTING_3            : in  std_logic_vector(31 downto 0);
  --     DETECTION_SETTING_4            : in  std_logic_vector(31 downto 0);
  --     RESEND_COUNTER                 : in  std_logic_vector(31 downto 0);
  --     VERTICAL_COUCH_POSITION        : in  std_logic_vector(31 downto 0);
  --     HORIZONTAL_COUCH_POSITION      : in  std_logic_vector(31 downto 0);
  --     GANTRY_TILT                    : in  std_logic_vector(31 downto 0);
  --     ROTOR_ANGLE_ACQUISITION        : in  std_logic_vector(31 downto 0);
  --     ROTOR_ANGLE_DATA_SENDING       : in  std_logic_vector(31 downto 0);
  --     HW_LINES_1                     : in  std_logic_vector(31 downto 0);
  --     HW_LINES_2                     : in  std_logic_vector(31 downto 0);
  --     BAD_READING_DETAILS            : in  std_logic_vector(31 downto 0);
  --     UID_REG                        : in  std_logic_vector(31 downto 0);
  --     SHOT_COUNTER                   : in  std_logic_vector(31 downto 0);
  --     ANGULAR_DENOMINATOR            : in  std_logic_vector(31 downto 0);
  --     TIME_STAMP_LOW                 : in  std_logic_vector(31 downto 0);
  --     TIME_STAMP_HIGH                : in  std_logic_vector(31 downto 0);
  --     NUMBER_OF_DETECTORS            : in  std_logic_vector(31 downto 0);
  --     UTC_TIME_LSB                   : in  std_logic_vector(31 downto 0);
  --     UTC_TIME_MSB                   : in  std_logic_vector(31 downto 0);
  --     ADDR_DMS_TYPE_REG              : in  std_logic_vector(31 downto 0);
  --     CAPABILITY_BITS_H              : in  std_logic_vector(31 downto 0);
  --     TUBE_MA_COMMAND                : in  std_logic_vector(31 downto 0);
  --     ACTUAL_TUBE_MA                 : in  std_logic_vector(31 downto 0);
  --     COLLIMATOR_1_REAR_BLADE        : in  std_logic_vector(31 downto 0);
  --     GRID_VOLTAGE_1                 : in  std_logic_vector(31 downto 0);
  --     GRID_VOLTAGE_2                 : in  std_logic_vector(31 downto 0);
  --     COLLIMATOR_2_FRONT_BLADE       : in  std_logic_vector(31 downto 0);
  --     CAPABILITY_BITS_M              : in  std_logic_vector(31 downto 0);
  --     DMS_TROUBLESHOOTING_1          : in  std_logic_vector(31 downto 0);
  --     DMS_TROUBLESHOOTING_2          : in  std_logic_vector(31 downto 0);
  --     FILAMENT_CURRENT               : in  std_logic_vector(31 downto 0);
  --     MA                             : in  std_logic_vector(31 downto 0);
  --     KV                             : in  std_logic_vector(31 downto 0);
  --     COLLIMATOR_3                   : in  std_logic_vector(31 downto 0);
  --     CAPABILITY_BITS_L              : in  std_logic_vector(31 downto 0);
  --     COLLIMATOR_4                   : in  std_logic_vector(31 downto 0);
  --     ECG                            : in  std_logic_vector(31 downto 0);
  --     DOM                            : in  std_logic_vector(31 downto 0);
  --     DATA_POINTER_0                 : in  std_logic_vector(31 downto 0);
  --     DATA_POINTER_1                 : in  std_logic_vector(31 downto 0);
  --     STAMP                          : in  std_logic_vector(31 downto 0);
  --     MASTERn_SLAVE                  : in  std_logic);
  -- end component tx_ctrl_serdes_wrap;
  component tx_ctrl_serdes_wrap is
    generic(
      G_PARAMS_LEN            : integer range 0 to 64           := 16;  --ip default 3msec +/-1.5usec (its count res is ACLK freq)
      G_TX_DATA_PACKET_SIZE   : std_logic_vector(32-1 downto 0) := x"00000020";  --header data packet bytes size is : 64*16 bits => 64*2Bytes => 128B
      G_TX_HEADER_PACKET_SIZE : std_logic_vector(8-1 downto 0)  := x"08";  --header bytes number is : 8 bytes
      G_TX_FOOTER_PACKET_SIZE : std_logic_vector(8-1 downto 0)  := x"08";  --footer bytes number is : 8 bytes
      G_HEADERS               : std_logic                       := '1';    -- sync or buffer signal
      G_RESET_POLARITY : std_logic                       := '1'  --ip default 3msec +/-1.5usec (its count res is ACLK freq)
      );
    port(
      CLK_50M   : in std_logic := '0';
      CLK_100M  : in std_logic := '0';
      CLK_200M  : in std_logic := '0';
      ACLK      : in std_logic := '0';
      INIT_DONE : in std_logic := '0';

      RESET : in std_logic := '0';

      SYNC_DEBUG_REG : in std_logic_vector(31 downto 0);

      NUMBER_OF_SLICES : in  std_logic_vector(16-1 downto 0);
      MAKE_DATA        : in  std_logic := '0';
      IP_LONG          : in  std_logic := '0';
      DFS              : in  std_logic := '0';
      TX_TRI_IN        : in  std_logic := '0';
      TX_TRI_O         : out std_logic := '0';
      TX_DATA_O        : out std_logic := '0';

      CT_TYPE                        : in std_logic_vector(31 downto 0);
      DMS_STATUS_REG                 : in std_logic_vector(31 downto 0);
      DMS_ERROR                      : in std_logic_vector(31 downto 0);
      INTEGRATION_TIME_IN_REG        : in std_logic_vector(31 downto 0);
      REF_CONVERTOR                  : in std_logic_vector(31 downto 0);
      L_DMS_TEMP                     : in std_logic_vector(31 downto 0);
      R_DMS_TEMP                     : in std_logic_vector(31 downto 0);
      FANS_SPEED_DMS_TROUBLESHOOTING : in std_logic_vector(31 downto 0);
      READING_NUMBER_REG             : in std_logic_vector(31 downto 0);
      DETECTION_SETTING_1            : in std_logic_vector(31 downto 0);
      DETECTION_SETTING_2            : in std_logic_vector(31 downto 0);
      DETECTION_SETTING_3            : in std_logic_vector(31 downto 0);
      DETECTION_SETTING_4            : in std_logic_vector(31 downto 0);
      RESEND_COUNTER                 : in std_logic_vector(31 downto 0);
      VERTICAL_COUCH_POSITION        : in std_logic_vector(31 downto 0);
      HORIZONTAL_COUCH_POSITION      : in std_logic_vector(31 downto 0);
      GANTRY_TILT                    : in std_logic_vector(31 downto 0);
      ROTOR_ANGLE_ACQUISITION        : in std_logic_vector(31 downto 0);
      ROTOR_ANGLE_DATA_SENDING       : in std_logic_vector(31 downto 0);
      HW_LINES_1                     : in std_logic_vector(31 downto 0);
      HW_LINES_2                     : in std_logic_vector(31 downto 0);
      BAD_READING_DETAILS            : in std_logic_vector(31 downto 0);
      UID_REG                        : in std_logic_vector(31 downto 0);
      SHOT_COUNTER                   : in std_logic_vector(31 downto 0);
      ANGULAR_DENOMINATOR            : in std_logic_vector(31 downto 0);
      TIME_STAMP_LOW                 : in std_logic_vector(31 downto 0);
      TIME_STAMP_HIGH                : in std_logic_vector(31 downto 0);
      NUMBER_OF_DETECTORS            : in std_logic_vector(31 downto 0);
      UTC_TIME_LSB                   : in std_logic_vector(31 downto 0);
      UTC_TIME_MSB                   : in std_logic_vector(31 downto 0);
      ADDR_DMS_TYPE_REG              : in std_logic_vector(31 downto 0);
      CAPABILITY_BITS_H              : in std_logic_vector(31 downto 0);
      TUBE_MA_COMMAND                : in std_logic_vector(31 downto 0);
      ACTUAL_TUBE_MA                 : in std_logic_vector(31 downto 0);
      COLLIMATOR_1_REAR_BLADE        : in std_logic_vector(31 downto 0);
      GRID_VOLTAGE_1                 : in std_logic_vector(31 downto 0);
      GRID_VOLTAGE_2                 : in std_logic_vector(31 downto 0);
      COLLIMATOR_2_FRONT_BLADE       : in std_logic_vector(31 downto 0);
      CAPABILITY_BITS_M              : in std_logic_vector(31 downto 0);
      DMS_TROUBLESHOOTING_1          : in std_logic_vector(31 downto 0);
      DMS_TROUBLESHOOTING_2          : in std_logic_vector(31 downto 0);
      FILAMENT_CURRENT               : in std_logic_vector(31 downto 0);
      MA                             : in std_logic_vector(31 downto 0);
      KV                             : in std_logic_vector(31 downto 0);
      COLLIMATOR_3                   : in std_logic_vector(31 downto 0);
      CAPABILITY_BITS_L              : in std_logic_vector(31 downto 0);
      COLLIMATOR_4                   : in std_logic_vector(31 downto 0);
      ECG                            : in std_logic_vector(31 downto 0);
      DOM                            : in std_logic_vector(31 downto 0);
      DATA_POINTER_0                 : in std_logic_vector(31 downto 0);
      DATA_POINTER_1                 : in std_logic_vector(31 downto 0);
      STAMP                          : in std_logic_vector(31 downto 0);
      ----------------------------------------------------------------------
      RLT_PTR_ADDRESS_REG            : in std_logic_vector(31 downto 0);
      HD_PTR_ADDRESS_REG             : in std_logic_vector(31 downto 0);
      BUF_PTR_ADDRESS                : in std_logic_vector(31 downto 0);
      STREAM_CTRL                    : in std_logic_vector(7 downto 0); -- 11/10/2023 was 31
      -- RLT_SLICE_MERGE_FACTOR         : in std_logic_vector(31 downto 0);
      RLT_SLICE_MERGE_FACTOR	            :in std_logic_vector(7 downto 0);
      FS_MERGE_FACTOR       	            :in std_logic_vector(7 downto 0);
      FQ_STREAM                      : in std_logic_vector(7 downto 0);
      --------------------------------------------------------------------
      HEADERS_CTRL_REG               : in std_logic_vector(31 downto 0);
      HEADERS_SAMP_TIME_REG          : in std_logic_vector(31 downto 0);
      DBG_READING_CNT                : in std_logic_vector(15-1 downto 0);

      --------------------------------------------------------------------
      MASTERn_SLAVE : in std_logic
      );
  end component;


  signal READING_NUMBER_REG : std_logic_vector(31 downto 0) := (others => '0');
  signal CT_TYPE            : std_logic_vector(31 downto 0);
  signal HD_PTR_ADDRESS_REG : std_logic_vector(31 downto 0) := X"00108800"; -- FQ WR addr
  signal RLT_PTR_ADDRESS_REG : std_logic_vector(31 downto 0) := (others => '0'); -- EV WR addr

  component RX_TX_TESTER is
    generic (
      G_DATA_LENGTH : INTEGER;
      DIAGNSOTIC_REGS : BOOLEAN);
    port (
      START_TEST               : IN  STD_LOGIC;
      RST                      : IN  STD_LOGIC;
      RX_IN                    : IN  STD_LOGIC;
      clk_inPLL_p              : IN  std_logic;
      clk_inPLL_n              : IN  std_logic;
      TX_DATA_out              : OUT STD_LOGIC;
      CHANNEL_RDY              : OUT STD_LOGIC;
      STATUS                   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      MU_CTRL                  : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ADD_CONST_OFST_TO_MU     : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      CONST_OFST_VAL_TO_MU     : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ASIC_TST_CAL_CTRL_TEST   : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      TEST_ERROR               : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      WR_TO_TEST_ERROR         : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      DIAGNSOTICS              : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      GLOBL_IP_COEF            : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      DIAGNSOTICS_TMP          : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ASIC_DATA_ALIGNMENT      : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      MODULE_DATA_OUT_SELCTION : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_HL               : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_LL               : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_PER_TILE         : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PACKET_RECEIVED      : IN  STD_LOGIC;
      CRC_ERROR                : IN  STD_LOGIC;
      STD_ERROR                : IN  STD_LOGIC;
      OUT_CLKDIV_50MHz         : OUT STD_LOGIC;
      OUT_FCLK_200MHz          : OUT STD_LOGIC;
      PLL_locked               : out std_logic);
  end component RX_TX_TESTER;

  signal S_START_TEST  : STD_LOGIC ;
  signal Reg_out_P, Reg_out_N, Reg_out_i : std_logic;
  signal Reg_in_P, Reg_in_N, Reg_in_i : std_logic;
  signal Diag_out_P, Diag_out_N, Diag_out_i : std_logic;
  signal Diag_in_P, Diag_in_N, Diag_in_i : std_logic;

  constant stamp_time_const : time := 100 us; -- Time Stamp Incrementing by 1 for each 100usec passing
  constant ip_time_const : time := 125 ns; -- IP [L.S.B = 125ns]
  constant ip_period_const : time := 200 us; -- IP period
  signal TIME_STAMP_LOW, INTEGRATION_TIME_IN_REG : std_logic_vector(31 downto 0);

  constant DDR3_RQ_WORD : std_logic_vector(31 downto 0) := X"C0040008";  -- rq_cmds[1..0] + rq_rd_ptr[29..0]
  signal ddr3_rq_word_idx : natural range 0 to 7 := 0;

begin  -- architecture ar


  rst_n <= '0', '1' after 1 US;
  rx_clk160 <= not rx_clk160 after 3.125 NS;
  rx_clk160_phased <= transport rx_clk160 after 4.3 NS;    -- shifted or inverted clock
  clk_in <= not clk_in after 10 NS; -- 7.8125 for sys_clk64, 15.625 for @32Mhz  24/10/2022 @50MHz
  rx_clk20 <= not rx_clk20 after 25 NS;
  CLK_200 <= not CLK_200 after 2.5 NS;
  MCLK <= not MCLK after 3.125 NS;      -- !debug: 08/11/2022 temporary uses OSC @160MHz
  CLK1     <= not CLK1 after 10 ns;      -- TMB clock @100MHz !debug: 01/03/2023 now @50MHz
  CLK_100M <= not CLK_100M after 5 ns; -- !debug: 02/10/2023 problem, when uses @50MHz for tx_ctrl_
  
  -- buffer_go <= transport IP after 150 US; -- 27/03/2023
  buffer_go <= transport IP after 62 US; -- !debug: 02/07/2023 90 US for packet delay by 1 IP request must be close to IP
                                         -- 27/07/2023 62 US for short IP

  Taichi_TMB_top_1: Taichi_TMB_top
    generic map (
      incr_num => X"000D0001")
    port map (
      RESET          => "not"(rst_n),
      MCLK           => std_logic_vector'(MCLK&MCLK&MCLK&MCLK&MCLK&MCLK&MCLK),
      MCLK_N         => std_logic_vector'("not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)),
      ACLK_MASTER    => ACLK_MASTER,
      ACLK_MASTER_N  => "not"(ACLK_MASTER),
      Sync_P         => Sync_P,
      Sync_N         => Sync_N,
      Reg_in_P       => Reg_in_P,       -- !debug: 08/11/2022 temporary NA
      Reg_in_N       => Reg_in_N,       -- !debug: 08/11/2022 temporary NA
      Reg_out_P      => Reg_out_P,
      Reg_out_N      => Reg_out_N,
      DATA_OUT       => DATA_OUT,
      DATA_OUT_N     => DATA_OUT_N,
      Sig_2          => Sig_2,
      Buffer_P       => Buffer_P,
      Buffer_N       => Buffer_N,
      Diag_out_P     => open,
      Diag_out_N     => open,
      Diag_in_P      => Diag_in_P,       -- !debug: 08/11/2022 temporary NA
      Diag_in_N      => Diag_in_N,       -- !debug: 08/11/2022 temporary NA
      Aux_Sync_P     => open,
      Aux_Sync_N     => open,
      Aux_Reg_out_P  => open,
      Aux_Reg_out_N  => open,
      Aux_Reg_in_P   => '0',       -- !debug: 08/11/2022 temporary NA
      Aux_Reg_in_N   => '1',       -- !debug: 08/11/2022 temporary NA
      AUX_DATA_IN    => "00",       -- !debug: 08/11/2022 temporary NA
      AUX_DATA_IN_N  => "11",       -- !debug: 08/11/2022 temporary NA
      Aux_Sig_2      => open,
      Aux_Buffer_P   => open,
      Aux_Buffer_N   => open,
      Aux_Diag_in_P  => '0',       -- !debug: 08/11/2022 temporary NA
      Aux_Diag_in_N  => '1',       -- !debug: 08/11/2022 temporary NA
      Aux_Diag_out_P => open,
      Aux_Diag_out_N => open,
      RESETn         => open,
      ACLK           => ACLK,
      SYNC           => SYNC,
      D_START        => open,
      DISCARD        => open,
      TILES_CLK      => open,
      TILES_CLK_N    => open,
      SCLK           => SCLK,
      SCS1           => SCS1,
      SCS2           => SCS2,
      SDI            => SDI,
      SDO            => SDO,
      ACO            => X"0",
      ACO_N          => X"F",
      DATA1          => tiles_data_i,
      DATA1_N        => tiles_data_i_n,
      DATA2          => tiles_data_i,
      DATA2_N        => tiles_data_i_n,
      DISABLE_CLK0n  => open,
      DISABLE_CLK1n  => open,
      DISABLE_SLAVEn => open,
      DISABLE_APOSn  => open,
      DISABLE_ANEGn  => open,
      HW_REV         => X"0",
      SCL            => open,           -- I2C IF
      SDA            => open,           -- I2C IF
      PGOOD_0_75V    => '1',
      PGOOD_1_0V     => '1',
      PGOOD_1_5V     => '1',
      PGOOD_1_8V     => '1',
      PGOOD_P1_5V    => '1',
      PGOOD_2_5V     => '1',
      STATUS_LEDS    => open,
      HEATER_1       => open,
      HEATER_2       => open,
      SO_FLASH       => '1',
      SI_FLASH       => open,
      CS_FLASH       => open,
      DEBUG_TP       => open
      );


  tile_packet_pr: process (rx_clk160, rst_n) is
    constant ser_idle_byte_v : std_logic_vector(7 downto 0) := X"B5"; -- 1011 0101
    -- constant ser_start_word_v : std_logic_vector(7 downto 0) := "000000101010101000100001100110010001000010001";
    constant ser_start_word_v : std_logic_vector(DW_WIDTH-1 downto 0) := "00001100110010001000010001";
  begin  -- process tile_packet_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      sync_tx_strobe <= '0';
      idle_data0 <= '0';
      sync_data0 <= '0';
      data_data0 <= '0';
      idle_bits_cnt <= 0;
      sync_bits_cnt <= 0;
      data_bits_cnt <= 0;
      data_dw <= (others => '0');
      sync_tx_end <= FALSE;
      sync_tx_end_r <= FALSE;
      data_tx_end <= FALSE;
      data_tx_end_r <= FALSE;
      tile_words_cnt <= 0;

      do_file_close_pre <= FALSE;
      do_file_close <= FALSE;

    elsif (rx_clk160'event and rx_clk160 = '1') then  -- rising clock edge

      sync_tx_strobe <= IP;
      sync_tx_strobe_r <= sync_tx_strobe;

      sync_tx_end_r <= sync_tx_end;
      data_tx_end_r <= data_tx_end;

      if (tile_data_st = IDLE_ST) then
        idle_bits_cnt <= (idle_bits_cnt + 1) mod 8; -- index in byte
        idle_data0 <= ser_idle_byte_v(7-idle_bits_cnt); -- IDLE to TX
      else
        idle_bits_cnt <= 0;
        idle_data0 <= '0';
      end if;

      if (sync_tx_strobe = '1') then    -- send idle pattern (here 1uS)
        if (idle_bits_cnt = 7) then           -- when sync, assumed 8bit word (idle_tx_end)
          sync_bits_cnt <= 0;
        else
          sync_bits_cnt <= sync_bits_cnt + 1;
        end if;
      elsif (tile_data_st = DATAW_ST) then   -- 27/05/2021
          sync_bits_cnt <= 0;
      elsif (tile_data_st = SYNC_ST) then -- 26bit word
        if (sync_bits_cnt = DW_WIDTH-1) then
          sync_bits_cnt <= 0;
        else
          sync_bits_cnt <= sync_bits_cnt + 1;
        end if;
      end if;
      sync_tx_end <= (sync_bits_cnt = DW_WIDTH-1);
      sync_data0 <= ser_start_word_v(25-sync_bits_cnt);

      if (data_bits_cnt < DW_WIDTH-1) then
        if (sync_tx_end or sync_tx_end_r) then -- sync_bits_cnt = DW_WIDTH-1
          data_bits_cnt <= data_bits_cnt + 1;
          data_dw <= (others => '0');
        elsif (tile_data_st = DATAW_ST) then -- !debug: 29/03/2021
          data_bits_cnt <= data_bits_cnt + 1;
        end if;
      elsif (data_bits_cnt = DW_WIDTH-1) then
        data_bits_cnt <= 0;
        data_dw <= std_logic_vector(unsigned(data_dw) + 1);
      end if;
      data_tx_end <= (data_bits_cnt = DW_WIDTH-1);
      data_data0 <= data_dw(25-data_bits_cnt);

      if (tile_data_st = IDLE_ST) then
        tile_words_cnt <= 0;
      elsif (data_tx_end_r) then
        if (tile_words_cnt < 255) then
          tile_words_cnt <= tile_words_cnt + 1;
        end if;
      end if;

      if (line_num_s > 19200) then -- calc: <IP period> * <FREQ> = 201e-6 * 160e6
                                   -- !debug: 25/07/2023: 32160 for 200 uS ,
                                   -- 16000 for 100 uS, 19200 for 120 uS
                                   -- 27200 for 170 uS
                                   -- 20800 for 130 uS
                                   -- see CTL driver VVV
        do_file_close_pre <= TRUE;
      elsif (do_file_close) then
        do_file_close_pre <= FALSE;
      end if;
      if (do_file_close_pre and idle_bits_cnt_s = 0) then
        do_file_close <= TRUE;
      else
        do_file_close <= FALSE;
      end if;

    end if;
  end process tile_packet_pr;


  -- mark fields in tile packet from file
  tile_data_fsm_pr: process (rx_clk160, rst_n) is
  begin  -- process tile_data_fsm_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      tile_data_st <= IDLE_ST;
    elsif (rx_clk160'event and rx_clk160 = '1') then  -- rising clock edge

      case tile_data_st is
        when IDLE_ST =>
          if (sync_tx_strobe = '0' and sync_tx_strobe_r = '1') then
            tile_data_st <= SYNC_ST;
          end if;

        when SYNC_ST =>
          if (sync_tx_end_r) then
            tile_data_st <= DATAW_ST;
          end if;

        when DATAW_ST =>
          if (tile_words_cnt = 255 and data_bits_cnt = 25) then -- !debug: 27/05/2021
            tile_data_st <= IDLE_ST;
          end if;

      end case;
    end if;
  end process tile_data_fsm_pr;




  -- 01/06/2021 pattern generator replaces with packet from tiles (exported from LA)
  tile_packet2_pr: process is
    file in_file1  : text;
    variable status : file_open_status;
    variable l1     : line;
    variable good : boolean;
    -- variable r_data_str_v : string(1 downto 1);
    variable r_data_int_v, r_sync_v : integer := 0;
    variable line_num_v : natural range 0 to 2**16;
    variable char:      character;
    variable reading_num_v : natural range 0 to 255;
    variable packet_start_v : boolean := FALSE; -- only for position indicate in wave
    variable packet_crc_v : boolean := FALSE; -- only for position indicate in wave
    constant ADDED_LINES_C : natural := 0;  -- !debug: 01/06/2021 must be updated for each file   3000
    constant ADDED_LINES_40BIT_C : natural := 3664;  -- !debug: 13/07/2022 must be updated for each file   3000
    variable idle_bits_cnt_v : natural range 0 to 7 := 0;  -- help to monitor idle_word in data0
    constant IS_OLD_FILE : boolean := FALSE;               -- 27/06/2022 old for 26bit, new for 40bit
    variable do_file_close_v : std_logic_vector(2 downto 0);

  begin  -- process tile_packet2_pr

    -- 75 uSec after sync (IP) start byte_align

    data0 <= '0';
    reading_num_v := 0;

    wait for 3 US;                      -- start delay

    wait until Rising_Edge(rx_clk160);
    wait for 1 PS;                  -- protection from simulation glitches

    readings_l : loop

      if (IS_OLD_FILE) then       -- 27/06/2022
        FILE_OPEN(status, in_file1, "iladata_rx_orig_fixed.csv", READ_MODE);
      else
        FILE_OPEN(status, in_file1, "iladata_packet_40bit_dw.csv", READ_MODE);
      end if;
      -- if (status = OPEN_OK) then
      --   report "-------  file OPEN_OK -------";
      -- end if;
      line_num_v := 0;
      data0 <= '0';
      wait until Rising_Edge(rx_clk160);
      wait for 1 PS;                  -- protection from simulation glitches
      if (do_file_close_pre) then
        do_file_close_v := do_file_close_v(1 downto 0) & '1';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
      else
        do_file_close_v := do_file_close_v(1 downto 0) & '0';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
      end if;
      wait until Rising_Edge(rx_clk160);
      wait for 1 PS;                  -- protection from simulation glitches
      if (do_file_close_pre) then
        do_file_close_v := do_file_close_v(1 downto 0) & '1';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
      else
        do_file_close_v := do_file_close_v(1 downto 0) & '0';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
      end if;





      file_read_l : loop

        --  - insert ADDED_LINES_C lines to file, then update line_num_v condition
        --  - purpose: data must be started (packet_start_v) after IP,
        --             file must be reloaded before rising Realin_byte
        if (Endfile(in_file1) or status = STATUS_ERROR or (do_file_close_v(2) = '0' and do_file_close_v(1) = '1')) then --  or (line_num_v > ADDED_LINES_C + 10000)
        -- if (status = STATUS_ERROR or (do_file_close_v(2) = '0' and do_file_close_v(1) = '1')) then  -- !debug: 08/11/2022 try NOT close, when endfile
          if (status = STATUS_ERROR) then
            assert (FALSE) report "Can't open file!!!" severity FAILURE;
          elsif (do_file_close_v(2) = '0' and do_file_close_v(1) = '1') then
            good := FALSE;              -- file closed, no read
            File_Close (in_file1);
            if ((do_file_close_v(2) = '0' and do_file_close_v(1) = '1') and reading_num_v < 255) then
              reading_num_v := reading_num_v + 1;
            end if;
            report "-------  Next reading -------";
            wait until Rising_Edge(rx_clk160);
            wait for 1 PS;                  -- protection from simulation glitches
            if (do_file_close_pre) then
              do_file_close_v := do_file_close_v(1 downto 0) & '1';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
            else
              do_file_close_v := do_file_close_v(1 downto 0) & '0';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
            end if;
            exit file_read_l;
          else
            good := FALSE;              -- file closed, no read
            File_Close (in_file1);
            if ((do_file_close_v(2) = '0' and do_file_close_v(1) = '1') and reading_num_v < 255) then
              reading_num_v := reading_num_v + 1;
            end if;
            report "-------  End of File -------";
            exit file_read_l;
          end if;

        else

          -- if (not Endfile(in_file1)) then  -- !debug: 08/11/2022 try NOT close, when endfile
            ReadLine(in_file1, l1);       -- read next string from file
          -- else
          --   wait;
          -- end if;

          if (l1 = null or l1(l1'LEFT) = '#') then
            good := FALSE;              -- comments, no read
            next;
          else
            -- Line: Sample in Buffer,rx_in[1:1],SYNC_OBUF[1:1],TRIGGER

            if (IS_OLD_FILE) then       -- 27/06/2022 iladata_rx_orig_fixed.csv: rx_in - 2nd field, sync - NU
            read(l1, r_data_int_v, good);  -- read sample number
            read(l1, char);                -- read delimiter
            read(l1, r_data_int_v, good);  -- read DATA1 (rx_in) from tile
            else                        -- iladata_packet_40bit_dw.csv: rx_in - 4th field, sync - 5th field
              read(l1, r_data_int_v, good);  -- read sample number (1)
              read(l1, char);                -- read delimiter
              read(l1, r_data_int_v, good);  -- read Sample in Window (2)
              read(l1, char);                -- read delimiter
              read(l1, r_data_int_v, good);  -- read TRIGGER (3)
              read(l1, char);                -- read delimiter
              read(l1, r_data_int_v, good);  -- read DATA1 (rx_in) from tile (4)
              read(l1, char);                -- read delimiter
              read(l1, r_sync_v, good);  -- read sync from tile (5)
            end if;

            if (not do_file_close_pre) then -- 06/09/2023
              idle_bits_cnt_v := 1;
            else
              idle_bits_cnt_v := (idle_bits_cnt_v + 1) mod 8; -- bit index in byte
            end if;
            idle_bits_cnt_s <= idle_bits_cnt_v;

            -- if (r_data_str_v = "1") then
            if (r_data_int_v = 1) then
              data0 <= '1';
            else
              data0 <= '0';
            end if;
          end if;

          line_num_v := line_num_v + 1; -- line in file
          line_num_s <= line_num_v;
          do_file_close_s <= do_file_close_v;

          if (IS_OLD_FILE) then
            packet_start_v := (line_num_v > (ADDED_LINES_C + 795) and line_num_v < (ADDED_LINES_C + 820)); -- 795-820 for original file
            packet_crc_v := (line_num_v >= (ADDED_LINES_C + 7634) and line_num_v < (ADDED_LINES_C + 7658));  -- 7634-7658 for original file
          else
            packet_start_v := (line_num_v > (ADDED_LINES_40BIT_C + 295) and line_num_v < (ADDED_LINES_40BIT_C + 334));
            packet_crc_v := (line_num_v = (ADDED_LINES_40BIT_C + 10854)); -- !debug: not CRC, end packet
          end if;

          wait until Rising_Edge(rx_clk160);
          wait for 1 PS;                  -- protection from simulation glitches
          if (do_file_close_pre) then
            do_file_close_v := do_file_close_v(1 downto 0) & '1';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
          else
            do_file_close_v := do_file_close_v(1 downto 0) & '0';  -- !debug: 12/10/2022 temporary, was do_file_close_160m(1)
          end if;

        end if;


      end loop file_read_l;

      -- wait;
      -- wait until (not do_file_close); -- reopen file for next packet

    end loop readings_l;

  end process tile_packet2_pr;


  -- 10/08/2020 Phoebe related

  tiles_data_g1: if (DATA_FROM_FILE) generate
    tiles_data_i <= data0 & data0 & data0 & data0; -- no delay
    tiles_data_i_n <= "not"(data0) & "not"(data0) & "not"(data0) & "not"(data0); -- no delay
    -- tiles_data_i <= '0' & data0 & data0 & '0'; -- 2x tiles
    -- tiles_data_i_n <= '1' & "not"(data0) & "not"(data0) & '1'; -- 2x tiles
    -- tiles_data_i <= X"0"; -- no data from tiles
    -- tiles_data_i_n <= X"F";

    -- tiles_data_i <= data0_dly & data0_dly & data0_dly & data0_dly;
  end generate tiles_data_g1;
  tiles_data_g2: if (not DATA_FROM_FILE) generate
    tiles_data_i <= real_tile_data & real_tile_data & real_tile_data & real_tile_data; -- !debug: 28/06/2022 data from file replaced by
  end generate tiles_data_g2;
                                                 -- data from REAL_TILE model

  -- IP generation, !debug: for ASIC init Aron send one clock chip reset ("11"), then
  -- after 1 US one clock clock reset ("10"), then after 40 US one clock clock reset ("10")
  ip_pr : process is
  begin  -- process ip_pr

    -- wait for 550 US;                    -- !debug: 08/05/2023 temporary setting, test SPI init when no IP

    CTL <= "10";                        -- init_ck
    wait for 5 US;
    CTL <= "00";
    wait for 5 US;

    loop

      CTL <= "01";                      -- send IP pulse
      wait for 2 US;                    -- !debug: 09/11/2022 was 1 US
      CTL <= "00";
      READING_NUMBER_REG <= std_logic_vector(unsigned(READING_NUMBER_REG) + 1); -- 14/06/2023

      wait for 120 US;                  -- see line_num_s ^^^
                                        -- !debug: 25/07/2023 was 200 US

    end loop;

  end process ip_pr;

  CT_TYPE <= X"00000010", X"00000040" after 0.5 MS; -- here no byte swap

  IP_i <= '1' when (CTL = "01") else '0';
  -- IP <= << signal .rx_ams_tiles_tb.Taichi_TMB_top_1.IP : std_logic >>; -- !debug: 08/11/2022 replaced by IP, generated in Taichi_TMB_top

  misc_pr: process (clk_in) is
  begin  -- process misc_pr
    if (clk_in'event and clk_in = '1') then  -- rising clock edge

      -- !debug: 05/04/2021 how sync with CTL?
      -- if (CTL = "01") then
      --   clk_cnt <= 0;
      -- elsif (clk_cnt = (C_CLK_MAX-1)) then
      if (clk_cnt = (75-1)) then -- for @50MHz 1.5e-6/20e-9=75
        clk_cnt <= 0;
      else
        clk_cnt <= clk_cnt + 1;
      end if;

      if (clk_cnt = 0) THEN             -- similar to old phoebe_controller
        ACLK_Master_i <= '1';
      elsif (clk_cnt = (75 /2)) THEN
        ACLK_Master_i <= '0';
        IP <= IP_i;
      end if;

      if (now < 20 US) then
        ACLK_Master <= '0';
      else
        ACLK_Master <= ACLK_Master_i;
      end if;

      TIME_STAMP_LOW <= std_logic_vector(to_unsigned(now/stamp_time_const,32));
      INTEGRATION_TIME_IN_REG <= std_logic_vector(to_unsigned(ip_period_const/ip_time_const,32));

      buffer_tx_data_in <= DDR3_RQ_WORD(8*ddr3_rq_word_idx+7 downto 8*ddr3_rq_word_idx);
      buffer_tx_rd_req_r <= buffer_tx_rd_req;
      buffer_go_r <= buffer_go;
      if (buffer_go_r = '0' and buffer_go = '1') then
        ddr3_rq_word_idx <= 0;
        buffer_tx_rd_empty <= '0';
      elsif (ddr3_rq_word_idx /= 3) then
        if (buffer_tx_rd_req_r = '1') then
          ddr3_rq_word_idx <= ddr3_rq_word_idx + 1;
        end if;
        buffer_tx_rd_empty <= '0';
      else
        buffer_tx_rd_empty <= '1';
      end if;

    end if;
  end process misc_pr;

  -- ACLK_Master <= transport '0', ACLK_Master_i after 20 US;

  misc_20m_pr: process (rx_clk20, rst_n) is
  begin  -- process misc_20m_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)

    elsif (rx_clk20'event and rx_clk20 = '1') then  -- rising clock edge

      -- start_align_reg <= '0', '1' after 10 US; -- 12/10/2022
      if (DATA_FROM_FILE) then
        if (do_file_close_pre) then     -- 13/10/2022 after new file open alignment not valid
          start_align_reg <= '0';
        elsif (now < 10 US) then        -- before 1st alignment
          start_align_reg <= '0';
        else
          start_align_reg <= '1';
        end if;
      else
        -- start_align_reg <= SYNC(1);     -- !debug: 18/10/2022 not work
        if (now > 10 US) then
          start_align_reg <= '1';       -- !TODO: 18/10/2022 check CRC
        end if;
      end if;

    end if;
  end process misc_20m_pr;


  tiles_gen: for i in 0 to 3 generate

    -- !TODO: 18/10/2022 add second instance for slave, select SCS1, SCS2, then MUX
    --                   problem: no SDI, SDO MUX in AS5912 -> if SCS1 = '1' must be tri-state
    -- Idan's AMS ASIC model, uses with small patches only for check SPI register interface
    AMS_V6Tile_inst : Register_DATA_IF
      port map(
        --Register_IF INPUTS--
        SCLK                       => SCLK(i),  -- !debug: 04/05/2021 was SCLK(0), temporary replaced with Idan's style clock
        RST                        => "not"(rst_n),  -- !debug: 29/04/2021 in Idan's model uses active '1' reset,
                                                         -- in AS5911 active '0'
        SDO                        => SDI(i),
        SCn                        => SCS1(i),
        --DATA_IF INPUTS--
        SYNC                       => SYNC(i),
        ACLK                       => ACLK(i),
        D_START                    => '0',
        DISCARD                    => '0',
        --Register IF OUTPUT--
        SDI                        => SDO(i), -- output from AMS
        --DATA IF OUTPUT--
        Operation_Mode_Initialized => open,
        DATA1_OUT                  => open,  -- !TODO: 28/04/2021 mux S_DATA1_OUT with tiles_data_i
        DATA2_OUT                  => open   -- !TODO: 28/04/2021 mux S_DATA2_OUT with tiles_data_i
        );

  end generate tiles_gen;


  -- 28/06/2022 Liron AMS ASIC model
  REAL_TILE_inst : REAL_TILE
    generic map (
      IDLE_WORD       => x"B5",
      START_WORD      => x"5544332211", -- !debug: 28/06/2022 see Phoebe_pack.START_WORD,  was x"a987654321",
      optional_footer => '1'
      )
    port map(
      Bytes_per_det => 5,  -- !debug: 28/06/2022 was 4
      RESET         => "not"(rst_n),
      ACLK          => ACLK(1),         -- I: one tile instance for all
      SYNC          => SYNC(1),
      DISCARD       => '0', -- DISCARD,
      CLKDIV        => rx_clk20,
      FCLK          => rx_clk160,
      SCSn          => '0', -- SCSn,
      SDI           => '0', -- SDI,
      SCLK          => '0', -- SCLK,
      SDO           => open, -- SDO,
      DATA1         => real_tile_data -- !debug: 13/10/2022 problem: after SYNC no data -> alignment
                                      -- not valid
    );


  -- --  dummy footer
  -- -- !TODO: 07/09/2022 copy footer from TMCOR v.6
  -- footer_l: for i in 0 to 15 generate
  --   ii: if (i = 0) generate
  --     footer_bits(i*8+7 downto i*8) <= X"11";
  --   elsif (i = 15) generate
  --     footer_bits(i*8+7 downto i*8) <= X"88";
  --   else generate
  --     footer_bits(i*8+7 downto i*8) <= X"00";
  --   end generate ii;
  -- end generate footer_l;


  -- data from TMB:
  DATA1_inst : IBUFDS
  generic map (
    DIFF_TERM => TRUE, -- Differential Termination
    IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => "LVDS_25")
  port map (
    O  => TMB_DATA_out,                    -- Buffer output
    I  => DATA_OUT(0),                      -- Diff_p buffer input (connect directly to top-level port)
    IB => DATA_OUT_N(0)                     -- Diff_n buffer input (connect directly to top-level port)
    );


  -- !debug: 08/09/2022 Can't set ParallelWidth = 16, got error
  -- ** Failure:  Attribute Syntax Warning  The attribute  DATA_WIDTH  on /ISERDESE2 instance  is set to  16.
  -- The Legal values for this attribute are  2, 3, 4, 5, 6, 7, 8, 10 or 14
  RX_series7_1 : RX_series7
    generic map (
      IDLE_word      => x"B5",
      StartWord      => x"21",
      Stream_type1   => x"43",
      Stream_type2   => x"DD",
      TapWidth       => 5,
      ParallelWidth  => 8,
      NumHeaderBytes => 132,            -- 4+128
      NumDataBytes   => 1,             -- NA for dynamic packet, 0 - prohibited
      NumFooterBytes => 16)  -- !debug: 02/05/2023 for 16DW footer 16 -> 64
    port map (
      RESET                => "not"(rst_n),
      CLKDIV               => rx_comm_clk, -- comm_clk,
      FCLK                 => rx_fclk, -- FCLK,
      channel_RDY          => channel_RDY,
      sDataIn              => TMB_DATA_out, -- !debug: 02/11/2022 was simulation error, temporary disconnected TX_DATA_out,
      IDLY_CNT             => open,
      RX_det_o             => open,     -- data
      start_valid          => open,
      Headers_valid        => open,
      data_valid           => open,
      Footers_valid        => open,
      IP_pckt_valid        => open,
      packet_received      => open,
      good_packet_received => open,
      bad_packet_received  => open,
      RX_ERRs              => open
      );

  rx_comm_clk <= transport clk_in after 1.2 NS; -- was comm_clk
  rx_fclk <= transport clk_200 after 1.2 NS;       -- was fclk
  channel_RDY <= '0', '1' after 5 US;

  -- dummy_header_pr: process (clk_in, rst_n) is
  -- begin  -- process dummy_header_pr
  --   if (rst_n = '0') then               -- asynchronous reset (active low)
  --     dummy_header_cnt <= 0;
  --     dummy_header_data <= (others => '0');
  --     dummy_header_valid <= '0';
  --   elsif (clk_in'event and clk_in = '1') then  -- rising clock edge
  --
  --     if (IP50 = '1') then              -- for real header: when header FIFO ready
  --       dummy_header_cnt <= 128;
  --     elsif (dummy_header_cnt /= 0) then
  --       dummy_header_cnt <= dummy_header_cnt - 1;
  --     end if;
  --
  --     if (dummy_header_cnt = 1 or dummy_header_cnt = 128) then
  --       dummy_header_data <= X"FF";
  --     else
  --       dummy_header_data <= X"80";
  --     end if;
  --
  --     if (IP50 = '0' and dummy_header_cnt /= 0) then              -- for real header: when header FIFO ready
  --       dummy_header_valid <= '1';
  --     else
  --       dummy_header_valid <= '0';
  --     end if;
  --
  --   end if;
  -- end process dummy_header_pr;


  -- -- CDM TX.TX_Zynq -> TMB Buffer RX
  -- TX_Buffer : TX_series7
  --   generic map(
  --     IDLE_WORD      => x"B5",
  --     StartWord      => X"21",
  --     Stream_type1   => X"43",
  --     Stream_type2   => X"DD",
  --
  --     NumHeaderbytes => X"00",
  --     NumDatabytes   => X"00000004",    -- !debug: 23/07/2023 was X"00000080",    --128
  --     NumFooterbytes => X"00"
  --     )
  --   port map(
  --     RESET       => "not"(rst_n),
  --     CLKDIV      => rx_comm_clk,          --50
  --     FCLK        => rx_fclk,            --200
  --     STATn_DYN   => '0',
  --     GO          => buffer_go,         -- !debug: 24/01/2023 was: both IP and buffer request - same signal (IP)
  --                                       -- !TODO: 24/01/2023 from SYNC packet to BUFFER packet 100uS
  --     IP          => '1',    -- !debug: 23/07/2023 was: '1', new: '0'
  --     PayloadSize => X"00000001",
  --     DATA_IN  => buffer_tx_data_in,    -- !debug: 23/07/2023 was   X"55",
  --     RD_EMPTY    => buffer_tx_rd_empty,  -- !debug: 23/07/2023 was   '0',
  --     RD_CLK      => open,
  --     RD_REQ      => buffer_tx_rd_req,   -- !debug: 23/07/2023 was  open
  --     DATA_out => Buffer_TX_DATA_out
  --     );

  -- !debug: 25/07/2023 old, before BUFFER @400MHz changes for memory buffer requests
  TX_Buffer : TX_series7 -- TX_Zynq
    generic map(
      IDLE_WORD      => x"B5",
      StartWord      => X"21",
      Stream_type1   => X"43",
      Stream_type2   => X"DD",

      NumHeaderbytes => X"00",
      NumDatabytes   => X"00000080",    --128
      NumFooterbytes => X"00"
      )
    port map(
      RESET       => "not"(rst_n),
      CLKDIV      => rx_comm_clk,          --50
      FCLK        => rx_fclk,            --200
      STATn_DYN   => '0',
      GO          => buffer_go,         -- !debug: 24/01/2023 was: both IP and buffer request - same signal (IP)
                                        -- !TODO: 24/01/2023 from SYNC packet to BUFFER packet 100uS
      IP          => '1',               -- always IP
      PayloadSize => X"00000001",
      DATA_IN  => X"55",
      RD_EMPTY    => '0',
      RD_CLK      => open,
      RD_REQ      => open,
      DATA_out => Buffer_TX_DATA_out
      );


      Buffer_req_inst : OBUFDS
      generic map (
        IOSTANDARD => "LVDS_25",        -- Specify the output I/O standard
        SLEW       => "SLOW")           -- Specify the output slew rate
      port map (
        O  => Buffer_P,
        OB => Buffer_N,
        I  => Buffer_TX_DATA_out        -- Buffer input
        );

  -- Liron Sig_2 communication
  TX_serial_inst : TX_serial
    generic map (
      NumDataBits => 32,
      cnt_clk_max => 2
      )
    port map(
      RESET        => "not"(rst_n),
      CLK          => CLK1,             -- !debug: 01/03/2023 now 50/cnt_clk_max = @25MHz
      serial_out   => Sig_2,
      valid_TX_VEC => x"00000005", -- x"51242355",
      TRIG         => PCKT_start
      );

  process
  begin
    wait for 40 US;                    -- was 400 US
    for i in 1 to 100 loop
      PCKT_start <= '1';
      wait until CLK1 'event and CLK1 = '1';
      PCKT_start <= '1';
      wait until CLK1 'event and CLK1 = '1';
      PCKT_start <= '0';
      -- wait for 100 US;
    end loop;
  end process;


  SYNC_TX_inst : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",                        -- Specify the output I/O standard
      SLEW       => "SLOW")                           -- Specify the output slew rate
    port map (
      O  => Sync_P,
      OB => Sync_N,
      I  => SYNC_DATA_out                             -- Buffer input
      );

  -- Tzvika: CDM TX -> TMB SYNC RX
  tx_serdes_ip : tx_ctrl_serdes_wrap
    generic map (
      G_PARAMS_LEN            => 16,
      G_TX_DATA_PACKET_SIZE   => x"00000080",         -- 128B
      G_TX_HEADER_PACKET_SIZE => x"02",
      -- G_TX_FOOTER_PACKET_SIZE => x"0b", -- !debug: 11/10/2023 was x"08"
      G_TX_FOOTER_PACKET_SIZE => x"0C", -- 12/10/2023 !debug: 13/10/2023 try x"0b" -> x"0C"
      G_HEADERS               => '1',
      G_RESET_POLARITY => '1'
      )
    port map (
      CLK_50M                      => clk_in,
      CLK_100M                     => CLK_100M,         -- !debug: 22/01/2023 check, if OK
      CLK_200M                     => CLK_200,

      RESET                        => "not"(rst_n),
      INIT_DONE                    => '1',            -- !debug: 22/01/2023 check, if OK
      ACLK                         => ACLK_Master,    -- !debug: 22/01/2023 check, if OK
      SYNC_DEBUG_REG               => x"DEADBEEF",
      NUMBER_OF_SLICES             => X"0040",        -- NU
      MAKE_DATA                    => '0',            -- make_data_sig,
      IP_LONG                      => IP,
      DFS                          => '0',            -- I: NU
      TX_TRI_IN                    => '1',
      TX_TRI_O                     => open,
      TX_DATA_O                    => SYNC_DATA_out,  -- from TX_Zynq

      -- I: header words
      CT_TYPE                      => CT_TYPE, -- !debug: 14/06/2023 was  CT_TYPE, x"00000004",
      DMS_STATUS_REG               => x"00000005",
      DMS_ERROR                    => x"00000006",
      INTEGRATION_TIME_IN_REG      => INTEGRATION_TIME_IN_REG, -- !debug: 14/06/2023 was  x"00000007",
      REF_CONVERTOR  => x"00000008",
      L_DMS_TEMP         => x"00000009",
      R_DMS_TEMP        => x"0000000a",
      FANS_SPEED_DMS_TROUBLESHOOTING   => x"0000000b",
      READING_NUMBER_REG              => READING_NUMBER_REG, -- !debug: 14/06/2023 was  x"0000000c",
      DETECTION_SETTING_1                 => x"0000000d",
      DETECTION_SETTING_2                 => x"0000000e",
      DETECTION_SETTING_3              => x"0000000f",
      DETECTION_SETTING_4             => x"00000010",
      RESEND_COUNTER               => x"00000011",
      VERTICAL_COUCH_POSITION      => x"00000012",
      HORIZONTAL_COUCH_POSITION    => x"00000013",
      GANTRY_TILT                  => x"00000014",
      ROTOR_ANGLE_ACQUISITION               => x"00000015",
      ROTOR_ANGLE_DATA_SENDING               => x"00000016",
      HW_LINES_1                     => x"00000017",
      HW_LINES_2               => x"00000018",
      BAD_READING_DETAILS              => x"00000055",
      UID_REG                          => x"0000BEEF", -- !debug: 14/06/2023 was  x"0000001a",
      SHOT_COUNTER                 => x"0000001b",
      ANGULAR_DENOMINATOR            => x"0000001c",

      TIME_STAMP_LOW          => TIME_STAMP_LOW, -- !debug: 14/06/2023 was  x"0000001d",
      TIME_STAMP_HIGH    => x"0000001e",
      NUMBER_OF_DETECTORS          => x"000004A0", -- !debug: 14/06/2023 was  x"0000001f",
      UTC_TIME_LSB => x"0000001f",
      UTC_TIME_MSB => x"00000020",
      ADDR_DMS_TYPE_REG        => x"00000021",
      CAPABILITY_BITS_H            => x"00000022",
      TUBE_MA_COMMAND                      => x"00000023",
      ACTUAL_TUBE_MA                 => x"00000024",
      COLLIMATOR_1_REAR_BLADE                 => x"00000025",
      GRID_VOLTAGE_1    => x"00000026",
      GRID_VOLTAGE_2       => x"00000027",
      COLLIMATOR_2_FRONT_BLADE           => x"00000028",

      CAPABILITY_BITS_M            => x"00000029",
      DMS_TROUBLESHOOTING_1       => x"0000002a",
      DMS_TROUBLESHOOTING_2             => x"0000002b",
      FILAMENT_CURRENT             => x"0000002c",
      MA                           => x"0000002d",
      KV                           => x"0000002e",
      COLLIMATOR_3              => x"0000002f",
      CAPABILITY_BITS_L            => x"00000030",
      COLLIMATOR_4             => x"00000031",
      ECG                          => x"00000032",
      DOM                        => x"00000033",
      DATA_POINTER_0             => x"00000034", -- W# 59
      DATA_POINTER_1             => x"00000035", -- W# 60
      STAMP             => x"0000FACE", -- W# 64 !debug: 14/06/2023 was  x"00000036",
        RLT_PTR_ADDRESS_REG    					=> RLT_PTR_ADDRESS_REG, -- X"00042000"
        HD_PTR_ADDRESS_REG    					=> HD_PTR_ADDRESS_REG, -- X"00108800", -- !TODO: check SYNC footer, was x"000000d5"
        BUF_PTR_ADDRESS 				        => x"000000d9", -- valid for BUFFER communication
        STREAM_CTRL    					        => x"dd", -- valid for BUFFER communication !debug: 12/10/2023 32bits -> 8bits
        -- NU for BUFFER   x"00000800", -- [11..10] - Slice Merging (RLT_SLICE_MERGE_FACTOR ), 0 -	No Slice Merging, 1	- Merged 2 Slices, 2 - Merged 4 Slices   , was x"00000051",
      -- RLT_SLICE_MERGE_FACTOR , -- 04/10/2023   x"00000800", -- [11..10] - Slice Merging (RLT_SLICE_MERGE_FACTOR ), 0 -	No Slice Merging, 1	- Merged 2 Slices, 2 - Merged 4 Slices   , was x"00000051",
        RLT_SLICE_MERGE_FACTOR => x"02", -- 2 - Merged 4 Slices
	FS_MERGE_FACTOR => X"00",
	FQ_STREAM	       => X"01", -- 1 - enable
        HEADERS_CTRL_REG    					=> x"000000e1",
        HEADERS_SAMP_TIME_REG    				=> x"00000008", -- !debug: 14/10/2023 was x"0000001f"
        DBG_READING_CNT    					    => "000"&x"0e9",
      MASTERn_SLAVE     => '0'
    );



  -- Registers tester
  RX_TX_TESTER_1: RX_TX_TESTER
    generic map (
      G_DATA_LENGTH => 32,
      DIAGNSOTIC_REGS => FALSE)
    port map (
      START_TEST               => S_START_TEST,
      RST                      => "not"(rst_n),
      RX_IN                    => Reg_out_i, -- serial RX from Reg_out
      clk_inPLL_p              => CLK_200,
      clk_inPLL_n              => "not"(CLK_200),
      TX_DATA_out              => Reg_in_i, -- serial TX to Reg_in
      CHANNEL_RDY              => open,     -- !debug: 04/04/2023 check if align OK
      STATUS                   => open,
      MU_CTRL                  => (others => '0'),
      ADD_CONST_OFST_TO_MU     => (others => '0'),
      CONST_OFST_VAL_TO_MU     => (others => '0'),
      ASIC_TST_CAL_CTRL_TEST   => (others => '0'),
      TEST_ERROR               => (others => '0'),
      WR_TO_TEST_ERROR         => open,
      DIAGNSOTICS              => (others => '0'),
      GLOBL_IP_COEF            => (others => '0'),
      DIAGNSOTICS_TMP          => (others => '0'),
      ASIC_DATA_ALIGNMENT      => (others => '0'),
      MODULE_DATA_OUT_SELCTION => (others => '0'),
      BAD_PIX_HL               => (others => '0'),
      BAD_PIX_LL               => (others => '0'),
      BAD_PIX_PER_TILE         => (others => '0'),
      BAD_PACKET_RECEIVED      => '0',
      CRC_ERROR                => '0',
      STD_ERROR                => '0',
      OUT_CLKDIV_50MHz         => open,
      OUT_FCLK_200MHz          => open,
      PLL_locked               => open
    );

   S_START_TEST<='0' , '1' AFTER 100 us;

  -- Diagnsotic Registers tester
  RX_TX_TESTER_2: RX_TX_TESTER
    generic map (
      G_DATA_LENGTH => 32,
      DIAGNSOTIC_REGS => TRUE)
    port map (
      START_TEST               => S_START_TEST,
      RST                      => "not"(rst_n),
      RX_IN                    => Diag_out_i, -- serial RX from Reg_out
      clk_inPLL_p              => CLK_200,
      clk_inPLL_n              => "not"(CLK_200),
      TX_DATA_out              => Diag_in_i, -- serial TX to Reg_in
      CHANNEL_RDY              => open,     -- !debug: 04/04/2023 check if align OK
      STATUS                   => open,
      MU_CTRL                  => (others => '0'),
      ADD_CONST_OFST_TO_MU     => (others => '0'),
      CONST_OFST_VAL_TO_MU     => (others => '0'),
      ASIC_TST_CAL_CTRL_TEST   => (others => '0'),
      TEST_ERROR               => (others => '0'),
      WR_TO_TEST_ERROR         => open,
      DIAGNSOTICS              => (others => '0'),
      GLOBL_IP_COEF            => (others => '0'),
      DIAGNSOTICS_TMP          => (others => '0'),
      ASIC_DATA_ALIGNMENT      => (others => '0'),
      MODULE_DATA_OUT_SELCTION => (others => '0'),
      BAD_PIX_HL               => (others => '0'),
      BAD_PIX_LL               => (others => '0'),
      BAD_PIX_PER_TILE         => (others => '0'),
      BAD_PACKET_RECEIVED      => '0',
      CRC_ERROR                => '0',
      STD_ERROR                => '0',
      OUT_CLKDIV_50MHz         => open,
      OUT_FCLK_200MHz          => open,
      PLL_locked               => open
    );

  Reg_out_inst : IBUFDS
  generic map (
    DIFF_TERM => TRUE, -- Differential Termination
    IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => "LVDS_25")
  port map (
    O  => Reg_out_i,                    -- Buffer output
    I  => Reg_out_P,                      -- Diff_p buffer input (connect directly to top-level port)
    IB => Reg_out_N                     -- Diff_n buffer input (connect directly to top-level port)
    );

  Diag_out_inst : IBUFDS
  generic map (
    DIFF_TERM => TRUE, -- Differential Termination
    IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => "LVDS_25")
  port map (
    O  => Diag_out_i,                    -- Buffer output
    I  => Diag_out_P,                      -- Diff_p buffer input (connect directly to top-level port)
    IB => Diag_out_N                     -- Diff_n buffer input (connect directly to top-level port)
    );

  Reg_in_inst : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Reg_in_P,
      OB => Reg_in_N,
      I  => Reg_in_i          -- Buffer input
      );

  Diag_in_inst : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Diag_in_P,
      OB => Diag_in_N,
      I  => Diag_in_i          -- Buffer input
      );


end architecture ar;
