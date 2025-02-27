-------------------------------------------------------------------------------
-- Title      : AMS memory_buffer interface
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : memory_buffer_if_tmp.vhd
-- Author     : Shinderman Eugene  <evgene@hbtech.co.il>
-- Company    : Philips Medical
-- Created    : 30/10/2022
-- Last update: 16/05/2024
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: prepare AMS ASIC's data for memory buffer or for TMB -> CDM payload
--  15/06/2023 version only for interface with data_sort_ddr3_wr
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_misc.all;
library work;

USE work.phoebe.all;
USE work.fs_merge_pack.all;

entity memory_buffer_if_tmp is
  generic (
    WORD_WIDTH : natural := 32);        -- byte,  consider change to 16bit
  port (
    sys_clk            : in  std_logic;  -- system clock @50MHz
    rst_n              : in  std_logic;
    IP50               : in  std_logic;
    Num_of_Slices      : in std_logic_vector(6 downto 0); -- note: this signal uses in slices_sorter, then not synced as others scan header words
    slice_merge        : in  std_logic;
    mu_ctl_reg         : in std_logic;
    rx_det_shl_reg     : in std_logic;                       -- [0] - '1' (default) if no MU use rx_det[16..1], '0' use rx_det[15..0]
    dummy_data_sel     : in  std_logic;
    test_ctl           : in std_logic_vector(7 DOWNTO 0);    -- 25/01/2024 [0] - READ_FSM_ERROR, [7..4] - select
    slice_merging_factor  : in std_logic_vector(1 DOWNTO 0);
    fs_merging_factor  : in std_logic_vector(1 DOWNTO 0); -- 17/12/2023
    fs_sequence_counter: in std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
    fs_merge_stop      : in std_logic;                    -- 30/03/2024
    sorter_data_ready  : in std_logic;                    -- 04/04/2024
    rlt_address_from_sync : in std_logic_vector(31 DOWNTO 0);
    make_data_from_sync : in std_logic; -- 05/05/2024
    stream_enable      : in std_logic_vector(1 downto 0);     -- FQ & EV
    fq_data_valid      : in  std_logic;  -- 30/10/2022
    fq_data_in         : in  std_logic_vector(31 downto 0);
    tmb_header_valid   : in std_logic;
    tmb_header         : in std_logic_vector (15 downto 0);
    params_ready       : out std_logic_vector(1 downto 0);  -- FQ & EV
    tmb_header_dout32  : out std_logic_vector (WORD_WIDTH-1 downto 0);
    tmb_header_rd      : in std_logic;
    ev_header_dout32   : out std_logic_vector (WORD_WIDTH-1 downto 0);
    ev_header_rd       : in std_logic;
    num_of_slices_no_merge : out std_logic_vector(6 downto 0);
    num_of_slices_after_merge : out std_logic_vector(6 downto 0);
    DATA_SORTER_DATA_EN: out std_logic;
    DATA_SORT_DOUT     : out std_logic_vector (WORD_WIDTH-1 downto 0);
    EVOLVING_DATA_EN   : out std_logic;
    EVOLVING_DOUT      : out std_logic_vector (WORD_WIDTH-1 downto 0)
    );
end entity memory_buffer_if_tmp;


