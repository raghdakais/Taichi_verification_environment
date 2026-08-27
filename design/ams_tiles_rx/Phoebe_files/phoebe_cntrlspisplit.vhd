--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.phoebe.all;
-------------------------------------------------------------------------------

ENTITY phoebe_cntrlspisplit IS
    GENERIC(
    	WORD_WIDTH1	: integer  := 14;
		WORD_WIDTH2	: integer  := 15
    );
    PORT(
        RESET_N       		: IN    std_logic;
        clk          		: IN    std_logic;
        ACLK_Master  		: IN    std_logic; -- 05/04/2021
		locked_fast   		: IN    std_logic;
		DiscardIP           : IN    std_logic;
		Discard          	: OUT   std_logic_vector(NumOfTiles-1 downto 0);
		IP                  : IN    std_logic;
		SYNC          	    : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		ACLK          		: OUT   std_logic_vector(NumOfTiles-1 downto 0);
        -- AMS_Time            : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0); -- 08/04/2021
		-- SPI_BUS_CTRL  		: IN    std_logic_vector(39 downto 0);
        SPI_BUS_CTRL  		: IN    std_logic_vector((NumOfTiles*40)-1 downto 0); -- 29/06/2021
        RAM_rd_en_o         : OUT   std_logic_vector(NumOfTiles-1 downto 0); -- 29/06/2021
        CNT_lines		    : in    std_logic_vector (15 DOWNTO 8);
		read_config_rom     : OUT   std_logic;
	    SCSn                : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		SDI	                : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		SCLK	            : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		SDO                 : IN    std_logic_vector(NumOfTiles-1 downto 0);
		Tiles_rst    		: OUT   std_logic_vector(NumOfTiles-1 downto 0);
        fifo_clear   		: OUT   std_logic_vector(NumOfTiles-1 downto 0); -- 23/11/2022
		Bias				: IN	std_logic;
		Calib				: IN	std_logic_vector (2 downto 0);
        calib_ctl_reg       : in  std_logic_vector(15 downto 0); -- 10/05/2021
        diag_reg            : in std_logic_vector(15 downto 0);   -- 07/11/2021
        exit_from_asic_reset : in std_logic;                  -- 20/04/2023
        calib_completed : in std_logic_vector((NumOfTiles*4)-1 downto 0); -- 12/03/2025
        overhead_bits       : out	std_logic_vector(63 downto 0); -- 21/06/2021
        pass_addr_test      : out   std_logic_vector(NumOfTiles-1 downto 0); -- 09/08/2021
        registers_test_result : out std_logic_vector(NumOfTiles-1 downto 0); -- 05/01/2022
		RAM_rd_en           : OUT	std_logic_vector (1 downto 0); -- !debug: 29/06/2021 now NU
		RAM_address         : OUT	std_logic_vector (13 downto 0); -- !debug: 29/06/2021 now NU
		-- fifo_status         : IN	std_logic;
        fifo_status         : IN   std_logic_vector(NumOfTiles-1 downto 0); -- 29/06/2021
		READ_OUT_ready_o    : OUT	std_logic_vector(NumOfTiles-1 downto 0); -- !debug: 21/06/2022 was width bit
        DATA2R_o		    : OUT	std_logic_vector(NumOfTiles*WORD_WIDTH2-1 downto 0); -- !debug: 21/06/2022 was width (WORD_WIDTH2-1 downto 0)
        DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
        ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
        Power_en          : out std_logic_vector (2 downto 0); -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
        SPI_ERRs        : OUT	std_logic_vector(3*NumOfTiles-1 downto 0) --add by Dalit 10/10/2023


    );
END phoebe_cntrlspisplit;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ARCHITECTURE behave OF phoebe_cntrlspisplit IS
-------------------------------------------------------------------------------
 COMPONENT SPI_AMS_CORE IS
    GENERIC(
    	WORD_WIDTH1	: integer  := 14;
		WORD_WIDTH2	: integer  := 15
    );
    PORT(
        RESET_N       	: IN    std_logic;
        clk          	: IN    std_logic;
		EXE             : IN    std_logic;
        Address			: IN	std_logic_vector(WORD_WIDTH1-1 downto 0);
		DATA2W			: IN	std_logic_vector(WORD_WIDTH2-1 downto 0);
		RWn             : IN    std_logic;
		SYNC            : IN    std_logic;   --Rev 2, Lock up, Yonatan, 23Nov2020
		SCLK            : OUT    std_logic;
		SDI             : OUT	std_logic;
		SDO             : IN	std_logic;
		SCSn            : OUT	std_logic;
		BUSY            : OUT	std_logic;
		READ_OUT_ready  : OUT	std_logic;
        spi_err_status  : OUT	std_logic_vector(2 downto 0);  --change by Dalit to vector 10/10/2023                     -- 24/06/2021
        Inst_4R		    : OUT	std_logic_vector(15 downto 0);						--	Instruction for read
        DATA2R		    : OUT	std_logic_vector(WORD_WIDTH2-1 downto 0)
    );
