--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.Phoebe.all;
-------------------------------------------------------------------------------

ENTITY phoebe_controller IS
    GENERIC(
    	WORD_WIDTH1	: integer  := 14;
      WORD_WIDTH2	: integer  := 15
    );
    PORT(
      RESET_N           : in  std_logic;
      clk               : in  std_logic;
      ACLK_Master       : in  std_logic;                       -- 05/04/2021
      locked_fast       : in  std_logic;
      DiscardIP         : in  std_logic;
      Discardo          : out std_logic; -- to SPI
      IP                : in  std_logic;
      SYNCo             : out std_logic; -- to SPI
      ACLKo             : out std_logic; -- to SPI
      AMS_Time          : out std_logic_vector (15 downto 0);  -- 08/04/2021 NU, uses ip_aclk_count value from tile
      SPI_BUS_CTRL      : in  std_logic_vector(39 downto 0);
      CNT_lines         : in  std_logic_vector (15 downto 8);
      SPICTRLencoder    : out std_logic_vector(3 downto 0);
      EXE               : out std_logic;
      Address           : out std_logic_vector(WORD_WIDTH1-1 downto 0);
      DATA2W            : out std_logic_vector(WORD_WIDTH2-1 downto 0);
      RWn               : out std_logic;
      BUSY              : in  std_logic;
      READ_OUT_ready    : in  std_logic;
      DATA2R            : in  std_logic_vector(WORD_WIDTH2-1 downto 0);
      Tile_reset        : out std_logic; -- to SPI
      fifo_clear        : out std_logic; -- 23/11/2022 to regs_fifo
      rst_seq_end       : in  std_logic; -- NU
      Bias              : in  std_logic;
      Calib             : in  std_logic_vector(2 downto 0);    -- NU
      calib_ctl_reg     : in  std_logic_vector(15 downto 0);   -- 10/05/2021
      diag_reg          : in std_logic_vector(15 downto 0);   -- 07/11/2021 [15..8] only for debug
      exit_from_asic_reset : in std_logic;                  -- 20/04/2023
      calib_completed   : in std_logic_vector(3 downto 0); -- 12/03/2025
      calib_busy_o      : out std_logic;                       -- 05/07/2021
      -- calib_monitor_reg : out std_logic_vector(WORD_WIDTH2-1 downto 0);    -- 21/06/2021
      power_monitor_reg : out std_logic_vector(11 downto 0);   -- 23/06/2021
      -- init_seq_end      : out std_logic;                       -- 23/06/2021
      pass_addr_test    : out std_logic;                       -- 09/08/2021
      -- registers_test    : out std_logic;                       -- 05/01/2022
      registers_test_result : out std_logic;                   -- 05/01/2022
      RAM_rd_en         : out std_logic_vector (1 downto 0);   -- 11/05/2021 [0] - NU, [1] - regs_fifo
      RAM_rd_en_o       : out std_logic; -- 29/06/2021
      RAM_address       : out std_logic_vector (13 downto 0);  -- 11/05/2021 NU
      rst_ctrl          : out std_logic_vector(NumOfTiles-1 downto 0);
      fifo_status       : in  std_logic;
      Tile_ready2sync   : out std_logic;
      DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
      ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
      Power_en          : out std_logic_vector (2 downto 0) -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
      );
end phoebe_controller;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ARCHITECTURE behave OF phoebe_controller IS
-------------------------------------------------------------------------------



	--SIGNAL busy_int              : std_logic;
	SIGNAL Instruction_int       : std_logic_vector(WORD_WIDTH1-1 downto 0);
	SIGNAL DATA2W_int			 : std_logic_vector(WORD_WIDTH2-1 downto 0);
	SIGNAL RWn_int               : std_logic;
	SIGNAL EXE_int               : std_logic;
	SIGNAL SPICTRLencoderi       : std_logic_vector(3 downto 0);
	-- SIGNAL ACLK_int              : std_logic;
  -- SIGNAL clk_cnt               : integer range 0 to 127;
	SIGNAL t_reset_cnt           : std_logic_vector(15 downto 0):=x"FFFF"; -- ES: tiles reset time
	type   sm_type               is (idle,Wait_For_Pll,Wait_for_t_reset,Wait_for_power_en,RESET_sequence,Settle_time_After_RST,Config_regs,Tile_ready,Tile_bias,Tile_calib,Tile_Power_Status);
	SIGNAL sm_powerup            : sm_type;
	type   configuring_sm_type   is (idle,rd_request,get_params,load_params,exe_st,Wait_for_end,DONE);
	type   configuring_sm_type2   is (idle,calib_sequencer,get_params,load_params,Wait_for_ans,Wait_for_end,DONE);
	type   configuring_sm_type3   is (idle,load_params,Wait_for_ans,Wait_for_end,DONE);
	SIGNAL configuring_sm_cfg    : configuring_sm_type;
	SIGNAL configuring_sm_bias   : configuring_sm_type;
	SIGNAL configuring_sm_calib  : configuring_sm_type2;
	SIGNAL configuring_sm_regs   : configuring_sm_type;
	SIGNAL configuring_sm_power  : configuring_sm_type3;
	SIGNAL counter_delay         : std_logic_vector(15 downto 0);           -- ES: powerup
	constant delay               : std_logic_vector(15 downto 0):= x"007f";--liron for simulation
                                                                         --!debug: 05/04/2021 x"00ff" -> x"007F"
	constant t_reset_cnt_num     : std_logic_vector(15 downto 0):=x"007F"; --liron for simulation
                                                                         --!debug: 05/04/2021 x"00ff" -> x"007F"
	SIGNAL Tile_reset_int        : std_logic;
	SIGNAL Settle_time_cnt       : std_logic_vector(15 downto 0):= x"ffff";
	SIGNAL rst_seq_end_int       : std_logic;
	SIGNAL cfg_seq_end_int       : std_logic;
	-- SIGNAL clk_cnt_pos_edge      : std_logic:='0';
	SIGNAL clk_cnt_neg_edge      : std_logic:='0';
	SIGNAL PLL_vec               : std_logic_vector(3 downto 0):= x"0";
	SIGNAL reserved1             : std_logic_vector(1 downto 0):= "00";
	SIGNAL reserved2,reserved3   : std_logic:= '0';
	SIGNAL Skip					 : std_logic:= '0';
	SIGNAL discard_int,sync_int  : std_logic :='0';
	signal sync_int_r0, sync_int_r1 : std_logic :='0';
	Signal RAM_address_int       : std_logic_vector(13 downto 0) ;
	Signal RAM_rd_en_int         : std_logic_vector(1 downto 0);
	Signal RAM_rd_en_int_s,RAM_rd_en_int_ss       : std_logic_vector(1 downto 0) ;
	signal Busy_vec              : std_logic_vector(3 downto 0) ;
	constant RAM_address_int_end : std_logic_vector(15 downto 0):=x"001f";
	constant RAM_address_cal_end: std_logic_vector (4 downto 0):="11111";
  signal bias_int              : std_logic :='0';
	signal calib_int             : std_logic_vector(2 downto 0) :="000";
	signal calib_d               : std_logic_vector(2 downto 0) :="000";
	signal bias_ready            : std_logic :='0';
	signal calib_ready           : std_logic :='0';
	signal IP_hold               : std_logic :='0';
	signal DiscardIP_hold		 : std_logic :='0';
	signal fifo_status_s		 : std_logic :='0';
	signal time_out_timer        : std_logic_vector(27 downto 0):=x"0000000";

	signal IP_v              : std_logic_vector(3 downto 0) ;


