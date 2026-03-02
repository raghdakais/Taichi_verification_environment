
package ddr3_model_pack is


  -- DDR3 IP parameters
  constant COL_WIDTH                     : natural   := 10;         -- # of memory Column Address bits. !debug: 19/09/2022 was 11
  constant CS_WIDTH                      : natural   := 1;          -- # of unique CS outputs to memory.
  constant DM_WIDTH                      : natural   := 1;          -- # of DM (data mask)
  constant DQ_WIDTH                      : natural   := 8;          -- # of DQ (data)
  constant DQS_WIDTH                     : natural   := 1;
  constant DQS_CNT_WIDTH                 : natural   := 1;          -- := ceil(log2(DQS_WIDTH))
  constant DRAM_WIDTH                    : natural   := 8;          -- # of DQ per DQS
  constant ECC                           : string    := "OFF";
  constant RANKS                         : natural   := 1;          -- # of Ranks.
  constant ODT_WIDTH                     : natural   := 1;          -- # of ODT outputs to memory.
  constant ROW_WIDTH                     : natural   := 16;         -- # of memory Row Address bits.
  constant ADDR_WIDTH                    : natural   := 30;         -- # = RANK_WIDTH + BANK_WIDTH  !debug: 19/09/2022 was 31
                                                                    --  + ROW_WIDTH + COL_WIDTH;
                                                                    -- Chip Select is always tied to low for
                                                                    -- single rank devices

  -- The following parameters are mode register settings
  constant BURST_MODE                    : string    := "8";        -- DDR3 SDRAM:
  -- Burst Length (Mode Register 0).
  -- # = "8", "4", "OTF".
  -- DDR2 SDRAM:
  -- Burst Length (Mode Register).
  -- # = "8", "4".
  -- constant CA_MIRROR : string := "OFF"; -- C/A mirror opt for DDR3 dual rank
  constant CA_MIRROR                     : natural   := 0;          -- C/A mirror opt for DDR3 dual rank: 0 - OFF, 1 - ON

  constant CLKIN_PERIOD                  : time      := 5.000 NS; -- Input Clock Period
                                                                 -- !debug: 19/09/2022 was 10.000 NS

  constant SIM_BYPASS_INIT_CAL           : string    := "FAST";
                                        -- # = "SIM_INIT_CAL_FULL" -  Complete
                                        --              memory init &
                                        --              calibration sequence
                                        -- # = "SKIP" - Not supported
                                        -- # = "FAST" - Complete memory init & use
                                        --              abbreviated calib sequence

  -- clock, IODELAY and PHY related parameters
  constant TCQ                           : natural   := 100;
  constant RST_ACT_LOW                   : natural   := 1;          -- =1 for active low reset, =0 for active high.
  constant REFCLK_FREQ                   : natural   := 200;        -- IODELAYCTRL reference clock frequency
  constant tCK                           : natural   := 3077;       -- memory tCK paramter, Clock Period in pS.
                                                                  -- !debug: 31/08/2022 3077 was 3125
  constant nCK_PER_CLK                   : natural   := 4;          -- # of memory CKs per fabric CLK
                                                                  -- !debug: 31/08/2022 was 2

  -- Slave AXI4 Interface
  constant C_S_AXI_ID_WIDTH              : natural   := 4;          -- Width of all master and slave ID signals.
                                                                    -- # = >= 1.
  constant C_S_AXI_ADDR_WIDTH            : natural   := 29;         -- Width of S_AXI_AWADDR, S_AXI_ARADDR, M_AXI_AWADDR and
                                                                  -- !debug: 31/08/2022 was 30
                                                                    -- M_AXI_ARADDR for all SI/MI slots.
                                                                    -- # = 32.
  constant C_S_AXI_DATA_WIDTH            : natural   := 32;         -- Width of WDATA and RDATA on SI slot.
                                                                    -- Must be <= APP_DATA_WIDTH.
                                                                    -- # = 32, 64, 128, 256.
  constant C_S_AXI_SUPPORTS_NARROW_BURST : natural   := 0;          -- Indicates whether to instatiate upsizer
                                                                    -- Range: 0, 1
  -- Debug and Internal parameters
  constant DEBUG_PORT                    : string    := "OFF";      -- # "ON" Enable debug signals/controls, "OFF" Disable debug signals/controls.
  constant DRAM_TYPE                     : string    := "DDR3";

  constant TPROP_DQS                     : real      := 0.00;       -- Delay for DQS signal during Write Operation
  constant TPROP_DQS_RD                  : real      := 0.00;       -- Delay for DQS signal during Read Operation
  constant TPROP_PCB_CTRL                : time      := 0 NS;       -- Delay for Address and Ctrl signals
  constant TPROP_PCB_DATA                : real      := 0.00;       -- Delay for data signal during Write operation
  constant TPROP_PCB_DATA_RD             : real      := 0.00;       -- Delay for data signal during Read operation
  constant MEMORY_WIDTH                  : natural   := 8;
  constant NUM_COMP                      : natural   := DQ_WIDTH/MEMORY_WIDTH;
  constant ECC_TEST                      : string    := "OFF";
  constant ERR_INSERT                    : string    := "OFF";      --  (ECC_TEST == "ON") ? "OFF" : ECC ;


  constant REFCLK_PERIOD                 : time      := (1000 NS/(2*REFCLK_FREQ));
  constant RESET_PERIOD                  : natural   := 200000;     -- in pSec
  constant SYSCLK_PERIOD                 : natural   := tCK;


end package ddr3_model_pack;