END COMPONENT;
------------------------------------------------------------------------------------
COMPONENT Phoebe_controller IS
    GENERIC(
    	WORD_WIDTH1	: integer  := 14;
		WORD_WIDTH2	: integer  := 15
    );
    PORT(
        RESET_N       		: IN    std_logic;
        clk          		: IN    std_logic;
        ACLK_Master  		: IN    std_logic; -- 05/04/2021
		locked_fast   		: IN    std_logic;
		DiscardIP           : IN    std_logic;
		Discardo          	: OUT   std_logic;
		IP                  : IN    std_logic;
		SYNCo          		: OUT   std_logic;
		ACLKo          		: OUT   std_logic;
        AMS_Time            : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0); -- 08/04/2021
		SPI_BUS_CTRL  		: IN    std_logic_vector(39 downto 0);
        CNT_lines		    : in    std_logic_vector (15 DOWNTO 8);
		SPICTRLencoder      : OUT	std_logic_vector(3 downto 0);
		EXE           		: OUT   std_logic;
        Address			    : OUT	std_logic_vector(WORD_WIDTH1-1 downto 0);
		DATA2W			    : OUT	std_logic_vector(WORD_WIDTH2-1 downto 0);
		RWn           		: OUT   std_logic;
		BUSY          		: IN	std_logic;
		READ_OUT_ready		: IN	std_logic;
        DATA2R		  		: IN	std_logic_vector(WORD_WIDTH2-1 downto 0);
		TILE_RESET    		: OUT   std_logic;
        fifo_clear          : out std_logic; -- 23/11/2022 to regs_fifo
		rst_seq_end         : IN	std_logic;
		Bias				: IN	std_logic;
		Calib				: IN	std_logic_vector (2 downto 0);
        calib_ctl_reg       : in  std_logic_vector(15 downto 0); -- 10/05/2021
        diag_reg            : in std_logic_vector(15 downto 0);   -- 07/11/2021
        exit_from_asic_reset : in std_logic;                  -- 20/04/2023
        calib_completed : in std_logic_vector(NumOfTiles-1 downto 0); -- 12/03/2025
        calib_busy_o        : out std_logic;                       -- 05/07/2021
        -- calib_monitor_reg   : out std_logic_vector(WORD_WIDTH2-1 downto 0); -- 21/06/2021
        power_monitor_reg   : out std_logic_vector(11 downto 0); -- 23/06/2021
        -- init_seq_end        : out std_logic;                -- 23/06/2021
        pass_addr_test      : out std_logic;                -- 09/08/2021
        registers_test_result : out std_logic;                   -- 05/01/2022
		RAM_rd_en           : OUT	std_logic_vector (1 downto 0);
        RAM_rd_en_o         : out std_logic; -- 29/06/2021
		RAM_address         : OUT	std_logic_vector (13 downto 0);
		rst_ctrl            : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		fifo_status         : IN	std_logic;
		Tile_ready2sync     : OUT   std_logic;
        DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
        ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
        Power_en          : out std_logic_vector (2 downto 0) -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
    );
END COMPONENT;

signal calib_busy : std_logic_vector(NumOfTiles-1 downto 0);

type DATA2R_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(WORD_WIDTH2-1 downto 0);
type Address_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(WORD_WIDTH1-1 downto 0);
SIGNAL EXE           		:  std_logic_vector(NumOfTiles-1 downto 0);
SIGNAL Address			    :  Address_TYP;
SIGNAL DATA2W			    :  DATA2R_TYP;
SIGNAL RWn           		:  std_logic_vector(NumOfTiles-1 downto 0);

