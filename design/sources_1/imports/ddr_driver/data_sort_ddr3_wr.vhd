------------------------------------------------------------------------------
-- Title      : FQ data write
-- Project    : DDR3 control (Trident project)
-------------------------------------------------------------------------------
-- File       : data_sort_ddr3_wr.vhd
-- Author     :   <ilq00431@ILQHFAATC1DT213> Shinderman Eugene
-- Company    : Philips Medical
-- Created    : 29/08/2005
-- Last update: 01/08/2024
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: accepts "reading" data and transmits them to DDR3 memory controller
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library xpm;
use xpm.vcomponents.all;

use work.tbuf_pack.all;
-- use work.ddr3_model_pack.all;


entity data_sort_ddr3_wr is
  port(
    RESET_I             : in std_logic;
    ddr3_if_rst_n           : in  std_logic; -- DDR3 clock domain
    CLK_50Mhz      : in std_logic;
    ui_clk              : in std_logic; -- DDR3 clock domain

    RAW_DATA_END_ADDR   : in  DDR3_ADDR_BUS_TYP;
    -- new_scan_begin : in boolean; -- added ports
    INIT_DONE_ALL_O         : in  std_logic; -- MIG: init_calib_complete
    IP50                : in std_logic; -- 22/10/2023

    -- Data and strobe from sorter block
    DATA_SORT_DOUT              : in std_logic_vector (31 downto 0);
    DATA_SORTER_DATA_EN         : in std_logic;  -- data strobe from sorter

    params_ready : in std_logic;  -- 20/09/2022
    tmb_header : in std_logic_vector (31 downto 0); -- 20/09/2022
    tmb_header_rd : out std_logic;
    raw_wr_ptr_addr : in DDR3_ADDR_BUS_TYP;  -- !debug: 16/07/2023 was wr_ptr_num (WR reading index)
    num_of_slices : in std_logic_vector (6 downto 0); -- !debug: 08/02/2023 was [7..0]

    -- Buffer control and errors registers interface
    RAW_READING_ADDR_FIFO_ADDR : out DDR3_ADDR_BUS_TYP;  -- RAW WR PTR
    RAW_READING_RAW_DATA_ADDR  : out DDR3_ADDR_BUS_TYP;  -- RAW WR address
    RAW_FSM_ERROR              : out std_logic;
    RAW_FIFO_NOTEMPTY          : out std_logic;  -- rdempty='0' and new_reading_begin
    RAW_FIFO_OVERFLOW          : out std_logic;  -- FIFO in overflow state, wrfull='1'
    RAW_POINTER_ERROR          : out std_logic;
    RAW_WR_ADDR_ERROR_O        : out std_logic;
    RAW_WR_BURST_INCOMPLETE    : out std_logic;
    RAW_BAD_PACKET_SIZE        : out std_logic;

    -- AXI4 master interface:
    start_write      : out std_logic;
    burst_len        : out std_logic_vector(7 downto 0);
    fifo_axi_wdata   : out std_logic_vector(31 downto 0);
    fifo_wdata_valid : out std_logic;
    waddr_offset     : out std_logic_vector(29 downto 0);
    fifo_rd_en       : in  std_logic;
    master_axi_state : in  std_logic_vector(7 downto 0);  -- master_axi_state(1) - write in process (busy)
    axi_if_req       : out std_logic;   -- 14/01/2020
    gnt_catch        : out std_logic;   -- 01/11/2023
    fifo_near_overflow : out std_logic;   -- 04/07/2023 req. high priority from arbiter

    RAW_WR_COUNTER     : out std_logic_vector(31 downto 0);
    DATA_SORT_2_DDR_TP : out std_logic_vector (31 downto 0)
  );
end data_sort_ddr3_wr;


architecture ar of data_sort_ddr3_wr is

  -- Component Declarations
  -- FIFO !debug: 31/12/2019 was Altera FIFO with lpm_showahead          => "ON"
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


  signal wrreq_a, wrreq_fsm : std_logic;                     -- write to FIFO
  -- signal rdreq_a            : std_logic;
  signal rdempty_a,rdempty_a_dst, rdempty_a_20m : std_logic;                     -- FIFO empty   -- change by Dalit 19/3/2024 timing issue solving
  signal wrfull_a           : std_logic;                     -- FIFO full
  signal wrusedw_a          : std_logic_vector(8 downto 0);  --words in FIFO
  signal rdusedw_a          : std_logic_vector(8 downto 0);
  signal raw_data_addr, raw_data_addr_saved : DDR3_ADDR_BUS_TYP;  -- RAW_DATA memory address
  signal raw_data_addr_dest : std_logic_vector(31 downto 0);
  signal reading_addr_fifo_addr  : DDR3_ADDR_BUS_TYP;  -- READING_ADDRESS_FIFO memory address
  signal raw_wr_ptr_addr_dest : std_logic_vector(DDR3_ADDR_WIDTH-1 downto 0);
  signal new_scan_begin, new_reading_begin, new_reading_begin_r, new_reading_begin_ui_clk, new_reading_begin_ui_clk_r : boolean;
  signal new_reading_begin_src, new_reading_begin_dst : std_logic;
  signal ptr_address_from_header : std_logic_vector(31 downto 0) := (others => '0');

  type RAW_DATA_CTL_FSM_TYP is (IDLE, SET_PTR_PARAMS, TX2ADDR_PTR_BUF, SET_HEADER_PARAMS, TX2DATA_BUF_HEADER, SET_DATA_PARAMS, TX2DATA_BUF_DATA, WAIT4DONE); -- was SET_PARAMS
  signal RAW_CTL_FSM_PS           : RAW_DATA_CTL_FSM_TYP;


  type RAW_DATA_FSM_TYP is (WAIT4DATA, SYNC1, PUSH2ADDR_FIFO, WAIT4HEADER, DATA2HEADER, DATA2RAW_DATA, ECC_DATA_WAIT, ECC_DATA);

  signal RAW_DATA_FSM_PS                                                  : RAW_DATA_FSM_TYP;


  signal muxed_data, muxed_data_r                                         : std_logic_vector(31 downto 0);
  signal data_sort_dout_r, data_sort_dout_r2                              : std_logic_vector(31 downto 0);  -- effective rate 32MHz !!!
  -- signal ecc_data_in : std_logic_vector(63 downto 0);
  -- signal raw_ecc_data               : std_logic_vector(7 downto 0);

  -- signal wait_data_done_cnt       : natural range 15 downto 0;  -- !check it
  signal reading_data_done        : boolean;  -- when not transfer Reading data
  signal data_sorter_data_ready_r, data_sorter_data_ready_r2 : boolean;
  signal data_in_fifo             : boolean;
  signal init_done_all_64m         : unsigned(1 downto 0);
  signal initialization           : boolean; -- ES: header not received, new address not set

  signal raw_fifo_notempty_20m   : std_logic;
  signal inc_raw_wr_counter : boolean;  -- , inc_raw_wr_counter_r
  signal raw_wr_counter_cnt : unsigned(31 downto 0);