-------------------------------------------------------------------------------

    signal aclk_master_shr : std_logic_vector(2 downto 0); -- 05/04/2021
    signal aclk_cnt : natural range 0 to 2**15;

    -- 10/05/2021
    type CALIB_ENTRY_TYP is record          -- for calibration sequencer
      calib_address : std_logic_vector(7 downto 0);
      calib_data    : std_logic_vector(15 downto 0);
      calib_rw      : std_logic;          -- note: wait when calib_rw ='1' and calib_data = X"FFFF",
                                          -- in this case address - wait time LSB 0.02 seconds
    end record CALIB_ENTRY_TYP;

    type CALIB_SEQ_TYP is array (positive range <>) of CALIB_ENTRY_TYP;
    constant offset_cal_c : CALIB_SEQ_TYP := ((X"54",X"000A",'0'),(X"53",X"1009",'0'), -- Offset voltage
                                              (X"52",X"0000",'0'),(X"52",X"0004",'0'),
                                              (X"01",X"FFFF",'1'), (X"52",X"0000",'0')); -- !debug: 28/05/2023 10 ms AMS requirement
    constant linearity_cal_c : CALIB_SEQ_TYP := ((X"57",X"03E8",'0'),(X"4D",X"0018",'0'), -- Linearity
                                                 (X"53",X"1100",'0'),(X"52",X"0001",'0'),
                                                 (X"52",X"0005",'0'),(X"FA",X"FFFF",'1'), -- X"FA" - 5Sec
                                                 (X"52",X"0000",'0'),(X"53",X"1000",'0'));
    constant leakage_cal_c : CALIB_SEQ_TYP := ((X"56",X"0200",'0'),(X"4D",X"0000",'0'), -- Offset current
                                               (X"53",X"1300",'0'),(X"52",X"0003",'0'),
                                               (X"52",X"0007",'0'),(X"03",X"FFFF",'1'), -- X"03" - 60mS
                                               (X"52",X"0000",'0'),(X"53",X"1000",'0'));
    constant array_cal_c : CALIB_SEQ_TYP := ((X"56",X"0200",'0'),(X"56",X"0000",'1'), -- Array delta calibration (NU from 23/03/2022)
                                             (X"53",X"1300",'0'),(X"53",X"1000",'1'),
                                             (X"52",X"0008",'0'),(X"52",X"000C",'0'),
                                             (X"05",X"FFFF",'1'),(X"52",X"0000",'0'),
                                             (X"53",X"1000",'0'),(X"53",X"1000",'1'),
                                             (X"58",X"0000",'1'));

    -- constant pass_addr_seq_c : CALIB_SEQ_TYP := ((X"12",X"2D60",'0'),(X"10",X"0003",'0'), -- Pass Address Test
    --                                         (X"1F",X"0355",'0'),(X"13",X"2211",'0'),
    --                                         (X"14",X"0866",'0'),(X"15",X"0155",'0'),
    --                                         (X"16",X"0098",'0'),(X"17",X"0000",'0'), -- !debug: 10/11/2022 temporary 17 (LVDS_CONFIG_3) X"1000 -> X"0000"
    --                                         (X"24",X"0000",'1'),(X"20",X"0000",'0'),
    --                                         (X"21",X"0000",'0'),(X"22",X"0010",'0'), -- !debug: 10/11/2022 temporary  22 TEST_PATTERN_2 X"0110" -> X"0010" Disable test pattern generator
	--     									   (X"22",X"0000",'1'),(X"0E",X"0000",'1'));
    constant pass_addr_seq_c : CALIB_SEQ_TYP := ((X"10",X"0003",'0'),(X"12",X"2D60",'0'), -- Pass Address Test
                                            (X"1F",X"0355",'0'),(X"13",X"2211",'0'),
                                            (X"14",X"0866",'0'),(X"15",X"0155",'0'),
                                            (X"16",X"0098",'0'),(X"17",X"0000",'0'), -- !debug: 10/11/2022 temporary 17 (LVDS_CONFIG_3) X"1000 -> X"0000"
                                            (X"20",X"2200",'0'),
                                            (X"21",X"0866",'0'),(X"22",X"0011",'0')); -- !debug: 10/11/2022 temporary  22 TEST_PATTERN_2 X"0110" -> X"0010" Disable test pattern generator
                                                                                      -- [8] - pattern_en, [6..4] - pattern_mode

    constant reg_seq_c : CALIB_SEQ_TYP := ((X"20",X"AA55",'0'),(X"21",X"8C4D",'0'), -- Regiters test
                                           (X"20",X"0000",'1'),(X"21",X"0000",'1'));


    signal calib_seq_cnt : natural range 0 to 7;
    signal calib_exec_cnt : positive range 1 to 31;
    signal calib_busy : boolean;
    signal calib_address : std_logic_vector(7 downto 0);
    signal calib_data	 : std_logic_vector(15 downto 0);
    signal calib_rw	 : std_logic;
    signal busy4ready : boolean;
    signal do_calib, do_tests, calib_ctl_reg_cr, calib_ctl_reg_tr : std_logic;
    signal calib_wait_cnt, calib_complete_cnt : natural range 0 to 2**28 - 1; -- const delay
    signal calib_monitor_running : boolean;
    -- signal init_seq_end_shr : std_logic_vector(3 downto 0) := (others => '0');
    signal do_power_check : boolean;
    signal power_status_ready : std_logic;
    signal test_mode_pass_address, test_mode_registers : boolean;
    signal calib_monitor_min_delay : natural range 0 to 2**16; -- calibration timing: 200, 10, 200, 5
    signal tiles_soft_reset : std_logic_vector(2 downto 0);    -- 07/10/2021
    signal calib_analize_cnt : natural range 0 to 2**30;
    signal test_wait_reg  : std_logic_vector(7 downto 0); -- !TODO: 07/11/2021 remove after test

    signal Expected_AA55, Expected_8C4D : std_logic_vector(WORD_WIDTH2-1 downto 0);

    attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of Tile_reset, fifo_clear : signal is "TRUE";
    attribute DONT_TOUCH of calib_ready, calib_monitor_running, calib_complete_cnt, READ_OUT_ready, calib_busy,
       calib_analize_cnt, calib_exec_cnt, calib_seq_cnt, calib_monitor_min_delay, aclk_cnt, EXE, configuring_sm_calib : signal is "TRUE";
    attribute mark_debug : string;
    attribute mark_debug of calib_ready, calib_monitor_running, calib_complete_cnt, READ_OUT_ready, calib_busy,
       calib_analize_cnt, calib_exec_cnt, calib_seq_cnt, calib_monitor_min_delay, aclk_cnt, EXE, configuring_sm_calib : signal is "TRUE";
    -- attribute mark_debug of aclk_cnt, AMS_Time, SYNCo, ACLKo : signal is "true";

    -- !debug: 22/12/2022  ASIC Power Sequence Test
    signal power_en_cnt : natural range 0 to 2**20;
    signal power_en_seq_shr : std_logic_vector(4 downto 0);
    signal free_running_1_5_us_cnt : natural range 0 to 127;

