-------------------------------------------------------------------------------
-- Title      : Read block, part of DDR3 driver
-- Project    : DDR3 control (Trident project)
-------------------------------------------------------------------------------
-- File       : read_ddr3_rd.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    :
-- Created    : 25/09/2005
-- Last update: 31/07/2024
-- Platform   :
-- Standard   : VHDL'93, Math Packages
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 25/09/2005  1.0      ilq00431  Created
-- 01/12/2016  2.0      310268386 Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- library altera_mf;
-- use altera_mf.altera_mf_components.all;

Library xpm;
use xpm.vcomponents.all;

use work.tbuf_pack.all;


entity read_ddr3_rd is
  port(
    RESET_I             : in std_logic;
    ddr3_if_rst_n          : in  std_logic;
    RESET_40           : in  std_logic;
    CLK_50Mhz      : in std_logic;
    ui_clk    : in std_logic;
    RAW_DATA_END_ADDR   : in  DDR3_ADDR_BUS_TYP;

    READ_DATA_FSM_IDLE : out std_logic;  -- read FSM in idle state
    NO_ECC_CHK         : in  std_logic;

    -- AXI4 master interface:
    axi_start_read     : out std_logic;
    axi_burst_len      : out std_logic_vector(7 downto 0);
    axi_raddr_offset  : out std_logic_vector(29 downto 0);
    axi_rdata	      : in  std_logic_vector(31 downto 0);
    axi_rdata_valid   : in  std_logic;
    axi_master_state  : in  std_logic_vector(7 downto 0); -- axi_master_state(1) - write in process (busy)
    axi_if_req        : out std_logic;
    gnt_catch         : out std_logic;   -- 01/11/2023

    -- Buffer control and errors registers interface
    READ_READING_ADDR_FIFO_ADDR : out DDR3_ADDR_BUS_TYP; -- RAW RD PTR
    READ_READING_RAW_DATA_ADDR  : out DDR3_ADDR_BUS_TYP; -- RAW RD read_addr
    READ_READING_EV_DATA_ADDR   : out DDR3_ADDR_BUS_TYP; -- EV RD read_addr
    READ_FSM_ERROR              : out std_logic;  -- FSM timeout
    -- READ_READING_EV_SLOTNUM     : out EV_BUFFER_SLOTS_TYP;
    READ_FIFO_NOTEMPTY          : out std_logic;  -- error, if FIFO not empty and NEXT_REQ
    READ_FIFO_OVERFLOW          : out std_logic;  -- FIFO full
    READ_ECC_ERROR              : out std_logic;  -- unrecoverable ECC error in slice
    ECC_ERROR_INTERNAL          : out boolean; -- output from ECC check
    ECC_DOUBLE_ERROR_INTERNAL   : out boolean; -- output from ECC check
    READ_ECC_ERROR_CHIPNUM      : out std_logic_vector(3 downto 0); -- Chip number of ECC Corrected Error
    READ_ECC_ERROR_ADDR         : out DDR3_ADDR_BUS_TYP;            -- Address of last ECC detected Error
    ECC_ERROR_INJECTION_CMD     : in  std_logic_vector(1 downto 0); -- 0,1,2 errors
    ECC_ERROR_MASK              : out std_logic_vector(6 downto 0); -- single bit error position
    READ_FIFO_SPACE             : out std_logic_vector(10 downto 0); -- available words in FIFO
    RAW_RD_COUNTER              : out std_logic_vector(31 downto 0);
    EV_RD_COUNTER               : out std_logic_vector(31 downto 0);
    READ_POINTER_ERROR          : out std_logic;
    READ_BUFFER_ADDR_ERROR      : out std_logic;
    
    -- Reading Read Logic interface - reading requests
    INIT_DONE_ALL_O    : in std_logic;
    EVOLVING_REQ_PULSE : in std_logic; -- EV data reading
    REGULAR_REQ_PULSE  : in std_logic; -- RAW data reading
    raw_rd_ptr_addr    : in DDR3_ADDR_BUS_TYP; -- absolute RD pointer
    ev_rd_slot_addr    : in DDR3_ADDR_BUS_TYP; -- absolute RD pointer

    -- Master/SlaveSelector interface
    DDR_DRIVER_RD              : in  std_logic;  -- request next 64bit word from FIFO
    DDR_DRIVER_DOUT            : out std_logic_vector (31 downto 0);
    DDR_DRIVER_FIFO_EMPTY      : out std_logic;
    DDR_DRIVER_RD_READY        : out std_logic; -- indicate DDR3 packet ready
    DDR_DRIVER_RD_VALID        : out std_logic; -- indicate DDR3 data valid
    DDR_DRIVER_HEADER_BUS      : out std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
    DDR_DRIVER_HEADER_READY    : out std_logic; -- 19/03/2017
    MEM_BUF_NUM_OF_SLICES      : out std_logic_vector(6 downto 0); -- 21/04/2024
    NEW_PACKET2TX              : out std_logic; -- 28/05/2024
    next_req_ready_M           : out std_logic; -- 16/07/2018
    DDR_READ_TP                : out std_logic_vector(15 downto 0)
  );

-- Declarations

end read_ddr3_rd;


