-------------------------------------------------------------------------------
-- Title      : remote Flash test
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : remote_flash_tb.vhd
-- Author     : Shinderman Eugene
-- Company    : Philips Medical
-- Created    : 26/09/2023
-- Last update: 17/06/2024
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VComponents.all;


entity remote_flash_tb is
  
end entity remote_flash_tb;


architecture ar of remote_flash_tb is


  component N25Qxxx
     --  generic(
     --      dataDim         : integer := 8;
     --      dummyDim        : integer := 15;
     --      devName         : std_logic_vector(120 downto 1) := ('L', 'H', 'L', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'L', 'L', 'H', 'H', 'L', 'L', 'H', 'L', 'L', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'H', 'H', 'L', 'L', 'L', 'H', 'L', 'L', 'H', 'H', 'L', 'L', 'H', 'L', 'L', 'H', 'L', 'L', 'L', 'L', 'L', 'H', 'L', 'H', 'L', 'L', 'L', 'L', 'H', 'L', 'L', 'H', 'L', 'L', 'L', 'L', 'H', 'L', 'L', 'L', 'H', 'H', 'H', 'L', 'L', 'L', 'L', 'H', 'L', 'L', 'L', 'H', 'L', 'H', 'L', 'L', 'H', 'H', 'L', 'L', 'L', 'L');
     --      addrDim         : integer := 26;
     --      sectorAddrDim   : integer := 10;
     --      Manufacturer_ID : std_logic_vector;
     --      MemoryType_ID   : std_logic_vector;
     --      MemoryCapacity_ID: std_logic_vector;
     --      UID             : std_logic_vector;
     --      EDID_0          : std_logic_vector;
     --      EDID_1          : std_logic_vector;
     --      CFD_0           : std_logic_vector;
     --      CFD_1           : std_logic_vector;
     --      CFD_2           : std_logic_vector;
     --      CFD_3           : std_logic_vector;
     --      CFD_4           : std_logic_vector;
     --      CFD_5           : std_logic_vector;
     --      CFD_6           : std_logic_vector;
     --      CFD_7           : std_logic_vector;
     --      CFD_8           : std_logic_vector;
     --      CFD_9           : std_logic_vector;
     --      CFD_10          : std_logic_vector;
     --      CFD_11          : std_logic_vector;
     --      CFD_12          : std_logic_vector;
     --      CFD_13          : std_logic_vector;
     --      RESET_PIN       : integer := 0;
     --      fC              : integer := 108;
     --      TC              : time;
     --      fC_dtr          : integer := 66;
     --      TC_dtr          : integer := 15;
     --      fR              : integer := 54;
     --      TR              : time;
     --      fR_dtr          : integer := 27;
     --      TR_dtr          : integer := 37;
     --      tCH             : time;
     --      tCL             : time;
     --      tSLCH           : time;
     --      tSHCH           : time;
     --      tHLCH           : time;
     --      tHHCH           : time;
     --      tCH_dtr         : real    := 6.750000;
     --      tCL_dtr         : real    := 6.750000;
     --      tCHSL           : time;
     --      tCHSH           : time;
     --      tSHSL           : time;
     --      tVPPHSL         : time;
     --      tWHSL           : time;
     --      tSLCH_dtr       : real    := 6.750000;
     --      tSHCH_dtr       : real    := 6.750000;
     --      tCHSL_dtr       : real    := 6.750000;
     --      tCHSH_dtr       : real    := 6.750000;
     --      tCLSH           : real    := 3.375000;
     --      tCHDX           : time;
     --      tSHWL           : time;
     --      tCHHH           : time;
     --      tCHHL           : time;
     --      tRLRH           : time;
     --      tSHRH           : time;
     --      tRHSL_1         : time;
     --      tRHSL_2         : time;
     --      tRHSL_3         : time;
     --      tRHSL_4         : time;
     --      tRHSL_5         : time;
     --      tRHSL_6         : time;
     --      tSHQZ           : time;
     --      tCLQV           : time;
     --      tCLQX           : time;
     --      tHHQX           : time;
     --      tHLQZ           : time;
     --      tCHQV           : integer := 6;
     --      tCHQX           : integer := 1;
     --      tDP             : time;
     --      tRDP            : time;
     --      tPP             : time;
     --      tSSE            : time;
     --      t32SSE          : time;
     --      tSE             : time;
     --      tBE             : time;
     --      tDE             : time;
     --      tWNVCR          : time;
     --      tWRASP          : time;
     --      tW              : time;
     --      tWVCR           : time;
     --      tWRVECR         : time;
     --      tCFSR           : time;
     --      tPOTP           : time;
     --      tWREAR          : time;
     --      tEN4AD          : time;
     --      tEX4AD          : time;
     --      tP_latency      : real    := 7.000000;
     --      tSE_latency     : real    := 15.000000;
     --      tSSE_latency    : real    := 15.000000;
     --      write_PMR_delay : real    := 500000.000000;
     --      progSusp_latencyTime: real    := 25000.000000;
     --      eraseSusp_latencyTime: real    := 25000.000000;
     --      tVTR            : time;
     --      tVTW            : time;
     --      program_delay   : time;
     --      program_OTP_delay: time;
     --      program_latency : time;
     --      write_SR_delay  : time;
     --      clear_FSR_delay : time;
     --      write_NVCR_delay: time;
     --      write_ASP_delay : time;
     --      write_VCR_delay : time;
     --      write_VECR_delay: time;
     --      write_EAR_delay : time;
     --      enable4_address_delay: time;
     --      exit4_address_delay: time;
     --      erase_delay     : time;
     --      erase_latency   : time;
     --      erase_bulk_delay: time;
     --      erase_die_delay : time;
     --      full_access_power_up_delay: time;
     --      read_access_power_up_delay: time;
     --      erase_ss_delay  : time;
     --      erase_ss_latency: time;
     --      erase_ss32k_delay: time;
     --      deep_power_down_delay: time;
     --      release_power_down_delay: time;
     --      tPPBP           : time;
     --      tPPBE           : time;
     --      write_PPB_delay : time;
     --      erase_PPB_delay : time;
     --      write_PLB_delay : time;
     --      write_PASSP_delay: time;
     --      tDVCH           : time;
     --      T               : time;
     --      cmdDim          : integer := 8;
     --      addrDimLatch    : integer := 24;
     --      addrDimLatch4   : integer := 32;
     --      colAddrDim      : integer := 8;
     --      -- colAddr_sup     : vl_notype;
     --      -- pageDim         : vl_notype;
     --      -- nSector         : vl_notype;
     --      -- memDim          : vl_notype;
     --      -- sectorAddr_inf  : vl_notype;
     --      EARvalidDim     : integer := 2;
     --      -- sectorAddr_sup  : vl_notype;
     --      -- sectorSize      : vl_notype;
     --      -- subsecAddrDim   : vl_notype;
     --      subsecAddr_inf  : integer := 12;
     --      -- subsecAddr_sup  : vl_notype;
     --      -- subsecSize      : vl_notype;
     --      -- nSSector        : vl_notype;
     --      -- subsec32AddrDim : vl_notype;
     --      subsec32Addr_inf: integer := 15;
     --      -- subsec32Addr_sup: vl_notype;
     --      -- subsec32Size    : vl_notype;
     --      TOP_sector      : integer := 0;
     --      BOTTOM_sector   : integer := 0;
     --      -- pageAddrDim     : vl_notype;
     --      -- pageAddr_inf    : vl_notype;
     --      -- pageAddr_sup    : vl_notype;
     --      OTP_dim         : integer := 65;
     --      OTP_addrDim     : integer := 7;
     --      FDP_dim         : integer := 16384;
     --      FDP_addrDim     : integer := 11;
     --      data_NP         : std_logic_vector;
     --      Vcc_wi          : std_logic_vector(31 downto 0) := ('L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'H', 'L', 'H', 'H', 'H', 'L', 'H', 'H', 'H', 'L', 'L');
     --      Vcc_min         : std_logic_vector(31 downto 0) := ('L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'H', 'L', 'L');
     --      Vcc_max         : std_logic_vector(31 downto 0) := ('L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'H', 'H', 'H', 'H', 'H', 'L', 'H', 'L', 'L', 'L', 'L');
     --      PLRS_1st_x4_byte3: integer := 7;
     --      PLRS_1st_x4_byte4: integer := 9;
     --      PLRS_1st_x2_byte3: integer := 13;
     --      PLRS_1st_x2_byte4: integer := 17;
     --      PLRS_1st_x1_byte3: integer := 25;
     --      PLRS_1st_x1_byte4: integer := 33;
     --      PLRS_2nd        : integer := 8;
     --      rdeasystacken   : std_logic_vector(1 downto 0) := ('L', 'L');
     --      rdeasystacken2  : std_logic_vector(1 downto 0) := ('L', 'L');
     --      NVConfigReg_default: std_logic_vector(15 downto 0) := ('H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H');
     --      memory_file     : std_logic_vector(320 downto 1) := ('L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'H', 'H', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'H', 'L', 'L', 'H', 'L', 'H', 'L', 'H', 'H', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'H', 'H', 'H', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'L', 'H', 'L', 'L', 'H', 'H', 'L', 'L', 'H', 'L', 'L', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'L', 'L', 'H', 'H', 'L', 'H', 'H', 'L', 'L', 'L', 'H', 'L', 'H', 'H', 'H', 'L', 'L', 'H', 'H', 'H', 'L', 'H', 'H', 'L', 'L', 'H', 'H', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'H', 'L', 'L', 'H', 'H', 'L');
     --      fdp_file        : std_logic_vector(384 downto 1) := ('L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'L', 'H', 'H', 'H', 'L', 'L', 'H', 'H', 'L', 'H', 'H', 'L', 'L', 'H', 'H', 'L', 'L', 'H', 'H', 'L', 'L', 'H', 'L', 'L', 'L', 'H', 'H', 'H', 'L', 'L', 'L', 'L', 'L', 'L', 'H', 'L', 'H', 'H', 'H', 'L', 'L', 'H', 'H', 'H', 'L', 'H', 'H', 'L', 'L', 'H', 'H', 'L', 'H', 'H', 'L', 'H', 'L', 'H', 'H', 'L', 'L', 'H', 'H', 'L')
     --  );
      port(
          S               : in    std_logic;
          \C_\            : in    std_logic;
          HOLD_DQ3        : inout std_logic;
          DQ0             : inout std_logic;
          DQ1             : inout std_logic;
          Vcc             : in    std_logic_vector(31 downto 0);
          Vpp_W_DQ2       : inout std_logic;
          RESET2          : in    std_logic
      );
  end component;
  
  component RX_TX_TESTER is
    generic (
      G_DATA_LENGTH : INTEGER;
      DIAGNSOTIC_REGS : BOOLEAN);
    port (
      START_TEST               : IN  STD_LOGIC;
      RST                      : IN  STD_LOGIC;
      RX_IN                    : IN  STD_LOGIC;
      clk_inPLL_p              : IN  std_logic;
      clk_inPLL_n              : IN  std_logic;
      TX_DATA_out              : OUT STD_LOGIC;
      CHANNEL_RDY              : OUT STD_LOGIC;
      STATUS                   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      MU_CTRL                  : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ADD_CONST_OFST_TO_MU     : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      CONST_OFST_VAL_TO_MU     : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ASIC_TST_CAL_CTRL_TEST   : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      TEST_ERROR               : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      WR_TO_TEST_ERROR         : OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      DIAGNSOTICS              : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      GLOBL_IP_COEF            : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      DIAGNSOTICS_TMP          : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      ASIC_DATA_ALIGNMENT      : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      MODULE_DATA_OUT_SELCTION : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_HL               : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_LL               : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PIX_PER_TILE         : IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
      BAD_PACKET_RECEIVED      : IN  STD_LOGIC;
      CRC_ERROR                : IN  STD_LOGIC;
      STD_ERROR                : IN  STD_LOGIC;
      OUT_CLKDIV_50MHz         : OUT STD_LOGIC;
      OUT_FCLK_200MHz          : OUT STD_LOGIC;
      PLL_locked               : out std_logic);
  end component RX_TX_TESTER;

  signal S_START_TEST  : STD_LOGIC ;
  signal rst_n : std_logic := '0';
  signal clk_in : std_logic := '0'; -- @50MHz
  signal MCLK  : std_logic := '0';
  signal CLK1                  : std_logic := '0';

   component Taichi_TMB_top_short is
    generic (
      incr_num : std_logic_vector(31 downto 0) := X"00000000");  -- for tests
    port (
      RESET          : in    std_logic;
      MCLK           : in    std_logic_vector (6 downto 0);
      MCLK_N         : in    std_logic_vector (6 downto 0);
      ACLK_MASTER    : in    std_logic;
      ACLK_MASTER_N  : in    std_logic;
      Sync_P         : in    std_logic;
      Sync_N         : in    std_logic;
      Reg_in_P       : in    std_logic;
      Reg_in_N       : in    std_logic;
      Reg_out_P      : out   std_logic;
      Reg_out_N      : out   std_logic;
      DATA_OUT       : out   std_logic_vector (1 downto 0);
      DATA_OUT_N     : out   std_logic_vector (1 downto 0);
      Sig_2          : in    std_logic;
      Buffer_P       : in    std_logic;
      Buffer_N       : in    std_logic;
      Diag_out_P     : out   std_logic;
      Diag_out_N     : out   std_logic;
      Diag_in_P      : in    std_logic;
      Diag_in_N      : in    std_logic;
      Aux_Sync_P     : out   std_logic;
      Aux_Sync_N     : out   std_logic;
      Aux_Reg_out_P  : out   std_logic;
      Aux_Reg_out_N  : out   std_logic;
      Aux_Reg_in_P   : in    std_logic;
      Aux_Reg_in_N   : in    std_logic;
      AUX_DATA_IN    : in    std_logic_vector (1 downto 0);
      AUX_DATA_IN_N  : in    std_logic_vector (1 downto 0);
      Aux_Sig_2      : out   std_logic;
      Aux_Buffer_P   : out   std_logic;
      Aux_Buffer_N   : out   std_logic;
      Aux_Diag_in_P  : in    std_logic;
      Aux_Diag_in_N  : in    std_logic;
      Aux_Diag_out_P : out   std_logic;
      Aux_Diag_out_N : out   std_logic;
      RESETn         : out   std_logic_vector (3 downto 0);
      ACLK           : out   std_logic_vector (3 downto 0);
      SYNC           : out   std_logic_vector (3 downto 0);
      D_START        : out   std_logic_vector (3 downto 0);
      DISCARD        : out   std_logic_vector (3 downto 0);
      TILES_CLK      : out   std_logic;
      TILES_CLK_N    : out   std_logic;
      SCLK           : out   std_logic_vector (3 downto 0);
      SCS1           : out   std_logic_vector (3 downto 0);
      SCS2           : out   std_logic_vector (3 downto 0);
      SDI            : out   std_logic_vector (3 downto 0);
      SDO            : in    std_logic_vector (3 downto 0);
      ACO            : in    std_logic_vector (3 downto 0);
      ACO_N          : in    std_logic_vector (3 downto 0);
      DATA1          : in    std_logic_vector (3 downto 0);
      DATA1_N        : in    std_logic_vector (3 downto 0);
      DATA2          : in    std_logic_vector (3 downto 0);
      DATA2_N        : in    std_logic_vector (3 downto 0);
      DISABLE_CLK0n  : out   std_logic;
      DISABLE_CLK1n  : out   std_logic;
      DISABLE_SLAVEn : out   std_logic;
      DISABLE_APOSn  : out   std_logic;
      DISABLE_ANEGn  : out   std_logic;
      HW_REV         : in    std_logic_vector (3 downto 0);
      SCL            : inout std_logic_vector (1 downto 0);
      SDA            : inout std_logic_vector (1 downto 0);
      PGOOD_0_75V    : in    std_logic;
      PGOOD_1_0V     : in    std_logic;
      PGOOD_1_5V     : in    std_logic;
      PGOOD_1_8V     : in    std_logic;
      PGOOD_P1_5V    : in    std_logic;
      PGOOD_2_5V     : in    std_logic;
      STATUS_LEDS    : out   std_logic_vector(1 downto 0);
      HEATER_1       : out   std_logic;
      HEATER_2       : out   std_logic;
      SO_FLASH               : in  std_logic;   -- 01/02/2023
      SI_FLASH               : out std_logic;   -- 01/02/2023
      CS_FLASH               : out std_logic;   -- 01/02/2023
      DEBUG_TP       : out   std_logic_vector(7 downto 0);
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
  end component Taichi_TMB_top_short;

  component TX_serial is
    generic (
      NumDataBits : natural := 32;
      cnt_clk_max : natural := 4
      );
    port(
      RESET        : in  std_logic;
      CLK          : in  std_logic;
      serial_out   : out std_logic;
      valid_TX_VEC : in  std_logic_vector (NumDataBits-1 downto 0);
      TRIG         : in  std_logic
      );
  end component;

  signal Sig_2          : std_logic;
  signal PCKT_start            : std_logic:='0';
  signal Diag_in_P, Diag_in_N, Diag_in_i : std_logic;
  signal Diag_out_P, Diag_out_N, Diag_out_i : std_logic;
  signal SO_FLASH, SI_FLASH, CS_FLASH : std_logic;
  signal SCK_FLASH : std_logic := '0';
  signal HOLD_DQ3, Vpp_W_DQ2 : std_logic := '1';
  
begin  -- architecture ar


  S_START_TEST<='0' , '1' AFTER 100 us;

  rst_n <= '0', '1' after 1 US;
  clk_in <= not clk_in after 10 NS; -- 7.8125 for sys_clk64, 15.625 for @32Mhz  24/10/2022 @50MHz
  MCLK <= not MCLK after 2.5 NS;      -- 2.5 @200MHz  !debug: 08/11/2022 temporary uses OSC 3.125 for @160MHz
  CLK1 <= not CLK1 after 10 ns;      -- TMB clock @100MHz !debug: 01/03/2023 now @50MHz

  SCK_FLASH <= << signal .remote_flash_tb.Taichi_TMB_top_1.SCK_FLASH : std_logic >>;

  -- Liron Sig_2 communication
  TX_serial_inst : TX_serial
    generic map (
      NumDataBits => 32,
      cnt_clk_max => 2
      )
    port map(
      RESET        => "not"(rst_n),
      CLK          => CLK1,             -- !debug: 01/03/2023 now 50/cnt_clk_max = @25MHz
      serial_out   => Sig_2,
      valid_TX_VEC => x"00000005", -- x"51242355",
      TRIG         => PCKT_start
      );

  process
  begin
    wait for 40 US;                    -- was 400 US
    for i in 1 to 100 loop
      PCKT_start <= '1';
      wait until CLK1 'event and CLK1 = '1';
      PCKT_start <= '1';
      wait until CLK1 'event and CLK1 = '1';
      PCKT_start <= '0';
      -- wait for 100 US;
    end loop;
  end process;
  
  -- !debug: 17/06/2024 connected only signals, used for registers and Flash
  Taichi_TMB_top_1: Taichi_TMB_top_short
    generic map (
      incr_num => X"000D0001")
    port map (
      RESET          => "not"(rst_n),
      MCLK           => std_logic_vector'(MCLK&MCLK&MCLK&MCLK&MCLK&MCLK&MCLK),
      MCLK_N         => std_logic_vector'("not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)&"not"(MCLK)),
      ACLK_MASTER    => '1',
      ACLK_MASTER_N  => '0',
      Sync_P         => '1',
      Sync_N         =>'0',
      Reg_in_P       => '1',
      Reg_in_N       => '0',
      Reg_out_P      => open,
      Reg_out_N      => open,
      DATA_OUT       => open,
      DATA_OUT_N     => open,
      Sig_2          => Sig_2,
      Buffer_P       => '1',
      Buffer_N       => '0',
      Diag_out_P     => Diag_out_P,
      Diag_out_N     => Diag_out_N,
      Diag_in_P      => Diag_in_P,
      Diag_in_N      => Diag_in_N,
      Aux_Sync_P     => open,
      Aux_Sync_N     => open,
      Aux_Reg_out_P  => open,
      Aux_Reg_out_N  => open,
      Aux_Reg_in_P   => '0',  
      Aux_Reg_in_N   => '1',  
      AUX_DATA_IN    => "00", 
      AUX_DATA_IN_N  => "11", 
      Aux_Sig_2      => open,
      Aux_Buffer_P   => open,
      Aux_Buffer_N   => open,
      Aux_Diag_in_P  => '0',  
      Aux_Diag_in_N  => '1',  
      Aux_Diag_out_P => open,
      Aux_Diag_out_N => open,
      RESETn         => open,
      ACLK           => open,
      SYNC           => open,
      D_START        => open,
      DISCARD        => open,
      TILES_CLK      => open,
      TILES_CLK_N    => open,
      SCLK           => open,
      SCS1           => open,
      SCS2           => open,
      SDI            => open,
      SDO            => X"0",
      ACO            => X"0",
      ACO_N          => X"F",
      DATA1          => X"0",
      DATA1_N        => X"F",
      DATA2          => X"0",
      DATA2_N        => X"F",
      DISABLE_CLK0n  => open,
      DISABLE_CLK1n  => open,
      DISABLE_SLAVEn => open,
      DISABLE_APOSn  => open,
      DISABLE_ANEGn  => open,
      HW_REV         => X"0",
      SCL            => open,           -- I2C IF
      SDA            => open,           -- I2C IF
      PGOOD_0_75V    => '1',
      PGOOD_1_0V     => '1',
      PGOOD_1_5V     => '1',
      PGOOD_1_8V     => '1',
      PGOOD_P1_5V    => '1',
      PGOOD_2_5V     => '1',
      STATUS_LEDS    => open,
      HEATER_1       => open,
      HEATER_2       => open,
      SO_FLASH       => SO_FLASH,       -- !TODO: 17/06/2024 connect
      SI_FLASH       => SI_FLASH,       -- !TODO: 17/06/2024 connect
      CS_FLASH       => CS_FLASH,       -- !TODO: 17/06/2024 connect
        ddr3_addr             => open,
        ddr3_ba               => open,
        ddr3_cas_n            => open,
        ddr3_cke           => open,
        ddr3_cs_n          => open,
        ddr3_dm               => open,
        ddr3_odt           => open,
        ddr3_ras_n            => open,
        ddr3_we_n             => open,
        ddr3_dq               => open,
        ddr3_dqs_p            => open,
        ddr3_dqs_n            => open,
        ddr3_ck_p             => open,
        ddr3_ck_n             => open,
        ddr3_reset_n          => open,
      DEBUG_TP       => open
      );

  Diag_out_inst : IBUFDS
  generic map (
    DIFF_TERM => TRUE, -- Differential Termination
    IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD => "LVDS_25")
  port map (
    O  => Diag_out_i,                    -- Buffer output
    I  => Diag_out_P,                      -- Diff_p buffer input (connect directly to top-level port)
    IB => Diag_out_N                     -- Diff_n buffer input (connect directly to top-level port)
    );


  Diag_in_inst : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Diag_in_P,
      OB => Diag_in_N,
      I  => Diag_in_i          -- Buffer input
      );
  
  -- Diagnsotic Registers tester
  RX_TX_TESTER_2: RX_TX_TESTER
    generic map (
      G_DATA_LENGTH => 32,
      DIAGNSOTIC_REGS => TRUE)
    port map (
      START_TEST               => S_START_TEST,
      RST                      => "not"(rst_n),
      RX_IN                    => Diag_out_i, -- serial RX from Reg_out
      clk_inPLL_p              => MCLK,
      clk_inPLL_n              => "not"(MCLK),
      TX_DATA_out              => Diag_in_i, -- serial TX to Reg_in
      CHANNEL_RDY              => open,     -- !debug: 04/04/2023 check if align OK
      STATUS                   => open,
      MU_CTRL                  => (others => '0'),
      ADD_CONST_OFST_TO_MU     => (others => '0'),
      CONST_OFST_VAL_TO_MU     => (others => '0'),
      ASIC_TST_CAL_CTRL_TEST   => (others => '0'),
      TEST_ERROR               => (others => '0'),
      WR_TO_TEST_ERROR         => open,
      DIAGNSOTICS              => (others => '0'),
      GLOBL_IP_COEF            => (others => '0'),
      DIAGNSOTICS_TMP          => (others => '0'),
      ASIC_DATA_ALIGNMENT      => (others => '0'),
      MODULE_DATA_OUT_SELCTION => (others => '0'),
      BAD_PIX_HL               => (others => '0'),
      BAD_PIX_LL               => (others => '0'),
      BAD_PIX_PER_TILE         => (others => '0'),
      BAD_PACKET_RECEIVED      => '0',
      CRC_ERROR                => '0',
      STD_ERROR                => '0',
      OUT_CLKDIV_50MHz         => open,
      OUT_FCLK_200MHz          => open,
      PLL_locked               => open
    );
  

  N25Qxxx_1: N25Qxxx
    -- generic map (
    --   dataDim                    => 8,
    --   dummyDim                   => 15,
    --   devName                    => devName,
    --   addrDim                    => addrDim,
    --   sectorAddrDim              => sectorAddrDim,
    --   Manufacturer_ID            => X"20",
    --   MemoryType_ID              => X"BA",
    --   MemoryCapacity_ID          => X"20",
    --   UID                        => UID,
    --   EDID_0                     => EDID_0,
    --   EDID_1                     => EDID_1,
    --   CFD_0                      => CFD_0,
    --   CFD_1                      => CFD_1,
    --   CFD_2                      => CFD_2,
    --   CFD_3                      => CFD_3,
    --   CFD_4                      => CFD_4,
    --   CFD_5                      => CFD_5,
    --   CFD_6                      => CFD_6,
    --   CFD_7                      => CFD_7,
    --   CFD_8                      => CFD_8,
    --   CFD_9                      => CFD_9,
    --   CFD_10                     => CFD_10,
    --   CFD_11                     => CFD_11,
    --   CFD_12                     => CFD_12,
    --   CFD_13                     => CFD_13,
    --   RESET_PIN                  => RESET_PIN,
    --   fC                         => fC,
    --   TC                         => TC,
    --   fC_dtr                     => fC_dtr,
    --   TC_dtr                     => TC_dtr,
    --   fR                         => fR,
    --   TR                         => TR,
    --   fR_dtr                     => fR_dtr,
    --   TR_dtr                     => TR_dtr,
    --   tCH                        => tCH,
    --   tCL                        => tCL,
    --   tSLCH                      => tSLCH,
    --   tSHCH                      => tSHCH,
    --   tHLCH                      => tHLCH,
    --   tHHCH                      => tHHCH,
    --   tCH_dtr                    => tCH_dtr,
    --   tCL_dtr                    => tCL_dtr,
    --   tCHSL                      => tCHSL,
    --   tCHSH                      => tCHSH,
    --   tSHSL                      => tSHSL,
    --   tVPPHSL                    => tVPPHSL,
    --   tWHSL                      => tWHSL,
    --   tSLCH_dtr                  => tSLCH_dtr,
    --   tSHCH_dtr                  => tSHCH_dtr,
    --   tCHSL_dtr                  => tCHSL_dtr,
    --   tCHSH_dtr                  => tCHSH_dtr,
    --   tCLSH                      => tCLSH,
    --   tCHDX                      => tCHDX,
    --   tSHWL                      => tSHWL,
    --   tCHHH                      => tCHHH,
    --   tCHHL                      => tCHHL,
    --   tRLRH                      => tRLRH,
    --   tSHRH                      => tSHRH,
    --   tRHSL_1                    => tRHSL_1,
    --   tRHSL_2                    => tRHSL_2,
    --   tRHSL_3                    => tRHSL_3,
    --   tRHSL_4                    => tRHSL_4,
    --   tRHSL_5                    => tRHSL_5,
    --   tRHSL_6                    => tRHSL_6,
    --   tSHQZ                      => tSHQZ,
    --   tCLQV                      => tCLQV,
    --   tCLQX                      => tCLQX,
    --   tHHQX                      => tHHQX,
    --   tHLQZ                      => tHLQZ,
    --   tCHQV                      => tCHQV,
    --   tCHQX                      => tCHQX,
    --   tDP                        => tDP,
    --   tRDP                       => tRDP,
    --   tPP                        => tPP,
    --   tSSE                       => tSSE,
    --   t32SSE                     => t32SSE,
    --   tSE                        => tSE,
    --   tBE                        => tBE,
    --   tDE                        => tDE,
    --   tWNVCR                     => tWNVCR,
    --   tWRASP                     => tWRASP,
    --   tW                         => tW,
    --   tWVCR                      => tWVCR,
    --   tWRVECR                    => tWRVECR,
    --   tCFSR                      => tCFSR,
    --   tPOTP                      => tPOTP,
    --   tWREAR                     => tWREAR,
    --   tEN4AD                     => tEN4AD,
    --   tEX4AD                     => tEX4AD,
    --   tP_latency                 => tP_latency,
    --   tSE_latency                => tSE_latency,
    --   tSSE_latency               => tSSE_latency,
    --   write_PMR_delay            => write_PMR_delay,
    --   progSusp_latencyTime       => progSusp_latencyTime,
    --   eraseSusp_latencyTime      => eraseSusp_latencyTime,
    --   tVTR                       => tVTR,
    --   tVTW                       => tVTW,
    --   program_delay              => program_delay,
    --   program_OTP_delay          => program_OTP_delay,
    --   program_latency            => program_latency,
    --   write_SR_delay             => write_SR_delay,
    --   clear_FSR_delay            => clear_FSR_delay,
    --   write_NVCR_delay           => write_NVCR_delay,
    --   write_ASP_delay            => write_ASP_delay,
    --   write_VCR_delay            => write_VCR_delay,
    --   write_VECR_delay           => write_VECR_delay,
    --   write_EAR_delay            => write_EAR_delay,
    --   enable4_address_delay      => enable4_address_delay,
    --   exit4_address_delay        => exit4_address_delay,
    --   erase_delay                => erase_delay,
    --   erase_latency              => erase_latency,
    --   erase_bulk_delay           => erase_bulk_delay,
    --   erase_die_delay            => erase_die_delay,
    --   full_access_power_up_delay => full_access_power_up_delay,
    --   read_access_power_up_delay => read_access_power_up_delay,
    --   erase_ss_delay             => erase_ss_delay,
    --   erase_ss_latency           => erase_ss_latency,
    --   erase_ss32k_delay          => erase_ss32k_delay,
    --   deep_power_down_delay      => deep_power_down_delay,
    --   release_power_down_delay   => release_power_down_delay,
    --   tPPBP                      => tPPBP,
    --   tPPBE                      => tPPBE,
    --   write_PPB_delay            => write_PPB_delay,
    --   erase_PPB_delay            => erase_PPB_delay,
    --   write_PLB_delay            => write_PLB_delay,
    --   write_PASSP_delay          => write_PASSP_delay,
    --   tDVCH                      => tDVCH,
    --   T                          => T,
    --   cmdDim                     => cmdDim,
    --   addrDimLatch               => addrDimLatch,
    --   addrDimLatch4              => addrDimLatch4,
    --   colAddrDim                 => colAddrDim,
    --   EARvalidDim                => EARvalidDim,
    --   subsecAddr_inf             => subsecAddr_inf,
    --   subsec32Addr_inf           => subsec32Addr_inf,
    --   TOP_sector                 => TOP_sector,
    --   BOTTOM_sector              => BOTTOM_sector,
    --   OTP_dim                    => OTP_dim,
    --   OTP_addrDim                => OTP_addrDim,
    --   FDP_dim                    => FDP_dim,
    --   FDP_addrDim                => FDP_addrDim,
    --   data_NP                    => data_NP,
    --   Vcc_wi                     => Vcc_wi,
    --   Vcc_min                    => Vcc_min,
    --   Vcc_max                    => Vcc_max,
    --   PLRS_1st_x4_byte3          => PLRS_1st_x4_byte3,
    --   PLRS_1st_x4_byte4          => PLRS_1st_x4_byte4,
    --   PLRS_1st_x2_byte3          => PLRS_1st_x2_byte3,
    --   PLRS_1st_x2_byte4          => PLRS_1st_x2_byte4,
    --   PLRS_1st_x1_byte3          => PLRS_1st_x1_byte3,
    --   PLRS_1st_x1_byte4          => PLRS_1st_x1_byte4,
    --   PLRS_2nd                   => PLRS_2nd,
    --   rdeasystacken              => rdeasystacken,
    --   rdeasystacken2             => rdeasystacken2,
    --   NVConfigReg_default        => NVConfigReg_default,
    --   memory_file                => memory_file,
    --   fdp_file                   => fdp_file)
    port map (
      S         => CS_FLASH,
      \C_\      => SCK_FLASH,
      HOLD_DQ3  => HOLD_DQ3,
      DQ0       => SI_FLASH,
      DQ1       => SO_FLASH,
      Vcc       => X"00000708",         -- 1800 to HEX
      Vpp_W_DQ2 => Vpp_W_DQ2,
      RESET2    => '1'
      );
  
end architecture ar;
