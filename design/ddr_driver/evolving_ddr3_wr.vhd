-------------------------------------------------------------------------------
-- Title      : Evolving data write
-- Project    : DDR3 control (Trident project)
-------------------------------------------------------------------------------
-- File       : evolving_ddr3_wr.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    : Philips Medical
-- Created    : 22/01/2006
-- Last update: 27/05/2025
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: accepts reading data and transmits them to DDR3 memory controller
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 22/01/2006  1.0      ilq00431  Created
-------------------------------------------------------------------------------
--  - 16/01/2017 multi-word header: header size and field names same as for RAW data
--
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library xpm;
use xpm.vcomponents.all;

use work.tbuf_pack.all;


entity evolving_ddr3_wr is
  port (
    RESET_I                  : in  std_logic;
    ddr3_if_rst_n            : in  std_logic; -- DDR3 clock domain
    CLK_50Mhz                : in  std_logic;
    ui_clk                   : in  std_logic; -- DDR3 clock domain

    -- Arbiter interface (all must be 128MHz!!!)
    INIT_DONE_ALL_O          : in  std_logic;
    IP50                : in std_logic; -- 22/10/2023

    -- Data and strobe from EV control block (!debug: 20/02/2017 DDR3 clock domain)
    EVOLVING_DOUT            : in  std_logic_vector (31 downto 0);
    EVOLVING_DATA_EN         : in  std_logic;

    params_ready : in std_logic;  -- 20/09/2022
    tmb_header : in std_logic_vector (31 downto 0); -- 20/09/2022
    tmb_header_rd : out std_logic;
    ev_wr_slot_addr : in DDR3_ADDR_BUS_TYP;  -- !TODO: 10/08/2023 replace with this internal incremented address
    num_of_slices : in std_logic_vector (6 downto 0); -- 08/02/2023 was [7..0]

    -- Buffer control and errors registers interface
    EV_READING_EV_DATA_ADDR  : out DDR3_ADDR_BUS_TYP;
    -- EV_READING_EV_SLOTNUM    : out EV_BUFFER_SLOTS_TYP; -- writen slots ptr
    EV_FSM_ERROR             : out std_logic;  -- FSM timeout
    EV_FIFO_SPACE            : out std_logic_vector(8 downto 0);  -- available words in FIFO
    EV_FIFO_OVERFLOW         : out std_logic;  -- FIFO in overflow state, wrfull='1'
    EV_FIFO_NOTEMPTY         : out std_logic;
    EV_WR_COUNTER            : out std_logic_vector(31 downto 0);
    EV_ADDR_AREA_ERROR       : out std_logic;
    EV_WR_BURST_ERROR        : out std_logic;
    EV_WR_BAD_PACKET_SIZE    : out std_logic;

    -- AXI4 master interface:
    start_write		  : out std_logic;
    burst_len		  : out std_logic_vector(7 downto 0);
    fifo_axi_wdata	  : out std_logic_vector(31 downto 0);
    fifo_wdata_valid      : out std_logic;
    waddr_offset	  : out std_logic_vector(29 downto 0);
    fifo_rd_en	          : in std_logic;
    master_axi_state      : in std_logic_vector(7 downto 0); -- master_axi_state(1) - write in process (busy)
    axi_if_req            : out std_logic;                   -- 14/01/2020
    gnt_catch             : out std_logic;   -- 01/11/2023
    fifo_near_overflow    : out std_logic;   -- 04/07/2023 req. high priority from arbiter

    EVOLVING_DDR3_WR_TP   : out std_logic_vector (31 downto 0));

end entity evolving_ddr3_wr;



