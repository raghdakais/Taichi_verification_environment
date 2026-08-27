--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.phoebe.all;
-------------------------------------------------------------------------------

ENTITY phoebe_cntrlspisplitmem IS
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
		REGS_req            : IN    std_logic_vector(39 downto 0);
        CNT_lines		    : in    std_logic_vector (15 DOWNTO 8);
		wrreq		        : IN     std_logic_vector(1 downto 0);
		RAM_wraddress       : IN	std_logic_vector (7 downto 0); -- !TODO: 01/12/2022 NU -> remove
		Discard          	: OUT   std_logic_vector(NumOfTiles-1 downto 0);
		IP                  : IN    std_logic;
		SYNC          	    : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		ACLK          		: OUT   std_logic_vector(NumOfTiles-1 downto 0);
        -- AMS_Time       : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0); -- 08/04/2021
	    SCSn                : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		SDI	                : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		SCLK	            : OUT   std_logic_vector(NumOfTiles-1 downto 0);
		SDO                 : IN    std_logic_vector(NumOfTiles-1 downto 0);
		Tiles_rst    		: OUT   std_logic_vector(NumOfTiles-1 downto 0);
		Bias				: IN	std_logic;
		Calib				: IN	std_logic_vector(2 downto 0);
        calib_ctl_reg       : in  std_logic_vector(15 downto 0); -- 10/05/2021
        diag_reg            : in std_logic_vector(15 downto 0);   -- 07/11/2021
        exit_from_asic_reset : in std_logic;                  -- 20/04/2023
        calib_completed : in std_logic_vector((NumOfTiles*4)-1 downto 0); -- 12/03/2025
        pass_addr_test      : out   std_logic_vector(NumOfTiles-1 downto 0); -- 09/08/2021
        registers_test_result : out std_logic_vector(NumOfTiles-1 downto 0); -- 05/01/2022
        overhead_bits       : out	std_logic_vector(63 downto 0); -- 21/06/2021
		READ_OUT_ready_o    : OUT	std_logic_vector(NumOfTiles-1 downto 0); -- !debug: 21/06/2022 was width bit
	    DATA2R_o	        : OUT	std_logic_vector(NumOfTiles*WORD_WIDTH2-1 downto 0); -- !debug: 21/06/2022 was width (WORD_WIDTH2-1 downto 0)
        DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
        ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
        Power_en          : out std_logic_vector (2 downto 0); -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
        SPI_ERRs        : OUT	std_logic_vector(3*NumOfTiles-1 downto 0) --add by Dalit 10/10/2023

    );
END phoebe_cntrlspisplitmem;

-------------------------------------------------------------------------------

ARCHITECTURE behave OF phoebe_cntrlspisplitmem IS


 COMPONENT phoebe_cntrlspisplit IS
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
		RAM_rd_en           : OUT	std_logic_vector (1 downto 0);
		RAM_address         : OUT	std_logic_vector (13 downto 0);
		-- fifo_status         : IN	std_logic;
        fifo_status         : IN   std_logic_vector(NumOfTiles-1 downto 0); -- 29/06/2021
		READ_OUT_ready_o    : OUT	std_logic_vector(NumOfTiles-1 downto 0); -- !debug: 21/06/2022 was width bit
		DATA2R_o	        : OUT	std_logic_vector(NumOfTiles*WORD_WIDTH2-1 downto 0); -- !debug: 21/06/2022 was width (WORD_WIDTH2-1 downto 0)
        DPOS_PGOOD        : in std_logic;                                    -- 17/04/2023
        ACLK_and_TILES_CLK_EN : out std_logic;                               -- 24/04/2023
        Power_en          : out std_logic_vector (2 downto 0); -- 22/12/2022 Analog power enable !debug: for  ASIC Power Sequence Test
        SPI_ERRs          : out	std_logic_vector(3*NumOfTiles-1 downto 0) --add by Dalit 10/10/2023
    );
 END COMPONENT;


-- component config_regs_ram is
--  Port (
--    clka : in STD_LOGIC;
--    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
--    addra : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    dina : in STD_LOGIC_VECTOR ( 39 downto 0 );
--    clkb : in STD_LOGIC;
--    addrb : in STD_LOGIC_VECTOR ( 7 downto 0 );
--    doutb : out STD_LOGIC_VECTOR ( 39 downto 0 )
--  );
-- end component;


