-------------------------------------------------------------------------------
-- Title      : EV calc testbench
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : tmb_ev_calc_tb.vhd
-- Author     : Shinderman Eugene
-- Company    : Philips Medical
-- Created    : 13/12/2016
-- Last update: 19/03/2026
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: 2026 changes: perform log (Mu) operation after Slices and FS merging.
-------------------------------------------------------------------------------
-- !TODO:
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

-- library modelsim_lib;
-- use modelsim_lib.util.all;              -- signal spy

use work.tbuf_pack.all;
USE work.phoebe.all;
use work.cdm_registers_pack.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


entity tmb_ev_calc_tb is

end entity tmb_ev_calc_tb;


architecture tmb_ev_calc_tb_ar of tmb_ev_calc_tb is

  signal RESET_I, reset_sys_clk : std_logic := '0';
  signal CLK_50Mhz : std_logic := '0';
  signal rx_clk20 : std_logic := '0';

  signal num_of_slices_after_merge : std_logic_vector(6 downto 0); -- 03/10/2023 must be even

  signal params_ready, params_ready_r : std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
  signal tmb_header_dout32, ev_header_dout32 : std_logic_vector (31 downto 0) := (0 => '1', others => '0');
  signal tmb_header_rd, ev_header_rd : std_logic := '0';
  signal temp_Num_of_Slices, temp_Num_of_Slices_synced2header : std_logic_vector(6 downto 0) := 7UX"10";
  signal ev_new_reading_begin, fq_new_reading_begin : boolean;
  signal fq_header_dw_cnt, ev_header_dw_cnt : natural range 0 to 31;

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
          reading_number_freerun_cnt : in std_logic_vector(15 downto 0); -- 14/06/2023
          tile_packet_ok_timeout_reg : in std_logic_vector(7 downto 0); -- 04/09/2023
          -- mu_ctl_reg          : in std_logic;
          take_rx_det_msb_reg : in std_logic;
          rx_det_shl_reg      : in std_logic;
          -- pipeline_ctl_reg    : in STD_LOGIC_VECTOR(31 downto 0);
          -- AMS_Time            : in std_logic_vector((NumOfTiles*16)-1 downto 0);
          -- ibias               : in std_logic_vector(4 downto 0);
          -- global_ip_time_reg  : in std_logic_vector(15 downto 0);
          -- gain                : in STD_LOGIC_VECTOR(3 downto 0);
          Num_of_Slices       : in std_logic_vector(6 downto 0);		-- 30/10/2022
          AMS_CrcError : in std_logic_vector(NumOfTiles-1 downto 0); -- 05/03/2025
          asic_data_good_read : in std_logic_vector(NumOfTiles-1 downto 0); -- 04/09/2023
          RX_det_m            : in std_logic_vector((NumOfTiles*26)-1 downto 0);
          data_valid_m        : in std_logic_vector(NumOfTiles-1 downto 0);
          RX_det_s            : in std_logic_vector((NumOfTiles*26)-1 downto 0);
          data_valid_s        : in std_logic_vector(NumOfTiles-1 downto 0);
          sorter_data_ready : out std_logic;                    -- 26/11/2023
          dpr_header_updated : in std_logic;                     -- 26/11/2023
          fq_data_valid       : out std_logic;                           -- 30/10/2022
          fq_data_in          : out std_logic_vector(51 downto 0)   -- !debug: 15/03/2026 width 32 -> 52
          );
  end component slices_sorter;

  signal IP, ip_i, synth_ip, ip_valid_sampled, ip_tb, ip_tb_r : std_logic := '0';
  signal ACLK_Master, ACLK_Master_i : std_logic := '0';
  signal aclk_shr_50m  : std_logic_vector(2 downto 0);
  SIGNAL clk_cnt               : integer range 0 to 127 := 0; -- moved from phoebe_controller
  signal CLK_200 : std_logic := '0';
  signal SYNC_DATA_out : std_logic;

  signal fq_data_valid       : std_logic;
  signal fq_data_in          : std_logic_vector(51 downto 0);   -- !debug: 15/03/2026 width 32 -> 52
  signal sorter_data_ready   : std_logic;                    -- 26/11/2023
  signal reading_number_freerun_cnt : std_logic_vector(15 downto 0);

  -- 22/01/2023 Tzvika's SYNC tester
  component tx_ctrl_serdes_wrap_2024 is
    generic (
      G_PARAMS_LEN            : integer range 0 to 64;
      G_TX_DATA_PACKET_SIZE   : std_logic_vector(32-1 downto 0);
      G_TX_HEADER_PACKET_SIZE : std_logic_vector(8-1 downto 0);
      G_TX_FOOTER_PACKET_SIZE : std_logic_vector(8-1 downto 0);
      G_HEADERS               : std_logic;
      G_RESET_POLARITY        : std_logic);
    port (
      CLK_50M                : in  std_logic := '0';
      USER_CLK               : in  std_logic := '0';
      CLK_200M               : in  std_logic := '0';
      ACLK                   : in  std_logic := '0';
      INIT_DONE              : in  std_logic := '0';
      RESET                  : in  std_logic := '0';
      RESET_ERRORS           : in  std_logic_vector(1 downto 0);
      TX_ERRORS              : out std_logic_vector(1 downto 0);
      ERR1_CNT               : out std_logic_vector(31 downto 0);
      ERR2_CNT               : out std_logic_vector(31 downto 0);
      SYNC_DEBUG_REG         : in  std_logic_vector(31 downto 0);
      NUMBER_OF_SLICES       : in  std_logic_vector(16-1 downto 0);
      MAKE_DATA              : in  std_logic := '0';
      IP_LONG                : in  std_logic := '0';
      DFS                    : in  std_logic := '0';
      EN_SWAP                : in  std_logic := '0';
      TX_TRI_IN              : in  std_logic := '0';
      TX_TRI_O               : out std_logic := '0';
      TX_DATA_O              : out std_logic := '0';
      RLT_PTR_ADDRESS_REG    : in  std_logic_vector(31 downto 0);
      HD_PTR_ADDRESS_REG     : in  std_logic_vector(31 downto 0);
      BUF_PTR_ADDRESS        : in  std_logic_vector(31 downto 0);
      STREAM_CTRL            : in  std_logic_vector(7 downto 0);
      RLT_SLICE_MERGE_FACTOR : in  std_logic_vector(7 downto 0);
      FS_MERGE_FACTOR        : in  std_logic_vector(7 downto 0);
      fs_sequence_counter    : in std_logic_vector(7 downto 0); -- !debug: ES 07/02/2024
      FQ_STREAM              : in  std_logic_vector(7 downto 0);
      HEADERS                : in  headers_arr;
      HEADERS_CTRL_REG       : in  std_logic_vector(31 downto 0);
      HEADERS_SAMP_TIME_REG  : in  std_logic_vector(31 downto 0);
      DBG_READING_CNT        : in  std_logic_vector(15-1 downto 0);
      MASTERn_SLAVE          : in  std_logic);
  end component tx_ctrl_serdes_wrap_2024;


  signal fq_stream_i, FQ_STREAM          : std_logic_vector(7 downto 0) := X"00";
  signal READING_NUMBER_REG : std_logic_vector(15 downto 0) := (others => '0');
  signal CT_TYPE, ct_type_i : std_logic_vector(15 downto 0) := X"1020";
  signal dms_status_i : std_logic_vector(15 downto 0);
  signal HD_PTR_ADDRESS_REG : std_logic_vector(31 downto 0) := X"00108800"; -- FQ WR addr
  signal RLT_PTR_ADDRESS_REG : std_logic_vector(31 downto 0) := (others => '0'); -- EV WR addr
  signal rlt_slice_merge_factor_i, RLT_SLICE_MERGE_FACTOR, FS_MERGE_FACTOR, fs_sequence_counter, fs_merge_factor_i : std_logic_vector(7 downto 0) := (others => '0');
  signal DFS, DFS_i : std_logic := '0';
  signal MAKE_DATA_i_start, MAKE_DATA_i_start_r, MAKE_DATA, MAKE_DATA_r, data_valid_i, data_valid_r : std_logic := '0'; -- MAKE_DATA_i,
  signal make_data_cnt : natural range 0 to 31 := 0;

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
      fs_sequence_counter      : out std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
      fq_stream_enable         : OUT STD_LOGIC;
      temp_Num_of_Slices       : out std_logic_vector(6 downto 0); -- 23/11/2023
      reading_number_freerun_cnt_o : out std_logic_vector(15 downto 0); -- 23/11/2023
      make_data_from_sync : out std_logic; -- 05/05/2024
      bad_packet_received : OUT std_logic;
    SYNC_EN_SWAP : in std_logic;             -- !debug: 03/03/2026
    RLT_PTR_ERR_INJECT : in std_logic_vector(1 downto 0);           -- !debug: 03/03/2026
    HD_PTR_ERR_INJECT : in std_logic_vector(1 downto 0);           -- !debug: 03/03/2026
    SYNTH_RLT_PTR_ADDRESS_REG : in std_logic_vector(31 downto 0);           -- !debug: 03/03/2026
    SYNTH_HD_PTR_ADDRESS_REG : in std_logic_vector(31 downto 0);           -- !debug: 03/03/2026
    skip_IP_packet          : in    std_logic;          -- 09/03/2026 0x63A0 [8]
    skip_scan_header_packet : in    std_logic;          -- 09/03/2026 0x63A0 [9]
    ERR_INJ             : in  std_logic; -- !debug: 03/03/2026 CRC error inject
    SYNC_CRC_INJ_CNT    : out	std_logic_vector(15 downto 0);           -- !debug: 03/03/2026
    ip_pkt_cnt          : out	std_logic_vector(15 downto 0);           -- !debug: 09/03/2026
    headers_pkt_cnt     : out	std_logic_vector(15 downto 0);           -- !debug: 09/03/2026
      RX_ERRs             : OUT	std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      );
  end component IP_DATAVAL_HEADER_TOP;

  signal make_data_from_sync : std_logic;
  signal Module_TX_RX_channel_RDY : std_logic;
  signal IP_READY            : STD_LOGIC;
  signal IP_DATA_OUT         : STD_LOGIC_VECTOR(IP_DATA_OUT_VAL-1 DOWNTO 0);
  signal HEADER_DATA_OUT     : STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);
  signal header_dpr_addr : std_logic_vector(5 downto 0) := (others => '0');

  signal rlt_address_from_sync    : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
  signal hd_ptr_address_from_sync : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
  signal slice_merging_factor, slice_merging_factor_synced2header     : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  signal fs_merging_factor, fs_merging_factor_synced2header        : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  signal fq_stream_enable, fq_stream_enable_synced2header         : std_logic := '0';
  signal stream_enable            : std_logic_vector(1 downto 0);

  signal buffer_go, buffer_go_r : std_logic;
  signal buffer_tx_data_in	 : std_logic_vector (7 downto 0);
  signal buffer_tx_rd_empty	 : std_logic := '0';
  signal buffer_tx_rd_req, buffer_tx_rd_req_r	 : std_logic;
  signal ddr3_rq_word_idx : natural range 0 to 7 := 0;
  signal Buffer_TX_DATA_out, buffer_data_valid : std_logic;
  signal buffer_data : std_logic_vector(7 downto 0);
  signal ddr3_rq_word : std_logic_vector(31 downto 0);


  component memory_buffer_if_tmp is
    generic (
      WORD_WIDTH : natural);
    port (
      sys_clk            : in  std_logic;  -- system clock @50MHz
      rst_n              : in  std_logic;
      IP50               : in  std_logic;
      Num_of_Slices      : in std_logic_vector(6 downto 0);
      slice_merge        : in  std_logic;
      mu_ctl_reg         : in std_logic;                          -- 15/11/2023
      pipeline_ctl_reg   : in STD_LOGIC_VECTOR(31 downto 0);
      AMS_Time	       : in std_logic_vector((NumOfTiles*16)-1 downto 0);
      ibias	       : in std_logic_vector(4 downto 0);
      global_ip_time_reg : in std_logic_vector(15 downto 0);
      gain	       : in std_logic_vector(3 downto 0);		-- CREG[15..12] - Crst
      rx_det_shl_reg     : in std_logic;                          -- 15/11/2023 [0] - '1' (default) if no MU use rx_det[16..1], '0' use rx_det[15..0]
      dummy_data_sel        : in  std_logic;                      -- 15/11/2023
      test_ctl           : in std_logic_vector(7 DOWNTO 0);       -- 25/01/2024
      slice_merging_factor  : in std_logic_vector(1 DOWNTO 0);
      fs_merging_factor  : in std_logic_vector(1 DOWNTO 0); -- 17/12/2023
      fs_sequence_counter: in std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
      fs_merge_stop      : in std_logic;                    -- 30/03/2024
      sorter_data_ready  : in std_logic;                    -- 04/04/2024
      rlt_address_from_sync : in std_logic_vector(31 DOWNTO 0);
      make_data_from_sync : in std_logic; -- 05/05/2024
      stream_enable      : in std_logic_vector(1 downto 0);     -- FQ & EV
      fq_data_valid      : in  std_logic;
      fq_data_in         : in  std_logic_vector(51 downto 0);   -- !debug: 15/03/2026 width 32 -> 52
      tmb_header_valid   : in std_logic;
      tmb_header         : in std_logic_vector (15 downto 0);
      params_ready       : out std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
      tmb_header_dout32  : out std_logic_vector (WORD_WIDTH-1 downto 0);
      tmb_header_rd      : in std_logic;
      ev_header_dout32   : out std_logic_vector (WORD_WIDTH-1 downto 0);
      ev_header_rd       : in std_logic;
      num_of_slices_no_merge : out std_logic_vector(6 downto 0); -- 17/12/2023
      num_of_slices_after_merge : out std_logic_vector(6 downto 0);
      DATA_SORTER_DATA_EN: out std_logic;
      DATA_SORT_DOUT     : out std_logic_vector (WORD_WIDTH-1 downto 0);
      EVOLVING_DATA_EN   : out std_logic;
      EVOLVING_DOUT      : out std_logic_vector (WORD_WIDTH-1 downto 0)
      );
  end component memory_buffer_if_tmp;

  signal test_ctl           : std_logic_vector(7 DOWNTO 0) := (others => '0');       -- 25/01/2024
  signal test_trig, test_sel : std_logic_vector(3 DOWNTO 0) := (others => '0');      -- 25/01/2024
  signal dpr_header_valid, dpr_header_valid_r : std_logic := '0';

  signal mem_buf_fifo_rdata : std_logic_vector(15 downto 0);
  signal mem_buf_fifo_empty : std_logic;
  signal mem_buf_fifo_rd    : std_logic;
  signal mem_buf_reading_ready : std_logic := '0';

  signal dpr_header_valid_shr : std_logic_vector(2 downto 0);

  constant stamp_time_const : time := 100 us; -- Time Stamp Incrementing by 1 for each 100usec passing
  constant ip_time_const : time := 125 ns; -- IP [L.S.B = 125ns]
  constant ip_period_const : time := 100 us; -- IP period !debug: 28/12/2023 was 200 us
  signal TIME_STAMP_LOW, INTEGRATION_TIME_IN_REG : std_logic_vector(15 downto 0);
  signal REFERENCE_DETECTOR : std_logic_vector(15 downto 0) := X"FBAD";
  signal dpr_header_updated : std_logic := '0';
  -- signal ip_cnt : natural range 0 to 127 := 0;

  signal IP64_vec : std_logic_vector(5 downto 0) := (others => '0');
  signal IP50     : std_logic;

  signal ff_headers_sig :headers_arr := (others => (others => '0'));
  signal fs_sequence_counter_top, fs_sequence_counter_top_synced2header : std_logic_vector(2 DOWNTO 0) := "000";
  signal fs_merge_stop_pre, fs_merge_stop : std_logic := '0';

  signal RX_ERR_INJECT_CTL_REG : std_logic_vector(31 downto 0);      -- !debug: 03/03/2026
  signal SYNTH_RLT_PTR_ADDRESS_REG : std_logic_vector(31 downto 0);  -- !debug: 03/03/2026
  signal SYNTH_HD_PTR_ADDRESS_REG : std_logic_vector(31 downto 0);   -- !debug: 03/03/2026
  signal SYNC_CRC_INJ_CNT	: std_logic_vector(15 downto 0);     -- !debug: 03/03/2026
  signal SYNTH_BUF_PTR_ADDRESS_REG : std_logic_vector(31 downto 0);  -- !debug: 03/03/2026
  signal BUF_CRC_INJ_CNT : std_logic_vector(15 downto 0);  -- !debug: 03/03/2026
  signal rx_err_inject_ctl_clr_0, rx_err_inject_ctl_clr : std_logic; -- 03/03/2026
  signal ip_pkt_cnt          : std_logic_vector(15 downto 0);           -- !debug: 09/03/2026
  signal headers_pkt_cnt     : std_logic_vector(15 downto 0);           -- !debug: 09/03/2026

  signal log2_in, log2_out : std_logic_vector(15 downto 0);