BEGIN


-------------------------------------------------------------------------------
--ACLK_genearation discard and sync sample with falling edge of ACLK
----------------------------------------------------

	process(RESET_N,clk)
	begin
		if (RESET_N = '0') then

			-- ACLK_int<='0';
			-- clk_cnt<=0;
			-- clk_cnt_pos_edge<='0';
			-- clk_cnt_neg_edge<='0';
			sync_int<='0';
			sync_int_r0<='0';
			sync_int_r1<='0';
			discard_int<='0';
			IP_hold<='0';
			DiscardIP_hold<='0';
			IP_v<=(others=>'0');
      aclk_master_shr <= (others=>'0');
      aclk_cnt <= 0;
      AMS_Time <=(others=>'0');
		elsif rising_edge(clk) then

			-- IF (clk_cnt = (C_CLK_MAX-1)) THEN
			--   clk_cnt <= 0;
			-- ELSE
			--   clk_cnt <= clk_cnt +1;
			-- END IF;
			-- IF (clk_cnt = 0) THEN
			--   clk_cnt_pos_edge <= '1';
			-- ELSE
			--   clk_cnt_pos_edge <= '0';
			-- END IF;
			-- IF (clk_cnt = ((C_CLK_MAX) /2)) THEN
			--   clk_cnt_neg_edge <= '1';
			-- ELSE
			--   clk_cnt_neg_edge <= '0';
			-- END IF;

			-- if clk_cnt_pos_edge ='1' then
			--   ACLK_int<='1';
			-- elsif clk_cnt_neg_edge='1' then
			--     ACLK_int<='0';
			-- end if;

			IP_v(3 downto 0)	<=	IP_v(2 downto 0) & IP;

			--------------------------
			if IP_v(3 downto 2) = "01" and (sm_powerup=Tile_ready or sm_powerup=Tile_calib or sm_powerup=Tile_bias or sm_powerup=Tile_Power_Status) then
				IP_HOLD<='1';
      -- synthesis translate_off
      elsif (IP_v(3 downto 2) = "01") then
        IP_HOLD<='1';
      -- synthesis translate_on
			elsif sync_int ='1' then     --debug!!
				IP_HOLD<='0';
			end if;
			-----------------------------
			if DiscardIP = '1' then
				DiscardIP_hold<='1';
			elsif Discard_int ='1' then    --debug!!
				DiscardIP_hold<='0';
			end if;


			if clk_cnt_neg_edge='1'and (sm_powerup=Tile_ready or sm_powerup=Tile_calib or sm_powerup=Tile_bias or sm_powerup=Tile_Power_Status) then
			   Discard_int<=DiscardIP_hold;
			  -- sync_int<=IP	;
			   sync_int<=IP_hold;
      -- synthesis translate_off
      elsif (clk_cnt_neg_edge='1') then
			   Discard_int<=DiscardIP_hold;
			   sync_int<=IP_hold;
      -- synthesis translate_on
			end if;

      aclk_master_shr <= aclk_master_shr(1 downto 0) & ACLK_Master; -- 05/04/2021
      if (sync_int = '1') then
        aclk_cnt <= 0;
        if (IP_hold = '1') then
          AMS_Time <= std_logic_vector(conv_unsigned(aclk_cnt,16));    -- 08/04/2021
        end if;
      elsif (clk_cnt_neg_edge = '1') then
        aclk_cnt <= aclk_cnt + 1;
      end if;

        sync_int_r0 <= sync_int;
        sync_int_r1 <= sync_int_r0;

		end if;
	end process;

  SYNCo <= sync_int_r1; -- !debug: 07/07/2021 was sync_int, now delayed external SYNC
  -- SYNCo <= sync_int; -- !debug: 25/08/2021 for AMS v.2 (no delay)
  Discardo<=Discard_int;
  -- ACLKo<= ACLK_Master; -- !debug: 05/04/2021 was  ACLK_int;
  --ACLKo <= aclk_master_shr(1); -- !debug: 25/08/2021 for AMS v.2 force same edge ACLK and SYNC
  ACLKo <= aclk_master_shr(2);  --liron
  --clk_cnt_neg_edge <= aclk_master_shr(1) and not aclk_master_shr(0); -- !debug: 05/04/2021
    clk_cnt_neg_edge <= aclk_master_shr(2) and not aclk_master_shr(1); -- liron
-----------------------------------------------------
Instruction_int    <= SPI_BUS_CTRL(13 downto 0);
reserved1          <= SPI_BUS_CTRL(15 downto 14);
DATA2W_int         <= SPI_BUS_CTRL(30 downto 16);
reserved2          <= SPI_BUS_CTRL(31);
SPICTRLencoderi    <= SPI_BUS_CTRL(35 downto 32);
Skip               <= SPI_BUS_CTRL(36);   --  '0' real ,'1' skip
reserved3          <= SPI_BUS_CTRL(37);
RWn_int            <= SPI_BUS_CTRL(38); -- 0 write 1 read
EXE_int            <= SPI_BUS_CTRL(39);
--------------------------------------------------------

   sm_proc_pr :  process(clk)
	begin
	  if rising_edge(clk) then
       	if (RESET_N   =   '0') then
          RWn	 <= 	  '1';
		  EXE	 <= 	 '0';
       	  DATA2W    <=    (others   =>   '0');
          Address   <=   (others  =>  '0');
		  RAM_address_int  <=  (others => '0');
		  busy_vec <= "0000";
		  configuring_sm_cfg  <= idle;
		  configuring_sm_bias  <= idle;
		  configuring_sm_calib  <= idle;
		  configuring_sm_regs  <= idle;
		  RAM_rd_en_int <= (others=>'0');
		  SPICTRLencoder<="0000";
		  RAM_rd_en_int_s<=(others=>'0');
		  cfg_seq_end_int<='0';
		  calib_ready<='0';
       	  power_status_ready <= '0';
		  fifo_status_s<='0';
		  time_out_timer<=(others=>'0');
       	  calib_exec_cnt <= 1;
       	  calib_seq_cnt <= 0;
       	  calib_address <= (others=>'0');
       	  calib_data <= (others=>'0');
       	  calib_rw <= '0';
       	  test_mode_pass_address <= FALSE;
       	  test_mode_registers <= FALSE;
       	  busy4ready <= false;
       	  calib_wait_cnt <= 0;
          calib_complete_cnt <= 0;
        else

          fifo_status_s<=fifo_status;
          cfg_seq_end_int<='0';
          busy_vec<= busy_vec(2 downto 0)& busy;
          RAM_rd_en_int_s<=RAM_rd_en_int;
          RAM_rd_en_int_ss<=RAM_rd_en_int_s;

          EXE	<=	'0';

          if (do_tests = '1') then
            if (calib_ctl_reg(4) = '1') then
              test_mode_pass_address <= TRUE;
              test_mode_registers <= FALSE;
            elsif (calib_ctl_reg(6) = '1') then
              test_mode_pass_address <= FALSE;
              test_mode_registers <= TRUE;
            end if;
          end if;

			--------------------------------------------

			if sm_powerup = Config_regs then
				--SPICTRLencoder<="0000";
				calib_ready<='0';

				case configuring_sm_cfg is

					when idle 		 =>  	RAM_address_int<=(others=>'0');
											RAM_rd_en_int(0)<='0';
											configuring_sm_cfg <= rd_request;

					when rd_request  =>     RAM_rd_en_int(0)<='1';
											configuring_sm_cfg<=get_params;
					when get_params  =>     RAM_rd_en_int(0)<='0';
											if RAM_rd_en_int_s(0)='1' then
											configuring_sm_cfg<=load_params;
											end if;

					when load_params =>     RAM_rd_en_int(0)<='0';
											RWn<= RWn_int;
											EXE<=EXE_int;
											DATA2W<=DATA2W_int;
											Address<=Instruction_int;
											SPICTRLencoder<=SPICTRLencoderi;
											if EXE_int='1' then
											configuring_sm_cfg<=exe_st;
											else
											configuring_sm_cfg<=rd_request;
											RAM_address_int<=RAM_address_int+1;
												if RAM_address_int=RAM_address_int_end then
													configuring_sm_cfg<=DONE;
												end if;
											end if;


					when exe_st=>
											EXE						<=	EXE_int;
											configuring_sm_regs		<=	Wait_for_end;


					when Wait_for_end=>	    															--	RWn<= '0';
											EXE<='0';
