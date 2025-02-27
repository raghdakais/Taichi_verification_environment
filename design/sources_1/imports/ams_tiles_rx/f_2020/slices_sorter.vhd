-------------------------------------------------------------------------------
-- Title      : AMS slices sorter
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : slices_sorter.vhd
-- Author     : Shinderman Eugene  <evgene@hbtech.co.il>
-- Company    : Philips Medical
-- Created    : 24/03/2021
-- Last update: 04/09/2024
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: prepare AMS ASIC's data for memory buffer or for TMB -> CDM payload
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- use ieee.std_logic_misc.all;
library work;

USE work.phoebe.all;

entity slices_sorter is
  port (
    clk20_c2     : in  std_logic;           -- RX word clock
    sys_clk      : in  std_logic;           -- system clock @50MHz
    rst_n        : in std_logic;
    NRST_20M     : in std_logic;
    IP20       : in std_logic;
    IP50       : in std_logic;
    dummy_data_sel : in std_logic; -- !TODO: 23/10/2022 add diag_reg[4] - '1' synthetic data in place tiles data
    diag_reg     : in std_logic_vector(15 downto 0);
    num_of_tiles : in std_logic_vector(NumOfTiles-1 downto 0); -- 31/08/2023
    reading_number_freerun_cnt : in std_logic_vector(15 downto 0); -- 14/06/2023
    tile_packet_ok_timeout_reg : in std_logic_vector(7 downto 0); -- 04/09/2023
    mu_ctl_reg   : in  std_logic;
    take_rx_det_msb_reg : in std_logic;
    rx_det_shl_reg : in std_logic;   -- 12/07/2022
    pipeline_ctl_reg    : in STD_LOGIC_VECTOR(31 downto 0); -- 29/07/2021
    AMS_Time       : in std_logic_vector((NumOfTiles*16)-1 downto 0); -- 16/06/2021
    -- AMS_Offset     : in std_logic_vector(15 downto 0);
    ibias          : in std_logic_vector(4 downto 0);  -- 13/12/2021
    global_ip_time_reg : in std_logic_vector(15 downto 0); -- 03/08/2021
    gain           : in std_logic_vector(3 downto 0);		-- 24/06/2021 CREG[15..12] - Crst
    Num_of_Slices  : in std_logic_vector(6 downto 0);		-- 30/10/2022
    asic_data_good_read : in std_logic_vector(NumOfTiles-1 downto 0); -- 04/09/2023
    RX_det_m     : in std_logic_vector((NumOfTiles*26)-1 downto 0);  -- master tiles data
    data_valid_m : in std_logic_vector(NumOfTiles-1 downto 0);       -- master tiles data strobe
    RX_det_s     : in std_logic_vector((NumOfTiles*26)-1 downto 0);  -- slave tiles data
    data_valid_s : in std_logic_vector(NumOfTiles-1 downto 0);        -- slave tiles data strobe
    sorter_data_ready : out std_logic;                    -- 26/11/2023
    dpr_header_updated : in std_logic;                     -- 26/11/2023
    fq_data_valid : out std_logic;                                    -- 30/10/2022
    fq_data_in : out std_logic_vector(31 downto 0)                    -- !debug: 26/07/2023 blk_mem_dpr512x16: [15..0]
    );
end entity slices_sorter;


