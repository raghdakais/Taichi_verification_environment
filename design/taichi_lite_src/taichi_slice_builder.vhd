-------------------------------------------------------------------------------
-- Title      : Taichi Slice Builder
-- Project    : Taichi module board, TMB
-------------------------------------------------------------------------------
-- File       : taichi_slice_builder.vhd
-- Author     : Shinderman Eugene  <eu1@localhost-localdomain>
-- Company    : HBtech
-- Created    : 05/09/2022
-- Last update: 26/02/2025
-- Platform   :
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: TMCOR with AMS v.6 Slice Builder, only for HD tiles
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 05/09/2022  1.0      eu1	only synthetic data
-------------------------------------------------------------------------------
-- notes:
--   - Interfaces:
--     - RX:
--       - rx_det[WORD_WIDTH-1..0] (I) from RX or from memory buffer, include
--         - payload header: 128 bytes
--         - slice data: when FQ - 2048 bytes, when EV - TBD bytes
--       - rd_reading_ready (I) - reading ready from tiles RX or from memory buffer block
--       - reading_type (I) - '0' - EV, '1' - FQ
--       - rx_fifo_rd (O) - read from tiles RX or in memory buffer
--       note: 4x tiles data already arranged to one stream -> move MU, MUX from here
--     - Footer:
--       - footer_bits[16*8-1..0] - 16 bytes
--     - TX communication:
--       - from Liron TX_series7.vhd
--   - signals:
--     - packet_header (TBD bytes): 1st byte - Dynamic Payload Size, others TBD
--     - sim_data - difference from TMCOR v.6 - all tiles in one stream
--     - reading_ready - '1' when data in FIFO > payload size *0.8
--   - clocks: sys_clk (50MHz ?), comm_clk (CLKDIV = 400/8 = 50MHz)
--   - blocks:
--     - slices_fsm - build reading and write to payload FIFO (include packet Header, {TMB Header,TMB data}, TMB footer)
--     - reading_fifo - store payload for TX communication
--     - gen_dummy_data_pr - generate sim_data
--     - data MUX - MUX sim_data or RX data
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- USE work.phoebe.all;

-- LIBRARY unisim ;
-- USE unisim.vcomponents.ALL;

entity taichi_slice_builder is
  generic (
    WORD_WIDTH : natural := 16;
    LONG_TMB_FOOTER : boolean := TRUE;
    MULTIBOOT_GOLDEN : boolean := FALSE
    );        -- byte,  consider change to 16bit
  port (
    reset_n    : in std_logic;
    nRST_20m   : in std_logic;
    sys_clk    : in std_logic;
    comm_clk   : in std_logic;

    -- controls, @sys_clk
    dummy_data_sel   : in  std_logic;                    -- 29/05/2024 NU
    diag_reg         : in  std_logic_vector(7 downto 0);       -- 12/07/2021
    diag_temp_reg    : in  std_logic_vector(7 downto 0);       -- 15/08/2021
    buffer_req       : in  std_logic;                          -- reading request from BUFFER
                                                               -- note: NOT use, because now request can delayed/ignored in DDR3 controller
    Num_of_Slices    : in std_logic_vector(6 downto 0);		-- 30/10/2022
    -- RX interface (now from DDR3), @sys_clk
    rd_reading_ready : in  std_logic;   -- 29/05/2024 NU, reading ready in RX FIFO
    rx_fifo_valid : in  std_logic; -- 29/05/2024
    new_packet2tx    : in std_logic;    -- 28/05/2024
    rx_det           : in  std_logic_vector(WORD_WIDTH-1 downto 0); -- data from RX FIFO, latency from read = 3
    rx_fifo_empty    : in  std_logic;   -- RX FIFO empty
    rx_fifo_rd       : out std_logic;   -- RD from RX FIFO
    reading_type     : in  std_logic;   -- '0' - EV, '1' - FQ
    footer_bits      : in  std_logic_vector(64*8-1 downto 0);  -- !debug: 02/05/2023 16bytes footer -> 64bytes footer
    IP20             : in  std_logic;                          -- IP sync to sys_clk

    -- TX communication interface, @comm_clk
    TX_STATn_DYN   : out std_logic;                       -- const '1'
    TX_GO          : out std_logic;                       -- start pulse
    TX_IP          : out std_logic;                       -- const '0'
    TX_PayloadSize : out std_logic_vector (31 downto 0);  -- size in bytes: {TMB Header,TMB data} + TMB footer
                                                          -- not include packet Header!!!
    TX_DATA_IN     : out std_logic_vector (7 downto 0);
    TX_RD_EMPTY    : out std_logic;
    TX_RD_REQ      : in  std_logic;
    rq_cmds_sampled: in std_logic_vector(1 downto 0);
    Footer_send  : out std_logic; --add by Dalit 1/11/2023
    taichi_slice_builder_tp : out std_logic_vector (7 downto 0)
    );