--											DATA2W<=(others=>'0');
											Address<=(others=>'0');
											if busy_vec(3 downto 2) = "10" then
												RAM_address_int<=RAM_address_int+1;
												configuring_sm_cfg<=rd_request;
												if RAM_address_int=RAM_address_int_end then
													configuring_sm_cfg<=DONE;
												end if;
											end if;

					when DONE        =>     RAM_address_int<=(others=>'0');
					                        RAM_rd_en_int(0)<='0';
																										--	RWn<= '0';
											EXE<='0';
--											DATA2W<=(others=>'0');
											Address<=(others=>'0');
											cfg_seq_end_int<='1';

					end case;

				--------------------------------------------------------------------

			elsif sm_powerup= Tile_ready then

				calib_ready<='0';

				case configuring_sm_regs is

					when idle 		 =>  	RAM_address_int<=(others=>'0');
											RAM_rd_en_int(1)<='0';
											if fifo_status_s='0' then
												RAM_rd_en_int(1)<='1';
												configuring_sm_regs <= rd_request;
											end if;

					when rd_request  =>     RAM_rd_en_int(1)<='0';
											configuring_sm_regs<=get_params;

					when get_params  =>     RAM_rd_en_int(1)<='0';

--											if RAM_rd_en_int_s(1)='1' then
											configuring_sm_regs<=load_params;
--											end if;

					when load_params =>     RAM_rd_en_int(1)<='0';
											RWn<= RWn_int;
											EXE<='0';  												--	EXE<=EXE_int;
											Address<=Instruction_int;
											DATA2W<=DATA2W_int;
											SPICTRLencoder<=SPICTRLencoderi;
											-- if EXE_int='1' then
											-- configuring_sm_regs<=Wait_for_end;
											-- else
											-- configuring_sm_regs<=rd_request;
											-- RAM_address_int<=RAM_address_int+1;
											--	if RAM_address_int=RAM_address_int_end then
											configuring_sm_regs<=exe_st;
											--	end if;
											--end if;

					when exe_st=>
                      EXE						<=	EXE_int;
                      configuring_sm_regs		<=	Wait_for_end;
																			--

                    when Wait_for_end=>
                      --	RWn<= '0';			-- ?  aron
                      EXE<='0';
                      -- if busy_vec(3 downto 2)<="10" then
                      if (busy_vec(3 downto 2) = "10") then -- !debug: 13/07/2021
                        configuring_sm_regs<=DONE;
                      end if;

                    when DONE        =>
                      RAM_address_int<=(others=>'0');
                      RAM_rd_en_int(1)<='0';
                      --	RWn<= '0';
                      EXE<='0';
                      configuring_sm_regs<=idle;

                end case;
			-------------------------------------------------------------------
			-- elsif sm_powerup= Tile_bias then
				-- case configuring_sm_bias is
				-- when idle 		 =>  	RAM_address_int<=(others=>'0');
										-- RAM_rd_en_int(0)<='0';
										-- configuring_sm_bias <= rd_request;
				-- when rd_request  =>     RAM_rd_en_int(0)<='1';
										-- configuring_sm_bias<=get_params;
				-- when get_params  =>     RAM_rd_en_int(0)<='0';
										-- configuring_sm_bias<=load_params;
				-- when load_params =>     RAM_rd_en_int(0)<='0';
										-- RWn<= RWn_int;
										-- EXE<=EXE_int;
										-- DATA2W<=DATA2W_int;
										-- configuring_sm_bias<=Wait_for_end;

				-- when Wait_for_end=>	    RWn<= '0';
										-- EXE<='0';
										-- DATA2W<=(others=>'0');
										-- if busy_vec(3 downto 2)<="10" then
											-- RAM_address_int<=RAM_address_int+1;
											-- configuring_sm_bias<=rd_request;
											-- if RAM_address_int=RAM_address_int_end then
												-- configuring_sm_bias<=DONE;
											-- end if;
										-- end if;

				-- when DONE        =>     RAM_address_int<=(others=>'0');
				                        -- RAM_rd_en_int(0)<='0';
				                        -- RWn<= '0';
				                        -- EXE<='0';
				                        -- DATA2W<=(others=>'0');
				                        -- Address<=(others=>'0');
										-- bias_ready<='1';
										-- configuring_sm_bias<=idle;
				-- end case;