-- SIGNAL BUSY          		:  std_logic;
-- SIGNAL READ_OUT_ready		:  std_logic;
-- SIGNAL DATA2R		  		:  std_logic_vector(WORD_WIDTH2-1 downto 0);
-- signal Inst_4R              :  std_logic_vector(15 downto 0);
SIGNAL BUSY          		: std_logic_vector(NumOfTiles-1 downto 0);
SIGNAL READ_OUT_ready		: std_logic_vector(NumOfTiles-1 downto 0);
SIGNAL DATA2R		  		: DATA2R_TYP;
type INST_4R_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(15 downto 0);
signal Inst_4R              : INST_4R_TYP;
-- SIGNAL BUSY_2ctl						:	 std_logic;
-- SIGNAL READ_OUT_ready_2ctl		:	 std_logic;
-- SIGNAL DATA2R_2ctl					:	 std_logic_vector(WORD_WIDTH2-1 downto 0);
-- SIGNAL DATA2R_i		  		:  std_logic_vector(WORD_WIDTH2-1 downto 0);
-- signal Inst_4R_i              :  std_logic_vector(WORD_WIDTH2-1  downto 0); -- !debug: 21/06/2022 was (15 downto 0)
signal DATA2R_i, Inst_4R_i : std_logic_vector(NumOfTiles*WORD_WIDTH2-1 downto 0); -- !debug: 21/06/2022
-- SIGNAL Tile_reset    		:  std_logic;
-- SIGNAL rst_seq_end          :  std_logic;
-- SIGNAL Discardo             :  std_logic;
-- SIGNAL SDOi			     	:  std_logic;
-- SIGNAL SDIi                 :  std_logic;
-- SIGNAL SCSni                :  std_logic;
-- SIGNAL SCLKi                :  std_logic;
SIGNAL SCLK_i,SDI_i,SDO_i,SCSn_i :  std_logic_vector(NumOfTiles-1 downto 0);
-- SIGNAL ACLKo                :  std_logic;
-- SIGNAL SYNCo                :  std_logic;

type SPICTRLencoder_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(3 downto 0); -- 29/06/2021
SIGNAL SPICTRLencoder       : SPICTRLencoder_TYP;
-- SIGNAL rst_ctrl             :  std_logic_vector(NumOfTiles-1 downto 0);

type CALIB_MONITOR_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(WORD_WIDTH2-1 downto 0); -- 29/06/2021
-- signal calib_monitor_reg : CALIB_MONITOR_TYP; -- 29/06/2021
type POWER_MONITOR_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(11 downto 0); -- 29/06/2021
signal power_monitor_reg : POWER_MONITOR_TYP; -- 23/06/2021
-- signal init_seq_end      : std_logic_vector(NumOfTiles-1 downto 0); -- 29/06/2021
signal spi_err_status    : std_logic_vector(3*NumOfTiles-1 downto 0); -- 24/06/2021 --change by Dalit 10/10/2023
signal mon_cnt : natural range 0 to 3 := 0;                          -- 29/06/2021
signal ip_r : std_logic;
signal SYNC_i : std_logic_vector(NumOfTiles-1 downto 0);
signal ACLK_and_TILES_CLK_EN_i : std_logic_vector(NumOfTiles-1 downto 0);

type POWER_EN_TYP is array (NumOfTiles-1 downto 0) OF std_logic_vector(2 downto 0);
signal power_en_arr : POWER_EN_TYP;


signal calib_time_cnt : natural range 0 to 2**29;
signal calib_busy_r : std_logic := '0';
attribute DONT_TOUCH : string;
attribute DONT_TOUCH of calib_time_cnt : signal is "TRUE";
attribute mark_debug : string;
attribute mark_debug of calib_time_cnt : signal is "true";

