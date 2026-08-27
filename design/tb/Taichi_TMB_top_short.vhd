-------------------------------------------------------------------------------
-- Title      : Taichi TMB project top
-- Project    : Taichi module board, TMB
-------------------------------------------------------------------------------
-- File       : Taichi_TMB_top_short.vhd
-- Author     : Shinderman Eugene  <eu1@localhost-localdomain>
-- Company    : HBtech
-- Created    : 05/09/2022
-- Last update: 19/06/2024
-- Platform   : Vivado v.2018.2, Device : xc7s75fgga484-2
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: TMCOR with AMS v.6 Slice Builder, only for HD tiles
-------------------------------------------------------------------------------
-- Copyright (c) 2022
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 05/09/2022  1.0      eu1	only synthetic data
-------------------------------------------------------------------------------
-- 04/06/2024 test for single AMS SPI control and one Tiles_managment block
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.phoebe.all;
use work.tbuf_pack.all;


entity Taichi_TMB_top_short is
  generic (
    incr_num : std_logic_vector(31 downto 0) := X"00000000");  -- for tests
  port (
    RESET                  : in    std_logic; -- external reset PIN L8 from testpoint, used internal power-up reset
    MCLK                   : in    std_logic_vector (6 downto 0); -- @200MHZ from clock buffer
    MCLK_N                 : in    std_logic_vector (6 downto 0);
    ACLK_MASTER            : in    std_logic; -- AclkP/N in connector -> buffer
    ACLK_MASTER_N          : in    std_logic;
    -- PLL_CLKOUT             : out   std_logic; -- clock loopback to DDR3 I/O bank
    -- PLL_CLKOUT_N           : out   std_logic;
    -- DDR3_SYS_CLK           : in    std_logic; -- 04/11/2019 from loopback
    -- DDR3_SYS_CLK_N         : in    std_logic; -- 04/11/2019 from loopback

    -- Module - Control & Data
    -- Main Connector (Bank 16, MCLK(1)):
    Sync_P     : in    std_logic; -- 13/10/2021 seems SyncP/N in connector -> CTL(0)
    Sync_N     : in    std_logic;
    Reg_in_P        : in    std_logic;
    Reg_in_N      : in    std_logic;
    Reg_out_P       : out   std_logic;
    Reg_out_N     : out   std_logic;
    DATA_OUT         : out   std_logic_vector (1 downto 0);
    DATA_OUT_N       : out   std_logic_vector (1 downto 0);
    Sig_2        : in   std_logic;
    Buffer_P              : in    std_logic;
    Buffer_N            : in    std_logic;
    Diag_out_P                : out    std_logic;
    Diag_out_N              : out    std_logic;
    Diag_in_P         : in   std_logic;
    Diag_in_N       : in   std_logic;
    -- AUX Connector (Bank 13, MCLK(6)):
    Aux_Sync_P : out   std_logic;
    Aux_Sync_N : out   std_logic;
    Aux_Reg_out_P    : out    std_logic;
    Aux_Reg_out_N  : out    std_logic;
    Aux_Reg_in_P   : in   std_logic;
    Aux_Reg_in_N : in   std_logic;
    AUX_DATA_IN      : in    std_logic_vector (1 downto 0);
    AUX_DATA_IN_N    : in    std_logic_vector (1 downto 0);
    Aux_Sig_2      : out    std_logic;
    Aux_Buffer_P            : out    std_logic;
    Aux_Buffer_N          : out    std_logic;
    Aux_Diag_in_P       : in    std_logic;
    Aux_Diag_in_N     : in    std_logic;
    Aux_Diag_out_P              : out    std_logic;
    Aux_Diag_out_N            : out    std_logic;
    -- pins in list, but not connected on board:
    -- removed from list:
    -- Splitter_RCOM2TMCOR    : in    std_logic;

    -- tiles interface
    RESETn                 : out   std_logic_vector (3 downto 0);  -- DI_PD
    ACLK                   : out   std_logic_vector (3 downto 0);  -- DI
    SYNC                   : out   std_logic_vector (3 downto 0);  -- DI
    D_START                : out   std_logic_vector (3 downto 0);  -- DI add 03/11/2019
    DISCARD                : out   std_logic_vector (3 downto 0);  -- DI
    -- TILES_CLK              : out   std_logic_vector (3 downto 0);                      -- DI_LVDS  -- !debug: 13/10/2021 removed clock buffer, was TILES_CLK_A(i),
    -- TILES_CLK_N            : out   std_logic_vector (3 downto 0);                      -- DI_LVDS
    TILES_CLK              : out   std_logic;                     -- 05/12/2021
    TILES_CLK_N            : out   std_logic;                     -- 05/12/2021
    SCLK                   : out   std_logic_vector (3 downto 0);  -- DI
    SCS1                   : out   std_logic_vector (3 downto 0);  -- DI
    SCS2                   : out   std_logic_vector (3 downto 0);  -- DI
    SDI                    : out   std_logic_vector (3 downto 0);  -- DI_PD
    SDO                    : in    std_logic_vector (3 downto 0);  -- DO_T
    ACO                    : in    std_logic_vector (3 downto 0);  -- DO_LVDS
    ACO_N                  : in    std_logic_vector (3 downto 0);  -- DO_LVDS
    DATA1                  : in    std_logic_vector (3 downto 0);  -- DO_LVDS
    DATA1_N                : in    std_logic_vector (3 downto 0);  -- DO_LVDS
    DATA2                  : in    std_logic_vector (3 downto 0);  -- DO_LVDS
    DATA2_N                : in    std_logic_vector (3 downto 0);  -- DO_LVDS

    -- Misc I/O
    DISABLE_CLK0n          : out   std_logic;
    DISABLE_CLK1n          : out   std_logic;
    -- DISABLE_DVDD1n         : out   std_logic; -- ? EN_1_5V
    DISABLE_SLAVEn         : out   std_logic; -- V
    DISABLE_APOSn          : out   std_logic; -- V tile power enable EN_P1_5V
    DISABLE_ANEGn          : out   std_logic; -- V tile power enable
    -- DISABLE_DVDD2n         : out   std_logic; -- ? tile power enable
    -- JTAG_MASTER_SLAVEn     : out   std_logic; -- control Configuration Source
    HW_REV                 : in    std_logic_vector (3 downto 0);
    SCL                    : inout std_logic_vector (1 downto 0); -- Temeprature Sensor and NVRAM
    SDA                    : inout std_logic_vector (1 downto 0); -- Temeprature Sensor and NVRAM
    PGOOD_0_75V              : in std_logic; -- 0.75v Good indication, VTT_PGOOD
    PGOOD_1_0V             : in std_logic;
    PGOOD_1_5V             : in std_logic;
    PGOOD_1_8V             : in std_logic;
    PGOOD_P1_5V            : in std_logic; -- analog voltage
    PGOOD_2_5V             : in std_logic; -- analog voltage
    STATUS_LEDS            : out   std_logic_vector(1 downto 0); -- [1] - red, [0] - green
    HEATER_1               : out   std_logic; -- 02/11/2021
    HEATER_2               : out   std_logic; -- 02/11/2021
    SO_FLASH               : in  std_logic;   -- 01/02/2023
    SI_FLASH               : out std_logic;   -- 01/02/2023
    CS_FLASH               : out std_logic;   -- 01/02/2023
    DEBUG_TP               : out   std_logic_vector(7 downto 0);

    -- DDR3
    ddr3_dq                : inout std_logic_vector(7 downto 0);
    ddr3_dqs_p             : inout std_logic_vector(0 downto 0);
    ddr3_dqs_n             : inout std_logic_vector(0 downto 0);
    ddr3_addr              : out   std_logic_vector(15 downto 0);
    ddr3_ba                : out   std_logic_vector(2 downto 0);
    ddr3_ras_n             : out   std_logic;
    ddr3_cas_n             : out   std_logic;
    ddr3_we_n              : out   std_logic;
    ddr3_reset_n           : out   std_logic;
    ddr3_ck_p              : out   std_logic_vector(0 downto 0);
    ddr3_ck_n              : out   std_logic_vector(0 downto 0);
    ddr3_cke               : out   std_logic_vector(0 downto 0);
    ddr3_cs_n              : out   std_logic_vector(0 downto 0);
    ddr3_dm                : out   std_logic_vector(0 downto 0);
    ddr3_odt               : out   std_logic_vector(0 downto 0)
    );
end Taichi_TMB_top_short;