-- Trigger on error
  signal pointer_error, pointer_error_dst, pointer_error_20m 			: std_logic; -- change by Dalit 19/3/2024 timing issue solving
  signal raw_wr_addr_error,raw_wr_addr_error_dst, raw_wr_addr_error_20m	: std_logic; -- change by Dalit 19/3/2024 timing issue solving
  signal wr_burst_error,wr_burst_error_dst, wr_burst_error_20m, bad_packet_size, bad_num_of_slices, raw_wr_ptr_err	: std_logic := '0'; -- change by Dalit 19/3/2024 timing issue solving
  signal do_packet_size_comp : boolean;

  signal module_raw_header : std_logic_vector(32*HEADER_NUM_DWORDS - 1 downto 0); -- Nx 32bit words header, only for monitoring
  signal sorter_data_header : std_logic; -- only for monitoring
  signal tmb_header_rd_i : std_logic;

  signal header_dw_cnt         		: natural range 0 to HEADER_NUM_DWORDS - 1; -- when saved

  signal saved_burst_size, burst_cnt : natural range 0 to 127;
  signal start_new_burst, start_new_burst_r : boolean;

  -- signals for ECC encoder:
  -- signal ecc_data_in_even : std_logic;
  signal fifo_wr_cnt : natural range 0 to 2047;
  signal ecc2fifo       : std_logic;          -- select data to FIFO: packet data or ECC data
  -- signal ecc_wrreq      : std_logic;					 -- write to FIFO
  signal ecc_rdreq		: std_logic;				 -- read from FIFO
  -- signal ecc_rdempty	: std_logic;					 -- FIFO empty
  -- signal ecc_wrfull		: std_logic;					 -- FIFO full
  -- signal ecc_wrusedw    : std_logic_vector(8 downto 0);  --words in FIFO
  -- signal ecc_rdusedw    : std_logic_vector(8 downto 0);
  signal ecc_q          : std_logic_vector(31 downto 0);
  -- signal ecc_wrreq_en   : std_logic;					 -- write to FIFO
  -- signal ecc_pack_counter			: integer range 0 to 3;
  -- signal ecc_pack_register			: std_logic_vector(31 downto 0);

  -- constant PACKET_SIZE : natural := 2*4*10;  -- <2x DW for 64bit ECC input word> * <4x bytes ECC out for single ECC DW> * <10 times>
  signal packet_size_sig, calc_packet_size : natural range 0 to 4095;  -- packet_size_calc

  signal raw_fifo_overflow_i : std_logic;  -- FIFO in overflow state, wrfull='1'
  signal ecc_rd_debug_cnt : natural range 0 to 7;
  signal master_axi_state_r : std_logic; -- master_axi_state(0) - no WR/RD (ready)
  constant MAX_AXI_GRANT_WAIT : natural := 255;  -- max read burst time
  signal axi_wait_cnt : natural range 0 to MAX_AXI_GRANT_WAIT;

  -- 20/09/2022
  signal params_ready_r : std_logic;
  signal fsm_wait_cnt : natural range 0 to 255;
  signal raw_fsm_error_20m : std_logic;

  signal reading_number_temp : natural range 0 to 2**16;

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

  signal ip_ui_clk : std_logic;
  signal fq_num_of_slices_from_header_sampled : std_logic_vector (6 downto 0); -- only for simulation

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of reading_addr_fifo_addr, raw_wr_ptr_addr_dest, raw_wr_ptr_addr, ip_ui_clk, packet_size_sig, calc_packet_size, raw_wr_counter_cnt, data_in_fifo, bad_num_of_slices, raw_data_addr : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of RAW_DATA_FSM_PS, reading_addr_fifo_addr, raw_wr_ptr_addr_dest, raw_wr_ptr_addr, ip_ui_clk, packet_size_sig, calc_packet_size, raw_wr_counter_cnt, data_in_fifo, bad_num_of_slices, raw_data_addr : signal is "true";