begin  -- architecture tmb_ev_calc_tb_ar


  -- Reset
  RESET_I        <= '0', '1' after 1000 NS;
  reset_sys_clk  <= RESET_I;

  -- Clock and clock enables:
  CLK_50Mhz <= not CLK_50Mhz after 10 NS; -- 50MHz
  rx_clk20 <= not rx_clk20 after 25 NS;
  CLK_200 <= not CLK_200 after 2.5 NS;

  Module_TX_RX_channel_RDY <= '0', '1' after 50 US;


  -- !debug: 12/04/2024
  -- test: switch from default to offset (2 slices), then switch to scan:
  --   - default: streams - 2 (fq_stream = X"01"), slices - 32, slices merging - 1, FS merging - 0
  --   - offset: streams - 1, slices - 2, slices merging - 0, FS merging - 0
  --   - scan: streams - 2, slices - 64, slices merging - 2, FS merging - 1
  --   - check: slices_num in header, EV data size in switch time
  --     - default: W #1 1010 (32 slices/2 slice merging), data size OK for 16 slices
  --     - switch to offset: W #1 1002 (2 slices, no slice merging), data size OK for 2 slices
  --     - switch to scan: W #1 1010 (64 slices/4 slice merging), data size OK for 16 slices
  --     resume: seems OK, but need to check, what uses when write to DDR3
  -- test: scan with odd number:
  --   - 16 IP (make_data_cnt = 15)
  --     result: First reading of a shot - OK, Last reading of a shot - OK
  --   - 17 IP (make_data_cnt = 16)
  --     result:
  --       - before fix: partial_frame = '1' - OK, last_reading_from_merging exist, no W #2 (5)
  --       - after fix: W #2 (5) - OK, W #21 (6) - OK, W #24 (13) - OK
  --
  -- -- test: 12/04/2024
  -- fq_stream_i <= X"01", X"00" after 0.6 MS, X"01" after 1.5 MS;
  -- ct_type_i <= X"1020", X"1002" after 0.6 MS, X"1040" after 1.5 MS; -- header W#1 (set slices_num), note: here no byte swap
  -- rlt_slice_merge_factor_i <= X"01", X"00" after 0.6 MS, X"02" after 1.5 MS; -- [11..10] - Slice Merging: 0 - No Slice Merging, 1 - Merged 2 Slices, 2 - Merged 4 Slices
  -- fs_merge_factor_i <= X"00", X"00" after 0.6 MS, X"01" after 1.5 MS; -- 0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8
  --                                                                         -- note: requires correct delay for FS calc, else generates start_over_1st
  -- MAKE_DATA_i_start <= '0', '1' after 1.5 MS;     -- 02/04/2024 only start, stop constraints by make_data_cnt

  -- -- test: 16/04/2024 power-up -> scan 2 slices (result OK) -> scan 64+FS merge
  -- -- sequence: start - as-is, 1st scan: 0.6 MS (expected end 0.6+0.8=1.4), 2nd scan: 2.2 MS
  -- fq_stream_i <= X"01", X"00" after 0.6 MS, X"01" after 1.8 MS;
  -- ct_type_i <= X"1020", X"1002" after 0.6 MS, X"1040" after 1.8 MS; -- header W#1 (set slices_num), note: here no byte swap
  -- rlt_slice_merge_factor_i <= X"01", X"00" after 0.6 MS, X"02" after 1.8 MS; -- [11..10] - Slice Merging: 0 - No Slice Merging, 1 - Merged 2 Slices, 2 - Merged 4 Slices
  -- fs_merge_factor_i <= X"00", X"00" after 0.6 MS, X"01" after 1.8 MS; -- 0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8
  --                                                                         -- note: requires correct delay for FS calc, else generates start_over_1st
  -- MAKE_DATA_i_start <= '0', '1' after 0.6 MS, '0' after 0.8 MS,
  --                      '1' after 2.2 MS, '0' after 2.4 MS;     -- 02/04/2024 only start, stop constraints by make_data_cnt

  -- test: 16/04/2024 power-up -> scan 64+FS merge (result OK) -> prescan 2 slices
  -- sequence: start - as-is, 1st scan: 0.6 MS (expected end 0.6+1.6=2.4), 2nd scan: 3.0 MS
  fq_stream_i <= X"01", X"01" after 0.6 MS, X"00" after 2.5 MS, X"01" after 3.8 MS;
  ct_type_i <= X"1020", X"1040" after 0.6 MS, X"1002" after 2.5 MS, X"1040" after 3.8 MS; -- header W#1 (set slices_num), note: here no byte swap
  rlt_slice_merge_factor_i <= X"01", X"02" after 0.6 MS, X"00" after 2.5 MS, X"02" after 3.8 MS; -- [11..10] - Slice Merging: 0 - No Slice Merging, 1 - Merged 2 Slices, 2 - Merged 4 Slices
  fs_merge_factor_i <= X"00", X"01" after 0.6 MS, X"00" after 2.5 MS, X"01" after 3.8 MS; -- 0 -> 1, 1 -> 2, 2 -> 4, 3 -> 8
                                                                          -- note: requires correct delay for FS calc, else generates start_over_1st
  -- MAKE_DATA_i_start <= '0', '1' after 0.6 MS, '0' after 0.8 MS,
  --                      '1' after 2.5 MS, '0' after 2.7 MS;     -- 02/04/2024 only start, stop constraints by make_data_cnt
 -- !debug: 01/05/2024 check, when scan start when incomplete FS merging
  MAKE_DATA_i_start <= '0', '1' after 0.9 MS, '0' after 1.3 MS,
                       '1' after 2.5 MS, '0' after 2.7 MS;     -- only start, stop constraints by make_data_cnt



  -- 11/06/2023 synthetic data
  slices_sorter_1 : slices_sorter
    port map (
      clk20_c2            => rx_clk20,            -- RX byte clock
      sys_clk             => CLK_50Mhz,
      rst_n               => reset_sys_clk,
      NRST_20M            => reset_sys_clk,
      IP20                => IP50,
      IP50                => IP50,
      dummy_data_sel      => '1',       -- always synthetic data
      diag_reg            => X"0018",   -- diag_reg(4) - synthetic data in place tiles data, diag_reg(3) - bypass_lut,
      num_of_tiles        => X"F",      -- 4 tiles
      reading_number_freerun_cnt => reading_number_freerun_cnt,
      tile_packet_ok_timeout_reg => (others => '0'), -- !debug: 30/10/2023 assigned in simulation
      -- mu_ctl_reg          => '0',       -- mu_en
      take_rx_det_msb_reg => '0',       -- sel. coarse
      rx_det_shl_reg      => '0',       -- sel. 16bit
      -- pipeline_ctl_reg    => (others => '0'), -- MU params
      -- AMS_Time            => (others => '0'), -- MU params
      -- ibias               => (others => '0'), -- MU params
      -- global_ip_time_reg  => (others => '0'), -- MU params
      -- gain                => (others => '0'), -- MU params
      Num_of_Slices       => temp_Num_of_Slices_synced2header,   -- from scan header
      AMS_CrcError        => (others => '0'), -- from Tiles_managment
      asic_data_good_read => X"F",      -- !debug: 30/10/2023 tile data always ready
      RX_det_m            => (others => '0'),     -- NU when synthetic data
      data_valid_m        => (others => '0'),     -- NU when synthetic data
      RX_det_s            => (others => '0'),     -- NU when synthetic data
      data_valid_s        => (others => '0'),     -- NU when synthetic data
      sorter_data_ready   => sorter_data_ready, -- 26/11/2023
      dpr_header_updated  => dpr_header_updated, -- 26/11/2023
      fq_data_valid       => fq_data_valid,
      fq_data_in          => fq_data_in
      );



  memory_buffer_if_1: memory_buffer_if_tmp
    generic map (
      WORD_WIDTH => 32)
    port map (
      sys_clk               => CLK_50Mhz,
      rst_n                 => reset_sys_clk,
      IP50                  => IP50,    -- 10/11/2022
      num_of_slices         => temp_Num_of_Slices_synced2header,  -- 28/06/2023
      slice_merge           => '1',
      mu_ctl_reg            => '0',
      pipeline_ctl_reg    => (others => '0'), -- MU params
      AMS_Time            => (others => '0'), -- MU params
      ibias               => (others => '0'), -- MU params
      global_ip_time_reg  => (others => '0'), -- MU params
      gain                => (others => '0'), -- MU params
      rx_det_shl_reg        => '0',
      dummy_data_sel        => '0',
      test_ctl              => test_ctl,
      slice_merging_factor  => slice_merging_factor_synced2header,   -- !debug: 17/03/2024 check driver
      fs_merging_factor     => fs_merging_factor_synced2header,      -- !debug: 17/03/2024 check driver
      fs_sequence_counter   => fs_sequence_counter_top_synced2header, -- !debug: 17/03/2024 check driver
      fs_merge_stop         => fs_merge_stop,                 -- 30/03/2024
      sorter_data_ready     => sorter_data_ready, -- 26/11/2023
      rlt_address_from_sync => rlt_address_from_sync,
      make_data_from_sync   => make_data_from_sync,                    -- 15/05/2024
      stream_enable         => (fq_stream_enable_synced2header & '1'), -- FQ & EV
      fq_data_valid         => fq_data_valid, -- from sorter
      fq_data_in            => fq_data_in, -- from sorter
      tmb_header_valid      => dpr_header_valid_r,   -- from scan header
      tmb_header            => HEADER_DATA_OUT,   -- from scan header
      params_ready          => params_ready,
      tmb_header_dout32     => tmb_header_dout32, -- NU, because no data_sort_ddr3_wr
      tmb_header_rd         => tmb_header_rd,     -- simulated data_sort_ddr3_wr
      ev_header_dout32      => ev_header_dout32,  -- NU, because no evolving_ddr3_wr
      ev_header_rd          => ev_header_rd,      -- simulated evolving_ddr3_wr
      num_of_slices_no_merge => open,
      num_of_slices_after_merge => num_of_slices_after_merge,
      DATA_SORTER_DATA_EN   => open,
      DATA_SORT_DOUT        => open,
      EVOLVING_DATA_EN      => open,
      EVOLVING_DOUT         => open
      );


  test_ctl <= test_sel & test_trig;

  ev_new_reading_begin <= (params_ready_r(0) = '0' and params_ready(0) = '1'); --  FQ & EV
  fq_new_reading_begin <= (params_ready_r(1) = '0' and params_ready(1) = '1'); --  FQ & EV

  ip_pr : process is
    variable ignore_at_start_v : boolean := TRUE;
  begin  -- process ip_pr
    wait for 12.8 US; -- !debug: 28/12/2023 added delay before 1st IP
    loop

      wait for ip_period_const;                  -- !TODO: 11/06/2023 change IP period to 95uSec
      -- send IP pulse
      ip_tb <= '1';
      wait for 2 US;
      ip_tb <= '0';

      wait for 2 US;                    -- !debug: 08/02/2024 add this and READING_NUMBER_REG, HD_PTR_ADDRESS_REG, RLT_PTR_ADDRESS_REG moved for update after IP_LONG

      -- prepare next IP scan header (for write to DDR3)
      -- !debug: 03/10/2023 because 1st IP without data, need to ignore
      if (not ignore_at_start_v) then
        if (MAKE_DATA_r = '0' and MAKE_DATA = '1') then -- 24/03/2024
          READING_NUMBER_REG <= (others => '0');
        else
          READING_NUMBER_REG <= std_logic_vector(unsigned(READING_NUMBER_REG) + 1); -- 14/06/2023
        end if;
        if (fq_stream(0) = '1') then                                              -- 18/02/2024
          HD_PTR_ADDRESS_REG <= std_logic_vector(unsigned(HD_PTR_ADDRESS_REG) + 4); -- 02/10/2023
        end if;
        if (unsigned(FS_MERGE_FACTOR) = 0 or to_integer(unsigned(fs_sequence_counter)) = (2**to_integer(unsigned(FS_MERGE_FACTOR)) - 2)) then  -- 11/02/2024 no FS merge or FS merge completed
          -- if (data_valid_r = '0' and data_valid_i = '1') then -- 03/03/2024
          if (unsigned(fs_merge_factor_i) /= 0 and unsigned(FS_MERGE_FACTOR) = 0) then -- 08/03/2024
            null;
          else
            RLT_PTR_ADDRESS_REG <= std_logic_vector(unsigned(RLT_PTR_ADDRESS_REG) + 16#1080#); -- !debug: 10/11/2023 was    16#0420#
          end if;
        end if;
        if (MAKE_DATA = '0') then  -- 24/03/2024
          REFERENCE_DETECTOR <= X"FBAD";
        elsif (MAKE_DATA_r = '0') then
          REFERENCE_DETECTOR <= X"5555";
        else
          REFERENCE_DETECTOR <= std_logic_vector(unsigned(REFERENCE_DETECTOR) + 200);
        end if;
      end if;

      ignore_at_start_v := FALSE;

    end loop;

  end process ip_pr;


  misc_tb_pr: process (CLK_50Mhz) is
    variable ddr3_rq_word_v : std_logic_vector(31 downto 0) := (others => '0');
  begin  -- process misc_tb_pr
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
        synth_ip <= ip_tb;
      end if;

      if (now < 20 US) then
        ACLK_Master <= '0';
      else
        ACLK_Master <= ACLK_Master_i;
      end if;

      TIME_STAMP_LOW <= std_logic_vector(to_unsigned(now/stamp_time_const,16));
      INTEGRATION_TIME_IN_REG <= std_logic_vector(to_unsigned(ip_period_const/ip_time_const,16));

      ip_tb_r <= ip_tb;
      if (ip_tb = '1' and ip_tb_r = '0') then
        -- ip_cnt <= ip_cnt + 1; -- data start on n IP
        DFS <= DFS_i;
        DFS_i <= not DFS_i;           -- 07/02/2024 do fix, DFS always module 2 counter
        FS_MERGE_FACTOR <= fs_merge_factor_i;
        RLT_SLICE_MERGE_FACTOR <= rlt_slice_merge_factor_i;
        FQ_STREAM <= fq_stream_i;
        MAKE_DATA_r <= MAKE_DATA;
        if (unsigned(FS_MERGE_FACTOR) = 0 or
            to_integer(unsigned(fs_sequence_counter)) = (2**to_integer(unsigned(FS_MERGE_FACTOR)) - 1)) then
          fs_sequence_counter <= X"00";
          CT_TYPE <= ct_type_i;         -- 12/04/2024
        elsif (unsigned(fs_merge_factor_i) /= unsigned(FS_MERGE_FACTOR)) then -- 04/04/2024
          fs_sequence_counter <= X"00";
          CT_TYPE <= ct_type_i;         -- 12/04/2024
        elsif (MAKE_DATA_i_start_r = '0' and MAKE_DATA_i_start = '1') then -- 01/05/2024 start_over_1st
          fs_sequence_counter <= X"00";
        else
          fs_sequence_counter <= std_logic_vector(unsigned(fs_sequence_counter) + 1);
          -- note: CT_TYPE not changes here
        end if;

      end if;

      -- Miki: For correct merging, At DFS = 0:
      --       i)	The merging sequence counter will be even.
      --       ii)	Number of slices can be updated.
      -- if (DFS_i = '0' and fs_sequence_counter(0) = '0') then
      --   CT_TYPE <= ct_type_i;           -- 29/03/2024
      -- end if;

      -- if (ip_tb = '1' and ip_tb_r = '0') then -- 01/04/2024
      --   if (to_integer(unsigned(fs_sequence_counter)) = (2**to_integer(unsigned(FS_MERGE_FACTOR)) - 1)) then -- 29/03/2024
      --     MAKE_DATA <= MAKE_DATA_i;     -- MAKE_DATA change synced with fs_sequence_counter = 0
      --   end if;
      -- end if;

      -- if ((clk_cnt = 35 and ip_tb = '1' and MAKE_DATA_i = '1') and DFS_i = '0') then -- 05/03/2024
      --   data_valid_i <= '1';
      -- elsif (MAKE_DATA_i = '0' and MAKE_DATA = '0') then
      --   data_valid_i <= '0';
      -- end if;

      if (ip_tb = '1' and ip_tb_r = '0') then -- 01/04/2024
        -- if (MAKE_DATA_i_start_r = '0' and to_integer(unsigned(fs_sequence_counter)) = (2**to_integer(unsigned(FS_MERGE_FACTOR)) - 1)) then -- 29/03/2024
        if (MAKE_DATA_i_start_r = '0' and to_integer(unsigned(fs_sequence_counter)) = 0) then -- !debug: 01/05/2024 check, when scan start when incomplete FS merging
          MAKE_DATA_i_start_r <= MAKE_DATA_i_start;
          if (MAKE_DATA_i_start = '1') then -- !debug: 16/04/2024 was   MAKE_DATA_i_start_r = '0' and
            -- if (now > 2 MS) then -- 16/04/2024 when 1st scan short with 2 slices
            if (now < 2.4 MS) then -- 16/04/2024 when 1st scan long with 64 slices
              make_data_cnt <= 15;        -- 7, 15
            else
              make_data_cnt <= 7;        -- 7, 15
            end if;
            MAKE_DATA <= '1';
          end if;
        elsif (make_data_cnt /= 0) then
          make_data_cnt <= make_data_cnt - 1;
        else
          MAKE_DATA <= '0';
          MAKE_DATA_i_start_r <= '0';
        end if;
      end if;

    end if;
  end process misc_tb_pr;



  data_valid_i <= MAKE_DATA;            -- 02/04/2024

  dms_status_i(3 downto 0) <= X"2" when (data_valid_i = '1') else X"0";
  dms_status_i(4) <= '1' when (data_valid_r = '0' and data_valid_i = '1') else '0';
  dms_status_i(5) <= '1' when (data_valid_i = '1' and make_data_cnt = 0) else '0';
  dms_status_i(15 downto 6) <= X"42" & "00";

  -- from Taichi_TMB_top
  misc_pr: process (CLK_50Mhz) is
    variable ddr3_rq_word_v : std_logic_vector(31 downto 0) := (others => '0');
    variable aclk_sample_v : boolean := FALSE;
  begin  -- process misc_pr
    if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge

      aclk_shr_50m <= aclk_shr_50m(1 downto 0) & ACLK_Master;
      aclk_sample_v := aclk_shr_50m(2) = '0' and aclk_shr_50m(1) = '1'; -- !debug: 26/03/2023 aclk rising

      -- header processing
      if (IP_READY = '1') then
        header_dpr_addr <= (others => '0');
        dpr_header_valid <= '0';
      elsif (sorter_data_ready = '1') then -- !debug: 26/11/2023 read header only when data received
        header_dpr_addr <= (0 => '1', others => '0');
        dpr_header_valid <= '1';
      elsif (unsigned(header_dpr_addr) /= 0 and unsigned(header_dpr_addr) < 63) then
        header_dpr_addr <= std_logic_vector(unsigned(header_dpr_addr) + 1);
        dpr_header_valid <= '1';
      else
        dpr_header_valid <= '0';
      end if;
      dpr_header_valid_shr <= dpr_header_valid_shr(1 downto 0) & dpr_header_valid;
      if (dpr_header_valid_shr(1) = '0' and dpr_header_valid_shr(2) = '1') then -- header updated
        dpr_header_updated <= '1';     -- constant after 1st valid header
      end if;

      -- IP sampling ;O
      if (IP_READY = '1') then
        ip_valid_sampled <= '1';
        ip_i <= '0';
      elsif (aclk_sample_v and ip_valid_sampled = '1') then -- !debug: 26/03/2023
        ip_i <= ip_valid_sampled;
        ip_valid_sampled <= '0';
      elsif (aclk_sample_v and ip_valid_sampled = '0') then -- !debug: 26/03/2023
        ip_i <= '0';
      end if;

      if (aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0') then -- ACLK falling
        ip <= ip_i;
      end if;

      -- in Tiles_managment
      if IP='1' then
        IP64_vec<=(others=>'1');
      else
        IP64_vec<=IP64_vec(4 downto 0) & '0';
      end if;
      IP50 <= IP64_vec(4);


      params_ready_r <= params_ready;
      if (fq_new_reading_begin) then
        fq_header_dw_cnt <= 31;
        tmb_header_rd <= '1';
      elsif (fq_header_dw_cnt /= 0) then
        fq_header_dw_cnt <= fq_header_dw_cnt - 1;
        tmb_header_rd <= '1';
      else
        tmb_header_rd <= '0';
      end if;
      if (ev_new_reading_begin) then
        ev_header_dw_cnt <= 31;
        ev_header_rd <= '1';
      elsif (ev_header_dw_cnt /= 0) then
        ev_header_dw_cnt <= ev_header_dw_cnt - 1;
        ev_header_rd <= '1';
      else
        ev_header_rd <= '0';
      end if;

      -- if (sorter_data_ready = '1') then -- !debug: 17/03/2024 update footer params only when new header reads from memory
      if (TRUE) then -- !debug: 04/04/2024 parameters must be updated before data and header processing
        fs_merging_factor_synced2header <= fs_merging_factor;
        fs_sequence_counter_top_synced2header <= fs_sequence_counter_top;
        slice_merging_factor_synced2header <= slice_merging_factor;
        fq_stream_enable_synced2header <= fq_stream_enable;
        temp_Num_of_Slices_synced2header <= temp_Num_of_Slices;
      end if;

      if (fs_merging_factor = "00" and fs_merging_factor_synced2header /= "00" and sorter_data_ready = '0') then -- 30/03/2024 switch from FS merge to no FS merge
        -- !debug: 04/04/2024 disabled   fs_merge_stop <= '1';           -- stop
      elsif (fs_merging_factor /= fs_merging_factor_synced2header and sorter_data_ready = '0') then -- 03/04/2024 FS merge factor changed
        fs_merge_stop <= '0';
        fs_merge_stop_pre <= '1';
      elsif (fs_merge_stop_pre = '1' and sorter_data_ready = '0') then
        -- !debug: 04/04/2024 disabled   fs_merge_stop <= '1';           -- changes
        fs_merge_stop_pre <= '0';
      elsif (dpr_header_valid_r = '0') then -- not scan header write
                                            -- note: same as tmb_header_valid
        fs_merge_stop <= '0';
      end if;

    end if;
  end process misc_pr;

  data_valid_r <= transport data_valid_i after 60 US;   -- !debug: 05/03/2024 scan header send 50uS after IP, then for data_valid riseing detect requires this delay

  dpr_header_valid_r <= '1' when (dpr_header_valid_shr(1 downto 0) /= "00") else '0';


  -- Tzvika: SYNC CDM TX -> TMB SYNC RX
  tx_ctrl_serdes_wrap_2024_1: tx_ctrl_serdes_wrap_2024
    generic map (
      G_PARAMS_LEN            => 16,
      G_TX_DATA_PACKET_SIZE   => x"00000080",         -- 128B
      G_TX_HEADER_PACKET_SIZE => x"02",
      G_TX_FOOTER_PACKET_SIZE => x"0C", -- 12/10/2023 !debug: 13/10/2023 try x"0b" -> x"0C"
      G_HEADERS               => '1',
      G_RESET_POLARITY        => '1')
    port map (
      CLK_50M                => CLK_50Mhz,
      USER_CLK               => CLK_50Mhz,
      CLK_200M               => CLK_200,
      ACLK                   => ACLK_Master,
      INIT_DONE              => '1',
      RESET                  => "not"(reset_sys_clk),
      RESET_ERRORS           => "00",
      TX_ERRORS              => open,
      ERR1_CNT               => open,
      ERR2_CNT               => open,
      SYNC_DEBUG_REG         => x"DEADBEEF",
      NUMBER_OF_SLICES       => X"0000",        -- NU, see CT_TYPE
      MAKE_DATA              => '0',            -- make_data_sig,
      IP_LONG                => synth_ip,
      DFS                    => '0',    -- NU, see HW_LINES_1
      EN_SWAP                => '1',    -- !debug: 04/01/2024 this is byte swap !TODO: check, if requires
      TX_TRI_IN              => '1',
      TX_TRI_O               => open,
      TX_DATA_O              => SYNC_DATA_out,  -- from TX_Zynq
      RLT_PTR_ADDRESS_REG    => RLT_PTR_ADDRESS_REG,  -- valid for SYNC communication
      HD_PTR_ADDRESS_REG     => HD_PTR_ADDRESS_REG,  -- valid for SYNC communication
      BUF_PTR_ADDRESS        => x"000000d9", -- valid for BUFFER communication
      STREAM_CTRL            => x"dd", -- valid for BUFFER communication
      RLT_SLICE_MERGE_FACTOR => RLT_SLICE_MERGE_FACTOR,
      FS_MERGE_FACTOR        => FS_MERGE_FACTOR,
      fs_sequence_counter    => fs_sequence_counter, -- 07/02/2024
      FQ_STREAM              => fq_stream, -- [0] '1' - enable
      HEADERS                => ff_headers_sig, -- !TODO: 04/01/2024 create driver
      HEADERS_CTRL_REG       => (others => '0'), -- NU
      HEADERS_SAMP_TIME_REG  => X"000009C4",     -- !debug: 04/01/2024 50uS when clk 50MHz, 50e-6/20e-9=2500=0x9c4
      DBG_READING_CNT        => "000"&x"0e9",
      MASTERn_SLAVE          => '0'
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
      slice_merging_factor => slice_merging_factor,          -- W #22
      fs_merging_factor => fs_merging_factor,
      fs_sequence_counter => fs_sequence_counter_top,
      fq_stream_enable => fq_stream_enable,
      temp_Num_of_Slices => temp_Num_of_Slices,
      reading_number_freerun_cnt_o => reading_number_freerun_cnt,
      make_data_from_sync   => make_data_from_sync,                    -- 15/05/2024
      bad_packet_received => open,
      SYNC_EN_SWAP => '0', -- 03/03/2026
      RLT_PTR_ERR_INJECT => RX_ERR_INJECT_CTL_REG(3 downto 2), -- 03/03/2026
      HD_PTR_ERR_INJECT => RX_ERR_INJECT_CTL_REG(5 downto 4), -- 03/03/2026
      SYNTH_RLT_PTR_ADDRESS_REG => SYNTH_RLT_PTR_ADDRESS_REG, -- 03/03/2026
      SYNTH_HD_PTR_ADDRESS_REG => SYNTH_HD_PTR_ADDRESS_REG, -- 03/03/2026
      skip_IP_packet => RX_ERR_INJECT_CTL_REG(8),                   -- 09/03/2026
      skip_scan_header_packet => RX_ERR_INJECT_CTL_REG(9), -- 09/03/2026
      ERR_INJ => RX_ERR_INJECT_CTL_REG(0), -- 03/03/2026
      SYNC_CRC_INJ_CNT => SYNC_CRC_INJ_CNT, -- 03/03/2026
      ip_pkt_cnt => ip_pkt_cnt,   -- !debug: 09/03/2026
      headers_pkt_cnt => headers_pkt_cnt,   -- !debug: 09/03/2026
      RX_ERRs             => open
    );


  -- headers from CDM
  synthetic_header_pr: process (CLK_50Mhz) is
  begin  -- process synthetic_header_pr
    if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge
       ff_headers_sig(0) <= CT_TYPE;	-- CT Type
       ff_headers_sig(1) <= dms_status_i;	-- DMS Status
       -- W3: NU,  ff_headers_sig(2);	-- DMS Error
       ff_headers_sig(3) <= INTEGRATION_TIME_IN_REG;	-- Integration time
       ff_headers_sig(4) <= REFERENCE_DETECTOR;	-- Reference Detector
       -- W6: NU,  ff_headers_sig(5);	-- DMS Temperature
       -- W7: NU,  ff_headers_sig(6);	-- Reserved for DMS
       -- W8: NU,  ff_headers_sig(7);	-- DMS Temperature Control Status
       ff_headers_sig(8) <= READING_NUMBER_REG;	-- Reading No. Low
       -- W10: NU,  ff_headers_sig(9);	-- Reading No. High
       if (READING_NUMBER_REG > X"000A") then -- !debug: 15/05/2024 temporary test reading number > 2^16
         ff_headers_sig(9) <= X"0001";	-- Reading No. High
       else
         ff_headers_sig(9) <= X"0000";	-- Reading No. High
       end if;
       -- W11: NU,  ff_headers_sig(10); -- Detection Setting 1
       -- W12: NU,  ff_headers_sig(11); -- Detection Setting 2
       -- W13: NU,  ff_headers_sig(12); -- Detection Setting 3
       -- W14: NU,  ff_headers_sig(13); -- Detection Setting 4 and Temperature Reading Format version
       -- W15: NU,  ff_headers_sig(14); -- Resend Counter
       -- W16: NU,  ff_headers_sig(15); -- Vertical Couch Position
       -- W17: NU,  ff_headers_sig(16); -- Horizontal Couch Position
       -- W18: NU,  ff_headers_sig(17); -- Gantry Tilt
       -- W19: NU,  ff_headers_sig(18); -- Rotation Angle
       -- W20: NU,  ff_headers_sig(19); -- Rotor Angle during Data Sending
       ff_headers_sig(20) <= (3 => DFS, others => '0'); -- HW lines: [3] '0' - start FS merging
       -- W22: NU,  ff_headers_sig(21);	-- HW lines 2
       -- W23: NU,  x"0000"; --#22		 -- Potential for FREE USE
       -- W24: NU,  ff_headers_sig(23); -- "Bad Reading" details
       ff_headers_sig(24) <= x"BEEF"; -- UID
       -- W26: NU,  ff_headers_sig(25); -- Shot Counter
       -- W27: NU,  x"0000"; --#26		 -- Potential for FREE USE
       -- W28: NU,  ff_headers_sig(27); -- Angular Denominator
       ff_headers_sig(28) <= TIME_STAMP_LOW; -- Time Stamp Low
       ff_headers_sig(29) <= (others => '0'); -- Time Stamp High
       ff_headers_sig(30) <= x"04A0"; -- Number of Detectors
       -- W32: NU,  ff_headers_sig(31); -- UTC Time [15..00]
       -- W33: NU,  ff_headers_sig(32); -- UTC Time [31..16]
       -- W34: NU,  ff_headers_sig(33); -- UTC Time [47..32]
       -- W35: NU,  ff_headers_sig(34); -- UTC Time [63..48]
       -- W36: NU,  x"0000"; --35		 -- Potential for Ref Det1
       -- W37: NU,  x"0000"; --36		 -- Potential for Ref Det2
       ff_headers_sig(37) <= X"0302"; -- DMS Type: 4cm DMS, Test Pattern
       -- W39: NU,  ff_headers_sig(38); -- Capability bits H
       -- W40: NU,  ff_headers_sig(39); -- Tube mA - Command
       -- W41: NU,  ff_headers_sig(40); -- Actual Tube mA
       -- W42: NU,  ff_headers_sig(41); -- Collimator 1 - Rear Blade
       -- W43: NU,  ff_headers_sig(42); -- Grid Voltage 1
       -- W44: NU,  ff_headers_sig(43); -- Grid Voltage 1
       -- W45: NU,  ff_headers_sig(44); -- Collimator 2 - Front Blade
       -- W46: NU,  ff_headers_sig(45); -- Capability bits M
       -- W47: NU,  ff_headers_sig(46); -- DMS Troubleshooting
       -- W48: NU,  ff_headers_sig(47); -- DMS Troubleshooting
       -- W49: NU,  ff_headers_sig(48); -- Filament Current
       -- W50: NU,  ff_headers_sig(49); -- mA (Actual Tube mA)
       -- W51: NU,  ff_headers_sig(50); -- kV (Actual Measured)
       -- W52: NU,  ff_headers_sig(51); -- Potential for FREE USE
       -- W53: NU,  ff_headers_sig(52); -- Capability bits L
       -- W54: NU,  ff_headers_sig(53); -- Potential for FREE USE
       -- W55: NU,  ff_headers_sig(54); -- ECG
       -- W56: NU,  ff_headers_sig(55); -- DOM mA
       ff_headers_sig(56) <= READING_NUMBER_REG;	-- Reading No. Low
       -- W58: NU,  ff_headers_sig(57); -- Reading	No.	 High
       -- W59: NU,  ff_headers_sig(58);
       -- W60: NU,  ff_headers_sig(59);
       -- W61: NU,  ff_headers_sig(60);
       -- W62: NU,  ff_headers_sig(61);
       -- W63: NU,  ff_headers_sig(62);
       ff_headers_sig(63) <= x"FACE"; -- W# 64 -- Stamp
    end if;
  end process synthetic_header_pr;

  mu_params_force_pr: process is
  begin  -- process mu_params_force_pr

    wait for 635470 NS;

    -- !debug: 19/03/2026
    -- Inject constants for MU calc check. Result sim:/tmb_ev_calc_tb/memory_buffer_if_1/PIPELINE2_IF_HD_MSB/MU_OUT = 0x7B6C  - OK
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.OSUB_EN : std_logic >> <= force '1';
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.LOG_EN : std_logic >> <= force '1';
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.TCSUB_EN : std_logic >> <= force '1';
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.PASST : std_logic >> <= force '0';
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.ZERO_BAD_POINT : std_logic >> <= force '1';
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.DELTA_EN : std_logic >> <= force '1';
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.AMS_Offset : std_logic_vector(15 downto 0) >> <= force X"1400";
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.AMS_Time : std_logic_vector(15 downto 0) >> <= force X"011F";
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.AMS_Charge : std_logic_vector(25 downto 0) >> <= force 26UX"A00";

    wait for 5 US;
    -- << tb.uut.s >> <= release;    -- stop overriding
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.OSUB_EN : std_logic >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.LOG_EN : std_logic >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.TCSUB_EN : std_logic >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.PASST : std_logic >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.ZERO_BAD_POINT : std_logic >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.DELTA_EN : std_logic >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.AMS_Offset : std_logic_vector(15 downto 0) >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.AMS_Time : std_logic_vector(15 downto 0) >> <= release;
    << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.AMS_Charge : std_logic_vector(25 downto 0) >> <= release;

    wait;

  end process mu_params_force_pr;


  log2_in <= << signal .tmb_ev_calc_tb.memory_buffer_if_1.PIPELINE2_IF_HD_MSB.STD_Charge_Added_Offset : std_logic_vector(22+15 downto 0)  >>(37 downto 22); -- X"1000";

  log2_taylor_1: entity work.log2_taylor
    port map (clk   => CLK_50Mhz,
              reset => "not"(reset_sys_clk),
              din   => log2_in,
              dout  => log2_out);

end architecture tmb_ev_calc_tb_ar;
