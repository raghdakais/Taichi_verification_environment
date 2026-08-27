-------------------------------------------------------------------------------
-- Title      : Dummy tile
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : io_tiles.vhd
-- Author     :   <Shinderman Eugene  <evgene@hbtech.co.il>>
-- Company    : HBtech
-- Created    : 28/07/2019
-- Last update: 19/01/2023
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description: Block preserves pins in design.
-------------------------------------------------------------------------------
-- Copyright (c) 2022 HBtech
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 28/07/2019  1.0      310268386   Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.phoebe.all;


entity io_tiles is
  generic (
    GEN_OUT_CLK : boolean := FALSE);
  port(
    fast_clk: in  std_logic;            -- tiles clock
    ACLK_MASTER : in std_logic;
    SYNC_i  : in std_logic;
    SCS1n_i : in std_logic;
    SCS2n_i : in std_logic;
    SDI_i   : in std_logic;
    SCLK_i  : in std_logic;
    Tiles_rst_i : in std_logic;
    Discard_i   : in std_logic;
    SDO_i   : out std_logic;
    asic1_data : out std_logic;
    asic2_data : out std_logic;
    -- Tiles IF
    TILES_CLK : out STD_LOGIC;
    TILES_CLK_N : out STD_LOGIC;
    RESETn  : out std_logic;
    ACLK    : out std_logic;
    SYNC    : out std_logic;
    D_START : out std_logic;  -- add 03/11/2019
    DISCARD : out std_logic;
    SCLK    : out std_logic;
    SCS1n   : out std_logic;
    SCS2n   : out std_logic;
    SDI     : out std_logic;
    SDO     : in  std_logic;
    ACO     : in  std_logic;
	ACO_N	: in  std_logic;
	DATA1	: in  std_logic;
	DATA1_N : in  std_logic;
	DATA2	: in  std_logic;
	DATA2_N : in  std_logic
    );

end io_tiles;


architecture ar of io_tiles is


  -- component ODDR
  --   generic (
  --     DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
  --     INIT		   : bit	:= '0';
  --     SRTYPE	   : string := "SYNC"
  --     );
  --   port (
  --     Q	 : out std_ulogic;
  --     C	 : in  std_ulogic;
  --     CE : in  std_ulogic;
  --     D1 : in  std_ulogic;
  --     D2 : in  std_ulogic;
  --     R	 : in  std_ulogic := 'L';
  --     S	 : in  std_ulogic := 'L'
  --     );
  -- end component;
  --  
  -- component OBUFDS
  --   generic (
  --     CAPACITANCE : string := "DONT_CARE";
  --     IOSTANDARD  : string := "DEFAULT";
  --     SLEW		  : string := "SLOW"
  --     );
  --   port (
  --     O	 : out std_ulogic;
  --     OB : out std_ulogic;
  --     I	 : in  std_ulogic
  --     );
  -- end component;
  --  
  -- component IBUFDS
  --   generic (
  --     CAPACITANCE	   : string	 := "DONT_CARE";
  --     DIFF_TERM		   : boolean := FALSE;
  --     DQS_BIAS		   : string	 := "FALSE";
  --     IBUF_DELAY_VALUE : string	 := "0";
  --     IBUF_LOW_PWR	   : boolean := TRUE;
  --     IFD_DELAY_VALUE  : string	 := "AUTO";
  --     IOSTANDARD	   : string	 := "DEFAULT"
  --     );
  --   port (
  --     O	 : out std_ulogic;
  --     I	 : in  std_ulogic;
  --     IB : in  std_ulogic
  --     );
  -- end component;

  signal oddr_q : std_logic;
  signal acq_i : std_logic;


begin  -- architecture ar


  SYNC  <= SYNC_i;
  SCS1n <= SCS1n_i;
  SCS2n <= SCS2n_i;
  SDI <= SDI_i;
  SCLK <= SCLK_i;
  SDO_i <= SDO;
  RESETn <= Tiles_rst_i;
  DISCARD <= Discard_i;
  D_START <= '0';  -- uses IDLE_WORD for sync
  --ACLK <= ACLK_i;              -- !debug: 09/05/2021 select ACLK external from pin or from tiles_managment
  ACLK <= ACLK_MASTER; -- directly from CDM

  clk_out_g: if (GEN_OUT_CLK) generate

    ODDR_inst : ODDR
      generic map(
        DDR_CLK_EDGE => "OPPOSITE_EDGE",  -- "OPPOSITE_EDGE" or "SAME_EDGE"
        INIT         => '0',              -- Initial value for Q port ('1' or '0')
        SRTYPE       => "SYNC")           -- Reset Type ("ASYNC" or "SYNC")
      port map (
        Q  => oddr_q,                     -- 1-bit DDR output
        C  => fast_clk,                   -- 1-bit clock input
        CE => '1',                        -- 1-bit clock enable input
        D1 => '0',                        -- 1-bit data input (positive edge)
        D2 => '1',                        -- 1-bit data input (negative edge)
        R  => '0',                        -- 1-bit reset input
        S  => '0'                         -- 1-bit set input
        );

    OBUFDS_inst : OBUFDS
      generic map (
        -- IOSTANDARD => "DEFAULT",        -- Specify the output I/O standard
        IOSTANDARD => "LVDS_25",        -- Specify the output I/O standard
        SLEW       => "SLOW")           -- Specify the output slew rate
      port map (
        O  => TILES_CLK,                -- Diff_p output (connect directly to top-level port)
        OB => TILES_CLK_N,              -- Diff_n output (connect directly to top-level port)
        I  => oddr_q                    -- Buffer input
        );

  end generate clk_out_g;


  DATA1_inst : IBUFDS
    generic map (
      DIFF_TERM => TRUE, -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD => "LVDS_25")
    port map (
      O  => asic1_data,                    -- Buffer output
      I  => DATA1,                      -- Diff_p buffer input (connect directly to top-level port)
      IB => DATA1_N                     -- Diff_n buffer input (connect directly to top-level port)
      );


  DATA2_inst : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => asic2_data,                 -- Buffer output
      I  => DATA2,                      -- Diff_p buffer input (connect directly to top-level port)
      IB => DATA2_N                     -- Diff_n buffer input (connect directly to top-level port)
      );


  ACO_inst : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => acq_i,                      -- Buffer output !debug: 06/11/2022 NU
      I  => ACO,                        -- Diff_p buffer input (connect directly to top-level port)
      IB => ACO_N                       -- Diff_n buffer input (connect directly to top-level port)
      );



end architecture ar;
