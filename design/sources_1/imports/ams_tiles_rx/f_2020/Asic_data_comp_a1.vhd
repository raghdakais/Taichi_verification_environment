--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.phoebe.all;
-------------------------------------------------------------------------------
-- 17/07/2022 : changes for bit alignment
-------------------------------------------------------------------------------


ENTITY Asic_data_Comp IS
  port(
    RESET_N            : in  std_logic;
    rx_in              : in  std_logic;
    clk20_c2           : in  std_logic;
    clk160_c0          : in  std_logic;
    IP20               : in  std_logic;
    diag_reg           : in std_logic_vector(7 downto 0);
    take_qp2_reg       : in std_logic;
    start_align_reg    : in  std_logic_vector (7 downto 0); -- !debug: 25/01/2023 was start_rx_sync      : in  std_logic;
    Tile_data_locked_o : out std_logic;
    RX_det_o           : out std_logic_vector (25 downto 0);  -- 26bit detector word
    data_valid         : out std_logic;
    ip_aclk_count      : out std_logic_vector (15 downto 0);
    temp_sensor        : out std_logic_vector (15 downto 0);
    power_monitor_footer : out std_logic_vector(11 downto 0);
    raw_data_bypass    : out   std_logic;
    calib_completed    : out   std_logic_vector(3 downto 0);
    sel_bit_18_16      : in std_logic_vector(2 downto 0); -- 06/06/2024
    selected_footer2diag : out std_logic_vector(15 downto 0); -- 06/06/2024
    ams_test_pattern_en  : out std_logic;                     -- 25/06/2024
    dataG_o            : out std_logic;
    data_test_result   : out std_logic;
    AMS_CrcError       : out std_logic;
    AMS_CrcOk          : out std_logic;      --Dalit 19/9/2023
    asic_data_good_read: out std_logic;
    Test_p             : out std_logic_vector (7 downto 0)
    );
END Asic_data_Comp;


ARCHITECTURE arc_Asic_data_Comp OF Asic_data_Comp IS

  component Phoebe_dat_IF is
    port(
      RESET              : in  std_logic;
      TILE_RDY           : in  std_logic;
      FCLK               : in  std_logic;
      CLKDIV             : in  std_logic;
      Bytes_per_det      : in  integer range 3 to 5;
      IDLE_word          : in  std_logic_vector (7 downto 0);
      SYNC               : in  std_logic;
      Footer_optional_en : in  std_logic;
      det2load_o         : out std_logic_vector (39 downto 0);
      load_o             : out std_logic;
      footer_valid_o     : out std_logic_vector (6 downto 1);
      -- sDataIn_p          : in  std_logic;  -- data channel positive
      -- sDataIn_n          : in  std_logic;  -- data channel negative
      sDataIn_i          : in  std_logic;  -- 28/06/2022 IBUFDS moved to top
      crc_ok             : out   std_logic;        --Dalit 19/9/2023
      crc_error          : out std_logic;
      std_error          : out std_logic;
      asic_data_good_read: out std_logic; -- 05/09/2023
      Phoebe_data_locked : out std_logic
      );
  end component;

  signal det2load_o     : std_logic_vector (39 downto 0);
  signal load_o         : std_logic;
  signal footer_valid_o : std_logic_vector (6 downto 1);

  signal data_test_mode : boolean;
  signal IP20_r : std_logic;
  signal crc_error : std_logic;
   signal crc_ok : std_logic; --Dalit 19/9/2023

  signal Phoebe_data_locked : std_logic;                     -- 27/07/2022
  signal start_rx_sync_masked, disable_rx_sync_window : std_logic := '0';
  signal rx_sync_window_cnt : natural range 0 to 4095 := 0;
  signal take_qp2 : std_logic := '0';
  signal raw_data_bypass_i    : std_logic;

  signal use_AMS_Time_const : std_logic;
  signal ip_aclk_count_i : std_logic_vector (15 downto 0);
  constant AMS_Time_const : std_logic_vector (15 downto 0) := X"00DC";

  signal footer_6 : std_logic_vector(11 downto 0);

  signal start_align_20m    : std_logic_vector (7 downto 0);
  signal diag_20m           : std_logic_vector(7 downto 0);
  signal sel_bit_18_16_20m  : std_logic_vector(2 downto 0);
  
  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of calib_completed, disable_rx_sync_window, start_rx_sync_masked, IP20, rx_sync_window_cnt, Phoebe_data_locked : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of calib_completed, disable_rx_sync_window, start_rx_sync_masked, IP20, rx_sync_window_cnt, Phoebe_data_locked : signal is "true";

