--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.phoebe.all;
library UNISIM;
use UNISIM.VComponents.all;


ENTITY Tiles_managment IS
    generic (
      IS_MASTER_ASIC : boolean := FALSE); -- 06/11/2022
    port(
      RESET_N            : in  std_logic;
      nRST_20m           : in  std_logic;
      clk20_c2           : in  std_logic;
      clk160_c0          : in  std_logic;
      clk64_c3           : in  std_logic;
      CLK_200            : in  std_logic; -- 17/07/2022
      ACLK_Master        : in  std_logic;
      IP                 : in  std_logic;
      TMC_exists         : in  std_logic; -- NU
      idelayctrl_rdy_i   : in  std_logic; -- 06/11/2022
      idelayctrl_rdy_o   : out std_logic; -- 06/11/2022
      locked_fast        : in  std_logic; -- PLL OK
      DiscardIP          : in  std_logic; -- NU
      Bias               : in  std_logic; -- NU
      rx_in              : in  std_logic_vector (NumOfTiles-1 downto 0);
      REGS_req           : in  std_logic_vector (39 downto 0);
      CNT_lines          : in  std_logic_vector (15 downto 8);
      wrreq              : in  std_logic_vector (1 downto 0); -- send to SPI: WR/RD AMS registers
      RAM_wraddress      : in  std_logic_vector (7 downto 0);
      Calib              : in  std_logic_vector(2 downto 0);  -- NU
      calib_ctl_reg      : in  std_logic_vector(15 downto 0);
      diag_reg           : in std_logic_vector(15 downto 0);
      take_qp2_reg       : in std_logic;                      -- 04/08/2022
      exit_from_asic_reset : in std_logic;                  -- 20/04/2023
      start_align_reg    : in  std_logic_vector (7 downto 0); -- !debug: 25/01/2023 was start_rx_sync      : in  std_logic;
      test_status_reg    : out std_logic_vector(11 downto 0);
      overhead_bits      : out std_logic_vector(63 downto 0);
      SPI_ERRs           : out	std_logic_vector(3*NumOfTiles-1 downto 0); --add by Dalit 10/10/2023
      AMS_CrcOk_o        : out  std_logic_vector(NumOfTiles-1 downto 0); -- add by Dalit 19/9/2023
      AMS_CrcError_o     : out  std_logic_vector(NumOfTiles-1 downto 0); --add by Dalit 10/10/2023
      AMS_CrcError_counter_o     : out  std_logic_vector(4*NumOfTiles-1 downto 0); -- -AMS_CrcError_o changed by Dalit 10/010/2023
      Tile_power_monitor_footer : out std_logic_vector((NumOfTiles*12)-1 downto 0); --add by Dalit 12/10/2023
      Asic_mode_Calibrated_or_Raw : out std_logic_vector(NumOfTiles-1 downto 0); --add by Dalit 18/10/2023
      asic_data_good_read: out  std_logic_vector(NumOfTiles-1 downto 0); -- 05/09/2023
      tiles_crc_clear_reg : in  std_logic; -- 20/07/2022
      ms_spi_sel         : in  std_logic; -- 19/10/2022
      SDO                : in  std_logic_vector(NumOfTiles-1 downto 0);

      IP20_o             : out std_logic;
      IP50_o             : out std_logic; -- 27/10/2022
      READ_OUT_ready_o   : out std_logic_vector(NumOfTiles-1 downto 0); -- !debug: 21/06/2022 was width bit
      SYNC               : out std_logic_vector(NumOfTiles-1 downto 0);
      ACLK               : out std_logic_vector(NumOfTiles-1 downto 0);
      SCSn               : out std_logic_vector(NumOfTiles-1 downto 0);
      SDI                : out std_logic_vector(NumOfTiles-1 downto 0);
      SCLK               : out std_logic_vector(NumOfTiles-1 downto 0);
      Tiles_rst          : out std_logic_vector(NumOfTiles-1 downto 0);
      Discard            : out std_logic_vector(NumOfTiles-1 downto 0);
      Tile_data_locked_o : out std_logic_vector(NumOfTiles-1 downto 0);
      AMS_Time           : out std_logic_vector((NumOfTiles*16)-1 downto 0);
      temp_sensor        : out std_logic_vector((NumOfTiles*16)-1 downto 0);
      RX_det_o           : out std_logic_vector((NumOfTiles*26)-1 downto 0);  -- tiles data
      data_valid_o       : out std_logic_vector(NumOfTiles-1 downto 0);       -- tiles data strobe
      DATA2R_o           : out std_logic_vector(NumOfTiles*15-1 downto 0); -- !debug: 21/06/2022 WORD_WIDTH2 = 15
      DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
      ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
      Power_en          : out std_logic_vector (2 downto 0); -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
      calib_completed_o : out std_logic_vector((NumOfTiles*4)-1 downto 0); -- 21/03/2023
      sel_bit_18_16        : in  std_logic_vector(2 downto 0);  -- 06/06/2024
      selected_footer2diag : out std_logic_vector((NumOfTiles*16)-1 downto 0);  -- 06/06/2024
      synthetic_data_from_asic : out std_logic;                                 -- 25/06/2024
      Tiles_managment_tp : out   std_logic_vector (7 downto 0)
    );
END Tiles_managment;


-------------------------------------------------------------------------------