architecture Behavioral of Taichi_TMB_top_short is

  signal rx_clk160             : std_logic;
  signal sys_clk                 : std_logic;
  signal CLK200                : std_logic;
  -- signal CLK80                 : std_logic;
  signal rx_clk20              : std_logic;
  signal CLK200A               : std_logic;
  signal CLK200_ref            : std_logic;

  -- 06/11/2022 was dummy_tile_for_pins, now io_tiles
  component io_tiles is
    generic (
      GEN_OUT_CLK : boolean);
    port (
      fast_clk    : in  std_logic;
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
      TILES_CLK   : out std_logic;
      TILES_CLK_N : out std_logic;
      RESETn      : out std_logic;
      ACLK        : out std_logic;
      SYNC        : out std_logic;
      D_START     : out std_logic;  -- add 03/11/2019
      DISCARD     : out std_logic;
      SCLK        : out std_logic;
      SCS1n       : out std_logic;
      SCS2n       : out std_logic;
      SDI         : out std_logic;
      SDO         : in  std_logic;
      ACO         : in  std_logic;
      ACO_N       : in  std_logic;
      DATA1       : in  std_logic;
      DATA1_N     : in  std_logic;
      DATA2       : in  std_logic;
      DATA2_N     : in  std_logic);
  end component io_tiles;

  type BOOL_ARRAY is array (integer range <>) of boolean;
  -- constant GEN_OUT_CLK : BOOL_ARRAY(0 to 3) := TRUE & FALSE & FALSE & FALSE;
  constant GEN_OUT_CLK : BOOL_ARRAY(0 to 3) := TRUE & TRUE & TRUE & TRUE; -- !debug: 13/10/2021 no external clock buffer
  signal TILES_CLK_A, TILES_CLK_A_N : std_logic_vector(3 downto 0);

  signal HeadBcast_i, ReadReq_i, mod_1_serial_in_i, mod_1_serial_aux_i, p2p_tmcor2rcom_s_i : std_logic;
  signal HeadBcast_r, ReadReq_r : std_logic;
  signal debug2_sig, debug3_sig : std_logic;


  signal enable_slave : std_logic;      -- 10/11/2019
  signal ctl_0 : std_logic;

  signal Reg_out_i, Reg_in_i, Diag_out_i,Diag_in_i, Sync_s_i : std_logic; --@Dalit 18/7/2023
  signal footer_send :std_logic; --add by Dalit 16/10/2023
  -- signal Reg_in_sig, Diag_in_sig, Aux_Diag_out_sig : std_logic_vector(7 downto 0);
  -- signal in_delay_reset : STD_LOGIC;
  -- signal in_delay_data_ce : STD_LOGIC_VECTOR ( 0 to 0 );
  -- signal in_delay_data_inc : STD_LOGIC_VECTOR ( 0 to 0 );
  -- signal in_delay_tap_in   : STD_LOGIC_VECTOR (4 downto 0); -- when VAR_LOAD
  -- signal in_delay_tap_out  : STD_LOGIC_VECTOR (4 downto 0); -- when VAR_LOAD

  -- !debug: 22/12/2021 only for IDELAY_TYPE("VARIABLE"): in_delay_reset, in_delay_data_ce, in_delay_data_inc

  -- signal clk_div : std_logic := '0';
  -- signal byte_rx_cnt : natural range 0 to 3 := 0;
  signal dbg_flag1 : boolean;

  signal CLK200_at, CLK80_at : std_logic_vector(6 downto 3);
  signal CLK200_at_sig, CLK80_at_sig : std_logic_vector(6 downto 3);

  signal clk200_aux, clk200_aux_buf : std_logic; -- 16/03/2022

  component io_inst is
    port (
      reset          : in  std_logic;
      MCLK           : in  std_logic_vector (6 downto 0);
      MCLK_N         : in  std_logic_vector (6 downto 0);
      ACLK_MASTER    : in  std_logic;
      ACLK_MASTER_N  : in  std_logic;
      AUX_DATA_IN    : in  std_logic_vector (1 downto 0);
      AUX_DATA_IN_N  : in  std_logic_vector (1 downto 0);
      Aux_Buffer_P   : out std_logic;
      Aux_Buffer_N   : out std_logic;
      Aux_Diag_in_P  : in  std_logic;
      Aux_Diag_in_N  : in  std_logic;
      Aux_Diag_out_P : out std_logic;
      Aux_Diag_out_N : out std_logic;
      Aux_Reg_out_P  : out std_logic;
      Aux_Reg_out_N  : out std_logic;
      Aux_Reg_in_P   : in  std_logic;
      Aux_Reg_in_N   : in  std_logic;
      Sync_P         : in  std_logic;
      Sync_N         : in  std_logic;
      Reg_in_P       : in  std_logic;
      Reg_in_N       : in  std_logic;
      Reg_out_i       : in  std_logic;    -- 08/12/2022
      Reg_out_P      : out std_logic;
      Reg_out_N      : out std_logic;
      Buffer_P       : in  std_logic;
      Buffer_N       : in  std_logic;
      Diag_out_i     : in  std_logic;  --@dalit 18/7/2023
      Diag_out_P     : out std_logic;
      Diag_out_N     : out std_logic;
      Diag_in_P      : in  std_logic;
      Diag_in_N      : in  std_logic;
      Diag_in_i      : out std_logic;  --@dalit 18/7/2023
      Aux_Sync_P     : out std_logic;
      Aux_Sync_N     : out std_logic;
      DATA_OUT       : out std_logic_vector (1 downto 0);
      DATA_OUT_N     : out std_logic_vector (1 downto 0);
      aclk_master_i  : out std_logic;
      -- DDR3_SYS_CLK   : in  std_logic;
      -- DDR3_SYS_CLK_N : in  std_logic;
      Aux_buffer_byte   : in  std_logic_vector(7 downto 0);  -- 07/11/2022
      Aux_diag_out_byte : in  std_logic_vector(7 downto 0);
      Aux_Sync_byte     : in  std_logic_vector(7 downto 0);
      Aux_Reg_out_byte  : in  std_logic_vector(7 downto 0);
      Reg_in_i     : out std_logic;       -- 08/12/2022
      Sync_i     : out std_logic;       -- 13/12/2022
      -- Buffer_byte       : out std_logic_vector(7 downto 0);
      RX_ERRs_buffer : out std_logic_vector(3 downto 0);
      buf_ptr_address_from_buffer : out std_logic_vector(31 downto 0); -- 21/09/2023
      stream_ctrl_from_buffer : out std_logic_vector(7 downto 0);     -- 21/09/2023
      buffer_req_valid  : out std_logic;      -- 14/12/2022
      Module_TX_RX_channel_RDY : in std_logic; -- 30/01/2023
      Aux_diag_in_byte  : out std_logic_vector(7 downto 0);
      Aux_reg_in_byte   : out std_logic_vector(7 downto 0);
      CLK160         : out std_logic;
      CLK20          : out std_logic;
      CLK200_ref     : out std_logic;
      CLK50_o        : out std_logic;
      CLK200_o       : out std_logic;
      clk_locked     : out std_logic;
      CLK200A        : out std_logic;
      ACLK           : out std_logic_vector (3 downto 0);
      ddr3_sys_clk_p : out std_logic;
      ddr3_sys_clk_n : out std_logic;
      -- PLL_CLKOUT     : out std_logic;
      -- PLL_CLKOUT_N   : out std_logic;
      channel_RDY    : out std_logic;
      clk_div        : in  std_logic;
      TX_DATA_out    : in  std_logic;
      debug2_sig     : in  std_logic;
      debug3_sig     : in  std_logic;
      ACLK_and_TILES_CLK_EN : in std_logic;                               -- 24/04/2023
      io_inst_tp     : out std_logic_vector(1 downto 0)
    );
  end component io_inst;

  signal io_inst_tp     : std_logic_vector(1 downto 0);
  signal aclk_master_i : std_logic;     -- , aclk_master_r, aclk_master_r0
  signal aclk_shr_50m  : std_logic_vector(2 downto 0);

  signal Aux_buffer_byte   : std_logic_vector(7 downto 0);
  signal Aux_diag_out_byte : std_logic_vector(7 downto 0);
  signal Aux_Sync_byte     : std_logic_vector(7 downto 0);
  signal Aux_Reg_out_byte  : std_logic_vector(7 downto 0);
  -- signal Buffer_byte       : std_logic_vector(7 downto 0);
  signal buf_ptr_address_from_buffer : std_logic_vector(31 downto 0);
  signal stream_ctrl_from_buffer : std_logic_vector(7 downto 0);
  signal Aux_diag_in_byte  : std_logic_vector(7 downto 0);
  signal Aux_reg_in_byte   : std_logic_vector(7 downto 0);
  signal buffer_req, buffer_req_valid, buffer_req_valid_r, buffer_req_valid_sampled : std_logic := '0'; -- buffer_req_valid_200m,

  -- 06/11/2022
  component Tiles_managment is
    -- generic (
    --   IS_MASTER_ASIC : boolean := FALSE);
    port (
      RESET_N            : in  std_logic;
      nRST_20m           : in  std_logic;
      clk20_c2           : in  std_logic;
      clk160_c0          : in  std_logic;
      clk64_c3           : in  std_logic;
      -- clk_200            : in  std_logic;
      ACLK_Master        : in  std_logic;
      IP                 : in  std_logic;
      TMC_exists         : in  std_logic;
      -- idelayctrl_rdy_i   : in  std_logic;
      -- idelayctrl_rdy_o   : out std_logic;
      locked_fast        : in  std_logic;
      DiscardIP          : in  std_logic;
      Bias               : in  std_logic;
      rx_in              : in  std_logic_vector (2*NumOfTiles-1 downto 0);
      REGS_req           : in  std_logic_vector (39 downto 0);
      CNT_lines          : in  std_logic_vector (15 downto 8);
      wrreq              : in  std_logic_vector (1 downto 0);
      RAM_wraddress      : in  std_logic_vector (7 downto 0);
      Calib              : in  std_logic_vector(2 downto 0);
      calib_ctl_reg      : in  std_logic_vector(15 downto 0);
      diag_reg           : in std_logic_vector(15 downto 0);
      take_qp2_reg       : in std_logic;
      exit_from_asic_reset : in std_logic;
      start_align_reg    : in std_logic_vector(7 downto 0); -- [0] - align
                                                            -- enable, [2] - disable_rx_sync_window
      test_status_reg    : out std_logic_vector(11 downto 0);
      overhead_bits      : out std_logic_vector(63 downto 0);
      SPI_ERRs           : out	std_logic_vector(3*2*NumOfTiles-1 downto 0); -- 26/05/2024 width changes
      AMS_CrcOk_o        : out  std_logic_vector(2*NumOfTiles-1 downto 0); -- 26/05/2024 width changes
      AMS_CrcError_o     : out  std_logic_vector(2*NumOfTiles-1 downto 0); -- 26/05/2024 width changes
      AMS_CrcError_counter_o : out  std_logic_vector(4*2*NumOfTiles-1 downto 0); -- 26/05/2024 width changes
      Tile_power_monitor_footer : out std_logic_vector((2*NumOfTiles*12)-1 downto 0); -- 26/05/2024 width changes
      Asic_mode_Calibrated_or_Raw : out std_logic_vector(2*NumOfTiles-1 downto 0); -- 26/05/2024 width changes
      asic_data_good_read: out  std_logic_vector(2*NumOfTiles-1 downto 0); -- 26/05/2024 width changes
      tiles_crc_clear_reg : in  std_logic;
      ms_spi_sel         : in  std_logic;
      SDO                : in  std_logic_vector(NumOfTiles-1 downto 0);
      IP20_o             : out std_logic;
      IP50_o             : out std_logic;
      READ_OUT_ready_o   : out std_logic_vector(2*NumOfTiles-1 downto 0);
      SYNC               : out std_logic_vector(NumOfTiles-1 downto 0);
      ACLK               : out std_logic_vector(NumOfTiles-1 downto 0);
      SCS1n              : out std_logic_vector(NumOfTiles-1 downto 0);
      SCS2n              : out std_logic_vector(NumOfTiles-1 downto 0);
      SDI                : out std_logic_vector(NumOfTiles-1 downto 0);
      SCLK               : out std_logic_vector(NumOfTiles-1 downto 0);
      Tiles_rst          : out std_logic_vector(NumOfTiles-1 downto 0);
      Discard            : out std_logic_vector(NumOfTiles-1 downto 0);
      Tile_data_locked_o : out std_logic_vector(2*NumOfTiles-1 downto 0);
      AMS_Time           : out std_logic_vector((2*NumOfTiles*16)-1 downto 0);
      temp_sensor        : out std_logic_vector((2*NumOfTiles*16)-1 downto 0);
      RX_det_o           : out std_logic_vector(2*(NumOfTiles*26)-1 downto 0);
      data_valid_o       : out std_logic_vector(2*NumOfTiles-1 downto 0);
      DATA2R_o           : out std_logic_vector(2*NumOfTiles*15-1 downto 0);
      DPOS_PGOOD        : in std_logic;
      ACLK_and_TILES_CLK_EN : out std_logic;
      Power_en          : out std_logic_vector (2 downto 0); -- Analog power enable
      calib_completed_o : out std_logic_vector((2*NumOfTiles*4)-1 downto 0);
      Tiles_managment_tp : out   std_logic_vector (7 downto 0));
  end component Tiles_managment;

  signal overhead_bits : std_logic_vector(63 downto 0);
  signal SPI_ERRs : std_logic_vector(2*3*NumOfTiles-1  downto 0); --add by Dalit 10/10/2023

  signal ACLK_and_TILES_CLK_EN : std_logic;                               -- 24/04/2023
  signal take_qp2_reg   : std_logic;

  signal idelayctrl_rdy : std_logic;

  signal Power_en : std_logic_vector (2 downto 0); -- 22/12/2022 Analog power enable (DISABLE_DVDDn & DISABLE_ANEGn & DISABLE_APOSn)
  signal SYNC_io, SYNC_i      : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) 6,4,2,0
  -- signal ACLK_i      : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) 6,4,2,0
  signal SCS1n_i, SCS2n_i, SCS2n_i_mux : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) SCS2[3] SCS1[3] SCS2[2] SCS1[2] SCS2[1] SCS1[1] SCS2[0] SCS1[0]
  signal SDI_io, SDI_i       : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) 6,4,2,0
  signal SCLK_io, SCLK_i      : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) 6,4,2,0
  -- signal SDO_i       : std_logic_vector(NumOfTiles-1 downto 0);  -- (I) 6,4,2,0
  signal Tiles_rst_io, Tiles_rst_i : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) 6,4,2,0
  signal Discard_i   : std_logic_vector(NumOfTiles-1 downto 0);  -- (O) 6,4,2,0
  signal asic1_data, asic2_data   : std_logic_vector(NumOfTiles-1 downto 0);

  signal rst_n0, rst_n, ddr3_rst_n, memory_buffer_rst_n : std_logic;
  signal rst200m_n : std_logic := '0';
  signal rst200m_vec : std_logic_vector(7 downto 0);
  signal long_reset_cnt : natural range 0 to 63;
  signal clk_locked : std_logic;
  signal IP : std_logic := '0';
  signal IP20, IP50, IP50_r : std_logic;
  -- signal dummy_ip_cnt : natural range 0 to 2**17-1 := 0;
  -- signal dummy_aclk_cnt : natural range 0 to 511 := 0;

  signal vio_reading_number_buffer_tmp_sel : std_logic_vector(7 downto 0); -- vio_rq_cmds
  signal diag_reg, vio_diag_reg : std_logic_vector(15 downto 0);
  signal mu_ctl_reg, vio_mu_ctl : std_logic; -- [0] - '1' MU enable
  signal take_rx_det_msb_reg : std_logic; -- ctl2_addr [2] - when no MU calc in case raw data mode take coarse counter
  signal rx_det_shl_reg : std_logic; -- ctl2_addr [0] - '1' (default) if no MU use rx_det[16..1], '0' use rx_det[15..0]
  signal ctl2_reg : std_logic_vector(7 downto 0);
  signal pipeline_ctl_reg, vio_pipeline_ctl, pipeline_ctl_70 : std_logic_vector(31 downto 0);
  signal AMS_Time            : std_logic_vector((2*NumOfTiles*16)-1 downto 0);
  signal AMS_Offset, vio_ams_offset : std_logic_vector(15 downto 0);
  signal ibias, vio_ibias    : std_logic_vector(4 downto 0);
  signal global_ip_time_reg, vio_global_ip_time : std_logic_vector(15 downto 0);
  signal gain, vio_CREG_Crst, CREG_Crst      : std_logic_vector(3 downto 0);
  signal diag_temp_reg       : std_logic_vector(7 downto 0);
  signal start_align_reg, vio_ctl1 : std_logic_vector(7 downto 0) := (others => '0');   -- 12/10/2022
  signal ms_spi_sel       : std_logic := '1';  -- select SPI master/slave
  signal calib_ctl_reg, vio_calib_ctl : std_logic_vector(15 downto 0);  -- [15] - execute calibration

  signal RX_det_m            : std_logic_vector((NumOfTiles*26)-1 downto 0);
  signal data_valid_m        : std_logic_vector(NumOfTiles-1 downto 0);
  signal RX_det_s            : std_logic_vector((NumOfTiles*26)-1 downto 0);
  signal data_valid_s        : std_logic_vector(NumOfTiles-1 downto 0);
  signal fq_data_valid       : std_logic;
  signal fq_data_in          : std_logic_vector(31 downto 0); -- !debug: 26/07/2023 was 15
  signal sorter_data_ready, sorter_data_ready_r   : std_logic;                    -- 26/11/2023

  signal calib_completed : std_logic_vector(2*(NumOfTiles*4)-1 downto 0); -- for 2x ASIC's
                                                                          -- nibble: Offset voltage & Offset current & '0' & Linearity

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
          mu_ctl_reg          : in std_logic;
          take_rx_det_msb_reg : in std_logic;
          rx_det_shl_reg      : in std_logic;
          pipeline_ctl_reg    : in STD_LOGIC_VECTOR(31 downto 0);
          AMS_Time            : in std_logic_vector((NumOfTiles*16)-1 downto 0);
          AMS_Offset          : in std_logic_vector(15 downto 0);
          ibias               : in std_logic_vector(4 downto 0);
          global_ip_time_reg  : in std_logic_vector(15 downto 0);
          gain                : in STD_LOGIC_VECTOR(3 downto 0);
          Num_of_Slices       : in std_logic_vector(6 downto 0);		-- 30/10/2022
          asic_data_good_read : in std_logic_vector(NumOfTiles-1 downto 0); -- 04/09/2023
          RX_det_m            : in std_logic_vector((NumOfTiles*26)-1 downto 0);
          data_valid_m        : in std_logic_vector(NumOfTiles-1 downto 0);
          RX_det_s            : in std_logic_vector((NumOfTiles*26)-1 downto 0);
          data_valid_s        : in std_logic_vector(NumOfTiles-1 downto 0);
          sorter_data_ready   : out std_logic;                    -- 26/11/2023
          dpr_header_updated  : in std_logic;                     -- 26/11/2023
          fq_data_valid       : out std_logic;                           -- 30/10/2022
          fq_data_in          : out std_logic_vector(31 downto 0) -- !debug: 26/07/2023 was 15
          );
  end component slices_sorter;


  component memory_buffer_if_tmp is
    generic (
      WORD_WIDTH : natural);
    port (
    sys_clk            : in  std_logic;  -- system clock @50MHz
    rst_n              : in  std_logic;
    IP50               : in  std_logic;
    Num_of_Slices      : in std_logic_vector(6 downto 0);		-- 30/10/2022
    slice_merge        : in  std_logic;                         -- 11/09/2023
    mu_ctl_reg         : in std_logic;                          -- 15/11/2023
    rx_det_shl_reg     : in std_logic;                          -- 15/11/2023
    dummy_data_sel     : in  std_logic;                      -- 15/11/2023
    test_ctl           : in std_logic_vector(7 DOWNTO 0);       -- 25/01/2024
    slice_merging_factor  : in std_logic_vector(1 DOWNTO 0); -- 11/10/2023
    fs_merging_factor  : in std_logic_vector(1 DOWNTO 0); -- 17/12/2023
    fs_sequence_counter: in std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
    fs_merge_stop      : in std_logic;                    -- 30/03/2024
    sorter_data_ready  : in std_logic;                    -- 04/04/2024
    rlt_address_from_sync : in std_logic_vector(31 DOWNTO 0); -- 08/10/2023
    make_data_from_sync : in std_logic; -- 05/05/2024
    stream_enable      : in std_logic_vector(1 downto 0);     -- 22/10/2023
    fq_data_valid      : in  std_logic;  -- 30/10/2022
    fq_data_in         : in  std_logic_vector(31 downto 0);
    tmb_header_valid   : in std_logic;
    tmb_header         : in std_logic_vector (15 downto 0);
    params_ready       : out std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
    tmb_header_dout32  : out std_logic_vector (WORD_WIDTH-1 downto 0);
    tmb_header_rd      : in std_logic;
    ev_header_dout32   : out std_logic_vector (WORD_WIDTH-1 downto 0); -- !debug: 20/09/2022
    ev_header_rd       : in std_logic;
    num_of_slices_no_merge : out std_logic_vector(6 downto 0);
    num_of_slices_after_merge : out std_logic_vector(6 downto 0);
    DATA_SORTER_DATA_EN: out std_logic;
    DATA_SORT_DOUT     : out std_logic_vector (WORD_WIDTH-1 downto 0);
    EVOLVING_DATA_EN   : out std_logic;
    EVOLVING_DOUT      : out std_logic_vector (WORD_WIDTH-1 downto 0)
    );
  end component memory_buffer_if_tmp;

  signal slice_merge        : std_logic := '1';             -- !TODO: 20/09/2023 connect
  -- signal merge_factor       : std_logic_vector(4 downto 0) := 5UX"2";

  -- signal mem_buf_fifo_rdata : std_logic_vector(31 downto 0);    -- !debug: 03/08/2023  was 15
  -- signal mem_buf_fifo_empty : std_logic;
  -- signal mem_buf_fifo_rd    : std_logic;
  -- signal mem_buf_reading_ready : std_logic := '0';

  signal dummy_header_cnt : natural range 0 to 128; -- 128bytes = 64words header
  signal tmb_header_data, dummy_header_data : std_logic_vector(15 downto 0); -- !debug: 19/01/2023 was 7
  signal tmb_header_valid, dummy_header_valid, dpr_header_valid, dpr_header_valid_r : std_logic; -- , sync_header_valid
  signal dpr_header_valid_shr : std_logic_vector(2 downto 0);
  -- signal sync_header_valid_cnt : natural range 0 to 127;
  signal num_of_slices_after_merge, num_of_slices_no_merge : std_logic_vector(6 downto 0);

  component taichi_slice_builder is
    generic (
      WORD_WIDTH : natural := 16;
      LONG_TMB_FOOTER : boolean := TRUE;
      MULTIBOOT_GOLDEN : boolean := FALSE
      );
    port (reset_n                 : in  std_logic;
          nRST_20m                : in  std_logic;
          sys_clk                 : in  std_logic;
          comm_clk                : in  std_logic;
          dummy_data_sel          : in  std_logic;
          diag_reg                : in  std_logic_vector(7 downto 0);
          diag_temp_reg           : in  std_logic_vector(7 downto 0);
          buffer_req              : in  std_logic;
          Num_of_Slices           : in std_logic_vector(6 downto 0);		-- 30/10/2022
          rd_reading_ready        : in  std_logic;
          new_packet2tx           : in std_logic; -- 28/05/2024
          rx_det                  : in  std_logic_vector(WORD_WIDTH-1 downto 0);
          rx_fifo_empty           : in  std_logic;
          rx_fifo_rd              : out std_logic;
          rx_fifo_valid           : in  std_logic; -- 29/05/2024
          reading_type            : in  std_logic;
          footer_bits             : in  std_logic_vector(64*8-1 downto 0); -- !debug: 02/05/2023
          IP20                    : in  std_logic;
          TX_STATn_DYN            : out std_logic;
          TX_GO                   : out std_logic;
          TX_IP                   : out std_logic;
          TX_PayloadSize          : out std_logic_vector (31 downto 0);
          TX_DATA_IN              : out std_logic_vector (7 downto 0);
          TX_RD_EMPTY             : out std_logic;
          TX_RD_REQ               : in  std_logic;
          rq_cmds_sampled         : in std_logic_vector(1 downto 0);
          Footer_send             : out std_logic; --add by Dalit 1/11/2023
          taichi_slice_builder_tp : out std_logic_vector (7 downto 0));
  end component taichi_slice_builder;

  signal footer_bits_dummy, footer_bits : std_logic_vector(64*8-1 downto 0); -- !debug: 02/05/2023 was (16*8-1 downto 0),  16bytes -> 16DW
  -- signal footer_dw1, footer_dw2, footer_dw3, footer_dw4, footer_dw5, footer_dw6 : std_logic_vector (31 downto 0);
  type FOOTER_ARR_TYP is array (1 to 16) of std_logic_vector (31 downto 0);
  signal footer_dw : FOOTER_ARR_TYP;
  signal diag_sel4footer, footer_dw7_src, footer_dw8_src : std_logic_vector (31 downto 0);

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
      DATA_out    : out std_logic;
      TX_ERRs     : out	std_logic_vector (1 downto 0) --TX_ERR(0) '1'  if empty when RD_REQ  ,RX_ERR(1) '1' if fifo not empty after packet transaction
      );
  end component TX_series7;

  signal test_cnt2_sig : natural range 0 to 2**24 - 1 := 2**24 - 1;
  signal test_cnt3_sig : natural range 0 to 15 := 15;


  component vio_0
    port (
      clk         : in  std_logic;
      probe_out0  : out std_logic_vector(15 downto 0);
      probe_out1  : out std_logic_vector(0 downto 0);
      probe_out2  : out std_logic_vector(7 downto 0);
      probe_out3  : out std_logic_vector(0 downto 0);
      probe_out4  : out std_logic_vector(31 downto 0);
      probe_out5  : out std_logic_vector(15 downto 0);
      probe_out6  : out std_logic_vector(3 downto 0);
      probe_out7  : out std_logic_vector(4 downto 0);
      probe_out8  : out std_logic_vector(15 downto 0);
      probe_out9  : out std_logic_vector(7 downto 0);
      probe_out10 : out std_logic_vector(7 downto 0);
      probe_out11 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      probe_out12 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      probe_out13 : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
      probe_out14 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
      );
  end component;

  signal ip_i : std_logic := '0';       -- , aclk_i_r0, aclk_i_r1

  constant G_DATA_LENGTH : integer := 32;

  --added by tzvika sweetkin 26/07/2023
  signal nvram_addr_reg_sig         : std_logic_vector(G_DATA_LENGTH-1 downto 0);
  signal nvram_data_reg_sig         : std_logic_vector(G_DATA_LENGTH-1 downto 0);
  signal nvram_readdata_reg_sig     : std_logic_vector(G_DATA_LENGTH-1 downto 0);
  signal nvram_status_reg_sig       : std_logic_vector(G_DATA_LENGTH-1 downto 0);

  signal tile_packet_ok_timeout     : std_logic_vector(G_DATA_LENGTH-1 DOWNTO 0);

  --added by tzvika sweetkin 26/07/2023
  component nvram_top is
      generic(
        G_IIC_CLKS_NUM : integer := 500; -- 100K with 50MHz clk
        G_TOUT : std_logic_vector(20 - 1 downto 0):= x"3D090" -- 5msec with 50MHz clk
    );
    port(
        CLK                 : in std_logic;
        RESET               : in std_logic;
        ------------------------------------
        REG1_ADDR          : in std_logic_vector(32 - 1 downto 0);
        REG2_WRITEDATA_OP  : in std_logic_vector(32 - 1 downto 0);
        REG3_READDATA      : out std_logic_vector(32 - 1 downto 0);
        REG4_STATUS        : out std_logic_vector(32 - 1 downto 0);
        ------------------------------------
        NVRAM_SDA           : inout std_logic;
        NVRAM_SCL           : inout std_logic;
        NVRAM_WP            : out std_logic
        ------------------------------------
--        NVRAM_BUSY          : out std_logic;
--        NVRAM_WR_FIFO_FULL  : out std_logic;
--        NVRAM_WR_FIFO_EMPTY : out std_logic;
--        NVRAM_WR_DONE       : out std_logic;
--        NVRAM_RD_DONE       : out std_logic
    );
    end component;


  component Module_TX_RX_diag_A is      ---- @dalit update 18/7/2023
    generic (
      DATA_ZISE     : INTEGER;
      G_DATA_LENGTH : INTEGER);
    port (
      S_clk_200MHz : IN  STD_LOGIC;
      S_clk_50MHz : IN  STD_LOGIC;
      S_locked : IN  STD_LOGIC;
      -- CLKp_200MHz              : IN  STD_LOGIC;
      -- CLKn_200MHz              : IN  STD_LOGIC;
      RST                      : IN  STD_LOGIC;
      channel_RDY              : IN  STD_LOGIC;
      RX_IN                    : IN  STD_LOGIC;
      TX_OUT                   : OUT STD_LOGIC;
      STATUS                   : IN  std_logic_vector (15 downto 0);
      --   DIAGNSOTICS_TMP          : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 0x77
      BAD_PIX_HL               : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_LL               : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      CONTROL_REGISTER_LSB                                 : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
  --    CONTROL_REGISTER_MSB                                 : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
      FIFO_RESET                                           : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
      CONFIGURATION_STATUS                                 : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
      WR_TO_CONFIGURATION_STATUS                           : in  std_logic_vector (G_DATA_LENGTH-1 downto 0);
      CONFIGURATION_FIFO_RD_CNT                            : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
      WR_TO_CONFIGURATION_FIFO_RD_CNT                      : in  std_logic_vector (G_DATA_LENGTH-1 downto 0);
      REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER          : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
      CONFIG_WR_EN                                         : out std_logic;
      REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER       : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
      WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER : in  std_logic_vector (G_DATA_LENGTH-1 downto 0);
      WR_TO_NVRAM_STATUS                                     :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  --    TEST                                                 : out std_logic_vector (G_DATA_LENGTH-1 downto 0);
  --    WR_TO_TEST                                           : in  std_logic_vector (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_PER_TILE         : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      NOT_VALID_ADDR_OUT       : OUT STD_LOGIC; -- 10/01/2023
      BAD_PACKET_RECEIVED      : OUT STD_LOGIC;
      -- CRC_ERROR                : OUT STD_LOGIC;
      -- STD_ERROR                : OUT STD_LOGIC;
    --  RX_ERRs                 : OUT	std_logic_vector (3 downto 0);    --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error delete by dalit 10/10/2023
    -- 21/03/2023
    Tile1_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile2_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile3_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile4_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Module_Inlet_Temperature                                :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Module_Outlet_Temperature                               :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Module_Average_Temperature                              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    diag_7_8_sel_reg                                        :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 06/06/2024
    Asics_Aligned_4B0                                       :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 06/06/2024
    kP_reg                                                  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    kI_reg                                                  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    kD_reg                                                  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    kAW_reg                                                 :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Heater_Control                                          :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    SetPoint                                                :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Temperature_Weighted_Average_CFG                        :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    PID_Stable_Tolerance                                    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Temperature_Sample_and_rates                            :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Integral_and_Derivative_rates                           :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Status_and_Errors                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    PWM_Duty_Cycle_IN			                            :IN std_logic_vector (7 DOWNTO 0);
    temporary_reg2                                          :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    timestamp                                               :In STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    fw_ver                                                  :In STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    board_ver                                               :In STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Num_of_Slices                                           :In STD_LOGIC_VECTOR(6 downto 0);
    Module_Status_Errors_reg                                :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 04/12/2023
    NVRAM_ADDR_REG                                          :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NVRAM_DATA_REG                                          :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NVRAM_READ_DATA_REG                                     :in STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NVRAM_STATUS_REG                                        :in STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    tile_packet_ok_timeout                                  :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    --added by Dalit 12/10/2023
    Diag_RX_ERRs                 : OUT	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
    Operational_RX_ERRs          : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
    Operational_TX_ERRs          : IN	std_logic_vector (1 downto 0);    -- add by Dalit 10/10/2023
    IP_HEADER_RX_ERRs            : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
    Buffer_Control_RX_ERRs       : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
    Data_TX_ERRs                 : IN	std_logic_vector (1 downto 0);    -- add by Dalit 10/10/2023
    AMS_CRC_ERRs_Counter         : IN  std_logic_vector(2*4*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
    AMS_CrcError                 : IN  std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
    AMS_CrcOk                    : IN  std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
    Tile_data_align_o            : IN std_logic_vector(2*NumOfTiles-1 downto 0); ---add by Dalit 19/9/2023
    SPI_Errs                     : IN std_logic_vector(3*2*NumOfTiles-1 downto 0); ---add by Dalit 19/9/2023
    HD_Buffer_Overrun            : IN std_logic; -- add by Dalit 10/10/2023
    RTL_Buffer_Overrun           : IN std_logic; -- add by Dalit 10/10/2023
    PGOOD_0_75V                  : IN std_logic; --add by Dalit 12/10/2023-- 0.75v Good indication, VTT_PGOOD
    PGOOD_1_0V                   : IN std_logic; --add by Dalit 12/10/2023
    PGOOD_1_5V                   : IN std_logic; --add by Dalit 12/10/2023
    PGOOD_1_8V                   : IN std_logic; --add by Dalit 12/10/2023
    PGOOD_P1_5V                  : IN std_logic; --add by Dalit 12/10/2023-- analog voltage
    PGOOD_2_5V                   : IN std_logic; --add by Dalit 12/10/2023-- analog voltage
    Tile_power_monitor_footer    : IN std_logic_vector(2*(NumOfTiles*12)-1 downto 0); --add by Dalit 12/10/2023
    Operational_DIAGNSOTICS      : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); --add by Dalit 12/10/2023
    IP_too_short                 : IN std_logic; --add by Dalit 12/10/2023
    IP_too_long                  : IN std_logic; --add by Dalit 12/10/2023
    ddr_driver_errors            : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 06/06/2024
    MU_CTRL                     : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); --add by Dalit 18/10/2023
    MODULE_DATA_OUT_SELCTION     : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);  --add by Dalit 18/10/2023
    Remote_Programing_SM_Bits    : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --add by Dalit 18/10/2023
    Asic_mode_Calibrated_or_Raw : IN std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 18/10/2023
    footer_send					 : IN std_logic; --add by Dalit 15/10/2023
    OverRun_RTL_reset_flag       : OUT std_logic;  --add by Dalit 17/12/2023
    OverRun_HD_reset_flag        : OUT std_logic  --add by Dalit 17/12/2023
      );
  end component Module_TX_RX_diag_A;


   component Module_TX_RX_Operational_B is      ---- @dalit update 18/7/2023
    generic (
      DATA_ZISE     : INTEGER;
      G_DATA_LENGTH : INTEGER);
    port (
      S_clk_200MHz : IN  STD_LOGIC;
      S_clk_50MHz : IN  STD_LOGIC;
      S_locked : IN  STD_LOGIC;
      -- CLKp_200MHz              : IN  STD_LOGIC;
      -- CLKn_200MHz              : IN  STD_LOGIC;
      RST                      : IN  STD_LOGIC;
      channel_RDY              : IN  STD_LOGIC;
      RX_IN                    : IN  STD_LOGIC;
      TX_OUT                   : OUT STD_LOGIC;
      STATUS                   : IN  std_logic_vector (15 downto 0);
      MU_CTRL                  : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ADD_CONST_OFST_TO_MU     : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      CONST_OFST_VAL_TO_MU     : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ASIC_TST_CAL_CTRL_TEST   : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      TEST_ERROR               : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      WR_TO_TEST_ERROR         : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 10/01/2023
      DIAGNSOTICS              : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      GLOBL_IP_COEF            : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  --    DIAGNSOTICS_TMP          : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ASIC_DATA_ALIGNMENT      : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      MODULE_DATA_OUT_SELCTION : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      NOT_VALID_ADDR_OUT       : OUT STD_LOGIC; -- 10/01/2023
      BAD_PACKET_RECEIVED      : OUT STD_LOGIC;
      -- CRC_ERROR                : OUT STD_LOGIC;
      -- STD_ERROR                : OUT STD_LOGIC;
      RX_ERRs             : OUT	std_logic_vector (3 downto 0);  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      TX_ERRs                   : OUT	std_logic_vector (1 downto 0); ---add by Dalit 10/10/2023
      ams_asics_reset          : OUT STD_LOGIC;
      Power_en_mask            : OUT STD_LOGIC_VECTOR(1 downto 0);
      asic_rdwr_exe            : OUT STD_LOGIC;
      asic_rdwr_ops            : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      AMS_DATA2R               : in std_logic_vector (15 downto 0);
      asics_read_sel           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
  end component Module_TX_RX_Operational_B;

  signal MU_CTRL                  : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal ADD_CONST_OFST_TO_MU     : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal CONST_OFST_VAL_TO_MU     : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal ASIC_TST_CAL_CTRL_TEST   : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal TEST_ERROR               : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal DIAGNSOTICS              : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal GLOBL_IP_COEF            : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal DIAGNSOTICS_TMP          : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal ASIC_DATA_ALIGNMENT      : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal MODULE_DATA_OUT_SELCTION : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal BAD_PIX_HL               : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal BAD_PIX_LL               : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal BAD_PIX_PER_TILE         : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal BAD_REG_PACKET_RECEIVED, BAD_IP_PACKET_RECEIVED : STD_LOGIC;
  -- signal REG_CRC_ERROR, IP_CRC_ERROR : STD_LOGIC;
  -- signal REG_STD_ERROR, IP_STD_ERROR : STD_LOGIC;
  signal RX_ERRs_diag_A, RX_ERRs_Operational_B, RX_ERRs_SYNC, RX_ERRs_buffer : std_logic_vector (3 downto 0);  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
  signal TX_ERRs_diag_A, TX_ERRs_Operational_B, TX_ERRs_SYNC  , TX_ERRs_DATA : std_logic_vector (1 downto 0); --add by Dalit 10/10/2023
  signal Asic_mode_Calibrated_or_Raw : std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 18/10/2023
  signal FIFO_RESET : std_logic_vector (G_DATA_LENGTH-1 downto 0);
  signal CONTROL_REGISTER_LSB        : std_logic_vector (G_DATA_LENGTH-1 downto 0);
  signal CONTROL_REGISTER_MSB        : std_logic_vector (G_DATA_LENGTH-1 downto 0);

  signal Tile1_Temperature           : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Tile2_Temperature           : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Tile3_Temperature           : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Tile4_Temperature           : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Module_Inlet_Temperature    : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Module_Outlet_Temperature   : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Module_Average_Temperature  : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal kP_reg                      : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal kI_reg                      : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal kD_reg                      : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal kAW_reg                     : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Heater_Control              : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- [9..8] - 0 - OFF, 1	- Manual (Heater Setting at bits[7..0]), 2 - Auto
  signal SetPoint                    : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Temperature_Weighted_Average_CFG  : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal PID_Stable_Tolerance              : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Temperature_Sample_and_rates      : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Integral_and_Derivative_rates     : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal Status_and_Errors                 : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal ams_asics_reset                   : STD_LOGIC;
  signal Power_en_mask                     : STD_LOGIC_VECTOR(1 downto 0);
  signal asic_rdwr_exe                     : STD_LOGIC;
  signal asic_rdwr_ops                     : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal asics_read_sel_enc : STD_LOGIC_VECTOR (7 DOWNTO 0);
  signal asics_read_sel_dec : STD_LOGIC_VECTOR (8 DOWNTO 0);

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
      NumFooterBytes      : INTEGER     -- 12/10/2023 added
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
      -- crc_error           : OUT std_logic;
      -- std_error           : OUT std_logic
      RX_ERRs             : OUT	std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      );
  end component IP_DATAVAL_HEADER_TOP;

  signal rlt_address_from_sync    : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal hd_ptr_address_from_sync : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal slice_merging_factor, slice_merging_factor_synced2header : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00"; -- !debug: 15/01/2024 temporary const zero
  signal fs_merging_factor, fs_merging_factor_synced2header : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal fs_sequence_counter, fs_sequence_counter_synced2header : std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
  signal make_data_from_sync : std_logic; -- 05/05/2024

  signal vio_ev_stream_enable, vio_fq_stream_enable, fq_stream_enable, fq_stream_enable_ui_clk, fq_stream_enable_synced2header : std_logic;
  signal stream_enable : std_logic_vector(1 downto 0);

  signal Module_TX_RX_channel_RDY : std_logic;


  signal IP_too_short        : STD_LOGIC; --add by Dalit 12/10/2026
  signal IP_too_long         : STD_LOGIC; --add by Dalit 12/10/2026
  signal IP_READY            : STD_LOGIC;
  signal IP_DATA_OUT         : STD_LOGIC_VECTOR(IP_DATA_OUT_VAL-1 DOWNTO 0);
  signal HEADER_DATA_OUT     : STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);
  signal header_dpr_addr, vio_header_dpr_addr, auto_header_dpr_addr : std_logic_vector(5 downto 0);

  signal ip_period_cnt, ip_period_saved : natural range 0 to 2**22 := 0;

  component RX_serial is
    generic (
      NumDataBits : natural := 32;
      cnt_clk_max : natural := 4
      );
    port(
      RESET           : in  std_logic;
      CLK             : in  std_logic;
      serial_in       : in  std_logic;
      valid_RX_VEC    : out std_logic_vector (NumDataBits-1 downto 0);
      packet_received : out std_logic;
      good_packet     : out std_logic;
      bad_packet      : out std_logic
      );
  end component;

  signal sig_2_data, sig_2_data_50m : std_logic_vector (31 downto 0); -- Sig_2 RX data
  signal sig_2_packet_received, sig_2_packet_received_50m, sig_2_good_packet, sig_2_bad_packet : std_logic;
  -- FW_VER: Main revision_Main or debug version nibble , Sub version_compilation number_Date (Format: XX_M/D, YY_ZZ_DDMMYY)
  --  fmt: XXDYYZZDDMMYY -> to register 0XXDYYZZ
  --  ex:  0100101180523 -> to register 00100101
  constant FW_VER_CONST : std_logic_vector(31 downto 0) := X"003D51" & incr_num(7 downto 0); -- X"00100104";

  signal fw_ver, board_ver, usr_access_timestamp, data_from_timestamp, date_in_bcd_sig : std_logic_vector(31 downto 0);
  signal sig_2_channel_RDY, sig_2_soft_reset, sig_2_soft_reset_50m : std_logic;
  signal sig_2_packet_received_pulse : std_logic_vector(7 downto 0); -- 200/50

  -- component Module_HTR_DRV_PWM is
  --   generic(
  --     sys_clk         : integer := 50_000_000;                           --system clock frequency in Hz --- (50MHZ)
  --     pwm_freq        : integer := 5;                                    --PWM switching frequency in Hz --- (5HZ)
  --     bits_resolution : integer := 8);                                   --bits of resolution setting the duty cycle
  --   port(
  --     clk           : in  std_logic;                                     --system clock
  --     reset_n       : in  std_logic;                                     --asynchronous reset                                  --latches in new duty cycle
  --     Duty_Cycle_In : in  std_logic_vector(bits_resolution-1 downto 0);  --duty cycle
  --     pwm_out       : out std_logic;                                     --pwm outputs
  --     pwm_n_out     : out std_logic);                                    --pwm inverse outputs
  -- end component;

  signal temp_Num_of_Slices, mem_buf_num_of_slices, temp_Num_of_Slices_synced2header : std_logic_vector(6 downto 0) := 7UX"10";
  signal Duty_Cycle_In : std_logic_vector(7 downto 0);  --duty cycle
  signal fs_merge_stop_pre, fs_merge_stop : std_logic := '0';

  -- Flash remote update
  component access_config_top is
    port(
      clk             : in  std_logic;
      config_ctl_reg  : in  std_logic_vector (31 downto 0);
      din             : in  std_logic_vector (63 downto 0);
      reset           : in  std_logic;
      reset_fifo      : in  std_logic;
      so              : in  std_logic;
      wr_en           : in  std_logic;
      CS              : out std_logic;
      SCK             : out std_logic;
      busy            : out std_logic;
      conf_status_reg : out std_logic_vector (15 downto 0);
      data_out        : out std_logic_vector (63 downto 0);
      rd_data_count   : out std_logic_vector(6 downto 0);
      si              : out std_logic
      );
  end component;

  signal config_data_in  : std_logic_vector (31 downto 0) := (others => '0');
  signal config_wr_en : std_logic := '0';
  signal config_wr_shr : std_logic_vector(2 downto 0);
  signal SCK             : std_logic;   --Liron Added for remote programming
  signal busy            : std_logic;
  signal config_data_out : std_logic_vector (63 downto 0); -- data_out
  signal rd_data_count   : std_logic_vector (6 downto 0);
  signal SCK_FLASH       : std_logic := '0';
  signal SM_Bits : std_logic_vector(1 downto 0); -- in TMCOR v.6: to data footer [3..2]

  signal config_ctl_reg : std_logic_vector(31 downto 0) := (others => '0');
  signal reset_fifo_reg : std_logic := '0';
  signal conf_status_reg : std_logic_vector(15 downto 0);
  signal conf_fifo_rd_cnt_reg : std_logic_vector(15 downto 0);

  signal led_stop_err : boolean := FALSE;
  signal reg_in_NE_B5, reg_in_EQ_B5, sync_bad_packet, sync_good_packet,
    do_led0_filter, do_led1_filter, do_led1_on : std_logic;
  signal led0_filter_cnt, led1_filter_cnt, led1_on_cnt : natural range 0 to 2**30;

  signal back2const_regs, ddr3_debug_ctl, tiles_crc_clear_reg, ip_valid_sampled : std_logic := '0'; -- , ip_exist
  signal vio_ctl2 : std_logic_vector(7 downto 0);
  signal vio_controls : std_logic_vector(3 downto 0);

  component TMP112_CTL is
    port (
      RESET                  : IN     std_logic;
      reset_64M              : IN     std_logic;
      clk                    : IN     std_logic;
      clk_64M                : IN     std_logic;
      Sda                    : INOUT  std_logic;
      Scl                    : INOUT  std_logic;
      data2read_out_Sensor_1 : Buffer std_logic_vector (15 DOWNTO 0);
      data2read_out_Sensor_2 : Buffer std_logic_vector (15 DOWNTO 0)
    );
  end component TMP112_CTL;

  signal data2read_out_Sensor_1 : std_logic_vector (15 DOWNTO 0);
  signal data2read_out_Sensor_2 : std_logic_vector (15 DOWNTO 0);

  component Temperature_Stabilization_TOP is
    generic (
      INPUT_CLK   : INTEGER;
      CLK_divider : INTEGER);
    port (
      Clock                   : IN  std_logic;
      nReset                  : IN  std_logic;
      Kd                      : IN  std_logic_vector (15 DOWNTO 0);
      Ki                      : IN  std_logic_vector (15 DOWNTO 0);
      Kp                      : IN  std_logic_vector (15 DOWNTO 0);
      Kaw                     : IN  std_logic_vector (15 DOWNTO 0);
      Sensor_In1              : IN  std_logic_vector (15 DOWNTO 0);
      Sensor_In2              : IN  std_logic_vector (15 DOWNTO 0);
      Sensor1_influence		  : IN  std_logic_vector(3 DOWNTO 0);
      SetPoint                : IN  std_logic_vector (15 DOWNTO 0);
      Calc_PID_reg            : IN  std_logic_vector (15 DOWNTO 0);
      Sample_reg              : IN  std_logic_vector (15 DOWNTO 0);
      Integrat_update_time    : IN  std_logic_vector (15 downto 0);
      HEATER_MODE             : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
      PID_REG_FOR_MANUAL_MODE : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      PID_Out                 : OUT std_logic_vector (7 DOWNTO 0);
      Sensors_Moving_SUM      : OUT std_logic_vector (15 DOWNTO 0);
      -- FAN_MODE                : OUT STD_LOGIC;
      -- NOT_STABLE              : OUT std_logic;
      STABLE                  : OUT std_logic;
	  STABLE_DURATION			: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
	  DMSTooCold				: OUT  std_logic;
	  DMSTooHot					: OUT  std_logic;
	  Cannot_Stabilize			: OUT  std_logic;
	  PWM_Duty_Cycle_IN			: OUT std_logic_vector (7 DOWNTO 0);
      PWM_OUT                 : OUT std_logic;
      PWM_N_OUT               : OUT std_logic);
  end component Temperature_Stabilization_TOP;

  signal PID_Out, PWM_Duty_Cycle_IN : std_logic_vector (7 DOWNTO 0);
  signal Sensors_Moving_SUM      : std_logic_vector (15 DOWNTO 0);

  signal STABLE, Cannot_Stabilize, DMSTooCold, DMSTooHot : std_logic;
  signal STABLE_DURATION : STD_LOGIC_VECTOR(31 DOWNTO 0);

  signal ddr3_sys_clk_p : std_logic;
  signal ddr3_sys_clk_n : std_logic;

  component tmb_reg2spictl is
    generic (
      WORD_WIDTH2 : integer);
    port (
      rst_n          : in  std_logic;
      sys_clk        : in  std_logic;
      AMS_packet     : in  std_logic_vector(31 downto 0);
      AMS_Wr         : in  std_logic;
      AMS_S2p_ready  : in std_logic;
      wrreq          : out std_logic_vector(1 downto 0);
      REGS_req       : out std_logic_vector (39 downto 0);
      ms_spi_sel     : in  std_logic;
      Asics_Read_Sel_dec : in  std_logic_vector(8 downto 0);
      READ_OUT_READY : in  std_logic_vector(2*NumOfTiles-1 downto 0);
      DATA2R         : in  std_logic_vector (2*NumOfTiles*WORD_WIDTH2-1 downto 0);
      AMS_DATA2R     : out std_logic_vector (15 downto 0)
    );
  end component tmb_reg2spictl;

  signal AMS_packet : std_logic_vector(31 downto 0); -- [15..0] - ASIC data, [31..16] - ASIC addr
  signal AMS_Wr, AMS_S2p_ready : std_logic;
  signal wrreq  : std_logic_vector (1 downto 0);
  signal REGS_req : std_logic_vector (39 downto 0);
  signal READ_OUT_READY : std_logic_vector(2*NumOfTiles-1 downto 0);
  signal Tile_data_locked : std_logic_vector(2*NumOfTiles-1 downto 0);
  signal AMS_CrcOk  : std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
  signal AMS_CRC_ERRs_Counter  : std_logic_vector(2*4*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
  signal AMS_CrcError : std_logic_vector(2*NumOfTiles-1 downto 0); --changed by Dalit 19/9/2023
  signal Tile_power_monitor_footer : std_logic_vector(2*(NumOfTiles*12)-1 downto 0); -- add by Dalit 12/10/2023
  signal asic_data_good_read: std_logic_vector(2*NumOfTiles-1 downto 0); -- 05/09/2023
  constant WORD_WIDTH2	: integer  := 15;
  signal DATA2R : std_logic_vector (2*NumOfTiles*WORD_WIDTH2-1 downto 0);
  signal AMS_DATA2R : std_logic_vector (15 downto 0);
  signal PGOOD_1_5V_vec : std_logic_vector (3 downto 0):="0000";

  signal exit_from_asic_reset : std_logic;
  --added by tzvika sweetkin 26/07/2023
  signal sda_sig : std_logic;
  signal scl_sig : std_logic;

  constant LONG_TMB_FOOTER : boolean := TRUE;
  constant TMB_NumFooterbytes : std_logic_vector (7 downto 0) := X"40"; --  X"40" when LONG_TMB_FOOTER else X"10"
  -- signal TMB_NumFooterbytes : std_logic_vector (7 downto 0) := X"10";

  signal temporary_reg2	: STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);

  constant MULTIBOOT_GOLDEN : boolean := FALSE;  -- FALSE, when update image, else golden image
  constant USE_DDR_DRIVER : boolean := FALSE;  -- if false, skip ddr_driver hierarchy


  component date_in_bcd is
    port (
      bin : in  std_logic_vector (31 downto 0);
      bcd : out std_logic_vector (31 downto 0));
  end component date_in_bcd;

  signal reading_number_freerun_cnt : std_logic_vector(15 downto 0) := (others => '0');
  signal test_100ms_cnt, test_timer : natural range 0 to 2**24;

  signal WR_TO_CONFIGURATION_STATUS : std_logic_vector(15 downto 0);


  -- -- ddr_driver top
  -- component ddr_driver is
  --   port (
  --     global_reset_n    : in  std_logic; -- DDR3_AXI_IF.aresetn to DDR3 IP
  --     reset_sys_clk     : in  std_logic;
  --     DDR3_SOFT_RESET_N : in  std_logic; -- local reset for DDR3 interface
  --     CLK_50Mhz         : in  std_logic;
  --     sys_clk_p         : in  std_logic;  -- 19/09/2022 DDR3 sys_clk
  --     sys_clk_n         : in  std_logic;  -- 19/09/2022 DDR3 sys_clk
  --     ui_clk_o          : out std_logic;
  --     ui_clk_sync_rst_o : out std_logic; -- (O) reset from DDR3 IP
  --
  --     IP50                : in std_logic; -- 22/10/2023
  --     DATA_SORTER_DATA_EN : in std_logic;
  --     DATA_SORT_DOUT      : in std_logic_vector (31 downto 0);
  --     EVOLVING_DATA_EN    : in std_logic;
  --     EVOLVING_DOUT       : in std_logic_vector (31 downto 0);
  --
  --     params_ready       : in std_logic_vector(1 downto 0);  -- 22/10/2023 FQ & EV
  --     tmb_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
  --     tmb_header_rd : out std_logic;
  --     ev_header : in std_logic_vector (31 downto 0); -- !debug: 20/09/2022
  --     ev_header_rd : out std_logic;
  --     raw_wr_ptr_addr : in DDR3_ADDR_BUS_TYP;  -- !debug: 16/07/2023 was wr_ptr_num (WR reading index)
  --     ev_wr_slot_addr : in DDR3_ADDR_BUS_TYP;
  --     num_of_slices_no_merge : in std_logic_vector (6 downto 0); -- 09/02/2023 was [7..0]
  --     num_of_slices_after_merge : in std_logic_vector(6 downto 0);
  --
  --     rq_cmds : in std_logic_vector (1 downto 0); -- [1] - HD, [0] - EV
  --     rq_rd_ptr : in std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0); -- absolute RD pointer
  --
  --     NO_ECC_CHK                  : in     std_logic;
  --     FPGA_ID                     : in     std_logic_vector (3 downto 0);
  --     UNIQ_ID                     : in     std_logic_vector (15 downto 0);
  --     ASSEMBLY_VERSION            : in     std_logic_vector(15 downto 0);
  --     INIT_DONE_A_O               : out    std_logic;
  --     READ_DATA_FSM_IDLE          : buffer std_logic;
  --     DDR_DRIVER_RD               : in     std_logic;
  --     DDR_DRIVER_DOUT             : out    std_logic_vector (31 downto 0);
  --     DDR_DRIVER_FIFO_EMPTY       : out    std_logic;
  --     DDR_DRIVER_RD_READY         : out    std_logic;
  --     DDR_DRIVER_HEADER_BUS       : out    std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
  --     DDR_DRIVER_HEADER_READY     : out    std_logic;
  --     MEM_BUF_NUM_OF_SLICES       : out std_logic_vector(6 downto 0); -- 21/04/2024
  --     ECC_ERROR                   : out    std_logic;
  --     RTL_buffer_free_size        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- 08/10/2023
  --     RTL_buffer_OverRun          : OUT STD_LOGIC;
  --     HD_buffer_free_size         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  --     HD_buffer_OverRun           : OUT STD_LOGIC;
  --     OverRun_RTL_reset_flag      : IN  STD_LOGIC;
  --     OverRun_HD_reset_flag       : IN  STD_LOGIC;
  --     diag_sel                    : in std_logic_vector(2 downto 0); -- 29/10/2023
  --     ddr3_dq                     : inout  std_logic_vector (7 downto 0);
  --     ddr3_dqs_n                  : inout  std_logic_vector (0 to 0);
  --     ddr3_dqs_p                  : inout  std_logic_vector (0 to 0);
  --     ddr3_addr                   : out    std_logic_vector (15 downto 0);
  --     ddr3_ba                     : out    std_logic_vector (2 downto 0);
  --     ddr3_ras_n                  : out    std_logic;
  --     ddr3_cas_n                  : out    std_logic;
  --     ddr3_we_n                   : out    std_logic;
  --     ddr3_reset_n                : out    std_logic;
  --     ddr3_ck_p                   : out    std_logic_vector (0 to 0);
  --     ddr3_ck_n                   : out    std_logic_vector (0 to 0);
  --     ddr3_cke                    : out    std_logic_vector (0 to 0);
  --     ddr3_cs_n                   : out    std_logic_vector (0 to 0);
  --     ddr3_dm                     : out    std_logic_vector (0 to 0);
  --     ddr3_odt                    : out    std_logic_vector (0 to 0);
  --     DDR_DRIVER_TESTPOINTS       : out    std_logic_vector (31 downto 0));
  -- end component ddr_driver;

  signal DDR_DRIVER_TESTPOINTS   : std_logic_vector (31 downto 0);
  signal diag_sel4la             : std_logic_vector(2 downto 0) := "000"; -- 29/10/2023
  -- signal DDR_DRIVER_HEADER_BUS   : std_logic_vector (32*HEADER_NUM_DWORDS - 1 downto 0);
  -- signal DDR_DRIVER_HEADER_READY : std_logic;
  signal ui_clk, ui_clk_sync_rst : std_logic;
  signal DATA_SORTER_DATA_EN     : std_logic;
  signal DATA_SORT_DOUT          : std_logic_vector (31 downto 0);  -- RAW data
  signal EVOLVING_DATA_EN        : std_logic;                       -- data strobe from EV control
  signal EVOLVING_DOUT           : std_logic_vector (31 downto 0);  -- EV data
  signal params_ready : std_logic_vector(1 downto 0);
  signal tmb_header_dout32, ev_header_dout32 : std_logic_vector (31 downto 0) := (0 => '1', others => '0');
  signal tmb_header_rd, ev_header_rd : std_logic;
  signal raw_wr_ptr_addr, raw_wr_ptr_0_addr, ev_wr_slot_addr, raw_wr_ptr_addr_prev : DDR3_ADDR_BUS_TYP;
  signal DDR_DRIVER_DOUT : std_logic_vector (31 downto 0);
  signal DDR_DRIVER_FIFO_EMPTY, DDR_DRIVER_RD_READY, DDR_DRIVER_RD, DDR_DRIVER_RD_VALID, NEW_PACKET2TX : std_logic := '0';
  signal rq_cmds : std_logic_vector (1 downto 0); -- [1] - HD, [0] - EV
  signal rq_cmds_sampled : std_logic_vector(1 downto 0) := "00"; -- [1] - HD, [0] - EV
  -- signal rq_rd_ptr : std_logic_vector (DDR3_ADDR_WIDTH-1 downto 0); -- absolute RD pointer
  signal RTL_buffer_free_size        : STD_LOGIC_VECTOR(31 DOWNTO 0); -- 08/10/2023
  signal RTL_buffer_OverRun          : STD_LOGIC;
  signal HD_buffer_free_size         : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal HD_buffer_OverRun           : STD_LOGIC;
  signal OverRun_RTL_reset_flag      : STD_LOGIC;
  signal OverRun_HD_reset_flag       : STD_LOGIC;
  signal dpr_header_updated : std_logic;

  signal Module_Status_Errors_reg : STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
  signal raw_wr_ptr_addr_buffer_out, rq_rd_ptr_buffer_out : std_logic_vector(DDR3_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal stream_enable_1_r, latch_test_buffer, raw_wr_ptr_addr_stopped : std_logic;
  signal raw_wr_ptr_addr_watch_cnt : natural range 0 to 3;

  signal timer_1_us_cnt : natural range 0 to 63 := 0;
  signal req2ddr3_out_cnt : natural range 0 to 255 := 0;

  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of IP_READY, IP_DATA_OUT, header_dpr_addr, HEADER_DATA_OUT : signal is "true";
  attribute DONT_TOUCH of MU_CTRL, ADD_CONST_OFST_TO_MU, CONST_OFST_VAL_TO_MU : signal is "true";
  attribute DONT_TOUCH of BAD_REG_PACKET_RECEIVED, ip_period_saved, test_100ms_cnt, test_timer : signal is "true";
  attribute DONT_TOUCH of sig_2_data_50m, sig_2_packet_received_50m, fs_merging_factor, slice_merging_factor, fq_stream_enable, RX_ERRs_SYNC, RX_ERRs_buffer : signal is "true";
  attribute DONT_TOUCH of temp_Num_of_Slices, AMS_Offset, SM_Bits, data2read_out_Sensor_1, data2read_out_Sensor_2 : signal is "true";
  attribute DONT_TOUCH of RX_det_m, data_valid_m, RX_det_s, data_valid_s,TX_GO,TX_DATA_IN,TX_RD_EMPTY,TX_RD_REQ, hd_ptr_address_from_sync, fq_stream_enable_ui_clk : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of IP_READY, IP_DATA_OUT, header_dpr_addr, HEADER_DATA_OUT : signal is "true";
  attribute mark_debug of MU_CTRL, ADD_CONST_OFST_TO_MU, CONST_OFST_VAL_TO_MU : signal is "true";
  attribute mark_debug of BAD_REG_PACKET_RECEIVED, ip_period_saved, test_100ms_cnt, test_timer : signal is "true";
  attribute mark_debug of sig_2_data_50m, sig_2_packet_received_50m, fs_merging_factor, slice_merging_factor, fq_stream_enable, RX_ERRs_SYNC, RX_ERRs_buffer : signal is "true";
  attribute mark_debug of temp_Num_of_Slices, AMS_Offset, SM_Bits, data2read_out_Sensor_1, data2read_out_Sensor_2 : signal is "true";
  attribute mark_debug of RX_det_m, data_valid_m, RX_det_s, data_valid_s,TX_GO,TX_DATA_IN,TX_RD_EMPTY,TX_RD_REQ : signal is "true";

  -- signal ip_timeout_cnt, buffer_timeout_cnt : natural range 0 to 25000 := 25000; -- 500 usec @200MHz
  -- signal ip_timeout_err, buffer_timeout_err : std_logic := '0';
  -- attribute DONT_TOUCH of ip_timeout_cnt, ip_timeout_err, buffer_timeout_cnt, buffer_timeout_err : signal is "true";
  -- attribute mark_debug of ip_timeout_cnt, ip_timeout_err, buffer_timeout_cnt, buffer_timeout_err : signal is "true";
    attribute DONT_TOUCH of raw_wr_ptr_addr_buffer_out, rq_rd_ptr_buffer_out, latch_test_buffer : signal is "true";
    attribute mark_debug of raw_wr_ptr_addr_buffer_out, rq_rd_ptr_buffer_out, latch_test_buffer : signal is "true";
  attribute DONT_TOUCH of req2ddr3_out_cnt : signal is "true";
  attribute mark_debug of req2ddr3_out_cnt : signal is "true";


begin

  tiles_if_g : for i in 0 to 3 generate

    SCS2n_i_mux(i) <= SCS1n_i(i) when (start_align_reg(3) = '1' and REGS_req(38) = '0') else SCS2n_i(i); -- !debug: 23/03/2023

    dummy_tile_for_pins_1 : io_tiles
      generic map (
        GEN_OUT_CLK => GEN_OUT_CLK(i))
      port map (
        fast_clk    => rx_clk160,
        ACLK_MASTER => '0',
        SYNC_i      => SYNC_i(i),
        SCS1n_i     => SCS1n_i(i),
        SCS2n_i     => SCS2n_i_mux(i), -- SCS2n_i(i),
        SDI_i       => SDI_i(i),
        SCLK_i      => SCLK_i(i),
        Tiles_rst_i => Tiles_rst_i(i),
        Discard_i   => Discard_i(i),
        asic1_data  => asic1_data(i),
        asic2_data  => asic2_data(i),
        TILES_CLK   => TILES_CLK_A(i),
        TILES_CLK_N => TILES_CLK_A_N(i),
        RESETn      => RESETn(i),
        ACLK        => open,
        SYNC        => SYNC(i),
        D_START     => D_START(i),      -- 03/11/2019
        DISCARD     => DISCARD(i),
        SCLK        => SCLK(i),
        SCS1n       => SCS1(i),
        SCS2n       => SCS2(i),
        SDI         => SDI(i),
        SDO         => SDO(i),
        ACO         => ACO(i),
        ACO_N       => ACO_N(i),
        DATA1       => DATA1(i),
        DATA1_N     => DATA1_N(i),
        DATA2       => DATA2(i),
        DATA2_N     => DATA2_N(i)
        );

  end generate tiles_if_g;


  TILES_CLK   <= TILES_CLK_A(0); -- !debug: 13/10/2021 removed clock buffer, now uses external clock buffer on board
  TILES_CLK_N <= TILES_CLK_A_N(0);



  debug2_sig <= HeadBcast_i and mod_1_serial_in_i and mod_1_serial_aux_i and p2p_tmcor2rcom_s_i and ReadReq_i;
  -- debug3_sig <= Splitter_RCOM2TMCOR;


  test_clk_pr: process (CLK200A) is
  begin  -- process test_clk_pr
    if (CLK200A'event and CLK200A = '1') then  -- rising clock edge

      HeadBcast_r <= HeadBcast_i and enable_slave;
      ReadReq_r <= ReadReq_i and enable_slave;

    end if;
  end process test_clk_pr;


  enable_slave <= '1';

  DISABLE_CLK0n  <= ACLK_and_TILES_CLK_EN; -- !debug: 24/04/2023 was  '1';
  DISABLE_CLK1n  <= ACLK_and_TILES_CLK_EN; -- !debug: 24/04/2023 was  '1';
  DISABLE_SLAVEn <= enable_slave;
  --DISABLE_APOSn  <= '1';
  --DISABLE_ANEGn  <= '1';
  -- JTAG_MASTER_SLAVEn <= '0';

  Aux_Sig_2 <= '0'; -- was Sig_2
 -------------------------------------------------------------------
  powerup_prc : process (sys_clk, rst_n) is
  begin  -- process misc_50m_pr
    if (rst_n = '0') then
      -- DISABLE_APOSn  <= '1';
      -- DISABLE_ANEGn  <= '0';
      PGOOD_1_5V_vec <= "0000";
    elsif (sys_clk'event and sys_clk = '1') then
      -- DISABLE_APOSn  <= '1';
      PGOOD_1_5V_vec <= PGOOD_1_5V_vec(2 downto 0)& PGOOD_P1_5V;  -- !debug: 16/04/2023 was PGOOD_1_5V;
      -- if (PGOOD_1_5V_vec(3) = '1') then
      --   DISABLE_ANEGn <= '1';
      -- else
      --   DISABLE_ANEGn <= '0';
      -- end if;

      DISABLE_APOSn <= Power_en(0) and Power_en_mask(0);
      DISABLE_ANEGn <= Power_en(1) and Power_en_mask(1);

    end if;
  end process;


-----------------------------------------------------------

  -- Module_HTR_DRV_PWM_inst : Module_HTR_DRV_PWM
  --   generic map (
  --     sys_clk         => 50_000_000,
  --     pwm_freq        => 5,
  --     bits_resolution => 8
  --     )
  --   port map (
  --     clk           => sys_clk,
  --     reset_n       => rst_n,
  --     Duty_Cycle_In => Duty_Cycle_In, -- !debug: 01/05/2023 was  ADD_CONST_OFST_TO_MU(7 downto 0)
  --     pwm_out       => HEATER_1,
  --     pwm_n_out     => open
  --     );

  -- Temperature_Stabilization_TOP_1: Temperature_Stabilization_TOP
  --   generic map (
  --     INPUT_CLK   => 50_000_000, --input clock speed from user logic in Hz ---(50MHZ)
  --     CLK_divider => 10          -- for determine the NUM_CLK_between_pulses, for example 50M/10 => pulse of one clk every 100ms
  --     )
  --   port map (
  --     Clock                   => sys_clk,
  --     nReset                  => rst_n,
  --     Kd                      => Kd_reg(15 downto 0), -- 0x528
  --     Ki                      => Ki_reg(15 downto 0), -- 0x524
  --     Kp                      => Kp_reg(15 downto 0), -- 0x520
  --     Kaw                     => Kaw_reg(15 downto 0), -- 0x52C
  --     Sensor_In1              => data2read_out_Sensor_1, -- outlet sensor (U20)
  --     Sensor_In2              => data2read_out_Sensor_2, -- inlet sensor (U19)
  --     Sensor1_influence       => Temperature_Weighted_Average_CFG(3 downto 0),   -- 15/05/2023 0x538[3..0]
  --     SetPoint                => SetPoint(15 downto 0), -- 0x534
  --     Calc_PID_reg            => Temperature_Sample_and_rates(31 downto 16), -- [MK]:0x544[31..16]
  --     Sample_reg              => Temperature_Sample_and_rates(15 downto 0), -- [MK]:0x544[15..0]
  --     Integrat_update_time    => Integral_and_Derivative_rates(15 downto 0), -- [MK]:0x548[15..0]
  --     -- !TODO: where connect   PID_Stable_Tolerance(15 downto 0),  -- [MK]:0x540[15..0]
  --     HEATER_MODE             => Heater_Control(9 downto 8),         -- [MK]: Heater Modes: Off/Auto/Manual setting in 0x530[9..8]
  --     PID_REG_FOR_MANUAL_MODE => Duty_Cycle_In,      -- when Heater_Control(9 downto 8) = "00", [MK]: 0x530[7..0]
  --     PID_Out                 => PID_Out,            -- PID drive PWM Duty_Cycle_In !TODO: 12/03/2023 connect to header
  --     Sensors_Moving_SUM      => Sensors_Moving_SUM, -- 0x518 - sensors average for N samples
  --     STABLE                  => STABLE,             -- status/errors [MK]:0x550[16]
  --     STABLE_DURATION         => STABLE_DURATION,    -- status/errors [MK]:0x550[15..0]
  --     DMSTooCold              => DMSTooCold,         -- status/errors [MK]:0x550[24]
  --     DMSTooHot               => DMSTooHot,          -- status/errors [MK]:0x550[25]
  --     Cannot_Stabilize        => Cannot_Stabilize,   -- status/errors [MK]:0x550[26]
  --     PWM_Duty_Cycle_IN       => PWM_Duty_Cycle_IN,  -- 0x554[7..0]
  --     PWM_OUT                 => HEATER_1, -- !debug: 10/05/2023 check, Module_HTR_DRV_PWM must be disconnected!!!
  --     PWM_N_OUT               => open
  --   );

  Module_Average_Temperature <= X"0000" & Sensors_Moving_SUM;
  Status_and_Errors <= (25 => DMSTooHot, 24 => DMSTooCold, 26 => Cannot_Stabilize, 16 => STABLE, 15 downto 0 => STABLE_DURATION(15 downto 0), others => '0');

  HEATER_2 <= '0'; -- NU
  -- DEBUG_TP <= (others => '0');
  -- DEBUG_TP <= (0 => aclk_master_i, 1 => IP_READY, others => '0'); -- aclk_master_i - X18.1, IP_READY - X18.2

  --added by tzvika sweetkin 26/07/2023
 -- DEBUG_TP <= SCS1n_i(3) & SCS2n_i_mux(3) & SCLK_i(3) & SDI_i(3) &
           --   aclk_shr_50m(2) & IP50 & Tiles_rst_i(1) & sig_2_soft_reset_50m;
	  DEBUG_TP <= SCS1n_i(3) & SCS2n_i_mux(3) & SCLK_i(3) & SDI_i(3) &
              aclk_shr_50m(2) & IP50 & sda_sig & scl_sig;


  misc_200m_pr : process (CLK200) is
  begin  -- process misc_200m_pr
    if (CLK200'EVENT and CLK200 = '1') then  -- rising clock edge

      if (sig_2_packet_received = '1' and sig_2_good_packet = '1') then
        sig_2_packet_received_pulse <= X"FF";
      else
        sig_2_packet_received_pulse <= sig_2_packet_received_pulse(6 downto 0) & '0';
      end if;

    end if;
  end process misc_200m_pr;


  io_inst_1: io_inst
    port map (
      reset          => "not"(rst200m_n),
      MCLK           => MCLK,
      MCLK_N         => MCLK_N,
      ACLK_MASTER    => ACLK_MASTER,
      ACLK_MASTER_N  => ACLK_MASTER_N,
      AUX_DATA_IN    => AUX_DATA_IN,
      AUX_DATA_IN_N  => AUX_DATA_IN_N,
      Aux_Buffer_P   => Aux_Buffer_P,
      Aux_Buffer_N   => Aux_Buffer_N,
      Aux_Diag_in_P  => Aux_Diag_in_P,
      Aux_Diag_in_N  => Aux_Diag_in_N,
      Aux_Diag_out_P => Aux_Diag_out_P,
      Aux_Diag_out_N => Aux_Diag_out_N,
      Aux_Reg_out_P  => Aux_Reg_out_P,
      Aux_Reg_out_N  => Aux_Reg_out_N,
      Aux_Reg_in_P   => Aux_Reg_in_P,
      Aux_Reg_in_N   => Aux_Reg_in_N,
      Sync_P         => Sync_P,
      Sync_N         => Sync_N,
      Reg_in_P       => Reg_in_P,
      Reg_in_N       => Reg_in_N,
      Reg_out_i      => Reg_out_i,
      Reg_out_P      => Reg_out_P,
      Reg_out_N      => Reg_out_N,
      Buffer_P       => Buffer_P,
      Buffer_N       => Buffer_N,
      Diag_out_i     => Diag_out_i, --@Dalit 18/7/2023
      Diag_out_P     => Diag_out_P,
      Diag_out_N     => Diag_out_N,
      Diag_in_P      => Diag_in_P,
      Diag_in_N      => Diag_in_N,
      Diag_in_i     => Diag_in_i, --@Dalit 18/7/2023
      Aux_Sync_P     => Aux_Sync_P,
      Aux_Sync_N     => Aux_Sync_N,
      DATA_OUT       => DATA_OUT,
      DATA_OUT_N     => DATA_OUT_N,
      aclk_master_i  => aclk_master_i,
      -- DDR3_SYS_CLK   => DDR3_SYS_CLK,
      -- DDR3_SYS_CLK_N => DDR3_SYS_CLK_N,
      Aux_buffer_byte   => (others => '0'), -- !TODO: 07/11/2022 temporary driver   Aux_buffer_byte,
      Aux_diag_out_byte => Aux_diag_in_byte, -- !TODO: 07/11/2022 temporary driver   Aux_diag_out_byte,
      Aux_Sync_byte     => (others => '0'), -- !TODO: 07/11/2022 temporary driver    Aux_Sync_byte,
      Aux_Reg_out_byte  => Aux_reg_in_byte, -- !TODO: 07/11/2022 temporary driver    Aux_Reg_out_byte,
      Reg_in_i          => Reg_in_i, -- 08/12/2022
      Sync_i            => Sync_s_i, -- 13/12/2022
      -- Buffer_byte       => Buffer_byte,
      RX_ERRs_buffer => RX_ERRs_buffer,
      buf_ptr_address_from_buffer => buf_ptr_address_from_buffer, -- 21/09/2023
      stream_ctrl_from_buffer => stream_ctrl_from_buffer, -- 21/09/2023
      buffer_req_valid     => buffer_req_valid, -- !debug: 18/01/2023 was IP_pckt_valid
      Module_TX_RX_channel_RDY => Module_TX_RX_channel_RDY, -- 30/01/2023
      Aux_diag_in_byte  => Aux_diag_in_byte,
      Aux_reg_in_byte   => Aux_reg_in_byte,
      CLK160         => rx_clk160,
      CLK20          => rx_clk20,       -- 06/11/2022
      CLK200_ref     => CLK200_ref,     -- 06/11/2022
      CLK50_o        => sys_clk,          -- 06/11/2022
      CLK200_o       => CLK200,
      clk_locked     => clk_locked,     -- 06/11/2022
      CLK200A        => CLK200A,
      ACLK           => ACLK,
      ddr3_sys_clk_p => ddr3_sys_clk_p,
      ddr3_sys_clk_n => ddr3_sys_clk_n,
      -- PLL_CLKOUT     => PLL_CLKOUT,
      -- PLL_CLKOUT_N   => PLL_CLKOUT_N,
      channel_RDY    => open, -- 28/12/2022 rise, when ~200 ACLK periods done
      clk_div        => sys_clk, -- !debug: 11/12/2022 clk_div,
      TX_DATA_out    => TX_DATA_out,     -- data to TMB
      debug2_sig     => debug2_sig,
      debug3_sig     => debug3_sig,
      ACLK_and_TILES_CLK_EN => ACLK_and_TILES_CLK_EN, -- 24/04/2023
      io_inst_tp     => io_inst_tp
      );


  -- -- AS5912 master+slave ASIC
  -- Tiles_managment_m : Tiles_managment
  --   -- generic map (
  --   --   IS_MASTER_ASIC => TRUE)
  --   port map (
  --     RESET_N               => rst_n,
  --     nRST_20m              => rst_n,
  --     clk20_c2              => rx_clk20,
  --     clk160_c0             => rx_clk160,
  --     clk64_c3              => sys_clk,
  --     -- clk_200               => CLK200_ref, -- 12/10/2022
  --     ACLK_Master => aclk_shr_50m(1), -- !debug: 20/03/2023  was aclk_master_i,
  --     -- Footer_optional_en    => '1',
  --     -- Bytes_per_det         => 5,
  --     IP                    => IP,
  --     TMC_exists            => '0',
  --     -- idelayctrl_rdy_i      => '0',
  --     -- idelayctrl_rdy_o      => idelayctrl_rdy, -- idelayctrl from ASIC1 RX
  --     locked_fast           => '1',
  --     DiscardIP             => '0',
  --     Bias                  => '0', -- !debug: from registers   Bias,
  --     rx_in                 => std_logic_vector'(asic2_data & asic1_data), -- serial data from AMS tile ASIC1 (master ASIC)
  --     REGS_req              => REGS_req, -- !debug: from registers   REGS_req,
  --     CNT_lines             => (8 => ams_asics_reset, others => '0'), -- !debug: from registers   CNT_lines,
  --     wrreq                 => wrreq, -- !debug: from registers  wrreq,
  --     RAM_wraddress         => (others => '0'), -- !debug: from registers   RAM_wraddress,
  --     -- IF_Command            => (3 => '1', others => '0'), -- !debug: from registers   IF_Command,
  --     Calib                 => (others => '0'), -- !debug: from registers   Calib,
  --     calib_ctl_reg         => calib_ctl_reg, -- register 0x73
  --     diag_reg              => diag_reg,
  --     take_qp2_reg          => take_qp2_reg,
  --     exit_from_asic_reset  => exit_from_asic_reset,
  --     start_align_reg       => start_align_reg,
  --     test_status_reg       => open,
  --     overhead_bits         => overhead_bits,
  --     SPI_ERRs              => SPI_Errs,
  --     AMS_CrcOk_o           => AMS_CrcOk,
  --     AMS_CrcError_o        => AMS_CrcError,
  --     AMS_CrcError_counter_o => AMS_Crc_Errs_counter,
  --     Tile_power_monitor_footer => Tile_power_monitor_footer,
  --     Asic_mode_Calibrated_or_Raw => Asic_mode_Calibrated_or_Raw,
  --     asic_data_good_read   => asic_data_good_read,
  --     tiles_crc_clear_reg   => tiles_crc_clear_reg,
  --     ms_spi_sel            => '1', -- !debug: 04/06/2024 was   ms_spi_sel
  --     SDO                   => SDO,  -- (others => '0'), -- !debug: no tiles interface  SDO_i,   -- tiles interface
  --     IP20_o                => IP20,
  --     IP50_o                => IP50,
  --     READ_OUT_ready_o      => READ_OUT_READY,
  --     SYNC                  => SYNC_io,  -- tiles interface
  --     ACLK                  => open, -- !debug: tiles interface, NU
  --     SCS1n                 => SCS1n_i,  -- tiles interface
  --     SCS2n                 => SCS2n_i,  -- tiles interface
  --     SDI                   => SDI_io,   -- tiles interface
  --     SCLK                  => SCLK_io,  -- tiles interface
  --     Tiles_rst             => Tiles_rst_io,  -- tiles interface
  --     Discard               => Discard_i,    -- tiles interface
  --     Tile_data_locked_o    => Tile_data_locked, -- 05/06/2024 check master only
  --     AMS_Time              => AMS_Time, -- 05/06/2024 check master only
  --     temp_sensor           => open,
  --     RX_det_o((NumOfTiles*26)-1 downto 0) => RX_det_m,
  --     RX_det_o((2*NumOfTiles*26)-1 downto NumOfTiles*26) => RX_det_s,
  --     data_valid_o(NumOfTiles-1 downto 0) => data_valid_m,
  --     data_valid_o(2*NumOfTiles-1 downto NumOfTiles) => data_valid_s,
  --     DATA2R_o              => DATA2R,
  --     DPOS_PGOOD            => PGOOD_1_5V_vec(3),
  --     ACLK_and_TILES_CLK_EN => ACLK_and_TILES_CLK_EN,
  --     Power_en              => Power_en,
  --     calib_completed_o     => calib_completed,
  --     Tiles_managment_tp    => open
  --   );

  -- -- !debug: 23/03/2023 broadcast to AMS
  -- SYNC_i <= SYNC_m when (ms_spi_sel = '1' or start_align_reg(3) = '1') else SYNC_s;
  -- SDI_i <= SDI_m when (ms_spi_sel = '1' or start_align_reg(3) = '1') else SDI_s;
  -- SCLK_i <= SCLK_m when (ms_spi_sel = '1' or start_align_reg(3) = '1') else SCLK_s;
  -- Tiles_rst_i <= Tiles_rst_m when (ms_spi_sel = '1' or start_align_reg(3) = '1') else Tiles_rst_s;
  -- !debug: 04/06/2024
  SYNC_i <= SYNC_io;
  SDI_i <= SDI_io;
  SCLK_i <= SCLK_io;
  Tiles_rst_i <= Tiles_rst_io;

  -- slices_sorter_1 : slices_sorter
  --   port map (
  --     clk20_c2            => rx_clk20,  -- RX byte clock
  --     sys_clk             => sys_clk,
  --     rst_n               => rst_n,
  --     NRST_20M            => rst_n,
  --     IP20                => IP20,
  --     IP50                => IP50,      -- 30/10/2022
  --     dummy_data_sel      => diag_reg(4),
  --     diag_reg            => diag_reg,
  --     num_of_tiles        => overhead_bits(63 downto 60), -- 31/08/2023
  --     reading_number_freerun_cnt => reading_number_freerun_cnt, -- 14/06/2023
  --     tile_packet_ok_timeout_reg => tile_packet_ok_timeout(7 downto 0), -- 04/09/2023
  --     mu_ctl_reg          => mu_ctl_reg,
  --     take_rx_det_msb_reg => take_rx_det_msb_reg,
  --     rx_det_shl_reg      => rx_det_shl_reg,
  --     pipeline_ctl_reg    => pipeline_ctl_reg,
  --     AMS_Time            => AMS_Time((NumOfTiles*16)-1 downto 0),
  --     AMS_Offset          => AMS_Offset,
  --     ibias               => ibias,
  --     global_ip_time_reg  => global_ip_time_reg,
  --     gain                => gain,
  --     RX_det_m            => RX_det_m,
  --     Num_of_Slices       => temp_Num_of_Slices_synced2header, -- from header, synced to sorter_data_ready
  --     asic_data_good_read => asic_data_good_read(NumOfTiles-1 downto 0),
  --     data_valid_m        => data_valid_m,
  --     RX_det_s            => RX_det_s,
  --     sorter_data_ready   => sorter_data_ready,
  --     dpr_header_updated  => dpr_header_updated, -- 26/11/2023
  --     data_valid_s        => data_valid_s,
  --     fq_data_valid       => fq_data_valid,
  --     fq_data_in          => fq_data_in
  --     );
  --
  --
  -- memory_buffer_if_1: memory_buffer_if_tmp
  --   generic map (
  --     WORD_WIDTH => 32)
  --   port map (
  --     sys_clk               => sys_clk,
  --     rst_n                 => memory_buffer_rst_n,
  --     IP50                  => IP50,
  --     num_of_slices         => temp_Num_of_Slices_synced2header,  -- from header, synced to fs_sequence_counter = 0 and to sorter_data_ready
  --     slice_merge           => slice_merge,
  --     mu_ctl_reg            => mu_ctl_reg,
  --     rx_det_shl_reg       => rx_det_shl_reg,
  --     dummy_data_sel       => diag_reg(4),
  --     test_ctl             => std_logic_vector'(vio_reading_number_buffer_tmp_sel(3 downto 0) & "000" & latch_test_buffer),
  --     fs_merging_factor    => fs_merging_factor_synced2header, -- 17/03/2024
  --     fs_sequence_counter  => fs_sequence_counter_synced2header, -- 17/03/2024
  --     fs_merge_stop        => fs_merge_stop,                 -- 30/03/2024
  --     sorter_data_ready    => sorter_data_ready,             -- 04/04/2024
  --     slice_merging_factor => slice_merging_factor_synced2header, -- 17/03/2024
  --     rlt_address_from_sync => rlt_address_from_sync,
  --     make_data_from_sync   => make_data_from_sync, -- 05/05/2024
  --     stream_enable         => stream_enable, -- !debug: 05/11/2023 for debug try "01"
  --     fq_data_valid         => fq_data_valid, -- from sorter
  --     fq_data_in            => fq_data_in, -- from sorter
  --     tmb_header_valid      => tmb_header_valid,   -- from scan header
  --     tmb_header            => tmb_header_data,   -- from scan header
  --     params_ready          => params_ready,
  --     tmb_header_dout32     => tmb_header_dout32,
  --     tmb_header_rd         => tmb_header_rd,
  --     ev_header_dout32      => ev_header_dout32,
  --     ev_header_rd          => ev_header_rd,
  --     num_of_slices_no_merge => num_of_slices_no_merge,
  --     num_of_slices_after_merge => num_of_slices_after_merge,
  --     DATA_SORTER_DATA_EN   => DATA_SORTER_DATA_EN,
  --     DATA_SORT_DOUT        => DATA_SORT_DOUT,
  --     EVOLVING_DATA_EN      => EVOLVING_DATA_EN,
  --     EVOLVING_DOUT         => EVOLVING_DOUT
  --     );


  -- 18/01/2023
  tmb_header_valid <= dummy_header_valid when (back2const_regs = '1') else dpr_header_valid_r;
  tmb_header_data <= dummy_header_data when (back2const_regs = '1') else HEADER_DATA_OUT;

  -- taichi_slice_builder_1 : taichi_slice_builder
  --   generic map (
  --     WORD_WIDTH => 32,    -- !debug: 03/08/2023  was 16
  --     LONG_TMB_FOOTER => TRUE,
  --     MULTIBOOT_GOLDEN => MULTIBOOT_GOLDEN
  --     )
  --   port map (
  --     reset_n                 => rst_n,
  --     nRST_20m                => rst_n,
  --     sys_clk                 => sys_clk,
  --     comm_clk                => sys_clk, -- now comm_clk = sys_clk
  --     dummy_data_sel          => diag_reg(0),
  --     diag_reg                => diag_reg(7 downto 0),
  --     diag_temp_reg           => diag_temp_reg,  -- delay after IP
  --     buffer_req              => buffer_req,     -- !debug: 19/01/2023
  --     Num_of_Slices           => mem_buf_num_of_slices, -- header word #1 from DDR3
  --     rd_reading_ready        => DDR_DRIVER_RD_READY, -- '1' when reading in fq_fifo
  --     new_packet2tx           => NEW_PACKET2TX,       -- 28/05/2024
  --     rx_det                  => DDR_DRIVER_DOUT,    -- MUX: fq_fifo[TMB data] or [TMB Header]
  --     rx_fifo_empty           => DDR_DRIVER_FIFO_EMPTY,    -- from fq_fifo
  --     rx_fifo_rd              => DDR_DRIVER_RD,       -- to fq_fifo
  --     rx_fifo_valid           => DDR_DRIVER_RD_VALID, -- 29/05/2024
  --     reading_type            => '1',              -- '0' - EV, '1' - FQ
  --     footer_bits             => footer_bits,
  --     IP20                    => IP50,
  --     TX_STATn_DYN            => TX_STATn_DYN,
  --     TX_GO                   => TX_GO,
  --     TX_IP                   => TX_IP,
  --     TX_PayloadSize          => TX_PayloadSize,
  --     TX_DATA_IN              => TX_DATA_IN,
  --     TX_RD_EMPTY             => TX_RD_EMPTY,
  --     TX_RD_REQ               => TX_RD_REQ,
  --     rq_cmds_sampled         => rq_cmds_sampled,
  --     Footer_send             => Footer_send, -- 12/11/2023
  --     taichi_slice_builder_tp => open
  --     );

  -- tx_footer_size_g: if (LONG_TMB_FOOTER) generate
  --   TMB_NumFooterbytes <= X"40";
  -- else generate
  --   TMB_NumFooterbytes <= X"10";
  -- end generate tx_footer_size_g;

  -- -- Data to CDM
  -- TX_series7_1 : TX_series7
  --   generic map (
  --     IDLE_WORD      => x"B5",
  --     StartWord      => x"21",
  --     Stream_type1   => x"43",
  --     Stream_type2   => x"DD",          -- dynamic packet
  --     NumHeaderbytes => x"84",         -- packet Header (4 bytes) + TMB Header = 0x4 + 0x80
  --     NumDatabytes   => x"00000001",   -- uses when static packet, 0x890 bytes for AS5911, 0x1090 bytes for AS5912
  --                                      -- !debug: 27/11/2022 NU for dynamic packet, X"00000000" - prohibited
  --                                      -- FQ, 16bytes TMB footer = 4+(128+2048+16)+0
  --     NumFooterbytes => TMB_NumFooterbytes  -- x"00" when no packet footer
  --     )
  --   port map (
  --     RESET       => "not"(rst_n),
  --     CLKDIV      => sys_clk, -- now comm_clk = sys_clk
  --     FCLK        => clk200,            -- bit clock, uses 200MHz and DDR (rate 400mbps)
  --     STATn_DYN   => TX_STATn_DYN,      -- '0' Static, '1' dynamic
  --     GO          => TX_GO,             -- ready, when enougth data in FIFO
  --     IP          => TX_IP,             -- '0' not IP packet
  --     PayloadSize => TX_PayloadSize,    -- from slice_builder
  --     DATA_IN     => TX_DATA_IN,        -- from slice_builder
  --     RD_EMPTY    => TX_RD_EMPTY,       -- from slice_builder
  --     RD_CLK      => open,              -- optional, use if RD_CLK /= CLKDIV
  --     RD_REQ      => TX_RD_REQ,         -- to slice_builder
  --     DATA_out    => TX_DATA_out,       -- serial data to OBUFDS
  --     TX_ERRs     => TX_ERRs_DATA    --add by Dalit 10/10/2023 --TX_ERR(0) '1'  if empty when RD_REQ  ,RX_ERR(1) '1' if fifo not empty after packet transaction
  --     );

  rst_pr : process(clk_locked,CLK200)
  begin
    if (clk_locked = '0') then
      sig_2_soft_reset <= '0';
      rst200m_vec <= (others => '0');
      rst200m_n <= '0';
    elsif (CLK200'EVENT and CLK200 = '1') then

      sig_2_soft_reset <= sig_2_soft_reset_50m;
      rst200m_vec <= rst200m_vec(rst200m_vec'HIGH-1 downto 0) & not sig_2_soft_reset; -- 20/04/2023
      rst200m_n <= rst200m_vec(rst200m_vec'HIGH);

    end if;
  end process rst_pr;

  rst_50m_pr : process(clk_locked,sys_clk)
  begin
    if (clk_locked = '0') then
      rst_n0 <= '0';
      rst_n <= '0';
      long_reset_cnt <= 63;
      ddr3_rst_n <= '0';
      memory_buffer_rst_n <= '0';
    elsif (sys_clk'EVENT and sys_clk = '1') then

      rst_n0 <= rst200m_n;
      rst_n <= rst_n0;
      memory_buffer_rst_n <= rst_n0;

      if (long_reset_cnt /= 0) then
        long_reset_cnt <= long_reset_cnt - 1;
        ddr3_rst_n <= '0';
        memory_buffer_rst_n <= '0';
      elsif (sig_2_soft_reset_50m = '1') then -- !debug: 18/10/2023
        long_reset_cnt <= 63;
      else
        ddr3_rst_n <= '1';
        memory_buffer_rst_n <= '1';
      end if;

    end if;
  end process rst_50m_pr;


  RX_serial_inst : RX_serial
    generic map (
      NumDataBits => 32,
      cnt_clk_max => 8 -- !debug: 11/01/2023 was 4 for 200/4=50MHz, now 8 for 200/8=25MHz
      )
    port map(
      RESET           => "not"(rst200m_n),
      CLK             => CLK200,
      serial_in       => Sig_2,         -- async serial in
      valid_RX_VEC    => sig_2_data,
      packet_received => sig_2_packet_received,
      good_packet     => sig_2_good_packet,
      bad_packet      => sig_2_bad_packet -- NU
      );

  sync_50m_pr : process (sys_clk) is
  begin  -- process sync_50m_pr
    if (sys_clk'EVENT and sys_clk = '1') then  -- rising clock edge

      if (test_cnt2_sig = 0) then
        test_cnt2_sig <= 2**24 - 1;
      else
        test_cnt2_sig <= test_cnt2_sig - 1;
      end if;

      -- if (diag_reg(2) = '0' and not led_stop_err) then
      --   if (test_cnt2_sig > 2**23) then
      --     STATUS_LEDS(0) <= '1';        -- !debug: 07/07/2022 normal - "01", golden image - "11"
      --     STATUS_LEDS(1) <= '0';
      --   else
      --     STATUS_LEDS(0) <= '0';        -- !debug: 07/07/2022 normal - "10", golden image - "00"
      --     STATUS_LEDS(1) <= '1';
      --   end if;
      -- else
      --   STATUS_LEDS(0) <= '1';
      --   STATUS_LEDS(1) <= '1';
      -- end if;
      --
      -- -- !debug: 26/12/2022 S_packet_received <- REG_STD_ERROR
      -- -- if (REG_STD_ERROR = '1') then
      -- --   STATUS_LEDS <= "10";
      -- --   test_cnt3_sig <= 10;
      -- -- elsif (test_cnt3_sig /= 0) then
      -- --   if (test_cnt2_sig = 0) then
      -- --     test_cnt3_sig <= test_cnt3_sig - 1;
      -- --   end if;
      -- -- else
      -- --   null;
      -- -- end if;
      -- if (REG_STD_ERROR = '1') then -- error
      --   STATUS_LEDS <= "10";
      --   led_stop_err <= TRUE;
      -- end if;

      -- 29/12/2022
      -- !debug: 05/10/2023 from Module_TX_RX_diag_A, Module_TX_RX_Operational_B, IP_DATAVAL_HEADER_TOP
      reg_in_NE_B5 <= RX_ERRs_Operational_B(1) or RX_ERRs_diag_A(1); -- Idle_WORD_BAD
                                                                     -- !TODO: 05/10/2023 add RX_ERRs_SYNC, RX_ERRs_buffer
      reg_in_EQ_B5 <= not reg_in_NE_B5; -- Idle_WORD_GOOD
      sync_bad_packet <= bad_ip_packet_received;
      sync_good_packet <= IP_READY;

      do_led0_filter <= reg_in_NE_B5 or sync_bad_packet;
      if (do_led0_filter = '1') then
        led0_filter_cnt <= 2**26;
      elsif (led0_filter_cnt /= 0) then
         led0_filter_cnt <= led0_filter_cnt - 1;
      end if;
      if (MULTIBOOT_GOLDEN) then
        if (test_cnt2_sig > 2**23) then
          STATUS_LEDS(0) <= '1';
          STATUS_LEDS(1) <= '1';
        else
          STATUS_LEDS(0) <= '0';
          STATUS_LEDS(1) <= '0';
        end if;
      elsif (diag_reg(2) = '1') then
        STATUS_LEDS(0) <= '0';
        STATUS_LEDS(1) <= '0';          -- D001054620 Rev B - active '1'
      elsif ((led1_on_cnt /= 0 and led1_filter_cnt = 0) and
             ((reg_in_EQ_B5 = '1' or sync_good_packet = '1') and led0_filter_cnt = 0)) then
          STATUS_LEDS(0) <= '1';        -- D001054620 Rev B - active '1'
          STATUS_LEDS(1) <= '0';
      else
        STATUS_LEDS(0) <= '0';
        STATUS_LEDS(1) <= '0';
      end if;

      -- io_inst_tp <= buffer_good_packet_received & buffer_bad_packet_received;
      do_led1_filter <= io_inst_tp(0); -- buffer_bad_packet_received
      if (do_led1_filter = '1') then
        led1_filter_cnt <= 2**26;
      elsif (led1_filter_cnt /= 0) then
         led1_filter_cnt <= led1_filter_cnt - 1;
      end if;
      do_led1_on <= io_inst_tp(1);
      if (do_led1_on = '1') then
        led1_on_cnt <= 30000;        -- !debug: 16/04/2023 was 2**29
      elsif (led1_on_cnt /= 0) then
         led1_on_cnt <= led1_on_cnt - 1;
      end if;

    end if;
  end process sync_50m_pr;


  misc_50m_pr: process (sys_clk, rst_n) is
    variable raw_wr_ptr_addr_buffer_tmp_v, rq_rd_ptr_buffer_tmp_v : std_logic_vector (16*DDR3_ADDR_WIDTH-1 downto 0) :=  (others => '0'); -- for test
    variable save_en_v : boolean := TRUE;             -- for test
  begin  -- process misc_50m_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      ip_period_cnt <= 0;
      ip_period_saved <= 0;
      sig_2_packet_received_50m <= '0';
      sig_2_data_50m <= (others => '0');
      sig_2_channel_RDY <= '0';
      sig_2_soft_reset_50m <= '0';
      aclk_shr_50m <= (others => '0');
      gain <= X"1";
      -- sync_header_valid <= '0';
      dpr_header_valid <= '0';
      -- temp_Num_of_Slices <= 7UX"10";
      exit_from_asic_reset <= '0';
      Asics_Read_Sel_dec <= (others => '0');
      Duty_Cycle_In <= (others => '0');
      auto_header_dpr_addr <= (others => '0');
      test_100ms_cnt <= 0;
      test_timer <= 0;
      -- mem_buf_num_of_slices <= (others => '0');
      -- ip_exist <= '0';
      dpr_header_updated <= '0';
      raw_wr_ptr_addr <= (others => '0');
      raw_wr_ptr_addr_prev <= (others => '0');
      ev_wr_slot_addr <= (others => '0');
      latch_test_buffer <= '0';
      raw_wr_ptr_addr_watch_cnt <= 3;
      raw_wr_ptr_addr_stopped <= '0';
      fs_merging_factor_synced2header <= (others => '0');
      fs_sequence_counter_synced2header <= (others => '0');
      slice_merging_factor_synced2header <= (others => '0');
      fq_stream_enable_synced2header <= '0';
      temp_Num_of_Slices_synced2header <= 7UX"10";
      fs_merge_stop <= '0';
      fs_merge_stop_pre <= '0';
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      if (IP_READY = '1') then
        ip_period_saved <= ip_period_cnt; -- measured IP period for test
        ip_period_cnt <= 0;
      elsif (ip_period_cnt < 2**22) then
        ip_period_cnt <= ip_period_cnt + 1;
      end if;

      --add by Dalit 1/11/2023-------------------
      if (ip_period_saved>0 and ip_period_saved <6000) then  --120usec -> clk 50M-> 20 ns  --changed by dalit 13/12/2023
            ip_too_short<='1';
      else
            ip_too_short<='0';
      end if;

      if (ip_period_saved > 3250000) then  --65msec -> clk 50M-> 20 ns --changed by dalit 13/12/2023
            ip_too_long<='1';
      else
            ip_too_long <='0';
      end if;
      -------------------------------------------

      sig_2_packet_received_50m <= sig_2_packet_received_pulse(7);
      sig_2_data_50m <= sig_2_data;
      if (sig_2_packet_received_50m = '1') then
        sig_2_channel_RDY <= sig_2_data_50m(0);
        if (sig_2_data_50m(7 downto 4) = X"C") then
          sig_2_soft_reset_50m <= '1';
        end if;
      end if;

      -- Gain value encoded in register, as in MOSASIC CREG
      -- -- CREG[15..12] - Crst
      if (unsigned(CREG_Crst) = X"F") then -- !debug: 23/12/2021
        gain <= X"1";
      elsif (unsigned(CREG_Crst) = X"7") then
        gain <= X"2";
      elsif (unsigned(CREG_Crst) = X"3") then
        gain <= X"4";
      elsif (unsigned(CREG_Crst) = X"1") then
        gain <= X"8";
      else
        gain <= X"1";
      end if;

      -- header processing
      aclk_shr_50m <= aclk_shr_50m(1 downto 0) & aclk_master_i;
      -- if (IP_READY = '1') then
      --   sync_header_valid_cnt <= 10;    -- timeout from IP packet to scan header ready
      --                                   -- note: now ~15us
      --   sync_header_valid <= '0';
      --   ip_exist <= '1';                -- 25/10/2023
      -- elsif (ip_exist = '1' and (aclk_shr_50m(2) = '0' and aclk_shr_50m(1) = '1')) then
      --   if (sync_header_valid_cnt /= 0) then
      --     sync_header_valid_cnt <= sync_header_valid_cnt - 1;
      --   else
      --     sync_header_valid <= '1';     -- scan header not in update process from SYNC channel
      --   end if;
      -- end if;

      if (IP_READY = '1') then
        auto_header_dpr_addr <= (others => '0');
        dpr_header_valid <= '0';
      elsif (sorter_data_ready = '1') then -- !debug: 26/11/2023 read header only when data received
                                                                               -- sync_header_valid -> sorter_data_ready
        auto_header_dpr_addr <= (0 => '1', others => '0');
        dpr_header_valid <= '1';
      elsif (unsigned(auto_header_dpr_addr) /= 0 and unsigned(auto_header_dpr_addr) < 63) then
        auto_header_dpr_addr <= std_logic_vector(unsigned(auto_header_dpr_addr) + 1);
        dpr_header_valid <= '1';
      else
        dpr_header_valid <= '0';
      end if;
      dpr_header_valid_shr <= dpr_header_valid_shr(1 downto 0) & dpr_header_valid;

      if (dpr_header_valid_shr(1) = '0' and dpr_header_valid_shr(2) = '1') then -- header updated
        dpr_header_updated <= '1';     -- constant after 1st valid header
      -- else
      --   dpr_header_updated <= '0';
      end if;

      -- -- parameters from scan header:
      -- if (dpr_header_valid_shr(1 downto 0) = "01") then -- W#1 of header
      --   if (HEADER_DATA_OUT(6 downto 0) /= 7UX"00") then
      --     temp_Num_of_Slices <= HEADER_DATA_OUT(6 downto 0);
      --   end if;
      -- end if;
      -- if (dpr_header_valid = '0' and dpr_header_valid_shr = "111") then -- W#63 of header
      --   if (HEADER_DATA_OUT(15) = '1') then
      --     reading_number_freerun_cnt <= '0' & unsigned(HEADER_DATA_OUT(14 downto 0)); -- load from header
      --   end if;
      -- elsif (IP_READY = '1') then
      --   reading_number_freerun_cnt <= reading_number_freerun_cnt + 1;
      -- end if;

      if (sig_2_packet_received_50m = '1') then
        exit_from_asic_reset <= '1';
      end if;

      -- Asics_Read_Sel_dec <= (others => '0'); --
      -- Asics_Read_Sel_dec(to_integer(unsigned(asics_read_sel_enc(2 downto 0)))) <= '1'; -- one hot[30..24] - ASIC in tile
      -- Asics_Read_Sel_dec(7) <= asics_read_sel_enc(7); -- [31] - master/slave ASIC

      ams_sel4rd_l: for i in 0 to 7 loop
        if (i = 7) then
          Asics_Read_Sel_dec(8) <= asics_read_sel_enc(i); -- [31] - master/slave ASIC
        elsif (i = to_integer(unsigned(asics_read_sel_enc(3 downto 0)))) then
          Asics_Read_Sel_dec(i) <= '1'; -- one hot[30..24] - ASIC in tile
        else
          Asics_Read_Sel_dec(i) <= '0';
        end if;
      end loop ams_sel4rd_l;

      -- -- !TODO: 01/05/2023 remove after PID integration
      -- if (Heater_Control(9 downto 8) = "00") then
      --   Duty_Cycle_In <= (others => '0');
      -- else                              -- manual
      --   Duty_Cycle_In <= Heater_Control(7 downto 0);
      -- end if;
      Duty_Cycle_In <= Heater_Control(7 downto 0); -- 16/08/2023

      -- test timer, LSB 0.1 Sec
      if (test_100ms_cnt = 0) then
        test_100ms_cnt <= 5000000;
      else
        test_100ms_cnt <= test_100ms_cnt - 1; -- 100ms delay
      end if;
      if (test_100ms_cnt = 1) then
        test_timer <= test_timer + 1; -- timer * 0.1S
      end if;

      -- if (DDR_DRIVER_HEADER_READY = '1') then
      --   mem_buf_num_of_slices <= DDR_DRIVER_HEADER_BUS(22 downto 16); -- [6:0]  !debug: 09/11/2023 was   6 downto 0
      -- end if;

      if (sorter_data_ready = '1') then -- !debug: 03/12/2023 update DDR3 EV/FQ reading start write addresses in same time as scan header
        raw_wr_ptr_addr <= unsigned(hd_ptr_address_from_sync(DDR3_ADDR_WIDTH-1 downto 0));
        -- raw_wr_ptr_addr <= raw_wr_ptr_0_addr;
        ev_wr_slot_addr <= unsigned(rlt_address_from_sync(DDR3_ADDR_WIDTH-1 downto 0));
      end if;

      -- if (sorter_data_ready = '1') then -- !debug: 17/03/2024 update footer params only when new header reads from memory
      if (TRUE) then -- !debug: 04/04/2024 parameters must be updated before data and header processing
        fs_merging_factor_synced2header <= fs_merging_factor;
        fs_sequence_counter_synced2header <= fs_sequence_counter;
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

      IP50_r <= IP50;
      -- if (IP50_r = '0' and IP50 = '1') then -- !debug: 19/02/2024 when FQ write restored, 1st PTR address lost, because long data packet delay > 1 IP
      --   raw_wr_ptr_0_addr <= unsigned(hd_ptr_address_from_sync(DDR3_ADDR_WIDTH-1 downto 0));
      -- end if;


      -- if (IP_READY = '1') then
      --   raw_wr_ptr_addr_prev <= raw_wr_ptr_addr;
      --   if (raw_wr_ptr_addr_prev /= raw_wr_ptr_addr) then
      --     raw_wr_ptr_addr_watch_cnt <= 3;
      --     raw_wr_ptr_addr_stopped <= '0';
      --   else
      --     if (raw_wr_ptr_addr_watch_cnt /= 0) then
      --       raw_wr_ptr_addr_watch_cnt <= raw_wr_ptr_addr_watch_cnt - 1;
      --     else
      --       raw_wr_ptr_addr_stopped <= '1';
      --     end if;
      --   end if;
      -- end if;

      -- !debug: 25/01/2024 only for test
      if (IP_READY = '1') then
        stream_enable_1_r <= stream_enable(1);
        if (unsigned(reading_number_freerun_cnt) > X"0001") then  -- protect from false init
          if (unsigned(vio_reading_number_buffer_tmp_sel(7 downto 4)) = X"0") then
            latch_test_buffer <= DDR_DRIVER_TESTPOINTS(1); --  raw_wr_ptr_addr_stopped
          elsif (unsigned(vio_reading_number_buffer_tmp_sel(7 downto 4)) = X"1") then
            latch_test_buffer <= latch_test_buffer or (stream_enable(1) and not stream_enable_1_r);
          elsif (unsigned(vio_reading_number_buffer_tmp_sel(7 downto 4)) = X"2") then
            latch_test_buffer <= latch_test_buffer or DDR_DRIVER_TESTPOINTS(0);
          elsif (unsigned(vio_reading_number_buffer_tmp_sel(7 downto 4)) = X"3") then
            if (unsigned(mem_buf_num_of_slices) /= 7UX"00" or
                unsigned(mem_buf_num_of_slices) /= 7UX"08" or
                unsigned(mem_buf_num_of_slices) /= 7UX"10" or
                unsigned(mem_buf_num_of_slices) /= 7UX"20" or
                unsigned(mem_buf_num_of_slices) /= 7UX"40") then
              latch_test_buffer <= '1';
            else
              latch_test_buffer <= '0';
            end if;
          else
            latch_test_buffer <= latch_test_buffer or DDR_DRIVER_TESTPOINTS(0);
          end if;
        end if;
      end if;
      sorter_data_ready_r <= sorter_data_ready;
      if (sorter_data_ready = '1' and sorter_data_ready_r = '0') then  -- latch on start
        if (save_en_v) then
          raw_wr_ptr_addr_buffer_tmp_v := raw_wr_ptr_addr_buffer_tmp_v(16*DDR3_ADDR_WIDTH-DDR3_ADDR_WIDTH-1 downto 0) & std_logic_vector(raw_wr_ptr_addr);
        end if;
        if (latch_test_buffer = '1') then     -- stop, when error
          save_en_v := FALSE;
        else
          if (unsigned(vio_reading_number_buffer_tmp_sel(7 downto 4)) = X"0") then
            save_en_v := TRUE;
          else
            null;                       -- hold test buffer
          end if;
        end if;
      end if;
      raw_wr_ptr_addr_buffer_out <= raw_wr_ptr_addr_buffer_tmp_v(DDR3_ADDR_WIDTH*to_integer(unsigned(vio_reading_number_buffer_tmp_sel(3 downto 0)))+DDR3_ADDR_WIDTH-1 downto DDR3_ADDR_WIDTH*to_integer(unsigned(vio_reading_number_buffer_tmp_sel(3 downto 0)))+0);

      -- !debug: 25/01/2024 only for test
      if (buffer_req_valid = '1' and buffer_req_valid_r = '0' and save_en_v) then  -- latch on start
        rq_rd_ptr_buffer_tmp_v := rq_rd_ptr_buffer_tmp_v(16*DDR3_ADDR_WIDTH-DDR3_ADDR_WIDTH-1 downto 0) & buf_ptr_address_from_buffer(DDR3_ADDR_WIDTH-1 downto 0);
      end if;
      rq_rd_ptr_buffer_out <= rq_rd_ptr_buffer_tmp_v(DDR3_ADDR_WIDTH*to_integer(unsigned(vio_reading_number_buffer_tmp_sel(3 downto 0)))+DDR3_ADDR_WIDTH-1 downto DDR3_ADDR_WIDTH*to_integer(unsigned(vio_reading_number_buffer_tmp_sel(3 downto 0)))+0);


    end if;
  end process misc_50m_pr;

  dpr_header_valid_r <= '1' when (dpr_header_valid_shr(1 downto 0) /= "00") else '0';


  registers_inst_A: Module_TX_RX_diag_A
    generic map (
      DATA_ZISE     => 8,
      G_DATA_LENGTH => G_DATA_LENGTH)
    port map (
      S_clk_200MHz => CLK200,
      S_clk_50MHz => sys_clk,
      S_locked => clk_locked,
      -- CLKp_200MHz              => CLKp_200MHz,
      -- CLKn_200MHz              => CLKn_200MHz,
      RST                      => "not"(rst_n),
      channel_RDY              => Module_TX_RX_channel_RDY,
      RX_IN                    => Diag_in_i,
      TX_OUT                   => Diag_out_i,
      STATUS                   => (others => '0'), -- !TODO: 08/12/2022 add driver
      BAD_PIX_HL               => BAD_PIX_HL,
      BAD_PIX_LL               => BAD_PIX_LL,
      CONTROL_REGISTER_LSB => CONTROL_REGISTER_LSB,
  --    CONTROL_REGISTER_MSB => CONTROL_REGISTER_MSB,
      FIFO_RESET                         => FIFO_RESET,
      CONFIGURATION_STATUS               => open,
      WR_TO_CONFIGURATION_STATUS(15 downto 0) => WR_TO_CONFIGURATION_STATUS, -- remote config 0x83 - Configuration status
      WR_TO_CONFIGURATION_STATUS(31 downto 16) => (others => '0'),
      CONFIGURATION_FIFO_RD_CNT => open,
      WR_TO_CONFIGURATION_FIFO_RD_CNT(15 downto 0) => conf_fifo_rd_cnt_reg, -- remote config 0x84 - Configuration FIFO rd count
      WR_TO_CONFIGURATION_FIFO_RD_CNT(31 downto 16) => (others => '0'),
      REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER => config_data_in, -- remote config 0x85 - Configuration FIFO filling registers
      CONFIG_WR_EN             => config_wr_en, -- remote config: 1 clk strobe, when write to 0x85
      REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER => open,
      WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER => config_data_out(31 downto 0), -- remote config 0x86 - read data
      WR_TO_NVRAM_STATUS => (others => '0'),                                                -- !TODO: 20/07/2023 connect
      -- TEST                     => open, -- !TODO: 07/02/2023 connect to remote config
      -- WR_TO_TEST               => (others => '0'), -- 0x8A - NU, free in Taichi
      BAD_PIX_PER_TILE         => BAD_PIX_PER_TILE, -- 0x7C
      NOT_VALID_ADDR_OUT       => open,
      BAD_PACKET_RECEIVED      => open, -- 20/07/2023
      -- CRC_ERROR                => open, -- 20/07/2023
      -- STD_ERROR                => open, -- 20/07/2023
      -- RX_ERRs => RX_ERRs_diag_A, -- !debug: 05/10/2023 delete by dalit 10/10/2023
     -- 21/03/2023
    Tile1_Temperature => Tile1_Temperature,
    Tile2_Temperature => Tile2_Temperature,
    Tile3_Temperature => Tile3_Temperature,
    Tile4_Temperature => Tile4_Temperature,
    Module_Inlet_Temperature => Module_Inlet_Temperature,
    Module_Outlet_Temperature => Module_Outlet_Temperature,
    Module_Average_Temperature => Module_Average_Temperature,
    diag_7_8_sel_reg => open,
    Asics_Aligned_4B0 => open,
    kP_reg => kP_reg,
    kI_reg => kI_reg,
    kD_reg => kD_reg,
    kAW_reg => kAW_reg,
    Heater_Control => Heater_Control,
    SetPoint => SetPoint,
    Temperature_Weighted_Average_CFG => Temperature_Weighted_Average_CFG,
    PID_Stable_Tolerance => PID_Stable_Tolerance,
    Temperature_Sample_and_rates => Temperature_Sample_and_rates,
    Integral_and_Derivative_rates => Integral_and_Derivative_rates,
    Status_and_Errors => Status_and_Errors,
    PWM_Duty_Cycle_IN => PWM_Duty_Cycle_IN,
    temporary_reg2 => temporary_reg2,
    timestamp => date_in_bcd_sig,    -- 22/05/2023
    fw_ver => fw_ver,
    board_ver => board_ver,
    Num_of_Slices => temp_Num_of_Slices,
    Module_Status_Errors_reg => Module_Status_Errors_reg, -- 04/12/2023

	--added by tzvika sweetkin 26/07/2023
    NVRAM_ADDR_REG          => nvram_addr_reg_sig,
    NVRAM_DATA_REG          => nvram_data_reg_sig,
    NVRAM_READ_DATA_REG     => nvram_readdata_reg_sig,
    NVRAM_STATUS_REG        => nvram_status_reg_sig,
    tile_packet_ok_timeout => tile_packet_ok_timeout,

    --added by Dalit 12/10/2023
      Diag_RX_ERRs               => RX_ERRs_diag_A,    -- add by Dalit 10/10/2023
      Operational_RX_ERRs        => RX_ERRs_Operational_B,    -- add by Dalit 10/10/2023
      Operational_TX_ERRs        => TX_ERRs_Operational_B,    -- add by Dalit 10/10/2023
      IP_HEADER_RX_ERRs          => RX_ERRs_SYNC,    -- add by Dalit 10/10/2023
      Buffer_Control_RX_ERRs     => RX_ERRs_buffer,  --  -- add by Dalit 10/10/2023
      Data_TX_ERRs               => TX_ERRs_DATA,     -- add by Dalit 10/10/2023
      AMS_CRC_ERRs_Counter       => AMS_CRC_ERRs_Counter, --add by Dalit 19/9/2023
      AMS_CrcError               => AMS_CrcError, --add by Dalit 19/9/2023
      AMS_CrcOk                  => AMS_CrcOk, --add by Dalit 19/9/2023
      Tile_data_align_o          => Tile_data_locked, ---add by Dalit 19/9/2023
      SPI_Errs                   => SPI_Errs,    ---add by Dalit 19/9/2023
      HD_Buffer_Overrun          => HD_Buffer_Overrun, -- add by Dalit 10/10/2023
      RTL_Buffer_Overrun         => RTL_Buffer_Overrun, -- add by Dalit 10/10/2023
      PGOOD_0_75V                => PGOOD_0_75V,--add by Dalit 12/10/2023-- 0.75v Good indication, VTT_PGOOD
      PGOOD_1_0V                 => PGOOD_1_0V,  --add by Dalit 12/10/2023
      PGOOD_1_5V                 => PGOOD_1_5V,--add by Dalit 12/10/2023
      PGOOD_1_8V                 => PGOOD_1_8V, --add by Dalit 12/10/2023
      PGOOD_P1_5V                => PGOOD_P1_5V,   --add by Dalit 12/10/2023-- analog voltage
      PGOOD_2_5V                 => PGOOD_2_5V, --add by Dalit 12/10/2023-- analog voltage
      Tile_power_monitor_footer  => Tile_power_monitor_footer, --add by Dalit 12/10/2023
      Operational_DIAGNSOTICS    => DIAGNSOTICS, --add by Dalit 12/10/2023
      IP_too_short               => IP_too_short, --add by Dalit 12/10/2023
      IP_too_long                => IP_too_long, --add by Dalit 12/10/2023
      ddr_driver_errors => (others => '0'),
      MU_CTRL                    => MU_CTRL, --add by Dalit 18/10/2023
      MODULE_DATA_OUT_SELCTION   => MODULE_DATA_OUT_SELCTION,  --add by Dalit 18/10/2023
      Remote_Programing_SM_Bits  => SM_Bits, --add by Dalit 18/10/2023
      Asic_mode_Calibrated_or_Raw => Asic_mode_Calibrated_or_Raw, --add by Dalit 18/10/2023
      footer_send				 => footer_send,--add by Dalit 15/10/2023
      OverRun_RTL_reset_flag     => OverRun_RTL_reset_flag,--add by Dalit 17/12/2023
      OverRun_HD_reset_flag      => OverRun_HD_reset_flag--add by Dalit 17/12/2023
    );

	--NVRAM controller:added by tzvika sweetkin 26/07/2023
  nvram_inst:component nvram_top
    generic map(
        G_IIC_CLKS_NUM  => 500, -- 100K with 50MHz clk
        G_TOUT          => x"3D090" -- 5msec with 50MHz clk
    )
    port map (
        CLK    =>  sys_clk,
        RESET  =>  "not"(rst_n),
        ------------------------------------
        REG1_ADDR               => nvram_addr_reg_sig       ,
        REG2_WRITEDATA_OP       => nvram_data_reg_sig       ,
        REG3_READDATA           => nvram_readdata_reg_sig   ,
        REG4_STATUS             => nvram_status_reg_sig     ,
        ------------------------------------
        NVRAM_SDA               => sda_sig ,
        NVRAM_SCL               => scl_sig ,
        NVRAM_WP                => open
        ------------------------------------
    );
  SDA(1)<= sda_sig;
  SCL(1) <= scl_sig;


 registers_inst_B: Module_TX_RX_Operational_B --@dalit 18/7/2023
    generic map (
      DATA_ZISE     => 8,
      G_DATA_LENGTH => G_DATA_LENGTH)
    port map (
      S_clk_200MHz => CLK200,
      S_clk_50MHz => sys_clk,
      S_locked => clk_locked,
      RST                      => "not"(rst_n),
      channel_RDY              => Module_TX_RX_channel_RDY,
      RX_IN                    => Reg_in_i,
      TX_OUT                   => Reg_out_i,
      STATUS                   => (others => '0'), -- !TODO: 08/12/2022 add driver
      MU_CTRL                  => MU_CTRL,
      ADD_CONST_OFST_TO_MU     => ADD_CONST_OFST_TO_MU,
     CONST_OFST_VAL_TO_MU     => CONST_OFST_VAL_TO_MU,
      ASIC_TST_CAL_CTRL_TEST   => ASIC_TST_CAL_CTRL_TEST, -- 0x73
      TEST_ERROR               => TEST_ERROR,
      WR_TO_TEST_ERROR         => (others => '0'), -- !TODO: 10/01/2023 add driver
     DIAGNSOTICS              => DIAGNSOTICS,     -- 0x75
      GLOBL_IP_COEF            => GLOBL_IP_COEF,
      ASIC_DATA_ALIGNMENT      => ASIC_DATA_ALIGNMENT, -- 78
      MODULE_DATA_OUT_SELCTION => MODULE_DATA_OUT_SELCTION,
      NOT_VALID_ADDR_OUT       => open,
      BAD_PACKET_RECEIVED      => BAD_REG_PACKET_RECEIVED,
      -- CRC_ERROR                => REG_CRC_ERROR,
      -- STD_ERROR                => REG_STD_ERROR, -- !debug: 26/12/2022  only for debug S_packet_received
      RX_ERRs => RX_ERRs_Operational_B, -- !debug: 05/10/2023
      TX_ERRs => TX_ERRs_Operational_B,  --add by Dalit 10/10/2023
    ams_asics_reset => ams_asics_reset,
    Power_en_mask => Power_en_mask,   -- 25/06/2023
    asic_rdwr_exe => asic_rdwr_exe,
    asic_rdwr_ops => asic_rdwr_ops,
    AMS_DATA2R => AMS_DATA2R,
    asics_read_sel => asics_read_sel_enc -- 0x66 [31] - master/slave ?!, [30..24] - ASIC in tile
    );


 -- temporary_reg1 <= AMS_CrcError;      --- delete by Dalit 10/10/2023 for diagnostic -- !debug: 11/05/2023 to reg. 0x4A
 -- temporary_reg2 <= X"000000" & Tile_data_locked;       -- !debug: 11/05/2023 to reg. 0x4A  --delete by Dalit 19/9/2023

  -- config_ctl_reg <= CONTROL_REGISTER_MSB(15 downto 0) & CONTROL_REGISTER_LSB(15 downto 0);
  config_ctl_reg <= CONTROL_REGISTER_LSB; -- !debug: 14/03/2023 control register MSB 0x81 removed
  reset_fifo_reg <= FIFO_RESET(1);

  Module_TX_RX_channel_RDY <= sig_2_channel_RDY;


  AMS_packet <= '0' & asic_rdwr_ops(14 downto 0) & asic_rdwr_ops(31 downto 16); -- [15..0] - ASIC data, [31..16] - ASIC addr
  AMS_Wr <= '1' when (asic_rdwr_ops(30) = '0' and asic_rdwr_exe = '1') else '0'; -- 03/04/2023 migrate from Aron [15],[14] to new design
  AMS_S2p_ready <= asic_rdwr_exe; -- 03/04/2023 migrate from Aron [15] to new design

  tmb_reg2spictl_1: tmb_reg2spictl
    generic map (
      WORD_WIDTH2 => WORD_WIDTH2)
    port map (
      rst_n          => rst_n,
      sys_clk        => sys_clk,
      AMS_packet     => AMS_packet,
      AMS_Wr         => AMS_Wr,
      AMS_S2p_ready  => AMS_S2p_ready,
      wrreq          => wrreq,
      REGS_req       => REGS_req,
      ms_spi_sel     => ms_spi_sel, -- asics_read_sel_enc(7),     -- '0' - SPI drive slave ASIC, '1' - SPI drive master ASIC
      Asics_Read_Sel_dec => Asics_Read_Sel_dec,
      READ_OUT_READY => READ_OUT_READY,
      DATA2R         => DATA2R,
      AMS_DATA2R     => AMS_DATA2R
      );


  -- IP_DATAVAL_HEADER_TOP_1: IP_DATAVAL_HEADER_TOP
  --   generic map (
  --     IP_DATA_OUT_VAL => IP_DATA_OUT_VAL,
  --     HEADER_DATA_OUT_VAL => HEADER_DATA_OUT_VAL,
  --     ADDR_BIT_VAL => ADDR_BIT_VAL,
  --     DATA_BIT_VAL => DATA_BIT_VAL,
  --     NumFooterBytes => 12              -- 12/10/2023 added !debug: 13/10/2023 try 11 -> 12
  --     )
  --   port map (
  --     CLK_200Mhz          => CLK200,
  --     CLK_50Mhz           => sys_clk,
  --     RST                 => "not"(rst_n),
  --     sDataIn             => Sync_s_i,
  --     Channel_RDY         => Module_TX_RX_channel_RDY, -- !debug: 02/01/2023 Channel_RDY, -- 28/12/2022
  --     IP_READY            => IP_READY,
  --     IP_DATA_OUT         => IP_DATA_OUT,
  --     HEADER_DATA_OUT     => HEADER_DATA_OUT, -- data from DPR
  --     clkb                => '0',
  --     enb                 => '0',
  --     web(0)              => '0',
  --     addrb               => header_dpr_addr, -- read address from DPR
  --     dinb                => (others => '0'),
  --     doutb               => open,      -- NU
  --     rlt_address_from_sync => rlt_address_from_sync, -- EV WR address
  --     hd_ptr_address_from_sync => hd_ptr_address_from_sync,  -- FQ WR address
  --     slice_merging_factor => slice_merging_factor,          -- from SYNC footer
  --     fs_merging_factor => fs_merging_factor,                -- from SYNC footer
  --     fs_sequence_counter => fs_sequence_counter,            -- from SYNC footer
  --     fq_stream_enable => fq_stream_enable,
  --     temp_Num_of_Slices => temp_Num_of_Slices,
  --     reading_number_freerun_cnt_o => reading_number_freerun_cnt,
  --     make_data_from_sync => make_data_from_sync, -- 05/05/2024
  --     bad_packet_received => bad_ip_packet_received,
  --     -- crc_error           => ip_crc_error,
  --     -- std_error           => ip_std_error
  --     RX_ERRs => RX_ERRs_SYNC
  --   );


  -- 01/02/2023 Flash remote update
  STARTUPE2_inst : STARTUPE2
  generic map (
   PROG_USR => "FALSE", -- Activate program event security feature. Requires encrypted bitstreams.
   SIM_CCLK_FREQ => 0.0 -- Set the Configuration Clock Frequency(ns) for simulation.
  )
  port map (
   CFGCLK => open,      -- 1-bit output: Configuration main clock output
   CFGMCLK => open,     -- 1-bit output: Configuration internal oscillator clock output
   EOS => open,         -- 1-bit output: Active high output signal indicating the End Of Startup.
   PREQ => open,        -- 1-bit output: PROGRAM request to fabric output
   CLK => '0',          -- 1-bit input: User start-up clock input
   GSR => '0',          -- 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
   GTS => '0',          -- 1-bit input: Global 3-state input (GTS cannot be used for the port name)
   KEYCLEARB => '1',    -- 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
   PACK => '0',         -- 1-bit input: PROGRAM acknowledge input
   USRCCLKO => SCK_FLASH, -- 1-bit input: User CCLK input
   USRCCLKTS => '0',    -- 1-bit input: User CCLK 3-state enable input
   USRDONEO => '1',     -- 1-bit input: User DONE pin output control
   USRDONETS => '0'     -- 1-bit input: User DONE 3-state enable output
  );

  -- 01/02/2023
  access_config_top_inst:  access_config_top
     port map (
        clk             =>  sys_clk            ,
        config_ctl_reg  =>  config_ctl_reg     ,
        din             =>  std_logic_vector'(X"00000000" & config_data_in(15 downto 0) & config_data_in(31 downto 16)),
        reset           =>  rst_n              ,
        reset_fifo      =>  reset_fifo_reg     ,
        so              =>  SO_FLASH           ,
        wr_en           =>  config_wr_en       ,
        CS              =>  CS_FLASH           ,
        SCK             =>  SCK_FLASH          ,
        busy            =>  busy               ,
        conf_status_reg =>  conf_status_reg    ,
        data_out        =>  config_data_out    ,
        rd_data_count   =>  rd_data_count      ,
        si              =>  SI_FLASH
     );

    conf_fifo_rd_cnt_reg(6 downto 0) <= rd_data_count;
    conf_fifo_rd_cnt_reg(15 downto 7) <= (others => '0');

    WR_TO_CONFIGURATION_STATUS(0) <= conf_status_reg(0);
    WR_TO_CONFIGURATION_STATUS(1) <= '1' when (conf_status_reg(4 downto 1) /= X"0") else '0'; -- 03/09/2023
    WR_TO_CONFIGURATION_STATUS(15 downto 2) <= 14UX"0000";

    -- Remote configuration statuses for software
    remote_status_pr: process (sys_clk, rst_n) is
    begin  -- process remote_status_pr
      if (rst_n = '0') then              -- asynchronous reset (active low)
        SM_Bits <= "00";
      elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

        if (reset_fifo_reg = '1') then
          SM_Bits <= "00";              -- FIFO reset
        elsif (conf_status_reg(1) = '1') then -- PP_CRC_error
          SM_Bits <= "11";              -- error
        elsif ((SM_Bits = "00" or SM_Bits = "10") and (conf_status_reg(2) = '1' or conf_status_reg(3) = '1')) then -- PP_EXE_error or PP_GT_EXE_error
          SM_Bits <= "11";              -- error: rd_data_count<64 or rd_data_count>64
        elsif ((SM_Bits = "00" or SM_Bits = "10") and conf_status_reg(0) = '1') then -- start program flash
          SM_Bits <= "01";              -- busy
        elsif (SM_Bits = "01" and conf_status_reg(0) = '0' and SM_Bits /= "11") then -- 06/03/2023
          SM_Bits <= "10";              -- done
        end if;

      end if;
    end process remote_status_pr;


    footer_pr: process (sys_clk, rst_n) is
    begin  -- process footer_pr
      if (rst_n = '0') then              -- asynchronous reset (active low)
        footer_dw <= (others => (others => '0'));
        diag_sel4footer <= (others => '0');
        footer_bits <= (others => '0');
      elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

        -- footer_dw(1) <= X"000000" & "000" & SM_Bits & ctl2_reg(0) & "not"(overhead_bits(51)) & mu_ctl_reg; -- #1 Module Status/Errors
        footer_dw(1) <= Module_Status_Errors_reg; -- 04/12/2023
        -- footer_dw(2) <= data2read_out_Sensor_2 & data2read_out_Sensor_1; -- #2 Module Temperature Sensors readout
        footer_dw(2) <= X"00" & Duty_Cycle_In & Sensors_Moving_SUM; -- 05/07/2023
        footer_dw(3) <= X"000000" & Heater_Control(7 downto 0);  -- !debug: 02/05/2023 X"04030201"
        footer_dw(4) <= X"000000" &
                        calib_completed(7*4+0) & calib_completed(6*4+0) & calib_completed(5*4+0) & calib_completed(4*4+0) &
                        calib_completed(3*4+0) & calib_completed(2*4+0) & calib_completed(1*4+0) & calib_completed(0); -- #4 E1 - Linearity Calibration - Done
        footer_dw(5) <= X"000000" &
                        calib_completed(7*4+3) & calib_completed(6*4+3) & calib_completed(5*4+3) & calib_completed(4*4+3) &
                        calib_completed(3*4+3) & calib_completed(2*4+3) & calib_completed(1*4+3) & calib_completed(3); -- #5 E1 - Offset Voltage Calibration - Done
        footer_dw(6) <= X"000000" &
                        calib_completed(7*4+2) & calib_completed(6*4+2) & calib_completed(5*4+2) & calib_completed(4*4+2) &
                        calib_completed(3*4+2) & calib_completed(2*4+2) & calib_completed(1*4+2) & calib_completed(2); -- #6 E1 - Offset Current Calibration - Done
        footer_dw(7) <= data2read_out_Sensor_1 & data2read_out_Sensor_2;  -- inlet/outlet/asic# temperature, according TBD selector !TODO: 05/07/2023 connect selector
        footer_dw(8) <= (others => '0');  -- #8
        footer_dw(9) <= RTL_buffer_free_size;  -- #9 RLT Buffer Free Space
        footer_dw(10) <= HD_buffer_free_size;  -- #10 HD Buffer Free Space
        footer_dw(11) <= (others => '0');  -- #11
        footer_dw(12) <= (others => '0');  -- #12 Spare 1
        footer_dw(13) <= (others => '0');  -- #13 Spare 2
        footer_dw(14) <= (others => '0');  -- #14 Spare 3
        footer_dw(15) <= (others => '0');  -- #15 Spare 4
        -- footer_dw(16) <= (others => '0');  -- #16 Spare 5
        footer_dw(16) <= X"F4F3F2F1";  -- !debug: 02/05/2023 only for test

        -- !debug: 21/03/2023 old footer 16*8 or 4*32 bits
        if (TRUE) then
          -- footer_bits(0*32+31 downto 0*32) <= footer_dw1; -- DW1: Module Status/Errors
          -- footer_bits(1*32+31 downto 1*32) <= footer_dw2; -- DW2: Temperature sensor2 & sensor1
          -- footer_bits(2*32+31 downto 2*32) <= footer_dw3; -- DW3: Temperature stabilization Status/Errors
          -- footer_bits(3*32+31 downto 3*32) <= footer_dw4; -- DW4: Lenearity Calibration
          -- -- !TODO: ask Tzvika/Hanan enlarge footer
          -- -- footer_bits(i*32+31 downto i*32) <= footer_dw5; -- DW5: Offset Voltage Calibration
          -- -- footer_bits(i*32+31 downto i*32) <= footer_dw6; -- DW6: Offset Current Calibration

          if (LONG_TMB_FOOTER) then
            for i in 0 to 15 loop
              footer_bits(i*32+31 downto i*32) <= footer_dw(15-i+1)(15 downto 0) & footer_dw(15-i+1)(31 downto 16);  -- 02/05/2023 reversed for packet builder
            end loop;  -- i
          else
            for i in 0 to 3 loop
              footer_bits(i*32+31 downto i*32) <= footer_dw(3-i+1);  -- 02/05/2023 Q: if must reversed for packet builder? !TODO: update after simulation
            end loop;  -- i
            -- synthesis translate_off
            -- note: old 16bytes footer
            -- for i in 0 to 3 loop
            --   footer_bits(i*32+31 downto i*32) <= footer_dw(3-i+1); -- 02/05/2023 Q: if must reversed for packet builder? !TODO: update after simulation
            -- end loop;  -- i
            for i in 0 to 3 loop
              footer_bits(i*32+31 downto i*32) <= footer_dw(3-i+1);  -- 02/05/2023 Q: if must reversed for packet builder? !TODO: update after simulation
            end loop;  -- i
            -- synthesis translate_on
          end if;
        else
          footer_bits <= footer_bits_dummy;
        end if;
        -- !TODO: 16/11/2023 add diag_sel4footer driver
        -- diag_sel4footer[31..0] - 0xA0X0651C	- Selector for Diagnostic D-Words transferred to CDM via Footers
        case to_integer(unsigned(diag_sel4footer(7 downto 0))) is
          when 1 => footer_dw7_src <= (others => '0');
          when 2 => footer_dw7_src <= (others => '0');
          when 3 => footer_dw7_src <= (others => '0');
          when 4 => footer_dw7_src <= (others => '0');
          when others => footer_dw7_src <= data2read_out_Sensor_1 & data2read_out_Sensor_2;  -- inlet/outlet/asic# temperature, according TBD selector
        end case;


      end if;
    end process footer_pr;


  ctl_pr : process (sys_clk) is
    variable aclk_sample_v : boolean := FALSE;
  begin  -- process ctl_pr
    if (sys_clk'EVENT and sys_clk = '1') then  -- rising clock edge

      -- aclk_sample_v := aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0'; -- aclk falling
      aclk_sample_v := aclk_shr_50m(2) = '0' and aclk_shr_50m(1) = '1'; -- !debug: 26/03/2023 aclk rising

      -- buffer request
      -- set buffer_req_valid -> wait for aclk fall -> set ip_i -> wait for aclk fall -> clear ip_i -> clear buffer_req_valid_sampled
      if (buffer_req_valid = '1') then -- BUFFER packet received
        buffer_req_valid_sampled <= '1';
        buffer_req <= '0';
      -- elsif ((aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0') and buffer_req_valid_sampled = '1') then
      elsif (aclk_sample_v and buffer_req_valid_sampled = '1') then -- !debug: 04/10/2023
      -- elsif (aclk_sample_v and IP50 = '1') then -- !debug: 03/08/2023 now buffer_req applied in IP
        buffer_req <= buffer_req_valid_sampled; -- wide pulse
        buffer_req_valid_sampled <= '0'; -- !debug: 03/08/2023 now old buffer_req_valid_sampled cleared by IP
      -- elsif ((aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0') and buffer_req_valid_sampled = '0') then
      elsif (aclk_sample_v and buffer_req_valid_sampled = '0') then -- !debug: 26/03/2023
        buffer_req <= '0';
      end if;

      -- IP: IP_READY -> wait for aclk fall -> set ip_i -> wait for aclk fall -> clear ip_i -> clear ip_valid_sampled
      if (IP_READY = '1') then
        ip_valid_sampled <= '1';
        ip_i <= '0';
      -- elsif ((aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0') and ip_valid_sampled = '1') then
      elsif (aclk_sample_v and ip_valid_sampled = '1') then -- !debug: 26/03/2023
        ip_i <= ip_valid_sampled;
        ip_valid_sampled <= '0';
      -- elsif ((aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0') and ip_valid_sampled = '0') then
      elsif (aclk_sample_v and ip_valid_sampled = '0') then -- !debug: 26/03/2023
        ip_i <= '0';
      end if;

      -- -- !debug: 20/03/2023 non-incremental reading number check
      -- if (ip_i = '0' and ip_valid_sampled = '1') then
   	  --   ip_timeout_cnt <= 25000; -- 500 usec @200MHz
      -- elsif (ip_timeout_cnt /= 0) then
	  --   ip_timeout_cnt <= ip_timeout_cnt - 1;
	  -- end if;
	  -- if (ip_timeout_cnt = 0) then
	  --   ip_timeout_err <= '1';
	  -- else
  	  --   ip_timeout_err <= '0';
	  -- end if;
      -- if (buffer_req = '0' and buffer_req_valid_sampled = '1') then
   	  --   buffer_timeout_cnt <= 25000;
      -- elsif (buffer_timeout_cnt /= 0) then
	  --   buffer_timeout_cnt <= buffer_timeout_cnt - 1;
	  -- end if;
	  -- if (buffer_timeout_cnt = 0) then
	  --   buffer_timeout_err <= '1';
	  -- else
  	  --   buffer_timeout_err <= '0';
	  -- end if;

      -- !debug: 09/07/2023 disabled IP from testbench
      -- -- synthesis translate_off
      -- ip_i <= << signal .rx_ams_tiles_tb.IP : std_logic >>; -- v.2 IP, generated in testbench
      -- -- synthesis translate_on

      if (diag_reg = X"0009") then      -- !debug: 21/12/2022 only for intergration with Yossi - IP not synced with ACLK
        ip <= ip_i;
      elsif (aclk_shr_50m(2) = '1' and aclk_shr_50m(1) = '0') then -- ACLK falling
        ip <= ip_i;
      end if;

      buffer_req_valid_r <= buffer_req_valid;
      if (buffer_req_valid_r = '1') then
        rq_cmds_sampled <= rq_cmds(1 downto 0);
      end if;

      -- !debug: 21/05/2024 measure time from buffer_req to DDR_DRIVER_RD
      if (timer_1_us_cnt < 49) then
        timer_1_us_cnt <= timer_1_us_cnt + 1;
      else
        timer_1_us_cnt <= 0;
      end if;
      if (DDR_DRIVER_RD = '1') then
        req2ddr3_out_cnt <= 0;          -- TX active
      elsif (buffer_req_valid_r = '1') then
        req2ddr3_out_cnt <= 1;          -- rq_cmds arrives
      elsif (req2ddr3_out_cnt > 0 and req2ddr3_out_cnt < 255 and timer_1_us_cnt = 49) then
        req2ddr3_out_cnt <= req2ddr3_out_cnt + 1;
      end if;

    end if;
  end process ctl_pr;


  Module_Inlet_Temperature <= X"0000" & data2read_out_Sensor_2;
  Module_Outlet_Temperature <= X"0000" & data2read_out_Sensor_1;

  -- TMP112_CTL_1: TMP112_CTL
  --   port map (
  --     RESET                  => rst_n,
  --     reset_64M              => rst_n,
  --     clk                    => sys_clk,
  --     clk_64M                => sys_clk,
  --     Sda                    => Sda(0),
  --     Scl                    => Scl(0),
  --     data2read_out_Sensor_1 => data2read_out_Sensor_1,
  --     data2read_out_Sensor_2 => data2read_out_Sensor_2
  --     );


  -- use_ddr3_phy_g : if (USE_DDR_DRIVER) generate
  --
  --   ddr_driver_1 : ddr_driver
  --     port map (
  --       global_reset_n      => ddr3_rst_n,
  --       reset_sys_clk       => ddr3_rst_n,
  --       DDR3_SOFT_RESET_N   => ddr3_rst_n,                 -- '1',
  --       CLK_50Mhz           => sys_clk,
  --       sys_clk_p           => ddr3_sys_clk_p,
  --       sys_clk_n           => ddr3_sys_clk_n,
  --       ui_clk_o            => ui_clk,  -- out
  --       ui_clk_sync_rst_o   => ui_clk_sync_rst,            -- out
  --       ASSEMBLY_VERSION    => (1 => '0', others => '1'),  -- 10/02/2023 [1..0] = "01" 4Gb DDR3 -- chips, else 8Gb DDR3
  --       INIT_DONE_A_O       => open,    -- !TODO: 20/09/2023 connect
  --       IP50                => IP50,       -- 22/10/2023
  --       DATA_SORTER_DATA_EN => DATA_SORTER_DATA_EN,
  --       DATA_SORT_DOUT      => DATA_SORT_DOUT,
  --       EVOLVING_DATA_EN    => EVOLVING_DATA_EN,
  --       EVOLVING_DOUT       => EVOLVING_DOUT,
  --
  --       params_ready              => params_ready,
  --       tmb_header                => tmb_header_dout32,  -- 08/06/2023 updates to 128bytes scan header
  --       tmb_header_rd             => tmb_header_rd,      -- 21/09/2022
  --       ev_header                 => ev_header_dout32,   -- 17/08/2023
  --       ev_header_rd              => ev_header_rd,       -- 17/08/2023
  --       raw_wr_ptr_addr           => raw_wr_ptr_addr,
  --       ev_wr_slot_addr           => ev_wr_slot_addr,
  --       num_of_slices_no_merge    => num_of_slices_no_merge,
  --       num_of_slices_after_merge => num_of_slices_after_merge,
  --
  --       FPGA_ID                 => X"0",           -- !TODO: 20/09/2023 ddr3_test_reg(3 downto 0),
  --       READ_DATA_FSM_IDLE      => open,
  --       DDR_DRIVER_DOUT         => DDR_DRIVER_DOUT,  -- to taichi_slice_builder rx_det
  --       DDR_DRIVER_FIFO_EMPTY   => DDR_DRIVER_FIFO_EMPTY,  -- to taichi_slice_builder rx_fifo_empty
  --       DDR_DRIVER_RD           => DDR_DRIVER_RD,  -- to taichi_slice_builder rx_fifo_rd
  --       DDR_DRIVER_RD_READY     => DDR_DRIVER_RD_READY,  -- to taichi_slice_builder rd_reading_ready
  --       DDR_DRIVER_HEADER_BUS   => open, -- DDR_DRIVER_HEADER_BUS,
  --       DDR_DRIVER_HEADER_READY => open, -- DDR_DRIVER_HEADER_READY,
  --       MEM_BUF_NUM_OF_SLICES   => mem_buf_num_of_slices, -- 21/04/2024
  --       ECC_ERROR               => open,
  --       NO_ECC_CHK              => '1',            -- !debug: 01/01/2020 disable ECC
  --       rq_cmds                 => rq_cmds,  -- from BUFFER @400MHz
  --
  --       rq_rd_ptr             => buf_ptr_address_from_buffer(DDR3_ADDR_WIDTH-1 downto 0),  -- 20/09/2023 from BUFFER @400MHz
  --       UNIQ_ID               => (others => '0'),  -- !debug: 10/02/2023 (0 => '1', others => '0'),
  --                                       -- !TODO: 20/09/2023 connect to ddr3_test_reg[5..4]
  --       RTL_buffer_free_size   => RTL_buffer_free_size, -- TMB footer W#9: RLT Buffer Free Space
  --       RTL_buffer_OverRun     => RTL_buffer_OverRun,  --add by Dalit 10/10/2023
  --       HD_buffer_free_size    => HD_buffer_free_size, -- TMB footer W#10: HD Buffer Free Space
  --       HD_buffer_OverRun      => HD_buffer_OverRun,  --add by Dalit 10/10/2023
  --       OverRun_RTL_reset_flag => OverRun_RTL_reset_flag, --add by Dalit 17/12/2023
  --       OverRun_HD_reset_flag  => OverRun_HD_reset_flag,  --add by Dalit 17/12/2023
  --       diag_sel               => (others => '0'),           -- 30/10/2023
  --
  --       ddr3_addr             => ddr3_addr,        -- see DDR2_ADDR_ROW_BITS
  --       ddr3_ba               => ddr3_ba,          -- see DDR2_ADDR_BA_BITS
  --       ddr3_cas_n            => ddr3_cas_n,
  --       ddr3_cke(0)           => ddr3_cke(0),
  --       ddr3_cs_n(0)          => ddr3_cs_n(0),
  --       ddr3_dm               => ddr3_dm,
  --       ddr3_odt(0)           => ddr3_odt(0),
  --       ddr3_ras_n            => ddr3_ras_n,
  --       ddr3_we_n             => ddr3_we_n,
  --       ddr3_dq               => ddr3_dq,
  --       ddr3_dqs_p            => ddr3_dqs_p,
  --       ddr3_dqs_n            => ddr3_dqs_n,
  --       ddr3_ck_p             => ddr3_ck_p,
  --       ddr3_ck_n             => ddr3_ck_n,
  --       ddr3_reset_n          => ddr3_reset_n,
  --       -- TB signals
  --       DDR_DRIVER_TESTPOINTS => DDR_DRIVER_TESTPOINTS -- [0] - READ_FSM_ERROR
  --       );
  --
  -- end generate use_ddr3_phy_g;


  -- vio_0_1: vio_0
  --   port map (
  --     clk         => sys_clk,
  --     probe_out0  => vio_diag_reg,
  --     probe_out1(0)  => vio_ev_stream_enable,
  --     probe_out2  => vio_ctl2, -- vio_take_rx_det_msb,
  --     probe_out3(0) => vio_fq_stream_enable, -- 19/10/2023 default '0'
  --     probe_out4  => vio_pipeline_ctl,   -- 0xC0000086
  --     probe_out5  => vio_ams_offset,
  --     probe_out6  => vio_controls, -- vio_CREG_Crst,
  --     probe_out7  => vio_ibias,
  --     probe_out8  => vio_global_ip_time,
  --     probe_out9  => vio_reading_number_buffer_tmp_sel, -- [7..0]  default '0'
  --     probe_out10 => vio_ctl1,
  --     probe_out11 => vio_calib_ctl,
  --     probe_out12 => open,
  --     probe_out13 => vio_header_dpr_addr,
  --     probe_out14 => Module_channel_RDY_FORCE
  --     );


  -- !TODO: 29/10/2023 connect diag_sel4la to vio_0
  back2const_regs <= '0'; -- !debug: 05/10/2023 was  vio_controls(0);   -- selector vio_0_1/internal
  ddr3_debug_ctl <= not vio_controls(1);   -- 06/10/2023 selector for DDR3 integration parameters
                                           -- !debug: 24/10/2023 add "not" for normal start on power-up

  -- !debug: 22/10/2023 because default ddr3_debug_ctl = '1', temporary on powerup both EV and FQ disabled
  stream_enable(0) <= vio_ev_stream_enable when (ddr3_debug_ctl = '1') else '1'; --  FQ & EV
  stream_enable(1) <= vio_fq_stream_enable when (ddr3_debug_ctl = '1') else fq_stream_enable_synced2header; --  FQ & EV !debug: 17/03/2024
  rq_cmds(0) <= stream_ctrl_from_buffer(0); -- [1] - HD, [0] - EV
  rq_cmds(1) <= stream_ctrl_from_buffer(1); -- [1] - HD, [0] - EV
  diag_reg <= vio_diag_reg when (back2const_regs = '1') else DIAGNSOTICS(15 downto 0);
  mu_ctl_reg <= vio_mu_ctl when (back2const_regs = '1') else MU_CTRL(0);
  ctl2_reg <= MODULE_DATA_OUT_SELCTION(7 downto 0);
  rx_det_shl_reg <= vio_ctl2(0) when (back2const_regs = '1') else ctl2_reg(0);
  tiles_crc_clear_reg <= vio_ctl2(1) when (back2const_regs = '1') else ctl2_reg(1);
  take_rx_det_msb_reg <= vio_ctl2(2) when (back2const_regs = '1') else ctl2_reg(2);
  take_qp2_reg <= ctl2_reg(3);
  -- !TODO: 20/04/2023 connect   clear_bad_pixels_cnt_reg <= ctl2_reg(4);
  --
  -- V OSUB_EN	     => pipeline_ctl_r(16)
  -- LOG_EN		   => pipeline_ctl_r(15), -- '1', -> MU_CTRL(16)
  -- TCSUB_EN	   => pipeline_ctl_r(17), -- '1', -> MU_CTRL(17)
  -- PASST		   => pipeline_ctl_r(8), -- '0', -> MU_CTRL(18)
  -- ZERO_BAD_POINT => pipeline_ctl_r(18), -- '1', -> MU_CTRL(19)
  -- pipeline_ctl_70 <= (18 => '1', 17 => '1', 16 => MU_CTRL(1), 15 => '1', others => '0');  -- PCREG
  pipeline_ctl_70 <= (18 => MU_CTRL(19), 17 => MU_CTRL(17), 16 => MU_CTRL(1), 15 => MU_CTRL(16),
                      8 => MU_CTRL(18), others => '0');  -- PCREG
  pipeline_ctl_reg <= vio_pipeline_ctl when (back2const_regs = '1') else pipeline_ctl_70;
  AMS_Offset <= vio_ams_offset when (back2const_regs = '1') else CONST_OFST_VAL_TO_MU(15 downto 0);
  CREG_Crst <= vio_CREG_Crst when (back2const_regs = '1') else MU_CTRL(15 downto 12); -- CREG for gain
  ibias <= vio_ibias when (back2const_regs = '1') else MU_CTRL(8 downto 4); -- CREG
  global_ip_time_reg <= vio_global_ip_time when (back2const_regs = '1') else GLOBL_IP_COEF(15 downto 0);
  calib_ctl_reg <= vio_calib_ctl when (back2const_regs = '1') else ASIC_TST_CAL_CTRL_TEST(15 downto 0);
  start_align_reg <= vio_ctl1 when (back2const_regs = '1') else ASIC_DATA_ALIGNMENT(7 downto 0);
  ms_spi_sel <= start_align_reg(1);
  diag_temp_reg <= X"1A"; -- !debug: 24/07/2023 was    when (back2const_regs = '1') else DIAGNSOTICS_TMP(7 downto 0);
  header_dpr_addr <= vio_header_dpr_addr when (back2const_regs = '1') else auto_header_dpr_addr;

  -- synthesis translate_off
  -- start_align_reg(0) <= force << signal .rx_ams_tiles_tb.start_align_reg : std_logic >>; -- !debug: 08/11/2022 replaced by IP, generated in testbench
  -- synthesis translate_on
  -- synthesis translate_on

  misc_ui_clk_pr: process (ui_clk) is
  begin  -- process misc_ui_clk_pr
    if (ui_clk'event and ui_clk = '1') then  -- rising clock edge

      fq_stream_enable_ui_clk <= fq_stream_enable;

    end if;
  end process misc_ui_clk_pr;

  -- dummy footer
  footer_l: for i in 0 to 63 generate -- !debug: 02/05/2023 15 -> 63
    ii: if (i = 0) generate
      footer_bits_dummy(i*8+7 downto i*8) <= X"11";
    elsif (i = 63) generate -- !debug: 02/05/2023 15 -> 63
      footer_bits_dummy(i*8+7 downto i*8) <= X"88";
    else generate
      footer_bits_dummy(i*8+7 downto i*8) <= X"00";
    end generate ii;
  end generate footer_l;

  dummy_header_pr: process (sys_clk, rst_n) is
  begin  -- process dummy_header_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      dummy_header_cnt <= 0;
      dummy_header_data <= (others => '0');
      dummy_header_valid <= '0';
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      -- !debug: 11/12/2022 my work
      -- if (IP50 = '1') then              -- for real header: when header FIFO ready
      --   dummy_header_cnt <= 128;
      -- elsif (dummy_header_cnt /= 0) then
      --   dummy_header_cnt <= dummy_header_cnt - 1;
      -- end if;
      --
      -- if (dummy_header_cnt = 1 or dummy_header_cnt = 128) then
      --   dummy_header_data <= X"FF";
      -- else
      --   dummy_header_data <= X"80";
      -- end if;
      -- !debug: 11/12/2022 for Yossi (in place constants send counter)
      if (IP50 = '1') then              -- for real header: when header FIFO ready
        dummy_header_cnt <= 64;        -- !debug: 19/01/2023 was 128
      elsif (dummy_header_cnt /= 0) then
        dummy_header_cnt <= dummy_header_cnt - 1;
      end if;

      if (dummy_header_cnt /= 0) then
        dummy_header_data <= std_logic_vector(to_unsigned(64 - dummy_header_cnt + 1,dummy_header_data'length)); -- !debug: 19/01/2023 was 128
      else
        dummy_header_data <= X"0000";
      end if;

      if (IP50 = '0' and dummy_header_cnt /= 0) then              -- for real header: when header FIFO ready
        dummy_header_valid <= '1';
      else
        dummy_header_valid <= '0';
      end if;

    end if;
  end process dummy_header_pr;

  fw_ver <= X"000E00EE" when (MULTIBOOT_GOLDEN) else FW_VER_CONST; -- X"00FX" reserved for debug
  board_ver <= (others => '0');


  --  USR_ACCESSE2_inst : USR_ACCESSE2
  --  port map (
  --     CFGCLK => open,       -- 1-bit output: Configuration Clock output
  --     DATA => usr_access_timestamp, -- 32-bit output: Configuration Data output
  --     DATAVALID => open  -- 1-bit output: Active high data valid output
  --  );
  --
  -- -- note: TIMESTAMP: ddddd_MMMM_yyyyyy_hhhhh_mmmmmm_ssssss
  -- --       decoded data_from_timestamp: DDMMYY
  -- data_from_timestamp <= X"00" & "000" & usr_access_timestamp(31 downto 27) & -- DD
  --                        "0000" & usr_access_timestamp(26 downto 23) & -- MM
  --                        "00" & usr_access_timestamp(22 downto 17); -- YY
  --
  -- date_in_bcd_1: date_in_bcd
  --   port map (
  --     bin => data_from_timestamp,
  --     bcd => date_in_bcd_sig
  --   );


end Behavioral;