begin


  new_scan_begin <= FALSE;              -- NU option

  data_in_fifo <= (unsigned(rdusedw_a) /= 0) when (not reading_data_done) else (unsigned(rdusedw_a) >= 2);
  -- fifo_near_overflow <= '1' when (unsigned(rdusedw_a(8 downto 7)) = "11") else '0'; -- 04/07/2023
  fifo_near_overflow <= '1' when (rdusedw_a(8) = '1') else '0'; -- 22/11/2023

  -- Sync to system clock.
  sync_pr : process (RESET_I, CLK_50Mhz) is
  begin  -- process sync_pr
    if RESET_I = '0' then
      init_done_all_64m <= (others => '0');
      raw_wr_counter_cnt <= (others => '0');
      RAW_FSM_ERROR <= '0';
      RAW_FIFO_OVERFLOW <= '0';
      -- inc_raw_wr_counter_r <= FALSE;
      RAW_FIFO_NOTEMPTY <= '0';
      -- RAW_READING_RAW_DATA_ADDR <= RAW_DATA_BASE_ADDR;
      calc_packet_size <= 0;
      bad_packet_size <= '0';
      raw_wr_ptr_err <= '0';
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      init_done_all_64m <= init_done_all_64m(0) & INIT_DONE_ALL_O;

      -- inc_raw_wr_counter_r <= inc_raw_wr_counter;

      if (inc_raw_wr_counter) then      --  and not inc_raw_wr_counter_r
        raw_wr_counter_cnt <= raw_wr_counter_cnt + 1;
      end if;

      RAW_FIFO_OVERFLOW <= raw_fifo_overflow_i;

      RAW_FIFO_NOTEMPTY <= raw_fifo_notempty_20m;

      -- RAW_READING_RAW_DATA_ADDR <= unsigned(raw_data_addr_dest(DDR3_ADDR_WIDTH-1 downto 0)); -- 08/10/2023

      pointer_error_20m <= pointer_error_dst;  -- change by Dalit 19/3/2024 timing issue solving
      raw_wr_addr_error_20m <= raw_wr_addr_error_dst;  -- change by Dalit 19/3/2024 timing issue solving
      wr_burst_error_20m <= wr_burst_error_dst;  -- change by Dalit 19/3/2024 timing issue solving

      if (RAW_DATA_FSM_PS = DATA2RAW_DATA) then
        if (unsigned(fq_num_of_slices_from_header_sampled) /= unsigned(num_of_slices)) then
          bad_num_of_slices <= '1';     -- !debug: 24/01/2024 possible false errors ?
        else
          bad_num_of_slices <= '0';
        end if;
      end if;

      calc_packet_size <= to_integer(unsigned(fq_num_of_slices_from_header_sampled) & "0000") + 32 + 1; -- data + header + pointer  !debug: 31/01/2024 was    num_of_slices
      if (do_packet_size_comp) then
        if (packet_size_sig /= calc_packet_size) then               -- size from input vs expected
          bad_packet_size <= '1';
        else
          bad_packet_size <= '0';
        end if;
      end if;

      if (RAW_DATA_FSM_PS = DATA2RAW_DATA) then
        if (resize(unsigned(ptr_address_from_header),raw_wr_ptr_addr'length) /= raw_wr_ptr_addr) then
          raw_wr_ptr_err <= '1';
        else
          raw_wr_ptr_err <= '0';
        end if;
      end if;

      RAW_FSM_ERROR <= raw_fsm_error_20m or pointer_error_20m or raw_wr_addr_error_20m or wr_burst_error_20m or bad_packet_size or raw_wr_ptr_err;

    end if;
  end process sync_pr;


  RAW_READING_RAW_DATA_ADDR <= unsigned(raw_data_addr_saved(DDR3_ADDR_WIDTH-1 downto 0));
  RAW_WR_COUNTER <= std_logic_vector(raw_wr_counter_cnt); -- reading counter (not Reading Number from scan header)
  RAW_POINTER_ERROR <= pointer_error_20m;
  RAW_WR_ADDR_ERROR_O <= raw_wr_addr_error_20m;
  RAW_WR_BURST_INCOMPLETE <= wr_burst_error_20m;
  RAW_BAD_PACKET_SIZE <= bad_packet_size;
    
  sync20_pr : process (RESET_I, CLK_50Mhz) is
  begin
    if RESET_I = '0' then
      params_ready_r <= '0';
      raw_fifo_notempty_20m    <= '0';
      muxed_data_r      <= (others => '0');
      new_reading_begin <= FALSE;
      new_reading_begin_r <= FALSE;
      rdempty_a_20m <= '0';
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      params_ready_r <= params_ready;
      rdempty_a_20m <= rdempty_a_dst;

      -- @SYSTEM_CLK64 To registers:
      -- !debug: 29/12/2019 no arbiter (1*)

      if (rdempty_a_20m = '0' and new_reading_begin and not new_reading_begin_r) then
        raw_fifo_notempty_20m <= '1';               -- sticky error, when new reading arrives and FIFO not empty
      end if;

      -- data/addr:
      if (ecc2fifo = '1') then          -- !TODO: 27/06/2023 NU, remove
        muxed_data_r <= ecc_q;          -- mux ECC to FIFO
      elsif (RAW_DATA_FSM_PS = DATA2HEADER or RAW_DATA_FSM_PS = PUSH2ADDR_FIFO or RAW_DATA_FSM_PS = WAIT4HEADER) then
        muxed_data_r <= tmb_header;
      else
        muxed_data_r <= muxed_data;       -- pipe
      end if;

      new_reading_begin <= (params_ready_r = '0' and params_ready = '1') and init_done_all_64m(1) = '1';
      new_reading_begin_r <= new_reading_begin;

      reading_number_temp <= to_integer(unsigned(module_raw_header(16*8+15 downto 16*8))); -- W9

    end if;
  end process sync20_pr;


  sync_ui_clk_pr: process (ui_clk) is
  begin  -- process sync_ui_clk_pr
    if (ui_clk'event and ui_clk = '1') then  -- rising clock edge

      -- new_reading_begin_ui_clk <= new_reading_begin;
      new_reading_begin_ui_clk <= (new_reading_begin_dst = '1');
      new_reading_begin_ui_clk_r <= new_reading_begin_ui_clk;

      ip_ui_clk <= IP50;                -- for LA

      if (RAW_CTL_FSM_PS = WAIT4DONE) then -- 23/01/2024
        if (burst_cnt /= 0 or fifo_rd_en = '1') then
          wr_burst_error <= '1';
        else
          wr_burst_error <= '0';
        end if;
      elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_DATA or RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER or RAW_CTL_FSM_PS = TX2ADDR_PTR_BUF) then
        if (fifo_rd_en = '1' and burst_cnt = 0) then
          wr_burst_error <= '1';
        else
          wr_burst_error <= '0';
        end if;
      end if;

    end if;
  end process sync_ui_clk_pr;

  new_reading_begin_src <= '1' when (new_reading_begin) else '0';

  xpm_cdc_single_inst : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => new_reading_begin_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => ui_clk,             -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => CLK_50Mhz,              -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => new_reading_begin_src   -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  -- purpose: RAW_DATA_FSM - write RAW data to FIFO
  raw_data_fsm_pr : process (RESET_I, CLK_50Mhz) is
  begin
    if RESET_I = '0' then
      RAW_DATA_FSM_PS    <= WAIT4DATA;
      raw_fifo_overflow_i <= '0';
      sorter_data_header <= '0';
      inc_raw_wr_counter <= FALSE;
      tmb_header_rd_i <= '0';
      fsm_wait_cnt <= 0;
      raw_fsm_error_20m <= '0';
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      inc_raw_wr_counter <= FALSE;
      tmb_header_rd_i <= '0';

      case RAW_DATA_FSM_PS is

        when WAIT4DATA =>
          if (wrfull_a = '0' and init_done_all_64m(1) = '1') then  -- 29/10/2023
            if (new_reading_begin and not new_reading_begin_r) then
              RAW_DATA_FSM_PS    <= SYNC1;                         -- requires for save address offset
              inc_raw_wr_counter <= TRUE;                          -- count reading number
              sorter_data_header <= '0';                           -- header updates
            elsif (data_sorter_data_ready_r2 and not initialization) then
              RAW_DATA_FSM_PS <= DATA2RAW_DATA;
            end if;
          end if;

        when SYNC1 =>
          RAW_DATA_FSM_PS <= PUSH2ADDR_FIFO;
          fsm_wait_cnt    <= 0;

        when PUSH2ADDR_FIFO =>
          RAW_DATA_FSM_PS <= WAIT4HEADER;
          fsm_wait_cnt    <= 1;

        when WAIT4HEADER =>
          if (fsm_wait_cnt = 0) then
            RAW_DATA_FSM_PS <= DATA2HEADER;
          end if;
          if (fsm_wait_cnt /= 0) then
            fsm_wait_cnt <= fsm_wait_cnt - 1;
          end if;
          tmb_header_rd_i <= '1';

        when DATA2HEADER =>
          if (header_dw_cnt = 0) then
            RAW_DATA_FSM_PS    <= WAIT4DATA;
            sorter_data_header <= '1';                             -- header sample ready
          end if;
          if (header_dw_cnt < 2) then
            tmb_header_rd_i <= '0';
          else
            tmb_header_rd_i <= '1';
          end if;

        when DATA2RAW_DATA =>                                      -- write to FIFO
          -- if (not data_sorter_data_ready_r and data_sorter_data_ready_r2) then
          if (not data_sorter_data_ready_r2) then                  -- 28/06/2023
            RAW_DATA_FSM_PS <= ECC_DATA_WAIT;
          end if;

        when ECC_DATA_WAIT =>
          if (ecc2fifo = '1' and ecc_rdreq = '1') then
            RAW_DATA_FSM_PS <= ECC_DATA;
          elsif (ecc2fifo = '0') then                              -- 27/06/2023
            RAW_DATA_FSM_PS <= WAIT4DATA;
          end if;

        when ECC_DATA =>
          if (ecc_rdreq = '0') then
            RAW_DATA_FSM_PS <= WAIT4DATA;
          end if;

      end case;

      if (wrfull_a = '0' and init_done_all_64m(1) = '1') then
        raw_fsm_error_20m <= '0'; -- 26/10/2023 not hold error state
        raw_fifo_overflow_i <= '0'; -- 26/10/2023 not hold error state
      else
        -- Place for writing to Error register
        if (init_done_all_64m(1) = '1') then
          raw_fifo_overflow_i <= '1';     -- !check, when clear overflow state
          raw_fsm_error_20m <= '1';
          assert not(wrfull_a = '1' and rdempty_a_20m = '0') report "FIFO full !!!" severity ERROR;
        end if;
      end if;

    end if;
  end process raw_data_fsm_pr;


  tmb_header_rd <= tmb_header_rd_i;

  -- wrreq -------------------------------------------------------------------
  with RAW_DATA_FSM_PS select
    wrreq_fsm <=
    '1' when PUSH2ADDR_FIFO | DATA2RAW_DATA | DATA2HEADER | ECC_DATA,
    '0' when WAIT4DATA | SYNC1 | WAIT4HEADER | ECC_DATA_WAIT;

  wrreq_a <= wrreq_fsm;

  -- Data MUX: ---------------------------------------------------------------
  --    new_reading_begin,then
  --        1) next_address write into the READING_ADDRESS_FIFO memory
  --        2) header write into the RAW_DATA memory
  --        3) data slices  write into the RAW_DATA memory

  -- with RAW_DATA_FSM_PS select
  --   muxed_data <= std_logic_vector(resize(raw_data_addr_saved, 32)) when SYNC1, -- address
  --                 data_sort_dout_r2                 				 when others; -- data or header
  with RAW_DATA_FSM_PS select
    muxed_data <= raw_data_addr_dest when SYNC1, -- address
                  data_sort_dout_r2 when others; -- data or header

  xpm_hand_simple_2: xpm_hand_simple
    generic map (
      SLOW2FAST => FALSE,
      WIDTH     => 32)
    port map (
      rst_n    => ddr3_if_rst_n,
      slow_clk => CLK_50Mhz,
      fast_clk => ui_clk,
      src_in   => std_logic_vector(resize(raw_data_addr_saved, 32)),
      dest_out => raw_data_addr_dest
    );

  -- ??? time shift + data for ECC calculation
  -- Sample Sorter data:
  data_sort_sample_pr : process (RESET_I, CLK_50Mhz)
  begin  -- process data_sort_sample_pr
    if RESET_I = '0' then
      data_sort_dout_r <= (others => '0');
      data_sort_dout_r2 <= (others => '0');
      data_sorter_data_ready_r <= FALSE;
      data_sorter_data_ready_r2 <= FALSE;
      initialization       <= TRUE;
      header_dw_cnt        <= 0;
      module_raw_header    <= (others => '0');

    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      -- data_sorter_data_ready <= (DATA_SORTER_DATA_EN = '1');
      data_sort_dout_r2 <= data_sort_dout_r;
      data_sorter_data_ready_r2 <= data_sorter_data_ready_r;

      if (RAW_DATA_FSM_PS = DATA2HEADER and initialization) then
        module_raw_header(32*(HEADER_NUM_DWORDS-1-header_dw_cnt) + 31 downto 32*(HEADER_NUM_DWORDS-1-header_dw_cnt)) <= muxed_data_r;
      end if;

      if (RAW_DATA_FSM_PS = WAIT4HEADER) then
        initialization <= TRUE;
      elsif (RAW_DATA_FSM_PS = DATA2HEADER and header_dw_cnt = 0) then
        initialization <= FALSE;
      end if;

      if (DATA_SORTER_DATA_EN = '1' and init_done_all_64m(1) = '1') then  -- !check

        data_sort_dout_r <= DATA_SORT_DOUT;         -- piping the data in order to save data until old header is being updated
        data_sorter_data_ready_r <= TRUE;
      else
        data_sort_dout_r <= (others => '0');
        data_sorter_data_ready_r <= FALSE;
      end if;

      if (new_reading_begin and not new_reading_begin_r) then
        header_dw_cnt   <= HEADER_NUM_DWORDS - 1;
      elsif (header_dw_cnt /= 0) then
        if(RAW_DATA_FSM_PS = DATA2HEADER) then       -- edge condition for initialize: after reset there is no old header!!!
          header_dw_cnt <= header_dw_cnt - 1;
        end if;
      end if;

    end if;
  end process data_sort_sample_pr;


  -- purpose: burst calc
  burst_calc_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then
      saved_burst_size <= 0;
      start_new_burst <= FALSE;
      start_new_burst_r <= FALSE;
      burst_cnt <= 0;
    elsif (ui_clk'EVENT and ui_clk = '1') then

      -- start_new_burst
      if (RAW_CTL_FSM_PS = TX2ADDR_PTR_BUF) then
        if (master_axi_state(1) = '0' and master_axi_state(2) = '0' and master_axi_state(5) = '1') then
          start_new_burst <= TRUE;
        else
          start_new_burst <= FALSE;
        end if;
      elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER) then
        if (master_axi_state(1) = '0' and master_axi_state(2) = '0' and master_axi_state(5) = '1') then
          start_new_burst <= TRUE;
        else
          start_new_burst <= FALSE;
        end if;
      elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_DATA) then
        if (master_axi_state(1) = '0' and master_axi_state(2) = '0' and master_axi_state(5) = '1') then
          start_new_burst <= TRUE;
        else
          start_new_burst <= FALSE;
        end if;
      else
        start_new_burst <= FALSE;
      end if;

      start_new_burst_r <= start_new_burst;

      -- !debug: 29/12/2019 no arbiter (2*)
      if (RAW_CTL_FSM_PS = SET_PTR_PARAMS) then -- next state TX2ADDR_PTR_BUF
        saved_burst_size <= 1;
        burst_cnt <= 1;
      elsif (RAW_CTL_FSM_PS = SET_HEADER_PARAMS) then -- next state TX2DATA_BUF_HEADER
        saved_burst_size <= HEADER_NUM_DWORDS;
        burst_cnt <= HEADER_NUM_DWORDS;
      elsif (RAW_CTL_FSM_PS = SET_DATA_PARAMS) then -- next state TX2DATA_BUF_DATA
        if (rdusedw_a(5) = '1' or rdusedw_a(6) = '1' or rdusedw_a(7) = '1' or rdusedw_a(8) = '1') then     -- >= 32
          saved_burst_size <= 32;
          burst_cnt <= 32;
        elsif (rdusedw_a(4) = '1') then     -- >= 16
          saved_burst_size <= 16;
          burst_cnt <= 16;
        elsif (rdusedw_a(3) = '1') then     -- >= 8
          saved_burst_size <= 8;
          burst_cnt <= 8;
        elsif (rdusedw_a(2) = '1') then     -- >= 4
          saved_burst_size <= 4;
          burst_cnt <= 4;
        elsif (rdusedw_a(1) = '1') then     -- >= 2
          saved_burst_size <= 2;
          burst_cnt <= 2;
        elsif (rdusedw_a(0) = '1') then     -- >= 1
          saved_burst_size <= 1;
          burst_cnt <= 1;
        end if;
      elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_DATA or RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER or RAW_CTL_FSM_PS = TX2ADDR_PTR_BUF) then
        -- value of saved_burst_size preserved
        if (fifo_rd_en = '1' and burst_cnt /= 0) then
          burst_cnt <= burst_cnt - 1;
        end if;
      -- else
      --   saved_burst_size <= 0;          -- error ?!
      --   burst_cnt <= 0;
      end if;

      assert not(rdempty_a = '1' and fifo_rd_en = '1')
        report "FIFO empty when attempt to read from FIFO!!!" severity ERROR;

    end if;
  end process burst_calc_pr;


  -- rdreq_a <= fifo_rd_en;                -- 14/01/2020


  -- purpose: 10.11 RAW Data Address Generation
  raw_data_addr_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then
      raw_data_addr       <= RAW_DATA_BASE_ADDR;
      raw_data_addr_saved <= RAW_DATA_BASE_ADDR;
    elsif (ui_clk'event and ui_clk = '1') then

      if (new_scan_begin) then
        raw_data_addr       <= RAW_DATA_BASE_ADDR;
        raw_data_addr_saved <= RAW_DATA_BASE_ADDR;
      elsif ((new_reading_begin_ui_clk and not new_reading_begin_ui_clk_r) and INIT_DONE_ALL_O = '1') then

        if (raw_data_addr > (unsigned(RAW_DATA_END_ADDR) - 4096)) then      -- goto buffer begin address if no place for full reading (here byte address, then fifo_wr_cnt * 4)
                                                                            -- !debug: 01/08/2024 2048 -> 4096
          raw_data_addr_saved <= RAW_DATA_BASE_ADDR;
          raw_data_addr       <= RAW_DATA_BASE_ADDR;
        else
          raw_data_addr_saved <= raw_data_addr;                   -- when enter to SYNC1 state
                                                                  -- address must be stable
                                                                  -- for minimum 2 128MHz clocks period
        end if;


      -- !debug: 29/12/2019 no arbiter (3*)
      elsif ((RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER or RAW_CTL_FSM_PS = TX2DATA_BUF_DATA) and
             fifo_rd_en = '1' and burst_cnt = 1) then  -- write to RAW_DATA buffer
        raw_data_addr <= raw_data_addr + (saved_burst_size * 4); -- !debug: 15/01/2020
        -- raw_data_addr <= raw_data_addr + saved_burst_size; -- !debug: 12/07/2023
      end if;

    end if;
  end process raw_data_addr_pr;


  -- purpose: 10.11 READING_ADDRESS_FIFO address Generation
  reading_addr_fifo_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then

      reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR;

    elsif (ui_clk'EVENT and ui_clk = '1') then

      if (new_scan_begin) then
        reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR;
      -- !debug: 29/12/2019 no arbiter (4*)
      -- elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER and (not start_new_burst_r and start_new_burst)) then -- 02/01/2020
      elsif (RAW_CTL_FSM_PS = SET_PTR_PARAMS) then -- !debug: 03/10/2023
        if (reading_addr_fifo_addr = ADDR_FIFO_END_ADDR) then
          reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR;     -- address overflow
                                                             -- 28/09/2022 for Taichi this error, TMB must prevent this case
        else
          -- reading_addr_fifo_addr <= reading_addr_fifo_addr + 4;  -- +4 for increment
          -- reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR + (wr_ptr_num sll 2); -- 22/09/2022 for external index
          reading_addr_fifo_addr <= unsigned(raw_wr_ptr_addr_dest); -- !debug: 27/09/2023 was  raw_wr_ptr_addr; -- !debug: 12/07/2023 src @sys_clk
          -- reading_addr_fifo_addr <= ADDR_FIFO_BASE_ADDR; -- !debug: 19/10/2023 temporary constant
        end if;
      end if;

    end if;
  end process reading_addr_fifo_pr;


  xpm_hand_simple_1: xpm_hand_simple
    generic map (
      SLOW2FAST => TRUE,
      WIDTH     => DDR3_ADDR_WIDTH)
    port map (
      rst_n    => RESET_I,
      slow_clk => CLK_50Mhz,
      fast_clk => ui_clk,
      src_in   => std_logic_vector(raw_wr_ptr_addr),
      dest_out => raw_wr_ptr_addr_dest
    );

  RAW_READING_ADDR_FIFO_ADDR <= reading_addr_fifo_addr;


  -- !debug: 29/12/2019 no arbiter
  -- RAW block <-> arbiter control
  raw_ctl_fsm_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then
      RAW_CTL_FSM_PS     <= IDLE;
      reading_data_done  <= TRUE;
      master_axi_state_r <= '0';
      axi_if_req         <= '0';
      axi_wait_cnt       <= 0;
      gnt_catch <= '0';
    elsif (ui_clk'event and ui_clk = '1') then

      if (new_reading_begin_ui_clk_r) then
        reading_data_done <= TRUE;      -- when not transfer Reading data
      end if;

      master_axi_state_r <= master_axi_state(0);
      axi_if_req         <= '0';
      gnt_catch <= '0';

      case RAW_CTL_FSM_PS is

        when IDLE =>
          if (data_in_fifo) then        -- start/continue to fetch reading packet from FIFO
            -- !debug: 31/12/2019 FIFO must be not empty all reading time
            if (reading_data_done) then                                     -- new Reading
              RAW_CTL_FSM_PS <= SET_PTR_PARAMS;
            else
              RAW_CTL_FSM_PS <= SET_DATA_PARAMS;
            end if;
            axi_wait_cnt <= MAX_AXI_GRANT_WAIT;
          end if;

        when SET_PTR_PARAMS =>
          if (axi_wait_cnt /= 0) then
            axi_wait_cnt <= axi_wait_cnt - 1;
          end if;
          if (master_axi_state(2) = '0' and master_axi_state(5) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4)) then  -- !debug: 24/02/2022 wait for grant
            RAW_CTL_FSM_PS <= TX2ADDR_PTR_BUF;                              -- write Reading start address to PTR memory
          end if;
          axi_if_req <= '1';
          if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
            gnt_catch <= '1';
          end if;

        when SET_HEADER_PARAMS =>
          if (axi_wait_cnt /= 0) then
            axi_wait_cnt <= axi_wait_cnt - 1;
          end if;
          if (master_axi_state(2) = '0' and master_axi_state(5) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4)) then  -- !debug: 24/02/2022 wait for grant
            if (rdusedw_a(5) = '1' or rdusedw_a(6) = '1') then -- 28/03/2024 prevent start read before header in fifo_rd_en
              RAW_CTL_FSM_PS <= TX2DATA_BUF_HEADER;
            end if;
          end if;
          axi_if_req <= '1';
          if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
            gnt_catch <= '1';
          end if;

        when SET_DATA_PARAMS =>
          if (axi_wait_cnt /= 0) then
            axi_wait_cnt <= axi_wait_cnt - 1;
          end if;
          if (master_axi_state(2) = '0' and master_axi_state(5) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4)) then  -- !debug: 24/02/2022 wait for grant
            RAW_CTL_FSM_PS <= TX2DATA_BUF_DATA;                             -- continue transfer Sorter data
          end if;
          axi_if_req <= '1';
          if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
            gnt_catch <= '1';
          end if;

        when TX2ADDR_PTR_BUF =>
          if (master_axi_state_r = '0' and master_axi_state(0) = '1') then  -- command was sent to DDR   fifo_rd_en = '1'
            RAW_CTL_FSM_PS <= SET_HEADER_PARAMS;
            axi_wait_cnt   <= MAX_AXI_GRANT_WAIT;
          end if;
          reading_data_done <= FALSE;
          axi_if_req        <= '1';
          gnt_catch <= '1';

        when TX2DATA_BUF_HEADER =>
          if (fifo_rd_en = '1' and burst_cnt <= 1) then                     -- command was sent to DDR
            RAW_CTL_FSM_PS <= WAIT4DONE;                                    -- burst_cnt must be set for multi-word header
          end if;
          axi_if_req <= '1';
          gnt_catch <= '1';

        when TX2DATA_BUF_DATA =>
          if (fifo_rd_en = '1' and burst_cnt <= 1) then                     -- was directly rdusedw_a check, now indirect: burst_cnt
            RAW_CTL_FSM_PS <= WAIT4DONE;
          end if;
          axi_if_req <= '1';
          gnt_catch <= '1';

        when WAIT4DONE =>
          if (master_axi_state(0) = '1') then                               -- !debug: 15/01/2020
            -- if (wait_data_done_cnt = 0) then
            if (not data_in_fifo and rdempty_a = '0') then
              assert (FALSE) report "raw_ctl_fsm_pr: Error: Not enough data available in FIFO" severity ERROR;
            end if;
            assert (burst_cnt = 0) report "Error: seems wrong burst size" severity ERROR;
            RAW_CTL_FSM_PS <= IDLE;
          end if;

      end case;

      if (RAW_CTL_FSM_PS = SET_PTR_PARAMS or RAW_CTL_FSM_PS = SET_DATA_PARAMS or RAW_CTL_FSM_PS = SET_HEADER_PARAMS) then
        assert (axi_wait_cnt /= 0) report "Error: AXI wait grant timeout" severity ERROR;
      end if;

    end if;
  end process raw_ctl_fsm_pr;


  wrreq_cnt_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if (ddr3_if_rst_n = '0') then
      pointer_error <= '0';
      raw_wr_addr_error <= '0';
    elsif (ui_clk'EVENT and ui_clk = '1') then

      if ( reading_addr_fifo_addr < ADDR_FIFO_BASE_ADDR ) or ( reading_addr_fifo_addr > ADDR_FIFO_END_ADDR ) then
        pointer_error <= '1';       -- error: saved address not belong to RAW memory
      end if;

      if ( raw_data_addr < RAW_DATA_BASE_ADDR ) or ( raw_data_addr >= unsigned(RAW_DATA_END_ADDR) ) then
        raw_wr_addr_error <= '1'; -- error: next address not belong to RAW memory
      end if;

    end if;
  end process wrreq_cnt_pr;


  raw_ctl_pr : process (ddr3_if_rst_n, ui_clk) is
  begin  -- process raw_ctl_pr
    if ddr3_if_rst_n = '0' then

      start_write <= '0';
      burst_len   <= (others => '0');
      waddr_offset   <= (others => '0');

    elsif ui_clk'EVENT and ui_clk = '1' then

      if (not start_new_burst_r and start_new_burst) then -- 19/01/2020 requires accepts pulse
        if (RAW_CTL_FSM_PS = TX2ADDR_PTR_BUF or RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER or RAW_CTL_FSM_PS = TX2DATA_BUF_DATA) then
          start_write <= '1';
        end if;
      else
        start_write <= '0';
      end if;

      -- !debug: 29/12/2019 no arbiter (6*)
      -- 02/01/2020 for AXI4 master interface:
      --  - PTR - start_write, burst_len = 1, waddr_offset in PTR area
      --  - header - start_write, burst_len = HEADER_NUM_DWORDS, waddr_offset in FQ area
      --  - data - start_write, burst_len = saved_burst_size, waddr_offset in FQ area
      if (RAW_CTL_FSM_PS = TX2ADDR_PTR_BUF and rdempty_a = '0') then        -- write to address pointer buffer

        burst_len       <= (0 => '1', others => '0');
        waddr_offset    <= std_logic_vector(resize(reading_addr_fifo_addr, waddr_offset'length));

      elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_HEADER and rdempty_a = '0') then  -- write header to RAW data buffer

        burst_len       <= std_logic_vector(to_unsigned(HEADER_NUM_DWORDS, burst_len'length));
        waddr_offset    <= std_logic_vector(resize(raw_data_addr, waddr_offset'length));

      elsif (RAW_CTL_FSM_PS = TX2DATA_BUF_DATA) then                        -- write Sorter data to RAW data buffer

        burst_len       <= std_logic_vector(to_unsigned(saved_burst_size, burst_len'length));
        waddr_offset    <= std_logic_vector(resize(raw_data_addr, waddr_offset'length));

      end if;

    end if;
  end process raw_ctl_pr;


  -- ------------------------------------------------------------------------------
  -- -- ECC Encoder
  -- ------------------------------------------------------------------------------
  -- -- note: 19/01/2017 if encoder and DATA_IN valid not each clock, then valid CHECK_BITS_OUT must be when DATA_IN strobe delayed to one clock
  -- ddr_hamming_1 : ddr_hamming
  --   generic map (
  --     ENCODER => TRUE)
  --   port map (
  --     CLK                => clk20,
  --     RESET_I            => RESET_128,
  --     DATA_IN            => ecc_data_in,
  --     CHECK_BITS_IN      => std_logic_vector'(X"00"),
  --     RD_DATA_READY      => '0',
  --     DATA_OUT           => open,
  --     CHECK_BITS_OUT     => raw_ecc_data,
  --     ECC_ERROR          => open,
  --     ECC_DOUBLE_ERROR   => open,
  --     ECC_ERROR_LOCATION => open,
  --     DDR_HAMMING_TP     => open
  --   );


  -- 24/01/2017 replace wrreq_a* -> data_sorter_data_ready* related signal.
  --            This because wrreq_a valid for all input, include address pointer, also this delayed signal
  ecc_enc_misc_pr: process (RESET_I, CLK_50Mhz) is
  begin  -- process ecc_enc_misc_pr
    if (RESET_I = '0') then               -- asynchronous reset (active low)
      -- ecc_data_in_even <= '0';
      -- ecc_data_in <= (others => '0');
      ecc2fifo <= '0';
      fifo_wr_cnt <= 0;
      packet_size_sig <= 0;
      do_packet_size_comp <= FALSE;
    elsif (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge

      -- if(new_reading_begin and not new_reading_begin_r) then
      --   ecc_data_in_even <= '0';
      -- elsif (data_sorter_data_ready_r or data_sorter_data_ready_r2) then
      --   ecc_data_in_even <= not ecc_data_in_even;
      -- end if;
      --
      -- if (ecc_data_in_even = '0') then
      --   ecc_data_in(31 downto 0) <= data_sort_dout_r;
      -- else
      --   ecc_data_in(63 downto 32) <= data_sort_dout_r;
      -- end if;
      --
      -- if (fifo_wr_cnt >= packet_size_sig and ecc_rdempty = '0') then
      --   ecc2fifo <= '1';
      -- else
      --   ecc2fifo <= '0';
      -- end if;

      ecc2fifo <= '0';                  -- !TODO: 27/06/2023 NU, remove
      ecc_rdreq <= '0';                  -- !TODO: 27/06/2023 NU, remove

      if(new_reading_begin and not new_reading_begin_r) then
        fifo_wr_cnt <= 0;
      elsif (ecc2fifo = '1') then       -- !debug: 27/06/2023 NU
        if (ecc_rdreq = '1') then
          fifo_wr_cnt <= fifo_wr_cnt + 1;
        end if;
      else
        if (wrreq_a = '1') then
          fifo_wr_cnt <= fifo_wr_cnt + 1;
        end if;
      end if;

      do_packet_size_comp <= (RAW_DATA_FSM_PS = ECC_DATA_WAIT);

      if ((DATA_SORTER_DATA_EN = '1' and init_done_all_64m(1) = '1') and not data_sorter_data_ready_r) then -- data strobe rise
        packet_size_sig <= 2047;                   -- max
      elsif (RAW_DATA_FSM_PS = ECC_DATA_WAIT) then
        packet_size_sig <= fifo_wr_cnt; -- real packet size,
                                        -- check: <PTR> + <slice size (DW)> * <FQ num_of_slices> + <header size>
                                        -- ex for 64 slices: 1+16*64+32=1057
      end if;

    end if;
  end process ecc_enc_misc_pr;


  -- -- Pack 4x bytes ECC out to single ECC DW
  -- ecc_pack_p : process(RESET_128, clk20)
  -- begin
  --   if (RESET_128 = '0') then
  --     ecc_pack_counter  <= 0;
  --     ecc_pack_register <= (others => '0');
  --     ecc_wrreq         <= '0';
  --     ecc_wrreq_en      <= '0';
  --     ecc_rdreq         <= '0';
  --     ecc_rd_debug_cnt <= 0;
  --   elsif rising_edge(clk20) then
  --
  --     if (data_sorter_data_ready_r2) then
  --       ecc_wrreq_en <= not ecc_data_in_even;
  --     else
  --       ecc_wrreq_en <= '0';
  --     end if;
  --
  --     ecc_wrreq <= '0';
  --
  --     if(new_reading_begin and not new_reading_begin_r) then
  --       -- !debug: 12/07/2017 was ecc_pack_counter 0 to 3, now 3 downto 0
  --       ecc_pack_counter <=  3; -- 0
  --     else
  --       if (ecc2fifo = '0') then
  --         if (ecc_wrreq_en = '1') then
  --           if (ecc_pack_counter = 0) then -- 3
  --             ecc_pack_counter <= 3;       -- 0
  --             ecc_wrreq        <= '1';  -- Write data when register is filled
  --           else
  --             ecc_pack_counter <= ecc_pack_counter - 1; -- +
  --           end if;
  --
  --           ecc_pack_register((8*((3 - ecc_pack_counter) + 1) - 1) downto (8*(3 - ecc_pack_counter))) <= raw_ecc_data;
  --         end if;
  --       else
  --         if (ecc_pack_counter = 1) then -- !TODO: 31/01/2017 need add cases when ecc_pack_counter /= 2 -- = 2
  --           l1: for i in 0 to 1 loop     -- 2 to 3
  --             ecc_pack_register((8*((3 - i) + 1) - 1) downto (8*(3 - i))) <= X"00";
  --           end loop l1;
  --           ecc_wrreq <= '1';
  --           ecc_pack_counter <= 0; -- Write data when last data word and register not filled -- 3
  --         else
  --           ecc_wrreq <= '0';
  --         end if;
  --       end if;
  --     end if;
  --
  --     if (ecc2fifo = '1') then
  --       if (to_integer(unsigned(ecc_rdusedw)) >= packet_size_sig/8) then -- !debug: 30/05/2018 was =
  --         if (ecc_rd_debug_cnt = 0) then -- !debug: 30/05/2018
  --           ecc_rdreq <= '1';               -- read from ECC FIFO
  --         end if;
  --       elsif (to_integer(unsigned(ecc_rdusedw)) < 3) then -- FIFO latency before empty when continuous read
  --         ecc_rdreq <= '0';
  --       end if;
  --     end if;
  --
  --     if (ecc2fifo = '0') then
  --       ecc_rd_debug_cnt <= 7;
  --     else
  --       if (ecc_rd_debug_cnt /= 0) then
  --         ecc_rd_debug_cnt <= ecc_rd_debug_cnt - 1;       -- delay after stop write to FIFO
  --       end if;
  --     end if;
  --
  --   end if;
  -- end process ecc_pack_p;


  -- RAW data buffer
  -- Input both RAW data and ECC data: PACKET_SIZE + PACKET_SIZE/(2*4) = 80 + 80/8 = 90 !debug: 19/01/2017 wrusedw_a = 89 - OK
  -- !debug: 24/01/2017 differences:
  --   - fifo_wr /= wrreq_a because wrreq_a uses for all writes (addr,data,header + ECC), fifo_wr uses for write ECC
  --  24/01/2017 added to RAW_DATA_FSM_PS new state - ECC_DATA, then wrreq_a must be active when reads ECC from dcfifo_ecc FIFO
  -- !debug: 31/12/2019 was dcfifo_1024x32
  dcfifo_a : dcfifo_512x32
    port map (
      rst           => "not"(ddr3_if_rst_n),
      wr_clk        => CLK_50Mhz,
      rd_clk        => ui_clk,
      din           => muxed_data_r,
      wr_en         => wrreq_a,
      rd_en         => fifo_rd_en, -- rdreq_a,
      dout          => fifo_axi_wdata,
      full          => wrfull_a,
      overflow      => open,
      empty         => rdempty_a,
      valid         => fifo_wdata_valid,  -- data strobe to DDR3
      underflow     => open,
      rd_data_count => rdusedw_a,
      wr_data_count => wrusedw_a
    );                                  -- FQ data FIFO


  -- -- ECC FIFO
  -- -- ECC output to ECC FIFO
  -- -- raw_ecc_data_wr
  -- -- !debug: 31/12/2019 was dcfifo_256x32
  -- dcfifo_ecc : dcfifo_512x32
  --   port map (
  --     rst           => "not"(RESET_128),
  --     wr_clk        => clk20,
  --     rd_clk        => clk20,
  --     din           => ecc_pack_register,
  --     wr_en         => ecc_wrreq,
  --     rd_en         => ecc_rdreq,
  --     dout          => ecc_q,
  --     full          => ecc_wrfull,
  --     overflow      => open,
  --     empty         => ecc_rdempty,
  --     valid         => open,
  --     underflow     => open,
  --     rd_data_count => ecc_rdusedw,
  --     wr_data_count => ecc_wrusedw
  --   );          --  ECC FIFO

  -- synthesis translate_off
  -- synthesis translate_on
  header_check_pr: process (CLK_50Mhz) is
    variable header_word_cnt : natural range 0 to 63 := 0;  -- 2x header word in 1
    variable fq_num_of_slices_from_header_v : std_logic_vector(6 downto 0) := (others => '0');
    variable DataType_from_header_v : std_logic_vector(2 downto 0) := (others => '0');
    variable StreamType_from_header_v : std_logic_vector(2 downto 0) := (others => '0');
    variable reading_num_from_header_v : std_logic_vector(15 downto 0) := (others => '0'); -- LSW
    variable slice_merging_factor_from_header_v : std_logic_vector(1 downto 0) := (others => '0');
    variable fs_merging_factor_from_header_v : std_logic_vector(1 downto 0) := (others => '0');
    variable ptr_address_from_header_v : std_logic_vector(31 downto 0) := (others => '0');
    variable tmb_header_v : std_logic_vector(31 downto 0) := (others => '0');
    variable stamp_v : std_logic_vector(15 downto 0) := (others => '0');
  begin  -- process header_check_pr
    if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge
      if (RAW_DATA_FSM_PS = WAIT4HEADER) then
        header_word_cnt := 0;
      elsif (RAW_DATA_FSM_PS = DATA2HEADER) then
        header_word_cnt := header_word_cnt + 1;
      end if;
      tmb_header_v := tmb_header(15 downto 0) & tmb_header(31 downto 16); -- words swap
      case header_word_cnt is
        when 0 => fq_num_of_slices_from_header_v := tmb_header_v(6 downto 0);
                  DataType_from_header_v := tmb_header_v(11+16 downto 9+16); -- 0x0 - Merged, 0x1 - HD
                  StreamType_from_header_v := tmb_header_v(15+16 downto 13+16); -- 0x1 - RLT, 0x2 - Buffered
        when 4 => reading_num_from_header_v := tmb_header_v(15 downto 0);
        when 10 => slice_merging_factor_from_header_v := tmb_header_v(11+16 downto 10+16);
                   fs_merging_factor_from_header_v := tmb_header_v(9+16 downto 8+16);
        when 29 => ptr_address_from_header_v := tmb_header_v; -- here PTR address?
        when 31 => stamp_v := tmb_header_v(31 downto 16);
        when others => null;
      end case;
      -- stamp_sampled <= stamp_v;
      fq_num_of_slices_from_header_sampled <= fq_num_of_slices_from_header_v;

      -- !TODO: 21/02/2024 compare ptr_address_from_header_v with raw_wr_ptr_addr
      ptr_address_from_header <= ptr_address_from_header_v;

    end if;
  end process header_check_pr;


  -- testpoints
  data_sort_2_ddr_tp(0) <= '0';
  data_sort_2_ddr_tp(1) <= '0';
  data_sort_2_ddr_tp(2) <= '0';
  data_sort_2_ddr_tp(3) <= '0';
  data_sort_2_ddr_tp(4) <= '0';
  data_sort_2_ddr_tp(5) <= '0';

  -- test (noopt)
  data_sort_2_ddr_tp(7) <= '0' when (RAW_CTL_FSM_PS = IDLE) else '1';
  data_sort_2_ddr_tp(8) <= '1';
  data_sort_2_ddr_tp(9) <= '1'; -- when ((or data_sort_dout_r) /= '0'
                                -- and sorter_data_header = '0' and data_sorter_data_ready_r2) else '0';

  data_sort_2_ddr_tp(10) <= pointer_error;
  data_sort_2_ddr_tp(11) <= raw_wr_addr_error;

  DATA_SORT_2_DDR_TP(31 downto 12) <= ( others => '0' );
  DATA_SORT_2_DDR_TP(6) <= '0';

--add by Dalit 19/3/2024 timing issue solving------

    xpm_cdc_single_2 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => wr_burst_error_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => wr_burst_error  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );
	  
	  xpm_cdc_single_3 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => raw_wr_addr_error_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => raw_wr_addr_error  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

  xpm_cdc_single_4 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => rdempty_a_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => rdempty_a  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

    xpm_cdc_single_5 : xpm_cdc_single
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

end architecture ar;