ARCHITECTURE behave OF Tiles_managment IS


 signal 	IP20   :   			std_logic ;                                             -- IP on 20 Meg Clock
 signal 	IP64_vec : 			std_logic_vector(5 downto 0)  ;
 signal 	IP20_v  : 			std_logic_vector(2 downto 0):= "000" ;


 COMPONENT Phoebe_CntrlSpiSplitMem IS
    GENERIC(
    	WORD_WIDTH1	: integer  := 15;
      WORD_WIDTH2	: integer  := 15
    );
    PORT(
      RESET_N          : in  std_logic;
      clk              : in  std_logic;
      ACLK_Master      : in  std_logic;                      -- 05/04/2021
      locked_fast      : in  std_logic;
      DiscardIP        : in  std_logic;
      REGS_req         : in  std_logic_vector(39 downto 0);
      CNT_lines        : in  std_logic_vector (15 downto 8);
      wrreq            : in  std_logic_vector(1 downto 0);
      RAM_wraddress    : in  std_logic_vector(7 downto 0);
      Discard          : out std_logic_vector(NumOfTiles-1 downto 0);
      IP               : in  std_logic;
      SYNC             : out std_logic_vector(NumOfTiles-1 downto 0);
      ACLK             : out std_logic_vector(NumOfTiles-1 downto 0);
      -- AMS_Time         : out std_logic_vector(15 downto 0);  -- 08/04/2021
      SCSn             : out std_logic_vector(NumOfTiles-1 downto 0);
      SDI              : out std_logic_vector(NumOfTiles-1 downto 0);
      SCLK             : out std_logic_vector(NumOfTiles-1 downto 0);
      SDO              : in  std_logic_vector(NumOfTiles-1 downto 0);
      Tiles_rst        : out std_logic_vector(NumOfTiles-1 downto 0);
      Bias             : in  std_logic;
      Calib            : in  std_logic_vector(2 downto 0);
      calib_ctl_reg    : in  std_logic_vector(15 downto 0);  -- 10/05/2021
      diag_reg         : in std_logic_vector(15 downto 0);   -- 07/11/2021
      exit_from_asic_reset : in std_logic;                  -- 20/04/2023      
      overhead_bits    : out std_logic_vector(63 downto 0);  -- 21/06/2021
      pass_addr_test   : out std_logic_vector(NumOfTiles-1 downto 0); -- 09/08/2021
      registers_test_result : out std_logic_vector(NumOfTiles-1 downto 0); -- 05/01/2022
      READ_OUT_ready_o : out std_logic_vector(NumOfTiles-1 downto 0); -- !debug: 21/06/2022 was width bit
      DATA2R_o         : out std_logic_vector(NumOfTiles*WORD_WIDTH2-1 downto 0); -- !debug: 21/06/2022 was width (WORD_WIDTH2-1 downto 0)
      DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
      ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
      Power_en          : out std_logic_vector (2 downto 0); -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
      SPI_ERRs          : out	std_logic_vector(3*NumOfTiles-1 downto 0) --add by Dalit 10/10/2023
      );
 END COMPONENT;


 component Asic_data_Comp is
   port(
     RESET_N              : in  std_logic;
     rx_in                : in  std_logic;
     clk20_c2             : in  std_logic;
     clk160_c0            : in  std_logic;
     IP20                 : in  std_logic;
     diag_reg             : in  std_logic_vector(7 downto 0);
     take_qp2_reg         : in  std_logic;
     start_align_reg      : in  std_logic_vector (7 downto 0);  -- !debug: 25/01/2023 was start_rx_sync      : in  std_logic;
     Tile_data_locked_o   : out std_logic;
     RX_det_o             : out std_logic_vector (25 downto 0);  -- 26bit detector word
     data_valid           : out std_logic;
     ip_aclk_count        : out std_logic_vector (15 downto 0);
     temp_sensor          : out std_logic_vector (15 downto 0);
     power_monitor_footer : out std_logic_vector(11 downto 0);
     raw_data_bypass      : out std_logic;
     calib_completed      : out std_logic_vector(3 downto 0);  -- register 0x0058 [0] - Linearity, [2] - offset current, [3] - Offset voltage
     sel_bit_18_16        : in  std_logic_vector(2 downto 0);  -- 06/06/2024
     selected_footer2diag : out std_logic_vector(15 downto 0);  -- 06/06/2024
     ams_test_pattern_en  : out std_logic;                     -- 25/06/2024
     dataG_o              : out std_logic;
     data_test_result     : out std_logic;
     AMS_CrcError         : out std_logic;
     AMS_CrcOk            : out std_logic;                     --add by Dalit 19/9/2023
     asic_data_good_read  : out std_logic;                     -- 05/09/2023
     Test_p               : out std_logic_vector (7 downto 0)
     );
 end component;


 signal Tile_data_locked_i : std_logic_vector (NumOfTiles-1 downto 0);

 signal WIdle_avl           : std_logic;						-- Idle word available,  Indicate the time before new sync and after the data from curent sync was ended

 signal data_valid  :   		std_logic_vector(NumOfTiles-1 downto 0) ;					-- could be  std_logic_vector(NumOfTiles-1 downto 0)

 signal rx_det_i : std_logic_vector((NumOfTiles*26)-1 downto 0);

 -- component map4ams_lut is
 --  port (
 --    clka  : in  STD_LOGIC;
 --    addra : in  STD_LOGIC_VECTOR (7 downto 0);
 --    douta : out STD_LOGIC_VECTOR (7 downto 0));
 -- end component map4ams_lut;

 -- type ADDR_ARRAY_TYP is array (NumOfTiles-1 downto 0) of std_logic_vector(7 downto 0);
 -- signal map4ams_lut_addr, map4ams_det_num, det_arrange_dpr_rdaddr : ADDR_ARRAY_TYP;
 -- signal data_valid_r : std_logic_vector(NumOfTiles-1 downto 0); -- from write to DPR
 -- signal wr2dpr_ready, data_valid_from_dpr, data_valid_lut : std_logic_vector(NumOfTiles-1 downto 0);
 -- signal RX_det_lut : std_logic_vector((NumOfTiles*26)-1 downto 0);
 -- signal wr2dpr_ready_0, wr2dpr_ready_1, wr2dpr_ready_2, wr2dpr_ready_3 : std_logic_vector(NumOfTiles-1 downto 0);

 -- component det_arrange_dpr is
 --   port (
 --     clka  : in  STD_LOGIC;
 --     wea   : in  STD_LOGIC_VECTOR (0 to 0);
 --     addra : in  STD_LOGIC_VECTOR (7 downto 0);
 --     dina  : in  STD_LOGIC_VECTOR (25 downto 0);
 --     clkb  : in  STD_LOGIC;
 --     addrb : in  STD_LOGIC_VECTOR (7 downto 0);
 --     doutb : out STD_LOGIC_VECTOR (25 downto 0));
 -- end component det_arrange_dpr;

 signal overhead_bits_i : std_logic_vector(63 downto 0); -- 21/06/2021
 signal ip_aclk_count_i : std_logic_vector((NumOfTiles*16)-1  DOWNTO 0);
 signal dataG, dataG_32m, dataG_32m_r : std_logic_vector(NumOfTiles-1 downto 0) := (others => '0'); -- 27/06/2021
 signal num_of_tiles, num_of_tiles_20m : std_logic_vector(NumOfTiles-1 downto 0) := X"6";     -- 06/12/2021
 signal latch_num_of_tiles_en, latch_num_of_tiles_dis : boolean := FALSE; -- 01/07/2021
 -- signal last_rd : std_logic_vector(NumOfTiles-1 downto 0);
 -- signal bypass_lut : std_logic;
 signal pass_addr_test, pass_addr_test_20m : std_logic_vector(NumOfTiles-1 downto 0); -- 09/08/2021
 type CHANNEL_CNT_ARRAY_TYP is array (NumOfTiles-1 downto 0) of natural range 0 to 256;
 signal channel_cnt, pass_addr_test_delay : CHANNEL_CNT_ARRAY_TYP;
 signal pass_addr_test_err : std_logic_vector(NumOfTiles-1 downto 0); -- 09/08/2021
 signal footer_bit21, footer_bit21_32m, footer_bit22_32m, footer_bit23_32m : std_logic;
 signal footer_ip_aclk, aclk_from_tile_1, aclk_from_tile_2 : std_logic_vector(9 downto 0) := (others => '0');
 signal force4tiles : std_logic := '0';         -- 06/12/2021 only for test
 signal registers_test_result, registers_test_result_r : std_logic_vector(NumOfTiles-1 downto 0); -- 05/01/2022
 signal bad_aclk_1, bad_aclk_2 : std_logic := '0';
 signal ip_period_1,ip_period_2, ip_period_1_sampled, ip_period_2_sampled : std_logic_vector(25 downto 0) := (others => '0');

 attribute DONT_TOUCH : string;
 attribute DONT_TOUCH of pass_addr_test, pass_addr_test_delay, aclk_from_tile_1, aclk_from_tile_2, bad_aclk_1, bad_aclk_2, ip_period_1_sampled, ip_period_2_sampled : signal is "TRUE";
 
 attribute mark_debug : string;
 attribute mark_debug of channel_cnt, pass_addr_test, pass_addr_test_delay, aclk_from_tile_1, aclk_from_tile_2, bad_aclk_1, bad_aclk_2, ip_period_1_sampled, ip_period_2_sampled : signal is "true";

 signal rx_det_dummy : std_logic_vector(4 downto 0); -- !debug: 06/10/2021
 signal power_monitor_footer : std_logic_vector((NumOfTiles*12)-1 downto 0); -- 29/12/2021
 attribute DONT_TOUCH of power_monitor_footer : signal is "TRUE";
  attribute mark_debug of power_monitor_footer: signal is "true";
 signal raw_data_bypass : std_logic_vector (NumOfTiles-1 downto 0);  -- 13/06/2022
 signal calib_completed : std_logic_vector((NumOfTiles*4)-1 downto 0); -- 20/06/2022
 signal mon_cnt : natural range 0 to 3 := 0;
 signal power_monitor_mux : std_logic_vector(15 downto 0);            -- 29/12/2021
 signal test_in_progress : std_logic;
 signal test_in_progress_cnt : natural range 0 to 255;
 signal do_tests, calib_ctl_reg_tr : std_logic;
 signal data_test_result : std_logic_vector (NumOfTiles-1 downto 0);
 signal ip_timeout_cnt : natural range 0 to 2**17;
 signal noip_tmp : boolean;
 signal overhead_bits_43_40_r, data_test_result_r : std_logic_vector (NumOfTiles-1 downto 0);
 signal Test_p : std_logic_vector (8*NumOfTiles-1 downto 0); -- [15] - Test_p(7) <= AMS_CrcError from tile1
 signal AMS_CrcError, AMS_CrcError_r  : std_logic_vector (NumOfTiles-1 downto 0);
 signal AMS_CrcError_cnt : unsigned(4*NumOfTiles-1 downto 0) := (others => '0'); -- 11/05/2023