architecture ar of memory_buffer_if_tmp is

  signal mem_buf_fifo_rd, ev_buf_fifo_rd, ev_buf_fifo_rd_masked : std_logic; -- , mem_buf_fifo_rd_r

  component header_fifo_dout32 is
  port (
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 15 downto 0 ); -- !debug: 19/01/2023 was 7
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    rd_data_count : out STD_LOGIC_VECTOR ( 5 downto 0 )
    );
  end component header_fifo_dout32;

  component header_fifo_rn is
  Port (
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 15 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 15 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 6 downto 0 )
  );
  end component header_fifo_rn;

  signal fifo_rn_wr_en : STD_LOGIC;
  signal fifo_rn_rd_en : STD_LOGIC;
  signal fifo_rn_dout : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal fifo_rn_full : STD_LOGIC;
  signal fifo_rn_empty : STD_LOGIC;
  signal fifo_rn_data_count : STD_LOGIC_VECTOR ( 6 downto 0 );

  component fq_fifo2048x32 is
  port (
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 11 downto 0 )
    );
  end component fq_fifo2048x32;

  signal header_fifo_data_count, ev_header_fifo_data_count : std_logic_vector ( 5 downto 0 );
  signal fq_fifo2048x16_data_count, ev_fifo2048x16_data_count : std_logic_vector ( 11 downto 0 );
  signal ev_header_ready, fq_header_ready : boolean;
  signal calc_data_ready, calc_ev_data_ready : unsigned(11 downto 0) := (others => '0');
  signal fq_fifo2048x16_dout, ev_fifo2048x16_dout : std_logic_vector ( 31 downto 0 );
  signal header_fifo_empty, fq_fifo2048x16_empty : std_logic;

  -- type DATA_SEQ_TYP is (IDLE_ST, EV_HEADER_RDY_ST, EV_HEADER_SEND_ST, FQ_HEADER_RDY_ST, FQ_HEADER_SEND_ST, FQ_DATA_RDY_ST, EV_DATA_RDY_ST);
  -- signal data_seq_ps : DATA_SEQ_TYP;
  type DATA_SEQ_TYP is (IDLE_ST, HEADER_RDY_ST, HEADER_SEND_ST, DATA_RDY_ST);
  signal ev_data_seq_ps, fq_data_seq_ps : DATA_SEQ_TYP;

  signal header_fifo_rn_wr_cnt, header_fifo_ev_wr_cnt : natural range 0 to 255;
  signal fq_fifo_wr_cnt : natural range 0 to 4095; -- for simulation only

  signal IP50_r, srst : std_logic; -- clear each IP
  signal tmb_header_dout_i, ev_header_dout_i : std_logic_vector (WORD_WIDTH-1 downto 0);
  signal ev_data_valid : std_logic;
  signal ev_data_in    : std_logic_vector(31 downto 0);

  component evolving_calc_ams is
    port (
      sys_clk          : in  std_logic;
      rst_n            : in  std_logic;
      slice_merge_en   : in  std_logic;                   -- slice merging enable
      fs_merge_en      : in  std_logic;                   -- slice merging enable
      num_of_slices    : in  std_logic_vector(6 downto 0);
      ev_num_of_slices : out std_logic_vector(6 downto 0);
      shift_val_o      : out natural range 0 to 7;
      merge_factor     : in  std_logic_vector(4 downto 0);
      fs_merging_factor : in std_logic_vector(1 DOWNTO 0);
      fs_merge_factor  : in std_logic_vector(3 downto 0);
      fs_sequence_counter: in std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
      start_over_1st   : in  std_logic;                     -- 03/03/2024
      fq_data_valid    : in  std_logic;
      fq_data_in       : in  std_logic_vector(31 downto 0);
      ev_header_en     : out std_logic;
      -- skip_wait2ev     : out std_logic; -- 31/12/2023
      ev_data_valid    : out std_logic;
      ev_data          : out std_logic_vector(31 downto 0));
  end component evolving_calc_ams;

  signal ev_num_of_slices, num_of_slices_saved : std_logic_vector(6 downto 0) := 7UX"10";
  signal shift_val : natural range 0 to 7;
  signal tmb_header_valid_4p_r0, tmb_header_valid_4p, tmb_header_valid_r00, tmb_header_valid_r0 : std_logic;
  signal tmb_header_4p, tmb_header_r0, tmb_header_4p_2_temp : std_logic_vector (15 downto 0);
  signal tmb_header_2_30_r00 : std_logic_vector (3 downto 0);

  signal merge_factor : std_logic_vector(4 downto 0);
  signal fs_merge_factor : std_logic_vector(3 downto 0);
  signal fq_stream_enable, ev_stream_enable : std_logic;
  signal fs_merging_factor_saved_next_ip : std_logic_vector(1 DOWNTO 0);
  signal fs_sequence_counter_saved_next_ip, fs_sequence_counter_saved_next_ip_r, fs_sequence_counter_saved, fs_sequence_counter_r : std_logic_vector(2 DOWNTO 0);
  signal fs_merge_en : std_logic;
  signal ev_header_en, skip_wait2ev : std_logic := '1';
  signal first_reading_from_merging, last_reading_from_merging : std_logic := '0';
  signal partial_frame : std_logic := '0'; -- , partial_frame_tmp
  signal scan_first_reading, scan_first_reading_r, scan_last_reading, scan_data_valid : std_logic := '0';
  signal fs_sequence_counter_changed : boolean;
  signal fix_delayed_last_flag_cnt : natural range 0 to 15;
  signal ev_reading_number2write, reading_number_buffer_out : std_logic_vector (31 downto 0); -- for simulation
  signal reading_number2write_msw_saved : std_logic_vector (15 downto 0); -- 15/05/2024
  signal reading_number_buffer_tmp : std_logic_vector (16*32-1 downto 0); -- for test
  signal save_en : boolean;             -- for test
  signal timeout_cnt : natural range 0 to 1023;
  signal no_header_data_err : std_logic;
  signal start_over_1st, start_over_1st_r, make_data_from_sync_r, fifo_rn_rd_srst : std_logic;

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of header_fifo_data_count, fq_fifo2048x16_data_count,
    reading_number_buffer_out, no_header_data_err, scan_first_reading, scan_last_reading, scan_data_valid, ev_header_en, first_reading_from_merging, last_reading_from_merging : signal is "true";
  attribute DONT_TOUCH of ev_data_seq_ps, fq_data_seq_ps : signal is "true";
  attribute DONT_TOUCH of ev_reading_number2write, tmb_header_4p : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of header_fifo_data_count, fq_fifo2048x16_data_count,
    reading_number_buffer_out, no_header_data_err, scan_first_reading, scan_last_reading, scan_data_valid, ev_header_en, first_reading_from_merging, last_reading_from_merging : signal is "true";
  attribute mark_debug of ev_data_seq_ps, fq_data_seq_ps : signal is "true";
  attribute mark_debug of ev_reading_number2write, tmb_header_4p : signal is "true";


  signal tmb_header_4p_2_40_temp, tmb_header_4p_2_40_temp_val, tmb_header_4p_2_40_r : std_logic_vector(4 downto 0);
  signal tmb_header_4p_2_5_temp, tmb_header_4p_2_5_temp_val, tmb_header_4p_2_5_r, tmb_header_4p_2_6_temp, tmb_header_4p_2_6_temp_val, tmb_header_4p_2_6_r : std_logic;
  signal tmb_header_4p_3_temp_val, tmb_header_4p_3_temp, tmb_header_4p_3_r,
    tmb_header_4p_4_temp, tmb_header_4p_4_r, tmb_header_4p_5_temp, tmb_header_4p_5_r : std_logic_vector(15 downto 0);
  signal tmb_header_4p_4_temp_val, tmb_header_4p_5_temp_val : std_logic_vector(18 downto 0);
  signal tmb_header_4p_22_temp, tmb_header_4p_22_temp_val, tmb_header_4p_22_r : std_logic_vector(2 downto 0);
  signal reference_detector_fbad_detected : std_logic;
  -- signal is_avg_or : boolean;