architecture ar of slices_sorter is

  constant DW_WIDTH : positive := 26;   -- word width 26bits

  component map4ams_lut is
   port (
     clka  : in  STD_LOGIC;
     addra : in  STD_LOGIC_VECTOR (9 downto 0);
     douta : out STD_LOGIC_VECTOR (9 downto 0));
  end component map4ams_lut;

  type MAP4AMS_ADDR_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(9 downto 0);
  signal map4ams_lut_addr, map4ams_det_num, map4ams_lut_addr_muxed : MAP4AMS_ADDR_ARRAY_TYP;
  type DET_ARRANGE_ADDR_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(8 downto 0);
  signal det_arrange_dpr_rdaddr : DET_ARRANGE_ADDR_ARRAY_TYP;
  -- signal data_valid_r : std_logic_vector(NumOfTiles-1 downto 0); -- from write to DPR
  signal wr2dpr_ready, data_valid2dpr, data_valid_lut, mu_in_valid : std_logic_vector(NumOfTiles-1 downto 0);
  signal RX_det_lut, mu_in : std_logic_vector((NumOfTiles*26)-1 downto 0);
  signal wr2dpr_ready_0 : std_logic_vector(NumOfTiles-1 downto 0);

  component det_arrange_dpr is
    port (
      clka  : in  STD_LOGIC;
      wea   : in  STD_LOGIC_VECTOR (0 to 0);
      addra : in  STD_LOGIC_VECTOR (8 downto 0);
      dina  : in  STD_LOGIC_VECTOR (25 downto 0);
      clkb  : in  STD_LOGIC;
      addrb : in  STD_LOGIC_VECTOR (8 downto 0);
      doutb : out STD_LOGIC_VECTOR (25 downto 0));
  end component det_arrange_dpr;

  signal last_rd : std_logic_vector(NumOfTiles-1 downto 0) := (others => '0');
  signal bypass_lut, send_constant : std_logic := '0';
  signal rx_det     : std_logic_vector((NumOfTiles*26)-1 downto 0);  -- slave tiles data
  -- signal data_valid, data_valid_s_r, data_valid_s_r2 : std_logic_vector(NumOfTiles-1 downto 0);       -- slave tiles data strobe
  signal data_valid : std_logic_vector(NumOfTiles-1 downto 0);       -- slave tiles data strobe

  component blk_mem_dpr512x16to32 is
  port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 8 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 15 downto 0 );
    clkb : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 7 downto 0 ); -- blk_mem_dpr512x16: [8..0]
    doutb : out STD_LOGIC_VECTOR ( 31 downto 0 ) -- blk_mem_dpr512x16: [15..0]
    );
  end component blk_mem_dpr512x16to32;

  signal dummy_data_sel_r : std_logic := '0';
  type WORD_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(15 downto 0);
  signal tile_sim_data : WORD_ARRAY_TYP;   -- generated data
  signal asic2fpga_time_cnt : natural range 0 to 4095 := 4095; --  generator latency after IP

  constant ASIC2FPGA_TIME_CONST : std_logic_vector(7 downto 0) := X"01"; -- latency ~1uS
  signal sim_data_cnt : natural range 0 to 511;
  signal sim_data_valid : std_logic := '0';
  signal IP50_r, sync_ip : std_logic;
  signal ip_exist : boolean := FALSE;

  type RX_DET_SHR_TYP is array (7 downto 0) of std_logic_vector((NumOfTiles*26)-1 downto 0); -- 29/05/2022
  signal rx_det_shr, mu_in_det_shr : RX_DET_SHR_TYP;
  type RX_VALID_SHR_TYP is array (7 downto 0) of std_logic_vector(NumOfTiles-1 downto 0);
  signal mu_in_valid_shr : RX_VALID_SHR_TYP;
  signal data_valid_shr : RX_VALID_SHR_TYP; -- delayed valid for address calc
  signal wr2dpr_ready_shr : RX_VALID_SHR_TYP;

  signal mu_en : std_logic;
  signal mu_val : std_logic_vector(NumOfTiles-1 downto 0);
  signal tile0_mu_data, tile1_mu_data, tile2_mu_data, tile3_mu_data : std_logic_vector(15 downto 0); -- Data Processing (mu) data
  type MU_OUT_TYP is array (0 to 3) of STD_LOGIC_VECTOR (15 DOWNTO 0);
  signal mu_out : MU_OUT_TYP;
  signal pipeline_ctl_r : std_logic_vector(31 downto 0);
  type OFFSET_ARRAY_TYP is array (natural range <>) of std_logic_vector(15 downto 0);
  constant BASIC_OFFSET : OFFSET_ARRAY_TYP(0 to 31) := (
    (X"0000"), (X"0080"), (X"00C0"), (X"0100"), (X"0140"), (X"0180"), (X"01C0"), (X"0200"),
    (X"0240"), (X"0280"), (X"02C0"), (X"0300"), (X"0340"), (X"0380"), (X"03C0"), (X"0400"),
    (X"0000"), (X"0500"), (X"0780"), (X"0A00"), (X"0C80"), (X"0F00"), (X"1180"), (X"1400"),
    (X"1680"), (X"1900"), (X"1B80"), (X"1E00"), (X"2080"), (X"2300"), (X"2580"), (X"2800"));
  signal ams_offset_i : std_logic_vector(15 downto 0);
  signal gain_r         : std_logic_vector(3 downto 0);

  component PIPELINE2 is
    port (CLK            : IN  STD_LOGIC;
          RST            : IN  STD_LOGIC;
          DELTA_EN       : IN  STD_LOGIC;
          OSUB_EN        : IN  STD_LOGIC;
          LOG_EN         : IN  STD_LOGIC;
          TCSUB_EN       : IN  STD_LOGIC;
          PASST          : IN  STD_LOGIC;
          ZERO_BAD_POINT : IN  STD_LOGIC;
          DSTROBE        : IN  STD_LOGIC;
          AMS_Charge     : IN  STD_LOGIC_VECTOR (25 DOWNTO 0);
          AMS_Time       : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          AMS_Offset     : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          Global_IP_Time : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
          sync_ip        : IN  STD_LOGIC;                     -- 10/06/2021
          gain           : in STD_LOGIC_VECTOR(3 downto 0);		-- 24/06/2021 CREG[15..12] - Crst
          diag_in        : in STD_LOGIC_VECTOR(3 downto 0);		-- 12/04/2022
          MU_OUT         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
          MU_VAL         : OUT STD_LOGIC;
          MU_BAD         : OUT STD_LOGIC);
  end component PIPELINE2;

  signal dpr512x16_dina, dpr512x16_dina_i : std_logic_vector(63 downto 0);
  signal dpr512x16_doutb : std_logic_vector(127 downto 0); -- blk_mem_dpr512x16: [63..0]
  signal dpr512x16_wr : std_logic_vector(NumOfTiles-1  downto 0);
  signal dpr512x16_addra : std_logic_vector(35 downto 0); -- !debug: 23/10/2022 was dpr256x16_addra 4*8, now dpr512x16_addra 4*9
  signal dpr512x16_addrb, dpr512x16_addrb_r1 : std_logic_vector(9 downto 0); -- blk_mem_dpr512x16: [10..0]
  signal dpr512x16_addrb_ss : std_logic_vector(1 downto 0);
  signal First_Detector_ADDR, Last_Detector_ADDR : unsigned(9 downto 0); -- blk_mem_dpr512x16: [10..0]

  signal take_rx_det_msb : std_logic;
  signal  rx_det_shl : std_logic := '0';
  type DATA_1ST_PIXEL_TYP is array (NumOfTiles-1 downto 0) of boolean; -- 05/04/2023
  signal data_1st_pixel : DATA_1ST_PIXEL_TYP;
  signal mod5_cnt : natural range 0 to 7;
  --signal dpr512x16_wr_cnt : natural range 0 to 511;
  type dpr512x16_wr_cnt_type is array (NumOfTiles-1 downto 0)of natural range 0 to 511;
  signal dpr512x16_wr_cnt : dpr512x16_wr_cnt_type;
  signal dpr512x16_wr_complete, dpr512x16_wr_complete_r : boolean;
  type dpr512x16_wr_complete_type is array (NumOfTiles-1 downto 0) of boolean;
  signal dpr512x16_wr_complete_vec: dpr512x16_wr_complete_type;


  signal fq_data_valid_0, fq_data_valid_1 : std_logic;
  signal last_word, first_word : boolean;

  component fifo_26x16 is
    port (
      clk   : in  std_logic;
      srst  : in  std_logic;
      din   : in  std_logic_vector (25 downto 0);
      wr_en : in  std_logic;
      rd_en : in  std_logic;
      dout  : out std_logic_vector (25 downto 0);
      full  : out std_logic;
      empty : out std_logic;
      data_count : out std_logic_vector (3 downto 0)
      );
  end component fifo_26x16;

  signal RX_det_m_fifo_out, RX_det_s_fifo_out : std_logic_vector((NumOfTiles*26)-1 downto 0);
  signal elast_fifo_rd_en, elast_fifo_m_empty, elast_fifo_s_empty : std_logic_vector(NumOfTiles-1 downto 0);
  type RD_EN_SHR_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(2 downto 0);
  signal elast_fifo_rd_en_shr : RD_EN_SHR_ARRAY_TYP := (others => (others => '0'));
  type DATA_COUNT_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(3 downto 0);
  signal elast_fifo_m_data_count, elast_fifo_s_data_count : DATA_COUNT_ARRAY_TYP;
  -- type START_READ_ARRAY_TYP is array (NumOfTiles-1 downto 0) of boolean;
  -- signal elast_fifo_start_read : START_READ_ARRAY_TYP := (others => FALSE);
  -- type FIFO_RD_COUNT_ARRAY_TYP is array (NumOfTiles-1 downto 0) of natural range 0 to 31;
  -- signal elast_fifo_rd_cnt : FIFO_RD_COUNT_ARRAY_TYP := (others => 24);

  type DATA_VALID_SHR_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(31 downto 0);
  signal data_valid_m_shr : DATA_VALID_SHR_ARRAY_TYP := (others => (others => '0'));

  signal addr_sim_slave : std_logic;
  signal IP50_to_IP20_protect_cnt : natural range 0 to 15;
  signal fq_data_valid_cnt, fq_data_valid_cnt_r : natural range 0 to 4095;
  signal dpr512x16_rden : boolean;
  signal fq_data_in_i : std_logic_vector(31 downto 0);

  signal timer_1_us_cnt : natural range 0 to 63 := 0;
  signal tile_packet_ok_timeout_cnt : natural range 0 to 127 := 127;

  type TILES_SHR_TYP is array (natural range <>) of std_logic_vector(NumOfTiles-1 downto 0);
  signal tile_packet_ok_shr : TILES_SHR_TYP (3 downto 0);
  signal tile_packet_ok_muxsel : std_logic_vector(NumOfTiles-1 downto 0);

  signal tile_packet_ok : dpr512x16_wr_complete_type;
  signal reading_number_freerun_cnt_20m : std_logic_vector(15 downto 0);
  signal dummy_data_sel_20m : std_logic;
  signal AMS_Time_50m       : std_logic_vector((NumOfTiles*16)-1 downto 0);

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of elast_fifo_rd_en, elast_fifo_m_empty, elast_fifo_s_empty, RX_det_m_fifo_out, RX_det_s_fifo_out, dpr512x16_wr, dpr512x16_dina : signal is "true";
  attribute DONT_TOUCH of rx_det_shr, map4ams_det_num, data_valid_shr, tile_packet_ok_muxsel : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of elast_fifo_rd_en, elast_fifo_m_empty, elast_fifo_s_empty, RX_det_m_fifo_out, RX_det_s_fifo_out, dpr512x16_wr, dpr512x16_dina : signal is "true";
  attribute mark_debug of rx_det_shr, map4ams_det_num, data_valid_shr, tile_packet_ok_muxsel : signal is "true";