BEGIN


  Phoebe_dat_IF_inst : Phoebe_dat_IF
    port map (
      RESET              => "not"(RESET_N),
      TILE_RDY           => start_rx_sync_masked, -- Liron: '0' - force unaligned status, '1' - enable alignment
      FCLK               => clk160_c0,
      CLKDIV             => clk20_c2,
      Bytes_per_det      => 5,          -- 40bit DW
      IDLE_word          => x"B5",
      SYNC               => IP20,
      Footer_optional_en => '1',
      det2load_o         => det2load_o,
      load_o             => load_o,
      footer_valid_o     => footer_valid_o, --28/06/2022 uses for statuses sampling
      -- sDataIn_p          => DATA1,
      -- sDataIn_n          => DATA1_n,
      sDataIn_i          => rx_in, -- 28/06/2022
      crc_error          => crc_error,
       crc_ok             => crc_ok,        --Dalit 19/9/2023
      std_error          => open, -- std_error,
      asic_data_good_read => asic_data_good_read, -- 05/09/2023
      Phoebe_data_locked => Phoebe_data_locked
    );


  -- RX_det_o <= det2load_o(25 downto 0);
  RX_det_o(16 downto 0) <= det2load_o(16 downto 0); -- offset and linearity corrected data / fine quantizer data
  -- RX_det_o(25 downto 17) <= det2load_o(25 downto 17) when (raw_data_bypass_i = '0' or take_qp2 = '1') else det2load_o(34 downto 26); -- 04/08/2022
  RX_det_o(25 downto 17) <= det2load_o(25 downto 17);             -- !debug: 01/05/2023 temporary always send QP2
  data_valid <= load_o when (footer_valid_o = "000000") else '0'; -- 28/06/2022 only data words

  Tile_data_locked_o <= Phoebe_data_locked;

  ams_footer_pr: process (clk20_c2, RESET_N) is
  begin  -- process ams_footer_pr
    if (RESET_N = '0') then             -- asynchronous reset (active low)
      temp_sensor <= (others => '0');   -- FOOTER_1: TEMP_SENSOR
      ip_aclk_count_i <= (others => '0'); -- FOOTER_2: IP_ACLK_COUNT
      power_monitor_footer <= (others => '0'); -- FOOTER_3: now POWER_MONITOR, AMS register 0x000E
      raw_data_bypass_i <= '0'; -- FOOTER_4: now LVDS_CONFIG_3, AMS register 0x0017 [12] - raw_data_bypass
      calib_completed <= (others => '0'); -- FOOTER_5: now CALIB_MONITOR, AMS register 0x0058 [0] - Linearity, [2] - offset current, [3] - Offset voltage
      data_test_mode <= FALSE;
      data_test_result <= '0';
      IP20_r <= '0';
      selected_footer2diag <= (others => '0');
    elsif (clk20_c2'event and clk20_c2 = '1') then  -- rising clock edge

      if (footer_valid_o(1) = '1') then
        temp_sensor <=  "00000" & det2load_o(10 downto 0); -- FOOTER_1: TEMP_SENSOR
      end if;

      if (footer_valid_o(2) = '1') then
        ip_aclk_count_i <= "000000" & det2load_o(9 downto 0); -- FOOTER_2: IP_ACLK_COUNT
      end if;

      if (footer_valid_o(3) = '1') then
        power_monitor_footer <= det2load_o(11 downto 0); -- FOOTER_3
      end if;

      if (footer_valid_o(4) = '1') then
        raw_data_bypass_i <= det2load_o(12);      -- FOOTER_4
      end if;

      if (footer_valid_o(5) = '1') then
        calib_completed <= det2load_o(3 downto 0); -- FOOTER_5
      end if;

      if (footer_valid_o(6) = '1') then            -- 06/06/2024
        footer_6 <= det2load_o(11 downto 0); -- FOOTER_6
      end if;

      IP20_r <= IP20;
      if (IP20_r = '0' and IP20 = '1') then
        if (not data_test_mode) then
          data_test_mode <= TRUE;
        else
          data_test_result <= '1';      -- second IP, but not received
        end if;
      elsif (data_test_mode and footer_valid_o(6) = '1') then
        data_test_mode <= FALSE;
        data_test_result <= '0';      -- '0' - ok , '1' fault
      end if;

      case conv_integer(sel_bit_18_16_20m) is
        when 1 => selected_footer2diag <= temp_sensor;
        when 2 => selected_footer2diag <= ip_aclk_count_i;
        when 3 => selected_footer2diag <= X"0" & power_monitor_footer;
        when 4 => selected_footer2diag <= X"0" & raw_data_bypass_i & "000" & X"00";
        when 5 => selected_footer2diag <= X"000" & calib_completed;
        when others => selected_footer2diag <= X"0" & footer_6;
      end case;

      -- descr: check if test pattern generator enabled in AMS (valid only, when in FOOTER_6 appears AMS register 0x0022 TEST_PATTERN_2)
      ams_test_pattern_en <= footer_6(8);
      
    end if;
  end process ams_footer_pr;

  misc_pr: process (clk20_c2) is
  begin  -- process misc_pr
    if (clk20_c2'event and clk20_c2 = '1') then  -- rising clock edge

      --  27/07/2022
      disable_rx_sync_window <= start_align_20m(2); -- !debug: 25/01/2023 was diag_20m(1);
      if (IP20_r = '0' and IP20 = '1') then
        rx_sync_window_cnt <= 0;
      elsif (rx_sync_window_cnt < 4095) then
        rx_sync_window_cnt <= rx_sync_window_cnt + 1;
      end if;
      -- note: aligment in sim. after AMS packet
      if (disable_rx_sync_window = '0') then
        start_rx_sync_masked <= start_align_20m(0);
        -- synthesis translate_off
        -- start_rx_sync_masked <= << signal .rx_ams_tiles_tb.start_align_20m : std_logic >>; -- !debug: 14/03/2023 only for simulation
        --[Raghda Kais - removed]  start_rx_sync_masked <= << signal ^.^.^.^.start_align_20m : std_logic >>; -- !debug: 02/10/2023 only for simulation
        -- synthesis translate_on
      elsif (Phoebe_data_locked = '1' or (rx_sync_window_cnt > 1800 and rx_sync_window_cnt < 3500)) then
        start_rx_sync_masked <= start_align_20m(0);
        -- synthesis translate_off
        -- start_rx_sync_masked <= << signal .rx_ams_tiles_tb.start_align_20m : std_logic >>; -- !debug: 14/03/2023 only for simulation
        --[Raghda Kais - removed]  start_rx_sync_masked <= << signal ^.^.^.^.start_align_20m : std_logic >>; -- !debug: 02/10/2023 only for simulation
        -- synthesis translate_on
      else
        start_rx_sync_masked <= '0';
      end if;
      -- -- synthesis translate_off
      -- -- note: aligment in sim. before AMS packet
      -- if (Phoebe_data_locked = '1' or (rx_sync_window_cnt > 50 and rx_sync_window_cnt < 380)) then
      --   start_rx_sync_masked <= start_align_20m(0);
      -- else
      --   start_rx_sync_masked <= '0';
      -- end if;
      -- -- synthesis translate_on

      take_qp2 <= take_qp2_reg;               -- 0x279 [3] - when 0x279 [2] = '1': '0' - QP1, '1' - QP2

      use_AMS_Time_const <= diag_20m(4); -- [4] - '1' synthetic data in place tiles data

      start_align_20m <= start_align_reg;
      diag_20m <= diag_reg;
      sel_bit_18_16_20m <= sel_bit_18_16;
        
    end if;
  end process misc_pr;


  dataG_o <= footer_valid_o(6);       -- !debug: 29/06/2022 now when end of AMS packet
  AMS_CrcOk <= crc_ok;   --Dalit 19/9/2023
  AMS_CrcError <= crc_error;
  raw_data_bypass <= raw_data_bypass_i;

  ip_aclk_count <= ip_aclk_count_i when (use_AMS_Time_const = '0') else AMS_TIME_CONST; -- 23/01/2023

  Test_p(7) <= crc_error;
  Test_p(6) <= '0';
  Test_p(5) <= '0';
  Test_p(4 downto 0) <= "00000";

END architecture arc_Asic_data_Comp;
