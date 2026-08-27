-------------------------------------------------------------------------------
-- Title      : DDR3 testbench
-- Project    : Trident
-------------------------------------------------------------------------------
-- File       : ddr3_tr_tb.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    : Philips Medical
-- Created    : 13/12/2016
-- Last update: 22/09/2022
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
use work.tmc_pack.all;
use work.ddr3_model_pack.all;


entity ddr3_tr_tb is

end entity ddr3_tr_tb;



architecture ddr3_tr_tb_ar of ddr3_tr_tb is

  constant USE_DDR_DRIVER : boolean := TRUE;  -- if false, skip ddr_driver hierarchy

  signal RESET_I, RESET_128, RESET_40 : std_logic := '0';
  signal SYSTEM_CLK64_I : std_logic := '0';
  signal clk20        : std_logic := '0';
  signal CLK_EN_20M     : std_logic := '0';
  signal CLK_16M     : std_logic := '0';


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

  -- Internal registered requests
  signal DEC_RRQ_INT      : std_logic;
  signal EVOLVING_REQ_INT : std_logic;
  signal INC_RRQ_INT      : std_logic;
  signal REGULAR_REQ_INT  : std_logic;
  signal SLICE_REQ_INT    : std_logic;  -- NU

  -- My simulation data generation IF
  signal DATA_SORTER_DATA_EN         : std_logic;
  signal DATA_SORTER_PRE_FRAME_START : std_logic;

  -- DDR driver (buffers) registers inputs
  signal FPGA_ID              : std_logic_vector (3 downto 0) := X"5";   --TBUF_R_L & FPGA_ID_I
  signal PORTS_CLK_EN         : std_logic;
  signal PORTS_CLK_LAUNCH_EN  : std_logic;  -- read to PORTS bus enable
  signal PORT_ALE_I           : std_logic;
  signal PORT_READ_I          : std_logic;
  signal PORT_WRITE_I         : std_logic;
  signal PORT_A_D_B           : std_logic_vector (15 downto 0);  -- shared bus
  signal DDR_DRIVER_INTR_L    : std_logic;  -- out , if any of int. bits active
  signal DDR_DRIVER_ACK       : std_logic;  -- out, after cmd. rd/wr
  signal DDR_DRIVER_STOP_SCAN : std_logic;  -- out, as INTR ?
  signal PORT_A_D_B_IN        : std_logic_vector (15 downto 0);  -- shared bus
  signal PORT_A_D_B_OUT       : std_logic_vector (15 downto 0);  -- shared bus
  signal Bi_Dir_Direction     : std_logic;

  type PORTS_TEST_REC is record
    cmd          : string(1 to 2);                 -- RD/WR
    data         : std_logic_vector(15 downto 0);  -- write data
    addr         : std_logic_vector(15 downto 0);  -- full address, include local addr , FPGA_ID , TBUF_RL
                                                   -- ports address for TDMC: -&(5..7)&<local address>
    shedule_time : time;
  end record PORTS_TEST_REC;

  type PORTS_TEST_TYP is array (positive range <>) of PORTS_TEST_REC;
  constant ports_test_c : PORTS_TEST_TYP := (
    ("RD",X"FFFF",X"50A0",11 US),("WR",X"0F05",X"50A4",12 US), -- Check RD/WR operations
    ("WR",X"FFFF",X"50A4",13 US),("WR",X"FFFF",X"5074",14 US),
    ("OK",X"FFFF",X"50A4",15 US),
    -- ("WR",X"0001",X"50CE",341 US),("WR",X"0000",X"50CE",342 US), -- ECC error injection start/stop
    -- ("WR",X"0002",X"50CE",975 US),("WR",X"0000",X"50CE",982 US), -- ECC error injection start/stop
    -- ("WR",X"0002",X"50C4",400 US),("WR",X"0000",X"50C4",410 US), -- Do quick, then full DDR test
    ("ST",X"FFFF",X"50A4",995 US));


  signal DDR_A_LOCAL_RDATA_TB       : std_logic_vector(31 downto 0);
  signal DDR_A_LOCAL_RDATA_VALID_TB : std_logic;
  signal READ_BUS_DONE_TB           : std_logic;
  signal TOP_CLK_MEM_128M_O : std_logic := '0';


  -- ddr_driver top
  component ddr_driver is
    port (
      global_reset_n              : in     std_logic;
      RESET_40                    : in     std_logic;
      DDR3_SOFT_RESET_N           : in     std_logic;
      CLK_40M                     : in     std_logic;
      SYSTEM_CLK64_I              : in     std_logic;
      -- sys_clk_i         : in  std_logic;  -- 14/09/2022 DDR3 sys_clk
      -- clk_ref_i         : in  std_logic;  -- 14/09/2022 DDR3 clk_ref
      sys_clk_p           : in    std_logic; -- 19/09/2022 DDR3 sys_clk
      sys_clk_n           : in    std_logic; -- 19/09/2022 DDR3 sys_clk
      ui_clk_o                    : out    std_logic;
      ui_clk_sync_rst_o           : out    std_logic;
      Bi_Dir_Direction            : out    std_logic;
      ASSEMBLY_VERSION            : in     std_logic_vector(15 downto 0);
      INIT_DONE_A_O               : out    std_logic;
      INC_RRQ_I                   : in     std_logic;
      DEC_RRQ_I                   : in     std_logic;
      REGULAR_REQ_I               : in     std_logic;
      EVOLVING_REQ_I              : in     std_logic;
      DATA_SORTER_DATA_EN         : in     std_logic;
      DATA_SORTER_PRE_FRAME_START : in     std_logic;
      DATA_SORT_DOUT              : in     std_logic_vector (31 downto 0);
      EVOLVING_DATA_EN            : in     std_logic;
      EVOLVING_PRE_FRAME_START    : in     std_logic;
      EVOLVING_DOUT               : in     std_logic_vector (31 downto 0);

      params_ready : in std_logic;  -- 20/09/2022
      tmb_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
      tmb_header_rd : out std_logic;
      wr_ptr_num : in DDR3_ADDR_BUS_TYP;  -- 22/09/2022
      num_of_slices : in std_logic_vector (7 downto 0); -- 22/09/2022

      NO_ECC_CHK                  : in     std_logic;
      FPGA_ID                     : in     std_logic_vector (3 downto 0);
      UNIQ_ID                     : in     std_logic_vector (15 downto 0);
      PORTS_CLK_EN                : in     std_logic;
      PORTS_CLK_LAUNCH_EN         : in     std_logic;
      PORT_ALE_I                  : in     std_logic;
      PORT_READ_I                 : in     std_logic;
      PORT_WRITE_I                : in     std_logic;
      PORT_A_D_B_IN               : in     std_logic_vector (15 downto 0);
      PORT_A_D_B_OUT              : out    std_logic_vector (15 downto 0);
      DDR_DRIVER_INTR_L           : out    std_logic;
      DDR_DRIVER_ACK              : buffer std_logic;
      DDR_DRIVER_STOP_SCAN        : buffer std_logic;
      EV_STOP_SCAN                : buffer std_logic;
      PTR_STOP_SCAN               : buffer std_logic;
      READ_DATA_FSM_IDLE          : buffer std_logic;
      DDR_DRIVER_RD               : in     std_logic;
      DDR_DRIVER_EN               : out    std_logic;
      DDR_DRIVER_DOUT             : out    std_logic_vector (7 downto 0);
      DDR_DRIVER_FIFO_EMPTY       : out    std_logic;
      DDR_DRIVER_RD_DONE          : out    std_logic;
      DDR_DRIVER_HEADER_BUS       : out    std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
      DDR_DRIVER_HEADER_READY     : out    std_logic;
      wr_data_2dual_output_fifo   : out    std_logic;
      ECC_ERROR                   : out    std_logic;
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
      UNMASKED_INTERRUPT          : out    STD_LOGIC;
      diag_p4                     : out    std_logic_vector (15 downto 0);
      DDR_DRIVER_TESTPOINTS       : out    std_logic_vector (31 downto 0));
  end component ddr_driver;


  -- EV signals
  signal EVOLVING_DATA_EN              : std_logic;  -- data strobe from EV control
  signal EVOLVING_PRE_FRAME_START      : std_logic;  -- in Reading

  -- Test block signals
  signal powerup_test_mode : boolean := FALSE;


  -- Tb signals:
  constant BUNDLES_NUM     : natural := 16; -- 4,32,64;                  -- slices in reading
  constant READINGS_NUM    : natural := 128;                  -- 20 num. readings
  constant BUNDLE_SIZE     : natural := 4*16*16/32;  -- 32 bit words , now bundle=slice
                                                     -- TMC*DETECTORS*BITS4DETECTOR/WORD_SIZE
  signal   num_words       : natural range 0 to (BUNDLE_SIZE * BUNDLES_NUM); -- words in slice

  constant EV_SLICES_NUM   : natural := 16;                -- 16 slices in reading
  constant EV_READINGS_NUM    : natural := 128;            --  num. readings !debug: 20/09/2022 was 128
  constant EV_SLICE_SIZE   : natural := 4*16*16/32;  -- 32 bit words , now bundle=slice
                                                     -- TMC*DETECTORS*BITS4DETECTOR/WORD_SIZE
  signal   ev_num_words    : natural range 0 to (EV_SLICE_SIZE * EV_SLICES_NUM); -- words in slice

  constant BUNDLE_SORTER_DELAY : delay_length := 200 US; -- !debug: 21/09/2022 was 100 US
  constant BUNDLE_EV_DELAY : delay_length := 100 US; --  100 US;
  signal   ddr_rdata_64bit : std_logic_vector(63 downto 0); -- for monitor
  constant GENERIC_MEM     : boolean := FALSE;
  signal  DDR_DRIVER_TESTPOINTS	: std_logic_vector(31 DOWNTO 0);
  signal  do_ev_read, do_reg_read : boolean;
  signal regular_reading : boolean;

  -- 13/12/2016
  constant PORTBUS_EN : boolean := TRUE;    -- enable PORT_* interface registers test
  constant DDR3_WAIT_DONE : boolean := TRUE;    -- override INIT_DONE from DDR3 core, enable test if core not ready

  signal params_ready : std_logic;  -- 20/09/2022
  signal tmb_header : std_logic_vector (31 downto 0) := (0 => '1', others => '0'); -- !debug: 20/09/2022
  signal tmb_header_rd, tmb_header_rd_r : std_logic;
  signal wr_ptr_num : DDR3_ADDR_BUS_TYP;  -- 22/09/2022
  signal num_of_slices : std_logic_vector (7 downto 0); -- 22/09/2022

  signal RAW_DATA_END_ADDR          : DDR3_ADDR_BUS_TYP;

  signal pll_ref_clk : std_logic := '0';

  signal ddr3_core_errors_src, ddr3_core_errors_src_r : std_logic_vector(7 downto 0);
  signal ddr3_if_clk_o : std_logic;

  signal start_write : std_logic;
  signal start_read  : std_logic;
  signal waddr_offset, raddr_offset : std_logic_vector(29 downto 0);

  signal tile_wdata, fifo_axi_wdata : std_logic_vector(31 downto 0);
  signal burst_len                              : std_logic_vector(7 downto 0);
  signal fifo_rd_en, fifo_wdata_valid : std_logic;
  signal master_axi_state : std_logic_vector(7 downto 0);

  -- signal sys_clk_i                       : std_logic := '0';
  -- signal clk_ref_i                       : std_logic := '0';
  signal sys_clk_p                       : std_logic := '0';
  signal sys_clk_n                       : std_logic := '1';

  signal ui_clk, ui_clk_sync_rst         : std_logic;
  signal r_state, r_state_m00_1 : std_logic_vector(1 downto 0);
  signal ev_handshake_1_req : std_logic;
  signal fq_error_count, ev_error_count : std_logic_vector(31 downto 0);
  signal state_idle, state_idle_rise : std_logic;
  signal ev_if_req, ev_if_req_rise : std_logic;

  signal fq_reading_num : std_logic_vector(7 downto 0);
  signal header_dw_cnt : natural range 0 to 7;

