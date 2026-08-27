-------------------------------------------------------------------------------
-- Title      : DDR3 testbench
-- Project    : Trident
-------------------------------------------------------------------------------
-- File       : ddr3_taichi_tb.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    : Philips Medical
-- Created    : 13/12/2016
-- Last update: 05/11/2023
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 13/12/2016  1.0      ilq00431  Created sct1_ddr3_tb.vhd
-------------------------------------------------------------------------------
-- Note: processes list
--   - cmds2ports_pr - commands to PORT bus (registers WR/RD)
--   - sorter_bfm_pr - RAW data write to DDR3
--   - ev_ctl_bfm_pr - EV data write to DDR3
--   - read_monitor_pr - save data readed from DDR3 to file
--   - comm1_bfm_pr - emulate Signals from Communication FPGA
--   - central_if_bfm_pr - emulate Signals from central_if block
--
-- 30/12/2019 changes
--  - in all hierarchy replace Altera IP to Xilinx
--  - DDR3 Micron model replaced to same as in trident_ddr3_tb_v2
--  - option: use cmds2ports_pr (registers)
--  - connect init_done_all to init_calib_complete
--  - change to 4 local header word in sorter_bfm_pr
--  - change num_words in sorter_bfm_pr according packet_size
--  - remove test_ddr3
--  - remove central_if_bfm_pr
--  - change comm1_bfm_pr or add  comm_ctl_pr from \\ilqhfaatc1msdgs\D_Drive\EugeneS\PR\MODEL\TMC_sCT1_integration_v107\Sources\sCT1_TC_tb.vhd
--  - ?! read_monitor_pr
--
-- 08/06/2023
-- !TODO:
--   - review all in clk20 clock domain
--   - remove all related to simulation data
--   - connect synthetic data from TMB
--   - connect real IP and header interface
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

library modelsim_lib;
use modelsim_lib.util.all;              -- signal spy

-- library accellera_ovl_vhdl;
-- use accellera_ovl_vhdl.std_ovl.all;
-- use accellera_ovl_vhdl.std_ovl_vhdl_components.all;

use work.tbuf_pack.all;
USE work.phoebe.all;


entity ddr3_taichi_tb is

end entity ddr3_taichi_tb;

use work.ddr3_model_pack.all;