begin  -- architecture ar


  -- header from RX @400MHz -> fifo.din = RX_series7.RX_det_o[7..0], fifo.wr_en = RX_series7.data_valid
  header_fifo_fq : header_fifo_dout32
    port map (
      clk   => sys_clk,
      srst   => srst,
      din   => tmb_header,
      wr_en => "and"(fq_stream_enable,tmb_header_valid), -- !debug: 30/11/2023 enable for header no delayed by IP
      rd_en => tmb_header_rd,
      dout  => tmb_header_dout_i,
      full  => open,
      empty => header_fifo_empty,
      rd_data_count => header_fifo_data_count
      );

  -- tmb_header_dout32 <= tmb_header_dout_i(15 downto 0) & tmb_header_dout_i(31 downto 16); -- swap
  tmb_header_dout32 <= tmb_header_dout_i; -- 09/11/2023 no swap

  -- EV patched scan header
  header_fifo_ev : header_fifo_dout32
    port map (
      clk   => sys_clk,
      srst   => srst,
      din   => tmb_header_4p,
      wr_en => tmb_header_valid_4p,
      rd_en => ev_header_rd,
      dout  => ev_header_dout_i,
      full  => open,
      empty => open,
      rd_data_count => ev_header_fifo_data_count
      );

  -- ev_header_dout32 <= ev_header_dout_i(15 downto 0) & ev_header_dout_i(31 downto 16); -- swap
  ev_header_dout32 <= ev_header_dout_i; -- 09/11/2023 no swap

  fq_fifo2048x32_1 : fq_fifo2048x32
    port map (
      clk   => sys_clk,
      srst  => srst,
      din   => fq_data_in,
      wr_en => "and"(fq_stream_enable,fq_data_valid),
      rd_en => mem_buf_fifo_rd,
      dout  => fq_fifo2048x16_dout,
      full  => open,
      empty => fq_fifo2048x16_empty,
      data_count => fq_fifo2048x16_data_count
      );


  -- !debug: 17/08/2023 temporary EV buffer
  ev_fifo2048x32_1 : fq_fifo2048x32
    port map (
      clk   => sys_clk,
      srst  => srst,
      din   => ev_data_in,
      wr_en => ev_data_valid,           -- after EV calc
      rd_en => ev_buf_fifo_rd_masked,
      dout  => ev_fifo2048x16_dout,
      full  => open,
      empty => open,
      data_count => ev_fifo2048x16_data_count
      );


  misc_pr: process (sys_clk, rst_n) is
  begin  -- process misc_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      srst <= '1';
      header_fifo_ev_wr_cnt <= 0;
      header_fifo_rn_wr_cnt <= 0;
      fq_fifo_wr_cnt <= 0;
      tmb_header_valid_4p <= '0';
      tmb_header_valid_r0 <= '0';
      tmb_header_valid_r00 <= '0';
      tmb_header_4p <= (others => '0');
      tmb_header_r0 <= (others => '0');
      tmb_header_2_30_r00 <= (others => '0');
      merge_factor <= (others => '0');
      fs_merge_factor <= (others => '0');
      fq_stream_enable <= '0';
      ev_stream_enable <= '0';
      num_of_slices_saved <= 7UX"10";
      fs_merging_factor_saved_next_ip <= (others => '0');
      IP50_r <= '0';
      ev_reading_number2write <= (others => '0');
      reading_number_buffer_tmp <= (others => '0');
      save_en <= TRUE;
      reading_number_buffer_out <= (others => '0');
      fs_sequence_counter_saved <= (others => '0');
      fs_sequence_counter_saved_next_ip <= (others => '0');
      fs_sequence_counter_saved_next_ip_r <= (others => '0');
      fs_sequence_counter_r <= (others => '0');
      start_over_1st <= '0';
      start_over_1st_r <= '0';
      make_data_from_sync_r <= '0';
      fifo_rn_rd_srst <= '0';
      fs_sequence_counter_changed <= FALSE;
      first_reading_from_merging <= '0';
      last_reading_from_merging <= '0';
      scan_first_reading <= '0';
      scan_first_reading_r <= '0';
      scan_last_reading <= '0';
      fix_delayed_last_flag_cnt <= 0;
      reference_detector_fbad_detected <= '0';
      partial_frame <= '0';
      -- partial_frame_tmp <= '0';
      tmb_header_4p_2_temp <= (others => '0');
      tmb_header_4p_2_40_temp_val <= (others => '0');
      tmb_header_4p_2_5_temp_val <= '0';
      tmb_header_4p_2_6_temp_val <= '0';
      tmb_header_4p_3_temp_val <= (others => '0');
      tmb_header_4p_4_temp_val <= (others => '0');
      tmb_header_4p_5_temp_val <= (others => '0');
      tmb_header_4p_22_temp_val <= (others => '0');
      tmb_header_4p_2_40_r <= (others => '0');
      tmb_header_4p_2_5_r <= '0';
      tmb_header_4p_2_6_r <= '0';
      tmb_header_4p_3_r <= (others => '0');
      tmb_header_4p_4_r <= (others => '0');
      tmb_header_4p_5_r <= (others => '0');
      tmb_header_4p_22_r <= (others => '0');
      reading_number2write_msw_saved <= (others => '0');
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      srst <= '0'; -- !debug: 28/11/2023 was   IP50;

      assert "not"((header_fifo_empty = '1' and tmb_header_rd = '1') or
                   (fq_fifo2048x16_empty = '1' and mem_buf_fifo_rd = '1'))
        report "Try read from empty FIFO" severity ERROR;

      if (tmb_header_valid_4p_r0 = '0') then -- !debug: 26/03/2024 was   tmb_header_valid_r0
        header_fifo_ev_wr_cnt <= 0;
      elsif (tmb_header_valid_4p_r0 = '1') then -- !debug: 26/03/2024 was   tmb_header_valid_r0
        header_fifo_ev_wr_cnt <= header_fifo_ev_wr_cnt + 1;
      end if;

      if (tmb_header_valid = '0') then  -- 27/03/2024
        header_fifo_rn_wr_cnt <= 0;
      else
        header_fifo_rn_wr_cnt <= header_fifo_rn_wr_cnt + 1;
      end if;

      -- !debug: 25/01/2024 only for test
      if (tmb_header_valid_r0 = '1' and header_fifo_ev_wr_cnt = 0) then  -- latch on start
        if (save_en) then
          reading_number_buffer_tmp <= reading_number_buffer_tmp(16*32-33 downto 0) & ev_reading_number2write;
        end if;
        if (test_ctl(0) = '1') then     -- stop, when error
          save_en <= FALSE;
        else
          if (TRUE) then  -- option: set driver
            save_en <= TRUE;
          else
            null;                       -- hold test buffer
          end if;
        end if;
      end if;
      reading_number_buffer_out <= reading_number_buffer_tmp(32*to_integer(unsigned(test_ctl(7 downto 4)))+31 downto 32*to_integer(unsigned(test_ctl(7 downto 4)))+0);

      if (fq_data_valid = '0') then
        fq_fifo_wr_cnt <= 0;
      elsif (fq_data_valid = '1') then
        fq_fifo_wr_cnt <= fq_fifo_wr_cnt + 1; -- for simulation only
      end if;

      tmb_header_valid_r00 <= tmb_header_valid;
      tmb_header_valid_r0 <= tmb_header_valid_r00;

      tmb_header_valid_4p_r0 <= fifo_rn_rd_en; -- !debug: 26/03/2024
      tmb_header_valid_4p <= tmb_header_valid_4p_r0; -- !debug: 26/03/2024

      -- if (unsigned(fs_sequence_counter) /= (unsigned(fs_merge_factor) - 1) or -- !debug: 05/04/2024
      --     fs_merging_factor = "00") then -- if last reading in FS cycle
        tmb_header_4p_2_40_r <= tmb_header_4p_2_40_temp;            -- W #2 [4..0]
        tmb_header_4p_2_5_r <= tmb_header_4p_2_5_temp;              -- W #2 [5]
        tmb_header_4p_2_6_r <= tmb_header_4p_2_6_temp;              -- W #2 [6]
        tmb_header_4p_3_r <= tmb_header_4p_3_temp;                  -- W #3
        tmb_header_4p_4_r <= tmb_header_4p_4_temp;                  -- W #4
        tmb_header_4p_5_r <= tmb_header_4p_5_temp;                  -- W #5
        tmb_header_4p_22_r <= tmb_header_4p_22_temp;                -- W #22
      -- end if;

      -- !debug: 21/03/2024 delay requires for R(n) support
      tmb_header_r0 <= fifo_rn_dout; -- !debug: 26/03/2024

      -- !debug: 26/03/2024 flags, related to make_data:
      case header_fifo_rn_wr_cnt is
        when 1 =>
          tmb_header_4p_2_temp <= tmb_header;
          if (tmb_header(3 downto 0) = X"2") then
            scan_data_valid <= '1';
          elsif (ev_header_en = '1' or ((scan_last_reading = '1' or tmb_header(5) = '1') and unsigned(fs_sequence_counter_saved) = 0)) then
            scan_data_valid <= '0';
          end if;
          scan_first_reading <= tmb_header(4);  -- NU, First reading of a shot
          if (fs_merging_factor = "00") then
            scan_last_reading <= tmb_header(5);  -- Last reading of a shot
            fix_delayed_last_flag_cnt <= 0;
          elsif (tmb_header(5) = '1' and fix_delayed_last_flag_cnt = 0) then -- 06/04/2024
            scan_last_reading <= tmb_header(5);  -- Last reading of a shot
            fix_delayed_last_flag_cnt <= to_integer(unsigned(fs_merge_factor)) - 1;      -- mask
          elsif (fix_delayed_last_flag_cnt /= 0) then
            fix_delayed_last_flag_cnt <= fix_delayed_last_flag_cnt - 1;
            if (fix_delayed_last_flag_cnt = 1) then
              scan_last_reading <= '0';
            end if;
          end if;
          if (fs_merging_factor /= "00") then  -- FS merging active and flag preserved for all FS merging cycle
            if (unsigned(fs_sequence_counter) = 0) then
              tmb_header_2_30_r00 <= tmb_header(3 downto 0); -- R(0)
            end if;

            if (unsigned(fs_sequence_counter) /= (unsigned(fs_merge_factor) - 1) and -- if not last reading in FS cycle
                unsigned(fs_sequence_counter) /= 0) then -- if not fist reading in FS cycle
              if (tmb_header(3 downto 0) /= tmb_header_2_30_r00) then
                partial_frame <= '1';   -- PartialFrame
              end if;
            else
              -- partial_frame_tmp <= '0';
              if (tmb_header(3 downto 0) /= tmb_header_2_30_r00 and
                  unsigned(fs_sequence_counter) /= 0) then -- if not fist reading in FS cycle
                partial_frame <= '1';
              else
                partial_frame <= '0';
              end if;
            end if;
          else                                             -- 05/04/2024
            tmb_header_2_30_r00 <= tmb_header(3 downto 0); -- R(0)
            partial_frame <= '0';
          end if;

          -- 30/03/2024 Last: Bit(5) = OR(R(0)(5)...R(n)(5))
          fs_or (
            data_in             => tmb_header(4 downto 0),
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val            => tmb_header_4p_2_40_temp_val,
            data_out            => tmb_header_4p_2_40_temp);
          -- 21/03/2024 Last: Bit(5) = OR(R(0)(5)...R(n)(5))
          fs_or (
            data_in(0)          => tmb_header(5),
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val(0)         => tmb_header_4p_2_5_temp_val,
            data_out(0)         => tmb_header_4p_2_5_temp);
          -- 21/03/2024 End of Series OR(R(0)(6) ... R(n)(6))
          fs_or (
            data_in(0)          => tmb_header(6),
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val(0)         => tmb_header_4p_2_6_temp_val,
            data_out(0)         => tmb_header_4p_2_6_temp);
        when 2 =>
          fs_or (
            data_in             => tmb_header,
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val            => tmb_header_4p_3_temp_val,
            data_out            => tmb_header_4p_3_temp);
        when 3 =>
          fs_avg (
            data_in             => tmb_header,
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val            => tmb_header_4p_4_temp_val,
            data_out            => tmb_header_4p_4_temp);
        when 4 =>
          -- 0xFBAD in reference detector
          if (unsigned(fs_sequence_counter_saved) = 0) then
            if (unsigned(tmb_header) = X"FBAD") then -- note: samples on previous clock (word #4)
              reference_detector_fbad_detected <= '1';
            else
              reference_detector_fbad_detected <= '0';
            end if;
          elsif (unsigned(tmb_header) = X"FBAD" or reference_detector_fbad_detected = '1') then
            reference_detector_fbad_detected <= '1';
          end if;
          fs_avg (
            data_in             => tmb_header,
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val            => tmb_header_4p_5_temp_val,
            data_out            => tmb_header_4p_5_temp);
        when 9 =>
          reading_number2write_msw_saved <= tmb_header; -- 15/05/2024 requires for calc ev_reading_number2write
        when 21 =>
          fs_or (
            data_in             => tmb_header(2 downto 0),
            fs_sequence_counter => fs_sequence_counter_saved,
            fs_merge_factor     => fs_merge_factor,
            fs_merging_factor   => fs_merging_factor,
            temp_val            => tmb_header_4p_22_temp_val,
            data_out            => tmb_header_4p_22_temp);
        when others => null;
      end case;

      -- EV scan header patch
      case header_fifo_ev_wr_cnt is        -- W# = header_fifo_ev_wr_cnt + 1
        when 0 =>
          tmb_header_4p(6 downto 0) <= ev_num_of_slices;
          tmb_header_4p(15 downto 7) <= tmb_header_r0(15 downto 7);
        when 1 =>
          if (scan_last_reading = '0') then -- 06/04/2024 not scan end latched
            --- tmb_header_4p(4 downto 0) <= tmb_header_r0(4 downto 0) or tmb_header_4p_2_40_r; -- 30/03/2024 First reading of a shot & Reading Type
            --- tmb_header_4p(5) <= tmb_header_r0(5) or tmb_header_4p_2_5_r; -- 28/03/2024 Last reading of a shot
            --- last_reading_from_merging  <= tmb_header_r0(5) or tmb_header_4p_2_5_r; -- only for LA
            tmb_header_4p(4 downto 0) <= tmb_header_r0(4 downto 0); -- 30/03/2024 First reading of a shot & Reading Type
            tmb_header_4p(5) <= tmb_header_r0(5); -- 28/03/2024 Last reading of a shot
            last_reading_from_merging  <= tmb_header_r0(5); -- only for LA
          else  -- scan_last_reading = '1'
            if (scan_data_valid = '1') then -- "normal" scan end: scan length / FS merging = 0
              tmb_header_4p(4 downto 0) <= tmb_header_r0(4 downto 0) or tmb_header_4p_2_40_r;
              tmb_header_4p(5) <= '1'; -- fix tmb_header_4p[5..0]: [5] '1'
              last_reading_from_merging  <= '1'; -- only for LA
            else                       -- "bad" scan end (partial_frame)
              -- tmb_header_4p(0) <= tmb_header_r0(0) or tmb_header_4p_2_40_r(0);
              -- tmb_header_4p(1) <= '0'; -- fix tmb_header_4p[5..0]: [1] '0'
              -- tmb_header_4p(4 downto 2) <= tmb_header_r0(4 downto 2) or tmb_header_4p_2_40_r(4 downto 2);
              tmb_header_4p(4 downto 0) <= tmb_header_r0(4 downto 0) or tmb_header_4p_2_40_r; -- !debug: 14/04/2024 data valid also in case of partial_frame
              tmb_header_4p(5) <= partial_frame; -- fix tmb_header_4p[5..0]: [5] '0' !debug: 12/04/2024 was  '0'
              last_reading_from_merging  <= partial_frame; -- only for LA
            end if;
          end if;
          first_reading_from_merging <= tmb_header_r0(4) or tmb_header_4p_2_40_r(4); -- only for LA

          tmb_header_4p(6) <= tmb_header_r0(6) or tmb_header_4p_2_6_r; -- 28/03/2024 End of Series
          tmb_header_4p(8 downto 7) <= tmb_header_r0(7 downto 6);

          if (fs_merging_factor = "00" and slice_merging_factor = "00") then
            tmb_header_4p(11 downto 9) <= "001"; -- HD
          else -- when either Slice Merging or Focal Spot Merging are activated
            tmb_header_4p(11 downto 9) <= "000"; -- Merged
          end if;
          tmb_header_4p(12) <= tmb_header_r0(12);
          tmb_header_4p(15 downto 13) <= "001"; -- RLT stream
          -- tmb_header_4p(13 downto 12) <= tmb_header(13 downto 12);  -- !debug: 07/12/2023 temporary, correct ^^^
          -- tmb_header_4p(15 downto 14) <= "01"; -- RLT stream
          -- note: X"22XX" when HD Data Type (not merged), else X"20XX"
        when 2 =>
          tmb_header_4p <= tmb_header_r0 or tmb_header_4p_3_r; -- DMS Errors
        when 3 =>
          tmb_header_4p <= tmb_header_r0 or tmb_header_4p_4_r;
        when 4 =>
          tmb_header_4p <= X"FBAD" when (reference_detector_fbad_detected = '1') else tmb_header_4p_5_r;
        when 8|56 =>
          tmb_header_4p <= tmb_header_r0 srl to_integer(unsigned(fs_merging_factor)); -- Reading_Number LSW
          if (fs_merging_factor /= "00" and reading_number2write_msw_saved(0) = '1') then -- 15/05/2024
            tmb_header_4p(15) <= '1';
          else                                          
            null;
          end if;
          if (tmb_header_valid_4p = '1') then
            ev_reading_number2write(15 downto 0) <= tmb_header_r0 srl to_integer(unsigned(fs_merging_factor));
            if (fs_merging_factor /= "00" and reading_number2write_msw_saved(0) = '1') then -- 15/05/2024
              ev_reading_number2write(15) <= '1';
            else                                          
              null;
            end if;
          end if;
        when 9|57 =>
          tmb_header_4p <= tmb_header_r0 srl to_integer(unsigned(fs_merging_factor)); -- Reading_Number MSW
          if (tmb_header_valid_4p = '1') then
            ev_reading_number2write(31 downto 16) <= tmb_header_r0 srl to_integer(unsigned(fs_merging_factor));
          end if;
        when 20 =>
          tmb_header_4p(5 downto 0) <= tmb_header_r0(5 downto 0);
          tmb_header_4p(6) <= partial_frame; -- BAD READING
          tmb_header_4p(15 downto 7) <= tmb_header_r0(15 downto 7);
        when 21 =>
          tmb_header_4p(2 downto 0) <= tmb_header_r0(2 downto 0) or tmb_header_4p_22_r;
          tmb_header_4p(5 downto 3) <= tmb_header_r0(3) & tmb_header_r0(3) & tmb_header_r0(3);
          tmb_header_4p(7 downto 6) <= tmb_header_r0(4) & tmb_header_r0(4);
          tmb_header_4p(9 downto 8) <= fs_merging_factor;
          tmb_header_4p(11 downto 10) <= slice_merging_factor;
          if (fs_merging_factor /= "00") then
            tmb_header_4p(15 downto 12) <= X"0";
          else
            tmb_header_4p(15 downto 12) <= tmb_header_r0(15 downto 12);
          end if;
        when 23 =>
          -- [13] - PartialFrame is determined at Header word#2 paragraph
          tmb_header_4p(12 downto 0) <= tmb_header_r0(12 downto 0);
          tmb_header_4p(13) <= partial_frame; -- BAD READING
          tmb_header_4p(15 downto 14) <= tmb_header_r0(15 downto 14);
        when 37 =>
          tmb_header_4p(7 downto 0) <= tmb_header_r0(7 downto 0);
          if (dummy_data_sel = '1') then
            tmb_header_4p(11 downto 8) <= X"3";  -- Test Pattern - incremental numbers along detectors
          elsif (mu_ctl_reg = '1') then
            tmb_header_4p(11 downto 8) <= X"0"; -- MU logged data
          elsif (rx_det_shl_reg = '0') then
            tmb_header_4p(11 downto 8) <= X"1"; -- Intensity - 16bit (detector raw data bits[15..0])
          elsif (rx_det_shl_reg = '1') then
            tmb_header_4p(11 downto 8) <= X"2"; -- Intensity - 16bit (detector raw data bits[16..1])
          end if;
          tmb_header_4p(15 downto 12) <= tmb_header_r0(15 downto 12);
        when 58 =>
          tmb_header_4p <= rlt_address_from_sync(15 downto 0);
        when 59 =>
          tmb_header_4p <= rlt_address_from_sync(31 downto 16);
        when others => tmb_header_4p <= tmb_header_r0;
      end case;

      -- merge factor from SYNC packet footer
      merge_factor <= 5UX"1" sll to_integer(unsigned(slice_merging_factor));
      fs_merge_factor <= X"1" sll to_integer(unsigned(fs_merging_factor));

      IP50_r <= IP50;
      if (IP50 = '1' and IP50_r = '0') then -- note: in this stage uses tile data from previous IP, then also params must be delayed by IP
        num_of_slices_saved <= Num_of_Slices;         -- !debug: 01/02/2024
        fs_merging_factor_saved_next_ip <= fs_merging_factor;
        fs_sequence_counter_saved_next_ip <= fs_sequence_counter;
        fs_sequence_counter_saved_next_ip_r <= fs_sequence_counter_saved_next_ip;
      end if;
      -- if (sorter_data_ready = '1') then -- !debug: 05/04/2024
        fs_sequence_counter_saved <= fs_sequence_counter; -- 04/04/2024
      -- end if;

      if (fq_data_seq_ps = IDLE_ST) then -- 18/04/2024
        ev_stream_enable <= stream_enable(0); -- FQ & EV option: update driver, like FQ
        fq_stream_enable <= stream_enable(1); -- !debug: 25/03/2024 was sysnced to IP
      end if;

      fs_sequence_counter_r <= fs_sequence_counter;          -- 04/03/2024
      if (fs_sequence_counter_r /= fs_sequence_counter) then -- counter changed value received from footer
        fs_sequence_counter_changed <= TRUE;
      elsif (IP50 = '1' and IP50_r = '0') then
        fs_sequence_counter_changed <= FALSE;
      end if;
      if (fs_sequence_counter_changed) then
        if (fs_merging_factor_saved_next_ip /= fs_merging_factor or -- FS merge factor changed, but not to zero
            (unsigned(fs_sequence_counter_saved_next_ip) /= (unsigned(fs_merge_factor) - 1) and unsigned(fs_sequence_counter) = "000")) then -- incomplete FS merging process

          start_over_1st <= '1';        -- !debug: 04/04/2024 merging factor change
        else
          start_over_1st <= '0';
        end if;
      elsif (fs_merging_factor_saved_next_ip /= "00" and fs_merging_factor = "00") then -- end FS merging

        if (unsigned(fs_sequence_counter_saved) /= (unsigned(fs_merge_factor) - 1)) then --  and unsigned(fs_sequence_counter) = "000"
          start_over_1st <= '1';  -- !debug: 05/05/2024 incomplete FS merging process
        else
          start_over_1st <= '0';
        end if;
      elsif (scan_first_reading = '1' and
             fs_merging_factor /= "00" and unsigned(fs_sequence_counter_saved_next_ip) /= (unsigned(fs_merge_factor) - 1)) then
        if (fs_merging_factor_saved_next_ip /= "00" and scan_first_reading_r = '0') then             -- not FS merge start, but case fs_sequence_counter 0, 0
          start_over_1st <= '1'; -- !debug: 02/05/2024 when MAKE_DATA rise
        end if;
      else
        start_over_1st <= '0';
      end if;

      start_over_1st_r <= start_over_1st;
      make_data_from_sync_r <= make_data_from_sync;
      if (srst = '1' or fs_merge_stop = '1') then
        fifo_rn_rd_srst <= '1';
      elsif (make_data_from_sync = '1' and make_data_from_sync_r = '0') then -- when MAKE_DATA rise
        fifo_rn_rd_srst <= '1';
      elsif (make_data_from_sync = '0' and start_over_1st = '1' and start_over_1st_r = '0') then -- merging factor change
        fifo_rn_rd_srst <= '1';
      else
        fifo_rn_rd_srst <= '0';
      end if;

      scan_first_reading_r <= scan_first_reading;

    end if;
  end process misc_pr;


  fs_merge_en <= '1' when (fs_merging_factor /= "00") else '0';


  ev_data_seq_pr: process (sys_clk) is
  begin  -- process ev_data_seq_pr
    if (sys_clk'event and sys_clk = '1') then  -- rising clock edge
      if (rst_n = '0') then             -- synchronous reset (active low)
        ev_data_seq_ps <= IDLE_ST;
        ev_header_ready <= FALSE;
        ev_buf_fifo_rd <= '0';
        calc_ev_data_ready <= (11 => '1', others => '0');
      else

        case ev_data_seq_ps is
          when IDLE_ST =>
            if (IP50_r = '1' and IP50 = '0') then
              ev_data_seq_ps <= HEADER_RDY_ST; -- wait for 1st header
            end if;
            calc_ev_data_ready <= ('0' & unsigned(num_of_slices_saved) & "0000") srl shift_val;

          when HEADER_RDY_ST =>
            if (ev_header_fifo_data_count = 6UX"20" and  -- 0x20*4=128 bytes scan header
                ev_fifo2048x16_data_count >= std_logic_vector(resize(calc_ev_data_ready,ev_fifo2048x16_data_count'length)) and
                (fq_data_seq_ps = IDLE_ST or fq_data_seq_ps = HEADER_RDY_ST)) then -- 15/01/2024 EV header and data in FIFO and FQ not active
              ev_data_seq_ps <= HEADER_SEND_ST;
              ev_header_ready <= TRUE;
              -- note: here must be rise params_ready(0)
            end if;
            calc_ev_data_ready <= ('0' & unsigned(num_of_slices_saved) & "0000") srl shift_val;
            -- !TODO: 30/11/2023 option: error, if EV header not in FIFO

          when HEADER_SEND_ST =>
            -- note: here must be ev_header_rd, ev_header_dout32
            if ((ev_fifo2048x16_data_count >= std_logic_vector(resize(calc_ev_data_ready,ev_fifo2048x16_data_count'length))) and ev_header_fifo_data_count = 6UX"00") then           -- EV header read complete
              ev_data_seq_ps <= DATA_RDY_ST;
              -- note: here must be fall params_ready(0)
              ev_header_ready <= FALSE;
            end if;

          when DATA_RDY_ST =>
            if (ev_fifo2048x16_data_count > 12UX"001") then
              ev_buf_fifo_rd <= '1';
            else
              ev_data_seq_ps <= IDLE_ST; -- wait for next header !debug: 01/02/2024 was HEADER_RDY_ST;
              ev_buf_fifo_rd <= '0';
            end if;
        end case;

      end if;
    end if;
  end process ev_data_seq_pr;


  fq_data_seq_pr: process (sys_clk) is
  begin  -- process fq_data_seq_pr
    if (sys_clk'event and sys_clk = '1') then  -- rising clock edge
      if (rst_n = '0') then             -- synchronous reset (active low)
        fq_data_seq_ps <= IDLE_ST;
        fq_header_ready <= FALSE;
        mem_buf_fifo_rd <= '0';
        timeout_cnt <= 1023;
        no_header_data_err <= '0';
        calc_data_ready <= (11 => '1', others => '0');
      else

        case fq_data_seq_ps is
          when IDLE_ST =>
            if (IP50_r = '1' and IP50 = '0') then
              if (fq_stream_enable = '1') then
                fq_data_seq_ps <= HEADER_RDY_ST; -- wait for 1st header
              end if;
            end if;
            timeout_cnt <= 1023;
            calc_data_ready <= '0' & unsigned(num_of_slices_saved) & "0000"; -- ex: for 64 slices = 1024

          when HEADER_RDY_ST =>
            if ((fq_fifo2048x16_data_count >= std_logic_vector(resize(calc_data_ready,fq_fifo2048x16_data_count'length))) and header_fifo_data_count = 6UX"20") then -- 0x20*4=128 bytes scan header
                fq_data_seq_ps <= HEADER_SEND_ST;
                fq_header_ready <= TRUE; -- rise params_ready(1)
            else
              -- error, if FQ header not in FIFO
              if (timeout_cnt /= 0) then
                timeout_cnt <= timeout_cnt - 1;
                no_header_data_err <= '0';
              else
                no_header_data_err <= '1';
              end if;
            end if;
            calc_data_ready <= '0' & unsigned(num_of_slices_saved) & "0000"; -- ex: for 64 slices = 1024

          when HEADER_SEND_ST =>
            -- note: here DDR3 interface must send tmb_header_rd
            if (fq_stream_enable = '1') then
              if ((fq_fifo2048x16_data_count >= std_logic_vector(resize(calc_data_ready,fq_fifo2048x16_data_count'length))) and header_fifo_data_count = 6UX"00") then  -- FQ header read complete
                fq_data_seq_ps <= DATA_RDY_ST;
                fq_header_ready <= FALSE; -- note: here must be fall params_ready(1)
              end if;
            end if;

          when DATA_RDY_ST =>
            if (fq_fifo2048x16_data_count > 12UX"001") then
              mem_buf_fifo_rd <= '1';
            else
              if (fq_stream_enable = '1') then
                fq_data_seq_ps <= IDLE_ST; -- !debug: 01/02/2024 was HEADER_RDY_ST;
              end if;
              mem_buf_fifo_rd <= '0';
            end if;
        end case;

      end if;
    end if;
  end process fq_data_seq_pr;


  evolving_calc_ams_1: evolving_calc_ams
    port map (
      sys_clk          => sys_clk,
      rst_n            => rst_n,
      slice_merge_en   => slice_merge,
      fs_merge_en      => fs_merge_en,   -- 26/02/2024
      num_of_slices    => num_of_slices, -- !debug: 04/02/2024 NOT use num_of_slices for data merging!!!
      ev_num_of_slices => ev_num_of_slices,
      shift_val_o      => shift_val,
      merge_factor     => merge_factor, -- slice merge
      fs_merging_factor => fs_merging_factor, -- from SYNC packet footer, delayed for alignment with fs0_sync (DFS)
      fs_merge_factor  => fs_merge_factor,
      fs_sequence_counter => fs_sequence_counter, -- 07/02/2024
      start_over_1st   => start_over_1st,               -- 03/03/2024
      fq_data_valid    => fq_data_valid,
      fq_data_in       => fq_data_in,
      ev_header_en     => ev_header_en,
      -- skip_wait2ev     => skip_wait2ev, -- 31/12/2023
      ev_data_valid    => ev_data_valid,
      ev_data          => ev_data_in
    );


  header_fifo_rn_1 : header_fifo_rn
    port map (
      clk        => sys_clk,
      srst       => fifo_rn_rd_srst,
      din        => tmb_header,
      wr_en      => "and"(fifo_rn_wr_en,tmb_header_valid),
      rd_en      => fifo_rn_rd_en,
      dout       => fifo_rn_dout,
      full       => fifo_rn_full,
      empty      => fifo_rn_empty,
      data_count => fifo_rn_data_count
      );

  fifo_rn_pr: process (sys_clk) is
  begin  -- process fifo_rn_pr
    if (sys_clk'event and sys_clk = '1') then  -- rising clock edge
      if (rst_n = '0') then             -- synchronous reset (active low)
        fifo_rn_wr_en <= '0';
        -- is_avg_or <= FALSE;
      else

        -- If FS merge, EV header writes for 1st reading of merge cycle
        if (fs_merging_factor = "00") then
          fifo_rn_wr_en <= '1';         -- always
        -- elsif (is_avg_or) then          -- !TODO: 24/03/2024 add driver
        --   fifo_rn_wr_en <= '1';         -- keep operation result
        elsif (unsigned(fs_sequence_counter) = 0) then
          fifo_rn_wr_en <= '1';         -- keep R(0)
        else
          fifo_rn_wr_en <= '0';
        end if;

        -- If FS merge, EV header reads at last reading of merge cycle
        if (fs_merging_factor = "00") then
          if (tmb_header_valid_r0 = '1' and unsigned(fifo_rn_data_count) > 1) then -- note: fifo_rn_empty too slow here
            fifo_rn_rd_en <= '1';
          elsif (fifo_rn_rd_en = '1' and unsigned(fifo_rn_data_count) > 1) then
            fifo_rn_rd_en <= not fifo_rn_empty;
          else
            fifo_rn_rd_en <= '0';
          end if;
        -- elsif (is_avg_or) then          -- !TODO: 24/03/2024 add driver
        --   null;
        elsif (unsigned(fs_sequence_counter) = (unsigned(fs_merge_factor) - 1)) then
          if (tmb_header_valid_r0 = '1' and unsigned(fifo_rn_data_count) > 1) then -- note: fifo_rn_empty too slow here
            fifo_rn_rd_en <= '1';
          elsif (fifo_rn_rd_en = '1' and unsigned(fifo_rn_data_count) > 1) then
            fifo_rn_rd_en <= not fifo_rn_empty;
          else
            fifo_rn_rd_en <= '0';
          end if;
        else
          fifo_rn_rd_en <= '0';
        end if;

      end if;
    end if;
  end process fifo_rn_pr;


  ev_buf_fifo_rd_masked <= ev_buf_fifo_rd; -- !debug: 15/01/2024 write EV after FQ, see ev_data_seq_ps

  DATA_SORTER_DATA_EN <= mem_buf_fifo_rd and fq_stream_enable; -- act as read next -> no delay
  DATA_SORT_DOUT <= fq_fifo2048x16_dout;
  EVOLVING_DATA_EN <= ev_buf_fifo_rd_masked and ev_stream_enable; -- !debug: 19/10/2023 temporary
  EVOLVING_DOUT <= ev_fifo2048x16_dout;
  params_ready(0) <= '1' when (ev_header_ready and ev_stream_enable = '1') else '0';
  params_ready(1) <= '1' when (fq_header_ready and fq_stream_enable = '1') else '0';
  num_of_slices_after_merge <= ev_num_of_slices;
  num_of_slices_no_merge <= num_of_slices_saved;

end architecture ar;
