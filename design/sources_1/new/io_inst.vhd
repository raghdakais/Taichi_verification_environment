-------------------------------------------------------------------------------
-- Title      : I/O instantiations
-- Project    : Taichi module board, TMB
-------------------------------------------------------------------------------
-- File       : io_inst.vhd
-- Author     : Shinderman Eugene  <eu1@localhost-localdomain>
-- Company    : HBtech
-- Created    : 03/11/2022
-- Last update: 04/09/2024
-- Platform   : Vivado v.2018.2, Device : xc7s75fgga484-2
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: Xilinx I/O instantiations
-------------------------------------------------------------------------------
-- Copyright (c) 2022
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 03/11/2022  1.0      eu1 only synthetic data
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;


entity io_inst is
  port (
    reset          : in  std_logic;
    MCLK           : in  std_logic_vector (6 downto 0);  -- @200MHZ from clock buffer
    MCLK_N         : in  std_logic_vector (6 downto 0);
    ACLK_MASTER    : in  std_logic;                      -- AclkP/N in connector -> buffer
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
    Sync_P         : in  std_logic;                      -- 13/10/2021 seems SyncP/N in connector -> CTL(0)
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
    -- DDR3_SYS_CLK   : in  std_logic;                      -- 04/11/2019 from loopback
    -- DDR3_SYS_CLK_N : in  std_logic;                      -- 04/11/2019 from loopback
    Aux_buffer_byte   : in  std_logic_vector(7 downto 0);  -- 07/11/2022
    Aux_diag_out_byte : in  std_logic_vector(7 downto 0);
    Aux_Sync_byte     : in  std_logic_vector(7 downto 0);
    Aux_Reg_out_byte  : in  std_logic_vector(7 downto 0);
    -- Reg_out_byte      : in  std_logic_vector(7 downto 0);
    -- Reg_in_byte       : out std_logic_vector(7 downto 0);
    Reg_in_i     : out std_logic;       -- 08/12/2022
    -- Sync_byte         : out std_logic_vector(7 downto 0);
    Sync_i     : out std_logic;       -- 13/12/2022
    -- Buffer_byte       : out std_logic_vector(7 downto 0);
    RX_ERRs_buffer : out std_logic_vector(3 downto 0);
    buf_ptr_address_from_buffer : out std_logic_vector(31 downto 0); -- 21/09/2023
    stream_ctrl_from_buffer : out std_logic_vector(7 downto 0);     -- 21/09/2023
    buffer_req_valid : out std_logic;      -- 14/12/2022
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
    -- PLL_CLKOUT     : out std_logic;                      -- clock loopback to DDR3 I/O bank
    -- PLL_CLKOUT_N   : out std_logic;
    channel_RDY    : out std_logic;
    clk_div        : in  std_logic;                      -- !TODO: 03/11/2022 must be same as TX_series7.CLKDIV ?
    TX_DATA_out     : in  std_logic;
    debug2_sig     : in  std_logic;
    debug3_sig     : in  std_logic;
    ACLK_and_TILES_CLK_EN : in std_logic;                               -- 24/04/2023
    io_inst_tp : out std_logic_vector(1 downto 0)
    );
end io_inst;