architecture ddr3_taichi_tb_ar of ddr3_taichi_tb is

  constant USE_DDR_DRIVER : boolean := TRUE;  -- if false, skip ddr_driver hierarchy

  signal RESET_I, reset_sys_clk : std_logic := '0';
  signal CLK_50Mhz : std_logic := '0';
  signal rx_clk20 : std_logic := '0';


  -- DDR3 Micron model
  component ddr3_model
    generic(
      DM_BITS   : integer := 1;
      ADDR_BITS : integer := 16;
      ROW_BITS  : integer := 16;
      COL_BITS  : integer := 11;
      DQ_BITS   : integer := 8;
      DQS_BITS  : integer := 1;
      BA_BITS   : integer := 3
      );
    port(
      rst_n   : in    std_logic;
      ck      : in    std_logic;
      ck_n    : in    std_logic;
      cke     : in    std_logic;
      cs_n    : in    std_logic;
      ras_n   : in    std_logic;
      cas_n   : in    std_logic;
      we_n    : in    std_logic;
      dm_tdqs : inout std_logic_vector(DM_BITS-1 downto 0);
      ba      : in    std_logic_vector(BA_BITS-1 downto 0);
      addr    : in    std_logic_vector(ADDR_BITS-1 downto 0);
      dq      : inout std_logic_vector(DQ_BITS-1 downto 0);
      dqs     : inout std_logic_vector(DQS_BITS-1 downto 0);
      dqs_n   : inout std_logic_vector(DQS_BITS-1 downto 0);
      tdqs_n  : out   std_logic_vector(DQS_BITS-1 downto 0);
      odt     : in    std_logic
      );
  end component;

  signal ddr3_reset_n               : std_logic;
  signal ddr3_dq                    : std_logic_vector(DQ_WIDTH-1 downto 0);
  signal ddr3_dqs_p                 : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal ddr3_dqs_n                 : std_logic_vector(DQS_WIDTH-1 downto 0);
  signal ddr3_addr                  : std_logic_vector(ROW_WIDTH-1 downto 0);
  signal ddr3_ba                    : std_logic_vector(3-1 downto 0);
  signal ddr3_ras_n                 : std_logic;
  signal ddr3_cas_n                 : std_logic;
  signal ddr3_we_n                  : std_logic;
  signal ddr3_cke                   : std_logic_vector(1-1 downto 0);
  signal ddr3_ck_p                  : std_logic_vector(1-1 downto 0);
  signal ddr3_ck_n                  : std_logic_vector(1-1 downto 0);

  signal init_calib_complete             : std_logic;
  signal tg_compare_error                : std_logic;
  signal ddr3_cs_n                  : std_logic_vector((CS_WIDTH*1)-1 downto 0);
  signal ddr3_dm                    : std_logic_vector(DM_WIDTH-1 downto 0);
  signal ddr3_odt                   : std_logic_vector(ODT_WIDTH-1 downto 0);

  signal init_done_all : boolean;
  signal init_done_all_o : std_logic;

  signal DATA_SORT_DOUT : std_logic_vector (31 downto 0);  -- RAW data
  signal EVOLVING_DOUT  : std_logic_vector (31 downto 0);  -- EV data


  -- My simulation data generation IF
  signal DATA_SORTER_DATA_EN : std_logic;

  -- DDR driver (buffers) registers inputs
  signal FPGA_ID              : std_logic_vector (3 downto 0) := X"5";   --TBUF_R_L & FPGA_ID_I !debug: 09/02/2023 was X"5"

  signal DDR_A_LOCAL_RDATA_TB       : std_logic_vector(31 downto 0);
  signal DDR_A_LOCAL_RDATA_VALID_TB : std_logic;
  signal READ_BUS_DONE_TB           : std_logic;


  -- ddr_driver top
  component ddr_driver is
    port (
      global_reset_n    : in  std_logic; -- DDR3_AXI_IF.aresetn to DDR3 IP
      reset_sys_clk     : in  std_logic;
      DDR3_SOFT_RESET_N : in  std_logic; -- local reset for DDR3 interface
      CLK_50Mhz         : in  std_logic;
      sys_clk_p         : in  std_logic;  -- 19/09/2022 DDR3 sys_clk
      sys_clk_n         : in  std_logic;  -- 19/09/2022 DDR3 sys_clk
      ui_clk_o          : out std_logic;
      ui_clk_sync_rst_o : out std_logic; -- (O) reset from DDR3 IP

      DATA_SORTER_DATA_EN : in std_logic;
      DATA_SORT_DOUT      : in std_logic_vector (31 downto 0);
      EVOLVING_DATA_EN    : in std_logic;
      EVOLVING_DOUT       : in std_logic_vector (31 downto 0);

      IP50                : in std_logic; -- 22/10/2023
      params_ready        : in std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
      tmb_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
      tmb_header_rd : out std_logic;
      ev_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
      ev_header_rd : out std_logic;
      raw_wr_ptr_addr : in DDR3_ADDR_BUS_TYP;  -- !debug: 16/07/2023 was wr_ptr_num (WR reading index)
      ev_wr_slot_addr : in DDR3_ADDR_BUS_TYP;
      num_of_slices : in std_logic_vector (6 downto 0); -- 09/02/2023 was [7..0]
      num_of_slices_after_merge : in std_logic_vector(6 downto 0); -- 03/10/2023 must be even

      rq_cmds : in std_logic_vector (1 downto 0); -- 08/06/2023 [0] - WR, [1] - RD, [2] - EV('0')/REGULAR('1') - [3] - DDR soft reset
      rq_rd_ptr : in std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0); -- absolute RD pointer

      NO_ECC_CHK                  : in     std_logic;
      FPGA_ID                     : in     std_logic_vector (3 downto 0);
      UNIQ_ID                     : in     std_logic_vector (15 downto 0);
      ASSEMBLY_VERSION            : in     std_logic_vector(15 downto 0);
      INIT_DONE_A_O               : out    std_logic;
      READ_DATA_FSM_IDLE          : buffer std_logic;
      diag_sel                    : in std_logic_vector(2 downto 0); -- 29/10/2023
      DDR_DRIVER_RD               : in  std_logic;  -- from taichi_slice_builder.rx_fifo_rd: request next 16bit word from FIFO
      DDR_DRIVER_FIFO_EMPTY       : out std_logic;  -- to taichi_slice_builder.rx_fifo_empty
      DDR_DRIVER_DOUT             : out std_logic_vector (31 downto 0);  -- to taichi_slice_builder.rx_det: data from FIFO
      DDR_DRIVER_RD_READY         : out std_logic; -- !TODO: 11/07/2023 update driver to taichi_slice_builder.rd_reading_ready
      DDR_DRIVER_HEADER_BUS       : out std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
      DDR_DRIVER_HEADER_READY     : out std_logic; -- 19/03/2017
      ECC_ERROR                   : out    std_logic;

      RTL_buffer_free_size        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 08/10/2023
      RTL_buffer_OverRun          : OUT STD_LOGIC;
      HD_buffer_free_size         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      HD_buffer_OverRun           : OUT STD_LOGIC;
      OverRun_RTL_reset_flag      : IN  STD_LOGIC;
      OverRun_HD_reset_flag       : IN  STD_LOGIC;

      ddr3_dq                     : inout  std_logic_vector (7 downto 0);
      ddr3_dqs_n                  : inout  std_logic_vector (0 to 0);
      ddr3_dqs_p                  : inout  std_logic_vector (0 to 0);
      ddr3_addr                   : out    std_logic_vector (15 downto 0);
      ddr3_ba                     : out    std_logic_vector (2 downto 0);
      ddr3_ras_n                  : out    std_logic;
      ddr3_cas_n                  : out    std_logic;
      ddr3_we_n                   : out    std_logic;
      ddr3_reset_n                : out    std_logic;
      ddr3_ck_p                   : out    std_logic_vector (0 to 0);
      ddr3_ck_n                   : out    std_logic_vector (0 to 0);
      ddr3_cke                    : out    std_logic_vector (0 to 0);
      ddr3_cs_n                   : out    std_logic_vector (0 to 0);
      ddr3_dm                     : out    std_logic_vector (0 to 0);
      ddr3_odt                    : out    std_logic_vector (0 to 0);
      DDR_DRIVER_TESTPOINTS       : out    std_logic_vector (31 downto 0));
  end component ddr_driver;

  signal num_of_slices_after_merge : std_logic_vector(6 downto 0); -- 03/10/2023 must be even
  signal DDR_DRIVER_DOUT : std_logic_vector (31 downto 0);
  signal DDR_DRIVER_FIFO_EMPTY, DDR_DRIVER_RD_READY, DDR_DRIVER_RD : std_logic := '0';

  -- signal rq_cmds : std_logic_vector (3 downto 0); -- 08/06/2023 [0] - WR, [1] - RD, [2] - EV('0')/REGULAR('1') - [3] - DDR soft reset
  signal rq_cmds : std_logic_vector (1 downto 0); -- 23/07/2023 [0] - RD, [1] - EV('0')/REGULAR('1')
  signal rq_rd_ptr : std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0); -- absolute RD pointer

  -- EV signals
  signal EVOLVING_DATA_EN             : std_logic;  -- data strobe from EV control

  -- Test block signals
  signal powerup_test_mode : boolean := FALSE;

  signal  DDR_DRIVER_TESTPOINTS	: std_logic_vector(31 DOWNTO 0);

  constant DDR3_WAIT_DONE : boolean := TRUE;    -- override INIT_DONE from DDR3 core, enable test if core not ready

  signal params_ready : std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
  signal tmb_header_dout32, ev_header_dout32 : std_logic_vector (31 downto 0) := (0 => '1', others => '0');
  signal tmb_header_rd, ev_header_rd : std_logic;
  signal raw_wr_ptr_addr, ev_wr_slot_addr : DDR3_ADDR_BUS_TYP;  -- 16/07/2023
  signal temp_Num_of_Slices : std_logic_vector(6 downto 0) := 7UX"10";

  signal RAW_DATA_END_ADDR          : DDR3_ADDR_BUS_TYP;

  signal ddr3_core_errors_src, ddr3_core_errors_src_r : std_logic_vector(7 downto 0);
  signal ddr3_if_clk_o : std_logic;

  signal start_write : std_logic;
  signal start_read  : std_logic;
  signal waddr_offset, raddr_offset : std_logic_vector(29 downto 0);

  signal tile_wdata, fifo_axi_wdata : std_logic_vector(31 downto 0);
  signal burst_len                              : std_logic_vector(7 downto 0);
  signal fifo_rd_en, fifo_wdata_valid : std_logic;
  signal master_axi_state : std_logic_vector(7 downto 0);

  signal sys_clk_p                       : std_logic := '0';
  signal sys_clk_n                       : std_logic := '1';

  signal ui_clk, ui_clk_sync_rst         : std_logic;
  -- signal r_state, r_state_m00_1 : std_logic_vector(1 downto 0);
  signal ev_handshake_1_req : std_logic;
  signal fq_error_count, ev_error_count : std_logic_vector(31 downto 0);
  signal state_idle, state_idle_rise : std_logic;
  signal ev_if_req, ev_if_req_rise : std_logic;

  -- signal fq_reading_num : std_logic_vector(7 downto 0);
  signal header_dw_cnt : natural range 0 to 7;

  -- signal DDR3_SOFT_RESET_N : std_logic;
  signal UNIQ_ID           : std_logic_vector (15 downto 0);

  component slices_sorter is
    port (clk20_c2            : in std_logic;
          sys_clk             : in std_logic;
          rst_n               : in std_logic;
          NRST_20M            : in std_logic;
          IP20                : in std_logic;
          IP50                : in std_logic;
          dummy_data_sel      : in std_logic;
          diag_reg            : in std_logic_vector(15 downto 0);
          num_of_tiles        : in std_logic_vector(NumOfTiles-1 downto 0); -- 31/08/2023
          reading_number_freerun_cnt : in unsigned(15 downto 0); -- 14/06/2023
          tile_packet_ok_timeout_reg : in std_logic_vector(7 downto 0); -- 04/09/2023
          mu_ctl_reg          : in std_logic;
          take_rx_det_msb_reg : in std_logic;
          rx_det_shl_reg      : in std_logic;
          pipeline_ctl_reg    : in STD_LOGIC_VECTOR(31 downto 0);
          AMS_Time            : in std_logic_vector((NumOfTiles*16)-1 downto 0);
          AMS_Offset          : in std_logic_vector(15 downto 0);
          ibias               : in std_logic_vector(4 downto 0);
          global_ip_time_reg  : in std_logic_vector(15 downto 0);
          gain                : in STD_LOGIC_VECTOR(3 downto 0);
          Num_of_Slices       : in std_logic_vector(6 downto 0);		-- 30/10/2022
          asic_data_good_read : in std_logic_vector(NumOfTiles-1 downto 0); -- 04/09/2023
          RX_det_m            : in std_logic_vector((NumOfTiles*26)-1 downto 0);
          data_valid_m        : in std_logic_vector(NumOfTiles-1 downto 0);
          RX_det_s            : in std_logic_vector((NumOfTiles*26)-1 downto 0);
          data_valid_s        : in std_logic_vector(NumOfTiles-1 downto 0);
          fq_data_valid       : out std_logic;                           -- 30/10/2022
          fq_data_in          : out std_logic_vector(31 downto 0)
          );
  end component slices_sorter;

  signal IP, IP_i, synth_ip, ip_valid_sampled : std_logic := '0';
  signal ACLK_Master, ACLK_Master_i : std_logic := '0';
  signal aclk_shr_50m  : std_logic_vector(2 downto 0);
  SIGNAL clk_cnt               : integer range 0 to 127 := 0; -- moved from phoebe_controller
  signal CLK_200 : std_logic := '0';
  signal SYNC_DATA_out : std_logic;

  signal fq_data_valid       : std_logic;
  signal fq_data_in          : std_logic_vector(31 downto 0);

  -- 22/01/2023 Tzvika's SYNC tester
  component tx_ctrl_serdes_wrap is
    generic(
      G_PARAMS_LEN            : integer range 0 to 64           := 16;           --ip default 3msec +/-1.5usec (its count res is ACLK freq)
      G_TX_DATA_PACKET_SIZE   : std_logic_vector(32-1 downto 0) := x"00000020";  --header data packet bytes size is : 64*16 bits => 64*2Bytes => 128B
      G_TX_HEADER_PACKET_SIZE : std_logic_vector(8-1 downto 0)  := x"08";        --header bytes number is : 8 bytes
      G_TX_FOOTER_PACKET_SIZE : std_logic_vector(8-1 downto 0)  := x"08";        --footer bytes number is : 8 bytes
      G_HEADERS               : std_logic                       := '1';          -- sync or buffer signal
      G_RESET_POLARITY        : std_logic                       := '1'           --ip default 3msec +/-1.5usec (its count res is ACLK freq)
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
      RLT_PTR_ADDRESS_REG            : in  std_logic_vector(31 downto 0);
      HD_PTR_ADDRESS_REG             : in  std_logic_vector(31 downto 0);
      BUF_PTR_ADDRESS                : in  std_logic_vector(31 downto 0);
      STREAM_CTRL                    : in  std_logic_vector(7 downto 0);
      RLT_SLICE_MERGE_FACTOR         : in  std_logic_vector(7 downto 0);
      FS_MERGE_FACTOR                : in  std_logic_vector(7 downto 0);
      FQ_STREAM                      : in  std_logic_vector(7 downto 0);
      --------------------------------------------------------------------
      HEADERS_CTRL_REG               : in  std_logic_vector(31 downto 0);
      HEADERS_SAMP_TIME_REG          : in  std_logic_vector(31 downto 0);
      DBG_READING_CNT                : in  std_logic_vector(15-1 downto 0);

      --------------------------------------------------------------------
      MASTERn_SLAVE                  : in  std_logic
      );
  end component tx_ctrl_serdes_wrap;


  signal READING_NUMBER_REG : std_logic_vector(31 downto 0) := (others => '0');
  signal CT_TYPE            : std_logic_vector(31 downto 0);
  signal HD_PTR_ADDRESS_REG : std_logic_vector(31 downto 0) := X"00108800"; -- FQ WR addr
  signal RLT_PTR_ADDRESS_REG : std_logic_vector(31 downto 0) := (others => '0'); -- EV WR addr
  signal RLT_SLICE_MERGE_FACTOR, FS_MERGE_FACTOR : std_logic_vector(7 downto 0) := (others => '0');

  constant IP_DATA_OUT_VAL : INTEGER :=8;
  constant HEADER_DATA_OUT_VAL: INTEGER :=16;
  constant ADDR_BIT_VAL : INTEGER :=6;
  constant DATA_BIT_VAL : INTEGER :=16;

  component IP_DATAVAL_HEADER_TOP is
    generic (
      IP_DATA_OUT_VAL     : INTEGER;
      HEADER_DATA_OUT_VAL : INTEGER;
      ADDR_BIT_VAL        : INTEGER;
      DATA_BIT_VAL        : INTEGER;
      NumFooterBytes      : INTEGER
      );
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
      rlt_address_from_sync    : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
      hd_ptr_address_from_sync : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
      slice_merging_factor     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 11/10/2023
      fs_merging_factor        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      fq_stream_enable         : OUT STD_LOGIC;
      bad_packet_received : OUT std_logic;
      -- crc_error           : OUT std_logic;
      -- std_error           : OUT std_logic);
      RX_ERRs             : OUT	std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      );
  end component IP_DATAVAL_HEADER_TOP;


  signal Module_TX_RX_channel_RDY : std_logic;
  signal IP_READY            : STD_LOGIC;
  signal IP_DATA_OUT         : STD_LOGIC_VECTOR(IP_DATA_OUT_VAL-1 DOWNTO 0);
  signal HEADER_DATA_OUT     : STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);
  signal header_dpr_addr : std_logic_vector(5 downto 0) := (others => '0');

  signal rlt_address_from_sync    : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
  signal hd_ptr_address_from_sync : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
  signal slice_merging_factor     : STD_LOGIC_VECTOR(1 DOWNTO 0); -- 11/10/2023
  signal fs_merging_factor        : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal fq_stream_enable         : std_logic;
  signal stream_enable            : std_logic_vector(1 downto 0);

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
      DATA_out    : out std_logic;
      TX_ERRs     : out	std_logic_vector (1 downto 0) --TX_ERR(0) '1'  if empty when RD_REQ  ,RX_ERR(1) '1' if fifo not empty after packet transaction
      );
  end component;

  signal buffer_go, buffer_go_r : std_logic;
  signal buffer_tx_data_in	 : std_logic_vector (7 downto 0);
  signal buffer_tx_rd_empty	 : std_logic := '0';
  signal buffer_tx_rd_req, buffer_tx_rd_req_r	 : std_logic;
  signal ddr3_rq_word_idx : natural range 0 to 7 := 0;
  signal Buffer_TX_DATA_out, buffer_data_valid : std_logic;
  signal buffer_data : std_logic_vector(7 downto 0);
  signal ddr3_rq_word : std_logic_vector(31 downto 0);

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
      -- crc_error            : out std_logic;
      -- std_error            : out std_logic);
      RX_ERRs              : out std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      );
  end component RX_series7;


  component memory_buffer_if_tmp is
    generic (
      WORD_WIDTH : natural);
    port (
    sys_clk            : in  std_logic;  -- system clock @50MHz
    rst_n              : in  std_logic;
    IP50               : in  std_logic;
    Num_of_Slices      : in std_logic_vector(6 downto 0);		-- 30/10/2022
    slice_merge        : in  std_logic;                         -- 11/09/2023
    -- merge_factor       : in  std_logic_vector(4 downto 0);      -- 11/09/2023
    slice_merging_factor  : in std_logic_vector(1 DOWNTO 0); -- 11/10/2023
    rlt_address_from_sync : in std_logic_vector(31 DOWNTO 0); -- 08/10/2023
    stream_enable      : in std_logic_vector(1 downto 0);     -- 22/10/2023
    fq_data_valid      : in  std_logic;  -- 30/10/2022
    fq_data_in         : in  std_logic_vector(31 downto 0);
    tmb_header_valid   : in std_logic;
    tmb_header         : in std_logic_vector (15 downto 0);
    params_ready       : out std_logic_vector(1 downto 0);  -- 20/09/2022
    tmb_header_dout32  : out std_logic_vector (WORD_WIDTH-1 downto 0);
    tmb_header_rd      : in std_logic;
    ev_header_dout32   : out std_logic_vector (WORD_WIDTH-1 downto 0); -- !debug: 20/09/2022
    ev_header_rd       : in std_logic;
    num_of_slices_after_merge : out std_logic_vector(6 downto 0);   -- 22/10/2023
    DATA_SORTER_DATA_EN: out std_logic;
    DATA_SORT_DOUT     : out std_logic_vector (WORD_WIDTH-1 downto 0);
    EVOLVING_DATA_EN   : out std_logic;
    EVOLVING_DOUT      : out std_logic_vector (WORD_WIDTH-1 downto 0)
    );
  end component memory_buffer_if_tmp;

  signal dpr_header_valid, dpr_header_valid_r, sync_header_valid : std_logic;

  signal mem_buf_fifo_rdata : std_logic_vector(15 downto 0);
  signal mem_buf_fifo_empty : std_logic;
  signal mem_buf_fifo_rd    : std_logic;
  signal mem_buf_reading_ready : std_logic := '0';

  signal dpr_header_valid_shr : std_logic_vector(2 downto 0);
  signal sync_header_valid_cnt : natural range 0 to 127;

  type RD_REQ_REC is record
    cmd          : string(1 to 2);                 -- RA(W RD)/EV(RD)/WR/RS(T)/ST(OP)
    ptr          : std_logic_vector(31 downto 0);  -- now: address, option: pointer
    shedule_time : time;
  end record RD_REQ_REC;

  type RD_REQ_TYP is array (positive range <>) of RD_REQ_REC;
  -- -- note: ADDR_FIFO_BASE_ADDR = X"0040000"
  -- constant rd_req_c : RD_REQ_TYP := (
  --   ("RS",X"00000000",380 US),("RA",X"00040000", 800 US),
  --   ("RA",X"00040004", 900 US),("RA",X"00040008", 1500 US),
  --   ("RA",X"0004000C", 1700 US),("RA",X"00040010", 1900 US),
  --   ("ST",X"12341234", 3000 US)
  --   );
  -- note: ADDR_FIFO_BASE_ADDR = X"0108800"
  constant rd_req_c : RD_REQ_TYP := (
    ("RS",X"00000000",380 US),("RA",X"00108800", 800 US),
    ("RA",X"00108804", 900 US),("EV",X"00000000", 1100 US),
    ("EV",X"00000420", 1200 US),("RA",X"00108808", 1500 US),
    ("RA",X"0010880C", 1700 US),("RA",X"00108810", 1800 US),
    ("EV",X"00000840", 1900 US), ("ST",X"12341234", 3000 US)
    );
  alias test_seq_sig : RD_REQ_TYP is rd_req_c;

  constant stamp_time_const : time := 100 us; -- Time Stamp Incrementing by 1 for each 100usec passing
  constant ip_time_const : time := 125 ns; -- IP [L.S.B = 125ns]
  constant ip_period_const : time := 200 us; -- IP period
  signal TIME_STAMP_LOW, INTEGRATION_TIME_IN_REG : std_logic_vector(31 downto 0);


  -- for test: force arbiter bug
  --   - case when: gnt_ps = FQ_ST, mst_exec_state = IDLE, not gnt_hold
  type GNT_TYP is (RD_ST, EV_ST, FQ_ST); -- gnt_ps
  type MST_EXEC_STATE_TYP is (IDLE, INIT_WRITE, INIT_READ); -- mst_exec_state
  type EV_CTL_FSM_TYP is (IDLE, SET_ADDR_PARAMS, ADDR_LOAD, TX2EV_BUF_HEADER,
                          SET_DATA_PARAMS, TX2EV_BUF_DATA, WAIT4DONE);
  type RAW_DATA_CTL_FSM_TYP is (IDLE, SET_PTR_PARAMS, TX2ADDR_PTR_BUF, SET_HEADER_PARAMS, TX2DATA_BUF_HEADER, SET_DATA_PARAMS, TX2DATA_BUF_DATA, WAIT4DONE); -- was SET_PARAMS

  alias force_arbiter_bug : std_logic is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_if_req : std_logic >>;
  alias gnt_ps : GNT_TYP is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.axi4_master_vhdl_inst.U0.axi4_master_vhdl_v1_0_M00_AXI_inst.gnt_ps : GNT_TYP >>;
  alias mst_exec_state : MST_EXEC_STATE_TYP is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.axi4_master_vhdl_inst.U0.axi4_master_vhdl_v1_0_M00_AXI_inst.mst_exec_state : MST_EXEC_STATE_TYP >>;
  alias gnt_hold : boolean is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.axi4_master_vhdl_inst.U0.axi4_master_vhdl_v1_0_M00_AXI_inst.gnt_hold : boolean >>;
  alias EV_CTL_FSM_PS : EV_CTL_FSM_TYP is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.EV_CTL_FSM_PS : EV_CTL_FSM_TYP >>;
  alias RAW_CTL_FSM_PS : RAW_DATA_CTL_FSM_TYP is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.RAW_CTL_FSM_PS : RAW_DATA_CTL_FSM_TYP >>;
  alias axi_wait_cnt : natural range 0 to 255 is << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.axi_wait_cnt : natural range 0 to 255 >>;
  signal arbiter_bug_driver : std_logic;