architecture ar of evolving_ddr3_wr is

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


  -- FIFO controls
  signal wrreq_a, wrreq_fsm : std_logic;                 -- write to FIFO
  -- signal rdreq_a        : std_logic;                     -- 15/01/2017 read from FIFO
  signal rdempty_a, rdempty_a_20m, overflow_a, underflow_a : std_logic;                     -- FIFO empty
  signal wrfull_a       : std_logic;                     -- FIFO full
  signal wrusedw_a      : std_logic_vector(8 downto 0);  --words in FIFO
  signal rdusedw_a      : std_logic_vector(8 downto 0);

  signal ev_data_addr                            : DDR3_ADDR_BUS_TYP;  -- EV_DATA memory address
  signal ev_header_addr                          : DDR3_ADDR_BUS_TYP;  -- saved address
  signal muxed_data_r                : std_logic_vector(31 downto 0);
  -- signal ecc_data_in                             : std_logic_vector(63 downto 0);
  signal ev_data_addr_offset                     : DDR3_ADDR_BUS_TYP;  -- EV_DATA memory address
  signal new_reading_begin, new_reading_begin_r, new_reading_begin_ui_clk, new_reading_begin_ui_clk_r : boolean;
  signal new_reading_begin_src, new_reading_begin_dst : std_logic;
  type   EV_DATA_FSM_TYP is (WAIT4DATA, SYNC1, WAIT4HEADER, DATA2HEADER, DATA2EV_DATA, ECC_DATA_WAIT, ECC_DATA);
  signal EV_DATA_FSM_PS                          : EV_DATA_FSM_TYP;
  attribute fsm_encoding : string;
  attribute fsm_encoding of EV_DATA_FSM_PS : signal is "one_hot";
  attribute fsm_safe_state : string;
  attribute fsm_safe_state of EV_DATA_FSM_PS : signal is "default_state";
  attribute keep : string;
  attribute keep of EV_DATA_FSM_PS : signal is "true";

  signal evolving_dout_r, evolving_dout_r2       : std_logic_vector(31 downto 0);  -- effective rate 32MHz !!!
  signal ev_ecc_data                             : std_logic_vector(7 downto 0);
  type EV_CTL_FSM_TYP is (IDLE, SET_ADDR_PARAMS, ADDR_LOAD, TX2EV_BUF_HEADER,  -- !debug: 21/01/2020 was   WAIT4GRANT, NODONE
                          SET_DATA_PARAMS, TX2EV_BUF_DATA, WAIT4DONE);
  signal EV_CTL_FSM_PS   : EV_CTL_FSM_TYP;
  -- signal wait_data_done_cnt       : natural range 15 downto 0;  -- !check it
  signal no_data_tx         : boolean;  -- when not transfer Reading data
  signal ev_data_ready_r, ev_data_ready_r2 : boolean;     -- when formed full 64bit word
  signal data_in_fifo    : boolean;
  signal init_done_all_64m         : unsigned(1 downto 0);
  signal sorter_data_header        : std_logic; -- only for monitoring
  -- signal ev_slotnum_ptr : EV_BUFFER_SLOTS_TYP;
  signal ev_fifo_notempty_64m, ev_fifo_notempty_128m, ev_fifo_notempty_128m_dst           : std_logic;  -- change by Dalit 19/3/2024 timing issue solving
  signal inc_ev_wr_counter, inc_ev_wr_counter_pulse_64m, inc_ev_wr_counter_pulse_64m_r : boolean;
  signal inc_ev_wr_counter_pulse_128m : unsigned(3 downto 0);
  signal ev_wr_counter_cnt : unsigned(31 downto 0);
  signal ev_fsm_error_i1, ev_fsm_error_i1_dst, wr_burst_error , wr_burst_error_dst  : std_logic;         -- , ev_fsm_error_i2, ev_fsm_error_i3  -- change by Dalit 19/3/2024 timing issue solving
  signal ev_fsm_error_i1_64m, bad_header_stamp, bad_num_of_slices, wr_burst_error_64m, bad_packet_size, ev_wr_slot_addr_err : std_logic;
  signal error_core_addr, error_core_addr_sys_clk : std_logic;
  signal initialization         : boolean; -- ES: header not received, new address not set

  -- 19/12/2016
  signal saved_burst_size, burst_cnt : natural range 0 to 127; -- 19/12/2016
  signal start_new_burst, start_new_burst_r : boolean;
  signal module_ev_header : std_logic_vector(32*HEADER_NUM_DWORDS - 1 downto 0); -- 15/12/2016 only for monitoring
  signal header_dw_cnt : natural range 0 to HEADER_NUM_DWORDS - 1; -- when saved

  -- 24/01/2017 signals for ECC encoder:
  -- signal ecc_data_in_even : std_logic;
  signal fifo_wr_cnt : natural range 0 to 2047;          -- !debug: 03/04/2017 was 511
  signal ecc2fifo       : std_logic;                     -- select data to FIFO: packet data or ECC data
  -- signal ecc_wrreq      : std_logic;					 -- write to FIFO
  signal ecc_rdreq		: std_logic;					 -- 15/01/2017 read from FIFO
  -- signal ecc_rdempty	: std_logic;					 -- FIFO empty
  -- signal ecc_wrfull		: std_logic;					 -- FIFO full
  -- signal ecc_wrusedw    : std_logic_vector(8 downto 0);  --words in FIFO -- !debug: 01/07/2018 was 6..0
  -- signal ecc_rdusedw    : std_logic_vector(8 downto 0);  -- !debug: 01/07/2018 was 6..0
  signal ecc_q          : std_logic_vector(31 downto 0);
  -- signal ecc_wrreq_en   : std_logic;					 -- write to FIFO
  -- signal ecc_pack_counter			: integer range 0 to 3;
  -- signal ecc_pack_register			: std_logic_vector(31 downto 0);

  signal packet_size_sig, calc_packet_size : natural range 0 to 2047;           -- data + header size

  signal ev_fifo_overflow_i : std_logic;

  signal ecc_rd_debug_cnt : natural range 0 to 7;           -- 30/05/2018

  -- signal wrong_slice_reading_number : std_logic_vector(23 downto 0); -- 02/07/2018

  -- !debug: 20/08/2018 only for simulation, remove
  -- constant EV_DATA_END_ADDR	   : unsigned(27 downto 0) := X"0007A00" ;		-- up to 25 ev readings

  signal master_axi_state_r : std_logic; -- master_axi_state(0) - no WR/RD (ready)   NU?
  signal start_write_i : std_logic;
  constant MAX_AXI_GRANT_WAIT : natural := 255;  -- max read burst time
  signal axi_wait_cnt : natural range 0 to MAX_AXI_GRANT_WAIT;

  signal params_ready_r : std_logic;
  signal tmb_header_rd_i : std_logic;
  signal fsm_wait_cnt : natural range 0 to 255;

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

  signal ev_wr_slot_addr_dest : std_logic_vector(DDR3_ADDR_WIDTH-1 downto 0);
  signal ev_wr_slot_addr_sampled : DDR3_ADDR_BUS_TYP := (others => '0');  -- !TODO: 15/01/2024 check
  signal stamp_sampled : std_logic_vector(15 downto 0) := (others => '0');
  signal ev_num_of_slices_from_header_sampled : std_logic_vector(6 downto 0) := (others => '0');
  signal do_packet_size_comp : boolean;

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of  wrfull_a, overflow_a, rdempty_a, underflow_a, fifo_wdata_valid, ev_wr_slot_addr_sampled, ev_wr_slot_addr_dest, bad_num_of_slices, wrusedw_a : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of EV_DATA_FSM_PS, wrfull_a, overflow_a, rdempty_a, underflow_a, fifo_wdata_valid, ev_wr_slot_addr_sampled, ev_wr_slot_addr_dest, bad_num_of_slices, wrusedw_a : signal is "true";