-----------------------------------------------------------------------------
            elsif (sm_powerup=Tile_Power_Status) then -- !debug: 23/06/2021
            -- !TODO: 23/06/2021
              case configuring_sm_power is
                when idle =>
                  if (do_power_check) then
                    configuring_sm_power<=load_params;
                  end if;
                  power_status_ready <= '0';
                  time_out_timer<=(others=>'0');

                when load_params =>
				  EXE <= '1';
				  RWn <= '1'; 					   -- RD
				  Address <= "000000" & X"0E"; 	   -- POWER_MONITOR
				  DATA2W  <= (others=>'0');
				  configuring_sm_power <= wait_for_ans;
				  busy4ready <= TRUE;

				when wait_for_ans =>
				  RWn <= '1'; 												--	aron ?
				  EXE <= '0';
				  if (time_out_timer >= x"1ffffff") then  -- !debug: 05/04/2021 x"3ffffff" -> x"1ffffff"
					time_out_timer <= (others => '0');
				  else
					time_out_timer <= time_out_timer+1;
				  end if;

				  if (time_out_timer >= x"1ffffff") then  -- !debug: 05/04/2021 x"3ffffff" -> x"1ffffff"
					configuring_sm_power <= Wait_for_end;
				  elsif (READ_OUT_ready = '1') then -- 12/03/2025  no do_power_check -> FSM in idle
					configuring_sm_power <= Wait_for_end;  -- !debug: 11/05/2021 check DATA2R, when READ_OUT_ready = '1'
				  end if;

				when Wait_for_end =>
				  EXE <= '0';
				  if (busy_vec(1 downto 0) = "10") then -- 12/05/2021
					busy4ready <= FALSE;
				  end if;
				  if (not busy4ready) then -- 12/05/2021
					configuring_sm_power <= DONE;
				  end if;

				when DONE =>
				  EXE <= '0';
				  Address			   <= (others => '0');
				  power_status_ready <= '1';
				  configuring_sm_power <= idle;

              end case;

			elsif (sm_powerup = Tile_calib) then

          if (configuring_sm_calib /= idle) then
            calib_busy <= TRUE;
          elsif (configuring_sm_calib = idle) then
            calib_busy <= FALSE;
          end if;

          if (configuring_sm_calib = get_params) then
            if (calib_seq_cnt = 0 and calib_exec_cnt <= offset_cal_c'HIGH) then        -- !debug: 11/05/2021 A'HIGH vs A'LEFT vs A'LENGTH
              calib_address <= offset_cal_c(calib_exec_cnt).calib_address;
              calib_data    <= offset_cal_c(calib_exec_cnt).calib_data;
              calib_rw      <= offset_cal_c(calib_exec_cnt).calib_rw;
            elsif (calib_seq_cnt = 1 and calib_exec_cnt <= linearity_cal_c'HIGH) then
              calib_address <= linearity_cal_c(calib_exec_cnt).calib_address;
              calib_data    <= linearity_cal_c(calib_exec_cnt).calib_data;
              calib_rw      <= linearity_cal_c(calib_exec_cnt).calib_rw;
            elsif (calib_seq_cnt = 2 and calib_exec_cnt <= leakage_cal_c'HIGH) then
              calib_address <= leakage_cal_c(calib_exec_cnt).calib_address;
              calib_data    <= leakage_cal_c(calib_exec_cnt).calib_data;
              calib_rw      <= leakage_cal_c(calib_exec_cnt).calib_rw;
            elsif (calib_seq_cnt = 3 and calib_exec_cnt <= array_cal_c'HIGH) then
              calib_address <= array_cal_c(calib_exec_cnt).calib_address;
              calib_data    <= array_cal_c(calib_exec_cnt).calib_data;
              calib_rw      <= array_cal_c(calib_exec_cnt).calib_rw;
            elsif (calib_seq_cnt = 4 and calib_exec_cnt <= pass_addr_seq_c'HIGH) then  -- !debug: 30/06/2021 Pass address test 0x0010
              calib_address <= pass_addr_seq_c(calib_exec_cnt).calib_address;
              calib_data    <= pass_addr_seq_c(calib_exec_cnt).calib_data;
              calib_rw      <= pass_addr_seq_c(calib_exec_cnt).calib_rw;
            elsif (calib_seq_cnt = 6 and calib_exec_cnt <= reg_seq_c'HIGH) then        -- !debug: 05/01/2022 registers test 0x0040
              calib_address <= reg_seq_c(calib_exec_cnt).calib_address;
              calib_data    <= reg_seq_c(calib_exec_cnt).calib_data;
              calib_rw      <= reg_seq_c(calib_exec_cnt).calib_rw;
            end if;
          elsif (configuring_sm_calib /= load_params) then
            calib_address <= (others => '0');
            calib_data    <= (others => '0');
            calib_rw <= '0';
          end if;
          -- 11/05/2021 calibration sequence: ^^^

          case configuring_sm_calib is
          when idle =>
            calib_ready<='0';
            if (calib_ready = '0') then
              configuring_sm_calib <= calib_sequencer;
              if (test_mode_pass_address) then
                calib_seq_cnt <= 4;      -- Pass address test
              elsif (test_mode_registers) then
                calib_seq_cnt <= 6;      -- registers test
              end if;
            end if;
            time_out_timer<=(others=>'0');

          when calib_sequencer =>
            if (calib_ctl_reg(calib_seq_cnt) = '1') then
              configuring_sm_calib <= get_params;
            -- elsif not(calib_seq_cnt = 3 and calib_exec_cnt = offset_cal_c'HIGH) then
            elsif (calib_seq_cnt < 3) then
              calib_seq_cnt <= calib_seq_cnt + 1;  -- skip this calibration type
            else
              configuring_sm_calib <= DONE;
            end if;
            time_out_timer<=(others=>'0');
            calib_exec_cnt <= 1;

          when get_params =>
            configuring_sm_calib<=load_params;

          when load_params =>
            -- RWn                  <= RWn_int;
            -- EXE                  <= EXE_int;
            -- Address              <= Instruction_int;
            -- DATA2W               <= DATA2W_int;
            RWn                  <= calib_rw;
            EXE                  <= '1';
            Address              <= "000000" & calib_address;
            DATA2W               <= calib_data(14 downto 0);
            if (calib_rw = '1') then -- RD
              if (calib_data = X"FFFF") then -- special case - wait in place read
                configuring_sm_calib <= Wait_for_end;
                EXE                  <= '0';  -- no operation
                calib_wait_cnt <= 10e5 * conv_integer(calib_address); -- !debug: 30/05/2023 10e5 for 0.02 seconds
                -- calib_wait_cnt <= 32e5 * conv_integer(test_wait_reg); -- !TODO: 07/11/2021 remove after test
                -- synthesis translate_off
                calib_wait_cnt <= 2e2 * conv_integer(calib_address);  -- for simulation only: 1mS
                -- calib_wait_cnt <= 1e3 * conv_integer(test_wait_reg); -- !TODO: 07/11/2021 remove after test
                -- synthesis translate_on
                busy4ready <= FALSE;
              else
                configuring_sm_calib <= wait_for_ans;
                busy4ready <= TRUE;
              end if;
            elsif (calib_monitor_running) then -- !debug: 20/06/2021 CALIB_MONITOR pooling
              RWn <= '1';                       -- RD
              Address              <= "000000" & X"58";
              DATA2W               <= (others=>'0');
              configuring_sm_calib <= wait_for_ans;
              busy4ready <= TRUE;
            else -- WR
              configuring_sm_calib <= Wait_for_end;
              busy4ready <= TRUE;
              calib_wait_cnt <= 100;     -- !debug: 04/11/2021 only for debug
            end if;

          when wait_for_ans =>
            RWn <= '1'; 												--	aron ?
            EXE <= '0';
            if (time_out_timer >= x"1ffffff") then  -- !debug: 05/04/2021 x"3ffffff" -> x"1ffffff"
              time_out_timer <= (others => '0');
            else
              time_out_timer <= time_out_timer+1;
            end if;

            if (time_out_timer >= x"1ffffff") then  -- !debug: 05/04/2021 x"3ffffff" -> x"1ffffff"
              configuring_sm_calib <= Wait_for_end;
            elsif (READ_OUT_ready = '1') then -- after read from AMS
              configuring_sm_calib <= Wait_for_end;  -- check DATA2R, when READ_OUT_ready = '1'
            end if;

          when Wait_for_end =>
            -- RWn<= '0';
            EXE <= '0';
            -- DATA2W<=(others=>'0');
            -- if (busy_vec(3 downto 2) <= "10") then
            if (busy_vec(1 downto 0) = "10") then -- 12/05/2021
              busy4ready <= FALSE;
            end if;
            if (calib_wait_cnt > 0) then -- wait in calibration sequence
              calib_wait_cnt <= calib_wait_cnt - 1;
              -- !TODO: 12/03/2025 possible additional delay not requires, because already exist delay in calibration sequence
              if (calib_seq_cnt = 0) then
                calib_complete_cnt <= 1;
              elsif (calib_seq_cnt = 1) then
                calib_complete_cnt <= 1;
              elsif (calib_seq_cnt = 2) then
                calib_complete_cnt <= 1;
              else
                calib_complete_cnt <= 0;
              end if;
            elsif (not busy4ready) then -- 12/05/2021
              if ((calib_seq_cnt = 0 and calib_exec_cnt < offset_cal_c'HIGH) or
                  (calib_seq_cnt = 1 and calib_exec_cnt < linearity_cal_c'HIGH) or
                  (calib_seq_cnt = 2 and calib_exec_cnt < leakage_cal_c'HIGH) or
                  (calib_seq_cnt = 3 and calib_exec_cnt < array_cal_c'HIGH) or
                  (calib_seq_cnt = 4 and calib_exec_cnt < pass_addr_seq_c'HIGH) or
                  (calib_seq_cnt = 6 and calib_exec_cnt < reg_seq_c'HIGH)) then
                configuring_sm_calib <= get_params;
                calib_exec_cnt <= calib_exec_cnt + 1;
              elsif (calib_monitor_running) then -- !debug: 20/06/2021 CALIB_MONITOR pooling
                configuring_sm_calib <= load_params;
              elsif (calib_complete_cnt /= 0) then -- 12/03/2025
                calib_complete_cnt <= calib_complete_cnt - 1;
                -- !TODO: 12/03/2025 if use calib_completed, add here
              elsif (calib_seq_cnt < 3) then
                configuring_sm_calib <= calib_sequencer;
                calib_seq_cnt <= calib_seq_cnt + 1;  -- goto next calibration type
              else
                configuring_sm_calib <= DONE;
              end if;
            end if;

          when DONE =>
            --  RWn<= '0';
            EXE <= '0';
            --  DATA2W<=(others=>'0');
            Address              <= (others => '0');
            calib_ready          <= '1';
            configuring_sm_calib <= idle;
            calib_seq_cnt <= 0;          -- 24/06/2021
            test_mode_pass_address <= FALSE;
            test_mode_registers <= FALSE;

          end case;

        end if;
      end if;
    end if;
	end process sm_proc_pr;

bias_int<=bias;
calib_int<=calib;
--------------------------------------------------------
--POWER_up machine
-------------------------------------------------------
	process(RESET_N,clk)
	begin
      if (RESET_N = '0') then
        sm_powerup       <= idle;
--      sm_powerup<=Tile_ready;                     -- for check
        Power_en <= "000"; -- 22/12/2022
        power_en_seq_shr <= "00000"; -- 22/12/2022
        power_en_cnt <= 0;
        counter_delay    <= delay;
        PLL_vec          <= "0000";
        t_reset_cnt      <= t_reset_cnt_num;
        -- synthesis translate_off
        t_reset_cnt      <= x"0001";    -- !debug: for simulation only
        -- synthesis translate_on
        Tile_reset_int   <= '0';
        fifo_clear   <= '0';
        Settle_time_cnt  <= Settle_time;
        Tile_ready2sync  <= '0';
        calib_d          <= "000";
        do_calib         <= '0';
        do_tests         <= '0';
        calib_ctl_reg_cr <= '0';
        calib_ctl_reg_tr <= '0';
        ACLK_and_TILES_CLK_EN <= '0'; -- 24/04/2023
      elsif rising_edge(clk) then

		PLL_vec<=PLL_vec(2 downto 0) & locked_fast;

		if (sm_powerup=Tile_ready or sm_powerup=Tile_bias or sm_powerup=Tile_calib or sm_powerup=Tile_Power_Status) then

			Tile_ready2sync<= '1';
		else
			Tile_ready2sync<= '0';
		end if;


		case sm_powerup is

			when idle =>
										PLL_vec<="0000";
										Tile_reset_int<= '0';
                                        fifo_clear   <= '0';
										t_reset_cnt<=t_reset_cnt_num;
                    -- synthesis translate_off
                    t_reset_cnt<=x"0001"; -- !debug: for simulation only
                    -- synthesis translate_on
										Settle_time_cnt<=Settle_time;
										if counter_delay=0 then
										sm_powerup<= wait_for_PLL;
										counter_delay<=(others=>'0');
										else
										counter_delay<=counter_delay-1;
										end if;
                                        ACLK_and_TILES_CLK_EN <= '0'; -- 24/04/2023

	    	When Wait_For_Pll            => if PLL_vec (3 downto 1) = "111" then
										sm_powerup<=Wait_for_t_reset;
										end if;

			when Wait_for_t_reset     => 	if t_reset_cnt=0 then
                                        -- sm_powerup<= reset_sequence;
                                        sm_powerup<= Wait_for_power_en; -- 22/12/2022
                                        power_en_seq_shr <= "00000";
                                        power_en_cnt <= 1;
                                        Power_en <= "000"; -- 22/12/2022
										t_reset_cnt<=(others=>'0');
										-- elsif clk_cnt_neg_edge='1' then -- ACLK falling
                                        elsif (free_running_1_5_us_cnt = 74) then
                                          t_reset_cnt<=t_reset_cnt-1;
										end if;
------------------------------------------------------------------------------

          when Wait_for_power_en =>              -- !debug: 22/12/2022
              -- TMCOR v.6: FW#1, DPOS -> 10msec Delay -> APOS -> 10msec Delay -> ANEG
              -- notes:
              --  - SBVS291C Delay time to PG depend from CNR/SS > 12mS
              --  - AS5911/AS5912 time from DPOS+APOS+ANEG to exit from reset: tLDO_START LDO startup wait time min. 100 ms
              -- TMB: FW#1, DPOS -> 20msec Delay -> APOS -> 20msec Delay -> ANEG -> reset_sequence:  20msec Delay -> exit from reset
              -- if (clk_cnt_neg_edge = '1') then   -- ACLK falling
              if (free_running_1_5_us_cnt = 74) then

                if (power_en_cnt = 0) then
                  power_en_seq_shr <= power_en_seq_shr(3 downto 0) & '1';
                else
                  power_en_cnt <= power_en_cnt - 1;
                end if;

                if (power_en_seq_shr = "00000") then
                  Power_en <= "000";
                  if (power_en_cnt = 0) then
                    power_en_cnt <= 1;           -- DPOS delay
                  end if;
                elsif (power_en_seq_shr = "00001") then
                  if (power_en_cnt = 0) then
                    power_en_cnt <= 13332;        --  APOS delay
                    -- synthesis translate_off
                    power_en_cnt <= 32;          --  APOS delay
                    -- synthesis translate_on
                    Power_en     <= "100";       --  power DPOS (DISABLE_DVDDn & DISABLE_ANEGn & DISABLE_APOSn)
                  end if;
                elsif (power_en_seq_shr = "00011") then
                  if (power_en_cnt = 0) then
                    power_en_cnt <= 13332;        --  ANEG delay
                    -- synthesis translate_off
                    power_en_cnt <= 32;          --  ANEG delay
                    -- synthesis translate_on
                    Power_en     <= "101";       --  power DPOS + APOS (DISABLE_DVDDn & DISABLE_ANEGn & DISABLE_APOSn)
                  end if;
                elsif (power_en_seq_shr = "00111") then
                  if (power_en_cnt = 0) then
                    power_en_cnt <= 13332;        --  ACLK and TILES_CLK delay
                    -- synthesis translate_off
                    power_en_cnt <= 32;          --  ACLK and TILES_CLK  delay
                    -- synthesis translate_on
                    if (DPOS_PGOOD = '1') then     -- 17/04/2023 enable ANEG only if APOS OK
                      Power_en <= "111";           -- power DPOS + APOS + ANEG (DISABLE_DVDDn & DISABLE_ANEGn & DISABLE_APOSn)
                    end if;
                  end if;
                elsif (power_en_seq_shr = "01111") then
                  if (power_en_cnt = 0) then
                    sm_powerup <= reset_sequence;  -- out from reset;
                    power_en_cnt <= 2**17;        -- exit from reset delay
                    -- synthesis translate_off
                    power_en_cnt <= 100;          --  exit from reset delay
                    -- synthesis translate_on
                  end if;
                end if;
              end if;

------------------------------------------------------------------------------
			When RESET_sequence        =>
              -- if (clk_cnt_neg_edge = '1') then   -- ACLK falling
              if (free_running_1_5_us_cnt = 74) then
                if (power_en_cnt /= 0) then
                  power_en_cnt <= power_en_cnt - 1;
                end if;
              end if;
              if (power_en_cnt = 0) then
                -- if rst_seq_end_int='1' then
                if (exit_from_asic_reset = '1') then -- 20/04/2023
                  Tile_reset_int<='1';
                  fifo_clear <= '1';
                  sm_powerup<=Settle_time_After_RST;
                end if;
              end if;
              ACLK_and_TILES_CLK_EN <= '1'; -- 24/04/2023

------------------------------------------------------------------------
			When Settle_time_After_RST =>
              if Settle_time_cnt=0 then
                --		sm_powerup<=Config_regs;
                sm_powerup<=Tile_ready;
              else
                Settle_time_cnt<=Settle_time_cnt-1;
              end if;
----------------------------------------------------------------------------------
			When Config_regs =>
										if cfg_seq_end_int='1' then
										sm_powerup<=Tile_ready;
										end if;
-------------------------------------------------------------------------------------
			When Tile_ready =>
                      -- !debug: 11/05/2021 commented  sm_powerup<=Tile_ready;
-- 										if bias_int='1' then										-- for check
-- 										sm_powerup <= Tile_bias;
-- 										elsif calib_int/="000" then
-- 										sm_powerup<=Tile_calib;
-- 										calib_d<=calib;
-- 										end if;
        calib_ctl_reg_cr <= calib_ctl_reg(15) and not calib_ctl_reg(11);
        do_calib <= (calib_ctl_reg(15) and not calib_ctl_reg(11)) and not calib_ctl_reg_cr;
        calib_ctl_reg_tr <= calib_ctl_reg(15) and calib_ctl_reg(11);
        do_tests <= (calib_ctl_reg(15) and calib_ctl_reg(11)) and not calib_ctl_reg_tr;
        if (do_calib = '1') then -- 11/05/2021 execute calibration
          sm_powerup <= Tile_calib;
        elsif (tiles_soft_reset(2) = '0' and tiles_soft_reset(1) = '1') then  -- 30/06/2021
          sm_powerup <= idle;
        elsif (do_tests = '1') then                    -- 30/06/2021
          --       Pass address 0x0010 - !TODO
          --       Connectivity 0x0020 - TBD
          --       Regiters 0x0040 - TBD
          sm_powerup <= Tile_calib;
        elsif (do_power_check and not calib_busy) then -- 23/06/2021 Realin_byte pulse -> enable when no data
          sm_powerup <= Tile_Power_Status;
        end if;

			When Tile_bias  => 			if bias_int='0' and bias_ready='1' then
										sm_powerup<=Tile_ready;
										end if;
			When Tile_calib  => 		if calib_int="000" and calib_ready='1' then
										sm_powerup<=Tile_ready;
										calib_d<="000";
										end if;

			When Tile_Power_Status => -- 23/06/2021
              if (power_status_ready = '1') then
                sm_powerup<=Tile_ready;
              end if;

    end case;

		end if;
	end process;
Tile_reset <=Tile_reset_int;
rst_seq_end_int<=rst_seq_end;
RAM_rd_en<=RAM_rd_en_int;
RAM_address<=RAM_address_int;
RAM_rd_en_o <= RAM_rd_en_int(1);        -- 29/06/2021

    process(RESET_N, clk)
    begin
    if (RESET_N = '0') then

      rst_ctrl              <= (others => '1');
      calib_monitor_running <= FALSE;
      -- calib_monitor_reg     <= (others => '0');
      do_power_check <= FALSE;
      power_monitor_reg     <= (others => '0');
      tiles_soft_reset <= (others => '0');
      Expected_AA55 <=  (others => '0');
      Expected_8C4D <=  (others => '0');
    elsif rising_edge(clk) then

      if (CNT_lines(8) = '1') then  -- when '1' active reset to the asic '0' no reset
        rst_ctrl <= (others => '1');
      else
        rst_ctrl <= (others => '0');
      end if;
      tiles_soft_reset <= tiles_soft_reset(1 downto 0) & CNT_lines(8); -- 07/10/2021

      -- 20/06/2021
      if (configuring_sm_calib = load_params) then
        if (calib_seq_cnt = 0) then
          calib_monitor_running <= (offset_cal_c(calib_exec_cnt).calib_address = X"58" and
                                    offset_cal_c(calib_exec_cnt).calib_rw = '1'); -- Offset voltage
        elsif (calib_seq_cnt = 1) then
          calib_monitor_running <= (linearity_cal_c(calib_exec_cnt).calib_address = X"58" and
                                    linearity_cal_c(calib_exec_cnt).calib_rw = '1'); -- Linearity
        elsif (calib_seq_cnt = 2) then
          calib_monitor_running <= (leakage_cal_c(calib_exec_cnt).calib_address = X"58" and
                                    leakage_cal_c(calib_exec_cnt).calib_rw = '1'); -- Offset current
        elsif (calib_seq_cnt = 3) then
          calib_monitor_running <= (array_cal_c(calib_exec_cnt).calib_address = X"58" and
                                    array_cal_c(calib_exec_cnt).calib_rw = '1'); -- Array delta
        end if;
      elsif (calib_monitor_running and READ_OUT_ready = '1') then
        -- if (DATA2R(3 downto 0) = X"0") then
        --   calib_monitor_running <= FALSE;
        -- end if;
        -- !debug: 28/06/2021
        if (calib_monitor_min_delay = 0) then             -- !debug: 04/07/2021 prevent case, if FSM check calibration done when calibration yet not started
          if (calib_seq_cnt = 0 and DATA2R(3) = '1') then -- Offset voltage
            calib_monitor_running <= FALSE;
          elsif (calib_seq_cnt = 1 and DATA2R(0) = '1') then -- Linearity
            calib_monitor_running <= FALSE;
          elsif (calib_seq_cnt = 2 and DATA2R(2) = '1') then -- Offset current
            calib_monitor_running <= FALSE;
          elsif (calib_seq_cnt = 3 and DATA2R(12) = '1') then -- Array delta
            calib_monitor_running <= FALSE;
          end if;
        end if;
      end if;
      -- if (calib_monitor_running and READ_OUT_ready = '1') then -- 08/11/2021 now calib_monitor_reg updates only in calibration time
      --   -- if (calib_seq_cnt = 0) then -- voltage
      --   --   calib_monitor_reg(3) <= DATA2R(3); -- completed
      --   --   calib_monitor_reg(7) <= DATA2R(7); -- err
      --   -- elsif (calib_seq_cnt = 1) then -- linearity
      --   --   calib_monitor_reg(0) <= DATA2R(0); -- completed
      --   --   calib_monitor_reg(4) <= DATA2R(4); -- err
      --   -- elsif (calib_seq_cnt = 2) then -- offset current
      --   --   calib_monitor_reg(2) <= DATA2R(2); -- completed
      --   --   calib_monitor_reg(6) <= DATA2R(6); -- err
      --   -- elsif (calib_seq_cnt = 3) then -- array delta
      --   --   calib_monitor_reg(12) <= DATA2R(12); -- completed
      --   --   calib_monitor_reg(13) <= DATA2R(13); -- err
      --   -- end if;
      --   calib_monitor_reg <= DATA2R; -- 12/03/2025 NU
      -- end if;

      -- if (do_calib = '1') then
      --   init_seq_end_shr(0) <= '1'; -- sticky
      -- end if;
      -- if (init_seq_end_shr(0) = '1' and READ_OUT_ready = '1') then
      --     init_seq_end_shr(1) <= '1';
      -- end if;
      -- init_seq_end_shr(3 downto 2) <= init_seq_end_shr(2 downto 1);

      -- if (Realin_byte_r = '0' and Realin_byte_r0 = '1') then -- 23/06/2021
      --   if (configuring_sm_regs = idle) then
      --     do_power_check <= FALSE;                  -- !debug: 14/06/2022 disabled, TRUE for enable
      --   end if;
      -- elsif (configuring_sm_power = load_params or Realin_byte_r0 = '0') then
      --   do_power_check <= FALSE;
      -- end if;
      do_power_check <= FALSE;
      if (configuring_sm_power = Wait_for_end and READ_OUT_ready = '1') then -- 12/03/2025 no do_power_check -> NU
        power_monitor_reg <= DATA2R(11 downto 0);
      end if;

      if (calib_seq_cnt = 6 and READ_OUT_ready = '1') then -- 12/03/2025 get registers test result, now NU
        if (calib_exec_cnt = 3) then -- 07/11/2021 voltage
          Expected_AA55 <= DATA2R;
        elsif (calib_exec_cnt = 4) then -- 07/11/2021 linearity
          Expected_8C4D <= DATA2R;
        end if;
      end if;

    end if;
	end process;

  -- init_seq_end <= init_seq_end_shr(2); -- 23/06/2021


  misc_pr: process (clk, RESET_N) is
  begin  -- process misc_pr
    if (RESET_N = '0') then           -- asynchronous reset (active low)
      calib_monitor_min_delay <= 0;
      pass_addr_test <= '0';
      -- registers_test <= '0';
      registers_test_result <= '0';
      calib_analize_cnt <= 0;
      test_wait_reg <= (others => '0');  -- 07/11/2021
      free_running_1_5_us_cnt <= 0;
    elsif (clk'event and clk = '1') then  -- rising clock edge
      if (configuring_sm_calib = get_params) then
        -- if (calib_seq_cnt = 0) then
        --   calib_monitor_min_delay <= 5;
        -- elsif (calib_seq_cnt = 1 or calib_seq_cnt = 3) then
        --   calib_monitor_min_delay <= 200;
        -- elsif (calib_seq_cnt = 2) then
        --   calib_monitor_min_delay <= 200; -- !debug: 31/10/2021 was 10
        -- end if;
        if (calib_seq_cnt < 4) then
          calib_monitor_min_delay <= 1; -- !debug: 31/05/2023 calib_monitor_min_delay shortened, because this part of old NU pooling status check
        end if;
        -- synthesis translate_off
        calib_monitor_min_delay <= 2;
        -- synthesis translate_on
      elsif (IP_v(3 downto 2) = "01" and calib_monitor_running) then -- !debug: 02/11/2021
        if (calib_monitor_min_delay /= 0) then
          calib_monitor_min_delay <= calib_monitor_min_delay - 1;
        end if;
      end if;

      if (configuring_sm_calib = DONE) then
        if (test_mode_pass_address) then
          pass_addr_test <= '1'; -- 09/08/2021 pass address sequence completed, started pass
        elsif (test_mode_registers) then
          -- registers_test <= '1';
        end if;
      elsif (do_calib = '1') then
        pass_addr_test <= '0';          -- new calibration, test stopped
        -- registers_test <= '0';          -- new calibration, test stopped
      end if;

      if (configuring_sm_calib = DONE and test_mode_registers) then -- 05/01/2022
        if (Expected_AA55 = X"2A55" and Expected_8C4D = X"0C4D") then -- note: valid bits are [14..0]
          registers_test_result <= '0';
        else
          registers_test_result <= '1'; -- '0' ok , '1' fault
        end if;
      end if;

      if (configuring_sm_calib = idle) then
        calib_analize_cnt <= 0;
      elsif (calib_analize_cnt /= 2**30) then
        calib_analize_cnt <= calib_analize_cnt + 1;
      end if;

      test_wait_reg <= diag_reg(15 downto 8); -- !TODO: 07/11/2021 remove after test

      if (free_running_1_5_us_cnt = 0) then
        free_running_1_5_us_cnt <= 74;
      else
        free_running_1_5_us_cnt <= free_running_1_5_us_cnt - 1;
      end if;

    end if;
  end process misc_pr;

  calib_busy_o <= '1' when (calib_busy) else '0';


END architecture behave;
