-------------------------------------------------------------------------------
-- Title      : Testbench for design "slice_builder"
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : taichi_slice_builder_tb.vhd
-- Author     : Shinderman Eugene  <eu1@localhost-localdomain>
-- Company    :
-- Created    : 07/09/2022
-- Last update: 30/09/2023
-- Platform   :
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2022
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 07/09/2022  1.0      eu1	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

-- use work.phoebe.all;


entity taichi_slice_builder_tb is

end entity taichi_slice_builder_tb;


architecture ar of taichi_slice_builder_tb is

  -- component ports
  signal reset_n        : std_logic := '0';
  signal comm_clk, fclk  : std_logic := '0';
  alias sys_clk : std_logic is comm_clk;
  signal clk20_c2       : std_logic := '0';
  -- signal dummy_data_sel : std_logic;
  signal IP20           : std_logic;
  -- signal data_valid     : std_logic_vector(NumOfTiles-1 downto 0);
  -- signal RX_det         : std_logic_vector((NumOfTiles*8)-1 downto 0);
  signal rx_comm_clk, rx_fclk : std_logic := '0';

  signal CTL : std_logic_vector(1 downto 0);

  component taichi_slice_builder is
    generic (WORD_WIDTH : natural);
    port (reset_n                 : in  std_logic;
          nRST_20m                : in  std_logic;
          sys_clk                 : in  std_logic;
          rx_div_clk              : in  std_logic;
          comm_clk                : in  std_logic;
          dummy_data_sel          : in  std_logic;
          diag_reg                : in  std_logic_vector(7 downto 0);
          diag_temp_reg           : in  std_logic_vector(7 downto 0);
          IP20                    : in  std_logic;
          IP32                    : in  std_logic;
          rd_reading_ready        : in  std_logic;
          rx_det                  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
          rx_fifo_empty           : in  std_logic;  -- RX FIFO empty
          rx_fifo_rd              : out std_logic;
          reading_type            : in  std_logic;
          footer_bits             : in  std_logic_vector(16*8-1 downto 0);
          TX_STATn_DYN            : out std_logic;
          TX_GO                   : out std_logic;
          TX_IP                   : out std_logic;
          TX_PayloadSize          : out std_logic_vector (31 downto 0);
          TX_DATA_IN              : out std_logic_vector (7 downto 0);
          TX_RD_EMPTY             : out std_logic;
          TX_RD_REQ               : in  std_logic;
          taichi_slice_builder_tp : out std_logic_vector (7 downto 0));
  end component taichi_slice_builder;

  signal rd_reading_ready : std_logic := '0';
  signal footer_bits      : std_logic_vector(16*8-1 downto 0);

  signal TX_STATn_DYN            : std_logic;
  signal TX_GO                   : std_logic;
  signal TX_IP                   : std_logic;
  signal TX_PayloadSize          : std_logic_vector (31 downto 0);
  signal TX_DATA_IN              : std_logic_vector (7 downto 0);
  signal TX_RD_EMPTY             : std_logic;
  signal TX_RD_REQ               : std_logic;
  signal TX_DATA_out             : std_logic;

  component TX_series7 is
    generic (
      IDLE_WORD    : std_logic_vector (7 downto 0) := x"B5";
      StartWord    : std_logic_vector (7 downto 0) := x"21";
      Stream_type1 : std_logic_vector (7 downto 0) := x"43";
      Stream_type2 : std_logic_vector (7 downto 0) := x"DD";
      NumHeaderbytes : std_logic_vector (7 downto 0)  := x"08";
      NumDatabytes   : std_logic_vector (31 downto 0) := x"00000020";
      NumFooterbytes : std_logic_vector (7 downto 0)  := x"08"
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
  end component TX_series7;

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
      crc_error            : out std_logic;
      std_error            : out std_logic);
  end component RX_series7;

  signal channel_RDY : std_logic;