architecture ar of io_inst is

  -- component BUFG is
  --   port(
  --     O : out std_ulogic;
  --
  --     I : in  std_ulogic
  --     );
  -- end component;

  component CLK0_PLL
    port
      (                                                         -- Clock in ports
        -- Clock out ports
        CLK200_ref   : out std_logic;
        CLK160    : out std_logic;
        CLK20     : out std_logic;
        -- Status and control signals
        locked    : out std_logic;
        clk_in1_p : in  std_logic;
        clk_in1_n : in  std_logic
        );
  end component;

  component CLK1_PLL
    port
      (                                                         -- Clock in ports
        -- Clock out ports
        CLK200    : out std_logic;
        CLK80     : out std_logic;
        CLK50     : out std_logic;
        -- Status and control signals
        locked    : out std_logic;
        clk_in1_p : in  std_logic;
        clk_in1_n : in  std_logic
        );
  end component;

  component CLK2_PLL
    port
      (                                                         -- Clock in ports
        -- Clock out ports
        CLK200    : out std_logic;
        CLK80     : out std_logic;
        -- Status and control signals
        locked    : out std_logic;
        clk_in1_p : in  std_logic;
        clk_in1_n : in  std_logic
        );
  end component;

  component clk_wiz_0 is
    port (
      clk_out1  : out std_logic;
      clk_out2  : out std_logic;
      clk_out3  : out std_logic;
      clk_out4  : out std_logic;
      reset     : in  std_logic;
      locked    : out std_logic;
      clk_in1_p : in  std_logic;
      clk_in1_n : in  std_logic);
  end component clk_wiz_0;

  component selectio_rx is
    port (
      data_in_from_pins_p : in  std_logic_vector (0 to 0);
      data_in_from_pins_n : in  std_logic_vector (0 to 0);
      data_in_to_device   : out std_logic_vector (7 downto 0);
      in_delay_reset      : in  std_logic;
      in_delay_data_ce    : in  std_logic_vector (0 to 0);
      in_delay_data_inc   : in  std_logic_vector (0 to 0);
      in_delay_tap_in     : in  std_logic_vector (4 downto 0);  -- when VAR_LOAD
      in_delay_tap_out    : out std_logic_vector (4 downto 0);  -- when VAR_LOAD
      bitslip             : in  std_logic_vector (0 to 0);
      clk_in              : in  std_logic;
      clk_div_in          : in  std_logic;
      io_reset            : in  std_logic
      );
  end component selectio_rx;

  -- component selectio_tx is
  --   port (
  --     data_out_from_device : in  std_logic_vector (7 downto 0);
  --     data_out_to_pins_p   : out std_logic_vector (0 to 0);
  --     data_out_to_pins_n   : out std_logic_vector (0 to 0);
  --     clk_in               : in  std_logic;
  --     clk_div_in           : in  std_logic;
  --     io_reset             : in  std_logic
  --     );
  -- end component;

  -- component IBUFDS
  --   generic (
  --     CAPACITANCE      : string  := "DONT_CARE";
  --     CCIO_EN_M        : string  := "TRUE";
  --     CCIO_EN_S        : string  := "TRUE";
  --     DIFF_TERM        : boolean := FALSE;
  --     DQS_BIAS         : string  := "FALSE";
  --     IBUF_DELAY_VALUE : string  := "0";
  --     IBUF_LOW_PWR     : boolean := TRUE;
  --     IFD_DELAY_VALUE  : string  := "AUTO";
  --     IOSTANDARD       : string  := "DEFAULT"
  --     );
  --   port (
  --     O  : out std_ulogic;
  --     I  : in  std_ulogic;
  --     IB : in  std_ulogic
  --     );
  -- end component;
  --
  -- component OBUFDS
  --   generic (
  --     CAPACITANCE : string := "DONT_CARE";
  --     IOSTANDARD  : string := "DEFAULT";
  --     SLEW        : string := "SLOW"
  --     );
  --   port (
  --     O  : out std_ulogic;
  --     OB : out std_ulogic;
  --     I  : in  std_ulogic
  --     );
  -- end component;
  --
  -- component IDELAYCTRL
  --   generic (
  --     SIM_DEVICE : string := "7SERIES"
  --     );
  --   port (
  --     RDY    : out std_ulogic;
  --     REFCLK : in  std_ulogic;
  --     RST    : in  std_ulogic
  --     );
  -- end component;

  signal CLK192                     : std_logic;
  signal CLK64                      : std_logic;
  signal CLK200_ext, CLK200_ext_buf : std_logic;

  signal CLK200_at, CLK80_at : std_logic_vector(6 downto 3);
  signal CLK200_at_sig, CLK80_at_sig : std_logic_vector(6 downto 3);

  signal clk200_aux, clk200_aux_buf, clk50_aux : std_logic; -- 16/03/2022
  signal div4_aux_cnt : natural range 0 to 3 := 0;

  signal AUX_DATA_IN_i : std_logic_vector(1 downto 0);

  signal in_delay_reset : STD_LOGIC;
  signal in_delay_data_ce : STD_LOGIC_VECTOR ( 0 to 0 );
  signal in_delay_data_inc : STD_LOGIC_VECTOR ( 0 to 0 );
  signal in_delay_tap_in   : STD_LOGIC_VECTOR (4 downto 0); -- when VAR_LOAD
  signal in_delay_tap_out  : STD_LOGIC_VECTOR (4 downto 0); -- when VAR_LOAD
  signal CLK80             : std_logic;
  signal CLK200            : std_logic;
  signal CLK50             : std_logic;

  signal aclk_i : std_logic;
  signal aclk_master_i_int : std_logic;
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
      RX_ERRs              : out std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
      );
  end component RX_series7;

  signal Buffer_i, buffer_req_valid_i : std_logic;          -- , buffer_channel_RDY
  signal watchdog_cnt : natural range 0 to 2**20;
  signal idelayctrl_rdy, idelayctrl_rdy_r : std_logic;
  signal channel_RDY_delay_cnt : natural range 0 to 255 := 0;
  signal incr_RDY_delay_cnt : std_logic := '0';
  signal pll_lock2aclk_cnt : natural range 0 to 2**30 := 0;
  signal clk_locked_i : std_logic;
  signal lock2aclk_stop : boolean := FALSE;

  -- !debug: 18/12/2022
  signal aclk_50m, aclk_50m_r,aclk_50m_rr, buffer_good_packet_received, buffer_bad_packet_received : std_logic;
  signal aclk_period_cnt, aclk_period_saved, aclk_filter_cnt : natural range 0 to 1023 := 0;
  signal aclk_rise_detect : boolean := FALSE;

  signal buffer_data_valid : std_logic;
  signal buffer_byte : std_logic_vector(7 downto 0);
  signal buffer_payload : std_logic_vector(8*8-1 downto 0); -- as rx_serdes_buffer.NumDataBytes
  signal short_pulse_cnt : natural range 0 to 7;

 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of aclk_50m, aclk_period_saved, buffer_good_packet_received, buffer_bad_packet_received, pll_lock2aclk_cnt : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of aclk_50m, aclk_period_saved, buffer_good_packet_received, buffer_bad_packet_received, pll_lock2aclk_cnt : signal is "true";