end entity taichi_slice_builder;


architecture ar of taichi_slice_builder is

   signal tiles_mux_data, tiles_data : std_logic_vector(WORD_WIDTH-1 downto 0);
   signal tiles_sim_data : std_logic_vector(15 downto 0); -- generated data !TODO: 03/08/2023 change to 32 bit
   signal tmcor_data_cnt : unsigned(11 downto 0) := (others => '0'); -- simulated TMB data count

  type PACKET_BUILD_FSM_TYP is (IDLE_ST, P_HEADER_ST, TMB_HEADER_ST, TMB_DATA_ST, TMB_FOOTER_ST, STOP_ST);
  signal packet_build_fsm : PACKET_BUILD_FSM_TYP;

  signal IP20_r : std_logic;
  -- signal slices_data : std_logic_vector(15 downto 0);

  signal diag_temp_r : std_logic_vector(7 downto 0);   -- 15/08/2021
  signal diag_temp_r_32m : std_logic_vector(7 downto 0);   -- 15/08/2021

  signal rx_fifo_rd_i, rx_fifo_rd_r : std_logic;
  signal fifo_wr, fifo_wr_i : std_logic;
  constant WORDS_IN_HEADER : natural := 2; -- 2x words = 4bytes
  signal packet_header : std_logic_vector(WORDS_IN_HEADER*16-1 downto 0);
  signal packet_field_cnt : natural range 0 to 4095;

  -- component fifo_dc_dw_16x4096 is
  --   port (
  --     rst           : in  std_logic;
  --     wr_clk        : in  std_logic;
  --     rd_clk        : in  std_logic;
  --     din           : in  std_logic_vector (15 downto 0);
  --     wr_en         : in  std_logic;
  --     rd_en         : in  std_logic;
  --     dout          : out std_logic_vector (7 downto 0);
  --     full          : out std_logic;
  --     empty         : out std_logic;
  --     rd_data_count : out std_logic_vector (12 downto 0);
  --     wr_data_count : out std_logic_vector (11 downto 0);
  --     wr_rst_busy   : out std_logic;
  --     rd_rst_busy   : out std_logic
  --     );
  -- end component;
  -- 03/08/2023 fifo_dc_dw_32to8x4096
  component fifo_dc_dw_32to8x4096 is
  Port (
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    rd_data_count : out STD_LOGIC_VECTOR ( 12 downto 0 );
    wr_data_count : out STD_LOGIC_VECTOR ( 10 downto 0 );
    wr_rst_busy : out STD_LOGIC;
    rd_rst_busy : out STD_LOGIC
  );
  end component fifo_dc_dw_32to8x4096;


  signal wr_data_count : std_logic_vector (10 downto 0); -- !debug: 03/08/2023  was 11
  signal rd_data_count : std_logic_vector (12 downto 0);
  signal wr_cnt, wr_cnt_saved : natural range 0 to 4095;  -- for test: {TMB Header,TMB data}
  signal tx_read_cnt : natural range 0 to 8191;  -- for test: packet Header, {TMB Header,TMB data}, TMB footer)
  signal tx_go_i, tx_go_r : std_logic;

  signal mem_buf_packet_size, mem_buf_packet_size_saved, tiles_data_size, tiles_data_size_saved : natural range 0 to 4095; -- size in words
  signal fifo_rst, fifo_full, fifo_empty : std_logic;
  signal tx_rd_req_r : std_logic;
  signal diag_reg_r  : std_logic_vector(7 downto 0);

  -- 20/03/2023
  -- signal buffer_req_saved : std_logic := '0';
  signal ev_reading_number_sampled, fq_reading_number_sampled : std_logic_vector(15 downto 0);
  signal reading_number_err2, tx_rd_req_timeout_err : std_logic := '0';
  signal tx_rd_req_timeout_cnt : natural range 0 to 25000 := 25000; -- 500 usec @50MHz

  signal wait1_cnt : natural range 0 to 7; -- !debug: 29/05/2024 only for debug

  signal new_packet2tx_shr : unsigned(2 downto 0);
  signal wr_cnt_keep_cnt : natural range 0 to 7;

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of rx_fifo_empty, ev_reading_number_sampled, fq_reading_number_sampled, reading_number_err2, RX_det, packet_field_cnt, packet_build_fsm, tx_rd_req_timeout_err, tx_rd_req_timeout_cnt : signal is "true";
  attribute DONT_TOUCH of buffer_req, diag_reg, IP20, fifo_wr, tx_read_cnt, rx_fifo_valid, new_packet2tx, Num_of_Slices : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of rx_fifo_empty, ev_reading_number_sampled, fq_reading_number_sampled, reading_number_err2, RX_det, packet_field_cnt, packet_build_fsm, tx_rd_req_timeout_err, tx_rd_req_timeout_cnt : signal is "true";
  attribute mark_debug of buffer_req, diag_reg, IP20, fifo_wr, tx_read_cnt, rx_fifo_valid, new_packet2tx, Num_of_Slices : signal is "true";