-- COMPONENT regs_fifo IS
--     PORT
--     (
--     	aclr		: IN STD_LOGIC ;
--     	clock		: IN STD_LOGIC ;
--     	data		: IN STD_LOGIC_VECTOR (39 DOWNTO 0);
--     	rdreq		: IN STD_LOGIC ;
--     	wrreq		: IN STD_LOGIC ;
--     	empty		: OUT STD_LOGIC ;
--     	full		: OUT STD_LOGIC ;
--     	q			: OUT STD_LOGIC_VECTOR (39 DOWNTO 0);
--     	usedw		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
--     );
-- END COMPONENT;
-- !debug: 29/01/2020 replaced with Xilinx IP
component regs_fifo is
  Port (
    clk : in STD_LOGIC;
    srst : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 39 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 39 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    data_count : out STD_LOGIC_VECTOR ( 5 downto 0 )
  );
 end component;

signal Tiles_rst_s          : std_logic_vector (NumOfTiles-1 downto 0); -- !debug: 30/03/2021 was 7

-- signal RAM_address          : std_logic_vector (13 downto 0);
-- signal SPI_BUS_CTRL         : std_logic_vector (39 downto 0);
 signal SPI_BUS_CTRL  		: std_logic_vector((NumOfTiles*40)-1 downto 0); -- 29/06/2021
 signal RAM_rd_en_o         : std_logic_vector(NumOfTiles-1 downto 0); -- 29/06/2021
-- signal SPI_BUS_CTRL_CFG	    : std_logic_vector (39 downto 0);
-- signal SPI_BUS_CTRL_regs	: std_logic_vector (39 downto 0);
signal RAM_rd_en,RAM_rd_en_s: std_logic_vector (1 downto 0);
-- signal fifo_status          : STD_LOGIC ;
signal fifo_status       : std_logic_vector(NumOfTiles-1 downto 0); -- 29/06/2021
signal fifo_clear   		: std_logic_vector(NumOfTiles-1 downto 0); -- 23/11/2022
signal sclr					: STD_LOGIC ;

signal fifo_ram_sel			: STD_LOGIC ;								--	select the source of control Bus  fifo or ram


BEGIN
-------------------------------------------------------------------------------

----------------------------------------------------
phoebe_cntrlspisplit_inst : phoebe_cntrlspisplit
    GENERIC MAP(
    	WORD_WIDTH1	=> 14,
		WORD_WIDTH2	=> 15
    )
    PORT MAP(
        RESET_N       		=> RESET_N       		,
        clk          		=> clk          		,
        ACLK_Master => ACLK_Master,     -- 05/04/2021
		locked_fast   		=> locked_fast   		,
		DiscardIP           => DiscardIP                 ,
		Discard          	=> Discard          	,
		IP                  => IP                  ,
		SYNC          	    => SYNC          	    ,
		ACLK          		=> ACLK          		,
        -- AMS_Time => AMS_Time,           -- 08/04/2021
		SPI_BUS_CTRL  		=> SPI_BUS_CTRL  		,
        RAM_rd_en_o         => RAM_rd_en_o, -- 29/06/2021
	    CNT_lines           =>  CNT_lines	        ,
	    SCSn                => SCSn                 ,
		SDI	                => SDI	                ,
		SCLK	            => SCLK	                ,
		SDO                 => SDO                 	,
		Tiles_rst    		=> Tiles_rst_s    		,
        fifo_clear          => fifo_clear           , -- 23/11/2022
		Bias				=> Bias				    ,
		Calib				=> Calib				,
        calib_ctl_reg       => calib_ctl_reg, -- 10/05/2021
        diag_reg            => diag_reg,      -- 07/11/2021
        exit_from_asic_reset => exit_from_asic_reset,   -- 20/04/2023
        calib_completed => calib_completed,             -- 12/03/2025
        pass_addr_test      => pass_addr_test,    -- 09/08/2021
        registers_test_result => registers_test_result, -- 05/01/2022
        overhead_bits       => overhead_bits, -- 22/06/2021
		RAM_rd_en           => RAM_rd_en            , -- NU
		RAM_address         => open, -- !debug: 01/12/2022  was  RAM_address          ,
        fifo_status  		=> fifo_status          ,
		READ_OUT_ready_o    => READ_OUT_ready_o   ,
        DPOS_PGOOD          => DPOS_PGOOD,     -- 17/04/2023
        ACLK_and_TILES_CLK_EN => ACLK_and_TILES_CLK_EN, -- 24/04/2023
		DATA2R_o	        => DATA2R_o,
        Power_en            => Power_en,  -- 22/12/2022
        SPI_ERRs            => SPI_ERRs         --add by Dalit 10/10/2023 --add by Dalit 10/10/2023
    );