begin


  CLK0_PLL_inst : CLK0_PLL
    port map (
      -- Clock out ports
      CLK200_ref => CLK200_ref, -- idelayctrl.refclk
      CLK160    => CLK160, -- tiles
      CLK20     => CLK20,  -- tile RX byte clock
      -- Status and control signals
      locked    => open,
      -- Clock in ports
      clk_in1_p => MCLK(0), -- bank 15 (tiles 2.5V)
      clk_in1_n => MCLK_N(0)
      );
  --------------------------------
  CLK1_PLL_inst : CLK1_PLL
    port map (
      -- Clock out ports
      CLK200    => CLK200, -- DDR3 ref_clk
      CLK80     => open, -- !debug: 04/11/2019 was   CLK80, -- DDR3 sys_clk
      CLK50     => CLK50, -- sys_clk
      -- Status and control signals
      locked    => clk_locked_i,
      -- Clock in ports
      clk_in1_p => MCLK(1), -- bank 16 (main connector)
      clk_in1_n => MCLK_N(1)
      );

  clk_locked <= clk_locked_i;


     BUFG_inst : BUFG
   port map (
   O =>aclk_master_i_int , -- 1-bit output: Clock output
   I =>aclk_i  -- 1-bit input: Clock input
   );

  -- !debug: 03/01/2022 temporary disabled, if use xapp523 RX
  CLK2_PLL_inst : CLK2_PLL
    port map (
      -- Clock out ports
      CLK200    => CLK200A, -- NU
      CLK80     => CLK80, -- 04/11/2019
      -- Status and control signals
      locked    => open,
      -- Clock in ports
      clk_in1_p => MCLK(2), -- bank 35 (near DDR3 bank)
      clk_in1_n => MCLK_N(2)
      );

  -- !debug: 19/01/2022 reserved clocks
  tmp_clk_array_g : for i in 3 to 4 generate

    CLK36_PLL_inst : CLK2_PLL
      port map (
        -- Clock out ports
        CLK200    => CLK200_at(i),      -- NU
        CLK80     => CLK80_at(i),       -- 04/11/2019
        -- Status and control signals
        locked    => open,
        -- Clock in ports
        clk_in1_p => MCLK(i),           -- bank 35 (near DDR3 bank)
        clk_in1_n => MCLK_N(i)
        );

    tmp_clk200_at_array_pr : process (CLK200_at(i)) is
    begin  -- process tmp_clk_array_pr
      if (CLK200_at(i)'EVENT and CLK200_at(i) = '1') then  -- rising clock edge
        CLK200_at_sig(i) <= not CLK80_at_sig(i);
      end if;
    end process tmp_clk200_at_array_pr;

    tmp_clk80_at_array_pr : process (CLK80_at(i)) is
    begin  -- process tmp_clk_array_pr
      if (CLK80_at(i)'EVENT and CLK80_at(i) = '1') then  -- rising clock edge
        CLK80_at_sig(i) <= not CLK200_at_sig(i);
      end if;
    end process tmp_clk80_at_array_pr;

  end generate tmp_clk_array_g;

  -- !debug: 16/03/2022 clock for SERDES'es in AUX
  mclk6_in : IBUFDS
    generic map (
      DIFF_TERM    => False,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => clk200_aux,                   -- Buffer output
      I  => MCLK(6),                      -- Diff_p buffer input (connect directly to top-level port)
      IB => MCLK_N(6)                     -- Diff_n buffer input (connect directly to top-level port)
      );

   mclk6_buf : BUFG
   port map (
      O => clk200_aux_buf, -- 1-bit output: Clock output
      I => clk200_aux  -- 1-bit input: Clock input
   );

  ddr3_sys_clk_p <= MCLK(5);
  ddr3_sys_clk_n <= MCLK_N(5);

  misc_aux_pr: process (clk200_aux_buf) is
  begin  -- process misc_aux_pr
    if (clk200_aux_buf'event and clk200_aux_buf = '1') then  -- rising clock edge

      div4_aux_cnt <= (div4_aux_cnt + 1) mod 4;

      if (div4_aux_cnt > 1) then
        clk50_aux <= '1';
      else
        clk50_aux <= '0';
      end if;

    end if;
  end process misc_aux_pr;


  -- clk_wiz_0_1: clk_wiz_0
  --   port map (
  --     clk_out1  => ACLK(0),
  --     clk_out2  => ACLK(1),
  --     clk_out3  => ACLK(2),
  --     clk_out4  => ACLK(3),
  --     reset     => reset,
  --     locked    => open,
  --     clk_in1_p => ACLK_MASTER,         -- !TODO: 27/12/2021 replace to same as in TMCOR v.6
  --     clk_in1_n => ACLK_MASTER_N
  --   );

  aclk_master_in : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => aclk_i,                   -- Buffer output
      I  => ACLK_MASTER,                      -- Diff_p buffer input (connect directly to top-level port)
      IB => ACLK_MASTER_N                     -- Diff_n buffer input (connect directly to top-level port)
      );

  aclk_master_i<=aclk_50m; -- !debug: 04/09/2024 was   aclk_master_i_int;

  misc_pr: process (clk50) is
  begin  -- process misc_pr
    if (clk50'event and clk50 = '1') then  -- rising clock edge

      aclk_50m <= aclk_master_i_int;
      aclk_50m_r <= aclk_50m;           -- !debug: 05/01/2023 add ACLK filter 1.5e-6/20e-9=75
      aclk_50m_rr <= aclk_50m_r;
      -- !debug: 08/01/2023
      --   - was: wait ACLK rise -> {open ~1 uS window,check window} -> if ACLK rise was long time ago set incr_RDY_delay_cnt
      --     problem: this solution prevent fast increments, but not prevent false increments
      --   - new: open 2 uS window -> wait ACLK rise -> set aclk_rise_detect -> wait ACLK rise -> if window /= 0 ignore, else set incr_RDY_delay_cnt
      --
      -- if (aclk_50m_r = '0' and aclk_50m = '1') then
      --   aclk_filter_cnt <= 63;
      --   if (aclk_period_saved /= 0 and aclk_filter_cnt = 0) then
      --     incr_RDY_delay_cnt <= '1';    -- else ACLK rise filtered
      --     lock2aclk_stop <= TRUE;       -- ACLK stable
      --   else
      --     incr_RDY_delay_cnt <= '0';
      --   end if;
      --   -- lock2aclk_stop <= TRUE; -- 1st ACLK edge
      -- elsif (aclk_filter_cnt /= 0) then
      --   aclk_filter_cnt <= aclk_filter_cnt - 1;
      --   incr_RDY_delay_cnt <= '0';
      -- end if;
      if (aclk_50m_rr = '0' and aclk_50m_r = '1') then
        if (not aclk_rise_detect) then
          aclk_filter_cnt <= 100;
        end if;
        aclk_rise_detect <= not aclk_rise_detect;
        if (aclk_period_saved /= 0 and aclk_filter_cnt = 0) then
          incr_RDY_delay_cnt <= '1';    -- else ACLK rise filtered
          lock2aclk_stop <= TRUE;       -- ACLK stable
        else
          incr_RDY_delay_cnt <= '0';
        end if;
      elsif (aclk_filter_cnt /= 0) then
        aclk_filter_cnt <= aclk_filter_cnt - 1;
        incr_RDY_delay_cnt <= '0';
      end if;

      if (aclk_50m_rr = '0' and aclk_50m_r = '1') then
        aclk_period_saved <= aclk_period_cnt; --  measured ACLK period for test
        aclk_period_cnt <= 0;
      elsif (aclk_period_cnt < 1023) then
        aclk_period_cnt <= aclk_period_cnt + 1;
      end if;

      idelayctrl_rdy_r <= idelayctrl_rdy;
      if (idelayctrl_rdy_r = '0') then
        channel_RDY_delay_cnt <= 0;
      -- elsif (aclk_50m_r = '0' and aclk_50m = '1') then
      elsif (incr_RDY_delay_cnt = '1') then
        if (channel_RDY_delay_cnt < 255) then
          channel_RDY_delay_cnt <= channel_RDY_delay_cnt + 1;
        end if;
      end if;

      if (channel_RDY_delay_cnt > 224) then
        channel_RDY <= '1';
      -- synthesis translate_off
      elsif (channel_RDY_delay_cnt > 20) then -- only for simulation
        channel_RDY <= '1';
      -- synthesis translate_on
      else
        channel_RDY <= '0';
      end if;

      if (clk_locked_i = '1' and not lock2aclk_stop) then
        if (pll_lock2aclk_cnt < 2**30) then
          pll_lock2aclk_cnt <= pll_lock2aclk_cnt + 1; -- time from PLL lock to 1st ACLK
        end if;
      end if;


    end if;
  end process misc_pr;

  -- -- 03/11/2019
  -- OBUFDS_clk_loop : OBUFDS
  --   generic map (
  --     IOSTANDARD => "DEFAULT",        -- Specify the output I/O standard
  --     SLEW       => "SLOW")           -- Specify the output slew rate
  --   port map (
  --     O  => PLL_CLKOUT,                -- Diff_p output (connect directly to top-level port)
  --     OB => PLL_CLKOUT_N,              -- Diff_n output (connect directly to top-level port)
  --     I  => CLK80                      -- Buffer input
  --     );

  -- -- 04/11/2019
  -- IBUFDS_clk_loop : IBUFDS
  -- generic map (
  --   DIFF_TERM    => FALSE,            -- Differential Termination
  --   IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
  --   IOSTANDARD   => "LVDS_25")
  -- port map (
  --   O  => CLK200_ext,                    -- Buffer output
  --   I  => DDR3_SYS_CLK,               -- bank 34 (DDR3)
  --   IB => DDR3_SYS_CLK_N
  --   );
  --
  -- CLK200_PLL_ext_BUFG_inst : BUFG
  -- port map (
  --    O => CLK200_ext_buf, -- 1-bit output: Clock output
  --    I => CLK200_ext  -- 1-bit input: Clock input
  -- );


  -- !debug: 29/07/2019 DPU interface
    mod_1_data_aux_in0_inst : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => AUX_DATA_IN_i(0),                    -- Buffer output
      I  => AUX_DATA_IN(0),                      -- Diff_p buffer input (connect directly to top-level port)
      IB => AUX_DATA_IN_N(0)                     -- Diff_n buffer input (connect directly to top-level port)
      );

    mod_1_data_aux_in1_inst : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => AUX_DATA_IN_i(1),                    -- Buffer output
      I  => AUX_DATA_IN(1),                      -- Diff_p buffer input (connect directly to top-level port)
      IB => AUX_DATA_IN_N(1)                     -- Diff_n buffer input (connect directly to top-level port)
      );


   -- IBUFDS_DIFF_OUT_inst : IBUFGDS_DIFF_OUT
   -- generic map (
   --    DIFF_TERM => TRUE, -- Differential Termination
   --    IBUF_LOW_PWR => TRUE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
   --    IOSTANDARD => "LVDS_25") -- Specify the input I/O standard
   -- port map (
   --    O => MCLK_2_P,     -- Buffer diff_p output
   --    OB => MCLK_2_N,   -- Buffer diff_n output
   --    I => MCLK(2),  -- Diff_p buffer input (connect directly to top-level port)
   --    IB => MCLK_N(2) -- Diff_n buffer input (connect directly to top-level port)
   -- );


  -- Aux_Buffer : selectio_tx
  --   port map (
  --     data_out_from_device => Aux_buffer_byte,
  --     data_out_to_pins_p(0)   => Aux_Buffer_P,
  --     data_out_to_pins_n(0)   => Aux_Buffer_N,
  --     clk_in               => clk200_aux_buf,
  --     clk_div_in           => clk50_aux,
  --     io_reset             => reset
  --     );
    Aux_Buffer : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Aux_Buffer_P,                -- Diff_p output (connect directly to top-level port)
      OB => Aux_Buffer_N,              -- Diff_n output (connect directly to top-level port)
      I  => '0'                 -- Buffer input
      );


  -- Aux_Diag_out1 : selectio_tx
  --   port map (
  --     data_out_from_device => Aux_diag_out_byte,
  --     data_out_to_pins_p(0)   => Aux_Diag_out_P,
  --     data_out_to_pins_n(0)   => Aux_Diag_out_N,
  --     clk_in               => clk200_aux_buf,
  --     clk_div_in           => clk50_aux,
  --     io_reset             => reset
  --     );
  Aux_Diag_out1 : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Aux_Diag_out_P,             -- Diff_p output (connect directly to top-level port)
      OB => Aux_Diag_out_N,             -- Diff_n output (connect directly to top-level port)
      I  => '0'                         -- Buffer input
      );


  -- Reg_in1_1: selectio_rx
  --   port map (
  --     data_in_from_pins_p(0) => Reg_in_P,
  --     data_in_from_pins_n(0) => Reg_in_N,
  --     data_in_to_device   => Reg_in_byte,
  --     in_delay_reset => '0',            -- !debug: 22/12/2021
  --     in_delay_data_ce => in_delay_data_ce,   -- !debug: 22/12/2021
  --     in_delay_data_inc => in_delay_data_inc,   -- !debug: 22/12/2021
  --     in_delay_tap_in => in_delay_tap_in,       -- 26/01/2022
  --     in_delay_tap_out => open,       -- 26/01/2022
  --     bitslip(0)             => '0',
  --     clk_in              => CLK200,
  --     clk_div_in          => clk_div,
  --     io_reset            => reset
  --   );

  Reg_in_1 : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => Reg_in_i,                   -- Buffer output
      I  => Reg_in_P,
      IB => Reg_in_N
      );

   Diag_in_1 : IBUFDS   --@Dalit 18/7/2023
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => Diag_in_i,                   -- Buffer output
      I  => Diag_in_P,
      IB => Diag_in_N
      );


  -- Sync_1: selectio_rx
  --   port map (
  --     data_in_from_pins_p(0) => Sync_P,
  --     data_in_from_pins_n(0) => Sync_N,
  --     data_in_to_device   => sync_byte,
  --     in_delay_reset => '0',            -- !debug: 22/12/2021
  --     in_delay_data_ce => in_delay_data_ce,   -- !debug: 22/12/2021
  --     in_delay_data_inc => in_delay_data_inc,   -- !debug: 22/12/2021
  --     in_delay_tap_in => in_delay_tap_in,       -- 26/01/2022
  --     in_delay_tap_out => open,       -- 26/01/2022
  --     bitslip(0)             => '0',
  --     clk_in              => CLK200,
  --     clk_div_in          => clk_div,
  --     io_reset            => reset
  --   );

  Sync_1 : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => Sync_i,                   -- Buffer output
      I  => Sync_P,
      IB => Sync_N
      );

  -- Buffer_1: selectio_rx
  --   port map (
  --     data_in_from_pins_p(0) => Buffer_P,
  --     data_in_from_pins_n(0) => Buffer_N,
  --     data_in_to_device   => buffer_byte,
  --     in_delay_reset => '0',            -- !debug: 22/12/2021
  --     in_delay_data_ce => in_delay_data_ce,   -- !debug: 22/12/2021
  --     in_delay_data_inc => in_delay_data_inc,   -- !debug: 22/12/2021
  --     in_delay_tap_in => in_delay_tap_in,       -- 26/01/2022
  --     in_delay_tap_out => in_delay_tap_out,       -- 26/01/2022
  --     bitslip(0)             => '0',
  --     clk_in              => CLK200,
  --     clk_div_in          => clk_div,
  --     io_reset            => reset
  --   );

    Buffer_1_inst : IBUFDS
    generic map (
      DIFF_TERM    => TRUE,            -- Differential Termination
      IBUF_LOW_PWR => TRUE,             -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map (
      O  => Buffer_i,                    -- Buffer output
      I  => Buffer_P,
      IB => Buffer_N
      );


  -- BUFFER, DDR3 RD request packet
  RX_series7_1 : RX_series7
    generic map (
      IDLE_word      => x"B5",
      StartWord      => x"21",
      Stream_type1   => x"43",
      Stream_type2   => x"DD",
      TapWidth       => 5,
      ParallelWidth  => 8,
      NumHeaderBytes => 2,  -- !debug: 21/09/2023 was  0
      NumDataBytes   => 8,  -- !debug: 11/10/2023 was  4 -> 6 -> 8
      NumFooterBytes => 2)  -- !debug: 21/09/2023 was  0
    port map (
      RESET                => reset,
      CLKDIV               => CLK50,  -- comm_clk,
      FCLK                 => CLK200,      -- FCLK,
      channel_RDY          => Module_TX_RX_channel_RDY, -- !debug: 30/01/2023 was  buffer_channel_RDY,
      sDataIn              => Buffer_i,  -- !debug: 02/11/2022 was simulation error, temporary disconnected TX_DATA_out,
      IDLY_CNT             => open,
      RX_det_o             => buffer_byte,         -- data
      start_valid          => open,
      Headers_valid        => open,
      data_valid           => buffer_data_valid,
      Footers_valid        => open,
      IP_pckt_valid        => open, -- in header detected X"1B" byte
                                                -- !debug: 24/07/2023 old: buffer_req_valid, new: open
      packet_received      => buffer_req_valid_i, -- !debug: 24/07/2023 old: open, new: buffer_req_valid
      good_packet_received => buffer_good_packet_received,
      bad_packet_received  => buffer_bad_packet_received,
      RX_ERRs              => RX_ERRs_buffer
    );

  buffer_sample_pr : process (clk50, reset) is
  begin  -- process buffer_sample_pr
    if (reset = '1') then           -- asynchronous reset (active HIGH)
      buffer_payload <= (others => '0');
      buf_ptr_address_from_buffer <= (others => '0');
      stream_ctrl_from_buffer <= (others => '0');
      short_pulse_cnt <= 0;
    elsif (clk50'event and clk50 = '1') then  -- rising clock edge

      if (buffer_data_valid = '1') then
        buffer_payload <= buffer_byte & buffer_payload(8*8-1 downto 8);
      elsif (buffer_req_valid_i = '1') then
        buf_ptr_address_from_buffer <= buffer_payload(31 downto 0); -- Bytes 0..3: Slot/Pointer Addres: bits [31..0]
        stream_ctrl_from_buffer <= buffer_payload(55 downto 48); -- Bytes 6: Stream Type: bits [55..48]
        buffer_payload <= (others => '0');
        short_pulse_cnt <= 1;           -- !debug: 17/01/2024 when 1 - xpm_cdc_handshake latch to constant
      else
        if (short_pulse_cnt /= 0) then
          short_pulse_cnt <= short_pulse_cnt - 1;
        else
          stream_ctrl_from_buffer <= (others => '0'); -- pulse !TODO: 02/10/2023 option to keep rq_cmds in case if DDR3 controller busy
        end if;
      end if;

    end if;
  end process buffer_sample_pr;

  buffer_req_valid <= buffer_req_valid_i;

   --
   -- align_restart_pr: process (CLK50, reset) is
   -- begin  -- process align_restart_pr
   --   if (reset = '1') then            -- asynchronous reset (active high)
   --     watchdog_cnt <= 2**17;
   --     buffer_channel_RDY <= '1';
   --   elsif (CLK50'event and CLK50 = '1') then  -- rising clock edge
   --     if (buffer_req_valid_i = '1' or buffer_channel_RDY = '0') then
   --       watchdog_cnt <= 2**17;
   --       buffer_channel_RDY <= '1';
   --     elsif (watchdog_cnt /= 0) then
   --       watchdog_cnt <= watchdog_cnt - 1;
   --       buffer_channel_RDY <= '1';
   --     else
   --       buffer_channel_RDY <= '0';
   --     end if;
   --   end if;
   -- end process align_restart_pr;

   delay_main_inst : idelayctrl
     port map (rst => reset, refclk => CLK200, rdy => idelayctrl_rdy); -- !debug: 29/12/2022 was channel_RDY

   delay_aux_inst : idelayctrl
     port map (rst => reset, refclk => clk200_aux_buf, rdy => open);

  -- misc_200m_pr: process (CLK200) is
  -- begin  -- process misc_200m_pr
  --   if (CLK200'event and CLK200 = '1') then  -- rising clock edge
  --
  --   end if;
  -- end process misc_200m_pr;

  -- Aux_Sync : selectio_tx
  --   port map (
  --     data_out_from_device => Aux_Sync_byte,
  --     data_out_to_pins_p(0)   => Aux_Sync_P,
  --     data_out_to_pins_n(0)   => Aux_Sync_N,
  --     clk_in               => clk200_aux_buf,
  --     clk_div_in           => clk50_aux,
  --     io_reset             => reset
  --     );
    Aux_Sync : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Aux_Sync_P,              -- Diff_p output (connect directly to top-level port)
      OB => Aux_Sync_N,              -- Diff_n output (connect directly to top-level port)
      I  => '0'                      -- Buffer input
      );


  Aux_Diag_in_1: selectio_rx
    port map (
      data_in_from_pins_p(0) => Aux_Diag_in_P,
      data_in_from_pins_n(0) => Aux_Diag_in_N,
      data_in_to_device   => aux_diag_in_byte,
      in_delay_reset => '0',            -- !debug: 22/12/2021
      in_delay_data_ce => in_delay_data_ce,   -- !debug: 22/12/2021
      in_delay_data_inc => in_delay_data_inc,   -- !debug: 22/12/2021
      in_delay_tap_in => in_delay_tap_in,       -- 26/01/2022
      in_delay_tap_out => open,       -- 26/01/2022
      bitslip(0)             => '0',
      clk_in              => clk200_aux_buf,
      clk_div_in          => clk50_aux,
      io_reset            => reset
    );




      DATA_OUT0_inst : OBUFDS
      generic map (
        IOSTANDARD => "LVDS_25",        -- Specify the output I/O standard
        SLEW       => "SLOW")           -- Specify the output slew rate
      port map (
        O  => DATA_OUT(0),                -- Diff_p output (connect directly to top-level port)
        OB => DATA_OUT_N(0),              -- Diff_n output (connect directly to top-level port)
        I  => TX_DATA_out                 -- Buffer input
        );

      DATA_OUT1_inst : OBUFDS
      generic map (
        IOSTANDARD => "LVDS_25",        -- Specify the output I/O standard
        SLEW       => "SLOW")           -- Specify the output slew rate
      port map (
        O  => DATA_OUT(1),                -- Diff_p output (connect directly to top-level port)
        OB => DATA_OUT_N(1),              -- Diff_n output (connect directly to top-level port)
        I  => debug2_sig                    -- Buffer input
        );


  Aux_Reg_in1_inst: selectio_rx
    port map (
      data_in_from_pins_p(0) => Aux_Reg_in_P,
      data_in_from_pins_n(0) => Aux_Reg_in_N,
      data_in_to_device   => Aux_reg_in_byte,
      in_delay_reset => '0',
      in_delay_data_ce => in_delay_data_ce,
      in_delay_data_inc => in_delay_data_inc,
      in_delay_tap_in => in_delay_tap_in,       -- 26/01/2022
      in_delay_tap_out => open,       -- 26/01/2022
      bitslip(0)             => '0',
      clk_in              => clk200_aux_buf,
      clk_div_in          => clk50_aux,
      io_reset            => reset
    );


  -- Aux_Reg_out : selectio_tx
  --   port map (
  --     data_out_from_device => Aux_Reg_out_byte,
  --     data_out_to_pins_p(0)   => Aux_Reg_out_P,
  --     data_out_to_pins_n(0)   => Aux_Reg_out_N,
  --     clk_in               => clk200_aux_buf,
  --     clk_div_in           => clk50_aux,
  --     io_reset             => reset
  --     );
  Aux_Reg_out : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Aux_Reg_out_P,                -- Diff_p output (connect directly to top-level port)
      OB => Aux_Reg_out_N,              -- Diff_n output (connect directly to top-level port)
      I  => '0'                 -- Buffer input
      );

  Reg_out1 : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Reg_out_P,                -- Diff_p output (connect directly to top-level port)
      OB => Reg_out_N,              -- Diff_n output (connect directly to top-level port)
      I  => Reg_out_i                 -- Buffer input
      );

    Diag_out1 : OBUFDS
    generic map (
      IOSTANDARD => "LVDS_25",          -- Specify the output I/O standard
      SLEW       => "SLOW")             -- Specify the output slew rate
    port map (
      O  => Diag_out_P,                -- Diff_p output (connect directly to top-level port)
      OB => Diag_out_N,              -- Diff_n output (connect directly to top-level port)
      I  => Diag_out_i                 -- Buffer input
      );

  CLK200_o <= CLK200;
  CLK50_o <= CLK50;

  io_inst_tp <= buffer_good_packet_received & buffer_bad_packet_received;

  ODDR_aclk0_inst : ODDR
generic map(
   DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => ACLK(0),   -- 1-bit DDR output
   C => aclk_master_i_int,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => "not"(ACLK_and_TILES_CLK_EN),    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);

 ODDR_aclk1_inst : ODDR
generic map(
   DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => ACLK(1),   -- 1-bit DDR output
   C => aclk_master_i_int,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => "not"(ACLK_and_TILES_CLK_EN),    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);
 ODDR_aclk2_inst : ODDR
generic map(
   DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => ACLK(2),   -- 1-bit DDR output
   C => aclk_master_i_int,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => "not"(ACLK_and_TILES_CLK_EN),    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);
 ODDR_aclk3_inst : ODDR
generic map(
   DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE"
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => ACLK(3),   -- 1-bit DDR output
   C => aclk_master_i_int,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => "not"(ACLK_and_TILES_CLK_EN),    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);


end ar;