begin  -- architecture ar


  misc_pr: process (sys_clk, nRST_20m) is
    variable packet_size_in_header_v : std_logic_vector(15 downto 0);
  begin  -- process misc_pr
    if (nRST_20m = '0') then             -- asynchronous reset (active low)
      IP20_r <= '0';
      diag_temp_r <= (others => '0');
      diag_reg_r <= (others => '0');
      -- fifo_wr <= '0';
      mem_buf_packet_size <= 576; -- data + scan header, for 16 slices, 2112 for 64 slices
      mem_buf_packet_size_saved <= 576;
      tiles_data_size <= 512; -- data only, for 16 slices, 2048 for 64 slices
      tiles_data_size_saved <= 512; -- for 16 slices, 2048 for 64 slices
      packet_header <= (others => '0');
      fifo_rst <= '0';
      ev_reading_number_sampled <= (others => '0');
      fq_reading_number_sampled <= (others => '0');
      wr_cnt <= 0;
      wr_cnt_saved <= 0;
      new_packet2tx_shr <= (others => '0');
      wr_cnt_keep_cnt <= 0;
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      IP20_r <= IP20;

      diag_temp_r <= diag_temp_reg;
      diag_reg_r <= diag_reg;

      -- fifo_wr <= fifo_wr_i;

      if (new_packet2tx_shr(0) = '1' and 2*wr_cnt > mem_buf_packet_size_saved) then
        wr_cnt_saved <= wr_cnt; -- !debug: 28/05/2024 "RD FIFO DATA Fully Transferred" packet_build_complete -> generate GO, when new_packet2tx arrives
        wr_cnt_keep_cnt <= 7;
      elsif (TX_RD_REQ = '0' and tx_rd_req_r = '1' and wr_cnt_keep_cnt > 0) then
        wr_cnt_keep_cnt <= wr_cnt_keep_cnt - 1; -- 10/06/2024 keep requires for correct TX_series7.fifo_not_empty checks
      elsif (wr_cnt_keep_cnt /= 7 and wr_cnt_keep_cnt > 0) then
          wr_cnt_keep_cnt <= wr_cnt_keep_cnt - 1;
          if (wr_cnt_keep_cnt = 1) then
            wr_cnt_saved <= 0;
          end if;
      end if;

      if (new_packet2tx_shr(0) = '1' and 2*wr_cnt > mem_buf_packet_size_saved) then
        wr_cnt <= 0;
      elsif (fifo_wr = '1') then
        wr_cnt <= wr_cnt + 1;           -- write to TX, only for diagnsotics
      end if;


      -- if (rx_fifo_rd_r = '1' and packet_build_fsm = TMB_DATA_ST) then
      --   assert (rx_fifo_empty ='0') report "Error: no enougth data in RX FIFO" severity ERROR;
      -- end if;

      if (TX_RD_REQ = '0' and tx_rd_req_r = '1') then
        assert (tx_read_cnt = (wr_cnt_saved*4))
          report "TX communication requested payload not match to TX FIFO. Check TX_PayloadSize" severity ERROR;
      end if;

      if (TX_RD_REQ = '1') then
        assert (TX_GO = '0') report "Error: RD request from CDM arrives, when TX to CDM not ends" severity ERROR;
      end if;

      -- new_packet2tx_shr <= new_packet2tx_shr(1 downto 0) & new_packet2tx;
      if (tx_rd_req_r = '1' and new_packet2tx = '1') then -- !debug: 26/02/2025
        new_packet2tx_shr(0) <= '1'; -- hold request, when builder busy
      elsif (tx_rd_req_r = '0') then
        new_packet2tx_shr <= new_packet2tx_shr(1 downto 0) & new_packet2tx; -- get new value
      end if;

      if (packet_build_fsm = IDLE_ST and new_packet2tx = '1' and new_packet2tx_shr(0) = '0') then         -- !debug: 28/05/2024
        mem_buf_packet_size <= 64 + 32 * to_integer(unsigned(Num_of_Slices)) + 16; -- !debug: 31/12/2023 header size 64 words and footer 16 words
        tiles_data_size <= 32 * to_integer(unsigned(Num_of_Slices));
        tiles_data_size_saved <= tiles_data_size;
        mem_buf_packet_size_saved <= mem_buf_packet_size;
      end if;

      -- Packet Header: 32bits, [15..0] - payload size, same as TX_series7.NumDatabytes?
      -- for RX_series7 seems need swap bytes: 0890 -> swapped 9008
      -- !TODO: 08/09/2022 try to change order of write header to FIFO for keep natural packet_header view
      -- !debug: 02/11/2022:
      --  - for AS5912 size changed 0x890 -> 0x1090
      --  - for partial tiles data (only selected slices): 64bytes/slice * Num_of_Slices
      packet_size_in_header_v := std_logic_vector(to_unsigned(tiles_data_size,15)) & '0'; -- size in bytes
      packet_header <= packet_size_in_header_v(7 downto 0) & packet_size_in_header_v(15 downto 8) & X"0000"; -- !debug: 03/08/2023

      -- if (nRST_20m = '0' or (TX_RD_REQ = '0' and tx_rd_req_r = '1')) then -- !debug: 05/02/2024 added  and fifo_empty = '0'
      if (nRST_20m = '0') then -- !debug: 28/05/2024 now in FIFO can be parts of 2 readings, then reset forbidden, except TMB reset
        fifo_rst <= '1';
      else
        fifo_rst <= '0';
      end if;

      -- !debug: 20/03/2023 non-incremental reading number check
      if (packet_build_fsm = TMB_HEADER_ST and packet_field_cnt = 27) then -- !debug: 03/08/2023 was 55
        if (rq_cmds_sampled = "01") then -- [1] - HD, [0] - EV
          ev_reading_number_sampled <= RX_det(31 downto 16);
        elsif (rq_cmds_sampled = "10") then -- [1] - HD, [0] - EV
          fq_reading_number_sampled <= RX_det(31 downto 16);
        end if;
        if ((rq_cmds_sampled = "01" and (unsigned(ev_reading_number_sampled) + 1) /= unsigned(RX_det(31 downto 16))) or
            (rq_cmds_sampled = "10" and (unsigned(fq_reading_number_sampled) + 1) /= unsigned(RX_det(31 downto 16)))) then
          reading_number_err2 <= '1';   -- note: not error, when changes FS merging factor or when resend or when start new scan
        else
          reading_number_err2 <= '0';
        end if;
      end if;

      if (TX_RD_REQ = '1' and tx_rd_req_r = '0') then -- RD request from TX rise
   	    tx_rd_req_timeout_cnt <= 25000; -- 500 usec @50MHz
      elsif (tx_rd_req_timeout_cnt /= 0) then
	    tx_rd_req_timeout_cnt <= tx_rd_req_timeout_cnt - 1;
	  end if;
	  if (tx_rd_req_timeout_cnt = 0) then
	    tx_rd_req_timeout_err <= '1';
	  else
  	    tx_rd_req_timeout_err <= '0';
	  end if;

    end if;
  end process misc_pr;


  fifo_wr <= fifo_wr_i; -- !debug: 29/05/2024 no delay

  tiles_mux_data <= tiles_data when (not MULTIBOOT_GOLDEN) else X"FBADFBAD"; -- 05/01/2025 don't care, no data packet for Golden version

  data_proc_pr: process (sys_clk) is
  begin	 -- process data_proc_pr
    if (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      if (packet_build_fsm = P_HEADER_ST) then -- packet Header for TX_series7
	tiles_data <= packet_header;
      elsif (packet_build_fsm = TMB_HEADER_ST) then -- TMB Header from FIFO
	tiles_data <= RX_det;	    -- data: rx_fifo_rd 2clk-> RX_det 1clk-> tiles_mux_data
				    -- {rx_fifo_rd_i,fifo_wr_i} 1clk-> fifo_wr
      elsif (packet_build_fsm = TMB_DATA_ST) then -- TMB Data from FIFO
	tiles_data <= RX_det;
      elsif (packet_build_fsm = TMB_FOOTER_ST) then
	-- tiles_data <= footer_bits(packet_field_cnt*16+15 downto packet_field_cnt*16);
	tiles_data <= footer_bits(packet_field_cnt*32+31 downto packet_field_cnt*32);
      else
	tiles_data <= (others => '0');
      end if;

    end if;
  end process data_proc_pr;


  -- Slice Builder FSM
  -- 05/09/2022 Taichi:
  -- data ordered in RX
  -- no need count slices
  -- state for each field:
  --   a) packet Header
  --   b) {TMB Header,TMB data}
  --   c) TMB footer
  packet_build_fsm_pr: process (sys_clk, reset_n) is
  begin  -- process packet_build_fsm_pr
    if (reset_n = '0') then             -- asynchronous reset (active low)
      packet_build_fsm <= IDLE_ST;
      rx_fifo_rd_i <= '0';
      rx_fifo_rd_r <= '0';
      fifo_wr_i <= '0';
      wait1_cnt <= 0;
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      case packet_build_fsm is
        when IDLE_ST =>
          if (new_packet2tx_shr(2) = '1' and tx_rd_req_r = '0') then -- new packet start !TODO: 29/05/2024 remove tx_rd_req_r
            packet_build_fsm <= P_HEADER_ST;
            packet_field_cnt <= 0; -- !debug: 03/08/2023  was WORDS_IN_HEADER-1;
            fifo_wr_i <= '0';
            rx_fifo_rd_i <= '0';
          else
            fifo_wr_i <= '0';
            rx_fifo_rd_i <= '0';
          end if;

        when P_HEADER_ST =>                -- selected only one DPR for read
          if (packet_field_cnt = 0) then
            packet_build_fsm <= TMB_HEADER_ST;
            packet_field_cnt <= 32;
            rx_fifo_rd_i <= '0';
            fifo_wr_i <= '1';
          else
            packet_field_cnt <= packet_field_cnt - 1;
            rx_fifo_rd_i <= '0';        -- !debug: 02/11/2022  read latency = 2, if WORDS_IN_HEADER /= 2 must be changed
            fifo_wr_i <= '1';
          end if;
          -- wait1_cnt <= 1;

        when TMB_HEADER_ST =>
          if (packet_field_cnt = 0 and rx_fifo_valid = '0') then
            packet_build_fsm <= TMB_DATA_ST;
            if (reading_type = '1') then
              packet_field_cnt <= tiles_data_size/2; -- when FQ !debug: 03/08/2023  was tiles_data_size - 1
            else
              packet_field_cnt <= tiles_data_size/2; -- when EV  !TODO: 05/09/2022 update value for EV reading
            end if;
            rx_fifo_rd_i <= '0';
            fifo_wr_i <= '0';
          elsif (packet_field_cnt = 1 and rx_fifo_valid = '1' and rx_fifo_rd_i = '1') then -- already on rx_det present 1st data word
            packet_build_fsm <= TMB_DATA_ST;
            if (reading_type = '1') then
              packet_field_cnt <= tiles_data_size/2; -- when FQ !debug: 03/08/2023  was tiles_data_size - 1
            else
              packet_field_cnt <= tiles_data_size/2; -- when EV  !TODO: 05/09/2022 update value for EV reading
            end if;
            rx_fifo_rd_i <= '0';
            fifo_wr_i <= rx_fifo_valid and rx_fifo_rd_i;
          else
            if (diag_reg_r(0) = '1' or (rx_fifo_valid = '1' and rx_fifo_rd_i = '1')) then
              packet_field_cnt <= packet_field_cnt - 1;
              fifo_wr_i <= '1';
            else
              fifo_wr_i <= '0';
            end if;
            if (diag_reg_r(0) = '1' or rx_fifo_empty = '0') then
              rx_fifo_rd_i <= '1';
            else
              rx_fifo_rd_i <= '0';
            end if;
          end if;

        when TMB_DATA_ST =>
          if (packet_field_cnt = 0) then  --  !debug: 10/11/2023 was  0, when normal FIFO
            packet_build_fsm <= TMB_FOOTER_ST;
            if (LONG_TMB_FOOTER) then
              -- packet_field_cnt <= 31;      -- !debug: 02/05/2023 for 16DW footer 7 -> 31
              packet_field_cnt <= 15;      -- !debug: 03/08/2023  was 31
            else
              packet_field_cnt <= 7;
            end if;
            rx_fifo_rd_i <= '0';
            fifo_wr_i <= '0';
          else
            -- if (wait1_cnt = 0) then     -- !debug: 29/05/2024 for debug
            if (diag_reg_r(0) = '1' or (rx_fifo_valid = '1' and rx_fifo_rd_i = '1')) then
              packet_field_cnt <= packet_field_cnt - 1;
              fifo_wr_i <= '1';
            else
              fifo_wr_i <= '0';
            end if;
            if (diag_reg_r(0) = '1' or rx_fifo_empty = '0') then
              rx_fifo_rd_i <= '1';
            else
              rx_fifo_rd_i <= '0';
            end if;
            -- else
            --   wait1_cnt <= wait1_cnt - 1;
            -- end if;
          end if;

        when TMB_FOOTER_ST =>
          if (packet_field_cnt = 0) then
            packet_build_fsm <= STOP_ST;
            fifo_wr_i <= '1';
            Footer_send<='1'; --add by Dalit 1/11/2023
          else
            packet_field_cnt <= packet_field_cnt - 1;
            fifo_wr_i <= '1';
            Footer_send<='0'; --add by Dalit 1/11/2023
          end if;
          rx_fifo_rd_i <= '0';

        when STOP_ST =>
          packet_build_fsm <= IDLE_ST;
          rx_fifo_rd_i <= '0';
          fifo_wr_i <= '0';

      end case;

      rx_fifo_rd_r <= rx_fifo_rd_i;

    end if;
  end process packet_build_fsm_pr;


  sync_32m: process (comm_clk) is
    variable tx_payloadsize_v : natural range 0 to 8191;
  begin  -- process sync_32m
    if (comm_clk'event and comm_clk = '1') then  -- rising clock edge

      diag_temp_r_32m <= diag_temp_r;

      -- if (packet_build_fsm = IDLE_ST and (2*wr_cnt_saved > mem_buf_packet_size)) then -- 28/05/2024 was request from CDM and TX data ready
      if (new_packet2tx_shr(1) = '1' and (2*wr_cnt_saved > mem_buf_packet_size_saved)) then -- 28/05/2024 was request from CDM and TX data ready
        tx_go_i <= '1';       -- rising edge of GO the transmitter identifies the packet
      else
        tx_go_i <= '0';
      end if;

      -- if (buffer_req = '1' and fifo_empty = '1') then -- !debug: 23/05/2024
      --   buffer_req_saved <= '1'; -- keep request until packet ready
      -- elsif (tx_go_i = '1') then
      --   buffer_req_saved <= '0';
      -- end if;

      tx_go_r <= tx_go_i;

      -- assert "not"(tx_go_i = '1' and unsigned(rd_data_count) < 16) report
      --   "Error: not enought fifo_dc_dw_16x4096" severity ERROR;

      -- packet Header, {TMB Header,TMB data}, TMB footer
      -- tx_payloadsize_v := 4+128+(tiles_data_size * 2)+16;
      tx_payloadsize_v := tiles_data_size_saved * 2;  -- !debug: 27/11/2022 only data in payload
      if (reading_type = '1') then -- FQ
        TX_PayloadSize <= std_logic_vector(to_unsigned(tx_payloadsize_v,TX_PayloadSize'length));        -- 4+128+4096+16=4244
      --  10/11/2023 full size for 16 slices: 4+128+1024+64=1220=0x4c4 bytes
      else                         -- EV
        TX_PayloadSize <= std_logic_vector(to_unsigned(2192,TX_PayloadSize'length));        -- !TODO: 06/09/2022 set value for EV
      end if;

      tx_rd_req_r <= TX_RD_REQ;

      if (tx_go_i = '1' and tx_go_r = '0') then
        tx_read_cnt <= 0;
      elsif (TX_RD_REQ = '1') then
        tx_read_cnt <= tx_read_cnt + 1;
      end if;

    end if;
  end process sync_32m;

  rx_fifo_rd <= rx_fifo_rd_i;

  -- TX FIFO
  -- dual clock: wr @sys_clk, rd @comm_clk
  -- width: wr - 16bit, rd - 8bit
  -- depth: 4096bytes
  -- fifo_dc_dw_16x4096 -> fifo_dc_dw_32to8x4096
  fifo_dc_dw_16x4096_1 : fifo_dc_dw_32to8x4096
    port map (
      rst           => fifo_rst,
      wr_clk        => sys_clk,
      rd_clk        => comm_clk,
      din           => tiles_mux_data,
      wr_en         => fifo_wr,
      rd_en         => TX_RD_REQ,
      dout          => TX_DATA_IN,
      full          => fifo_full,
      empty         => fifo_empty, --  04/02/2024
      rd_data_count => rd_data_count,
      wr_data_count => wr_data_count,
      wr_rst_busy   => open,
      rd_rst_busy   => open
    );

  -- drive from process @comm_clk: TX_GO, TX_PayloadSize
  TX_STATn_DYN <= '1';
  TX_IP <= '0';                         -- not IP packet
  TX_GO <= tx_go_i when (not MULTIBOOT_GOLDEN) else '0'; -- 05/01/2025 no data packet for Golden version
  -- TX_RD_EMPTY <= '1' when (unsigned(rd_data_count) = 0) else '0';
  TX_RD_EMPTY <= '1' when (tx_read_cnt = (wr_cnt_saved*4)) else '0';


  taichi_slice_builder_tp(0) <= '1';
  taichi_slice_builder_tp(1) <= '1';
  taichi_slice_builder_tp(2) <= '0';
  taichi_slice_builder_tp(3) <= '0';
  taichi_slice_builder_tp(4) <= '0';
  taichi_slice_builder_tp(5) <= '0';
  taichi_slice_builder_tp(6) <= '1';
  taichi_slice_builder_tp(7) <= '0';

end architecture ar;