begin  -- architecture ddr3_taichi_tb_ar

  -- arbiter_bug_driver <= '1' when (gnt_ps = FQ_ST and mst_exec_state = IDLE and not gnt_hold) else '0';
  arbiter_bug_driver <= '1' when (gnt_ps = FQ_ST and mst_exec_state = IDLE and RAW_CTL_FSM_PS = SET_DATA_PARAMS and axi_wait_cnt < 251) else '0';
  test1_pr : process (ui_clk) is
  begin  -- process test1_pr
    if (ui_clk'EVENT and ui_clk = '1') then  -- rising clock edge
      if (now > 900 US) then
        if (arbiter_bug_driver = '1') then
          force_arbiter_bug <= force arbiter_bug_driver;  -- !debug: 31/10/2023 force arbiter bug
        else
          force_arbiter_bug <= release;
        end if;
      else
        force_arbiter_bug <= release;
      end if;
    end if;
end process test1_pr;


  use_ddr_driver_g : if (USE_DDR_DRIVER) generate

    ddr_driver_1 : ddr_driver
      port map (
        global_reset_n              => reset_sys_clk,
        reset_sys_clk               => reset_sys_clk,
        DDR3_SOFT_RESET_N           => reset_sys_clk, -- '1',
        CLK_50Mhz                   => CLK_50Mhz,
        sys_clk_p                   => sys_clk_p,         -- 19/09/2022
        sys_clk_n                   => sys_clk_n,         -- 19/09/2022
        ui_clk_o                    => ui_clk,            -- 01/01/2020
        ui_clk_sync_rst_o           => ui_clk_sync_rst,   -- 01/01/2020
        ASSEMBLY_VERSION            => (1 => '0', others => '1'),   -- 10/02/2023 [1..0] = "01" 4Gb DDR3 -- chips, else 8Gb DDR3
        INIT_DONE_A_O               => INIT_DONE_ALL_O,
        DATA_SORTER_DATA_EN         => DATA_SORTER_DATA_EN,
        DATA_SORT_DOUT              => DATA_SORT_DOUT,
        EVOLVING_DATA_EN            => EVOLVING_DATA_EN,
        EVOLVING_DOUT               => EVOLVING_DOUT,

        IP50          => IP,            -- 30/10/2023
        params_ready  => params_ready,
        tmb_header    => tmb_header_dout32,     -- 08/06/2023 updates to 128bytes scan header
        tmb_header_rd => tmb_header_rd,  -- 21/09/2022
        ev_header    => ev_header_dout32, -- 17/08/2023
        ev_header_rd => ev_header_rd,     -- 17/08/2023
        raw_wr_ptr_addr => raw_wr_ptr_addr,     -- 16/07/2023
        ev_wr_slot_addr => ev_wr_slot_addr,     -- 17/08/2023
        num_of_slices => temp_Num_of_Slices,  -- 22/09/2022
        num_of_slices_after_merge => num_of_slices_after_merge, -- 30/10/2023
        diag_sel                  => (others => '0'),           -- 30/10/2023
        FPGA_ID               => FPGA_ID,
        READ_DATA_FSM_IDLE    => open,
        DDR_DRIVER_DOUT       => DDR_DRIVER_DOUT, -- 11/07/2023
        DDR_DRIVER_FIFO_EMPTY => DDR_DRIVER_FIFO_EMPTY, -- 11/07/2023
        DDR_DRIVER_RD         => DDR_DRIVER_RD,        -- 11/07/2023
        DDR_DRIVER_RD_READY    => DDR_DRIVER_RD_READY, -- 11/07/2023
        DDR_DRIVER_HEADER_BUS => open,
        ECC_ERROR             => open,
        NO_ECC_CHK            => '1',        -- !debug: 01/01/2020 disable ECC
        RTL_buffer_free_size  => open,       -- 30/10/2023
        RTL_buffer_OverRun    => open,
        HD_buffer_free_size   => open,
        HD_buffer_OverRun     => open,
        OverRun_RTL_reset_flag => '0',
        OverRun_HD_reset_flag  => '0',
        rq_cmds               => rq_cmds, -- !TODO: 31/07/2023 ddr3_rq_word(31 downto 30),
        rq_rd_ptr             => rq_rd_ptr, -- !TODO: 31/07/2023 ddr3_rq_word(28 downto 0),
        UNIQ_ID               => UNIQ_ID, -- !debug: 10/02/2023 (0 => '1', others => '0'),
        ddr3_addr             => ddr3_addr,  -- see DDR2_ADDR_ROW_BITS
        ddr3_ba               => ddr3_ba,    -- see DDR2_ADDR_BA_BITS
        ddr3_cas_n            => ddr3_cas_n,
        ddr3_cke(0)           => ddr3_cke(0),
        ddr3_cs_n(0)          => ddr3_cs_n(0),
        ddr3_dm               => ddr3_dm,
        ddr3_odt(0)           => ddr3_odt(0),
        ddr3_ras_n            => ddr3_ras_n,
        ddr3_we_n             => ddr3_we_n,
        ddr3_dq               => ddr3_dq,
        ddr3_dqs_p            => ddr3_dqs_p,
        ddr3_dqs_n            => ddr3_dqs_n,
        ddr3_ck_p             => ddr3_ck_p,
        ddr3_ck_n             => ddr3_ck_n,
        ddr3_reset_n          => ddr3_reset_n,
        -- TB signals
        DDR_DRIVER_TESTPOINTS => DDR_DRIVER_TESTPOINTS
        );

  end generate use_ddr_driver_g;



  -- DDR3 controller statuses
  ddr3_stat_pr: process (ui_clk) is
  begin  -- process ddr3_stat_pr
    if (ui_clk'event and ui_clk = '1') then  -- rising clock edge

      ddr3_core_errors_src_r <= ddr3_core_errors_src;

      assert not(<< signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.start_write : std_logic >> = '1' and << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.start_read : std_logic >> = '1') report "Error: start_write and start_read in same time" severity ERROR;

      -- assert not(<< signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.axi_if_req : std_logic_vector(2 downto 0) >> /= "000" and << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(0) = '0') report "Warning: request to AXI when mst_exec_state /= IDLE" severity ERROR;
      assert (<< signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "001" or << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "010" or << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "100" or << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "000") report "Error: multiple grant to AXI" severity ERROR;

      state_idle <= << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(0); -- return to idle
      state_idle_rise <= not state_idle and << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(0);

      ev_if_req <= << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_if_req : std_logic >>;
      ev_if_req_rise <= not ev_if_req and << signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_if_req : std_logic >>;

    end if;
  end process ddr3_stat_pr;


  -- Reset
  RESET_I        <= '0', '1' after 1000 NS;
  reset_sys_clk  <= RESET_I;

  -- Clock and clock enables:
  CLK_50Mhz <= not CLK_50Mhz after 10 NS; -- 50MHz
  sys_clk_p <= not sys_clk_p after CLKIN_PERIOD/2;
  sys_clk_n <= not sys_clk_p;
  rx_clk20 <= not rx_clk20 after 25 NS;
  CLK_200 <= not CLK_200 after 2.5 NS;


  init_done_g2: if (not DDR3_WAIT_DONE) generate
    INIT_DONE_ALL_O <= '0', '1' after 100 US; -- for case if no DDR3 model
  end generate init_done_g2;
  INIT_DONE_ALL <= (INIT_DONE_ALL_O = '1'); -- from DDR3_AXI_IF.init_calib_complete

  check_ddr3_init_pr : process
  begin  -- process check_ddr3_init_pr

    wait until RESET_I = '1';
    wait on init_done_all for 225 US;   -- timeout, 01/09/2022 init_done_all @100USec
    if (USE_DDR_DRIVER) then
      if (init_done_all) then
        report "Done: DDR3 init OK";
      else
        report "Error: DDR3 init failed!!!" severity FAILURE;
      end if;
    end if;
    wait;

  end process check_ddr3_init_pr;


  use_ddr3_phy_g : if (USE_DDR_DRIVER) generate

    -- DDR3 Micron model
    ddr3_0 : ddr3_model
      port map (
        rst_n   => ddr3_reset_n,
        ck      => ddr3_ck_p(0),
        ck_n    => ddr3_ck_n(0),
        cke     => ddr3_cke(0),
        cs_n    => ddr3_cs_n(0),
        ras_n   => ddr3_ras_n,
        cas_n   => ddr3_cas_n,
        we_n    => ddr3_we_n,
        dm_tdqs => ddr3_dm(0 downto 0),     -- i0  -- shared DM/TDQS
        ba      => ddr3_ba,                 -- (1) for dual rank
        addr    => ddr3_addr,               -- (1) for dual rank
        dq      => ddr3_dq(7 downto 0),     -- i0
        dqs     => ddr3_dqs_p(0 downto 0),  -- i0
        dqs_n   => ddr3_dqs_n(0 downto 0),  -- i0
        tdqs_n  => open,                    -- core not drive, always 'Z'
        odt     => ddr3_odt(0)              -- (1) for dual rank
        );

  end generate use_ddr3_phy_g;


  -- wr_ptr_num <= resize(unsigned(READING_NUMBER_REG),wr_ptr_num'length); -- 22/09/2022 !TODO: 22/09/2022
                                                                    -- replace READING_NUMBER_REG with value from SyncP/N

  -- 09/02/2023
  -- DDR3_SOFT_RESET_N <= '0', '1' after 300 US;
  -- test_params_ready <= '0', '1' after 400 US;
  UNIQ_ID <= (others => '0'); -- (0 => '1', others => '0'), (0 to 1 => '1', others => '0') after 400 US; -- memory test: [0] - controls MUX to AXI4 master, [1] - test_data_en
  Module_TX_RX_channel_RDY <= '0', '1' after 50 US;


  -- 11/06/2023 synthetic data
  slices_sorter_1 : slices_sorter
    port map (
      clk20_c2            => rx_clk20,            -- RX byte clock
      sys_clk             => CLK_50Mhz,
      rst_n               => reset_sys_clk,
      NRST_20M            => reset_sys_clk,
      IP20                => IP,
      IP50                => IP,
      dummy_data_sel      => '1',       -- always synthetic data
      diag_reg            => X"0018",   -- diag_reg(4) - synthetic data in place tiles data, diag_reg(3) - bypass_lut,
      num_of_tiles        => X"F",      -- 4 tiles
      reading_number_freerun_cnt => (others => '0'),
      tile_packet_ok_timeout_reg => (others => '0'), -- !debug: 30/10/2023 assigned in simulation
      mu_ctl_reg          => '0',       -- mu_en
      take_rx_det_msb_reg => '0',       -- sel. coarse
      rx_det_shl_reg      => '0',       -- sel. 16bit
      pipeline_ctl_reg    => (others => '0'), -- MU params
      AMS_Time            => (others => '0'), -- MU params
      AMS_Offset          => (others => '0'), -- MU params
      ibias               => (others => '0'), -- MU params
      global_ip_time_reg  => (others => '0'), -- MU params
      gain                => (others => '0'), -- MU params
      Num_of_Slices       => temp_Num_of_Slices,   -- from scan header
      asic_data_good_read => X"F",      -- !debug: 30/10/2023 tile data always ready
      RX_det_m            => (others => '0'),     -- NU when synthetic data
      data_valid_m        => (others => '0'),     -- NU when synthetic data
      RX_det_s            => (others => '0'),     -- NU when synthetic data
      data_valid_s        => (others => '0'),     -- NU when synthetic data
      fq_data_valid       => fq_data_valid,
      fq_data_in          => fq_data_in
      );



  memory_buffer_if_1: memory_buffer_if_tmp
    generic map (
      WORD_WIDTH => 32)
    port map (
      sys_clk               => CLK_50Mhz,
      rst_n                 => reset_sys_clk,
      IP50                  => IP,    -- 10/11/2022
      num_of_slices         => temp_Num_of_Slices,  -- 28/06/2023
      slice_merge           => '1',
      -- merge_factor          => 5UX"2",
      slice_merging_factor  => slice_merging_factor,   -- 11/10/2023
      rlt_address_from_sync => rlt_address_from_sync, -- 08/10/2023
      stream_enable         => "11", -- FQ & EV !debug: 18/10/2023 temporary constant   fq_stream_enable,
       fq_data_valid         => fq_data_valid, -- from sorter
      fq_data_in            => fq_data_in, -- from sorter
      tmb_header_valid      => dpr_header_valid_r,   -- from scan header
      tmb_header            => HEADER_DATA_OUT,   -- from scan header
      params_ready          => params_ready,
      tmb_header_dout32     => tmb_header_dout32,
      tmb_header_rd         => tmb_header_rd,
      ev_header_dout32      => ev_header_dout32,
      ev_header_rd          => ev_header_rd,
      num_of_slices_after_merge => num_of_slices_after_merge, -- 18/10/2023
      DATA_SORTER_DATA_EN   => DATA_SORTER_DATA_EN,
      DATA_SORT_DOUT        => DATA_SORT_DOUT,
      EVOLVING_DATA_EN      => EVOLVING_DATA_EN,
      EVOLVING_DOUT         => EVOLVING_DOUT
      );


  ip_pr : process is
    variable ignore_at_start_v : boolean := TRUE;
  begin  -- process ip_pr
   loop

      wait for ip_period_const;                  -- !TODO: 11/06/2023 change IP period to 95uSec
      -- send IP pulse
      IP_i <= '1';
      wait for 2 US;
      IP_i <= '0';

      READING_NUMBER_REG <= std_logic_vector(unsigned(READING_NUMBER_REG) + 1); -- 14/06/2023

      -- prepare next IP scan header (for write to DDR3)
      -- !debug: 03/10/2023 because 1st IP without data, need to ignore
      if (not ignore_at_start_v) then
        READING_NUMBER_REG <= std_logic_vector(unsigned(READING_NUMBER_REG) + 1); -- 14/06/2023
        HD_PTR_ADDRESS_REG <= std_logic_vector(unsigned(HD_PTR_ADDRESS_REG) + 4); -- 02/10/2023
        RLT_PTR_ADDRESS_REG <= std_logic_vector(unsigned(RLT_PTR_ADDRESS_REG) + 16#0420#); -- 02/10/2023
      end if;
      ignore_at_start_v := FALSE;

    end loop;

  end process ip_pr;


  CT_TYPE <= X"00000010", X"00000040" after 0.5 MS; -- header W#1 (set slices_num), note: here no byte swap


  misc_pr: process (CLK_50Mhz) is
    variable ddr3_rq_word_v : std_logic_vector(31 downto 0) := (others => '0');
  begin  -- process misc_pr
    if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge

      -- ACLK generator
      if (clk_cnt = (75-1)) then -- for @50MHz 1.5e-6/20e-9=75
        clk_cnt <= 0;
      else
        clk_cnt <= clk_cnt + 1;
      end if;

      if (clk_cnt = 0) THEN             -- similar to old phoebe_controller
        ACLK_Master_i <= '1';
      elsif (clk_cnt = (75 /2)) THEN
        ACLK_Master_i <= '0';
        synth_ip <= IP_i;
      end if;

      if (now < 20 US) then
        ACLK_Master <= '0';
      else
        ACLK_Master <= ACLK_Master_i;
      end if;


      -- header processing
      aclk_shr_50m <= aclk_shr_50m(1 downto 0) & aclk_master_i;
      if (IP_READY = '1') then
        sync_header_valid_cnt <= 10;
        sync_header_valid <= '0';
      elsif (aclk_shr_50m(2) = '0' and aclk_shr_50m(1) = '1') then
        if (sync_header_valid_cnt /= 0) then
          sync_header_valid_cnt <= sync_header_valid_cnt - 1;
        else
          sync_header_valid <= '1';     -- header from SYNC channel ready
        end if;
      end if;

      if (IP_READY = '1') then
        header_dpr_addr <= (others => '0');
        dpr_header_valid <= '0';
      elsif (sync_header_valid = '1' and unsigned(header_dpr_addr) < 63) then
        header_dpr_addr <= std_logic_vector(unsigned(header_dpr_addr) + 1);
        dpr_header_valid <= '1';
      else
        dpr_header_valid <= '0';
      end if;
      dpr_header_valid_shr <= dpr_header_valid_shr(1 downto 0) & dpr_header_valid;

      if (dpr_header_valid_shr(1 downto 0) = "01") then -- header W#1
        if (HEADER_DATA_OUT(6 downto 0) /= 7UX"00") then
          temp_Num_of_Slices <= HEADER_DATA_OUT(6 downto 0); -- sample num_of_slices from scan header
        end if;
      end if;

      if (IP_READY = '1') then
        ip_valid_sampled <= '1';
        IP <= '0';
      elsif ((aclk_shr_50m(2) = '0' and aclk_shr_50m(1) = '1') and ip_valid_sampled = '1') then
        IP <= ip_valid_sampled;
        ip_valid_sampled <= '0';
      elsif ((aclk_shr_50m(2) = '0' and aclk_shr_50m(1) = '1') and ip_valid_sampled = '0') then
        IP <= '0';
      end if;

      TIME_STAMP_LOW <= std_logic_vector(to_unsigned(now/stamp_time_const,32));
      INTEGRATION_TIME_IN_REG <= std_logic_vector(to_unsigned(ip_period_const/ip_time_const,32));

      -- !debug: 11/07/2023 temporary drivers
      -- !TODO: 11/07/2023 replace with taichi_slice_builder
      if (DDR_DRIVER_RD_READY = '1') then
        DDR_DRIVER_RD <= '1';
      elsif (DDR_DRIVER_FIFO_EMPTY = '1' or
             unsigned(<< signal .ddr3_taichi_tb.use_ddr_driver_g.ddr_driver_1.read_ddr3_rd_1.fifo4k_rd_data_count :  std_logic_vector(11 downto 0) >>) = 0) then
        DDR_DRIVER_RD <= '0';
      end if;

      -- raw_wr_ptr_addr <= ADDR_FIFO_BASE_ADDR + (resize(unsigned(READING_NUMBER_REG),raw_wr_ptr_addr'length) sll 2); -- 16/07/2023
      -- ev_wr_slot_addr <= EV_DATA_BASE_ADDR + resize(unsigned(READING_NUMBER_REG) * to_unsigned(EV_READING_SIZE,ev_wr_slot_addr'length),ev_wr_slot_addr'length); -- 17/08/2023
      ev_wr_slot_addr <= unsigned(rlt_address_from_sync(DDR3_ADDR_WIDTH-1 downto 0)); -- 05/11/2023
      raw_wr_ptr_addr <= unsigned(hd_ptr_address_from_sync(DDR3_ADDR_WIDTH-1 downto 0)); -- 05/11/2023

      ddr3_rq_word_v := rq_cmds & '0' & rq_rd_ptr;
      buffer_tx_data_in <= ddr3_rq_word_v(8*ddr3_rq_word_idx+7 downto 8*ddr3_rq_word_idx);
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


  dpr_header_valid_r <= '1' when (dpr_header_valid_shr(1 downto 0) /= "00") else '0';


  -- Tzvika: SYNC CDM TX -> TMB SYNC RX
  tx_serdes_ip : tx_ctrl_serdes_wrap
    generic map (
      G_PARAMS_LEN            => 16,
      G_TX_DATA_PACKET_SIZE   => x"00000080",         -- 128B
      G_TX_HEADER_PACKET_SIZE => x"02",
      G_TX_FOOTER_PACKET_SIZE => x"0C", -- 12/10/2023 !debug: 13/10/2023 try x"0b" -> x"0C"
      G_HEADERS               => '1',
      G_RESET_POLARITY => '1'
      )
    port map (
      CLK_50M                      => CLK_50Mhz,
      CLK_100M                     => CLK_50Mhz,         -- !debug: 22/01/2023 check, if OK
      CLK_200M                     => CLK_200,

      RESET                        => "not"(reset_sys_clk),
      INIT_DONE                    => '1',            -- !debug: 22/01/2023 check, if OK
      ACLK                         => ACLK_Master,    -- !debug: 22/01/2023 check, if OK
      SYNC_DEBUG_REG               => x"DEADBEEF",
      NUMBER_OF_SLICES             => X"0040",        -- NU
      MAKE_DATA                    => '0',            -- make_data_sig,
      IP_LONG                      => synth_ip,
      DFS                          => '0',            -- I: NU
      TX_TRI_IN                    => '1',
      TX_TRI_O                     => open,
      TX_DATA_O                    => SYNC_DATA_out,  -- from TX_Zynq

      -- I: header words
      CT_TYPE                      => CT_TYPE,                 -- W1
      DMS_STATUS_REG               => x"00000005",             -- W2
      DMS_ERROR                    => x"00000006",             -- W3
      INTEGRATION_TIME_IN_REG      => INTEGRATION_TIME_IN_REG, -- W4
      REF_CONVERTOR  => x"00000008",                           -- W5
      L_DMS_TEMP         => x"00000009",                       -- W6
      R_DMS_TEMP        => x"0000000a",                        -- W7
      FANS_SPEED_DMS_TROUBLESHOOTING   => x"0000000b",         -- W8
      READING_NUMBER_REG              => READING_NUMBER_REG,   -- W9
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
      RLT_PTR_ADDRESS_REG						=> RLT_PTR_ADDRESS_REG, -- X"00042000"
	  HD_PTR_ADDRESS_REG						=> HD_PTR_ADDRESS_REG, -- X"00108800", -- !TODO: check SYNC footer, was x"000000d5"
	  BUF_PTR_ADDRESS						=> x"000000d9", -- valid for BUFFER communication
	  STREAM_CTRL								=> x"dd", -- valid for BUFFER communication !debug: 12/10/2023 32bits -> 8bits
	  -- NU for BUFFER	 x"00000800", -- [11..10] - Slice Merging (RLT_SLICE_MERGE_FACTOR ), 0 -	No Slice Merging, 1	- Merged 2 Slices, 2 - Merged 4 Slices	 , was x"00000051",
	  RLT_SLICE_MERGE_FACTOR => x"02", -- 2 - Merged 4 Slices
      FS_MERGE_FACTOR => X"00",
      FQ_STREAM	       => X"01", -- 1 - enable
	  HEADERS_CTRL_REG						=> x"000000e1",
	  HEADERS_SAMP_TIME_REG					=> x"00000008", -- !debug: 14/10/2023 was x"0000001f"
	  DBG_READING_CNT							=> "000"&x"0e9",
      MASTERn_SLAVE     => '0'
    );


  -- TMB SYNC RX
  IP_DATAVAL_HEADER_TOP_1: IP_DATAVAL_HEADER_TOP
    generic map (
      IP_DATA_OUT_VAL => IP_DATA_OUT_VAL,
      HEADER_DATA_OUT_VAL => HEADER_DATA_OUT_VAL,
      ADDR_BIT_VAL => ADDR_BIT_VAL,
      DATA_BIT_VAL => DATA_BIT_VAL,
      NumFooterBytes => 12              -- 12/10/2023 added !debug: 13/10/2023 try 11 -> 12
      )
    port map (
      CLK_200Mhz          => CLK_200,
      CLK_50Mhz           => CLK_50Mhz,
      RST                 => "not"(reset_sys_clk),
      sDataIn             => SYNC_DATA_out, -- Buffer input
      Channel_RDY         => Module_TX_RX_channel_RDY, -- !debug: 02/01/2023 Channel_RDY, -- 28/12/2022
      IP_READY            => IP_READY,
      IP_DATA_OUT         => IP_DATA_OUT,
      HEADER_DATA_OUT     => HEADER_DATA_OUT, -- data from DPR
      clkb                => '0',
      enb                 => '0',
      web(0)              => '0',
      addrb               => header_dpr_addr, -- read address from DPR
      dinb                => (others => '0'),
      doutb               => open,      -- NU
      rlt_address_from_sync => rlt_address_from_sync, -- EV WR address
      hd_ptr_address_from_sync => hd_ptr_address_from_sync,  -- FQ WR address
      slice_merging_factor => slice_merging_factor,          -- !TODO: 11/10/2023 #22
      fs_merging_factor => fs_merging_factor,                -- !TODO: 11/10/2023 connect
      fq_stream_enable => fq_stream_enable,                  -- !TODO: 11/10/2023 connect
      bad_packet_received => open,
      RX_ERRs             => open
      );


  -- !TODO: 15/06/2023 add driver for reading request interface
  -- old: rq_cmds[3..0]: [0] - WR, [1] - RD, [2] - EV('0')/REGULAR('1') - [3] - DDR soft reset
  -- new: rq_cmds[1..0]: [0] - RD, [1] - EV('0')/REGULAR('1')
  -- rq_rd_ptr[29..0] - absolute RD pointer
  regs2tx_pr: process is
    variable shedule_time_v : time;
    variable test_reg_addr_v: std_logic_vector(31 downto 0) := (others => '0');
    variable test_reg_cmd_v	: std_logic_vector(1 downto 0) := (others => '0');  -- !debug: 23/07/2023 was [3..0]
  begin  -- process regs2tx_pr

    rq_cmds <= (others => '0');
    rq_rd_ptr <= (others => '0');

    wait for 5 US;
    wait on CLK_50Mhz until (CLK_50Mhz = '1');
    wait for 200 PS;

    prep_for_tx_l: for i in test_seq_sig'range loop

      -- If special events, not WR/RD commands
      if (test_seq_sig(i).cmd = "ST") then -- all shedule pass
        wait;
      end if;

      -- Shedule, when send command
      shedule_time_v := test_seq_sig(i).shedule_time;
      assert (now < shedule_time_v) report "Sheduler was not ready!!!" severity ERROR;
      wait for (shedule_time_v - now);

      wait on CLK_50Mhz until (CLK_50Mhz = '1');
      wait for 200 PS;

      -- if (test_seq_sig(i).cmd = "WR") then
      --   test_reg_cmd_v := X"1";
      -- elsif (test_seq_sig(i).cmd = "EV") then
      --   test_reg_cmd_v := X"2";
      -- elsif (test_seq_sig(i).cmd = "RA") then
      --   test_reg_cmd_v := X"6";
      -- elsif (test_seq_sig(i).cmd = "RS") then
      --   test_reg_cmd_v := X"8";
      -- elsif (test_seq_sig(i).cmd = "OK") then
      --   next;
      -- end if;
      -- !debug: 23/07/2023
      if (test_seq_sig(i).cmd = "EV") then
        test_reg_cmd_v := "01";
        buffer_go <= '1';
      elsif (test_seq_sig(i).cmd = "RA") then
        test_reg_cmd_v := "11";
        buffer_go <= '1';
      elsif (test_seq_sig(i).cmd = "RS") then
        test_reg_cmd_v := "00";
        buffer_go <= '0';
      elsif (test_seq_sig(i).cmd = "OK") then
        next;
      end if;
      rq_cmds <= test_reg_cmd_v;
      test_reg_addr_v := test_seq_sig(i).ptr;
      rq_rd_ptr <= test_reg_addr_v(28 downto 0); -- (others => '0');

      wait on CLK_50Mhz until (CLK_50Mhz = '1');
      wait for 200 PS;

      buffer_go <= '0';
      test_reg_cmd_v := "00";
      rq_cmds <= test_reg_cmd_v; -- [0] - RD EXE, [1] - EV('0')/REGULAR('1')

    end loop;  -- prep_for_tx_l

  end process regs2tx_pr;


  -- CDM TX.TX_Zynq -> TMB Buffer RX
  TX_Buffer : TX_series7
    generic map(
      IDLE_WORD      => x"B5",
      StartWord      => X"21",
      Stream_type1   => X"43",
      Stream_type2   => X"DD",

      NumHeaderbytes => X"00",
      NumDatabytes   => X"00000004",    -- !debug: 23/07/2023 was X"00000080",    --128
      NumFooterbytes => X"00"
      )
    port map(
      RESET       => "not"(reset_sys_clk),
      CLKDIV      => CLK_50Mhz,          --50
      FCLK        => CLK_200,            --200
      STATn_DYN   => '0',
      GO          => buffer_go,         -- !debug: 24/01/2023 was: both IP and buffer request - same signal (IP)
                                        -- !TODO: 24/01/2023 from SYNC packet to BUFFER packet 100uS
      IP          => '0',    -- !debug: 23/07/2023 was  '1',               -- always IP
      PayloadSize => X"00000001",
      DATA_IN     => buffer_tx_data_in,    -- !debug: 23/07/2023 was   X"55",
      RD_EMPTY    => buffer_tx_rd_empty,  -- !debug: 23/07/2023 was   '0',
      RD_CLK      => open,
      RD_REQ      => buffer_tx_rd_req,   -- !debug: 23/07/2023 was  open
      DATA_out    => Buffer_TX_DATA_out,
      TX_ERRs     => open               -- 30/10/2023
      );

  -- BUFFER, DDR3 RD request packet
  RX_series7_1 : RX_series7
    generic map (
      IDLE_word      => x"B5",
      StartWord      => x"21",
      Stream_type1   => x"43",
      Stream_type2   => x"DD",
      TapWidth       => 5,
      ParallelWidth  => 8,
      NumHeaderBytes => 0,  -- !debug: 23/07/2023 was  4
      NumDataBytes   => 4,  -- !debug: 23/07/2023 was  4
      NumFooterBytes => 0)  -- !debug: 23/07/2023 was  8
    port map (
      RESET                => "not"(reset_sys_clk),
      CLKDIV               => CLK_50Mhz,  -- comm_clk,
      FCLK                 => CLK_200,      -- FCLK,
      channel_RDY          => Module_TX_RX_channel_RDY,
      sDataIn              => Buffer_TX_DATA_out,
      IDLY_CNT             => open,
      RX_det_o             => buffer_data, -- data[7..0]
      start_valid          => open,
      Headers_valid        => open,
      data_valid           => buffer_data_valid,
      Footers_valid        => open,
      IP_pckt_valid        => open,
      packet_received      => open,
      good_packet_received => open,
      bad_packet_received  => open,
      RX_ERRs              => open
      );


end architecture ddr3_taichi_tb_ar;