BEGIN


  -- 06/05/2021 support Single read operation transfers data from all 4 Asics
  spi_ams_gen : for i in 0 to (NumOfTiles-1) generate

    SPI_AMS_CORE_inst : SPI_AMS_CORE
      generic map(
        WORD_WIDTH1 => 14,
        WORD_WIDTH2 => 15
        )
      port map(
        RESET_N        => RESET_N,
        clk            => clk,
        EXE            => EXE(i),
        Address        => Address(i),
        DATA2W         => DATA2W(i),
        RWn            => RWn(i),
        SYNC           => SYNC_i(i),    -- 07/07/2021
        SCLK           => SCLK_i(i),
        SDI            => SDI_i(i),
        SDO            => SDO_i(i),
        SCSn           => SCSn_i(i),
        BUSY           => BUSY(i),
        READ_OUT_ready => READ_OUT_ready(i),
        spi_err_status => spi_err_status((i*3)+2 downto i*3), -- 24/06/2021 ---changed by Dalit 10/10/2023
        Inst_4R        => Inst_4R(i),
        DATA2R         => DATA2R(i)
        );

    SPI_ERRs <= spi_err_status;   --add by Dalit 10/10/2023
    SYNC <= SYNC_i;                     -- 07/07/2021
    ACLK_and_TILES_CLK_EN <= ACLK_and_TILES_CLK_EN_i(1); -- 24/04/2023

    -- 29/06/2021 added independent controller for each SPI AMS
    phoebe_controller_inst : phoebe_controller
      generic map(
        WORD_WIDTH1 => 14,
        WORD_WIDTH2 => 15
        )
      port map(
        RESET_N           => RESET_N,
        clk               => clk,
        ACLK_Master       => ACLK_Master,        -- 05/04/2021
        locked_fast       => locked_fast,
        DiscardIP         => DiscardIP,
        Discardo          => Discard(i),  -- !debug: 29/06/2021 was   Discardo,
        IP                => IP,
        SYNCo             => SYNC_i(i),  -- !debug: 29/06/2021 was   SYNCo,
        ACLKo             => ACLK(i),  -- !debug: 29/06/2021 was   ACLKo,
        AMS_Time          => open,           -- 08/04/2021
        SPI_BUS_CTRL      => SPI_BUS_CTRL(i*40+39 downto i*40),
        CNT_lines         => CNT_lines,
        SPICTRLencoder    => SPICTRLencoder(i),
        EXE               => EXE(i),
        Address           => Address(i),
        DATA2W            => DATA2W(i),
        RWn               => RWn(i),
        BUSY              => BUSY(i), -- !debug: 29/06/2021 was    BUSY_2ctl,
        READ_OUT_ready    => READ_OUT_ready(i),  -- !debug: 29/06/2021 was     READ_OUT_ready_2ctl,
        DATA2R            => DATA2R(i),  -- !debug: 29/06/2021 was     DATA2R_2ctl,
        Tile_reset        => Tiles_rst(i),  -- !debug: 29/06/2021 was    Tile_reset,
        fifo_clear        => fifo_clear(i),
        rst_seq_end       => '1', -- !debug: 29/06/2021 disabled, was  rst_seq_end,
        Bias              => Bias,
        Calib             => Calib,
        calib_ctl_reg     => calib_ctl_reg,      -- 10/05/2021
        diag_reg            => diag_reg,      -- 07/11/2021
        exit_from_asic_reset => exit_from_asic_reset,   -- 20/04/2023
        calib_completed => calib_completed((i*4)+4-1 downto i*4),  -- 12/03/2025
        calib_busy_o      => calib_busy(i),       -- 05/07/2021
        -- calib_monitor_reg => calib_monitor_reg(i),  -- 21/06/2021
        power_monitor_reg => power_monitor_reg(i),  -- 23/06/2021
        -- init_seq_end      => init_seq_end(i),       -- 23/06/2021
        pass_addr_test    => pass_addr_test(i),  -- 09/08/2021
        registers_test_result => registers_test_result(i), -- 05/01/2022
        RAM_rd_en         => open,
        RAM_rd_en_o       => RAM_rd_en_o(i),
        RAM_address       => open, -- !debug: 29/06/2021 disabled, was  RAM_address,
        rst_ctrl          => open, -- !debug: 29/06/2021 disabled, was  rst_ctrl,
        fifo_status       => fifo_status(i),
        Tile_ready2sync   => open,
        DPOS_PGOOD        => DPOS_PGOOD,     -- 17/04/2023
        ACLK_and_TILES_CLK_EN => ACLK_and_TILES_CLK_EN_i(i), -- 24/04/2023
        Power_en          => power_en_arr(i)  -- 22/12/2022
        );

  end generate;


  Power_en <= power_en_arr(1);

  RAM_address <= (others => '0');     -- 29/06/2021
  RAM_rd_en <= (others => '0');       -- 29/06/2021


  -- 4x independent SPI controllers, then cab be problem if fetch from FIFO not same tile select
  -- uses registers from all tiles
  READ_OUT_ready_o <= READ_OUT_ready; -- to registers
  DATA2R_i <= DATA2R(3) & DATA2R(2) & DATA2R(1) & DATA2R(0); -- to registers
  Inst_4R_i <= Inst_4R(3)(WORD_WIDTH2-1 downto 0) & Inst_4R(2)(WORD_WIDTH2-1 downto 0) &
               Inst_4R(1)(WORD_WIDTH2-1 downto 0) & Inst_4R(0)(WORD_WIDTH2-1 downto 0); -- to registers

  with CNT_lines(9) select              --  Read register depended on control lines
     DATA2R_o <= DATA2R_i when '0',
				 Inst_4R_i when '1',
				 DATA2R_i				when others;


  -- !debug: 29/06/2021 moved from spi_split_cntrl
  -------------------------------------------
  --Splitting the SPI signals
  -------------------------------------------
  process(RESET_N,  clk)
  begin
    if (RESET_N   =   '0') then
      SCSn   <=  (others => '1');
      SDI	  <= (others=>'0');
      SCLK <=(others=>'0');
    elsif rising_edge(clk) then

      for i in 0 to NumOfTiles-1 loop

        if (busy(i) = '1') then
          SCSn(i) <= SCSn_i(i);
        else
          SCSn(i) <= '1';
        end if;

        if (busy(i) = '1') then
          SDI(i) <= SDI_i(i);
        else
          SDI(i) <= '0';
        end if;

        if (busy(i) = '1') then
          SCLK(i) <= SCLK_i(i);
        else
          SCLK(i) <= '0';
        end if;

      end loop;  -- i

    end if;
  end process;

  SDO_i <= SDO;


  overhead_pr: process (clk) is
  begin  -- process overhead_pr
    if (clk'event and clk = '1') then  -- rising clock edge

      overhead_bits <= (others => '0'); -- default

      overhead_bits(63 downto 60) <= X"0"; -- !debug: 12/03/2025 was  init_seq_end(3) & init_seq_end(2) & init_seq_end(1) & init_seq_end(0); -- note: must be muxed init_seq_end and Tile_data_locked -> [63..60] number of tiles

      -- [13]- array delta err, [6] - offset current err, [4] - linearity calibration err, [7] - offset voltage err
      -- [12] - Array delta calibration completed, [2] - Offset current calibration completed, [0] - Linearity calibration completed, [3] - offset voltage completed
      -- overhead_bits(59 downto 56) <= calib_monitor_reg(0)(13) & calib_monitor_reg(0)(2) & -- !TODO: 13/06/2022 array delta NU -> (13) NU
      --                                calib_monitor_reg(0)(0) & calib_monitor_reg(0)(3);
      -- overhead_bits(55 downto 52) <= calib_monitor_reg(1)(13) & calib_monitor_reg(1)(2) &
      --                                calib_monitor_reg(1)(0) & calib_monitor_reg(1)(3);
      -- overhead_bits(51 downto 48) <= calib_monitor_reg(2)(13) & calib_monitor_reg(2)(2) &
      --                                calib_monitor_reg(2)(0) & calib_monitor_reg(2)(3);
      -- overhead_bits(47 downto 44) <= calib_monitor_reg(3)(13) & calib_monitor_reg(3)(2) &
      --                                calib_monitor_reg(3)(0) & calib_monitor_reg(3)(3);

      overhead_bits(43 downto 40) <= spi_err_status(9) & spi_err_status(6) & spi_err_status(3) & spi_err_status(0);  ---changed by Dalit 10/10/2023

      ip_r <= IP;
      if (IP = '1' and ip_r = '0') then
        mon_cnt <= (mon_cnt + 1) mod 4;
      end if;
      if (mon_cnt = 0) then
        overhead_bits(39 downto 24) <= X"1" & power_monitor_reg(0);
      end if;
      if (mon_cnt = 1) then
        overhead_bits(39 downto 24) <= X"2" & power_monitor_reg(1);
      end if;
      if (mon_cnt = 2) then
        overhead_bits(39 downto 24) <= X"4" & power_monitor_reg(2);
      end if;
      if (mon_cnt = 3) then
        overhead_bits(39 downto 24) <= X"8" & power_monitor_reg(3);
      end if;

      overhead_bits(20) <= calib_busy(1);

      -- !debug: 03/05/2023 only for test
      calib_busy_r <= calib_busy(1);
      if (calib_busy_r = '0' and calib_busy(1) = '1') then -- start calibration
        calib_time_cnt <= 0;
      elsif (calib_time_cnt < 2**29 and calib_busy(1) = '1') then
        calib_time_cnt <= calib_time_cnt + 1;
      end if;

    end if;
  end process overhead_pr;


------------------------------------------------------------------------------
END architecture behave;
-------------------------------------------------------------------------------