begin  -- architecture ddr3_tr_tb_ar


  use_ddr_driver_g : if (USE_DDR_DRIVER) generate  -- !debug: 27/12/2016

    ddr_driver_1 : ddr_driver
      port map (
        global_reset_n              => RESET_I,
        RESET_40                    => RESET_40,
        DDR3_SOFT_RESET_N           => '1',
        CLK_40M                     => clk20,
        SYSTEM_CLK64_I              => SYSTEM_CLK64_I,
        -- sys_clk_i                                  => sys_clk_i,
        -- clk_ref_i                     => clk_ref_i, -- 01/01/2020
        sys_clk_p                   => sys_clk_p,         -- 19/09/2022
        sys_clk_n                   => sys_clk_n,         -- 19/09/2022
        ui_clk_o                    => ui_clk,            -- 01/01/2020
        ui_clk_sync_rst_o           => ui_clk_sync_rst,   -- 01/01/2020
        Bi_Dir_Direction            => Bi_Dir_Direction,  -- 27/12/2016 ES: MUX vs bidir
        ASSEMBLY_VERSION            => (others => '1'),   -- 27/12/2016 4Gb DDR3 chips
        INIT_DONE_A_O               => INIT_DONE_ALL_O,   -- 28/12/2016
        INC_RRQ_I                   => INC_RRQ_INT,
        DEC_RRQ_I                   => '0',
        REGULAR_REQ_I               => REGULAR_REQ_INT,
        -- SLICE_REQ_I                                => SLICE_REQ_INT,
        EVOLVING_REQ_I              => EVOLVING_REQ_INT,
        DATA_SORTER_DATA_EN         => DATA_SORTER_DATA_EN,
        DATA_SORTER_PRE_FRAME_START => DATA_SORTER_PRE_FRAME_START,
        DATA_SORT_DOUT              => DATA_SORT_DOUT,
        EVOLVING_DATA_EN            => EVOLVING_DATA_EN,
        EVOLVING_PRE_FRAME_START    => EVOLVING_PRE_FRAME_START,
        EVOLVING_DOUT               => EVOLVING_DOUT,

        params_ready  => params_ready,   -- 21/09/2022
        tmb_header    => tmb_header,     -- 21/09/2022
        tmb_header_rd => tmb_header_rd,  -- 21/09/2022
        wr_ptr_num    => wr_ptr_num,     -- 22/09/2022
        num_of_slices => num_of_slices,  -- 22/09/2022

        FPGA_ID               => FPGA_ID,
        PORTS_CLK_EN          => PORTS_CLK_EN,
        PORTS_CLK_LAUNCH_EN   => PORTS_CLK_LAUNCH_EN,
        PORT_ALE_I            => PORT_ALE_I,
        PORT_READ_I           => PORT_READ_I,
        PORT_WRITE_I          => PORT_WRITE_I,
        -- PORT_A_D_B                              => PORT_A_D_B,
        PORT_A_D_B_IN         => PORT_A_D_B_IN,
        PORT_A_D_B_OUT        => PORT_A_D_B_OUT,
        DDR_DRIVER_INTR_L     => DDR_DRIVER_INTR_L,
        DDR_DRIVER_ACK        => DDR_DRIVER_ACK,
        DDR_DRIVER_STOP_SCAN  => DDR_DRIVER_STOP_SCAN,
        EV_STOP_SCAN          => open,       -- 27/12/2016
        PTR_STOP_SCAN         => open,       -- 27/12/2016
        READ_DATA_FSM_IDLE    => open,       -- 27/12/2016
        DDR_DRIVER_RD         => '0',        -- 01/01/2020
        DDR_DRIVER_EN         => open,       -- 01/01/2020
        DDR_DRIVER_DOUT       => open,
        DDR_DRIVER_FIFO_EMPTY => open,
        DDR_DRIVER_HEADER_BUS => open,
        ECC_ERROR             => open,
        NO_ECC_CHK            => '1',        -- !debug: 01/01/2020 disable ECC
        UNIQ_ID               => (0 => '1', others => '0'),
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

      assert not(<< signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.start_write : std_logic >> = '1' and << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.start_read : std_logic >> = '1') report "Error: start_write and start_read in same time" severity ERROR;

      -- assert not(<< signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.axi_if_req : std_logic_vector(2 downto 0) >> /= "000" and << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(0) = '0') report "Warning: request to AXI when mst_exec_state /= IDLE" severity ERROR;
      assert (<< signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "001" or << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "010" or << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "100" or << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(6 downto 4) = "000") report "Error: multiple grant to AXI" severity ERROR;

      state_idle <= << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(0); -- return to idle
      state_idle_rise <= not state_idle and << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(0);

      ev_if_req <= << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_if_req : std_logic >>;
      ev_if_req_rise <= not ev_if_req and << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_if_req : std_logic >>;

    end if;
  end process ddr3_stat_pr;

  -- note: DDR3 controller possible errors:
  --   - burst_cnt < min burst
  --
  -- ddr3_core_errors_src(0) <= '0';
  -- ddr3_core_errors_src(1) <= '0';
  -- ddr3_core_errors_src(2) <= '0';
  -- ddr3_core_errors_src(3) <= '1' when (<< signal .ddr3_tr_tb.use_ddr_driver_g.use_ddr_driver_1.data_sort_ddr3_wr_1.burst_cnt : natural range 0 to 127 >> = 1) else '0';
  -- ddr3_core_errors_src(4) <= '1' when (<< signal .ddr3_tr_tb.use_ddr_driver_g.use_ddr_driver_1.evolving_ddr3_wr_1.burst_cnt : natural range 0 to 127 >> = 1) else '0';
  -- ddr3_core_errors_src(5) <= '0';
  -- ddr3_core_errors_src(6) <= ddr3_core_errors_src_r(1) when (ddr3_core_errors_src_r(3) = '1' or ddr3_core_errors_src_r(4) = '1') else '1';
  -- ddr3_core_errors_src(7) <= ddr3_core_errors_src(0) when
  --                            ((ddr3_core_errors_src(1) = '1' and ddr3_core_errors_src_r(1) = '0') or
  --                             (ddr3_core_errors_src(2) = '1' and ddr3_core_errors_src_r(2) = '0')) else '1';
  -- assert (ddr3_core_errors_src(6) = '1') report "Something wrong N2 in DDR3 arbiter!" severity ERROR;
  -- assert (ddr3_core_errors_src(7) = '1') report "Something wrong N1 in DDR3 arbiter!" severity ERROR;


  -- init_done_g: if (DDR3_WAIT_DONE) generate
  --   INIT_DONE_ALL <= (INIT_DONE_ALL_O = '1');
  -- else generate
  --   INIT_DONE_ALL <= FALSE, TRUE after 100 US; -- !debug: 13/12/2016 added for case if no DDR3 model
  -- end generate init_done_g;
  init_done_g2: if (not DDR3_WAIT_DONE) generate
    INIT_DONE_ALL_O <= '0', '1' after 100 US; -- !debug: 13/12/2016 added for case if no DDR3 model
    TOP_CLK_MEM_128M_O <= not TOP_CLK_MEM_128M_O after 3.125 NS;
  end generate init_done_g2;

  INIT_DONE_ALL <= (INIT_DONE_ALL_O = '1');

  -- Reset
  RESET_I        <= '0', '1' after 1000 NS;
  RESET_128      <= RESET_I;
  RESET_40       <= RESET_I;

  -- Clock and clock enables:
  SYSTEM_CLK64_I <= not SYSTEM_CLK64_I after 7.8125 NS; -- 64MHz
  clk20        <= not clk20        after 25 NS; -- RX word clock, 20MHz
  CLK_16M <= not CLK_16M after 31.25 NS; -- PORTS CLK, 16MHz
  pll_ref_clk <= not pll_ref_clk after 7.8125 NS; -- now virtually same as SYSTEM_CLK64_I, possible change frequency or phase
  -- sys_clk_i <= not sys_clk_i after CLKIN_PERIOD/2;
  -- clk_ref_i <= not clk_ref_i after REFCLK_PERIOD;
  sys_clk_p <= not sys_clk_p after CLKIN_PERIOD/2;
  sys_clk_n <= not sys_clk_p;

  -- 160MHz RX serial clock, then 1:8 enable byte save pulse
  clk_en_20m_pr : process is
  begin  -- process clk_en_pr

    CLK_EN_20M <= '1';
    wait for 6.25 NS;
    CLK_EN_20M <= '0';
    wait for 6.25*7 NS;

  end process clk_en_20m_pr;


  -- 13/12/2016 one 15.625ns pulse each 62.5ns
  clk_en_16m_pr : process is
  begin  -- process clk_en_pr

    wait on SYSTEM_CLK64_I until SYSTEM_CLK64_I = '1';
    wait for 200 PS;
    PORTS_CLK_EN <= '1';
    wait for 15.625 NS;                 -- pulse 64MHz
    PORTS_CLK_EN <= '0';
    wait for (62.5 NS - 15.625 NS);

  end process clk_en_16m_pr;

  PORTS_CLK_LAUNCH_EN <= PORTS_CLK_EN;  -- in my test have same phase

  ---------------------------------------------------------------------------------------------------


  -- Sending commands to PORT bus
  cmds2ports_pr: process is
    variable shedule_time_v : time;
  begin  -- process cmds2ports_pr

    wait for 5 US;
    wait on CLK_16M until (CLK_16M = '1');
    wait for 200 PS;

    if (not PORTBUS_EN) then
      wait;                             -- !debug: 27/12/2016 disable  PORT_* interface registers test
    end if;

    for i in ports_test_c'range loop

      PORT_WRITE_I <= '1';              -- active '0'
      PORT_READ_I <= '1';               -- active '0'
      PORT_ALE_I <= '1';                -- active '0'
      PORT_A_D_B <= (others => 'Z');

      -- If special events, not WR/RD commands
      if (ports_test_c(i).cmd = "OK") then
        report "PORTS test done" severity NOTE;
      end if;
      if (ports_test_c(i).cmd = "ST") then -- all shedule pass
        wait;
      end if;

      -- Shedule, when send command
      shedule_time_v := ports_test_c(i).shedule_time;
      assert (now < shedule_time_v) report "Sheduler was not ready!!!" severity ERROR;
      wait for (shedule_time_v - now);

      wait on CLK_16M until (CLK_16M = '1');
      wait for 200 PS;

      -- Send command (address, then data)
      --
      -- Send address
      if (ports_test_c(i).cmd /= "OK") then -- valid WR/RD command
        PORT_ALE_I <= '0';
      end if;
      PORT_A_D_B <= ports_test_c(i).addr;
      if (ports_test_c(i).cmd = "WR") then
        PORT_WRITE_I <= '0';
      elsif (ports_test_c(i).cmd = "RD") then
        PORT_READ_I <= '0';
      end if;

      wait on CLK_16M until (CLK_16M = '1');
      wait for 200 PS;

      -- Send/receive data
      PORT_ALE_I <= '1';
      if (ports_test_c(i).cmd = "WR") then
        PORT_WRITE_I <= '0';
        PORT_A_D_B <= ports_test_c(i).data;
      elsif (ports_test_c(i).cmd = "RD") then
        PORT_READ_I <= '0';
        PORT_A_D_B <= (others => 'Z');
      end if;

      wait on DDR_DRIVER_ACK for 125 NS;
      wait on CLK_16M until (CLK_16M = '1');
      wait for 200 PS;

      -- Check acknowledge from peripheral
      if ((ports_test_c(i).cmd = "WR" or ports_test_c(i).cmd = "RD") and
          (unsigned(PORT_A_D_B(7 downto 0)) < to_unsigned(BUFFER_CONTROL_TOP_ADDR,8) and
           unsigned(PORT_A_D_B(7 downto 0)) > to_unsigned(BUFFER_CONTROL_BOTTOM_ADDR,8))) then
        assert (DDR_DRIVER_ACK = '0')
          report "After PORTS command no ACK, port address 0x" & to_hstring(PORT_A_D_B)
          severity WARNING;
      end if;

      wait on CLK_16M until (CLK_16M = '1');
      wait for 200 PS;


    end loop;  -- i

  end process cmds2ports_pr;


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


  -- purpose: RAW data packet write to DDR3
  sorter_bfm_pr : process is
    variable shedule_time_v : time;
    variable reading_num_lsb_v : std_logic_vector(7 downto 0);
  begin  -- process sorter_bfm_pr

    DATA_SORTER_PRE_FRAME_START <= '0';
    DATA_SORTER_DATA_EN         <= '0';
    DATA_SORT_DOUT              <= (others => '0');

    wait until RESET_I = '1';
    wait until init_done_all;
    wait until Rising_Edge(clk20);
    wait until Rising_Edge(clk20);
    wait for 100 PS;

    if (FALSE) then                      -- !debug: 29/12/2016 disabled, re-enable after test module will OK
      wait;
    end if;

    for i in 0 to READINGS_NUM -1 loop
    --    for i in 0 to BUNDLES_NUM -1 loop

      DATA_SORTER_PRE_FRAME_START <= '0';
      num_words                   <= 0;
      DATA_SORTER_DATA_EN         <= '0';
      DATA_SORT_DOUT              <= (31 downto 24 => '0', 23 downto 16 => '1', others => '0');
      reading_num_lsb_v := std_logic_vector(to_unsigned(i,8));
      fq_reading_num <= std_logic_vector(to_unsigned(i,8));
      params_ready <= '0';

      -- send PRE_FRAME_START pulse
      wait until Rising_Edge(clk20);
      wait for 100 PS;
      -- DATA_SORTER_PRE_FRAME_START <= '1';
      -- wait until Rising_Edge(clk20);
      -- wait until Rising_Edge(clk20);
      -- wait for 100 PS;
      -- DATA_SORTER_PRE_FRAME_START <= '0';
      -- wait until Rising_Edge(clk20);
      -- wait for 15.625 * 7 NS;           -- ~8-10 cycles
      -- wait for 100 PS;

      shedule_time_v := now;            -- set reading (bundle) start time
                                        -- note: this in place IP

      wait for 10 US;                   -- params_ready - all received from CDM
      wait until Rising_Edge(clk20);
      wait for 100 PS;
      params_ready <= '1';

      wait for 30 US;                   -- data received from tiles
      wait until Rising_Edge(clk20);
      wait for 100 PS;

      DATA_SORTER_DATA_EN         <= '1';  -- data strobe start in same time with data

      -- -- send local header
      -- -- !TODO: 13/12/2016 change header size from 2x 32bit words to 4x 32bit words
      -- -- first local header word
      -- DATA_SORT_DOUT <= (X"F000" & reading_num_lsb_v & -- 24bit Reading number, sequential, reset on the beginning of every scan
      --                        X"AA");    -- 8bit UID (SHOT_NUM) (old)
      -- wait until Rising_Edge(clk20);
      -- wait for 100 PS;
      -- -- second local header word
      -- DATA_SORT_DOUT <= (std_logic_vector(TO_UNSIGNED(BUNDLES_NUM,8)) &  -- 8bit num_of_slices - determines number of slices in the present scan
      --                        "010" &  -- 3bit num. of bits per detector - can be 16 ("010"), 24 or 48
      --                        "00" &     -- 2bit Reading Type: Raw/EV/Offset ("00" - RAW)
      --                        '1' &  -- 1bit make data - received data is scan data ('1') or idle data ('0')
      --                        '1' &      -- 1bit data valid
      --                        '0' &      -- 1bit TMC CRC ERROR
      --                        '0' &      -- 1bit ECC error during slice
      --                        "00" &     -- 2bit indicating type of slice merge (EV readings only)
      --                        "00" &     -- 2bit indicating Focal-spot merge (EV readings only)
      --                        -- "10101010101");  -- 11bit spare  Sum: X"0000_01AA_2046_0000" !debug, test change: msb X"F"
      --                        "000" & X"10");  --  !debug: 16/01/2020 Hawk: [41..32] - slices_num
      -- wait until Rising_Edge(clk20);
      -- wait for 100 PS;
      -- -- 19/12/2016 third local header word (reserved)
      -- DATA_SORT_DOUT <= (0 => '1', others => '0'); -- 13/01/2020 UNIQ_ID
      -- wait until Rising_Edge(clk20);
      -- wait for 100 PS;
      -- -- 19/12/2016 fourth local header word (reserved)
      -- DATA_SORT_DOUT <= (others => '1');
      -- wait until Rising_Edge(clk20);
      -- wait for 100 PS;

      -- first data word
      num_words <= num_words + 1;
      -- 13/12/2016 seems in simulation in header in place reading number sends constant, but reading number sends in first data word
      --      DATA_SORT_DOUT <= (31 downto 24 => '0', 23 downto 16 => '1', others => '0');
      DATA_SORT_DOUT(31 downto 21) <= (31 => '1', others => '0');
      DATA_SORT_DOUT(20 downto 16) <= std_logic_vector(to_unsigned(i,5)); -- reading number
      DATA_SORT_DOUT(15 downto 0) <= (others => '0');

      wait until Rising_Edge(clk20);
      wait for 100 PS;

      l1 : loop
        num_words           <= num_words + 1;
        DATA_SORT_DOUT      <= std_logic_vector(unsigned(DATA_SORT_DOUT) + 1);  -- next word: 1,2,3...
        wait until Rising_Edge(clk20);
        wait for 100 PS;
        exit l1 when (num_words = (BUNDLE_SIZE * BUNDLES_NUM)); -- <words in reading> * <readings num>
      end loop l1;

      DATA_SORTER_DATA_EN <= '0';       -- end reading frame

      wait for (BUNDLE_SORTER_DELAY - (now - shedule_time_v)); -- wait for next reading

      -- wait until DDR_DRIVER_TESTPOINTS(0) = '0'; -- !debug: 13/12/2016 ?!

      if (powerup_test_mode) then
        wait;                           -- after memory test data in memory not valid
      end if;

    end loop;  -- i

  end process sorter_bfm_pr;


  -- purpose: EV data packet write to DDR3
  ev_ctl_bfm_pr : process is
    variable shedule_time_v : time;
    variable reading_num_lsb_v : std_logic_vector(7 downto 0);
  begin  -- process ev_ctl_bfm_pr

    EVOLVING_PRE_FRAME_START <= '0';
    EVOLVING_DATA_EN         <= '0';
    EVOLVING_DOUT            <= (others => '0');

    wait until RESET_I = '1';
    wait until init_done_all;

    wait for 10 US;                     -- !debug: 21/01/2020 prevent EV and FQ readings in same time, remove after debug

    wait until Rising_Edge(clk20);
    wait until Rising_Edge(clk20);
    wait for 100 PS;

    if (TRUE) then                      -- !debug: 29/12/2016 disabled, re-enable after test module will OK
      wait;
    end if;

    for i in 1 to EV_READINGS_NUM loop

      EVOLVING_PRE_FRAME_START <= '0';
      ev_num_words             <= 0;
      EVOLVING_DATA_EN         <= '0';
      EVOLVING_DOUT            <= (31 downto 24 => '0', 23 downto 16 => '1', others => '0');
      reading_num_lsb_v := std_logic_vector(to_unsigned(i,8));

      wait on clk20 until clk20 = '1';
      wait for 100 PS;

      -- FRAME_START pulse
      EVOLVING_PRE_FRAME_START <= '1';
      wait until Rising_Edge(clk20);
      wait until Rising_Edge(clk20);
      wait for 100 PS;
      EVOLVING_PRE_FRAME_START <= '0';
      wait for 15.625 * 7 NS;           -- ~8-10 cycles
      wait until Rising_Edge(clk20);
      wait for 100 PS;

      shedule_time_v := now;            -- set reading (bundle) start time

      EVOLVING_DATA_EN         <= '1';  -- 1st strobe before data

      -- send local header
      -- !TODO: 13/12/2016 change header size from 2x 32bit words to 4x 32bit words
      -- first local header word
      EVOLVING_DOUT <= (X"F000" & reading_num_lsb_v &  -- 24bit Reading number, sequential, reset on the beginning of every scan
                             X"AA");    -- 8bit UID (SHOT_NUM)
      wait until Rising_Edge(clk20);
      wait for 100 PS;
      -- second local header word
      EVOLVING_DOUT <= (std_logic_vector(TO_UNSIGNED(EV_SLICES_NUM,8)) &  -- 8bit num_of_slices - determines number of slices in the present scan
                             "010" &  -- (23:21) 3bit num. of bits per detector - can be 16 ("010"), 24 or 48
                             "01" &   -- (20:19) 2bit Reading Type: Raw/EV/Offset ("01" - EV)
                             '1' &  -- 1bit make data - received data is scan data ('1') or idle data ('0')
                             '1' &      -- 1bit data valid
                             '0' &      -- 1bit TMC CRC ERROR
                             '0' &      -- 1bit ECC error during slice
                             "00" &     -- 2bit indicating type of slice merge (EV readings only)
                             "00" &     -- 2bit indicating Focal-spot merge (EV readings only)
                             -- "10101010101");  -- 11bit spare  Sum: X"0000_01AA_2046_0000" !debug, test change: msb X"F"
                             "000" & std_logic_vector(TO_UNSIGNED(EV_SLICES_NUM,8)));  --  !debug: 16/01/2020 Hawk: [41..32] - slices_num

      wait until Rising_Edge(clk20);
      wait for 100 PS;
      -- 19/12/2016 third local header word (reserved)
      EVOLVING_DOUT <= (0 => '1', others => '0'); -- 13/01/2020 UNIQ_ID
      wait until Rising_Edge(clk20);
      wait for 100 PS;
      -- 19/12/2016 fourth local header word (reserved)
      EVOLVING_DOUT <= (others => '1');
      wait until Rising_Edge(clk20);
      wait for 100 PS;


      -- first data word
      ev_num_words           <= ev_num_words + 1;
      EVOLVING_DOUT(31 downto 21) <= (31 => '1', others => '0');
      EVOLVING_DOUT(20 downto 16) <= std_logic_vector(to_unsigned(i,5));
      EVOLVING_DOUT(15 downto 0) <= (others => '0');

      wait until Rising_Edge(clk20);
      wait for 100 PS;

      l1 : loop
        ev_num_words       <= ev_num_words + 1;
        EVOLVING_DOUT      <= std_logic_vector(unsigned(EVOLVING_DOUT(31 downto 4)) + 1) &
                              std_logic_vector'(X"0");  -- 11,12,13...
        wait until Rising_Edge(clk20);
        wait for 100 PS;
        exit l1 when (ev_num_words = (BUNDLE_SIZE * EV_SLICES_NUM/4));
      end loop l1;

      EVOLVING_DATA_EN <= '0';

      wait for (BUNDLE_EV_DELAY - (now - shedule_time_v)); -- wait for next reading

      -- wait until DDR_DRIVER_TESTPOINTS(0) = '0'; -- !debug: 13/12/2016 ?!

      if (powerup_test_mode) then
        wait;                           -- after memory test data in memory not valid
      end if;

    end loop;  -- i

  end process ev_ctl_bfm_pr;


  -- purpose: Signals from Communication FPGA
  -- 13/12/2016 seems this signals from 160MHz LVDS interface
  comm1_bfm_pr : process is
    variable readings_num_cnt_v : natural range 0 to 31 := 0;
    variable ev_readings_num_cnt_v : natural range 0 to 31 := 0;
  begin  -- process comm1_bfm_pr

    SLICE_REQ_INT    <= '0';
    REGULAR_REQ_INT  <= '0';
    EVOLVING_REQ_INT <= '0';
    INC_RRQ_INT      <= '0';

    regular_reading <= FALSE;

    wait until (RESET_I = '1' and init_done_all);

    -- read_l1 : for i in 1 to (READINGS_NUM + EV_READINGS_NUM) loop
    read_l1 : for i in 1 to 4 loop -- !debug: 22/09/2022 temporary for case 200uS IP and no EV

      if (powerup_test_mode) then
        wait;                           -- after memory test data in memory not valid
      end if;

      if (not do_reg_read and not do_ev_read) then
        wait until (do_reg_read and not do_ev_read) or  -- no ptr_buffer_underflow
          do_ev_read;                                   -- no ev_slots_underflow
      else
        null;
      end if;

      regular_reading <= FALSE;

      wait on CLK_EN_20M until CLK_EN_20M = '1';

      if (do_reg_read and not do_ev_read) then
        REGULAR_REQ_INT <= '1';         -- according High Speed Concentrator
                                        -- Connection Fig.3
        regular_reading <= TRUE;
        if (readings_num_cnt_v /= 0) then      -- if not 1st reading
          INC_RRQ_INT <= '1'; -- ! need be smaller from REGULAR_REQ_INT
        end if;
        readings_num_cnt_v := (readings_num_cnt_v + 1) mod 32;
      else
        EVOLVING_REQ_INT <= '1';
        if (ev_readings_num_cnt_v /= 0) then      -- if not 1st reading
          INC_RRQ_INT <= '1'; -- ! need be smaller from REGULAR_REQ_INT
        end if;
        ev_readings_num_cnt_v := (ev_readings_num_cnt_v + 1) mod 32;
      end if;

      wait on CLK_EN_20M until CLK_EN_20M = '1';
      wait for 50*2 NS;
      REGULAR_REQ_INT  <= '0';
      EVOLVING_REQ_INT <= '0';
      INC_RRQ_INT      <= '0';

      if (regular_reading) then         -- Regular mode

        read_l2 : for i2 in 1 to BUNDLES_NUM loop
          wait for 50*5 NS;
          SLICE_REQ_INT <= '1';
          wait on CLK_EN_20M until CLK_EN_20M = '1';
          wait for 50*2 NS;
          SLICE_REQ_INT <= '0';
          wait for 1 US;               -- for simulation purpose
        end loop read_l2;

      else

        read_l3 : for i3 in 1 to EV_SLICES_NUM/4 loop
          wait for 50*5 NS;
          SLICE_REQ_INT <= '1';
          wait on CLK_EN_20M until CLK_EN_20M = '1';
          wait for 50*2 NS;
          SLICE_REQ_INT <= '0';
          wait for 1 US;               -- for simulation purpose
        end loop read_l3;

      end if;

      wait for 40 US;               -- 29/01/2017 wait for next packet (not real IP)  was   10 US

    end loop read_l1;
    wait;

  end process comm1_bfm_pr;


  -- ddr_rdata_64bit <= DDR_A_LOCAL_RDATA_TB & DDR_A_LOCAL_RDATA_TB;
  --
  --
  -- -- purpose: Check data from DDR2
  -- read_monitor_pr : process is
  --   file read_out_file    : text;
  --   variable L            : line;
  --   variable decoded_addr : std_logic_vector (26 downto 0) := (others => '0'); -- !TODO: 13/12/2016 change for compatibility with DDR3 memory model
  -- begin  -- process read_monitor_pr
  --
  --
  --   wait until RESET_I = '1';
  --   --    wait until READ_BUS_DONE_TB = '0';  -- in read mode
  --
  --   if (powerup_test_mode) then
  --     wait;                           -- !debug: 13/12/2016 write to file temporary disabled
  --   end if;
  --
  --   FILE_OPEN(read_out_file, "read_out_file.txt", WRITE_MODE);
  --
  --   while (now < 249 US) loop
  --
  --     --      wait on TOP_CLK_MEM_128M_O until
  --     --        (TOP_CLK_MEM_128M_O = '1' and DDR_A_LOCAL_RDATA_VALID_TB = '1');
  --     --      write( L, string'(time'image(now) & ":  ") );
  --     --      hwrite(L,ddr_rdata_64bit);
  --     --      writeline(read_out_file, L);
  --
  --     wait until TOP_CLK_MEM_128M_O = '1';
  --
  --     if (mem_CS_N = '0') then        -- write/read address report
  --
  --       if (mem_RAS_N = '0' and mem_CAS_N = '1' and mem_WE_N = '1') then  -- ACT
  --         decoded_addr(26 downto 24) := mem_BA;                               -- bank_addr
  --         decoded_addr(23 downto 10) := mem_A(13 downto 0);                   -- row_addr
  --       end if;
  --
  --       if (mem_RAS_N = '1' and mem_CAS_N = '0' and mem_WE_N = '0') or  -- WR
  --                                     (mem_RAS_N = '1' and mem_CAS_N = '0' and mem_WE_N = '1') then  -- RD
  --         decoded_addr(9 downto 0) := (mem_A(11) & mem_A(9 downto 1));    -- col_addr
  --
  --         write(L, string'(time'IMAGE(now) & ":  "));
  --         write(L, natural'IMAGE(to_integer(unsigned(decoded_addr))));
  --         write(L, string'("   Hex address: "));
  --         hwrite(L, "00" & decoded_addr);
  --         writeline(read_out_file, L);
  --       end if;
  --
  --     end if;
  --
  --     if (DDR_A_LOCAL_RDATA_VALID_TB = '1') then
  --       write(L, string'(time'IMAGE(now) & " Read data:  "));
  --       hwrite(L, ddr_rdata_64bit);
  --       writeline(read_out_file, L);
  --     end if;
  --
  --   end loop;
  --
  --   FILE_CLOSE(read_out_file);
  --
  -- end process read_monitor_pr;


  -- DDR_DRIVER_TESTPOINTS(15 downto 8) represent LSB bits of ptr_addr_cmp_underflow_result

  -- Frequent read (when no underflow state)
  do_reg_read <= FALSE, (DDR_DRIVER_TESTPOINTS(1) = '0') after 1.0 MS; -- !debug: 08/01/2017 when not ptr_buffer_underflow
  -- do_ev_read <= FALSE, (DDR_DRIVER_TESTPOINTS(2) = '0') after 0.55 MS, FALSE after 0.7 MS; -- !debug: 08/01/2017 temporary disabled DDR_DRIVER_TESTPOINTS(2) = '0';  -- not EV_BUFFER_UNDERFLOW
  do_ev_read <= FALSE; -- !debug: 15/09/2022 only FQ read

  -- Port_a_d_b --> Bi-Dir is cancelled only for ddr block ( in favor of partition)
	with Bi_Dir_Direction select
		PORT_A_D_B <= PORT_A_D_B_OUT when '1',
					  "ZZZZZZZZZZZZZZZZ" when others;
PORT_A_D_B_IN <= PORT_A_D_B;


  -- 01/01/2020

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


--   -- Checker description:
--   --  - start_event: << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.start_read : std_logic >>
--   --  - test_expr: << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>
--   --  - num_cks - read latency 50
--   --  - fire - NA, can be used << .ddr3_tr_tb/ovl_change_1/u/error_count : std_logic_vector(31 downto 0) >>
--   --  - OVL_ASSUME_2STATE -> OVL_FIRE_2STATE
--   ovl_change_1: ovl_change
--   generic map (
--     severity_level		=> OVL_ERROR,
--     num_cks				=> 50,
--     action_on_new_start => OVL_ERROR_ON_NEW_START, -- OVL_IGNORE_NEW_START/OVL_RESET_ON_NEW_START/OVL_ERROR_ON_NEW_START
--     property_type	   => OVL_ASSUME, -- OVL_ASSERT/OVL_ASSUME/OVL_IGNORE/OVL_ASSERT_2STATE/OVL_ASSUME_2STATE
--     msg					=> "Error: no responce from AXI master to read command",
--     coverage_level		=> OVL_COVER_ALL -- OVL_COVER_BASIC,
--     -- clock_edge		   => OVL_POSEDGE,
--     -- reset_polarity	   => OVL_ACTIVE_LOW,
--     -- gating_type		   => OVL_GATE_CLOCK
--     )
--   port map (
--     clock		=> ui_clk,
--     reset		=> "not"(ui_clk_sync_rst), -- active low
--     enable		=> '1',
--     start_event => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.start_read : std_logic >>, -- falling
--     test_expr(0) => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(2),
--     fire		=> open
--   );
--
--   -- !debug: 20/01/2020 error: vcom Message # 1300: Only object classes of VARIABLE, CONSTANT, and SIGNAL are valid for external names
--   -- assert not(<< .ddr3_tr_tb.ovl_change_1.u.error_count : integer >> = 0) report "Error: no responce from AXI master to read command" severity ERROR;
--
--   ev_win_change_1 : ovl_win_change
--     generic map (
--       severity_level => OVL_ERROR,
--       -- width          => width,
--       property_type  => OVL_ASSUME,
--       msg            => "Error: no responce to EV request",
--       coverage_level => OVL_COVER_ALL,
--       -- clock_edge     => clock_edge,
--       -- reset_polarity => reset_polarity,
--       -- gating_type    => gating_type,
--       controls       => OVL_CTRL_DEFAULTS)
--     port map (
--       clock       => ui_clk,
--       reset       => "not"(ui_clk_sync_rst), -- active low
--       enable      => '1',
--       start_event => ev_if_req_rise,
--       test_expr(0)   => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.start_write : std_logic >>,
--       end_event   => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.fifo_wdata_valid : std_logic >>,
--       fire        => open
--     );
--
--   init_signal_spy( "/ddr3_tr_tb/ev_win_change_1/u/error_count", "ev_error_count" );
--   assert (ev_error_count = 32UX"0")
--     report "Error: FQ handshake - no answer to write request" severity ERROR;
--
--   ev_handshake_1 : ovl_handshake
--     generic map (OVL_ERROR, 0, 40, 0, 0, 1) -- min_ack_cycle, max_ack_cycle, req_drop, deassert_count, max_ack_length
--                                 -- min_ack_cycle=0, max_ack_cycle=10, req_drop = 0
--     port map
--     (clock  => ui_clk,
--      reset  => "not"(ui_clk_sync_rst), -- active low
--      enable => '1',
--      req    => ev_handshake_1_req,
--      ack    => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.start_write : std_logic >>,
--      fire    => open
--    );
--
--   ev_handshake_1_req <= << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_if_req : std_logic >> and << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.master_axi_state : std_logic_vector(7 downto 0) >>(4);
--   init_signal_spy( "/ddr3_tr_tb/ev_handshake_1/u/r_state", "r_state" );
--   assert (r_state /= "10")
--     report "Error: EV handshake - no answer to write request" severity ERROR;
--
--   -- fq_handshake_1 : ovl_handshake
--   --   generic map (OVL_ERROR, 0, 10, 0, 0, 0) -- min_ack_cycle, max_ack_cycle, req_drop, deassert_count, max_ack_length
--   --                               -- min_ack_cycle=0, max_ack_cycle=10, req_drop = 0
--   --   port map
--   --   (clock  => ui_clk,
--   --    reset  => "not"(ui_clk_sync_rst), -- active low
--   --    enable => '1',
--   --    req    => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.start_write : std_logic >>,
--   --    ack    => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.fifo_rd_en : std_logic >>,
--   --    fire    => open
--   --  );
--
--   fq_win_change_1 : ovl_win_change
--     generic map (
--       severity_level => OVL_ERROR,
--       property_type  => OVL_ASSERT, -- OVL_ASSUME,
--       msg            => "Error: no responce to EV request",
--       coverage_level => OVL_COVER_BASIC, -- OVL_COVER_ALL,
--       controls       => OVL_CTRL_DEFAULTS)
--     port map (
--       clock       => ui_clk,
--       reset       => "not"(ui_clk_sync_rst), -- active low
--       enable      => '1',
--       start_event => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.start_write : std_logic >>,
--       test_expr(0)   => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.fifo_rd_en : std_logic >>,
--       end_event   => state_idle_rise, -- return to idle
--       -- !TODO: 23/02/2022 replace to rising
--       fire        => open
--     );
--
--   init_signal_spy( "/ddr3_tr_tb/fq_win_change_1/u/error_count", "fq_error_count" );
--   assert (fq_error_count = 32UX"0")
--     report "Error: FQ handshake - no answer to write request" severity ERROR;
--
--   -- /ddr3_tr_tb/use_ddr_driver_g/ddr_driver_1/axi4_master_vhdl_inst/U0/axi4_master_vhdl_v2_0_M00_AXI_inst
--   m00_handshake_1 : ovl_handshake
--     generic map (OVL_ERROR, 0, 0, 0, 0, 2) -- min_ack_cycle, max_ack_cycle, req_drop, deassert_count, max_ack_length
--                                 -- min_ack_cycle=0, max_ack_cycle=10, req_drop = 0
--     port map
--     (clock  => ui_clk,
--      reset  => "not"(ui_clk_sync_rst), -- active low
--      enable => '1',
--      req    => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.axi4_master_vhdl_inst.U0.axi4_master_vhdl_v2_0_M00_AXI_inst.axi_wlast : std_logic >>,
--      ack    => << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.axi4_master_vhdl_inst.U0.axi4_master_vhdl_v2_0_M00_AXI_inst.M_AXI_BVALID : std_logic >>,
--      fire    => open
--    );

--  init_signal_spy( "/ddr3_tr_tb/m00_handshake_1/u/r_state", "r_state_m00_1" );
--  assert (r_state_m00_1 /= "10")
--    report "Error: M00 handshake - no BVALID after WLAST" severity ERROR;

  test2_pr: process (ui_clk) is
    constant MAX_AXI_GRANT_WAIT : natural := 255;  -- max read burst time
  begin  -- process test2_pr
    if (ui_clk'event and ui_clk = '1') then  -- rising clock edge

      if ( << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.DATA_SORT_2_DDR_TP : std_logic_vector(31 downto 0) >>(7) = '1' ) then
        assert (  << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.data_sort_ddr3_wr_1.axi_wait_cnt : natural range 0 to MAX_AXI_GRANT_WAIT >> /= 0)
          report "Error: FQ handshake - no grant" severity ERROR;
      end if;

      if ( << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.EVOLVING_DDR3_WR_TP : std_logic_vector(31 downto 0) >>(2) = '1' ) then
        assert (  << signal .ddr3_tr_tb.use_ddr_driver_g.ddr_driver_1.evolving_ddr3_wr_1.axi_wait_cnt : natural range 0 to MAX_AXI_GRANT_WAIT >> /= 0)
          report "Error: EV handshake - no grant" severity ERROR;
      end if;

    end if;
  end process test2_pr;


  -- 21/09/2022 header
  fq_header_pr: process (clk20, reset_i) is
  begin  -- process fq_header_pr
    if (reset_i = '0') then             -- asynchronous reset (active low)
      tmb_header <= (others => '0');
      tmb_header_rd_r <= '0';
      header_dw_cnt <= 3;
    elsif (clk20'event and clk20 = '1') then  -- rising clock edge

      tmb_header_rd_r <= tmb_header_rd;

      if (tmb_header_rd = '0' and tmb_header_rd_r = '1') then
        header_dw_cnt <= 3;
      elsif (tmb_header_rd = '1') then
        if (header_dw_cnt > 0) then
          header_dw_cnt <= header_dw_cnt - 1;
        end if;
      end if;

      if (header_dw_cnt = 3) then
        -- first local header word
        tmb_header <= (X"F000" & fq_reading_num & -- 24bit Reading number, sequential, reset on the beginning of every scan
                       X"AA");    -- 8bit UID (SHOT_NUM) (old)
      elsif (header_dw_cnt = 2) then
        -- second local header word
        tmb_header <= (std_logic_vector(TO_UNSIGNED(BUNDLES_NUM, 8)) &  -- 8bit num_of_slices - determines number of slices in the present scan
                           "010" &  -- 3bit num. of bits per detector - can be 16 ("010"), 24 or 48
                           "00" &       -- 2bit Reading Type: Raw/EV/Offset ("00" - RAW)
                           '1' &  -- 1bit make data - received data is scan data ('1') or idle data ('0')
                           '1' &        -- 1bit data valid
                           '0' &        -- 1bit TMC CRC ERROR
                           '0' &        -- 1bit ECC error during slice
                           "00" &       -- 2bit indicating type of slice merge (EV readings only)
                           "00" &       -- 2bit indicating Focal-spot merge (EV readings only)
                           -- "10101010101");  -- 11bit spare  Sum: X"0000_01AA_2046_0000" !debug, test change: msb X"F"
                           "000" & X"10");  --  !debug: 16/01/2020 Hawk: [41..32] - slices_num
      elsif (header_dw_cnt = 1) then
        -- 19/12/2016 third local header word (reserved)
        tmb_header <= (0 => '1', others => '0'); -- 13/01/2020 UNIQ_ID
      else
        -- 19/12/2016 fourth local header word (reserved)
        tmb_header <= (others => '1');
      end if;

    end if;
  end process fq_header_pr;


  wr_ptr_num <= resize(unsigned(fq_reading_num)+1,wr_ptr_num'length); -- 22/09/2022 !TODO: 22/09/2022
                                                                    -- replace fq_reading_num with value from SyncP/N
  num_of_slices <= std_logic_vector(to_unsigned(BUNDLES_NUM,num_of_slices'length));

end architecture ddr3_tr_tb_ar;