begin  -- architecture ar


  elast_fifo_g : for i in 0 to (NumOfTiles-1) generate

    fifo_26x16_m : fifo_26x16
      port map (
        clk   => clk20_c2,
        srst  => IP20, -- !debug: 20/04/2023 "not"(NRST_20M),
        din   => RX_det_m(i*26+25 downto i*26),
        wr_en => data_valid_m(i),
        rd_en => elast_fifo_rd_en(i),      -- !TODO: 23/03/2023 this signal + 1 must replace data_valid_m
        dout  => RX_det_m_fifo_out(i*26+25 downto i*26),   -- !TODO: 23/03/2023 this signal must replace RX_det_m
        full  => open,
        empty => elast_fifo_m_empty(i),
        data_count => elast_fifo_m_data_count(i)
        );

    fifo_26x16_s : fifo_26x16
      port map (
        clk   => clk20_c2,
        srst  => IP20, -- !debug: 20/04/2023 "not"(NRST_20M),
        din   => RX_det_s(i*26+25 downto i*26),
        wr_en => data_valid_s(i),
        rd_en => elast_fifo_rd_en(i),      -- !TODO: 23/03/2023 this signal + 2 must replace data data_valid_s
        dout  => RX_det_s_fifo_out(i*26+25 downto i*26),   -- !TODO: 23/03/2023 this signal must replace RX_det_m
        full  => open,
        empty => elast_fifo_s_empty(i),
        data_count => elast_fifo_s_data_count(i)
        );

  -- Sequence 1:
  --   - write to FIFO's: {data_valid_m,RX_det_m}, {data_valid_s,RX_det_s}
  --   - if (elast_fifo_m_empty = '0' and elast_fifo_s_empty = '0' and
  --     elast_fifo_rd_en_shr = "000") -> elast_fifo_rd_en
  --   - elast_fifo_rd_en_shr <= elast_fifo_rd_en_shr(1 downto 0) & elast_fifo_rd_en;
  --     if (elast_fifo_rd_en_shr(0) = '1') -> master data to MUX
  --     if (elast_fifo_rd_en_shr(1) = '1') -> slave data to MUX
  --   result: bad, because elast_fifo_m_empty,elast_fifo_s_empty not real-time
  -- Sequence 2:
  --   - write to FIFO's: {data_valid_m,RX_det_m}, {data_valid_s,RX_det_s}
  --   - elast_fifo_rd_en <= data_valid_m_shr(30 downto 0) & data_valid_m; -- solution, not need read counter, not need check FIFO empty
  --   - elast_fifo_rd_en_shr(i)(0) uses in place old data_valid_m,
  --     elast_fifo_rd_en_shr(i)(1) uses in place old data_valid_s_r
  --

  end generate elast_fifo_g;


  misc20m_pr: process(clk20_c2)
  begin
    if rising_edge(clk20_c2) then

      -- delayed slave ASIC data
      -- RX_det_s_r <= RX_det_s;
      -- data_valid_s_r <= data_valid_s;
      -- data_valid_s_r2 <= data_valid_s_r;
      data_valid_shr <= data_valid_shr(6 downto 0) & data_valid;
      rx_det_shr <= rx_det_shr(6 downto 0) & rx_det;

      reading_number_freerun_cnt_20m <= reading_number_freerun_cnt;
      dummy_data_sel_20m <= dummy_data_sel;
      
      for i in 0 to 3 loop

        data_valid_m_shr(i) <= data_valid_m_shr(i)(30 downto 0) & data_valid_m(i); -- solution, not need read counter, not need check FIFO empty
        elast_fifo_rd_en(i) <= data_valid_m_shr(i)(31);
        elast_fifo_rd_en_shr(i) <= elast_fifo_rd_en_shr(i)(1 downto 0) & elast_fifo_rd_en(i);


        -- RX data MUX to DPR
        -- !debug: 26/03/2023
        if (dummy_data_sel_r = '1') then
          rx_det(i*26+25 downto i*26) <= std_logic_vector(resize(unsigned(tile_sim_data(i)),26));
          data_valid(i) <= sim_data_valid;
        elsif (elast_fifo_rd_en_shr(i)(0) = '1') then -- select master ASIC
          data_valid(i) <= '1';
          rx_det(i*26+25 downto i*26) <= RX_det_m_fifo_out(i*26+25 downto i*26);
        elsif (elast_fifo_rd_en_shr(i)(1) = '1') then -- select slave ASIC
          data_valid(i) <= '1';
          rx_det(i*26+25 downto i*26) <= RX_det_s_fifo_out(i*26+25 downto i*26);
        else
          data_valid(i) <= '0';
          rx_det(i*26+25 downto i*26) <= std_logic_vector(resize(unsigned'(X"0000"),26));
        end if;

        -- synthetic data
        -- old format: tile0_sim_data <= X"0A" & std_logic_vector(tmcor_data_cnt(7 downto 0));
        -- new format: tile_sim_data(i) <= std_logic_vector(to_unsigned(i,4)) & "000" & map4ams_lut_addr(i)(8 downto 0); -- [15..12] - tile number, [8..0] - 512 detectors/tile
        if (send_constant = '1') then
          tile_sim_data(i) <= reading_number_freerun_cnt_20m;
        else
          -- normal slice order
          -- tile_sim_data(i) <= std_logic_vector(to_unsigned(i,4)) & "000" & map4ams_lut_addr(i)(8 downto 0); -- [15..12] - tile number, [8..0] - 512 detectors/tile
          -- 02/07/2023 reversed slice order
          tile_sim_data(i) <= std_logic_vector(to_unsigned(3-i,4)) & "000" & map4ams_lut_addr(i)(8 downto 0); -- [15..12] - tile number, [8..0] - 512 detectors/tile
        end if;

      end loop;  -- i

      bypass_lut <= diag_reg(3);
      send_constant <= diag_reg(5);     -- 14/06/2023

      if (IP20 = '1') then              -- 05/06/2023
        dummy_data_sel_r <= dummy_data_sel_20m;
      end if;

      if (IP20 = '1') then
        asic2fpga_time_cnt <= to_integer(unsigned(ASIC2FPGA_TIME_CONST) & X"0");
      else
        if (asic2fpga_time_cnt > 0) then
          asic2fpga_time_cnt <= asic2fpga_time_cnt - 1;
        end if;
      end if;

      if (IP20 = '1') then
        sim_data_cnt <= 0;
        sim_data_valid <= '0';
        mod5_cnt <= 0;
        addr_sim_slave <= '0';
      elsif (asic2fpga_time_cnt = 0) then
        if (mod5_cnt < 4) then
          mod5_cnt <= mod5_cnt + 1;
        else
          mod5_cnt <= 0;
        end if;
        if (mod5_cnt = 1 or mod5_cnt = 2) then
          if (dummy_data_sel_r = '1' and asic2fpga_time_cnt = 0 and sim_data_cnt < 256) then  -- 17/04/2023
            sim_data_valid <= '1';        -- sequence for compatibility with tile data: '0', m, s, 2x '0'
          end if;
        else
          sim_data_valid <= '0';
        end if;
        if (sim_data_cnt < 256) then
          if (mod5_cnt = 4) then
            sim_data_cnt <= sim_data_cnt + 1;
          end if;
        end if;
        if (mod5_cnt = 3) then          -- 18/04/2023
          addr_sim_slave <= '1';
        else
          addr_sim_slave <= '0';
        end if;

      end if;

    end if;
  end process misc20m_pr;


  misc50m_pr: process(sys_clk)
  begin
    if rising_edge(sys_clk) then

      IP50_r <= IP50;
      sync_ip <= IP50 and not IP50_r; -- 29/05/2022
      AMS_Time_50m <= AMS_Time;

      for i in 0 to 3 loop

        if (sync_ip = '1') then
          det_arrange_dpr_rdaddr(i) <= (others => '0');
        elsif (wr2dpr_ready_shr(7)(i) = '1') then
          if (unsigned(det_arrange_dpr_rdaddr(i)) < 9UX"1FF") then -- 512 detectors/tile
            det_arrange_dpr_rdaddr(i) <= std_logic_vector(unsigned(det_arrange_dpr_rdaddr(i)) + 1);
          end if;
        end if;

        if (sync_ip = '1') then
          data_valid2dpr(i) <= '0';
          last_rd(i)             <= '0';
        elsif (wr2dpr_ready_shr(7)(i) = '1') then
          if (unsigned(det_arrange_dpr_rdaddr(i)) < 9UX"1FF") then -- 512 detectors/tile
            data_valid2dpr(i) <= '1';
            last_rd(i)             <= '0';
          else
            data_valid2dpr(i) <= '0';
            last_rd(i)             <= data_valid2dpr(i);
          end if;
        else
          data_valid2dpr(i) <= '0';
        end if;

        data_valid_lut(i) <= data_valid2dpr(i) or last_rd(i);

        if (sync_ip = '1') then               -- !debug: 18/04/2023 compensates possible delay from IP50 to IP20
          IP50_to_IP20_protect_cnt <= 10;
          wr2dpr_ready_0(i) <= '0';
        elsif (IP50_to_IP20_protect_cnt /= 0) then
          IP50_to_IP20_protect_cnt <= IP50_to_IP20_protect_cnt - 1;
          wr2dpr_ready_0(i) <= '0';
        elsif (IP50_to_IP20_protect_cnt = 0) then
          wr2dpr_ready_0(i) <= wr2dpr_ready(i);     -- sync end of write to DPR
        end if;

        if (sync_ip = '1' or wr2dpr_ready_0(i) = '0') then
          for x in 7 downto 0 loop
            wr2dpr_ready_shr(x)(i) <= '0';
          end loop;  -- x
        else
          for x in 7 downto 0 loop
            if (x = 0) then
              wr2dpr_ready_shr(0)(i) <= wr2dpr_ready_0(i);
            else
              wr2dpr_ready_shr(x)(i) <= wr2dpr_ready_shr(x-1)(i);
            end if;
          end loop;  -- x
        end if;

        -- MU calc in
        mu_in(i*26+25 downto i*26) <= RX_det_lut(i*26+25 downto i*26); -- see RX_det_bout in TMCOR v.6
        mu_in_valid(i) <= data_valid_lut(i); -- see data_valid_bout in TMCOR v.6

      end loop;  -- i

      take_rx_det_msb <= take_rx_det_msb_reg; -- 0x279 [2] - when no MU calc in case raw data mode take coarse counter
      rx_det_shl <= rx_det_shl_reg;            -- 11/07/2022
      pipeline_ctl_r <= pipeline_ctl_reg;

      if (sync_ip = '1') then
        ams_offset_i <= BASIC_OFFSET(to_integer(unsigned(ibias)));
      end if;

      gain_r <= gain;

      if (timer_1_us_cnt < 49) then
        timer_1_us_cnt <= timer_1_us_cnt + 1;
      else
        timer_1_us_cnt <= 0;
      end if;

      if (sync_ip = '1') then
        ip_exist <= TRUE;
        tile_packet_ok_timeout_cnt <= to_integer(unsigned(tile_packet_ok_timeout_reg));
        -- synthesis translate_off
        tile_packet_ok_timeout_cnt <= 16#44#; -- !debug: 13/09/2023 16#4E# good for my TB
        -- synthesis translate_on
      elsif (ip_exist and timer_1_us_cnt = 49 and tile_packet_ok_timeout_cnt /= 0) then
        tile_packet_ok_timeout_cnt <= tile_packet_ok_timeout_cnt - 1;
      end if;

      -- !TODO: 04/09/2023 asic_data_good_read, tile_packet_ok_shr, tile_packet_ok, tile_packet_ok_muxsel - create code for each tile
      tile_packet_ok_shr(3 downto 0) <= tile_packet_ok_shr(2 downto 0) & asic_data_good_read;

      for i in 0 to 3 loop

        if (sync_ip = '1') then
          tile_packet_ok(i) <= FALSE;
        elsif (tile_packet_ok_shr(1)(i) = '1' and tile_packet_ok_shr(2)(i) = '0') then
          tile_packet_ok(i) <= TRUE;
        end if;

        if (tile_packet_ok_timeout_cnt = 0) then -- 04/09/2023
          if (tile_packet_ok(i) or dummy_data_sel_r = '1') then
            tile_packet_ok_muxsel(i) <= '0';
          else
            tile_packet_ok_muxsel(i) <= '1';
          end if;
        end if;

      end loop;  -- i

      if (dpr512x16_wr_complete and not dpr512x16_wr_complete_r) then
        sorter_data_ready <= '1';       -- 26/11/2023
      else
        sorter_data_ready <= '0';
      end if;

    end if;
  end process misc50m_pr;


  -- 14/06/2021 LUT + DPR
  lut_dpr_g : for i in 0 to (NumOfTiles-1) generate

    lut_ctl_pr : process (clk20_c2, NRST_20M) is
    begin  -- process lut_ctl_pr
      if (NRST_20M = '0') then                        -- asynchronous reset (active low)
        map4ams_lut_addr(i)       <= (others => '0');
        -- data_valid_r(i)           <= '0';
        wr2dpr_ready(i)           <= '0';
        data_1st_pixel(i) <= FALSE;
      elsif (clk20_c2'EVENT and clk20_c2 = '1') then  -- rising clock edge

        if (IP20 = '1') then
          data_1st_pixel(i) <= TRUE;
        elsif (data_valid_shr(0)(i) /= '0') then
          data_1st_pixel(i) <= FALSE;   -- 05/04/2023
        end if;

        if (IP20 = '1') then -- start offset
          if (bypass_lut = '0') then
            map4ams_lut_addr(i) <= (others => '0');
          else
            map4ams_lut_addr(i) <= 10UX"200";
          end if;
        elsif (dummy_data_sel_r = '0') then  -- tiles data
          -- if (data_valid_m(i) = '1' and not data_1st_pixel) then  -- must be aligned with next data_valid_m data_valid_m_shr()
          if (elast_fifo_rd_en_shr(i)(0) = '1' and not data_1st_pixel(i)) then  -- must be aligned with next data_valid_m data_valid_m_shr()
            map4ams_lut_addr(i) <= bypass_lut & std_logic_vector(unsigned(map4ams_lut_addr(i)(8 downto 0)) + 1);  -- mem depth according num of detectors
          end if;
        elsif (dummy_data_sel_r = '1' and asic2fpga_time_cnt = 0) then  -- simulated data
                                                                        -- !TODO: 23/10/2022 add synth data start time
          if (sim_data_cnt < 256) then
            map4ams_lut_addr(i) <= bypass_lut & std_logic_vector(to_unsigned(sim_data_cnt,9));
          end if;
        end if;

        -- data_valid_r(i) <= data_valid(i); -- !debug: 23/10/2022 check, must be aligned with rx_det

        if (IP20 = '1') then
          wr2dpr_ready(i) <= '0';
        elsif ((bypass_lut = '0' and map4ams_lut_addr(i) = 10UX"0FF") or -- 512 detectors from addr 0
               (bypass_lut = '1' and map4ams_lut_addr(i) = 10UX"2FF")) then -- 512 detectors from addr 0x200
                                                                            -- note: address increments only for master ASIC
          wr2dpr_ready(i) <= '1';       -- enable read from DPR
        end if;

        if (dummy_data_sel_r = '0') then -- 17/04/2023
          map4ams_lut_addr_muxed(i) <= map4ams_lut_addr(i)(9) & elast_fifo_rd_en_shr(i)(2) & map4ams_lut_addr(i)(7 downto 0); --Miki 27/Mar/2023
        else
          map4ams_lut_addr_muxed(i) <= map4ams_lut_addr(i)(9) & addr_sim_slave & map4ams_lut_addr(i)(7 downto 0);
        end if;


      end if;
    end process lut_ctl_pr;


    map4ams_lut_1 : map4ams_lut
      port map (
        clka  => clk20_c2,
        addra => map4ams_lut_addr_muxed(i),
        douta => map4ams_det_num(i)     -- decoded address
        );

    -- LUT DPR
    det_arrange_dpr_1 : det_arrange_dpr
      port map (
        clka   => clk20_c2,
        wea(0) => data_valid_shr(2)(i),
        addra  => map4ams_det_num(i)(8 downto 0),
        dina   => rx_det_shr(2)(i*26+25 downto i*26),   -- data before LUT + DPR
        clkb   => sys_clk,
        addrb  => det_arrange_dpr_rdaddr(i),
        doutb  => RX_det_lut(i*26+25 downto i*26)  -- data after LUT + DPR
                                                   -- note: read latency 2clk
        );

  end generate lut_dpr_g;


  mu_calc_g: for i in 0 to NumOfTiles-1 generate

    -- MU calc
    PIPELINE2_IF : PIPELINE2
      port map(
        --input control
        CLK            => sys_clk,
        RST            => "not"(rst_n),
        DELTA_EN       => pipeline_ctl_r(14), -- '0', NU
        OSUB_EN		   => pipeline_ctl_r(16), -- 02/12/2021 was    osub_en, -- from 0x275 [6]
        LOG_EN		   => pipeline_ctl_r(15), -- '1',
        TCSUB_EN	   => pipeline_ctl_r(17), -- '1',
        PASST		   => pipeline_ctl_r(8), -- '0',
        ZERO_BAD_POINT => pipeline_ctl_r(18), -- '1',
        DSTROBE        => mu_in_valid(i),  -- data strobe, in simulation - pulse depends from CNT_1_usec period
        AMS_Charge     => mu_in(i*26+25 downto i*26),
        AMS_Time       => AMS_Time_50m(i*16+15 downto i*16), -- 16/06/2021 ACLK counter, was X"0400"
        AMS_Offset     => ams_offset_i, -- 13/12/2021  was AMS_Offset from register 0x72
        Global_IP_Time => global_ip_time_reg,    -- was X"3333"
        gain           => gain_r, -- diag_temp_r(3 downto 0),
        diag_in        => X"0", -- diag_temp_r(3 downto 0),
        sync_ip        => sync_ip,
        --pipeline output
        MU_OUT         => MU_OUT(i),
        MU_VAL         => mu_val(i),
        MU_BAD         => open
        );

  end generate mu_calc_g;


  mu_ctl_pr: process (sys_clk, rst_n) is
  begin  -- process mu_ctl_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      mu_in_det_shr <= (others => (others => '0'));
      mu_in_valid_shr <= (others => (others => '0'));
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      mu_en <= mu_ctl_reg;

      for i in 0 to 3 loop
        mu_in_det_shr <= mu_in_det_shr(6 downto 0) & mu_in;
        mu_in_valid_shr <= mu_in_valid_shr(6 downto 0) & mu_in_valid;
      end loop;  -- i

      if (mu_en = '0') then -- LSB from 26bit data
        if (take_rx_det_msb = '0') then
          if (rx_det_shl = '0') then    -- 11/07/2022
            tile0_mu_data <= mu_in_det_shr(6)(15 downto 0);
            tile1_mu_data <= mu_in_det_shr(6)(DW_WIDTH+15 downto DW_WIDTH);
            tile2_mu_data <= mu_in_det_shr(6)(2*DW_WIDTH+15 downto 2*DW_WIDTH);
            tile3_mu_data <= mu_in_det_shr(6)(3*DW_WIDTH+15 downto 3*DW_WIDTH);
          else
            tile0_mu_data <= mu_in_det_shr(6)(16 downto 1);
            tile1_mu_data <= mu_in_det_shr(6)(DW_WIDTH+16 downto DW_WIDTH+1);
            tile2_mu_data <= mu_in_det_shr(6)(2*DW_WIDTH+16 downto 2*DW_WIDTH+1);
            tile3_mu_data <= mu_in_det_shr(6)(3*DW_WIDTH+16 downto 3*DW_WIDTH+1);
          end if;
        else
          -- note: here coarse quantizer 1 / 2 always in rx_det[25..17], QP1 / QP2 selector in receiver
          tile0_mu_data <= "0000000" & mu_in_det_shr(6)(17+8 downto 17+0); -- 27/03/2022 when MSB, uses QP2 Data
          tile1_mu_data <= "0000000" & mu_in_det_shr(6)(17+DW_WIDTH+8 downto 17+DW_WIDTH);
          tile2_mu_data <= "0000000" & mu_in_det_shr(6)(17+(2*DW_WIDTH)+8 downto 17+(2*DW_WIDTH));
          tile3_mu_data <= "0000000" & mu_in_det_shr(6)(17+(3*DW_WIDTH)+8 downto 17+(3*DW_WIDTH));
        end if;
      else                  -- MU data
        tile0_mu_data <= MU_OUT(0);
        tile1_mu_data <= MU_OUT(1);
        tile2_mu_data <= MU_OUT(2);
        tile3_mu_data <= MU_OUT(3);
      end if;

    end if;
  end process mu_ctl_pr;


  slices_sort_pr : process (sys_clk, rst_n) is
  begin  -- process slices_sort_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      dpr512x16_wr <= (others => '0');
      dpr512x16_addra <= (others => '0');
      for i in 0 to 3 loop
        dpr512x16_wr_cnt(i) <= 0;
        dpr512x16_wr_complete_vec(i)<= FALSE;
      end loop;

    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      for i in 0 to 3 loop

        -- write to DPR before slices MUX
        if (tile_packet_ok_timeout_cnt = 0 and not tile_packet_ok(i)) then -- 04/09/2023 no tile data
          if (dpr512x16_wr_cnt(i) /= 511) then
            dpr512x16_wr(i) <= '1';
          else
            dpr512x16_wr(i) <= '0';
          end if;
        elsif (mu_en = '0') then -- no MU
          dpr512x16_wr(i) <= mu_in_valid_shr(6)(i);
        else
          dpr512x16_wr(i) <= mu_val(i);
        end if;

        if (sync_ip = '1') then
          dpr512x16_addra <= (others => '0');
        elsif (dpr512x16_wr(i) = '1') then
          dpr512x16_addra(9*i+8 downto 9*i) <= std_logic_vector(unsigned(dpr512x16_addra(9*i+8 downto 9*i)) + 1);
        end if;
        if (sync_ip = '1') then
            dpr512x16_wr_cnt(i) <= 0;
        elsif (dpr512x16_wr(i)= '1')  then         -- from one tile only
            if (dpr512x16_wr_cnt(i) /= 511) then
              dpr512x16_wr_cnt(i) <= dpr512x16_wr_cnt(i) + 1;
            end if;
        end if;

        if (num_of_tiles(i) = '0' and dummy_data_sel_r = '0') then -- tile not exist
          dpr512x16_wr_complete_vec(i) <= FALSE;
        elsif (dpr512x16_wr(i)= '1') then -- unset when new write, else latch when complete
          dpr512x16_wr_complete_vec(i) <= FALSE;
        elsif (dpr512x16_wr_cnt(i) = 511) then
          dpr512x16_wr_complete_vec(i) <= TRUE;
        end if;

      end loop;  -- i

    end if;
  end process slices_sort_pr;

  dpr512x16_wr_complete <= dpr512x16_wr_complete_vec(0) or dpr512x16_wr_complete_vec(1) or dpr512x16_wr_complete_vec(2) or dpr512x16_wr_complete_vec(3);
  ----------------------------------------------------------------------------------------------------
  dpr512x16_dina_i <= tile3_mu_data & tile2_mu_data & tile1_mu_data & tile0_mu_data;

  slices_dpr_g : for i in 0 to (NumOfTiles-1) generate

    dpr512x16_dina(16*i+15 downto 16*i) <= dpr512x16_dina_i(16*i+15 downto 16*i) when (tile_packet_ok_muxsel(i) = '0') else X"FF" & std_logic_vector(to_unsigned(i,8));

    -- MU DPR
    blk_mem_dpr512x16_1 : blk_mem_dpr512x16to32
      port map
      (
        clka  => sys_clk,
        wea(0) => dpr512x16_wr(i),
        addra => dpr512x16_addra(9*i+8 downto 9*i), -- !debug: 23/10/2022 was depth 256, now 512
        dina  => dpr512x16_dina(16*i+15 downto 16*i),
        clkb  => sys_clk,
        addrb => dpr512x16_addrb(7 downto 0), -- blk_mem_dpr512x16: [8..0]
        doutb => dpr512x16_doutb(32*i+31 downto 32*i) -- blk_mem_dpr512x16: (16*i+15 downto 16*i)
        );

  end generate slices_dpr_g;


  data_out_sequencer_pr : process (sys_clk, rst_n) is
  begin  -- process data_out_sequencer_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      First_Detector_ADDR <= (others => '0');
      Last_Detector_ADDR <= (others => '0');
      dpr512x16_addrb <= (others => '0');
      dpr512x16_addrb_r1 <= (others => '0');
      -- dpr512x16_addrb_r2 <= (others => '0');
      dpr512x16_addrb_ss <= (others => '0');
      dpr512x16_wr_complete_r <= FALSE;
      fq_data_valid_0 <= '0';
      fq_data_valid_1 <= '0';
      fq_data_valid <= '0';
      last_word <= FALSE;
      dpr512x16_rden <= FALSE;
      -- dpr512x16_rden_r1 <= FALSE;
      fq_data_in_i <= (others => '0');
      first_word <= FALSE;
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      -- if (not dpr512x16_wr_complete) then -- !debug: 25/07/2023 protect from change address, when read from DPR
      if (IP50 = '1') then -- !debug: 27/11/2023 protect from change address, when read from DPR
        First_Detector_ADDR <= to_unsigned(512,10) - (unsigned(Num_of_Slices(6 downto 1)) & "0000");
        Last_Detector_ADDR <= to_unsigned(512,10) + (unsigned(Num_of_Slices(6 downto 1)) & "0000") - 1;
      end if;

      dpr512x16_wr_complete_r <= dpr512x16_wr_complete;

      -- if (dpr512x16_wr_complete and not dpr512x16_wr_complete_r) then
      if (dpr512x16_wr_complete and sync_ip = '1') then -- !debug: 26/11/2023 restart
                              -- was: dpr_header_updated = '0' or sync_ip = '1'
        dpr512x16_addrb <= std_logic_vector(First_Detector_ADDR);
        first_word <= TRUE;
      elsif (first_word and dpr512x16_wr_complete and unsigned(dpr512x16_addrb) = First_Detector_ADDR) then -- !debug: 26/11/2023 start read from DPR2
        dpr512x16_addrb <= std_logic_vector(unsigned(dpr512x16_addrb) + 1);
        first_word <= FALSE;
      elsif (unsigned(dpr512x16_addrb) < Last_Detector_ADDR) then -- !debug: 25/07/2023  and dpr512x16_rden
        dpr512x16_addrb <= std_logic_vector(unsigned(dpr512x16_addrb) + 1);
        first_word <= FALSE;
      end if;

      last_word <= (dpr512x16_wr_complete_r and unsigned(dpr512x16_addrb) = Last_Detector_ADDR);

      dpr512x16_addrb_r1 <= dpr512x16_addrb;
      -- dpr512x16_addrb_r2 <= dpr512x16_addrb_r1;

      case dpr512x16_addrb_r1(9 downto 8) is -- blk_mem_dpr512x16: [10..9]
        when "00" => dpr512x16_addrb_ss <= "11";
        when "01" => dpr512x16_addrb_ss <= "10";
        when "10" => dpr512x16_addrb_ss <= "01";
        when "11" => dpr512x16_addrb_ss <= "00";
        when others => null;
      end case;

      for i in 0 to 3 loop
        if (unsigned(dpr512x16_addrb_ss) = i) then
          fq_data_in_i <= dpr512x16_doutb(32*i+31 downto 32*i);  -- DPR data MUX
                                                               -- blk_mem_dpr512x16: (16*i+15 downto 16*i)
        end if;
      end loop;  -- i

      if (dpr512x16_rden and unsigned(dpr512x16_addrb) < Last_Detector_ADDR) then
        fq_data_valid_1 <= '1';
      elsif (dpr512x16_rden and unsigned(dpr512x16_addrb) = Last_Detector_ADDR) then
        fq_data_valid_1 <= '1';
      else
        fq_data_valid_1 <= '0';
      end if;

      -- fq_data_valid_1 <= fq_data_valid_0;
      fq_data_valid <= fq_data_valid_1; -- read latency

      if (sync_ip = '1') then
        fq_data_valid_cnt <= 0;
        fq_data_valid_cnt_r <= 0;
      elsif (dpr512x16_rden and unsigned(dpr512x16_addrb) < Last_Detector_ADDR) then   -- !debug: 18/04/2023 only for test
        fq_data_valid_cnt <= fq_data_valid_cnt + 1;
        fq_data_valid_cnt_r <= fq_data_valid_cnt;
      end if;

      if (first_word and sync_ip = '0') then -- !debug: 27/11/2023
        dpr512x16_rden <= TRUE;
      elsif (last_word) then
        dpr512x16_rden <= FALSE;
      end if;
      -- dpr512x16_rden_r1 <= dpr512x16_rden;

    end if;
  end process data_out_sequencer_pr;


  fq_data_in <= fq_data_in_i(15 downto 0) & fq_data_in_i(31 downto 16); -- !debug: 14/08/2023 swap

end architecture ar;