begin  -- architecture ar

  reset_n <= '0', '1' after 1 US;

  comm_clk <= not comm_clk after 10 ns; -- 50MHz
  clk20_c2 <=  not clk20_c2 after 25 ns; -- 20MHz
  fclk <= not fclk after 2.5 NS;          -- @200MHz

  channel_RDY <= '1', '0' after 20 US, '1' after 40 US;

  -- IP generation, !debug: for ASIC init Aron send one clock chip reset ("11"), then
  -- after 1 US one clock clock reset ("10"), then after 40 US one clock clock reset ("10")
  ip_pr : process is
  begin  -- process ip_pr

    CTL <= "10";                        -- init_ck
    wait for 5 US;
    CTL <= "00";
    wait for 5 US;

    loop

      CTL <= "01";                      -- send IP pulse
      wait for 1 US;
      CTL <= "00";

      wait for 200 US;

    end loop;

  end process ip_pr;

  IP20 <= '1' when (CTL = "01") else '0';
  rd_reading_ready <= transport IP20 after 50 US; -- pulse TBD RX latency after IP

  taichi_slice_builder_1 : taichi_slice_builder
    generic map (WORD_WIDTH => 16)
    port map (
      reset_n                 => reset_n,
      nRST_20m                => reset_n,
      sys_clk                 => sys_clk,
      rx_div_clk              => clk20_c2,
      comm_clk                => comm_clk,
      dummy_data_sel          => '1',   -- !TODO: drive from register
      diag_reg                => (others => '0'),
      diag_temp_reg           => X"1A",
      IP20                    => IP20,
      IP32                    => IP20,
      rd_reading_ready        => rd_reading_ready,
      rx_det                  => (others => '0'), -- !TODO: 07/09/2022 connect RX data
      rx_fifo_empty           => '1',
      rx_fifo_rd              => open, -- !TODO: 07/09/2022 connect RX data
      reading_type            => '1',  -- '0' - EV, '1' - FQ
      footer_bits             => footer_bits,
      TX_STATn_DYN            => TX_STATn_DYN,
      TX_GO                   => TX_GO,
      TX_IP                   => TX_IP,
      TX_PayloadSize          => TX_PayloadSize,
      TX_DATA_IN              => TX_DATA_IN,
      TX_RD_EMPTY             => TX_RD_EMPTY,
      TX_RD_REQ               => TX_RD_REQ,
      taichi_slice_builder_tp => open
    );

  -- !TODO: 07/09/2022 copy footer from TMCOR v.6
  footer_l: for i in 0 to 15 generate
    ii: if (i = 0) generate
      footer_bits(i*8+7 downto i*8) <= X"11";
    elsif (i = 15) generate
      footer_bits(i*8+7 downto i*8) <= X"88";
    else generate
      footer_bits(i*8+7 downto i*8) <= X"00";
    end generate ii;
  end generate footer_l;

  TX_series7_1 : TX_series7
    generic map (
      IDLE_WORD      => x"B5",
      StartWord      => x"21",
      Stream_type1   => x"43",
      Stream_type2   => x"DD",
      NumHeaderbytes => x"04",         -- 4bytes packet header
      NumDatabytes   => x"00000890",   -- uses when static packet
                                       -- FQ, 16bytes TMB footer = 4+(128+2048+16)+0
      NumFooterbytes => x"00"          -- no packet footer
      )
    port map (
      RESET       => "not"(reset_n),
      CLKDIV      => comm_clk,
      FCLK        => FCLK,
      STATn_DYN   => TX_STATn_DYN,
      GO          => TX_GO,
      IP          => TX_IP,
      PayloadSize => TX_PayloadSize,
      DATA_IN     => TX_DATA_IN,
      RD_EMPTY    => TX_RD_EMPTY,
      RD_CLK      => open,
      RD_REQ      => TX_RD_REQ,
      DATA_out    => TX_DATA_out
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
      NumHeaderBytes => 4,
      NumDataBytes   => 32,             -- NA for dynamic packet
      NumFooterBytes => 0)
    port map (
      RESET                => "not"(reset_n),
      CLKDIV               => rx_comm_clk, -- comm_clk,
      FCLK                 => rx_fclk, -- FCLK,
      channel_RDY          => channel_RDY,
      sDataIn              => TX_DATA_out,
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
      crc_error            => open,
      std_error            => open
      );

  rx_comm_clk <= transport comm_clk after 1.2 NS; -- 12/09/2022
  rx_fclk <= transport fclk after 1.2 NS;

  -- -- waveform generation
  -- WaveGen_Proc: process
  -- begin
  --   -- insert signal assignments here
  --
  --   wait until Clk = '1';
  -- end process WaveGen_Proc;



end architecture ar;