signal AMS_CrcOk  : std_logic_vector (NumOfTiles-1 downto 0);  -- add by Dalit 19/9/2023

 signal overhead_bit_0, overhead_bit_0_32m : std_logic := '0';

 signal idelayctrl_rdy, idelayctrl_rdy_20m, tiles_rx_reset_n : std_logic;

 -- attribute IODELAY_GROUP : STRING;
 -- attribute IODELAY_GROUP of idelay_rx_inst : label is "ams_rx_in_group";

 signal start_rx_sync_32m : std_logic;
 signal delay_ipx_cnt : natural range 0 to 15 := 0;

 signal calib_ctl_reg_masked : std_logic_vector(15 downto 0);  -- 19/10/2022
 signal wrreq_masked : std_logic_vector (1 downto 0);
 signal ams_test_pattern_en : std_logic_vector (NumOfTiles-1 downto 0);
 
BEGIN

  ms_gen_1: if (IS_MASTER_ASIC) generate

    idelay_rx_inst : idelayctrl
      port map (rst => "not"(RESET_N), refclk => CLK_200, rdy => idelayctrl_rdy);

  end generate ms_gen_1;

  idelayctrl_rdy_o <= idelayctrl_rdy;


  Asic_data_gen : for i in 0 to (NumOfTiles-1) generate

    Asic_data_inst : Asic_data_Comp
      port map (
        RESET_N               => tiles_rx_reset_n,
        rx_in                 => rx_in(i),
        clk20_c2              => clk20_c2,
        clk160_c0             => clk160_c0,
        IP20                  => IP20,
        diag_reg              => diag_reg(7 downto 0),
        take_qp2_reg          => take_qp2_reg,
        start_align_reg       => start_align_reg,  -- !debug: 25/01/2023 was start_rx_sync
        Tile_data_locked_o    => Tile_data_locked_i(i),
        RX_det_o              => rx_det_i(i*26+25 downto i*26),
        data_valid            => data_valid(i),
        ip_aclk_count         => ip_aclk_count_i(i*16+15 downto i*16),
        temp_sensor           => temp_sensor(i*16+15 downto i*16),
        power_monitor_footer  => power_monitor_footer(i*12+11 downto i*12),
        raw_data_bypass       => raw_data_bypass(i),
        calib_completed       => calib_completed(i*4+3 downto i*4), -- connect to overhead_bits(59 downto 44)
        sel_bit_18_16         => sel_bit_18_16,                     -- 06/06/2024
        selected_footer2diag  => selected_footer2diag(i*16+15 downto i*16), -- 06/06/2024
        ams_test_pattern_en   => ams_test_pattern_en(i),
        dataG_o               => dataG(i),
        data_test_result      => data_test_result(i),
		AMS_CrcError          => AMS_CrcError(i),
        AMS_CrcOk             => AMS_CrcOk(i),     --add by Dalit 19/9/2023  
        asic_data_good_read   => asic_data_good_read(i), -- 05/09/2023
		Test_p                => Test_p(i*8+7 downto i*8)
        );
    Asic_mode_Calibrated_or_Raw<=raw_data_bypass; --add by Dalit 18/10/2023
    Tiles_managment_tp <= (0 => Test_p(14), 1 => Test_p(13), others => '0'); -- dw_start & data_valid

  end generate;

  Tile_power_monitor_footer <= power_monitor_footer;  -- add by Dalit 12/10/2023
  
  Tile_data_locked_o <= Tile_data_locked_i;
  calib_completed_o <= calib_completed; -- 21/03/2023