architecture read_ddr3_rd_a of read_ddr3_rd is

  -- Architecture declarations

  signal read_addr              : DDR3_ADDR_BUS_TYP; -- current read address in DDR memory
  signal reading_start_addr         : DDR3_ADDR_BUS_TYP; -- start addr for current reading (sampled
                                                         -- start_addr_reg_128m)
  signal reading_addr_fifo_addr     : DDR3_ADDR_BUS_TYP; -- memory address in PTR buffer

  signal num_words, words_in_bundle : natural range 0 to 2047; -- packet size (64bit words)  !debug: 03/04/2017 was 511
                                                               -- now bundle = slice
  signal requested_words_cnt : natural range 0 to 255;  -- now same as burst ?
  signal requested_packetwords_cnt, requested_packetwords_cnt_40m : natural range 0 to 2047; -- <packet size> + <ECC size>
  signal requested_packetwords_cnt_dest : std_logic_vector (12 downto 0);

  -- Non hierarchical state machine declarations
  type read_data_fsm_state_type is (
    IDLE,
    READ_IDLE,
    SLICES_WAIT4GRANT,
    ADDR_WAIT4GRANT,
    ADDR_READ_RD,
    ADDR_LOAD,
    ADDR_CALC,
    SLICES_READ_RD,
    SLICES_READ_WAIT,
    ADDR_READ_WAIT,
    SLICES_HEADER_RD,
    SLICES_HEADER_WAIT,
    WAIT4DONE
    );

  -- Declare current and next state signals
  signal READ_DATA_FSM_PS          : read_data_fsm_state_type; -- read reading FSM
  -- State vector declaration
  attribute state_vector           : string;
  attribute state_vector of read_ddr3_rd_a : architecture is "READ_DATA_FSM_PS";


  -- Internal signal declarations
  signal ecc_fifo_wrreq                   : std_logic;  -- strobe from DDR2 core
  signal wait_data_done_cnt        : natural range 255 downto 0; -- FSM timeout
                                                                   -- (controller not ready or
                                                                   -- transfer not complete)
  signal rd_data_ready             : std_logic;  -- requested data from FIFO ready strobe
  signal ecc_fifo_rdempty          : std_logic;  -- FIFO empty
  signal ecc_fifo_wrfull           : std_logic;  -- FIFO full
  signal fifo_almost_full          : boolean;    -- read will blocked, if FIFO full
  signal ecc_fifo_wrusedw          : std_logic_vector(11 downto 0);   -- words in FIFO
  signal ecc_fifo_rdusedw          : std_logic_vector(13 downto 0);
  signal ecc_fifo_q                : std_logic_vector(7 downto 0);  -- data from FIFO

  signal tx_completed                             : boolean;     -- transfer done event
  signal new_reading_begin, new_reading_begin_40m, new_reading_begin_40m_r : boolean;  -- place for start address and header change
  signal new_reading_begin_vec : unsigned(2 downto 0);

  signal timeout_cnt                    : natural range 1023 downto 0; -- can be delay in case DDR3 self-refresh
                                                                      -- !debug: 05/09/2018 255 -> 1023

  -- Component Declarations
  --component dcfifo
  --  generic (
  --    lpm_width               : natural;
  --    lpm_widthu              : natural;
  --    lpm_numwords            : natural;
  --    delay_rdusedw           : natural;
  --    delay_wrusedw           : natural;
  --    rdsync_delaypipe        : natural;
  --    wrsync_delaypipe        : natural;
  --    intended_device_family  : string;
  --    lpm_showahead           : string;
  --    underflow_checking      : string;
  --    overflow_checking       : string;
  --    clocks_are_synchronized : string;
  --    use_eab                 : string;
  --    add_ram_output_register : string;
  --    add_width               : natural;
  --    lpm_hint                : string;
  --    lpm_type                : string
  --    );
  --  port (
  --    aclr    : in  std_logic := '0';
  --    data    : in  std_logic_vector (lpm_width-1 downto 0);
  --    rdclk   : in  std_logic;
  --    rdreq   : in  std_logic;
  --    wrclk   : in  std_logic;
  --    wrreq   : in  std_logic;
  --    q       : out std_logic_vector (lpm_width-1 downto 0);
  --    rdempty : out std_logic;
  --    rdfull  : out std_logic;
  --    rdusedw : out std_logic_vector (lpm_widthu-1 downto 0);
  --    wrempty : out std_logic;
  --    wrfull  : out std_logic;
  --    wrusedw : out std_logic_vector (lpm_widthu-1 downto 0)
  --    );
  --end component;
  -- FIFO !debug: 31/12/2019 was Altera FIFO with lpm_showahead          => "OFF"
  component dcfifo_512x32 is
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector (31 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector (31 downto 0);
      full          : out std_logic;
      overflow      : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;
      underflow     : out std_logic;
      rd_data_count : out std_logic_vector (8 downto 0);
      wr_data_count : out std_logic_vector (8 downto 0));
  end component dcfifo_512x32;

  component fifo_dc_2k_32 is
    port (
      wr_clk        : in  std_logic;
      wr_rst        : in  std_logic;
      rd_clk        : in  std_logic;
      rd_rst        : in  std_logic;
      din           : in  std_logic_vector (31 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector (31 downto 0);
      full          : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;    -- 29/05/2024
      rd_data_count : out std_logic_vector (10 downto 0);
      wr_data_count : out std_logic_vector (10 downto 0));
  end component fifo_dc_2k_32;

  signal fifo4k_wr_en, fifo4k_rd_en : std_logic;
  signal fifo4k_wr_data_count : std_logic_vector(10 downto 0);
  signal fifo4k_rd_data_count :  std_logic_vector(10 downto 0);
  signal fifo4k_dout : std_logic_vector(31 downto 0);
  signal fifo4k_full, fifo4k_full_128m, fifo4k_full_50m, fifo4k_empty, fifo4k_valid : std_logic;
  signal fifo4k_full_128m_shr : std_logic_vector(3 downto 0);

  -- component ecc_fifo_2k_mixed is
  -- Port (
  --   wr_clk : in STD_LOGIC;
  --   wr_rst : in STD_LOGIC;
  --   rd_clk : in STD_LOGIC;
  --   rd_rst : in STD_LOGIC;
  --   din : in STD_LOGIC_VECTOR ( 31 downto 0 );
  --   wr_en : in STD_LOGIC;
  --   rd_en : in STD_LOGIC;
  --   dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
  --   full : out STD_LOGIC;
  --   overflow : out STD_LOGIC;
  --   empty : out STD_LOGIC;
  --   underflow : out STD_LOGIC;
  --   rd_data_count : out STD_LOGIC_VECTOR ( 13 downto 0 );
  --   wr_data_count : out STD_LOGIC_VECTOR ( 11 downto 0 )
  -- );
  -- end component;

  -- component dec_fifo_2k_mixed is
  -- Port (
  --   wr_clk : in STD_LOGIC;
  --   wr_rst : in STD_LOGIC;
  --   rd_clk : in STD_LOGIC;
  --   rd_rst : in STD_LOGIC;
  --   din : in STD_LOGIC_VECTOR ( 31 downto 0 );
  --   wr_en : in STD_LOGIC;
  --   rd_en : in STD_LOGIC;
  --   dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
  --   full : out STD_LOGIC;
  --   empty : out STD_LOGIC;
  --   rd_data_count : out STD_LOGIC_VECTOR ( 10 downto 0 );
  --   wr_data_count : out STD_LOGIC_VECTOR ( 11 downto 0 )
  -- );
  -- end component;

  -- -- ECC
  -- component ddr_hamming is
  --   generic (
  --     ENCODER : boolean);
  --   port (
  --     CLK                : in  std_logic;
  --     RESET_I            : in  std_logic;
  --     DATA_IN            : in  std_logic_vector(63 downto 0);
  --     CHECK_BITS_IN      : in  std_logic_vector(7 downto 0);
  --     RD_DATA_READY      : in  std_logic;
  --     DATA_OUT           : out std_logic_vector(63 downto 0);
  --     CHECK_BITS_OUT     : out std_logic_vector(7 downto 0);
  --     ECC_ERROR          : out boolean;
  --     ECC_DOUBLE_ERROR   : out boolean;
  --     ECC_ERROR_LOCATION : out natural range 0 to 127;
  --     DDR_HAMMING_TP     : out std_logic_vector(7 downto 0));
  -- end component ddr_hamming;


  signal read_fifo_overflow_r  : std_logic;
  signal read_fsm_error_128m,read_fsm_error_128m_dst, read_fsm_error_40m_0, read_fsm_error_40m : std_logic; -- change by Dalit 19/3/2024 timing issue solving
  signal error_read_addr 					: boolean;
  signal read_fifo_space_128m, read_fifo_space_64m : std_logic_vector(10 downto 0);

  signal pointer_error, pointer_error_dst		: std_logic; -- ptr memory ---- change by Dalit 19/3/2024 timing issue solving
  signal buffer_rd_addr_error, buffer_rd_addr_error_dst	: std_logic; -- EV or RAW memory ---- change by Dalit 19/3/2024 timing issue solving

  signal ev_data_addr_offset, ev_data_addr_offset_40m : DDR3_ADDR_BUS_TYP;  -- EV_DATA memory address
  -- signal prev_ev_addr_offset : DDR3_ADDR_BUS_TYP;
  -- signal ev_slotnum_ptr      : EV_BUFFER_SLOTS_TYP := (others => '0');
  signal evolving_reading, evolving_reading_40m : boolean;
  signal evolving_reading_src, evolving_reading_dst : std_logic;

  signal check_bits_in, check_bits_in_masked : std_logic_vector(7 downto 0);
  signal ecc_error, ecc_error_t, ecc_error_64m : boolean;
  signal ecc_double_error, ecc_double_error_t, ecc_double_error_64m      : boolean;
  signal ecc_error_location                          : natural range 0 to 127;
  signal read_ecc_error_chipnum_i                    : std_logic_vector(3 downto 0);
  signal read_ecc_error_addr_cnt : DDR3_ADDR_BUS_TYP; -- used for calc. last ECC error addr.
  --  signal central_interface_read_req_128m : std_logic_vector(2 downto 0);

  type FIFO_SEL_FSM_TYPE is (READING_WAIT, DATA_CONNECTED,
                             ADDR_SAVE_PULSE, ADDR_SAVED, HEADER_WAIT, HEADER_SAVE_PULSE, HEADER_SAVED,
                             ECC_CONNECTED, HEADER_ECC_CHECK, DATA_ECC_CHECK, DUAL_BUFFER_SW,
                             ECC_FIFO_CHECK, ECC_FIFO_CLR);
  signal FIFO_SEL_FSM_PS : FIFO_SEL_FSM_TYPE; -- buffers manager FSM
  signal ready_read_data : std_logic;       -- local header saved, go read data
  signal ready_read_data_128m, ready_read_data_128m_r : std_logic;

  signal ecc_data_in, ecc_data_in_masked : std_logic_vector(63 downto 0);
  signal ecc_data_out, ecc_data_out_i : std_logic_vector(63 downto 0);
  signal single_error, double_error :  std_logic_vector (71 downto 0); -- Error injection pattern
  signal error_mask :  unsigned(71 downto 0);
  signal ecc_error_mask_i : std_logic_vector(6 downto 0);
  signal ecc_error_injection_cmd_40m, ecc_error_injection_cmd_40m_r : std_logic_vector(1 downto 0);
  signal ecc_error_injection_cmd_r : std_logic_vector(1 downto 0);

  -- Test counters (check reading number)
  signal raw_rd_counter_cnt : unsigned(31 downto 0);
  signal ev_rd_counter_cnt  : unsigned(31 downto 0);
  -- signal inc_raw_rd_counter_64m, inc_ev_rd_counter_64m : boolean;
  signal inc_raw_rd_128m, inc_ev_rd_128m : std_logic;
  signal inc_raw_rd_vec, inc_ev_rd_vec : unsigned(2 downto 0);
  signal inc_raw_rd_vec_64m, inc_ev_rd_vec_64m : unsigned(2 downto 0);
  -- ECC Test
  -- signal ecc_err_word_in, ecc_err_word_in_r, ecc_err_word_out :  std_logic_vector (71 downto 0);
  -- signal ecc_check_bits_out : std_logic_vector(7 downto 0);
  -- signal load_ecc_err_word : boolean;
  -- signal shift_cnt : natural range 0 to 7;

  signal axi_rdata_r : std_logic_vector(31 downto 0);
  signal axi_rdata_valid_r   : std_logic;
  signal h_a_received_40m, h_a_received_40m_r : boolean;     -- 09/01/2017 read from FIFO sync

  signal start_address_ready : boolean;
  signal start_addr_reg_r, start_addr_reg_128m,
    start_addr_reg_40m : DDR3_ADDR_BUS_TYP; -- adress from ptr (FIFO) buffer
  signal addr_saved_128m : boolean;
  signal addr_saved_src, addr_saved_dst : std_logic;
  signal fifo_with_data_sync2eccout : std_logic;

  -- Header/address FIFO
  signal wrreq_h_a_fifo, rdreq_h_a_fifo : std_logic;
  signal q_128to40m, q_128to40m_r : std_logic_vector(31 downto 0);
  signal rdempty_h_a_fifo : std_logic;
  -- signal wrusedw_h_a_fifo : std_logic_vector(2 downto 0); -- NU

  -- !debug: 08/01/2017
  -- constant SKIP_ECC : boolean := FALSE;  -- disable ECC check
  signal SKIP_ECC : boolean;
  signal dummy_ecc_data_out : std_logic_vector(63 downto 0);
  signal header_received_128m, header_received_r0_40m, header_received_40m : boolean;
  signal saved_burst_size, burst_cnt : natural range 0 to 127;
  signal header_dw_cnt, header_idx_40m : natural range 0 to HEADER_NUM_DWORDS; -- when saved
  signal module_raw_header, module_raw_header_r, module_raw_header_128m : std_logic_vector(32*HEADER_NUM_DWORDS - 1 downto 0); -- 10/01/2017

  signal packet_size_sig : natural range 0 to 2**14;     -- reading size, not include header and ECC
  signal ecc_fifo_rdreq : std_logic;
  -- signal dec_fifo_wrreq : std_logic;                     -- write to FIFO
  signal dec_fifo_rdreq    : std_logic;                     -- read from FIFO
  signal dec_fifo_rdempty  : std_logic;                     -- FIFO empty
  signal dec_fifo_wrfull   : std_logic;                     -- FIFO full
  signal dec_fifo_wrusedw  : std_logic_vector(11 downto 0);  --words in FIFO
  signal dec_fifo_rdusedw  : std_logic_vector(10 downto 0);
  signal dec_fifo_q  : std_logic_vector (63 downto 0); -- data rom FIFO !debug: 11/07/2017 was also dec_fifo_data
  signal mod4_cnt : natural range 0 to 3;                             -- !debug: 11/07/2017 was for:
                                                                      --  - select QW from header for ECC check

  signal enable_read_data, enable_read_ecc, read_continue : boolean;
  -- constant SLICE_SIZE : natural := 16*16/32;   -- 29/01/2017 module slice size (detectors * bits / DW)
  constant SLICE_SIZE : natural := 4096/(4*64);   -- result in QW, when HD tiles, TMB RAW data for 64 slices = 4K bytes
  -- constant EV_SLICE_SIZE : natural := 16*16/(32*4);   -- 29/01/2017 module slice size (detectors * bits / DW)
                                                      -- 26/04/2017 change const merge_val = 4 to dynamic (see header SLICE_MERGE and FS_MERGE fields)
  signal reading_size_40m, reading_size_128m : natural range 0 to 2**14;

  signal check_header : std_logic;      -- check header ECC
  signal check_header_cnt : natural range 0 to HEADER_NUM_DWORDS; -- 06/07/2017
  -- signal dec_fifo_rdreq_en : std_logic; -- !debug: 28/02/2017 for sync between rd_data_ready, dec_fifo_rdreq, dec_fifo_q, ecc_fifo_q

  -- signal footer_w0, footer_w1, footer_w2, footer_w3 : std_logic_vector(31 downto 0); -- packet footer
  -- signal footer_w0_b0, footer_w0_b1 : std_logic; -- for footer word 0 ECC error and ECC double error bits
  -- signal write_footer, write_footer_en : std_logic;        -- 20/08/2017
  -- signal footer_cnt : natural range 0 to HEADER_NUM_DWORDS; -- !debug: 17/07/2017 now header size = footer size
  -- signal footer_qw : std_logic_vector(63 downto 0);

  signal remain_words : natural range 0 to 255; -- if words_in_bundle > max
  signal slices_num_temp, slices_num : natural range 0 to 255;
  signal slices_num_valid : boolean;
  signal reading_number_temp, time_stamp_low_temp : natural range 0 to 2**16;

  signal pattern_sig, pattern_sig_swapped : std_logic_vector(63 downto 0); -- !debug: 17/09/2018 only for test, remove

  -- 13/01/2020
  signal axi_start_read_i : std_logic;
  constant MAX_AXI_GRANT_WAIT : natural := 1023;  -- !debug: 04/07/2023 255 for max write burst time
  signal axi_wait_cnt : natural range 0 to MAX_AXI_GRANT_WAIT;

  component xpm_cdc_single
    generic (

      -- Common module generics
      DEST_SYNC_FF   : integer := 4;
      INIT_SYNC_FF   : integer := 0;
      SIM_ASSERT_CHK : integer := 0;
      SRC_INPUT_REG  : integer := 1
      );
    port (
      src_clk  : in  std_logic;
      src_in   : in  std_logic;
      dest_clk : in  std_logic;
      dest_out : out std_logic
      );
  end component;

  component xpm_hand_simple is
    generic (SLOW2FAST : boolean;
             WIDTH     : integer);
    port (rst_n    : in  std_logic;
          slow_clk : in  std_logic;
          fast_clk : in  std_logic;
          src_in   : in  std_logic_vector(WIDTH-1 downto 0);
          dest_out : out std_logic_vector(WIDTH-1 downto 0));
  end component xpm_hand_simple;

  signal start_addr_reg_dest : std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0);
  signal read_data_fsm_idle_ui_clk : std_logic;  -- read FSM in idle state
  signal regular_req_pulse_64m, evolving_req_pulse_64m : std_logic;
  
  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of read_fsm_error_40m_0, pointer_error, buffer_rd_addr_error, read_addr : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of read_fsm_error_40m_0, pointer_error, buffer_rd_addr_error, read_addr : signal is "true";

  signal writes2fifo_tmp_cnt : natural range 0 to 4095 := 0; -- !debug: 10/11/2023 only for debug