-- -- !debug: 29/01/2020 replaced with Xilinx IP
-- --                    RAM_rd_en(0) NU
-- config_regs_ram_inst : config_regs_ram
--   port map (
--     clka  => clk,
--     wea   => wrreq(0 downto 0),
--     addra => RAM_wraddress,
--     dina  => REGS_req,
--     clkb  => clk,
--     addrb => RAM_address(7 downto 0),
--     doutb => SPI_BUS_CTRL_CFG
--   );

--	aclr<= not Tiles_rst_s(0);


-- regs_fifo_inst: regs_fifo
--     PORT MAP
--     (
--     	aclr		=> aclr          ,
--     	clock		=> clk                  ,
--     	data		=> REGS_req             ,
--     	rdreq		=> RAM_rd_en(1)         ,
--     	wrreq		=> wrreq(1)                ,
--     	empty		=> fifo_status          ,
--     	q			=> SPI_BUS_CTRL_REGS
--     );

-- 29/06/2021
regs_fifo_g : for i in 0 to (NumOfTiles-1) generate

-- !debug: 29/01/2020 replaced with Xilinx IP
  regs_fifo_inst : regs_fifo
    port map (
      clk        => clk,
      srst       => sclr,
      din        => REGS_req,
      wr_en      => wrreq(1),
      rd_en      => RAM_rd_en_o(i),  -- !debug: 29/06/2021 was   RAM_rd_en(1),
      dout       => SPI_BUS_CTRL(i*40+39 downto i*40),  -- !debug: 29/06/2021 SPI_BUS_CTRL_REGS,
      full       => open,
      empty      => fifo_status(i),
      data_count => open
      );

end generate regs_fifo_g;



-- process(RESET_N,clk)
-- 	begin
-- 		if (RESET_N = '0') then
-- 			SPI_BUS_CTRL<=(others=>'0');
-- 			RAM_rd_en_s<="00";
-- 		elsif rising_edge(clk) then
-- 			RAM_rd_en_s<=RAM_rd_en;
-- 			if    RAM_rd_en_s(0)='1' then
-- 				SPI_BUS_CTRL<=SPI_BUS_CTRL_CFG;
-- 			elsif RAM_rd_en_s(1)='1' then
-- 				SPI_BUS_CTRL<=SPI_BUS_CTRL_REGS;
-- 			end if;
-- 		end if;
-- end process;







process(RESET_N,clk)
	begin
		if (RESET_N = '0') then
			fifo_ram_sel	<=	'0' ;
          sclr <= '0';
		elsif rising_edge(clk) then

			if    RAM_rd_en(0)='1' then
				fifo_ram_sel	<=	'0' ;
			elsif RAM_rd_en(1)='1' then
				fifo_ram_sel	<=	'1' ;
			end if;
            sclr <= not fifo_clear(0);  -- 23/11/2022 fifo reset was combinatorial signal prevent set RESETn[0] to IOB
		end if;
end process;


--    with fifo_ram_sel select									--  Read register depended on control lines
--
--    			SPI_BUS_CTRL 	<= 	SPI_BUS_CTRL_CFG		when 	'0',
--    								SPI_BUS_CTRL_REGS 		when 	'1',
--    								SPI_BUS_CTRL_REGS 		when others;
-- !debug: 29/06/2021 SPI_BUS_CTRL_CFG never uses, because never phoebe_controller.sm_powerup = Config_regs


 Tiles_rst		<=		Tiles_rst_s;





------------------------------------------------------------------------------
END architecture behave;
-------------------------------------------------------------------------------