-- !TODO: 30/03/2021 check
Phoebe_CntrlSpiSplitMem_inst: Phoebe_CntrlSpiSplitMem
    GENERIC MAP(
    	WORD_WIDTH1	=> 14,
      WORD_WIDTH2	=> 15
    )
    PORT MAP(
      RESET_N          => RESET_N,
      clk              => clk64_c3,     -- now it is system clock
      ACLK_Master      => ACLK_Master,  -- 05/04/2021
      locked_fast      => locked_fast,
      DiscardIP        => DiscardIP,
      REGS_req         => REGS_req,
      CNT_lines        => CNT_lines,
      wrreq            => wrreq_masked,
      RAM_wraddress    => RAM_wraddress,
      Discard          => Discard,
      IP               => IP,
      SYNC             => SYNC,
      ACLK             => ACLK,
      -- AMS_Time         => open,  -- !debug: 08/04/2021 internal calculated, can be connected for test
      SCSn             => SCSn,
      SDI              => SDI,
      SCLK             => SCLK,
      SDO              => SDO,
      Tiles_rst        => Tiles_rst,
      Bias             => Bias,
      Calib            => Calib,
      calib_ctl_reg    => calib_ctl_reg_masked,    -- 10/05/2021
      diag_reg         => diag_reg,     -- 07/11/2021
      overhead_bits    => overhead_bits_i,  -- 22/06/2021
      exit_from_asic_reset => exit_from_asic_reset,   -- 20/04/2023
      pass_addr_test   => pass_addr_test,   -- 09/08/2021
      registers_test_result => registers_test_result, -- 05/01/2022
      READ_OUT_ready_o => READ_OUT_ready_o,
      DATA2R_o         => DATA2R_o,
      DPOS_PGOOD       => DPOS_PGOOD,
      ACLK_and_TILES_CLK_EN => ACLK_and_TILES_CLK_EN,
      Power_en          => Power_en,  -- 22/12/2022
      SPI_ERRs         => SPI_ERRs--add by Dalit 10/10/2023
      );


  misc_pr: process (clk64_c3) is
  begin  -- process misc_pr
    if (clk64_c3'event and clk64_c3 = '1') then  -- rising clock edge

      footer_bit21_32m <= footer_bit21;
      footer_ip_aclk <= ip_aclk_count_i(25 downto 16);

      -- For LA: test, if packet from tiles arrives each IP
      dataG_32m <= dataG;
      dataG_32m_r <= dataG_32m;

      if (dataG_32m(1) = '1' and dataG_32m_r(1) = '0') then
        ip_period_1_sampled <= ip_period_1;
        ip_period_1 <= (others => '0');
      else
        ip_period_1 <= ip_period_1 + 1;
      end if;
      if (dataG_32m(2) = '1' and dataG_32m_r(2) = '0') then
        ip_period_2_sampled <= ip_period_2;
        ip_period_2 <= (others => '0');
      else
        ip_period_2 <= ip_period_2 + 1;
      end if;


      -- !debug: 28/03/2022 only for LA, remove
      aclk_from_tile_1 <= ip_aclk_count_i(25 downto 16);
      aclk_from_tile_2 <= ip_aclk_count_i(41 downto 32);
      if (conv_integer(aclk_from_tile_1) < 286 or
          conv_integer(aclk_from_tile_1) > 290) then
        bad_aclk_1 <= '1';
      else
        bad_aclk_1 <= '0';
      end if;
      if (conv_integer(aclk_from_tile_2) < 286 or
          conv_integer(aclk_from_tile_2) > 290) then
        bad_aclk_2 <= '1';
      else
        bad_aclk_2 <= '0';
      end if;


      -- 29/12/2021
      if (IP64_vec(2) = '1' and IP64_vec(1) = '0') then
        mon_cnt <= (mon_cnt + 1) mod 4;
      end if;
      if (mon_cnt = 0) then
        if (num_of_tiles = X"6") then
          power_monitor_mux <= X"1000";
        else
          power_monitor_mux <= X"1" & power_monitor_footer(3*12+11 downto 3*12); -- 22/08/2022 reversed order
          power_monitor_mux(11) <= not Tile_data_locked_i(3);
        end if;
      end if;
      if (mon_cnt = 1) then
        power_monitor_mux <= X"2" & power_monitor_footer(2*12+11 downto 2*12);
        power_monitor_mux(11) <= not Tile_data_locked_i(2);
      end if;
      if (mon_cnt = 2) then
        power_monitor_mux <= X"4" & power_monitor_footer(1*12+11 downto 1*12);
        power_monitor_mux(11) <= not Tile_data_locked_i(1);
      end if;
      if (mon_cnt = 3) then
        if (num_of_tiles = X"6") then
          power_monitor_mux <= X"8000";
        else
          power_monitor_mux <= X"8" & power_monitor_footer(0*12+11 downto 0*12);
          power_monitor_mux(11) <= not Tile_data_locked_i(0);
        end if;
      end if;

      calib_ctl_reg_tr <= calib_ctl_reg_masked(15) and calib_ctl_reg_masked(11);
      do_tests <= (calib_ctl_reg_masked(15) and calib_ctl_reg_masked(11)) and not calib_ctl_reg_tr;

      if (do_tests = '1') then                    -- !TODO: 05/01/2022 add driver
        test_in_progress_cnt <= 200;
        -- synthesis translate_off
        test_in_progress_cnt <= 2;
        -- synthesis translate_on
      elsif (IP64_vec(2) = '1' and IP64_vec(1) = '0') then -- 05/01/2022
        if (test_in_progress_cnt > 0) then
          test_in_progress_cnt <= test_in_progress_cnt - 1;
        end if;
      end if;

      if (test_in_progress_cnt > 0) then
        test_in_progress <= '1';
      else
        test_in_progress <= '0';
      end if;

      registers_test_result_r <= registers_test_result;
      if (do_tests = '1') then
        footer_bit22_32m <= '0';        -- clear error
      elsif ((num_of_tiles = X"F" and registers_test_result_r /= X"0") or -- !debug: 02/02/2022
             (num_of_tiles = X"6" and (registers_test_result_r(1) /= '0' or registers_test_result_r(2) /= '0'))) then
        footer_bit22_32m <= '1';
      end if;

      -- !TODO: 05/01/2022 footer_bit23_32m
      if (do_tests = '1') then
        ip_timeout_cnt <= 2**17;
        -- synthesis translate_off
        ip_timeout_cnt <= 2**13; -- !debug: 06/01/2022 small time - force error
        -- synthesis translate_on
        noip_tmp <= TRUE;
      elsif (ip_timeout_cnt > 0) then
        ip_timeout_cnt <= ip_timeout_cnt - 1;
        if (IP64_vec(2) = '1' and IP64_vec(1) = '0') then -- 05/01/2022
          noip_tmp <= FALSE;
        end if;
      end if;

      if (do_tests = '1') then
        footer_bit23_32m <= '0';            -- clear status
      elsif (data_test_result_r /= X"0") then -- Data Error
        footer_bit23_32m <= '1';
      elsif (power_monitor_mux(10 downto 0) /= (0 to 10 => '0')) then -- Power Status Error
        footer_bit23_32m <= '1';
      elsif (overhead_bits_43_40_r /= X"0") then -- SPI Error
        footer_bit23_32m <= '1';
      elsif (ip_timeout_cnt = 0 and noip_tmp) then -- no IP Error
        footer_bit23_32m <= '1';
      end if;

      if (num_of_tiles = X"6") then
        overhead_bits_43_40_r <= '0' & overhead_bits_i(41) & overhead_bits_i(42) & '0';
        data_test_result_r <= '0' & data_test_result(2 downto 1) & '0';
      else
        overhead_bits_43_40_r <= overhead_bits_i(40) & overhead_bits_i(41) & overhead_bits_i(42) & overhead_bits_i(43); -- SPI status 22/08/2022 reversed order
        data_test_result_r <= data_test_result;
      end if;

      if (AMS_CrcError = X"0") then
        overhead_bit_0 <= '0';
      else
        overhead_bit_0 <= '1';
      end if;
      if (tiles_crc_clear_reg = '1') then -- !TODO: 20/07/2022 clear cmd: write to CREG (JTAG_dev.updatereg1), write to register 0x279[1]
        overhead_bit_0_32m <= '0';      -- clear
      elsif (overhead_bit_0 = '1') then
        overhead_bit_0_32m <= '1';
      end if;

      -- 31/07/2022 num_of_tiles must be latched after bit alignment
      start_rx_sync_32m <= start_align_reg(0);
      -- synthesis translate_off
      -- start_rx_sync_32m <= << signal .rx_ams_tiles_tb.start_align_reg : std_logic >>; -- !debug: 14/03/2023 only for simulation
     --- [Raghda kais - removed - no need for ompilation] start_rx_sync_32m <= << signal ^.^.start_align_reg : std_logic >>; -- !debug: 14/03/2023 only for simulation
      -- synthesis translate_on
      if (start_rx_sync_32m = '1') then
        if (IP64_vec(2) = '1' and IP64_vec(1) = '0') then
          if (delay_ipx_cnt /= 1) then
            delay_ipx_cnt <= delay_ipx_cnt - 1;
            latch_num_of_tiles_en <= FALSE;
          elsif (not latch_num_of_tiles_dis) then
            latch_num_of_tiles_en <= TRUE;
          end if;
        end if;
      else
        delay_ipx_cnt <= 5;
      end if;

      -- !debug: 31/07/2022 old version: num_of_tiles latched after calibration
      -- if (calib_ctl_reg(15) = '1' and not latch_num_of_tiles_dis) then
      --   latch_num_of_tiles_en <= TRUE;
      -- end if;

      -- force4tiles <= diag_reg(5); -- !debug: 06/12/2021 conflict with  slice_builder.aclk_as_1st_pixel
      if (force4tiles = '1') then
        num_of_tiles <= X"F";
      -- elsif (latch_num_of_tiles_en and dataG_32m(2 downto 1) = "11") then -- when latched after calibration
      --   num_of_tiles <= overhead_bits_i(63 downto 60) and dataG_32m;
      --   latch_num_of_tiles_dis <= TRUE;
      elsif (latch_num_of_tiles_en and not latch_num_of_tiles_dis) then -- when latched after bit alignment
        num_of_tiles <= Tile_data_locked_i;
        latch_num_of_tiles_dis <= TRUE;
      end if;

      if (ms_spi_sel = '1' or start_align_reg(3) = '1') then -- !debug: 30/05/2023 was (ms_spi_sel = '1')
        calib_ctl_reg_masked <= calib_ctl_reg;
        wrreq_masked <= wrreq;
      else
        calib_ctl_reg_masked <= X"0000"; -- disable send to SPI, if ASIC not selected
        wrreq_masked <= "00";            -- disable send to SPI, if ASIC not selected
        -- wrreq_masked <= wrreq; -- !debug: 06/12/2023 check, if this OK
      end if;

      AMS_CrcError_r <= AMS_CrcError;
      for i in 0 to 3 loop
        if (AMS_CrcError_r(i) = '0' and AMS_CrcError(i) = '1' and AMS_CrcError_cnt(4*i+3 downto 4*i) /= 15) then
          AMS_CrcError_cnt(4*i+3 downto 4*i) <= AMS_CrcError_cnt(4*i+3 downto 4*i) + 1;
        end if;
      end loop;  -- i
      

      
    end if;
  end process misc_pr;

  AMS_CrcOk_o <= AMS_CrcOk;
  AMS_CrcError_o <= AMS_CrcError; --- add by Dalit 10/10/2023
  AMS_CrcError_counter_o <= std_logic_vector(AMS_CrcError_cnt); ---AMS_CrcError_o changed by Dalit 10/10/2023
  
  overhead_bits(63 downto 60) <= num_of_tiles; -- number of tiles
  -- overhead_bits(59 downto 44) <= overhead_bits_i(59 downto 44); -- calibration status
  overhead_bits(59 downto 44) <= raw_data_bypass(3) & calib_completed(4*3+2) & calib_completed(4*3+0) & calib_completed(4*3+3) &
                                 raw_data_bypass(2) & calib_completed(4*2+2) & calib_completed(4*2+0) & calib_completed(4*2+3) &
                                 raw_data_bypass(1) & calib_completed(4*1+2) & calib_completed(4*1+0) & calib_completed(4*1+3) &
                                 raw_data_bypass(0) & calib_completed(4*0+2) & calib_completed(4*0+0) & calib_completed(4*0+3); -- 13/06/2022 calibration status
  overhead_bits(43 downto 40) <= overhead_bits_43_40_r; -- SPI status
  overhead_bits(39 downto 24) <= power_monitor_mux; -- !debug: 29/12/2021 was  overhead_bits_i(39 downto 24); -- Power Status
  overhead_bits(23 downto 20) <= footer_bit23_32m & footer_bit22_32m & footer_bit21_32m & test_in_progress; -- Test Results & Test In Progress
  overhead_bits(19 downto 10) <= footer_ip_aclk; -- number of Aclk (from 2nd tile)
  overhead_bits(9 downto 1) <= overhead_bits_i(9 downto 1); -- driven from top
  overhead_bits(0) <= overhead_bit_0_32m;  -- 18/07/2022

  AMS_Time <= ip_aclk_count_i;


process(RESET_N,clk64_c3)
	begin
		if (RESET_N = '0') then
				IP64_vec<=(others=>'0');
		elsif rising_edge(clk64_c3) then
			if IP='1' then
				IP64_vec<=(others=>'1');
			else
				IP64_vec<=IP64_vec(4 downto 0) & '0';
			end if;
		end if;
end process;


misc20m_pr: process(NRST_20M, clk20_c2)
begin
  if (NRST_20M = '0') then
    IP20_v <= "000";  -- 23/05/2021
    RX_det_o <= (others => '0');
    data_valid_o <= (others => '0');
    test_status_reg <= (others => '0');
    footer_bit21 <= '0';
    pass_addr_test_err <= (others => '0');
    pass_addr_test_20m <= (others => '0');
    num_of_tiles_20m <= (others => '0');
    idelayctrl_rdy_20m <= '0';
    tiles_rx_reset_n <= '0';
    synthetic_data_from_asic <= '0'; 
  elsif rising_edge(clk20_c2) then

    IP20_v <= IP20_v(1 downto 0) & IP64_vec(4);

    -- bypass_lut <= diag_reg(3);          -- 14/07/2021
    -- if (bypass_lut = '1') then
      RX_det_o <= rx_det_i;
      data_valid_o <= data_valid;
    -- else
    --   RX_det_o <= RX_det_lut;
    --   data_valid_o <= data_valid_lut;
    -- end if;

    pass_addr_test_20m <= pass_addr_test;
    num_of_tiles_20m <= num_of_tiles;

    -- 10/08/2021
    for i in 0 to 3 loop

      if (pass_addr_test_20m(i) = '0') then
        pass_addr_test_delay(i) <= 10;   -- 1st IP after pass_addr_test yet no test data
        -- synthesis translate_off
        pass_addr_test_delay(i) <= 2;   -- 1st IP after pass_addr_test yet no test data
        -- synthesis translate_on
      elsif (IP20_v(2 downto 1) = "01" and pass_addr_test_delay(i) /= 0) then
        pass_addr_test_delay(i) <= pass_addr_test_delay(i) - 1;
      end if;

      if (IP20_v(2 downto 1) = "01") then
        channel_cnt(i) <= 0;
        if (pass_addr_test_err(i) = '1') then
          test_status_reg(i) <= '1';    -- reg 0x74
        end if;
        if (pass_addr_test_delay(i) = 9) then -- clear, when new test
          pass_addr_test_err(i) <= '0';
        end if;
        -- synthesis translate_off
        if (pass_addr_test_delay(i) = 1) then -- clear, when new test
          pass_addr_test_err(i) <= '0';
        end if;
        -- synthesis translate_on
      else
        if (pass_addr_test_delay(i) < 8 and data_valid(i) = '1' and channel_cnt(i) < 256) then
          channel_cnt(i) <= channel_cnt(i) + 1;
        end if;
        if (pass_addr_test_delay(i) < 8 and data_valid(i) = '1' and channel_cnt(i) /= 256 and
            unsigned(rx_det_i(i*26+25 downto i*26)) /= conv_unsigned(channel_cnt(i),26)) then
          if (num_of_tiles_20m = X"6" and (i = 0 or i = 3)) then
            pass_addr_test_err(i) <= '0';
          else
            pass_addr_test_err(i) <= '1';
          end if;
        end if;
        -- synthesis translate_off
        if (pass_addr_test_delay(i) = 0 and data_valid(i) = '1' and channel_cnt(i) /= 256 and
            unsigned(rx_det_i(i*26+25 downto i*26)) /= conv_unsigned(channel_cnt(i),26)) then
          if (num_of_tiles_20m = X"6" and (i = 0 or i = 3)) then
            pass_addr_test_err(i) <= '0';
          else
            pass_addr_test_err(i) <= '1';
          end if;
        end if;
        -- synthesis translate_on
      end if;

    end loop;  -- i

    if (pass_addr_test_err /= X"0") then
      footer_bit21 <= '1';
    else
      footer_bit21 <= '0';
    end if;

    -- wr2dpr_ready_0 <= wr2dpr_ready;     -- 23/05/2022
    -- wr2dpr_ready_1 <= wr2dpr_ready_0;
    -- wr2dpr_ready_2 <= wr2dpr_ready_1;
    -- wr2dpr_ready_3 <= wr2dpr_ready_2;

    if (IS_MASTER_ASIC) then
      idelayctrl_rdy_20m <= idelayctrl_rdy;
    else
      idelayctrl_rdy_20m <= idelayctrl_rdy_i;
    end if;
    tiles_rx_reset_n <= NRST_20M and idelayctrl_rdy_20m; -- 26/07/2022

    if (ams_test_pattern_en = (ams_test_pattern_en'reverse_range => '0')) then -- 25/06/2024
      synthetic_data_from_asic <= '0';
    else
      synthetic_data_from_asic <= '1';
    end if;
    
  end if;
end process misc20m_pr;



 IP20		<=	IP20_v(2) ;
 IP20_o	<=	IP20_v(2) ;
 IP50_o	<=  IP64_vec(4);

-- -- 14/06/2021 LUT + DPR
-- lut_dpr_g : for i in 0 to (NumOfTiles-1) generate
--
--   lut_ctl_pr : process (clk20_c2, NRST_20M) is
--   begin  -- process lut_ctl_pr
--     if (NRST_20M = '0') then                         -- asynchronous reset (active low)
--       map4ams_lut_addr(i)       <= (others => '0');
--       data_valid_r(i)           <= '0';
--       wr2dpr_ready(i)           <= '0';
--       det_arrange_dpr_rdaddr(i) <= (others => '0');
--       data_valid_from_dpr(i)    <= '0';
--       last_rd(i) <= '0';
--       data_valid_lut(i) <= '0';
--     elsif (clk20_c2'event and clk20_c2 = '1') then  -- rising clock edge
--
--       if (IP20_v(2) = '1') then
--         map4ams_lut_addr(i) <= (others => '0');
--       elsif (data_valid(i) = '1') then
--         map4ams_lut_addr(i) <= map4ams_lut_addr(i) + 1;  -- mem depth according num of detectors
--       end if;
--
--       data_valid_r(i) <= data_valid(i);
--
--       if (IP20_v(2) = '1') then
--         wr2dpr_ready(i) <= '0';
--       elsif (map4ams_lut_addr(i) = X"FF") then
--         wr2dpr_ready(i) <= '1';         -- enable read from DPR
--       end if;
--
--       if (IP20_v(2) = '1') then
--         det_arrange_dpr_rdaddr(i) <= (others => '0');
--       elsif (wr2dpr_ready_3(i) = '1') then -- !debug: 23/05/2022 was wr2dpr_ready(i)
--         if (det_arrange_dpr_rdaddr(i) < X"FF") then
--           det_arrange_dpr_rdaddr(i) <= det_arrange_dpr_rdaddr(i) + 1;
--         end if;
--       end if;
--       -- rx_det_dummy <= det_arrange_dpr_rdaddr(7 downto 3); -- !debug: 06/10/2021
--
--       if (IP20_v(2) = '1') then
--         data_valid_from_dpr(i) <= '0';
--         last_rd(i) <= '0';
--       elsif (wr2dpr_ready_3(i) = '1') then -- !debug: 23/05/2022 was wr2dpr_ready(i)
--         if (det_arrange_dpr_rdaddr(i) < X"FF") then
--           data_valid_from_dpr(i) <= '1';
--           last_rd(i) <= '0';
--         else
--           data_valid_from_dpr(i) <= '0';
--           last_rd(i) <= data_valid_from_dpr(i);
--         end if;
--       else
--         data_valid_from_dpr(i) <= '0';
--       end if;
--
--       data_valid_lut(i) <= data_valid_from_dpr(i) or last_rd(i); -- !debug: 11/07/2021
--
--     end if;
--   end process lut_ctl_pr;
--
--   map4ams_lut_1 : map4ams_lut
--     port map (
--       clka  => clk20_c2,
--       addra => map4ams_lut_addr(i),
--       douta => map4ams_det_num(i)       -- decoded address
--       );
--
--   det_arrange_dpr_1 : det_arrange_dpr
--     port map (
--       clka   => clk20_c2,
--       wea(0) => data_valid_r(i),
--       addra  => map4ams_det_num(i),
--       dina   => rx_det_i(i*26+25 downto i*26),  -- data before LUT + DPR
--       clkb   => clk20_c2,
--       addrb  => det_arrange_dpr_rdaddr(i),
--       doutb  => RX_det_lut(i*26+25 downto i*26)   -- data after LUT + DPR
--       );
--
-- end generate lut_dpr_g;

-- data_valid_o   <=  data_valid;

-- !debug: 06/10/2021 usage: disconnect det_arrange_dpr.doutb, then connect const data
-- RX_det_lut(0*26+25 downto 0*26) <= 26UX"0000A00";
-- RX_det_lut(1*26+25 downto 1*26) <= 26UX"0001000";
-- RX_det_lut(2*26+25 downto 2*26) <= 26UX"0004000";
-- RX_det_lut(3*26+25 downto 3*26) <= 26UX"0008000";

END architecture behave;