begin


  sync_pr : process (ddr3_if_rst_n, ui_clk)
  begin
    if ddr3_if_rst_n = '0' then
      READ_READING_RAW_DATA_ADDR <= RAW_DATA_BASE_ADDR;
      READ_READING_EV_DATA_ADDR  <= EV_DATA_BASE_ADDR;
      read_fsm_error_128m        <= '0';
      read_fifo_space_128m       <= (others => '1');
      fifo_almost_full           <= FALSE;
      evolving_reading           <= FALSE;
      timeout_cnt                <= 1023;
      new_reading_begin_vec      <= (others => '0');
      -- ready_read_data_128m       <= '0';
      ready_read_data_128m_r     <= '0';
      axi_rdata_r                <= (others => '0');
      axi_rdata_valid_r          <= '0';
      -- addr_saved_r               <= FALSE;
      addr_saved_128m            <= FALSE;
      start_addr_reg_r           <= (others => '0');
      start_addr_reg_128m        <= (others => '0');
      start_address_ready        <= FALSE;
      pointer_error              <= '0';
      buffer_rd_addr_error       <= '0';
      header_dw_cnt <= 0;
      header_received_128m <= FALSE;
      enable_read_data <= FALSE;
      read_continue <= FALSE;
      reading_size_128m <= 0;
      enable_read_ecc <= FALSE;
      fifo4k_full_128m_shr <= (others => '0');
      fifo4k_full_128m <= '0';
      read_data_fsm_idle_ui_clk <= '0';
    elsif ui_clk'EVENT and ui_clk = '1' then

      fifo4k_full_128m_shr <= fifo4k_full_128m_shr(2 downto 0) & fifo4k_full;
      if (fifo4k_full_128m_shr = X"F") then
        fifo4k_full_128m <= '1'; -- prevent short full pulse after reset
      else
        fifo4k_full_128m <= '0';
      end if;

      if ( reading_addr_fifo_addr < ADDR_FIFO_BASE_ADDR ) or ( reading_addr_fifo_addr >= ADDR_FIFO_END_ADDR ) then
        pointer_error <= '1'; -- sticky error
      end if;

      if (READ_DATA_FSM_PS = SLICES_HEADER_WAIT or READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT) then
        if not((not evolving_reading and (read_addr >= RAW_DATA_BASE_ADDR and read_addr <= RAW_DATA_END_ADDR)) or
               (evolving_reading and (read_addr >= EV_DATA_BASE_ADDR and read_addr <= EV_DATA_END_ADDR))) then
          buffer_rd_addr_error <= '1'; -- sticky error
        end if;
      end if;

      if ((timeout_cnt = 0) or          -- !debug: 17/01/2017  was wait_data_done_cnt
          ((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT) and requested_words_cnt > words_in_bundle) or
          ((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT) and module_raw_header_128m(1023-16 downto 1023-31) /= X"FACE") or -- !debug: 09/11/2023 was   1023 downto 1023-15
          error_read_addr) then
        read_fsm_error_128m <= '1';     -- read module error
        assert (FALSE) report "Read block: FSM error!!!" severity ERROR;
      elsif (READ_DATA_FSM_PS = READ_IDLE) then
        read_fsm_error_128m <= '0';
      end if;

      read_fifo_space_128m <= std_logic_vector(to_unsigned(2047, 11) - unsigned(fifo4k_wr_data_count(10 downto 0)));

      fifo_almost_full <= (unsigned(read_fifo_space_128m) < to_unsigned(64, 11)); -- this flag prevent read from DDR3

      if (READ_DATA_FSM_PS = READ_IDLE and (REGULAR_REQ_PULSE = '1' or EVOLVING_REQ_PULSE = '1')) then
        writes2fifo_tmp_cnt <= 0;
      elsif (fifo4k_wr_en = '1') then
        writes2fifo_tmp_cnt <= writes2fifo_tmp_cnt + 1;
      end if;

      if (REGULAR_REQ_PULSE = '1') then
        evolving_reading <= FALSE;
      elsif (EVOLVING_REQ_PULSE = '1') then
        evolving_reading <= TRUE;
      end if;

      if (READ_DATA_FSM_PS /= SLICES_HEADER_WAIT and
          READ_DATA_FSM_PS /= SLICES_READ_RD and READ_DATA_FSM_PS /= SLICES_READ_WAIT and
          READ_DATA_FSM_PS /= WAIT4DONE and READ_DATA_FSM_PS /= ADDR_READ_WAIT) then -- !debug: 15/08/2018
        timeout_cnt <= 1023;
      elsif (timeout_cnt /= 0) then
        timeout_cnt <= timeout_cnt - 1;
      end if;

      -- ready_read_data_128m <= ready_read_data; -- 40MHz to 128MHz
      ready_read_data_128m_r <= ready_read_data_128m;

      -- registered DDR2 controller outputs
      axi_rdata_r          <=  axi_rdata;
      axi_rdata_valid_r <= axi_rdata_valid;

      -- wide pulse for sync to 40MHz
      if (new_reading_begin) then
        new_reading_begin_vec <= (new_reading_begin_vec'range => '1');
      else
        new_reading_begin_vec <= (new_reading_begin_vec(1 downto 0) & '0');
      end if;

      -- Read pointers for comparison in EV and RAW buffers
      if (not new_reading_begin) then
        if (evolving_reading) then
          READ_READING_EV_DATA_ADDR <= read_addr;
        else
          READ_READING_RAW_DATA_ADDR <= read_addr;
        end if;
      end if;

      -- sync RAW reading start address to 128MHz
      -- addr_saved_r <= (FIFO_SEL_FSM_PS = ADDR_SAVED); -- sync 40MHz to 128MHz
      -- addr_saved_128m  <= addr_saved_r;
      addr_saved_128m  <= (addr_saved_dst = '1'); -- 27/09/2023
      start_addr_reg_r <= DDR3_ADDR_BUS_TYP(start_addr_reg_dest); -- !TODO: 27/09/2023 src @sys_clk -> use xpm_cdc_array_single
      if (addr_saved_128m) then
        start_addr_reg_128m <= start_addr_reg_r;
        start_address_ready <= TRUE;
      else
        start_address_ready <= FALSE;
      end if;

      -- 09/01/2017
      if (REGULAR_REQ_PULSE = '1' or EVOLVING_REQ_PULSE = '1') then
        header_dw_cnt   <= HEADER_NUM_DWORDS;
      elsif (header_dw_cnt /= 0) then
        if(READ_DATA_FSM_PS = SLICES_HEADER_WAIT and header_dw_cnt /= 0 and axi_rdata_valid = '1') then
          header_dw_cnt <= header_dw_cnt - 1;
        end if;
      end if;

      header_received_128m <= (header_dw_cnt = 0);

      if (new_reading_begin or requested_packetwords_cnt >= reading_size_128m) then
        enable_read_data <= FALSE;
      elsif (new_reading_begin_vec(2) = '1' and new_reading_begin_vec(1) = '0') then
        enable_read_data <= TRUE;
      end if;
      if (SKIP_ECC) then
        enable_read_ecc <= FALSE;
      else
        if (new_reading_begin or requested_packetwords_cnt >= (reading_size_128m+reading_size_128m/8+1)) then -- 4x ECC bytes per DW
          enable_read_ecc <= FALSE;
        elsif (new_reading_begin_vec(2) = '1' and new_reading_begin_vec(1) = '0') then
          enable_read_ecc <= TRUE;
        end if;
      end if;
      if (SKIP_ECC) then
        if ((enable_read_data) and not new_reading_begin) then
          read_continue <= (requested_packetwords_cnt < (reading_size_128m));
        else
          read_continue <= FALSE;
        end if;
      else
        if ((enable_read_data or enable_read_ecc) and not new_reading_begin) then
          read_continue <= (requested_packetwords_cnt < (reading_size_128m+reading_size_128m/8+1));
        else
          read_continue <= FALSE;
        end if;
      end if;

      reading_size_128m <= reading_size_40m;

      if (READ_DATA_FSM_PS = READ_IDLE) then
        read_data_fsm_idle_ui_clk <= '1';
      else
        read_data_fsm_idle_ui_clk <= '0';
      end if;

    end if;
  end process sync_pr;

  xpm_cdc_single_1 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => addr_saved_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => addr_saved_src                -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  xpm_cdc_single_3 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => ready_read_data_128m, -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,               -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,            -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => ready_read_data       -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  xpm_hand_simple_1: xpm_hand_simple
    generic map (
      SLOW2FAST => TRUE,
      WIDTH     => DDR3_ADDR_WIDTH)
    port map (
      rst_n    => RESET_I,
      slow_clk => CLK_50Mhz,
      fast_clk => ui_clk,
      src_in   => std_logic_vector(start_addr_reg_40m),
      dest_out => start_addr_reg_dest
    );

  -------- Sync received header/address to 40MHz -------------------------------

  wrreq_h_a_fifo <= '1' when ((READ_DATA_FSM_PS = SLICES_HEADER_WAIT or
                               READ_DATA_FSM_PS = ADDR_READ_WAIT)
                              and axi_rdata_valid_r = '1')
                    else '0';

  rdreq_h_a_fifo <= not rdempty_h_a_fifo when (header_received_40m or not evolving_reading_40m) else '0';


  -- Received header/address
  dcfifo_a : dcfifo_512x32
    port map (
      rst           => "not"(ddr3_if_rst_n),
      wr_clk        => ui_clk, -- !debug: 20/02/2017 now same WR/RD clocks, was  CLK_50Mhz,
      rd_clk        => CLK_50Mhz,
      din           => axi_rdata_r,
      wr_en         => wrreq_h_a_fifo,
      rd_en         => rdreq_h_a_fifo,
      dout          => q_128to40m,
      full          => open,
      overflow      => open,
      empty         => rdempty_h_a_fifo,
      valid         => open,
      underflow     => open,
      rd_data_count => open,
      wr_data_count => open
    );                                  -- FQ data FIFO


  -- READ_READING_EV_SLOTNUM <= ev_slotnum_ptr;


  -- Read data request
  read_ctl_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then

      axi_start_read_i <= '0';
      axi_burst_len    <= (others => '0');
      axi_raddr_offset <= (others => '0');

    elsif ui_clk'event and ui_clk = '1' then

      if (not fifo_almost_full) then
        if (READ_DATA_FSM_PS = SLICES_HEADER_RD) then   -- request header from DDR
          if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4) and (axi_master_state(4) = '0' and axi_master_state(5) = '0' and axi_master_state(1) = '0')) then
            axi_start_read_i <= '1';
          end if;
          axi_burst_len    <= std_logic_vector(to_unsigned(HEADER_NUM_DWORDS, axi_burst_len'length));
          axi_raddr_offset <= std_logic_vector(resize(read_addr, axi_raddr_offset'length));

        elsif (READ_DATA_FSM_PS = SLICES_READ_RD) then  -- request slice data from DDR
          axi_start_read_i <= '1';
          axi_burst_len    <= std_logic_vector(to_unsigned(saved_burst_size, axi_burst_len'length));
          axi_raddr_offset <= std_logic_vector(resize(read_addr, axi_raddr_offset'length));

        elsif (READ_DATA_FSM_PS = ADDR_READ_RD) then    -- request start address
                                                        -- for next reading
          axi_start_read_i <= '1';
          axi_burst_len    <= (0 => '1', others => '0');
          axi_raddr_offset <= std_logic_vector(resize(reading_addr_fifo_addr, axi_raddr_offset'length));

        else
          axi_start_read_i <= '0';
        end if;
      else
        axi_start_read_i <= '0';
      end if;

    end if;
  end process read_ctl_pr;

  axi_start_read <= axi_start_read_i;

  -- purpose: 10.11 READING_ADDRESS_FIFO address reading
  -- TODO: add check for DDR read overflow (if read ptr. > write ptr.)
  reading_addr_fifo_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then                                        -- asynchronous reset (active low)

      reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR;

    elsif ui_clk'event and ui_clk = '1' then

      if (READ_DATA_FSM_PS = READ_IDLE and REGULAR_REQ_PULSE = '1') then
          if (reading_addr_fifo_addr = ADDR_FIFO_END_ADDR) then
            reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR;         -- overflow
          else
            -- reading_addr_fifo_addr <= reading_addr_fifo_addr + 4;  -- next reading
                        -- !debug: 15/01/2020 was + 1
            -- reading_addr_fifo_addr <= reading_addr_fifo_addr + 1;  -- next reading !debug: 12/07/2023
            reading_addr_fifo_addr <= raw_rd_ptr_addr; -- !debug: 13/07/2023 replaces increment with load
          end if;
      end if;

    end if;
  end process reading_addr_fifo_pr;


  READ_READING_ADDR_FIFO_ADDR <= reading_addr_fifo_addr;


  -- purpose: 10.11 RAW Data Address Generation, 10.11.2  EV Address Generation
  read_addr_pr : process (ddr3_if_rst_n, ui_clk) is
  begin  -- process read_addr_pr
    if ddr3_if_rst_n = '0' then

      read_addr       <= RAW_DATA_BASE_ADDR;
      requested_words_cnt <= 0;
      reading_start_addr  <= (others => '0');
      error_read_addr <= FALSE;
      -- ev_slotnum_ptr      <= (others => '0');
      ev_data_addr_offset <= EV_DATA_BASE_ADDR;
      -- prev_ev_addr_offset <= EV_DATA_BASE_ADDR;
      requested_packetwords_cnt <= 0;

    elsif ui_clk'EVENT and ui_clk = '1' then

      if (start_address_ready) then                         -- start addr for RAW reading
        read_addr       <= unsigned(start_addr_reg_128m);  -- Reading start address
        requested_words_cnt <= 0;
        reading_start_addr  <= unsigned(start_addr_reg_128m);

      elsif (READ_DATA_FSM_PS = ADDR_CALC) then  -- Calculate offset address for EV reading

        -- loaded address
        if ( ev_data_addr_offset > EV_DATA_END_ADDR) then  -- !debug: 27/11/2023 was EV_DATA_END_ADDR - 2*EV_READING_SIZE
                                                           -- now gap decremented in address map
          ev_data_addr_offset <= EV_DATA_BASE_ADDR; -- !debug: 18/07/2023 error
        else
          -- ev_data_addr_offset <= ev_data_addr_offset + EV_READING_SIZE;  -- save next reading
          ev_data_addr_offset <= ev_rd_slot_addr;
          -- prev_ev_addr_offset <= ev_data_addr_offset;
          -- !TODO: 18/07/2023 create assertion, when loaded increment slot prev_ev_addr_offset = ev_rd_slot_addr
        end if;

        -- !TODO: 16/07/2023 replace incremet slot number with calculated from ev_data_addr_offset_40m
        -- (ev_data_addr_offset - EV_DATA_BASE_ADDR) / slot_size
        -- if (ev_slotnum_ptr < to_unsigned((EV_NUM_OF_SLOTS), ev_slotnum_ptr'LENGTH)) then
        --   ev_slotnum_ptr <= ev_slotnum_ptr + 1;         -- next slot
        -- else
        --   ev_slotnum_ptr <= (0 => '1', others => '0');  -- EV address overflow
        -- end if;

      elsif (READ_DATA_FSM_PS = ADDR_LOAD) then  -- Load start addr for EV reading

        read_addr       <= ev_data_addr_offset;  -- goto next reading slot
        requested_words_cnt <= 0;
        requested_packetwords_cnt <= 0;
        reading_start_addr  <= ev_data_addr_offset;

      elsif (READ_DATA_FSM_PS = ADDR_READ_WAIT) then  -- Load start addr for RAW reading

        requested_packetwords_cnt <= 0;               -- !debug: 02/02/2017

      elsif (READ_DATA_FSM_PS = SLICES_WAIT4GRANT) then
        requested_words_cnt <= 0;

        --      elsif (READ_DATA_FSM_PS = SLICES_HEADER_WAIT and LOCAL_READ_DATA_VALID_A = '1') then

        --        read_addr <= read_addr + unsigned(BURST_SIZE); -- received header word, go to data

      elsif (((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT) and
              requested_words_cnt < words_in_bundle)  -- read data slice
             or (READ_DATA_FSM_PS = SLICES_HEADER_WAIT and ready_read_data_128m_r = '1')  -- received header word
             ) then

        if (evolving_reading) then

          if (read_addr > EV_DATA_END_ADDR) then -- !debug: 14/11/2023
            assert (FALSE) report "Error: wrong EV reading size!!!" severity ERROR;
            error_read_addr <= TRUE;
          elsif (read_addr < EV_DATA_BASE_ADDR or read_addr > EV_DATA_END_ADDR) then
            assert (FALSE) report "Error: Selected address not in EV buffer!!!" severity ERROR;
            error_read_addr <= TRUE;
          elsif (READ_DATA_FSM_PS = SLICES_HEADER_WAIT and ready_read_data_128m_r = '1') then -- 15/01/2017
            read_addr <= read_addr + (HEADER_NUM_DWORDS * 4); -- !debug: 15/01/2020 << 2
            -- read_addr <= read_addr + HEADER_NUM_DWORDS; -- !debug: 12/07/2023
          elsif (burst_cnt = 1 and axi_rdata_valid_r = '1') then   -- 10/01/2017
            read_addr <= read_addr + (saved_burst_size * 4); --  !debug: 15/01/2020 << 2
            -- read_addr <= read_addr + saved_burst_size; --  !debug: 12/07/2023
          end if;

        else

          if (read_addr > RAW_DATA_END_ADDR) then -- !debug: 27/11/2023 now gap decremented in address map
            read_addr <= RAW_DATA_BASE_ADDR;      -- address overflow
          elsif (READ_DATA_FSM_PS = SLICES_HEADER_WAIT and ready_read_data_128m_r = '1') then -- 10/01/2017
            read_addr <= read_addr + (HEADER_NUM_DWORDS * 4); -- !debug: 15/01/2020 << 2
            -- read_addr <= read_addr + HEADER_NUM_DWORDS; -- !debug: 12/07/2023
          elsif (burst_cnt = 1 and axi_rdata_valid_r = '1') then   -- 10/01/2017
            read_addr <= read_addr + (saved_burst_size * 4); --  !debug: 15/01/2020 << 2
            -- read_addr <= read_addr + saved_burst_size; -- !debug: 12/07/2023
          end if;

        end if;

        if ((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT) and burst_cnt = 0) then  -- header is not data word
          requested_words_cnt <= requested_words_cnt + saved_burst_size;  -- 10/01/2017
          requested_packetwords_cnt <= requested_packetwords_cnt + saved_burst_size;  -- 29/01/2017
        end if;

      end if;

      if (read_addr > RAW_DATA_END_ADDR) then
        assert (FALSE) report "Error: wrong RAW reading size!!!" severity ERROR;
        error_read_addr <= TRUE;
      end if;

    end if;
  end process read_addr_pr;


  tx_completed <= (num_words = words_in_bundle) and (READ_DATA_FSM_PS = WAIT4DONE);


  -- purpose: sync local header to DDR3 clock, also burst support
  header_reg_pr : process (ddr3_if_rst_n, ui_clk) is
  begin  -- process header_reg_pr
    if ddr3_if_rst_n = '0' then

      module_raw_header_r <= (others => '0');
      module_raw_header_128m <= (others => '0');
      words_in_bundle <= 0;
      remain_words <= 0;

    elsif ui_clk'EVENT and ui_clk = '1' then

      -- 10/01/2017
      module_raw_header_r <= module_raw_header;
      module_raw_header_128m <= module_raw_header_r;

      -- <Slice size> = 16 detectors/TMC * {16 | 24 | 48} bit/detector * 4 TMC/peripheral
      -- Ex: For 16 detectors/TMC: 16*16*4 = 1024 bits or 1024/64=16 words
      --
      -- slice size: 8 DW
      if (enable_read_data) then -- 29/01/2017
        words_in_bundle <= SLICE_SIZE * 2;   -- burst size
                                             -- !debug 03/06/2018 32 -> 16 (reading read time: ~4uSec -> ~5uSec)
      else
        if (enable_read_ecc) then
          if ((reading_size_128m/8 + 1) < 127) then     -- not 127 slices
            words_in_bundle <= reading_size_128m/8 + 1; -- burst when reading ECC, must be less then max IP burst size. 4x ECC bytes per DW
          elsif (READ_DATA_FSM_PS = WAIT4DONE) then
            if (remain_words > (SLICE_SIZE * 2)) then
              words_in_bundle <= SLICE_SIZE * 2;
            else
              words_in_bundle <= remain_words;
            end if;
          end if;
        end if;
      end if;

       -- 10/07/2017 in case 127 slices
      if (enable_read_data) then
        remain_words <= (reading_size_128m/8 + 1);
      elsif (enable_read_ecc) then
        if ((reading_size_128m/8 + 1) >= 127 and (burst_cnt = 1 and axi_rdata_valid_r = '1')) then
          if (remain_words > (SLICE_SIZE * 2)) then
            remain_words <= remain_words - (SLICE_SIZE * 2);
          else
            remain_words <= 0;
          end if;
        end if;
      end if;

    end if;
  end process header_reg_pr;


  -- purpose: sampling Reading local header and start address from ECC decoder
  local_header_40m_pr: process (CLK_50Mhz, RESET_40)
  begin  -- process local_header_40m_pr
    if RESET_40 = '0' then              -- asynchronous reset (active low)
      start_addr_reg_40m <= (others => '0');
      module_raw_header <= (others => '0');
      header_idx_40m <= 0;
      reading_size_40m <= 2**14;         -- unknown, then when init uses MAX value
      READ_ECC_ERROR <= '0';
      -- footer_w0_b0 <= '0';
      -- footer_w0_b1 <= '0';
      slices_num_temp <= 0;
      slices_num <= 0;
      slices_num_valid <= TRUE;
      reading_number_temp <= 0;
      time_stamp_low_temp <= 0;
    elsif CLK_50Mhz'event and CLK_50Mhz = '1' then  -- rising clock edge

      if (FIFO_SEL_FSM_PS /= HEADER_WAIT) then
        header_idx_40m <= 0;
      elsif (h_a_received_40m_r) then
        header_idx_40m <= header_idx_40m + 1;
      end if;

      if (FIFO_SEL_FSM_PS = HEADER_WAIT) then
        if (not ecc_double_error or SKIP_ECC) then
          module_raw_header(32*header_idx_40m + 31 downto 32*header_idx_40m) <= q_128to40m_r(31 downto 0);
        end if;
      end if;

      -- -- !debug: 12/06/2017 now ECC part of footer, not header
      -- if (new_reading_begin_40m) then
      --   READ_ECC_ERROR <= '0';
      --   footer_w0_b0 <= '0';
      --   footer_w0_b1 <= '0';
      -- else
      --   if (ecc_double_error) then
      --     READ_ECC_ERROR <= '1';
      --     footer_w0_b1 <= '1';
      --   end if;
      --   if (ecc_error) then
      --     footer_w0_b0 <= '1';
      --   end if;
      -- end if;

      if (FIFO_SEL_FSM_PS = ADDR_SAVE_PULSE) then
        if (not ecc_double_error or SKIP_ECC) then
          start_addr_reg_40m <= unsigned(q_128to40m_r(DDR3_ADDR_BUS_TYP'RANGE)); -- RAW Reading start address
        end if;
      end if;

      if (FIFO_SEL_FSM_PS = HEADER_WAIT) then -- 10/07/2017
        if (header_idx_40m = (HEADER_NUM_DWORDS - 1) and h_a_received_40m_r) then
          slices_num_temp <= to_integer(unsigned(module_raw_header(23 downto 16))); -- W1 !debug: 09/11/2023 was  7 downto 0
          reading_number_temp <= to_integer(unsigned(module_raw_header(16*9+15 downto 16*9))); -- W9 !debug: 09/11/2023 was   16*8+15 downto 16*8
          time_stamp_low_temp <= to_integer(unsigned(module_raw_header(16*29+15 downto 16*29))); -- W29 !debug: 09/11/2023 was  16*28+15 downto 16*28
        end if;
      end if;

      if (FIFO_SEL_FSM_PS = HEADER_SAVE_PULSE) then
--      if (slices_num_temp = 4 or slices_num_temp = 8 or
--             slices_num_temp = 16 or slices_num_temp = 32 or slices_num_temp = 64 or
--             slices_num_temp = 128 or slices_num_temp = 256) then
        if (slices_num_temp <= 64) and (slices_num_temp >= 2) and 							--  >= 4
          (to_unsigned(slices_num_temp,10)(0) = '0') then													-- in one energy
--        	  (slices_num_fh(0) = '0') then													-- in one energy
--        	  (slices_num_fh(1 downto 0) = "00") then										-- in the two  energy
          slices_num_valid <= TRUE;
          slices_num <= slices_num_temp; -- 03/07/2023
        else
          slices_num_valid <= FALSE;    -- !TODO: 07/11/2017 add as error to register
        end if;
      end if;

      if (FIFO_SEL_FSM_PS = HEADER_SAVED) then
        if (slices_num_valid) then -- hold previous value if not valid
          reading_size_40m <= SLICE_SIZE * slices_num; -- reading_size calc from header
                                                                                                      -- !debug: 12/06/2017 was (32+31 downto 32+24)
        else
          if (evolving_reading_40m) then         -- !debug: 03/07/2018 was evolving_reading
            reading_size_40m <= SLICE_SIZE * 8 ;						-- 32 slc full quality : 4
          else
            reading_size_40m <= SLICE_SIZE * 32 ;						-- 32 slc full quality
          end if;
        end if;

      end if;

    end if;
  end process local_header_40m_pr;


  -- purpose: Connect/disconnect output FIFO to central_interface.
  --  CHANGE: select source for ECC decoder
  -- Select local header word from FIFO
  fifo_sel_fsm_pr: process (CLK_50Mhz, RESET_40)
  begin  -- process fifo_sel_fsm_pr
    if RESET_40 = '0' then              -- asynchronous reset (active low)
      FIFO_SEL_FSM_PS <= READING_WAIT;
      ready_read_data <= '0';
      -- dual_buffer_wr_sel <= '0';
      -- write_footer_en <= '0';
      addr_saved_src <= '0';
    elsif CLK_50Mhz'event and CLK_50Mhz = '1' then  -- rising clock edge

      ready_read_data <= '0';

      case FIFO_SEL_FSM_PS is

        when READING_WAIT =>  -- wait for registered address or header
          if (h_a_received_40m) then -- address received
            if (evolving_reading_40m) then -- expected local header from DDR controller
              FIFO_SEL_FSM_PS <= HEADER_WAIT; -- !debug: 15/01/2017 was  HEADER_SAVE_PULSE
            else -- expected start address from DDR controller
              FIFO_SEL_FSM_PS <= ADDR_SAVE_PULSE;
            end if;
            -- write_footer_en <= '0';
          end if;

        when ADDR_SAVE_PULSE =>  -- save checked address
          FIFO_SEL_FSM_PS <= ADDR_SAVED;
          addr_saved_src <= '1';

        when ADDR_SAVED =>   -- place for sync checked address to 128MHz
          if (h_a_received_40m) then
            FIFO_SEL_FSM_PS <= HEADER_WAIT;
            addr_saved_src <= '0';
          end if;

        when HEADER_WAIT =>
          if (header_idx_40m = (HEADER_NUM_DWORDS - 1) and h_a_received_40m_r) then -- expected local header from DDR controller 09/01/2017
            FIFO_SEL_FSM_PS <= HEADER_SAVE_PULSE;
          end if;

        when HEADER_SAVE_PULSE =>  -- save checked header
          FIFO_SEL_FSM_PS <= HEADER_SAVED; -- reconnect DDR_DRIVER_FIFO_EMPTY to output
          ready_read_data <= '1'; -- local header saved, go read data

        when HEADER_SAVED => -- place for sync checked header to 128MHz
          FIFO_SEL_FSM_PS <= DATA_CONNECTED;

        when DATA_CONNECTED =>          -- save data from DDR3 to FIFO
          if (requested_packetwords_cnt_40m >= reading_size_40m) then
            -- FIFO_SEL_FSM_PS <= ECC_CONNECTED;
            FIFO_SEL_FSM_PS <= READING_WAIT; -- !debug: 29/06/2023 ECC removed
          end if;

        when ECC_CONNECTED =>           -- save ECC from DDR3 to FIFO
          if (requested_packetwords_cnt_40m >= (reading_size_40m+reading_size_40m/8+1)) then
            FIFO_SEL_FSM_PS <= DUAL_BUFFER_SW;
          end if;

        when DUAL_BUFFER_SW =>
          -- dual_buffer_wr_sel <= not dual_buffer_wr_sel; -- dual-buffer filling end
          FIFO_SEL_FSM_PS <= HEADER_ECC_CHECK;

        when HEADER_ECC_CHECK =>
          if (check_header = '0') then
            FIFO_SEL_FSM_PS <= DATA_ECC_CHECK;
          end if;

        -- !debug: 17/09/2018 from Aron new states: ECC_FIFO_CHECK, ECC_FIFO_CLR
        -- when DATA_ECC_CHECK =>
        --   if (fifo_empty_sync2eccout = '0') then            -- ECC check end
        --     FIFO_SEL_FSM_PS <= READING_WAIT;
        --     write_footer_en <= '1';
        --   end if;
        when DATA_ECC_CHECK =>
          if (fifo_with_data_sync2eccout = '0') then            -- ECC check end
            FIFO_SEL_FSM_PS <= ECC_FIFO_CHECK;
            -- write_footer_en <= '1';
          end if;

        when ECC_FIFO_CHECK =>
          if (ecc_fifo_rdempty = '1') then
            FIFO_SEL_FSM_PS <= READING_WAIT;
            -- write_footer_en <= '1';
          else
            FIFO_SEL_FSM_PS <= ECC_FIFO_CLR;
          end if;

        when ECC_FIFO_CLR =>
          if (ecc_fifo_rdempty = '1') then
            FIFO_SEL_FSM_PS <= READING_WAIT;
            -- write_footer_en <= '1';
          end if;

      end case;

    end if;
  end process fifo_sel_fsm_pr;


  -- purpose: counter for readed data burst from DDR
  num_words_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then
      num_words <= 0;
    elsif ui_clk'EVENT and ui_clk = '1' then
      if (READ_DATA_FSM_PS = SLICES_WAIT4GRANT) then -- !debug: 25/01/2017 was  SLICE_REQ_PULSE

        num_words <= 0;                 -- num_words - received data counter

      elsif ((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT or
              READ_DATA_FSM_PS = WAIT4DONE) and axi_rdata_valid_r = '1') then

        num_words <= num_words + 1;     -- !check, overflow

      end if;
    end if;
  end process num_words_pr;

------------------------------------------------------------------------------
-- ECC check
------------------------------------------------------------------------------

  -- ddr_hamming_1 : ddr_hamming
  --   generic map (
  --     ENCODER => FALSE)
  --   port map (
  --     CLK                => CLK_40M,
  --     RESET_I            => RESET_40,
  --     DATA_IN            => ecc_data_in_masked, -- dec_fifo_q from dec_fifo
  --     CHECK_BITS_IN      => check_bits_in_masked, -- ecc_fifo_q from ecc_fifo
  --     RD_DATA_READY      => rd_data_ready,
  --     DATA_OUT           => ecc_data_out_i,
  --     CHECK_BITS_OUT     => ecc_check_bits_out, -- open,
  --     ECC_ERROR          => ecc_error_t,
  --     ECC_DOUBLE_ERROR   => ecc_double_error_t,
  --     ECC_ERROR_LOCATION => ecc_error_location,
  --     DDR_HAMMING_TP     => open);


  -- disable ECC check
  ecc_error <= ecc_error_t when (not SKIP_ECC) else FALSE;
  ecc_double_error <= ecc_double_error_t when (not SKIP_ECC) else FALSE;
  ecc_data_out <= (others => '0'); -- pattern_sig_swapped when (packet_dec_word_cnt = 4) else
                  -- ecc_data_out_i when (not SKIP_ECC and read_fsm_error_40m = '0') else
                  -- dummy_ecc_data_out; -- !debug: 16/09/2018 send header in data only for debug - remove

  ecc_data_in <= dec_fifo_q when (check_header = '0') else
                 module_raw_header(63 downto 0) when (mod4_cnt = 0) else  -- header
                 module_raw_header(127 downto 64) when (mod4_cnt = 1) else  -- header
                 (others => '0');

  ecc_data_in_masked <= std_logic_vector(unsigned(ecc_data_in) xor error_mask(63 downto 0));


  process (CLK_50Mhz, RESET_40)
  begin
    if RESET_40 = '0' then
      SKIP_ECC		<=	FALSE ;
    elsif CLK_50Mhz = '1' and CLK_50Mhz'EVENT then

    	if (NO_ECC_CHK = '1') then
      		SKIP_ECC		<=	TRUE ;
    	else
      		SKIP_ECC		<=	FALSE ;
    	end if;
    end if;
  end process;


  -- Error injection - single_error_gen, double_error_gen
  -- (from Xilinx XAPP645, modified)
  error_gen : process (CLK_50Mhz, RESET_40)
  begin
    if RESET_40 = '0' then
      single_error <= X"000000000000000001";
      double_error <= X"000000000000000003";
    elsif CLK_50Mhz = '1' and CLK_50Mhz'EVENT then
      single_error(0)           <= single_error(71);
      single_error(71 downto 1) <= single_error(70 downto 0);
      double_error(0)           <= double_error(71);
      double_error(71 downto 1) <= double_error(70 downto 0);
    end if;
  end process;


  set_error_mask: process (CLK_50Mhz, RESET_40) is
    variable ecc_error_mask_v : unsigned(6 downto 0);
  begin  -- process set_error_mask
    if RESET_40 = '0' then              -- asynchronous reset (active low)
      error_mask <= (others => '0');
      ecc_error_mask_i <= (others => '0');
    elsif CLK_50Mhz'event and CLK_50Mhz = '1' then  -- rising clock edge

      if (ecc_error_injection_cmd_40m_r /= ecc_error_injection_cmd_40m) then
        case ecc_error_injection_cmd_40m is
          when "01" => error_mask <= unsigned(single_error); -- load error mask value
          when "10" => error_mask <= unsigned(double_error);
          when others => error_mask <= (error_mask'range => '0');
        end case;
      end if;

      ecc_error_mask_v := (others => '0');
      for i in 0 to error_mask'LEFT loop
        if (error_mask(i) = '1') then
          ecc_error_mask_v := to_unsigned(i,7);
          exit;
        end if;
      end loop;  -- i

      ecc_error_mask_i <= std_logic_vector(ecc_error_mask_v);

    end if;
  end process set_error_mask;


  -- -- For debug purpose - if ECC error check ECC decoder data in/out
  -- sample_error_pr: process (CLK_50Mhz, RESET_40) is
  -- begin  -- process sample_error_pr
  --   if RESET_40 = '0' then              -- asynchronous reset (active low)
  --     ecc_err_word_in  <= (others => '0');
  --     ecc_err_word_in_r  <= (others => '0');
  --     ecc_err_word_out <= (others => '0');
  --     load_ecc_err_word <= TRUE;
  --     shift_cnt <= 0;
  --   elsif CLK_50Mhz'event and CLK_50Mhz = '1' then  -- rising clock edge
  --
  --     ecc_err_word_in(71 downto 64) <= check_bits_in_masked;
  --     ecc_err_word_in(63 downto 0)  <= ecc_data_in_masked;
  --
  --     if ( ecc_error and load_ecc_err_word) then
  --       ecc_err_word_in_r  <= ecc_err_word_in;
  --       ecc_err_word_out(71 downto 64) <= ecc_check_bits_out;
  --       ecc_err_word_out(63 downto 0) <= ecc_data_out;
  --       load_ecc_err_word <= FALSE;
  --       shift_cnt <= 7;
  --     else
  --       if (shift_cnt > 0) then
  --         ecc_err_word_in_r <= (ecc_err_word_in_r(63 downto 0) & X"00");
  --         ecc_err_word_out <= (ecc_err_word_out(63 downto 0) & X"00");
  --         shift_cnt <= shift_cnt - 1;
  --       else
  --         load_ecc_err_word <= TRUE;
  --       end if;
  --     end if;
  --
  --     --      lai_8bit_err_word_in <= ecc_err_word_in_r(71 downto 64);
  --     --      lai_8bit_err_word_out <= ecc_err_word_out(71 downto 64);
  --
  --   end if;
  -- end process sample_error_pr;


  -- -- Central interface <-> READ block:
  -- DDR_DRIVER_DOUT       <= fifo_dual_b1_q when (dual_buffer_rd_sel = '0') else fifo_dual_b2_q; -- 13/07/2017  was ecc_data_out
  -- DDR_DRIVER_FIFO_EMPTY <= fifo_dual_b1_empty when (dual_buffer_rd_sel = '0') else fifo_dual_b2_empty; -- 13/07/2017
  -- DDR_DRIVER_RD_DONE <= write_footer_en and not write_footer; -- 15/01/2018


  -- Main read data FSM's
  -- 13/01/2020 usage:
  --  - start read new reading - REGULAR_REQ_PULSE, EVOLVING_REQ_PULSE
  --  - check if current reading not complete - read_continue
  --  - request/wait pointer address (FQ reading start address) and reading header
  --  - calc EV reading start address
  read_data_fsm_clocked_proc : process (ddr3_if_rst_n, ui_clk)
  begin
    if (ddr3_if_rst_n = '0') then

      READ_DATA_FSM_PS   <= IDLE;
      -- Default Reset Values
      wait_data_done_cnt <= 63;
      new_reading_begin <= FALSE;
      inc_raw_rd_vec <= (others => '0');
      inc_ev_rd_vec <=  (others => '0');
      inc_ev_rd_128m <= '0';
      inc_raw_rd_128m <= '0';
      axi_if_req <= '0';
      axi_wait_cnt <= 0;
      gnt_catch <= '0';

    elsif (ui_clk'EVENT and ui_clk = '1') then

      axi_if_req <= '0';
      gnt_catch <= '0';

      -- read_data_fsm_nextstate
    case READ_DATA_FSM_PS is
      when IDLE =>                      -- after reset or error
        READ_DATA_FSM_PS <= READ_IDLE;

      when READ_IDLE =>
        if (read_continue and axi_master_state(0) = '1' and not fifo_almost_full) then  --  !debug: 16/07/2023
          READ_DATA_FSM_PS <= SLICES_WAIT4GRANT;
          axi_if_req <= '1';
        elsif (REGULAR_REQ_PULSE = '1') then
          READ_DATA_FSM_PS <= ADDR_WAIT4GRANT; -- then ADDR_READ_RD -> ADDR_READ_WAIT -> SLICES_HEADER_RD
          axi_if_req <= '1';
        elsif (EVOLVING_REQ_PULSE = '1') then  -- then ADDR_LOAD -> SLICES_HEADER_RD
          READ_DATA_FSM_PS <= ADDR_CALC;
        end if;
        axi_wait_cnt <= MAX_AXI_GRANT_WAIT;

      when SLICES_WAIT4GRANT =>
        if (axi_wait_cnt /= 0) then
          axi_wait_cnt <= axi_wait_cnt - 1;
        end if;
        if (axi_master_state(0) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4) and (axi_master_state(4) = '0' and axi_master_state(5) = '0' and axi_master_state(1) = '0')) then  -- !debug: 13/01/2020
          READ_DATA_FSM_PS <= SLICES_READ_RD;
        end if;
        axi_if_req <= '1';
        if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
          gnt_catch <= '1';
        end if;

      when ADDR_WAIT4GRANT =>
        if (axi_wait_cnt /= 0) then
          axi_wait_cnt <= axi_wait_cnt - 1;
        end if;
        if (axi_master_state(0) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4) and (axi_master_state(4) = '0' and axi_master_state(5) = '0' and axi_master_state(1) = '0')) then    -- send reading_addr_fifo_addr
          READ_DATA_FSM_PS <= ADDR_READ_RD;
        end if;
        axi_if_req <= '1';
        axi_if_req <= '1';
        if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
          gnt_catch <= '1';
        end if;

      when ADDR_READ_RD =>
        READ_DATA_FSM_PS <= ADDR_READ_WAIT;
        gnt_catch <= '1';

      when ADDR_LOAD =>
          if (axi_master_state(0) = '1') then
            READ_DATA_FSM_PS <= SLICES_HEADER_RD;
            axi_if_req <= '1';
            axi_wait_cnt <= MAX_AXI_GRANT_WAIT;
          elsif (timeout_cnt = 0) then -- error end
            READ_DATA_FSM_PS <= WAIT4DONE;
          end if;

      when ADDR_CALC =>
        READ_DATA_FSM_PS <= ADDR_LOAD;

      when SLICES_READ_RD =>
        READ_DATA_FSM_PS <= SLICES_READ_WAIT;
        axi_if_req <= '1';
        gnt_catch <= '1';

      when SLICES_READ_WAIT =>
        if (burst_cnt = 0) then         -- all received
          READ_DATA_FSM_PS <= WAIT4DONE;
        elsif (timeout_cnt = 0) then -- error end
          READ_DATA_FSM_PS <= WAIT4DONE;
        elsif (requested_words_cnt >= words_in_bundle) then -- ?!
          READ_DATA_FSM_PS <= WAIT4DONE;
        end if;
        axi_if_req <= '1';
        gnt_catch <= '1';

      when ADDR_READ_WAIT =>
        if (start_address_ready) then -- RAW start address saved, checked and synced
          if (axi_master_state(0) = '1') then
            READ_DATA_FSM_PS <= SLICES_HEADER_RD;
            axi_if_req <= '1';
            axi_wait_cnt <= MAX_AXI_GRANT_WAIT;
          end if;
        elsif (timeout_cnt = 0) then -- error end
          READ_DATA_FSM_PS <= WAIT4DONE;
        end if;
        gnt_catch <= '1';

      when SLICES_HEADER_RD =>
        if (axi_wait_cnt /= 0) then
          axi_wait_cnt <= axi_wait_cnt - 1;
        end if;
        if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4) and (axi_master_state(4) = '0' and axi_master_state(5) = '0' and axi_master_state(1) = '0')) then
          READ_DATA_FSM_PS <= SLICES_HEADER_WAIT;
        end if;
        axi_if_req <= '1';
        if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
          gnt_catch <= '1';
        end if;

      when SLICES_HEADER_WAIT =>
        if (ready_read_data_128m_r = '1') then
          READ_DATA_FSM_PS <= READ_IDLE;
        elsif (timeout_cnt = 0) then -- error end
          READ_DATA_FSM_PS <= WAIT4DONE;
        end if;
        gnt_catch <= '1';

      when WAIT4DONE =>
        if (tx_completed) then          -- normal end
          READ_DATA_FSM_PS <= READ_IDLE;
        elsif (timeout_cnt = 0) then -- error end
          assert (tx_completed) report "Error: DDR read timeout" severity ERROR;
          READ_DATA_FSM_PS <= IDLE;
        end if;
      when others =>
        READ_DATA_FSM_PS <= IDLE;
    end case;



      -- Default Assignment To Internals
      wait_data_done_cnt <= 63;

      inc_raw_rd_vec <= (inc_raw_rd_vec(1 downto 0) & '0');
      inc_ev_rd_vec <= (inc_ev_rd_vec(1 downto 0) & '0');
      if (inc_ev_rd_vec /= "000") then
        inc_ev_rd_128m <= '1';          -- pulse for @50MHz domain
      else
        inc_ev_rd_128m <= '0';
      end if;
      if (inc_raw_rd_vec /= "000") then
        inc_raw_rd_128m <= '1';         -- pulse for @50MHz domain
      else
        inc_raw_rd_128m <= '0';
      end if;

      -- Combined Actions
      case READ_DATA_FSM_PS is
        when READ_IDLE =>
          if (REGULAR_REQ_PULSE = '1') then
            new_reading_begin <= TRUE;   -- true, if set start address
            inc_raw_rd_vec <= "111";
          elsif (EVOLVING_REQ_PULSE = '1') then
            new_reading_begin <= TRUE;   -- true, if set start address
            inc_ev_rd_vec <= "111";
          end if;
        when SLICES_HEADER_WAIT =>
          -- if (axi_rdata_valid_r = '1' and header_received_128m) then -- 10/01/2017
          if (ready_read_data_128m = '1') then
            new_reading_begin <= FALSE;  -- header OK , go read data
          end if;
          if (wait_data_done_cnt /= 0) then -- !debug
            wait_data_done_cnt <= wait_data_done_cnt - 1;
          end if;
        when WAIT4DONE | SLICES_READ_WAIT | ADDR_READ_WAIT | ADDR_LOAD =>
          if (axi_master_state(0) = '1' and wait_data_done_cnt /= 0) then -- !debug: 13/01/2020
            wait_data_done_cnt <= wait_data_done_cnt - 1;
          end if;
          if (timeout_cnt = 0) then -- !debug: 15/08/2018  error end
            new_reading_begin <= FALSE;  -- can't start read: not received start address or header
          end if;
        when others =>
          null;
      end case;
    end if;
  end process read_data_fsm_clocked_proc;


  -- -- 10/07/2017 ECC FIFO: 2Kx32 dual-clock, mixed_widths
  -- ecc_fifo : ecc_fifo_2k_mixed
  --   port map (
  --     wr_clk        => TOP_CLK_MEM_128M,
  --     wr_rst        => "not"(RESET_128),
  --     rd_clk        => CLK_40M,
  --     rd_rst        => "not"(RESET_40),
  --     din           => axi_rdata_r,
  --     wr_en         => ecc_fifo_wrreq,
  --     rd_en         => ecc_fifo_rdreq,
  --     dout          => ecc_fifo_q,
  --     full          => ecc_fifo_wrfull,
  --     overflow      => open,
  --     empty         => ecc_fifo_rdempty,
  --     underflow     => open,
  --     rd_data_count => ecc_fifo_rdusedw,
  --     wr_data_count => ecc_fifo_wrusedw
  --   );


  -- wrreq to DCFIFO. Only data
  ecc_fifo_wrreq <= axi_rdata_valid_r when
              ((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT
               or READ_DATA_FSM_PS = WAIT4DONE) and requested_packetwords_cnt >= reading_size_128m) -- !debug: 11/07/2017
              else '0';


  sync_40 : process (CLK_50Mhz, RESET_40) is
  begin  -- process sync_40
    if RESET_40 = '0' then               -- asynchronous reset (active low)
      ecc_error_injection_cmd_40m <= (others => '0');
      ecc_error_injection_cmd_40m_r <= (others => '0');
      new_reading_begin_40m <= FALSE;
      new_reading_begin_40m_r <= FALSE;
      -- evolving_reading_40m <= FALSE;
      h_a_received_40m <= FALSE;
      h_a_received_40m_r <= FALSE;
      read_ecc_error_addr_cnt <= (others => '0');
      READ_ECC_ERROR_ADDR <= (others => '0');
      fifo_with_data_sync2eccout <= '1';
      dummy_ecc_data_out <= (others => '0');   -- 08/01/2017
      header_received_r0_40m <= FALSE;
      header_received_40m <= FALSE;
      DDR_DRIVER_HEADER_READY <= '0';
      q_128to40m_r <= (others => '0');
      -- requested_packetwords_cnt_40m <= 0;
      ev_data_addr_offset_40m <= (others => '0');
      read_fsm_error_40m_0 <= '0';
      read_fsm_error_40m <= '0';
      next_req_ready_M <= '0';
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then  -- rising clock edge

      ev_data_addr_offset_40m <= ev_data_addr_offset; -- 24/12/2017

      -- Force ECC errors, used in memory test
      if (ecc_error_injection_cmd_r = ECC_ERROR_INJECTION_CMD) then -- cmd stable
        ecc_error_injection_cmd_40m <= ECC_ERROR_INJECTION_CMD;       -- 64MHz to 40MHz
      end if;
      ecc_error_injection_cmd_40m_r <= ecc_error_injection_cmd_40m;

      new_reading_begin_40m <=
        (new_reading_begin_vec(2) = '1'); -- !debug: 24/12/2017
      new_reading_begin_40m_r <= new_reading_begin_40m;

      -- evolving_reading_40m <= evolving_reading; -- 128MHz to 40MHz

      h_a_received_40m <= (rdreq_h_a_fifo = '1'); -- FIFO not empty and header_received_40m
      h_a_received_40m_r <= h_a_received_40m;     -- data from FIFO ready

      -- ECC error address counter
      if (evolving_reading_40m = TRUE and FIFO_SEL_FSM_PS = HEADER_SAVED) then
        read_ecc_error_addr_cnt <= ev_data_addr_offset_40m; -- EV reading start address
      elsif (FIFO_SEL_FSM_PS = ADDR_SAVED) then
        read_ecc_error_addr_cnt <= start_addr_reg_40m; -- RAW reading start address
      elsif (ecc_fifo_rdreq = '1') then
          read_ecc_error_addr_cnt <= read_ecc_error_addr_cnt + 1; -- relative to reading start address
      end if;

      if (ecc_error) then
        READ_ECC_ERROR_ADDR <= read_ecc_error_addr_cnt;  -- 40Mhz
      end if;

      if (dec_fifo_rdempty = '0') then     -- !debug: 17/09/2018 was ecc_fifo_rdempty and no ECC_FIFO_CHECK, ECC_FIFO_CLR states
        fifo_with_data_sync2eccout <= '1'; -- delayed FIFO_EMPTY
      else
        fifo_with_data_sync2eccout <= '0';
      end if;

      -- !debug: 05/09/2018 uses when skipped ECC check or when wrong header
      read_fsm_error_40m_0 <= read_fsm_error_128m_dst;  -- change by Dalit 19/3/2024 timing issue solving
      if (FIFO_SEL_FSM_PS /= READING_WAIT) then
        read_fsm_error_40m <= read_fsm_error_40m_0;
      end if;
      if (read_fsm_error_40m = '1') then
        dummy_ecc_data_out <= X"EFEFEFEFEFEFEFEF";
      else
        dummy_ecc_data_out <= ecc_data_in_masked;
      end if;

      header_received_r0_40m <= header_received_128m; -- 10/01/2017 sync long pulse to 40MHz
      header_received_40m <= header_received_r0_40m;


      -- if (check_header = '1') then
      --   DDR_DRIVER_HEADER_READY <= '1';
      -- elsif (FIFO_SEL_FSM_PS = READING_WAIT and not header_received_40m) then
      --   DDR_DRIVER_HEADER_READY <= '0';
      -- end if;
      if (FIFO_SEL_FSM_PS = HEADER_WAIT or FIFO_SEL_FSM_PS = HEADER_SAVE_PULSE or FIFO_SEL_FSM_PS = HEADER_SAVED) then -- !debug: 15/01/2018
        DDR_DRIVER_HEADER_READY <= '0';
      else
        DDR_DRIVER_HEADER_READY <= '1';
      end if;

      q_128to40m_r <= q_128to40m;

      -- requested_packetwords_cnt_40m <= requested_packetwords_cnt;

      if (FIFO_SEL_FSM_PS = READING_WAIT) then
        next_req_ready_M <= '1';        -- enable next reading request from CDM
      else
        next_req_ready_M <= '0';
      end if;

    end if;
  end process sync_40;

  evolving_reading_src <= '1' when (evolving_reading) else '0';
  evolving_reading_40m <= (evolving_reading_dst = '1');

  xpm_cdc_single_2 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => evolving_reading_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => evolving_reading_src  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  xpm_cdc_single_7 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => READ_DATA_FSM_IDLE,   -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => read_data_fsm_idle_ui_clk  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  xpm_hand_simple_2: xpm_hand_simple
    generic map (
      SLOW2FAST => FALSE,
      WIDTH     => 13)
    port map (
      rst_n    => ddr3_if_rst_n,
      slow_clk => CLK_50Mhz,
      fast_clk => ui_clk,
      src_in   => std_logic_vector(to_unsigned(requested_packetwords_cnt, 13)),
      dest_out => requested_packetwords_cnt_dest
    );

  requested_packetwords_cnt_40m <= to_integer(unsigned(requested_packetwords_cnt_dest));

  DDR_DRIVER_HEADER_BUS <= module_raw_header; -- 22/02/2017

  read_ecc_error_chipnum_i <= X"F" when (ecc_error_location = 127) else X"0"; -- 0 - 1st chip


  sync_64m_pr : process (RESET_I, CLK_50Mhz) is
  begin  -- process sync_64m_pr
    if RESET_I = '0' then

      READ_FIFO_OVERFLOW     <= '0';
      read_fifo_overflow_r   <= '0';
      READ_FSM_ERROR         <= '0';
      READ_ECC_ERROR_CHIPNUM <= (others => '1'); -- if X"F" - not detected single error
      READ_FIFO_NOTEMPTY     <= '0';
      ecc_double_error_64m <= FALSE;
      ecc_error_64m <= FALSE;
      ECC_ERROR_MASK <= (others => '0');
      -- inc_raw_rd_counter_64m <= FALSE;
      -- inc_ev_rd_counter_64m <= FALSE;
      raw_rd_counter_cnt <= (others => '0');
      ev_rd_counter_cnt <= (others => '0');
      ecc_error_injection_cmd_r <= (others => '0');
      read_fifo_space_64m <= (others => '0');
      READ_FIFO_SPACE <= (others => '0');
      inc_raw_rd_vec_64m <= (others => '0');
      inc_ev_rd_vec_64m <=  (others => '0');
      fifo4k_full_50m <= '0';
      regular_req_pulse_64m <= '0';
      evolving_req_pulse_64m <= '0';
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then  -- rising clock edge

      fifo4k_full_50m <= fifo4k_full_128m;
      if (fifo4k_full_50m = '1') then    -- data FIFO full
        read_fifo_overflow_r <= '1';  -- sticky errors, need reset for clear
      end if;

      READ_FIFO_OVERFLOW <= read_fifo_overflow_r;

      READ_FSM_ERROR     <= read_fsm_error_40m_0 or pointer_error_dst or buffer_rd_addr_error_dst; -- change by Dalit 19/3/2024 timing issue solving

      if (ecc_error) then
        READ_ECC_ERROR_CHIPNUM <= read_ecc_error_chipnum_i; -- 40Mhz to 64Mhz
      end if;

      ecc_error_64m <= ecc_error; -- 40Mhz to 64Mhz

      -- ECC errors won't be while changing important registers.
      if(ecc_double_error) then
      	ecc_double_error_64m <= ecc_double_error; -- 40Mhz to 64Mhz
      else
      	ecc_double_error_64m <= FALSE;
      end if;

      regular_req_pulse_64m <= REGULAR_REQ_PULSE;
      evolving_req_pulse_64m <= EVOLVING_REQ_PULSE;
      if (fifo4k_empty = '0' and (regular_req_pulse_64m = '1' or evolving_req_pulse_64m = '1')) then
        READ_FIFO_NOTEMPTY <= '1';
      else
        READ_FIFO_NOTEMPTY <= '0';
      end if;

      assert not(fifo4k_empty = '0' and (regular_req_pulse_64m = '1' or evolving_req_pulse_64m = '1'))
        report "Error: Reading request, when previous request not completed, FIFO not empty" severity ERROR;


      ECC_ERROR_MASK <= ecc_error_mask_i;

      inc_raw_rd_vec_64m <= inc_raw_rd_vec_64m(1 downto 0) & inc_raw_rd_128m;
      if (inc_raw_rd_vec_64m(2) = '0' and inc_raw_rd_vec_64m(1) = '1') then
        raw_rd_counter_cnt <= raw_rd_counter_cnt + 1;
      end if;

      inc_ev_rd_vec_64m <= inc_ev_rd_vec_64m(1 downto 0) & inc_ev_rd_128m;
      -- inc_ev_rd_counter_64m <= inc_ev_rd_128m;
      if (inc_ev_rd_vec_64m(2) = '0' and inc_ev_rd_vec_64m(1) = '1') then
        ev_rd_counter_cnt <= ev_rd_counter_cnt + 1;
      end if;

      ecc_error_injection_cmd_r <= ECC_ERROR_INJECTION_CMD;

      read_fifo_space_64m <= read_fifo_space_128m;  -- 128Mhz
      READ_FIFO_SPACE <= read_fifo_space_64m;

    end if;
  end process sync_64m_pr;


  -- 10/01/2017
  -- purpose: burst calc
  burst_calc_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then
      saved_burst_size <= 0;
      burst_cnt <= 0;
    elsif ui_clk'EVENT and ui_clk = '1' then

      if (READ_DATA_FSM_PS = ADDR_READ_WAIT or READ_DATA_FSM_PS = ADDR_LOAD) then -- next state TX2DATA_BUF_HEADER
        saved_burst_size <= HEADER_NUM_DWORDS;
        burst_cnt <= HEADER_NUM_DWORDS;
      elsif (READ_DATA_FSM_PS = SLICES_WAIT4GRANT) then -- !debug: 26/01/2017
        saved_burst_size <= words_in_bundle;
        burst_cnt <= words_in_bundle;
      elsif (READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT) then -- !debug: 11/01/2017  or READ_DATA_FSM_PS = SLICES_HEADER_WAIT
                                                                                            -- !debug: 26/02/2017
        -- value of saved_burst_size preserved
        if (burst_cnt /= 0 and axi_rdata_valid_r = '1') then
          burst_cnt <= burst_cnt - 1;
        end if;
      elsif (READ_DATA_FSM_PS /= SLICES_READ_WAIT) then -- !debug: 23/02/2017
        saved_burst_size <= 0;
        burst_cnt <= 0;
      end if;

    end if;
  end process burst_calc_pr;


  ------------------------------------------------------------------------------
  -- 24/01/2017 ECC Decoder
  ------------------------------------------------------------------------------

  check_bits_in <= ecc_fifo_q;

  check_bits_in_masked <= std_logic_vector(unsigned(check_bits_in) xor error_mask(71 downto 64));


  dec_packet_pr: process (CLK_50Mhz, RESET_40) is
  begin  -- process dec_packet_pr
    if (RESET_40 = '0') then               -- asynchronous reset (active low)
      dec_fifo_rdreq <= '0';
      -- dec_fifo_data <= (others => '0');
      -- packet_dec_word_cnt <= 0;
      mod4_cnt <= 0;
      -- dec_fifo_rdreq_en <= '0';
      -- dec_fifo_wrreq <= '0';
      packet_size_sig <= 2**14;         -- unknown, then when init uses MAX value
      check_header_cnt <= 0;
      pattern_sig <= (others => '0');
      pattern_sig_swapped <= (others => '0');
    elsif (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge

      -- if (requested_packetwords_cnt_40m >= reading_size_40m) then
      --   if (ecc_fifo_rdempty = '0' and FIFO_SEL_FSM_PS = DATA_ECC_CHECK) then
      --     if (packet_dec_word_cnt < packet_size_sig) then -- data, but not check_header
      --       dec_fifo_rdreq <= '1';
      --       packet_dec_word_cnt <= packet_dec_word_cnt + 2;  -- words readed !debug: 12/07/2017 + 2 because 2x DW in FIFO read side
      --     -- elsif (dec_fifo_rdreq_en = '0' and unsigned(ecc_fifo_rdusedw) = 1) then -- !debug: 08/03/2017 get last word from ECC FIFO
      --     --   dec_fifo_rdreq <= '1';
      --     else
      --       dec_fifo_rdreq <= '0';
      --     end if;
      --   else
      --     dec_fifo_rdreq <= '0';
      --   end if;
      -- else
      --   dec_fifo_rdreq <= '0';
      --   packet_dec_word_cnt <= 0;
      -- end if;

      -- receive ECC words
      if (new_reading_begin_40m) then
        mod4_cnt <= 0;
      elsif (FIFO_SEL_FSM_PS = HEADER_ECC_CHECK and rd_data_ready = '1') then -- !debug: 12/07/2017
        mod4_cnt <= (mod4_cnt + 1) mod 4;
      end if;

      -- if ((packet_dec_word_cnt >= packet_size_sig and check_header_cnt = HEADER_NUM_DWORDS/2) and
      --     packet_dec_word_cnt <= (packet_size_sig + packet_size_sig/2 + 1)) then -- !debug: 13/07/2017 was    and requested_packetwords_cnt_40m >= reading_size_40m
      --   dec_fifo_rdreq_en <= '1';
      -- else
      --   dec_fifo_rdreq_en <= '0';
      -- end if;

      if (FIFO_SEL_FSM_PS = ECC_CONNECTED) then -- !debug: 16/07/2017
        check_header_cnt <= 0;
      elsif (FIFO_SEL_FSM_PS = HEADER_ECC_CHECK and check_header_cnt < HEADER_NUM_DWORDS/2) then
        check_header_cnt <= check_header_cnt + 1;
      end if;

      if (new_reading_begin_40m) then
        packet_size_sig <= 2**14;                 -- max, when init
      else
        if (evolving_reading_40m) then -- expected local header from DDR controller
          packet_size_sig <= reading_size_40m;
        else
          packet_size_sig <= reading_size_40m;
        end if;
      end if;

      -- !debug: 16/09/2018 send header in data only for debug - remove
      pattern_sig <= X"1234FEDC00" & module_raw_header(23 downto 0);
      if (FIFO_SEL_FSM_PS = HEADER_SAVED) then
        pattern_sig_swapped <= pattern_sig(7 downto 0) & pattern_sig(15 downto 8) &
                               pattern_sig(23 downto 16) & pattern_sig(31 downto 24) &
                               pattern_sig(32+7 downto 32+0) & pattern_sig(32+15 downto 32+8) &
                               pattern_sig(32+23 downto 32+16) & pattern_sig(32+31 downto 32+24);
      end if;

    end if;
  end process dec_packet_pr;


  check_header <= '1' when (FIFO_SEL_FSM_PS = HEADER_ECC_CHECK and check_header_cnt < HEADER_NUM_DWORDS/2) else '0';

  rd_data_ready <= dec_fifo_rdreq or check_header;      -- !debug: 12/07/2017
  ecc_fifo_rdreq <= dec_fifo_rdreq or check_header or (dec_fifo_rdempty and not ecc_fifo_rdempty); -- !debug: 12/07/201

  -- RAW data buffer
  -- 11/07/2023
  fifo_dc_2k_32_1 : fifo_dc_2k_32
    port map (
      wr_clk        => ui_clk,
      wr_rst        => "not"(ddr3_if_rst_n),
      rd_clk        => CLK_50Mhz,
      rd_rst        => "not"(RESET_40),
      din           => axi_rdata_r,
      wr_en         => fifo4k_wr_en,
      rd_en         => fifo4k_rd_en,
      dout          => fifo4k_dout,
      full          => fifo4k_full,
      empty         => fifo4k_empty,
      valid         => fifo4k_valid,    -- 29/05/2024
      rd_data_count => fifo4k_rd_data_count,
      wr_data_count => fifo4k_wr_data_count
    );

  fifo4k_wr_en <= axi_rdata_valid_r when
                  (READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT or READ_DATA_FSM_PS = WAIT4DONE or
                   READ_DATA_FSM_PS = SLICES_HEADER_WAIT) else '0'; -- !debug: 11/07/2023
  fifo4k_rd_en <= DDR_DRIVER_RD;
  DDR_DRIVER_FIFO_EMPTY <= fifo4k_empty; -- '1' when (unsigned(fifo4k_rd_data_count) < 2) else '0';   -- !debug: 29/05/2024 was  fifo4k_empty
  DDR_DRIVER_DOUT <= fifo4k_dout;
  -- DDR_DRIVER_RD_READY <= '1' when (FIFO_SEL_FSM_PS = DATA_CONNECTED and requested_packetwords_cnt_40m >= reading_size_40m) else '0'; -- note: read from DDR3 faster, then TX to CDM  !debug: 22/10/2023 was reading_size_40m / 2
  DDR_DRIVER_RD_READY <= '1' when (FIFO_SEL_FSM_PS = READING_WAIT and unsigned(fifo4k_rd_data_count) >= reading_size_40m) else '0'; -- note: read from DDR3 faster, then TX to CDM  !debug: 13/12/2023 was reading_size_40m / 2, alo was short pulse
  DDR_DRIVER_RD_VALID <= fifo4k_valid;
  MEM_BUF_NUM_OF_SLICES <= std_logic_vector(to_unsigned(slices_num,7)); -- 21/04/2024

  -- Save RAW data from dcfifo_a to temporary 64bit word data buffer (PACKET_SIZE), then
  -- read ECC data from dcfifo_a (1:4 read rate, because 4 ECC in DW)
  --
  -- -- data FIFO for ECC calc, dual-clock mixed_widths
  -- dec_fifo : dec_fifo_2k_mixed
  --   port map (
  --     wr_clk        => TOP_CLK_MEM_128M,
  --     wr_rst        => "not"(RESET_128),
  --     rd_clk        => CLK_40M,
  --     rd_rst        => "not"(RESET_40),
  --     din           => axi_rdata_r,
  --     wr_en         => dec_fifo_wrreq,
  --     rd_en         => dec_fifo_rdreq,
  --     dout          => dec_fifo_q,
  --     full          => dec_fifo_wrfull,
  --     empty         => dec_fifo_rdempty,
  --     rd_data_count => dec_fifo_rdusedw,
  --     wr_data_count => dec_fifo_wrusedw
  --   );


  -- dec_fifo_wrreq <= axi_rdata_valid_r when
  --             ((READ_DATA_FSM_PS = SLICES_READ_RD or READ_DATA_FSM_PS = SLICES_READ_WAIT
  --              or READ_DATA_FSM_PS = WAIT4DONE) and requested_packetwords_cnt < reading_size_128m) -- !debug: 11/07/2017
  --             else '0';

  -- dual_buf_pr: process (CLK_40M, RESET_40) is
  -- begin  -- process dual_buf_pr
  --   if (RESET_40 = '0') then            -- asynchronous reset (active low)
  --     fifo_dual_b1_wrreq <= '0';
  --     fifo_dual_b2_wrreq <= '0';
  --     dual_buffer_rd_sel <= '0';
  --     dual_buffer_rd_sel_0 <= '0';
  --   elsif (CLK_40M'event and CLK_40M = '1') then  -- rising clock edge
  --
  --     -- write to dual buffer
  --     if (dual_buffer_wr_sel = '0') then
  --       fifo_dual_b1_wrreq <= fifo_dual_b_wrreq_i;
  --       fifo_dual_b2_wrreq <= '0';
  --     else
  --       fifo_dual_b1_wrreq <= '0';
  --       fifo_dual_b2_wrreq <= fifo_dual_b_wrreq_i;
  --     end if;
  --
  --     -- 10/01/2018 read from dual-buffer
  --     if (fifo_dual_b1_empty = '1' and fifo_dual_b2_empty = '1') then
  --       dual_buffer_rd_sel_0 <= '0';
  --     elsif (fifo_dual_b1_empty = '0' and fifo_dual_b2_empty = '1') then
  --       dual_buffer_rd_sel_0 <= '0';
  --     elsif (fifo_dual_b1_empty = '1' and fifo_dual_b2_empty = '0') then
  --       dual_buffer_rd_sel_0 <= '1';
  --     else
  --       null;                           -- continue read from current buffer
  --     end if;
  --     dual_buffer_rd_sel <= dual_buffer_rd_sel_0;
  --
  --   end if;
  -- end process dual_buf_pr;


  -- fifo_dual_b1_rdreq <= DDR_DRIVER_RD when (dual_buffer_rd_sel = '0') else '0';
  -- fifo_dual_b2_rdreq <= DDR_DRIVER_RD when (dual_buffer_rd_sel = '1') else '0';

  RAW_RD_COUNTER <= std_logic_vector(raw_rd_counter_cnt);
  EV_RD_COUNTER <= std_logic_vector(ev_rd_counter_cnt);

  ECC_ERROR_INTERNAL <= ecc_error_64m;
  ECC_DOUBLE_ERROR_INTERNAL <= ecc_double_error_64m;

  READ_POINTER_ERROR <= pointer_error_dst;
  READ_BUFFER_ADDR_ERROR <= buffer_rd_addr_error_dst;
  
  assert (timeout_cnt /= 0) report "Read block: header timeout!!!" severity FAILURE;


  DDR_READ_TP(0) <= '1' when (wait_data_done_cnt = 0) else '0';
  DDR_READ_TP(1) <= '1' when fifo_almost_full else '0';  -- !TODO: 21/01/2020 add to errors
  DDR_READ_TP(2) <= '1' when (timeout_cnt = 0) else '0'; -- LOCAL_READY_R_ECC;
--  DDR_READ_TP(3) <= '1' when header_error_reg /= (header_error_reg'RANGE => '0') else '0';
--  DDR_READ_TP(4) <= header_error;
  DDR_READ_TP( 4 downto 3 ) <= ( others => '0' );
  DDR_READ_TP(5) <= '1' when  (ecc_data_out /= (ecc_data_out'REVERSE_RANGE => '0') and
                               fifo_with_data_sync2eccout = '1') else '0'; -- find error in Periph4,
                                                                       -- check with unconnected
                                                                       -- TMC and without test pattern
  DDR_READ_TP(6) <= '0';
  DDR_READ_TP(7) <= '0'; -- '1' when (ecc_err_word_in_r(71 downto 64) /= ecc_err_word_out(71 downto 64))
                    -- or (ecc_check_bits_out = (ecc_check_bits_out'REVERSE_RANGE => '0'))
                    -- or (ecc_data_out = (ecc_data_out'REVERSE_RANGE => '0')) else '0';

  DDR_READ_TP(8) <= pointer_error;
  DDR_READ_TP(9) <= buffer_rd_addr_error;
  DDR_READ_TP(10) <= '0';

  DDR_READ_TP( 15 downto 11 ) <= ( others => '0' );


  --add by Dalit 19/3/2024 timing issue solving------

    xpm_cdc_single_4 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => pointer_error_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => pointer_error  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

	  xpm_cdc_single_5 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => read_fsm_error_128m_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => read_fsm_error_128m  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

	    xpm_cdc_single_6 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => buffer_rd_addr_error_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => buffer_rd_addr_error  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );


  NEW_PACKET2TX <= '1' when (FIFO_SEL_FSM_PS = HEADER_SAVED and slices_num_valid) else '0';    -- 28/05/2024


end read_ddr3_rd_a;