begin  -- architecture ar


  data_in_fifo <= (unsigned(rdusedw_a) /= 0);
  -- fifo_near_overflow <= '1' when (unsigned(rdusedw_a(8 downto 7)) = "11") else '0'; -- 04/07/2023
  fifo_near_overflow <= '1' when (rdusedw_a(8) = '1') else '0'; -- 22/11/2023

  sync_pr : process (RESET_I, CLK_50Mhz) is
  begin  -- process sync_pr
    if RESET_I = '0' then
      EV_FIFO_SPACE    <= (others => '0');
      init_done_all_64m <= (others => '0');
      ev_fifo_notempty_64m <= '0';
      EV_FIFO_NOTEMPTY <= '0';
      EV_FIFO_OVERFLOW <= '0';
      ev_wr_counter_cnt <= (others => '0');
      ev_fsm_error_i1_64m <= '0';
      -- ev_fsm_error_i2_64m <= '0';
      -- ev_fsm_error_i3_64m <= '0';
      inc_ev_wr_counter_pulse_64m <= FALSE;
      inc_ev_wr_counter_pulse_64m_r <= FALSE;
      new_reading_begin <= FALSE;
      new_reading_begin_r <= FALSE;
      params_ready_r <= '0';
      rdempty_a_20m <= '0';
      bad_header_stamp <= '0';
      bad_num_of_slices <= '0';
      wr_burst_error_64m <= '0';
      calc_packet_size <= 0;
      bad_packet_size <= '0';
      ev_wr_slot_addr_err <= '0';
      error_core_addr_sys_clk <= '0';
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      EV_FIFO_SPACE <= std_logic_vector(to_unsigned(511, 9) - unsigned(wrusedw_a));

      init_done_all_64m <= init_done_all_64m(0) & INIT_DONE_ALL_O; -- sync 'constant' INIT_DONE_ALL_O from 128MHz
                                            -- domain to 64MHz

      ev_fifo_notempty_64m <= ev_fifo_notempty_128m_dst;
      EV_FIFO_NOTEMPTY <= ev_fifo_notempty_64m;

      EV_FIFO_OVERFLOW <= ev_fifo_overflow_i;

      inc_ev_wr_counter_pulse_64m <= (inc_ev_wr_counter_pulse_128m(3) = '1'); -- !debug: 24/12/2017
      inc_ev_wr_counter_pulse_64m_r <= inc_ev_wr_counter_pulse_64m;

      if (inc_ev_wr_counter_pulse_64m and not inc_ev_wr_counter_pulse_64m_r) then -- !debug: 08/05/2017
      -- if (inc_ev_wr_counter) then
        ev_wr_counter_cnt <= ev_wr_counter_cnt + 1; -- for tests only
      end if;

      ev_fsm_error_i1_64m <= ev_fsm_error_i1_dst;  -- change by Dalit 19/3/2024 timing issue solving
      -- ev_fsm_error_i2_64m <= ev_fsm_error_i2;
      -- ev_fsm_error_i3_64m <= ev_fsm_error_i3;

      new_reading_begin <= (params_ready_r = '0' and params_ready = '1') and init_done_all_64m(1) = '1';
      new_reading_begin_r <= new_reading_begin;

      params_ready_r <= params_ready;
      rdempty_a_20m <= rdempty_a;

      if (EV_DATA_FSM_PS = DATA2EV_DATA) then
        if (unsigned(stamp_sampled) /= X"FACE") then
          bad_header_stamp <= '1';      -- sticky
        end if;
      end if;

      if (EV_DATA_FSM_PS = DATA2HEADER) then
        if (unsigned(ev_num_of_slices_from_header_sampled) /= unsigned(num_of_slices)) then
          bad_num_of_slices <= '1';     -- !debug: 24/01/2024 possible false errors ?
        else
          bad_num_of_slices <= '0';
        end if;
      end if;

      wr_burst_error_64m <= wr_burst_error_dst;

      calc_packet_size <= to_integer(unsigned(ev_num_of_slices_from_header_sampled) & "0000") + 32;
      if (do_packet_size_comp) then
        if (packet_size_sig /= calc_packet_size) then
          bad_packet_size <= '1';
        else
          bad_packet_size <= '0';
        end if;
      end if;

      if (EV_DATA_FSM_PS = DATA2EV_DATA and ev_wr_slot_addr_sampled /= ev_wr_slot_addr) then
        ev_wr_slot_addr_err <= '1';
      else
        ev_wr_slot_addr_err <= '0';
      end if;

      error_core_addr_sys_clk <= error_core_addr;
      
    end if;
  end process sync_pr;


  sync128_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then

      EV_READING_EV_DATA_ADDR    <= EV_DATA_BASE_ADDR;
      ev_fifo_notempty_128m      <= '0';
      -- ev_fsm_error_i2            <= '0';
      -- ev_fsm_error_i3            <= '0';
      inc_ev_wr_counter_pulse_128m <= (others => '0');
      -- wrong_slice_reading_number <= (others => '0');
      new_reading_begin_ui_clk <= FALSE;
      new_reading_begin_ui_clk_r <= FALSE;
      wr_burst_error <= '0';
    elsif ui_clk'EVENT and ui_clk = '1' then

      -- 1st data word is header
      -- if (INIT_DONE_ALL_O = '1' and header_dw_cnt = 1 and EV_DATA_FSM_PS = DATA2HEADER) then -- and ev_ecc_ready

        -- report "Checked reading header in EV data stream..." severity NOTE;
        -- assert (muxed_data_r(7 downto 0) = UNIQ_ID(7 downto 0))
        --   report "Error in EVOLVING_DOUT, must be header" severity ERROR; -- !debug: 11/01/2018  was  X"55"
        -- !TODO: 10/08/2023 add check header (W#64	Stamp = 0xFACE)

        -- if (muxed_data_r(7 downto 0) /= UNIQ_ID(7 downto 0)) then -- !debug: 11/01/2018  was  X"55"
        --   ev_fsm_error_i2 <= '1';
        -- end if;

      -- end if;

      -- if (EV_DATA_FSM_PS = DATA2EV_DATA) then
      --   if (to_integer(unsigned(module_ev_header(41 downto 32))) = 0) then -- wrong number of slices
      --     ev_fsm_error_i3 <= '1';                                          -- !debug: 02/07/2018 sticky error
      --     if (ev_fsm_error_i3 = '0') then
      --       wrong_slice_reading_number <= module_ev_header(23 downto 0);
      --     end if;
      --   end if;
      -- end if;
      -- !TODO: 10/08/2023
      -- create similar check @CLK_50m: if something bad in header -> error
      -- see data_sort_ddr3_wr.reading_number_temp for wrong_slice_reading_number driver

      if (EV_CTL_FSM_PS /= IDLE and EV_CTL_FSM_PS /= SET_ADDR_PARAMS) then
        EV_READING_EV_DATA_ADDR <= ev_data_addr; -- for overflow/underflow calc.
      end if;

      if (rdempty_a = '0' and new_reading_begin_ui_clk and not new_reading_begin_ui_clk_r) then
        ev_fifo_notempty_128m <= '1';  -- !check, when clear
      end if;

      if (inc_ev_wr_counter) then
        inc_ev_wr_counter_pulse_128m <= (others => '1');
      else
        inc_ev_wr_counter_pulse_128m <= inc_ev_wr_counter_pulse_128m(2 downto 0) & '0';
      end if;

      -- new_reading_begin_ui_clk <= new_reading_begin; -- sync from @sys_clk
      new_reading_begin_ui_clk <= (new_reading_begin_dst = '1');
      new_reading_begin_ui_clk_r <= new_reading_begin_ui_clk;

      if (EV_CTL_FSM_PS = WAIT4DONE) then -- 23/01/2024
        if (burst_cnt /= 0 or fifo_rd_en = '1') then
          wr_burst_error <= '1';
        else
          wr_burst_error <= '0';
        end if;
      elsif (EV_CTL_FSM_PS = TX2EV_BUF_DATA or EV_CTL_FSM_PS = TX2EV_BUF_HEADER) then
        if (fifo_rd_en = '1' and burst_cnt = 0) then
          wr_burst_error <= '1';
        else
          wr_burst_error <= '0';
        end if;
      end if;

    end if;
  end process sync128_pr;

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

  -- purpose: EV_DATA_FSM - write EV data to FIFO ------------------------------
  ev_data_fsm_pr : process (RESET_I, CLK_50Mhz) is
  begin
    if RESET_I = '0' then

      EV_DATA_FSM_PS    <= WAIT4DATA;
      ev_fifo_overflow_i  <= '0';
      sorter_data_header <= '0';
      inc_ev_wr_counter <= FALSE;
      tmb_header_rd_i <= '0';
      fsm_wait_cnt <= 0;

    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      inc_ev_wr_counter <= FALSE;
      tmb_header_rd_i <= '0';

      case EV_DATA_FSM_PS is

        when WAIT4DATA =>
          if (wrfull_a = '0' and init_done_all_64m(1) = '1') then
            if (new_reading_begin_r) then     -- !debug: 28/09/2023 was new_reading_begin_ui_clk_r
              EV_DATA_FSM_PS     <= SYNC1;
              inc_ev_wr_counter  <= TRUE;
              sorter_data_header <= '0';
            elsif (ev_data_ready_r2 and not initialization) then
              EV_DATA_FSM_PS <= DATA2EV_DATA;
            end if;
          end if;

        when SYNC1 =>
          EV_DATA_FSM_PS <= WAIT4HEADER;
          fsm_wait_cnt   <= 1;

        when WAIT4HEADER =>                   -- write to FIFO
          if (fsm_wait_cnt = 0) then
            EV_DATA_FSM_PS <= DATA2HEADER;
          end if;
          if (fsm_wait_cnt /= 0) then
            fsm_wait_cnt <= fsm_wait_cnt - 1;
          end if;
          tmb_header_rd_i <= '1';

        when DATA2HEADER =>                   -- write to FIFO
          if (header_dw_cnt = 0) then         -- !debug: 21/08/2023 was   and not initialization
            EV_DATA_FSM_PS     <= WAIT4DATA;  -- !debug: 21/08/2023 was   DATA2EV_DATA;
            sorter_data_header <= '1';        -- header sample ready
          end if;
          if (header_dw_cnt < 2) then
            tmb_header_rd_i <= '0';
          else
            tmb_header_rd_i <= '1';
          end if;

        when DATA2EV_DATA =>                  -- write to FIFO
          if (not ev_data_ready_r2) then
            EV_DATA_FSM_PS <= ECC_DATA_WAIT;  -- 24/01/2017
          end if;

        when ECC_DATA_WAIT =>
          if (ecc2fifo = '1' and ecc_rdreq = '1') then
            EV_DATA_FSM_PS <= ECC_DATA;
          elsif (ecc2fifo = '0') then         -- 27/06/2023
            EV_DATA_FSM_PS <= WAIT4DATA;
          end if;

        when ECC_DATA =>
          if (ecc_rdreq = '0') then
            EV_DATA_FSM_PS <= WAIT4DATA;
          end if;

      end case;

      if (wrfull_a = '0' and init_done_all_64m(1) = '1') then
        ev_fifo_overflow_i <= '0';
      else
        -- Place for writing to Error register
        if (init_done_all_64m(1) = '1') then
          ev_fifo_overflow_i <= '1';    -- !check, when clear overflow state
          assert not(wrfull_a = '1' and rdempty_a_20m = '0') report "FIFO full !!!" severity ERROR;
        end if;
      end if;

    end if;
  end process ev_data_fsm_pr;


  tmb_header_rd <= tmb_header_rd_i;

  -- wrreq -------------------------------------------------------------------
  with EV_DATA_FSM_PS select
    wrreq_fsm <=
    '1' when DATA2EV_DATA | DATA2HEADER | ECC_DATA,
    '0' when WAIT4DATA | SYNC1| WAIT4HEADER | ECC_DATA_WAIT;

  -- EV data words write only when ready ev_data_64bit word ------------------
  wrreq_a   <= wrreq_fsm;


  -- Sample Sorter data: -----------------------------------------------------
  data_sort_sample_pr : process (RESET_I, CLK_50Mhz)
  begin  -- process data_sort_sample_pr
    if RESET_I = '0' then
      muxed_data_r <= (others => '0');
      evolving_dout_r <= (others => '0');
      evolving_dout_r2 <= (others => '0');
      ev_data_ready_r  <= FALSE;
      ev_data_ready_r2 <= FALSE;
      initialization     <= TRUE;
      header_dw_cnt      <= 0;
      module_ev_header <= (others => '0');
    elsif CLK_50Mhz'EVENT and CLK_50Mhz = '1' then

      evolving_dout_r2 <= evolving_dout_r;
      ev_data_ready_r2 <= ev_data_ready_r;

      if (EVOLVING_DATA_EN = '1' and init_done_all_64m(1) = '1' ) then  -- !check
        evolving_dout_r <= EVOLVING_DOUT;
        ev_data_ready_r <= TRUE;
      else
        evolving_dout_r <= (others => '0');
        ev_data_ready_r <= FALSE;
      end if;

      if (ecc2fifo = '1') then
        muxed_data_r <= ecc_q;              -- mux ECC to FIFO
      elsif (EV_DATA_FSM_PS = DATA2HEADER or EV_DATA_FSM_PS = WAIT4HEADER) then
        muxed_data_r <= tmb_header;
      else
        muxed_data_r <= evolving_dout_r2;   -- EV data pipe to FIFO
      end if;

      if (EV_DATA_FSM_PS = DATA2HEADER and initialization) then
        module_ev_header(32*(HEADER_NUM_DWORDS-1-header_dw_cnt) + 31 downto 32*(HEADER_NUM_DWORDS-1-header_dw_cnt)) <= muxed_data_r;
      end if;

      if (EV_DATA_FSM_PS = WAIT4HEADER) then
        initialization <= TRUE;
      elsif (EV_DATA_FSM_PS = DATA2HEADER and header_dw_cnt = 0) then
        initialization <= FALSE;
      end if;

      if (new_reading_begin and not new_reading_begin_r) then
        header_dw_cnt <= HEADER_NUM_DWORDS - 1;
      elsif (header_dw_cnt /= 0) then
        if(EV_DATA_FSM_PS = DATA2HEADER) then       -- edge condition for initialize: after reset there is no old header!!!  !debug: 21/08/2023 was    and initialization = TRUE
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
    elsif ui_clk'EVENT and ui_clk = '1' then

      -- start_new_burst
      -- if (EV_CTL_FSM_PS = SET_ADDR_PARAMS and not no_data_tx) then
      --   if (master_axi_state(1) = '0' and master_axi_state(2) = '0' and master_axi_state(4) = '1') then
      --     start_new_burst <= TRUE;
      --   else
      --     start_new_burst <= FALSE;
      --   end if;
      -- elsif (EV_CTL_FSM_PS = ADDR_LOAD) then
      if (EV_CTL_FSM_PS = TX2EV_BUF_HEADER or EV_CTL_FSM_PS = TX2EV_BUF_DATA) then -- !debug: 21/01/2020
        if (master_axi_state(1) = '0' and master_axi_state(2) = '0' and master_axi_state(4) = '1') then
          start_new_burst <= TRUE;
        else
          start_new_burst <= FALSE;
        end if;
      -- elsif (EV_CTL_FSM_PS = TX2EV_BUF_DATA or EV_CTL_FSM_PS = TX2EV_BUF_HEADER) then
      --   start_new_burst <= FALSE;
      else
        start_new_burst <= FALSE;
      end if;

      start_new_burst_r <= start_new_burst;

      -- !TODO: 21/01/2020 fix, when sample burst_cnt
      if (EV_CTL_FSM_PS = SET_ADDR_PARAMS and not no_data_tx) then
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
      elsif (EV_CTL_FSM_PS = ADDR_LOAD) then
        saved_burst_size <= HEADER_NUM_DWORDS;
        burst_cnt <= HEADER_NUM_DWORDS;
      elsif (EV_CTL_FSM_PS = TX2EV_BUF_DATA or EV_CTL_FSM_PS = TX2EV_BUF_HEADER) then
        -- value of saved_burst_size preserved
        if (fifo_rd_en = '1' and burst_cnt /= 0) then
          burst_cnt <= burst_cnt - 1;
        end if;
      -- else
      --   saved_burst_size <= 0;          -- error ?!
      --   burst_cnt <= 0;
      end if;

      if (rdempty_a = '1') then
        assert (fifo_rd_en = '0')
          report "Try read from empty FIFO" severity ERROR;
      end if;

    end if;
  end process burst_calc_pr;


  -- 10.11.2	EV Address Generation ------------------------------------------------
  ev_data_addr_pr : process (ddr3_if_rst_n, ui_clk) is
  begin  -- process ev_data_addr_pr
    if ddr3_if_rst_n = '0' then               -- asynchronous reset (active low)
      ev_data_addr        <= EV_DATA_BASE_ADDR;
      ev_header_addr      <= EV_DATA_BASE_ADDR;
      ev_data_addr_offset <= EV_DATA_BASE_ADDR;
      -- ev_slotnum_ptr      <= (others => '0');
      ev_fsm_error_i1     <= '0';
      error_core_addr     <= '0';

    elsif ui_clk'EVENT and ui_clk = '1' then  -- rising clock edge

      if not( ( ev_data_addr >= EV_DATA_BASE_ADDR ) and ( ev_data_addr <= EV_DATA_END_ADDR ) ) then
        if (EV_CTL_FSM_PS = TX2EV_BUF_DATA) then
          error_core_addr <= '1';         -- Error: Selected address not in EV buffer
        end if;
      end if;

      if (EV_CTL_FSM_PS = ADDR_LOAD) then
      	ev_header_addr <= ev_data_addr;  -- header address
      end if;


      -- if (EV_CTL_FSM_PS = ADDR_LOAD) then
      if (EV_CTL_FSM_PS = IDLE and data_in_fifo) then -- !debug: 03/10/2023 must prepare before SET_ADDR_PARAMS
        if (ev_data_addr_offset > EV_DATA_END_ADDR) then -- !debug: 27/11/2023 was EV_DATA_END_ADDR - 2*EV_READING_SIZE
                                                                               -- now gap decremented in address map
          ev_data_addr_offset <= EV_DATA_BASE_ADDR;
        else
          -- !debug: 03/10/2023 commented  if (master_axi_state(2) = '0' and master_axi_state(4) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 32)) then   -- wait for grant
            -- ev_data_addr_offset <= ev_data_addr_offset + EV_READING_SIZE;  -- save next reading begin address
          ev_data_addr_offset <= unsigned(ev_wr_slot_addr_dest); -- save next reading begin address
          -- ev_data_addr_offset <= EV_DATA_BASE_ADDR; -- !debug: 19/10/2023 temporary constant
          -- end if;
        end if;

        -- if (ev_slotnum_ptr < to_unsigned((EV_NUM_OF_SLOTS), ev_slotnum_ptr'LENGTH)) then
        --   if (master_axi_state(2) = '0' and master_axi_state(4) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 32)) then   -- wait for grant
        --     ev_slotnum_ptr <= ev_slotnum_ptr + 1; -- next slot
        --   end if;
        -- else
        --   ev_slotnum_ptr <= (0 => '1', others => '0');  -- EV address overflow
        -- end if;

      end if;

      if (EV_CTL_FSM_PS = SET_ADDR_PARAMS and no_data_tx) then

        ev_data_addr <= ev_data_addr_offset;  -- goto next reading slot

      elsif ((EV_CTL_FSM_PS = TX2EV_BUF_DATA or EV_CTL_FSM_PS = TX2EV_BUF_HEADER) and fifo_rd_en = '1' and burst_cnt <= 1) then

        if (ev_data_addr > (EV_DATA_END_ADDR - saved_burst_size)) then
          assert (FALSE) report "Error: wrong EV reading size!!!" severity ERROR;
          ev_fsm_error_i1 <= '1';
        else
          ev_data_addr <= ev_data_addr + (saved_burst_size * 4); -- !debug: 22/01/2020
        end if;

      end if;

    end if;
  end process ev_data_addr_pr;

  xpm_hand_simple_1: xpm_hand_simple
    generic map (
      SLOW2FAST => TRUE,
      WIDTH     => DDR3_ADDR_WIDTH)
    port map (
      rst_n    => RESET_I,
      slow_clk => CLK_50Mhz,
      fast_clk => ui_clk,
      src_in   => std_logic_vector(ev_wr_slot_addr), -- !debug: 06/03/2024 check, use this or ev_wr_slot_addr_sampled
      dest_out => ev_wr_slot_addr_dest
    );

  -- EV_READING_EV_SLOTNUM <= ev_slotnum_ptr;


  -- EV block <-> arbiter control
  ev_ctl_fsm_pr : process (ddr3_if_rst_n, ui_clk) is
  begin
    if ddr3_if_rst_n = '0' then
      EV_CTL_FSM_PS    <= IDLE;
      no_data_tx <= TRUE;
      master_axi_state_r <= '0';
      axi_if_req <= '0';
      axi_wait_cnt <= 0;
      gnt_catch <= '0';
    elsif ui_clk'EVENT and ui_clk = '1' then

      if (new_reading_begin_ui_clk) then
        no_data_tx <= TRUE;      -- when not transfer Reading data
        assert (rdempty_a = '1') report "EV FIFO not empty, when reading begin!!!" severity FAILURE;
      end if;

      master_axi_state_r <= master_axi_state(0);
      axi_if_req <= '0';
      gnt_catch <= '0';

      case EV_CTL_FSM_PS is

        when IDLE =>
          if (data_in_fifo) then
            EV_CTL_FSM_PS <= SET_ADDR_PARAMS;
          end if;

        when SET_ADDR_PARAMS =>
          if (no_data_tx) then            -- 1st write in Reading
            EV_CTL_FSM_PS <= ADDR_LOAD;
          else
            -- EV_CTL_FSM_PS <= TX2EV_BUF_DATA;  -- continue transfer Sorter data
            EV_CTL_FSM_PS <= SET_DATA_PARAMS;
          end if;
          axi_wait_cnt <= MAX_AXI_GRANT_WAIT;
          axi_if_req <= '1';

        when ADDR_LOAD =>
          if (axi_wait_cnt /= 0) then
            axi_wait_cnt <= axi_wait_cnt - 1;
          end if;
          if (master_axi_state(2) = '0' and master_axi_state(4) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4)) then  -- wait for grant
            if (rdusedw_a(5) = '1' or rdusedw_a(6) = '1') then  -- 11/03/2024 prevent start read before header in FIFO
              EV_CTL_FSM_PS <= TX2EV_BUF_HEADER; -- send header (header with data, but address goes to next offset)
            end if;
          end if;
          axi_if_req <= '1';
          if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
            gnt_catch <= '1';
          end if;

        when TX2EV_BUF_HEADER =>
          if (fifo_rd_en = '1' and burst_cnt <= 1) then  -- data was sent to DDR
            EV_CTL_FSM_PS <= WAIT4DONE;
          end if;
          no_data_tx <= FALSE;
          axi_if_req <= '1';
          gnt_catch <= '1';

        when SET_DATA_PARAMS =>
          if (axi_wait_cnt /= 0) then
            axi_wait_cnt <= axi_wait_cnt - 1;
          end if;
          if (master_axi_state(2) = '0' and master_axi_state(4) = '1' and axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 4)) then -- wait for grant
            EV_CTL_FSM_PS <= TX2EV_BUF_DATA;
          end if;
          axi_if_req <= '1';
          if (axi_wait_cnt < (MAX_AXI_GRANT_WAIT - 2)) then
            gnt_catch <= '1';
          end if;

        when TX2EV_BUF_DATA =>
          if (fifo_rd_en = '1' and burst_cnt <= 1) then -- 19/12/2016
            EV_CTL_FSM_PS <= WAIT4DONE;
          end if;
          axi_if_req <= '1';
          gnt_catch <= '1';

        when WAIT4DONE =>
          if (master_axi_state(0) = '1') then -- !debug: 15/01/2020
          -- if (wait_data_done_cnt = 0) then
            if (not data_in_fifo and rdempty_a = '0') then -- end packet, data < BURST_SIZE
              assert (FALSE) report "Error: No avaliable enough data in FIFO" severity ERROR;
            end if;
            EV_CTL_FSM_PS <= IDLE;
            assert (burst_cnt = 0) report "Burst length error!" severity ERROR;
          end if;

      end case;

    end if;
  end process ev_ctl_fsm_pr;


  -- done_cnt_pr : process (RESET_128, TOP_CLK_MEM_128M) is
  -- begin  -- process done_cnt_pr
  --   if RESET_128 = '0' then
  --     wait_data_done_cnt <= 15; -- !debug, 7,15;
  --   elsif TOP_CLK_MEM_128M'EVENT and TOP_CLK_MEM_128M = '1' then
  --     if (EV_CTL_FSM_PS /= WAIT4DONE) then
  --       wait_data_done_cnt <= 15; -- !debug, 7,15;
  --     elsif (wait_data_done_cnt /= 0) then
  --       wait_data_done_cnt <= wait_data_done_cnt - 1;
  --     end if;
  --   end if;
  -- end process done_cnt_pr;


  ev_ctl_pr : process (ddr3_if_rst_n, ui_clk) is
  begin  -- process ev_ctl_pr
    if ddr3_if_rst_n = '0' then

      start_write_i <= '0';
      burst_len   <= (others => '0');
      waddr_offset   <= (others => '0');

    elsif ui_clk'event and ui_clk = '1' then

      if (not start_new_burst_r and start_new_burst) then -- 19/01/2020 requires accepts pulse
        if (EV_CTL_FSM_PS = TX2EV_BUF_HEADER or EV_CTL_FSM_PS = TX2EV_BUF_DATA) then
          start_write_i <= '1';
        end if;
      else
        start_write_i <= '0';
      end if;

      if (EV_CTL_FSM_PS = TX2EV_BUF_HEADER  and rdempty_a = '0') then               -- write header to EV data buffer

        burst_len <= std_logic_vector(to_unsigned(HEADER_NUM_DWORDS, burst_len'length));
        waddr_offset <= std_logic_vector(resize(ev_header_addr, waddr_offset'length));

      elsif (EV_CTL_FSM_PS = TX2EV_BUF_DATA) then                             -- write Sorter data to EV data buffer

        burst_len <= std_logic_vector(to_unsigned(saved_burst_size, burst_len'length));  -- 18/12/2016
        waddr_offset <= std_logic_vector(resize(ev_data_addr, waddr_offset'length));

      end if;

    end if;
  end process ev_ctl_pr;

  start_write <= start_write_i; -- 19/01/2020

  -- ------------------------------------------------------------------------------
  -- -- ECC encoder
  -- ------------------------------------------------------------------------------
  -- -- note: 19/01/2017 if encoder and DATA_IN valid not each clock, then valid CHECK_BITS_OUT must be when DATA_IN strobe delayed to one clock
  -- -- !debug: 09/03/2017 SYSTEM_CLK64 -> ui_clk
  -- ddr_hamming_1 : ddr_hamming
  --   generic map (
  --     ENCODER => TRUE)
  --   port map (
  --     CLK                => ui_clk,
  --     RESET_I            => ddr3_if_rst_n,
  --     DATA_IN            => ecc_data_in,
  --     CHECK_BITS_IN      => std_logic_vector'(X"00"),
  --     RD_DATA_READY      => '0',
  --     DATA_OUT           => open,
  --     CHECK_BITS_OUT     => ev_ecc_data,
  --     ECC_ERROR          => open,
  --     ECC_DOUBLE_ERROR   => open,
  --     ECC_ERROR_LOCATION => open,
  --     DDR_HAMMING_TP     => open
  --   );


  ecc_enc_misc_pr: process (CLK_50Mhz, RESET_I) is
  begin  -- process ecc_enc_misc_pr
    if (RESET_I = '0') then               -- asynchronous reset (active low)
      -- ecc_data_in_even <= '0';
      -- ecc_data_in <= (others => '0');
      ecc2fifo <= '0';
      fifo_wr_cnt <= 0;
      packet_size_sig <= 0;
      do_packet_size_comp <= FALSE;
    elsif (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge

      -- if(EVOLVING_PRE_FRAME_START = '1') then
      --   ecc_data_in_even <= '0';
      -- elsif (ev_data_ready_r or ev_data_ready_r2) then -- !debug: 09/03/2017
      --   ecc_data_in_even <= not ecc_data_in_even;
      -- end if;

      -- if (ecc_data_in_even = '0') then
      --   ecc_data_in(31 downto 0) <= evolving_dout_r;
      -- else
      --   ecc_data_in(63 downto 32) <= evolving_dout_r;
      -- end if;

      -- if (fifo_wr_cnt >= packet_size_sig and ecc_rdempty = '0') then -- !debug: 22/01/2017
      --   ecc2fifo <= '1';
      -- else
      --   ecc2fifo <= '0';
      -- end if;

      ecc2fifo <= '0';                  -- !TODO: 27/06/2023 NU, remove
      ecc_rdreq <= '0';                  -- !TODO: 27/06/2023 NU, remove

      if(new_reading_begin and not new_reading_begin_r) then
        fifo_wr_cnt <= 0;
      elsif (ecc2fifo = '1') then       -- written ECC
        if (ecc_rdreq = '1') then
          fifo_wr_cnt <= fifo_wr_cnt + 1;
        end if;
      else                              -- written data
        if (wrreq_a = '1' and fifo_wr_cnt < 2047) then -- 27/05/2025
          fifo_wr_cnt <= fifo_wr_cnt + 1;
        end if;
      end if;

      -- packet size compare:
      --   - calc_packet_size updates, when scan header received
      --   - packet_size_sig updates, when data received
      do_packet_size_comp <= (EV_DATA_FSM_PS = ECC_DATA_WAIT);

      if ((EVOLVING_DATA_EN = '1' and init_done_all_64m(1) = '1') and not ev_data_ready_r) then -- data strobe rise
        packet_size_sig <= 2047;                   -- max packet size
      -- elsif (not ev_data_ready_r and ev_data_ready_r2) then -- data strobe fall
      elsif (EV_DATA_FSM_PS = ECC_DATA_WAIT) then
        packet_size_sig <= fifo_wr_cnt; -- real packet size,
                                        -- check: <slice size (DW)> * <FQ num_of_slices> / <merge factor> + <header size>
                                        -- ex for 16 slices and merge factor 2: 16*16/2+32=288
      end if;

    end if;
  end process ecc_enc_misc_pr;


  -- -- Pack 4x bytes ECC out to single ECC DW
  -- -- !debug: 09/03/2017 SYSTEM_CLK64 -> ui_clk
  -- ecc_pack_p : process(ui_clk, ddr3_if_rst_n)
  -- begin
  --   if (ddr3_if_rst_n = '0') then
  --     ecc_pack_counter  <= 0;
  --     ecc_pack_register <= (others => '0');
  --     ecc_wrreq         <= '0';
  --     ecc_wrreq_en      <= '0';
  --     ecc_rdreq         <= '0';
  --     ecc_rd_debug_cnt <= 0;
  --   elsif rising_edge(ui_clk) then
  --
  --     if (ev_data_ready_r2) then
  --       ecc_wrreq_en <= not ecc_data_in_even;
  --     else
  --       ecc_wrreq_en <= '0';
  --     end if;
  --
  --
  --     if(EVOLVING_PRE_FRAME_START = '1') then  -- packet start
  --       -- !debug: 12/07/2017 was ecc_pack_counter 0 to 3, now 3 downto 0
  --       ecc_pack_counter <= 3; -- 0
  --       ecc_wrreq <= '0';
  --     else
  --       if (ecc2fifo = '0') then
  --         if (ecc_wrreq_en = '1') then
  --           if (ecc_pack_counter = 0) then -- 3
  --             ecc_pack_counter <= 3;       -- 0
  --             ecc_wrreq <= '1'; -- Write data when register is filled
  --           else
  --             ecc_pack_counter <= ecc_pack_counter - 1; -- +
  --             ecc_wrreq <= '0';
  --           end if;
  --         else
  --           ecc_wrreq <= '0';
  --         end if;
  --
  --         ecc_pack_register((8*((3 - ecc_pack_counter) + 1) - 1) downto (8*(3 - ecc_pack_counter))) <= ev_ecc_data;
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
  --     else                              -- !debug: 01/07/2018
  --       ecc_rdreq <= '0';
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


  -- EV data buffer
  -- Input both EV data and ECC data: PACKET_SIZE + PACKET_SIZE/(2*4) = 80 + 80/8 = 90 !debug: 19/01/2017 wrusedw_a = 89 - OK
  -- !debug: 24/01/2017 differences:
  --   - fifo_wr /= wrreq_a because wrreq_a uses for all writes (addr,data,header + ECC), fifo_wr uses for write ECC
  --   - to EV_DATA_FSM_PS added new state - ECC_DATA, then wrreq_a must be active when reads ECC from dcfifo_ecc FIFO
  -- !debug: 09/03/2017 SYSTEM_CLK64 -> TOP_CLK_MEM_128M
  --dcfifo_a : dcfifo
  --  generic map (
  --    lpm_width              => 32,
  --    lpm_numwords           => 512,
  --    lpm_widthu             => 9,
  --    intended_device_family => "Cyclone V",
  --    lpm_type               => "dcfifo",
  --    lpm_showahead          => "ON",
  --    clocks_are_synchronized => "TRUE",
  --    overflow_checking      => "ON",
  --    underflow_checking     => "ON",
  --    use_eab                => "ON"
  --    )
  --  port map (
  --    wrclk   => TOP_CLK_MEM_128M, -- !debug: 09/03/2017 now same WR/RD clocks, was  CLK_50Mhz
  --    rdreq   => rdreq_a,
  --    aclr    => "not"(RESET_128),
  --    rdclk   => TOP_CLK_MEM_128M,
  --    wrreq   => wrreq_a,
  --    data    => muxed_data_r,
  --    rdempty => rdempty_a,
  --    wrusedw => wrusedw_a,
  --    wrfull  => wrfull_a,
  --    q       => local_wdata_e_a_i,
  --    rdusedw => rdusedw_a
  --  );                                --  FIFO_512X32_DC
  -- !debug: 31/12/2019 was dcfifo_1024x32
  dcfifo_a : dcfifo_512x32
    port map (
      rst           => "not"(ddr3_if_rst_n),
      wr_clk        => CLK_50Mhz,
      rd_clk        => ui_clk,
      din           => muxed_data_r,
      wr_en         => wrreq_a,
      rd_en         => fifo_rd_en, -- rdreq_a,
      dout          => fifo_axi_wdata, -- local_wdata_e_a_i,
      full          => wrfull_a,
      overflow      => overflow_a, -- open,
      empty         => rdempty_a,
      valid         => fifo_wdata_valid,  -- data strobe to DDR3
      underflow     => underflow_a, -- open,
      rd_data_count => rdusedw_a,
      wr_data_count => wrusedw_a
    );                                  -- FQ data FIFO


  -- -- ECC FIFO
  -- -- ECC output to ECC FIFO
  -- -- ev_ecc_data_wr
  -- -- !debug: 31/12/2019 was dcfifo_256x32
  -- dcfifo_ecc : dcfifo_512x32
  --   port map (
  --     rst           => "not"(ddr3_if_rst_n),
  --     wr_clk        => ui_clk, -- !debug: 20/02/2017 now same WR/RD clocks, was  CLK_50Mhz,
  --     rd_clk        => ui_clk,
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
  sim_check_pr: process (CLK_50Mhz) is
    variable header_word_cnt : natural range 0 to 63 := 0;  -- 2x header word in 1
    variable ev_num_of_slices_from_header_v : std_logic_vector(6 downto 0) := (others => '0');
    variable DataType_from_header_v : std_logic_vector(2 downto 0) := (others => '0');
    variable StreamType_from_header_v : std_logic_vector(2 downto 0) := (others => '0');
    variable reading_num_from_header_v : std_logic_vector(15 downto 0) := (others => '0'); -- LSW
    variable slice_merging_factor_from_header_v : std_logic_vector(1 downto 0) := (others => '0');
    variable fs_merging_factor_from_header_v : std_logic_vector(1 downto 0) := (others => '0');
    variable rlt_address_from_header_v : std_logic_vector(31 downto 0) := (others => '0');
    variable tmb_header_v : std_logic_vector(31 downto 0) := (others => '0');
    variable stamp_v : std_logic_vector(15 downto 0) := (others => '0');
  begin  -- process sim_check_pr
    if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge
      if (EV_DATA_FSM_PS = WAIT4HEADER) then
        header_word_cnt := 0;
      elsif (EV_DATA_FSM_PS = DATA2HEADER) then
        header_word_cnt := header_word_cnt + 1;
      end if;
      tmb_header_v := tmb_header(15 downto 0) & tmb_header(31 downto 16); -- words swap
      case header_word_cnt is
        when 0 => ev_num_of_slices_from_header_v := tmb_header_v(6 downto 0);
                  DataType_from_header_v := tmb_header_v(11+16 downto 9+16); -- 0x0 - Merged, 0x1 - HD
                  StreamType_from_header_v := tmb_header_v(15+16 downto 13+16); -- 0x1 - RLT, 0x2 - Buffered
        when 4 => reading_num_from_header_v := tmb_header_v(15 downto 0);
        when 10 => slice_merging_factor_from_header_v := tmb_header_v(11+16 downto 10+16);
                   fs_merging_factor_from_header_v := tmb_header_v(9+16 downto 8+16);
        when 29 => rlt_address_from_header_v := tmb_header_v;
        when 31 => stamp_v := tmb_header_v(31 downto 16);
        when others => null;
      end case;
      if (EV_DATA_FSM_PS = DATA2HEADER) then
        ev_wr_slot_addr_sampled <= unsigned(rlt_address_from_header_v(28 downto 0)); -- 15/01/2024
      end if;
      stamp_sampled <= stamp_v;
      ev_num_of_slices_from_header_sampled <= ev_num_of_slices_from_header_v;

    end if;
  end process sim_check_pr;

  EV_WR_COUNTER <= std_logic_vector(ev_wr_counter_cnt); -- EV Readings Written into buffer

  -- EV_FSM_ERROR <= ev_fsm_error_i1_64m or ev_fsm_error_i2_64m or ev_fsm_error_i3_64m;
  EV_FSM_ERROR <= ev_fsm_error_i1_64m or bad_header_stamp or wr_burst_error_64m or bad_packet_size or ev_wr_slot_addr_err;
  EV_ADDR_AREA_ERROR <= error_core_addr_sys_clk;
  EV_WR_BURST_ERROR <= wr_burst_error_64m;
  EV_WR_BAD_PACKET_SIZE <= bad_packet_size;
    
  EVOLVING_DDR3_WR_TP(0) <= error_core_addr;
  EVOLVING_DDR3_WR_TP(1) <= '1'; --  when (to_integer(unsigned(wrong_slice_reading_number)) = 0) else '0';
  EVOLVING_DDR3_WR_TP(2) <= '0' when (EV_CTL_FSM_PS = IDLE) else '1';
  EVOLVING_DDR3_WR_TP(31 downto 3) <= ( others => '0' );

 --add by Dalit 19/3/2024 timing issue solving------
  
    xpm_cdc_single_2 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => ev_fsm_error_i1_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => ev_fsm_error_i1  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );
	  
	 xpm_cdc_single_3 : xpm_cdc_single
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
	  
	 xpm_cdc_single_4 : xpm_cdc_single
    generic map (
      DEST_SYNC_FF   => 2,              -- DECIMAL; range: 2-10
      INIT_SYNC_FF   => 0,              -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      SIM_ASSERT_CHK => 0,              -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      SRC_INPUT_REG  => 1               -- DECIMAL; 0=do not register input, 1=register input
      )
    port map (
      dest_out => ev_fifo_notempty_128m_dst,             -- 1-bit output: src_in synchronized to the destination clock domain. This output
-- is registered.
      dest_clk => CLK_50Mhz,            -- 1-bit input: Clock signal for the destination clock domain.
      src_clk  => ui_clk,               -- 1-bit input: optional; required when SRC_INPUT_REG = 1
      src_in   => ev_fifo_notempty_128m  -- 1-bit input: Input signal to be synchronized to dest_clk domain.
      );

end architecture ar;
