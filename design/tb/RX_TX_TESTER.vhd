
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-- Library UNISIM;
-- use UNISIM.vcomponents.all;

entity RX_TX_TESTER is
GENERIC (
  G_DATA_LENGTH:INTEGER:=32;
  DIAGNSOTIC_REGS : BOOLEAN
  );
Port (
    START_TEST  : IN STD_LOGIC ;
    RST         : IN STD_LOGIC ;
    RX_IN       : IN STD_LOGIC ;
    clk_inPLL_p : IN     std_logic;
    clk_inPLL_n : IN     std_logic;

    TX_DATA_out : OUT STD_LOGIC;
    CHANNEL_RDY : OUT STD_LOGIC ;
    --CLKDIV_50MHz      : IN STD_LOGIC ;--50MHZ--CLKp_200MHz : IN STD_LOGIC;
    --FCLK_200MHz       : IN STD_LOGIC ;--200MHz--CLKn_200MHz : IN STD_LOGIC;
    STATUS            : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        --BANK REGISTER OUTPUTS:
    MU_CTRL                 :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ADD_CONST_OFST_TO_MU    :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONST_OFST_VAL_TO_MU    :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_TST_CAL_CTRL_TEST  :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    TEST_ERROR              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_TEST_ERROR        :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    DIAGNSOTICS             :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    GLOBL_IP_COEF           :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    DIAGNSOTICS_TMP         :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_DATA_ALIGNMENT     :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    MODULE_DATA_OUT_SELCTION:IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_HL              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_LL              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_PER_TILE        :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    -- NOT_VALID_ADDR          :OUT STD_LOGIC;
    --INDICATION FOR BAD RECEIVED
    BAD_PACKET_RECEIVED     :IN STD_LOGIC;
    CRC_ERROR               :IN STD_LOGIC;
    STD_ERROR               :IN STD_LOGIC;
    OUT_CLKDIV_50MHz      : OUT STD_LOGIC ;--50MHZ--CLKp_200MHz : IN STD_LOGIC;
    OUT_FCLK_200MHz       : OUT STD_LOGIC; --200MHz--CLKn_200MHz : IN STD_LOGIC;
    PLL_locked            : out    std_logic
    );

end RX_TX_TESTER;

architecture RX_TX_TESTER_ARC of RX_TX_TESTER is

COMPONENT TX_Zynq
   Generic ( IDLE_WORD      : std_logic_vector (7 downto 0) :=x"B5";
			 StartWord      : std_logic_vector (7 downto 0) :=x"21";
			 Stream_type1   : std_logic_vector (7 downto 0) :=x"43";
			 Stream_type2   : std_logic_vector (7 downto 0) :=x"DD";

			 NumHeaderbytes : std_logic_vector (7 downto 0) :=x"02";
             NumDatabytes   : std_logic_vector (31 downto 0):=x"00000004";
			 NumFooterbytes : std_logic_vector (7 downto 0) :=x"03"

);
   PORT(
	 RESET             : IN     std_logic;
     CLKDIV     	   : IN     std_logic;
	 FCLK	           : IN     std_logic;
	 STATn_DYN         : IN     std_logic;
	 GO                : IN     std_logic;
	 IP                : IN     std_logic;
	 PayloadSize       : IN     std_logic_vector (31 downto 0);
	 DATA_IN        : IN     std_logic_vector (7 downto 0);
	 RD_EMPTY          : IN     std_logic;
	 RD_CLK   	       : OUT    std_logic;
	 RD_REQ            : OUT    std_logic;
	 Tristate_i        : IN     std_logic;
	 Tristate_o        : OUT    std_logic;
	 DATA_out       : OUT	std_logic
   );

END COMPONENT;

COMPONENT RX_Zynq
    Generic (
      IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
	  StartWord      : std_logic_vector (7 downto 0):=x"21";
	  Stream_type1   : std_logic_vector (7 downto 0):=x"43";
	  Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
	  TapWidth       : natural := 9;
	  ParallelWidth  : natural := 8;
      NumHeaderBytes : natural := 2;
	  NumDataBytes   : natural := 4;
	  NumFooterBytes : natural := 3

	  );
    PORT(
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		FCLK      		        : in    std_logic;   --serial clock input side
		Channel_RDY   	        : in    std_logic;
		sDataIn                 : in    std_logic;
		IDLY_CNT  		        : out   std_logic_vector(TapWidth-1 downto 0);  --IDELAYE3 Current Tap Count
		RX_det_o       	        : OUT   std_logic_vector (7 downto 0);
		start_valid             : OUT   std_logic;
		Headers_valid           : OUT   std_logic;
		data_valid              : OUT   std_logic;
		Footers_valid           : OUT   std_logic;
		IP_pckt_valid           : OUT   std_logic;
		packet_received         : OUT   std_logic;
		good_packet_received    : OUT   std_logic;
		bad_packet_received     : OUT   std_logic;
		crc_error               : OUT   std_logic;
        std_error               : OUT   std_logic

    	);

END COMPONENT;

---------TX_FIFO---------
 COMPONENT TX_FIFO
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;--always '1'
    rd_en : IN STD_LOGIC;--always '1'
    dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full  : OUT STD_LOGIC;
    empty : OUT STD_LOGIC

  );
END COMPONENT;
constant Max_s_delay_cnt_val : integer :=3000;
--SIGNAL S_RX_IN         :std_logic;
SIGNAL S_TX_OUT        :std_logic;
-----TX
SIGNAL S_RD_EMPTY       :std_logic;
SIGNAL S_RD_CLK   	    :std_logic;
SIGNAL S_RD_REQ         :std_logic;
SIGNAL S_Tristate_i     :std_logic;
SIGNAL S_Tristate_O     :std_logic;

SIGNAL S_TX_FIFO_OUT :std_logic_VECTOR (7 DOWNTO 0);
----RX
---signals for tests

SIGNAL S_CLKp_200MHz     : STD_LOGIC ;
SIGNAL S_CLKn_200MHz     : STD_LOGIC ;
--SIGNAL S_CLKDIV     	 : std_logic;
--SIGNAL S_FCLK	         : std_logic;
SIGNAL S_STATn_DYN       : std_logic;
SIGNAL S_GO              : std_logic;
SIGNAL S_IP              : std_logic;
SIGNAL S_PayloadSize     : std_logic_vector (31 downto 0);
SIGNAL S_SYNT_DATA_IN  : std_logic_vector (7 downto 0);
SIGNAL S_DATAIN          : std_logic;
SIGNAL S_CHANNEL_RDY     : std_logic;
SIGNAL S_WR_EN           : std_logic;
SIGNAL S_DATA_FROM_ZTNQTX        : std_logic_vector (7 downto 0);


--
signal S_case_counter_sig : std_logic_vector (7 downto 0);
signal S_tx_data_08_sig : std_logic_vector (7 downto 0);
--
signal S_bit_counter : INTEGER RANGE  0 TO 9:=0;
signal S_data_byte_cnt: INTEGER RANGE  0 TO 100:=0;
signal s_delay_cnt : integer range 0 to Max_s_delay_cnt_val;

SIGNAL S_CLK_200MHz:STD_LOGIC:='0';
--SIGNAL S_CLKDIV_50MHz      : STD_LOGIC ;--50MHZ--
--SIGNAL S_FCLK_200MHz       : STD_LOGIC ;--200MHz-
---clk_wiz_1-----------
component clk_wiz_1
port
 (-- Clock in ports
  -- Clock out ports
  clk_200MHz        : out    std_logic;
  clk_50MHz         : out    std_logic;
  -- Status and control signals
  reset             : in     std_logic;
  locked            : out    std_logic;
  clk_in1_p         : in     std_logic;
  clk_in1_n         : in     std_logic
 );
end component;

SIGNAL S_clk_50MHz         :     std_logic;
SIGNAL S_locked            :     std_logic;

  -- !debug: 19/02/2023
  type REGS_TEST_REC is record
    cmd          : string(1 to 2);                 -- RD/WR command in header
    data         : std_logic_vector(31 downto 0);  -- data
    footer       : std_logic_vector(23 downto 0);  -- address
    shedule_time : time;
  end record REGS_TEST_REC;

  type REGS_TEST_TYP is array (positive range <>) of REGS_TEST_REC;
  constant regs_test_remote : REGS_TEST_TYP := (
    -- ("WR",X"00000000",X"006800",11 US), -- page_num & page_addr
    -- ("WR",X"00008512",X"006810",12 US), -- erase: EXE & command & sector_num
    ("WR",X"85120000",X"006800",12 US), -- erase: EXE & command & sector_num & page_num & page_addr
    ("OK",X"00000000",X"000000",149 US), -- max 1 sec Sector erase time
    ("WR",X"00000002",X"006820",150 US), -- Reset Data FIFO and Errors
    ("WR",X"00000000",X"006820",151 US), -- exit from FIFO reset
    ("WR",X"00020406",X"006850",152 US), -- data to Configuration FIFO
    ("WR",X"080a0c0e",X"006850",153 US), -- data to Configuration FIFO
    ("WR",X"10121416",X"006850",154 US), -- data to Configuration FIFO
    ("WR",X"181a1c1e",X"006850",155 US), -- data to Configuration FIFO
    ("WR",X"20222426",X"006850",156 US), -- data to Configuration FIFO
    ("WR",X"282a2c2e",X"006850",157 US), -- data to Configuration FIFO
    ("WR",X"30323436",X"006850",158 US), -- data to Configuration FIFO
    ("WR",X"383a3c3e",X"006850",159 US), -- data to Configuration FIFO
    ("WR",X"40424446",X"006850",160 US), -- data to Configuration FIFO
    ("WR",X"484a4c4e",X"006850",161 US), -- data to Configuration FIFO
    ("WR",X"50525456",X"006850",162 US), -- data to Configuration FIFO
    ("WR",X"585a5c5e",X"006850",163 US), -- data to Configuration FIFO
    ("WR",X"60626466",X"006850",164 US), -- data to Configuration FIFO
    ("WR",X"686a6c6e",X"006850",165 US), -- data to Configuration FIFO
    ("WR",X"70727476",X"006850",166 US), -- data to Configuration FIFO
    ("WR",X"787a7c7e",X"006850",167 US), -- data to Configuration FIFO
    ("WR",X"80828486",X"006850",168 US), -- data to Configuration FIFO
    ("WR",X"888a8c8e",X"006850",169 US), -- data to Configuration FIFO
    ("WR",X"90929496",X"006850",170 US), -- data to Configuration FIFO
    ("WR",X"989a9c9e",X"006850",171 US), -- data to Configuration FIFO
    ("WR",X"a0a2a4a6",X"006850",172 US), -- data to Configuration FIFO
    ("WR",X"a8aaacae",X"006850",173 US), -- data to Configuration FIFO
    ("WR",X"b0b2b4b6",X"006850",174 US), -- data to Configuration FIFO
    ("WR",X"b8babcbe",X"006850",175 US), -- data to Configuration FIFO
    ("WR",X"c0c2c4c6",X"006850",176 US), -- data to Configuration FIFO
    ("WR",X"c8caccce",X"006850",177 US), -- data to Configuration FIFO
    ("WR",X"d0d2d4d6",X"006850",178 US), -- data to Configuration FIFO
    ("WR",X"d8dadcde",X"006850",179 US), -- data to Configuration FIFO
    ("WR",X"e0e2e4e6",X"006850",180 US), -- data to Configuration FIFO
    ("WR",X"e8eaecee",X"006850",181 US), -- data to Configuration FIFO
    ("WR",X"f0f2f4f6",X"006850",182 US), -- data to Configuration FIFO
    ("WR",X"f8fafcfe",X"006850",183 US), -- data to Configuration FIFO
    ("WR",X"00020406",X"006850",184 US), -- data to Configuration FIFO
    ("WR",X"080a0c0e",X"006850",185 US), -- data to Configuration FIFO
    ("WR",X"10121416",X"006850",186 US), -- data to Configuration FIFO
    ("WR",X"181a1c1e",X"006850",187 US), -- data to Configuration FIFO
    ("WR",X"20222426",X"006850",188 US), -- data to Configuration FIFO
    ("WR",X"282a2c2e",X"006850",189 US), -- data to Configuration FIFO
    ("WR",X"30323436",X"006850",190 US), -- data to Configuration FIFO
    ("WR",X"383a3c3e",X"006850",191 US), -- data to Configuration FIFO
    ("WR",X"40424446",X"006850",192 US), -- data to Configuration FIFO
    ("WR",X"484a4c4e",X"006850",193 US), -- data to Configuration FIFO
    ("WR",X"50525456",X"006850",194 US), -- data to Configuration FIFO
    ("WR",X"585a5c5e",X"006850",195 US), -- data to Configuration FIFO
    ("WR",X"60626466",X"006850",196 US), -- data to Configuration FIFO
    ("WR",X"686a6c6e",X"006850",197 US), -- data to Configuration FIFO
    ("WR",X"70727476",X"006850",198 US), -- data to Configuration FIFO
    ("WR",X"787a7c7e",X"006850",199 US), -- data to Configuration FIFO
    ("WR",X"80828486",X"006850",200 US), -- data to Configuration FIFO
    ("WR",X"888a8c8e",X"006850",201 US), -- data to Configuration FIFO
    ("WR",X"90929496",X"006850",202 US), -- data to Configuration FIFO
    ("WR",X"989a9c9e",X"006850",203 US), -- data to Configuration FIFO
    ("WR",X"a0a2a4a6",X"006850",204 US), -- data to Configuration FIFO
    ("WR",X"a8aaacae",X"006850",205 US), -- data to Configuration FIFO
    ("WR",X"b0b2b4b6",X"006850",206 US), -- data to Configuration FIFO
    ("WR",X"b8babcbe",X"006850",207 US), -- data to Configuration FIFO
    ("WR",X"c0c2c4c6",X"006850",208 US), -- data to Configuration FIFO
    ("WR",X"c8caccce",X"006850",209 US), -- data to Configuration FIFO
    ("WR",X"d0d2d4d6",X"006850",210 US), -- data to Configuration FIFO
    ("WR",X"d8dadcde",X"006850",211 US), -- data to Configuration FIFO
    ("WR",X"e0e2e4e6",X"006850",212 US), -- data to Configuration FIFO
    ("WR",X"e8eaecee",X"006850",213 US), -- data to Configuration FIFO
    ("WR",X"f0f2f4f6",X"006850",214 US), -- data to Configuration FIFO
    ("WR",X"f8fafcfe",X"006850",215 US), -- data to Configuration FIFO
    ("RD",X"00000000",X"006840",310 US), -- Read FIFO Fill Counter
    -- ("WR",X"00000000",X"006800",311 US), -- page_num & page_addr
    -- ("WR",X"00008412",X"006810",312 US), -- Page Program: EXE & command & sector_num
    ("WR",X"84120000",X"006800",311 US), -- Page Program: EXE & command & sector_num & page_num & page_addr
    ("WR",X"83120000",X"006800",2500 US), -- Read 4 bytes from Flash: EXE & command & sector_num & page_num & page_addr
    ("RD",X"00000000",X"006860",2520 US), -- Read Flash Data to CDM
    ("WR",X"83120004",X"006800",2530 US), -- Read 4 bytes from Flash: EXE & command & sector_num & page_num & page_addr
    ("RD",X"00000000",X"006860",2550 US), -- Read Flash Data to CDM
    ("WR",X"83120008",X"006800",2560 US), -- Read 4 bytes from Flash: EXE & command & sector_num & page_num & page_addr
    ("RD",X"00000000",X"006860",2580 US), -- Read Flash Data to CDM
    ("ST",X"00000000",X"000000",2600 US));
  constant regs_test_ams : REGS_TEST_TYP := (
    -- ("WR",X"00000001",X"006780",237 US), -- !debug: 10/12/2023 remove after test. [0] - keep align, [1] - '0' select slave ASIC's, [3] - Asic's master/slave broadcast
    -- ("WR",X"C0120000",X"006650",417 US), -- !debug: 10/12/2023 remove after test. read ASIC register 0x0012
    ("WR",X"C0240000",X"006650",417 US), -- !debug: 10/12/2023 remove after test. read ASIC register 0x0024 IP_ACLK_COUNT
    ("WR",X"02000000",X"006660",487 US), -- !debug: 10/12/2023 remove after test. Asics Read Select: [31] - '1' master tile, [27..24] - ASIC in tile--
    ("WR",X"80122D60",X"006650",517 US), -- [31..16] - ASIC addr, [15..0] - ASIC data
    ("WR",X"80100003",X"006650",617 US),
    ("WR",X"801F0355",X"006650",717 US),
    ("WR",X"80132211",X"006650",817 US),
    ("WR",X"80140866",X"006650",917 US),
    ("WR",X"80150155",X"006650",1017 US),
    ("WR",X"80160098",X"006650",1117 US),
    ("WR",X"80170000",X"006650",1217 US),
    ("WR",X"00000003",X"006780",1237 US), -- [0] - keep align, [1] - '1' select master ASIC's, [3] - Asic's master/slave broadcast
    ("WR",X"C0120000",X"006650",1317 US), -- read ASIC register 0x0012
    ("WR",X"82000000",X"006660",1417 US), -- Asics Read Select: [31] - '1' master tile, [27..24] - ASIC in tile
    ("RD",X"00000000",X"006660",1517 US), -- send register data TMB to CDM
    ("WR",X"80531000",X"006650",1617 US),
    ("ST",X"80170000",X"006650",1717 US));
  constant regs_general : REGS_TEST_TYP := (
    ("WR",X"000BF170",X"006700",117 US), -- disable MU, no OS
    ("WR",X"00000018",X"006750",147 US), -- disable LEDS, turn on synthetic data with LUT bypass
    ("WR",X"00000000",X"006790",187 US), -- use rx_det[15..0]
    ("RD",X"00000000",X"006700",617 US),
    ("RD",X"00000000",X"006750",717 US),
    ("ST",X"00000000",X"000000",1517 US));
  constant regs_calib : REGS_TEST_TYP := (
    ("WR",X"000BF171",X"006700",117 US), -- [0] '0' - disable MU, no OS
    ("WR",X"0000000A",X"006780",147 US), -- Enable Broadcast write Mode to Asics
    ("WR",X"00000018",X"006750",187 US), -- turn on synthetic data with LUT bypass
    ("WR",X"00000000",X"006790",217 US), -- use rx_det[15..0]
    ("WR",X"00000000",X"006730",247 US), -- stop calibration
    ("WR",X"00008007",X"006730",287 US), -- start calibration
    ("WR",X"00000002",X"006780",1617 US),
    ("WR",X"00000000",X"006780",2017 US),
    ("WR",X"00000002",X"006780",2317 US),
    ("ST",X"00000000",X"000000",2417 US));
  constant regs_diags : REGS_TEST_TYP := (
    ("RD",X"00000000",X"006400",417 US), -- Firmware Version
    ("WR",X"00000018",X"006510",517 US), -- Module Temperature bits(31..16): Outlet; bits(15..0): Inlet;
    -- ("RD",X"00000000",X"006440",617 US),  -- Number of Slices
    ("RD",X"00000000",X"0063A0",617 US),
    ("WR",X"00000100",X"0063A0",717 US),  -- [8] - Ignore Next IP when set (Sample rising edge), [9] - Ignore Next Headers when set (Sample rising edge)
    ("WR",X"00000200",X"0063A0",917 US),
    ("WR",X"00000300",X"0063A0",1117 US),
    -- ("RD",X"00000000",X"006380",777 US),  -- RTL_buffer_deep
    -- ("RD",X"00000000",X"006390",817 US),  -- HD_buffer_deep
    ("RD",X"00000000",X"0063B8",1317 US), -- ip_pkt_cnt
    ("RD",X"00000000",X"0063BC",1417 US), -- headers_pkt_cnt
    ("RD",X"00000000",X"006304",1517 US), -- AMS_Time_test_reg
    ("WR",X"00000000",X"006304",1617 US), -- AMS_Time_test_reg clear
    ("ST",X"00000000",X"000000",1817 US));
  alias regs_operational_test_sig : REGS_TEST_TYP is regs_calib; -- WR/RD operational registers (Reg_in/_out), 0xBxxxx area
                                                                    -- regs_test_ams when AMS registers test,
                                                                    -- regs_general when misc 0xBxxx
                                                                    -- regs_calib: part of DMS Power up and Initialization sequences

  alias regs_diag_test_sig : REGS_TEST_TYP is regs_diags;  -- WR/RD diagnsotic registers (Diag_in/_out), 0xAxxxx area
                                                                 -- regs_test_remote when remote config test,
                                                                 -- regs_diags when misc 0xAxxx


  signal N_GO           : std_logic;
  signal N_WR_EN        : std_logic;
  signal N_SYNT_DATA_IN : std_logic_vector(7 downto 0);

  begin


----------------------------------------------------
clk_wiz_200MHz_50MHz : clk_wiz_1
   port map (
  -- Clock out ports
   clk_200MHz => S_clk_200MHz,--200
   clk_50MHz =>  S_clk_50MHz,--50MHz
  -- Status and control signals
   reset => RST,
   locked => S_locked,
   -- Clock in ports
   clk_in1_p => clk_inPLL_p,--in from RX_TX_TESTER_VXX_TB
   clk_in1_n => clk_inPLL_n--in from RX_TX_TESTER_VXX_TB
 );

 PLL_locked<=S_locked;

U2_TX_FIFO: TX_FIFO
  PORT MAP (
    rst => RST,
    wr_clk => S_clk_50MHz,
    rd_clk => S_RD_CLK,
    din => N_SYNT_DATA_IN, -- !debug: 20/02/2023   S_SYNT_DATA_IN,
    wr_en => N_WR_EN, -- !debug: 20/02/2023   S_WR_EN,
    rd_en => S_RD_REQ,
    dout => S_TX_FIFO_OUT,
    --full => S_TX_FIFO_full,
    empty => S_RD_EMPTY

  );




U3_TX_Zynq : TX_Zynq
   Generic MAP( IDLE_WORD   =>x"B5"			    ,
			 StartWord      =>X"21"              ,
			 Stream_type1   =>X"43"              ,
			 Stream_type2   =>X"DD"              ,

			 NumHeaderbytes =>X"02"              ,
             NumDatabytes   =>X"00000004"        ,
			 NumFooterbytes =>X"03"

)
   PORT map(
	 RESET             =>  RST                 ,
     CLKDIV     	   =>  S_clk_50MHz            ,--50
	 FCLK	           =>  S_clk_200MHz	           ,--200
	 STATn_DYN         =>  S_STATn_DYN         ,
	 GO                =>  N_GO, -- !debug: 20/02/2023 was  S_GO                ,
	 IP                =>  S_IP                ,
	 PayloadSize       =>  S_PayloadSize       ,
	 DATA_IN           =>  S_TX_FIFO_OUT           ,
	 RD_EMPTY          => S_RD_EMPTY ,
	 RD_CLK   	       =>  S_RD_CLK   	       ,
	 RD_REQ            =>  S_RD_REQ            ,
	 Tristate_i        =>  '0'        ,
	 Tristate_o        =>  S_Tristate_o        ,
	 DATA_out          =>  TX_DATA_out
   );


U4_RX_Zynq: RX_Zynq
    Generic MAP(
      IDLE_word      =>x"B5",
	  StartWord      =>x"21",
	  Stream_type1   =>x"43",
	  Stream_type2   =>x"DD",
	  TapWidth       =>9,
	  ParallelWidth  =>8,
      NumHeaderBytes =>2,
	  NumDataBytes   =>4,
	  NumFooterBytes =>3

	  )
    PORT MAP(
        RESET       		   =>  RST    ,
        CLKDIV          	   =>  S_clk_50MHz ,
		FCLK      		       =>  S_clk_200MHz,
		channel_RDY   	       =>  S_channel_RDY ,
		sDataIn                =>  RX_IN     ,
		RX_det_o       	       =>  S_DATA_FROM_ZTNQTX

    	);
----for tests:
S_STATn_DYN     <= '0';
S_IP            <= '0' ;
S_PayloadSize   <=(others=>'0');
S_DATAIN        <='1' ;
S_CHANNEL_RDY   <= '1' ;
CHANNEL_RDY   <= '1' ;

--S_CLKp_200MHz<=CLKp_200MHz;
--S_CLKn_200MHz<=CLKn_200MHz;
status<=X"ABCD";
OUT_CLKDIV_50MHz<=S_clk_50MHz;
OUT_FCLK_200MHz <=S_clk_200MHz;
--S_FCLK<=S_CLKp_200MHz;

--clk200MHz_proc: PROCESS

--   BEGIN
--    S_CLKp_200MHz <= '1';
--    S_CLKn_200MHz <= '0';
--    wait for 0.1 ns;
--    S_CLKp_200MHz <= '0';
--    S_CLKn_200MHz <= '1';
--    wait for 0.1 ns;
--end process;

-- clk50MHz_proc: PROCESS
--     --CREATE CLK OF 50MHz
--   BEGIN
--    S_CLKDIV <= '1';
--    wait for 0.4 ns;
--    S_CLKDIV <= '0';
--    wait for 0.4 ns;
--end process;

S_GO_CNT: process (S_clk_200MHz, RST) --200MHz clk
--counts the bits of each data byte (9 bits)
begin
IF RST='1' THEN
     S_bit_counter<=0;
ELSIF RISING_EDGE(S_clk_200MHz)  then
    IF S_bit_counter<7 THEN
            S_bit_counter <= S_bit_counter +1;
     ELSE   S_bit_counter<=0;
     END IF;
END IF;
end process;



GO_SIGNAL: process (S_clk_50MHz, RST)
begin
IF RST='1' THEN
     S_GO<='0';

ELSIF RISING_EDGE(S_clk_50MHz) then
           CASE s_delay_cnt IS
           WHEN 0 TO 395 => S_GO<='0';
           WHEN 396 =>S_GO<='1';-- AFTER 9 BYTES CREATE ONE PULSE
           WHEN 397 TO Max_s_delay_cnt_val=>S_GO<='0';

           WHEN OTHERS=>S_GO<='0';
           END CASE;


END IF;
end process;

wr_en_process:process(S_clk_50MHz, RST)
begin
IF RST='1' THEN
    S_WR_EN<='0';
    s_delay_cnt<=0;
ELSIF RISING_EDGE(S_clk_50MHz) THEN
    IF s_delay_cnt <= 46 THEN
        S_WR_EN<='0';
        s_delay_cnt<=s_delay_cnt+1;
    ELSIF  s_delay_cnt >= 47 AND s_delay_cnt<56 THEN
        S_WR_EN<='1';
         s_delay_cnt<=s_delay_cnt+1;
    ELSIF  s_delay_cnt >= 56 AND s_delay_cnt <Max_s_delay_cnt_val  THEN
         S_WR_EN<='0';
         s_delay_cnt<=s_delay_cnt+1;
    ELSIF  s_delay_cnt =Max_s_delay_cnt_val  THEN
            s_delay_cnt<=0;
    END IF;
END IF;
end process;




SYNTHETIC_DATA_PRO: PROCESS(S_clk_50MHz, RST) --50MHz clk
BEGIN


IF RST='1' THEN
     S_case_counter_sig<=x"00";
     S_tx_data_08_sig<= x"F1";-- 1 IS WRITE 2 READ
     S_SYNT_DATA_IN<=(others=>'0');

ELSIF RISING_EDGE(S_clk_50MHz) then
        IF s_delay_cnt > 46 and s_delay_cnt<=55 AND S_case_counter_sig < X"74" THEN --2d" THEN  --1b" THEN
            S_case_counter_sig <= std_logic_vector(unsigned(S_Case_counter_sig)+ "1");
             S_SYNT_DATA_IN<=S_tx_data_08_sig;


                case S_case_counter_sig is
					when x"00" => S_tx_data_08_sig <= x"A1";--header 1
					when x"01" => S_tx_data_08_sig <= x"A2";--data   1--data[31..24]
					when x"02" => S_tx_data_08_sig <= x"A3";--data   1--data[23..16]
					when x"03" => S_tx_data_08_sig <= x"A4";--data   1--data[15..8]
					when x"04" => S_tx_data_08_sig <= x"A5";--data   1--data[7..0]
					when x"05" => S_tx_data_08_sig <= x"00";--addr   1--addr[23..16]
					when x"06" => S_tx_data_08_sig <= x"67";--addr   1--addr[15..8]
					when x"07" => S_tx_data_08_sig <= x"00";--addr   1--addr[7..0]
					when x"08" => S_tx_data_08_sig <= x"F0"; ----delta
					when x"09" => S_tx_data_08_sig <= x"B1";--header 2
					when x"0A" => S_tx_data_08_sig <= x"B2";--data   2 --data[31..24]
					when x"0B" => S_tx_data_08_sig <= x"B3";--data   2 --data[23..16]
					when x"0C" => S_tx_data_08_sig <= x"B4";--data   2 --data[15..8]
					when x"0D" => S_tx_data_08_sig <= x"B5";--data   2 --data[7..0]
					when x"0E" => S_tx_data_08_sig <= x"00";--addr   2 --addr[23..16]
					when x"0F" => S_tx_data_08_sig <= x"67";--addr   2 --addr[15..8]
					when x"10" => S_tx_data_08_sig <= x"10";--addr   2 --addr[7..0]
					when x"11" => S_tx_data_08_sig <= x"F0"; ----delta
					when x"12" => S_tx_data_08_sig <= x"C1";--header 3
					when x"13" => S_tx_data_08_sig <= x"C2";--data   3
					when x"14" => S_tx_data_08_sig <= x"C3";--data   3
					when x"15" => S_tx_data_08_sig <= x"C4";--data   3
					when x"16" => S_tx_data_08_sig <= x"C5";--data   3
					when x"17" => S_tx_data_08_sig <= x"00";--addr   3
					when x"18" => S_tx_data_08_sig <= x"67";--addr   3
					when x"19" => S_tx_data_08_sig <= x"20";--addr   3
					when x"1A" => S_tx_data_08_sig <= X"F0";----delta
  					when x"1B" => S_tx_data_08_sig <= X"D1";--header 4
        			when x"1C" => S_tx_data_08_sig <= x"D2";--data   4
        			when x"1D" => S_tx_data_08_sig <= x"D3";--data   4
        			when x"1E" => S_tx_data_08_sig <= x"D4";--data   4
        			when x"1F" => S_tx_data_08_sig <= x"D5";--data   4
        			when x"20" => S_tx_data_08_sig <= x"00";--addr   4
        			when x"21" => S_tx_data_08_sig <= x"67";--addr   4
        			when x"22" => S_tx_data_08_sig <= x"30";--addr   4
        			when x"23" => S_tx_data_08_sig <= x"F0";  ----delta
        			when x"24" => S_tx_data_08_sig <= x"E1";--header 5
        			when x"25" => S_tx_data_08_sig <= x"E2";---data   5
					when x"26" => S_tx_data_08_sig <= x"E3";---data   5
					when x"27" => S_tx_data_08_sig <= x"E4";---data   5
					when x"28" => S_tx_data_08_sig <= x"E5";---data   5
					when x"29" => S_tx_data_08_sig <= x"00";---addr   5
					when x"2A" => S_tx_data_08_sig <= x"67";---addr   5
					when x"2B" => S_tx_data_08_sig <= x"40";---addr   5
					when x"2C" => S_tx_data_08_sig <= x"F0";----delta
					when x"2D" => S_tx_data_08_sig <= x"2D";--header 6
					when x"2E" => S_tx_data_08_sig <= x"2E";---data 6--
					when x"2F" => S_tx_data_08_sig <= x"2F";---data 6-
					when x"30" => S_tx_data_08_sig <= x"30";---data 6-
					when x"31" => S_tx_data_08_sig <= x"31";---data 6-
					when x"32" => S_tx_data_08_sig <= x"00";---addr 6-
					when x"33" => S_tx_data_08_sig <= x"67";---addr 6-
					when x"34" => S_tx_data_08_sig <= x"50";---addr 6-
					when x"35" => S_tx_data_08_sig <= x"35";----delt
					when x"36" => S_tx_data_08_sig <= x"36";--header
					when x"37" => S_tx_data_08_sig <= x"37";---data 7
					when x"38" => S_tx_data_08_sig <= x"38";---data 7
					when x"39" => S_tx_data_08_sig <= x"39";---data 7
					when x"3A" => S_tx_data_08_sig <= x"3A";---data 7
					when x"3B" => S_tx_data_08_sig <= x"00";---addr 7
					when x"3C" => S_tx_data_08_sig <= x"67";---addr 7
					when x"3D" => S_tx_data_08_sig <= x"60";---addr 7
					when x"3E" => S_tx_data_08_sig <= x"3E";----delta
                    when x"3f" => S_tx_data_08_sig <= x"3f";--header 8
                    when x"40" => S_tx_data_08_sig <= x"40";---data  8
                    when x"41" => S_tx_data_08_sig <= x"41";---data  8
                    when x"42" => S_tx_data_08_sig <= x"42";---data  8
                    when x"43" => S_tx_data_08_sig <= x"43";---data  8
                    when x"44" => S_tx_data_08_sig <= x"00";---addr  8
                    when x"45" => S_tx_data_08_sig <= x"67";---addr  8
                    when x"46" => S_tx_data_08_sig <= x"70";---addr  8
                    when x"47" => S_tx_data_08_sig <= x"47";----delta
                    when x"48" => S_tx_data_08_sig <= x"48";--header 9
                    when x"49" => S_tx_data_08_sig <= x"49";---data  9
                    when x"4a" => S_tx_data_08_sig <= x"4a";---data  9
                    when x"4b" => S_tx_data_08_sig <= x"4b";---data  9
                    when x"4c" => S_tx_data_08_sig <= x"4c";---data  9
                    when x"4d" => S_tx_data_08_sig <= x"00";---addr  9
                    when x"4e" => S_tx_data_08_sig <= x"67";---addr  9
                    when x"4f" => S_tx_data_08_sig <= x"80";---addr  9
                    when x"50" => S_tx_data_08_sig <= x"50";----delta
                    when x"51" => S_tx_data_08_sig <= x"51";--header 10
                    when x"52" => S_tx_data_08_sig <= x"52";---data  10
                    when x"53" => S_tx_data_08_sig <= x"53";---data  10
                    when x"54" => S_tx_data_08_sig <= x"54";---data  10
                    when x"55" => S_tx_data_08_sig <= x"55";---data  10
                    when x"56" => S_tx_data_08_sig <= x"00";---addr  10
                    when x"57" => S_tx_data_08_sig <= x"67";---addr  10
                    when x"58" => S_tx_data_08_sig <= x"90";---addr  10
                    when x"59" => S_tx_data_08_sig <= x"59";----delta
                    when x"5a" => S_tx_data_08_sig <= x"5a";--header 11
                    when x"5b" => S_tx_data_08_sig <= x"5b";---data  11
                    when x"5c" => S_tx_data_08_sig <= x"5c";---data  11
                    when x"5d" => S_tx_data_08_sig <= x"5d";---data  11
                    when x"5e" => S_tx_data_08_sig <= x"5e";---data  11
                    when x"5f" => S_tx_data_08_sig <= x"00";---addr  11
                    when x"60" => S_tx_data_08_sig <= x"67";---addr  11
                    when x"61" => S_tx_data_08_sig <= x"A0";---addr  11
                    when x"62" => S_tx_data_08_sig <= x"62";----delta
                    when x"63" => S_tx_data_08_sig <= x"63";--header 12
                    when x"64" => S_tx_data_08_sig <= x"64";---data  12
                    when x"65" => S_tx_data_08_sig <= x"65";---data  12
                    when x"66" => S_tx_data_08_sig <= x"66";---data  12
                    when x"67" => S_tx_data_08_sig <= x"67";---data  12
                    when x"68" => S_tx_data_08_sig <= x"00";---addr  12
                    when x"69" => S_tx_data_08_sig <= x"67";---addr  12
                    when x"6a" => S_tx_data_08_sig <= x"B0";---addr  12
                    when x"6b" => S_tx_data_08_sig <= x"00";----delta
                    when x"6c" => S_tx_data_08_sig <= x"6c";--header 1
                    when x"6d" => S_tx_data_08_sig <= x"6d";---data  13
                    when x"6e" => S_tx_data_08_sig <= x"6e";---data  13
                    when x"6f" => S_tx_data_08_sig <= x"6f";---data  13
                    when x"70" => S_tx_data_08_sig <= x"70";---data  13
                    when x"71" => S_tx_data_08_sig <= x"00";---addr  13 -
                    when x"72" => S_tx_data_08_sig <= x"67";---addr  13 -
                    when x"73" => S_tx_data_08_sig <= x"C0";---addr  13 -
                    when x"74" => S_tx_data_08_sig <= x"74";----delta
                    when x"75" => S_tx_data_08_sig <= x"75";
--                    when x"76" => S_tx_data_08_sig <= x"76";
--                    when x"77" => S_tx_data_08_sig <= x"77";
--                    when x"78" => S_tx_data_08_sig <= x"78";
--                    when x"79" => S_tx_data_08_sig <= x"79";
--                    when x"7a" => S_tx_data_08_sig <= x"7a";
--                    when x"7b" => S_tx_data_08_sig <= x"7b";
--                    when x"7c" => S_tx_data_08_sig <= x"7c";
--                    when x"7d" => S_tx_data_08_sig <= x"7d";
--                    when x"7e" => S_tx_data_08_sig <= x"7e";
--                    when x"7f" => S_tx_data_08_sig <= x"7f";
--                    when x"80" => S_tx_data_08_sig <= x"80";
--                    when x"81" => S_tx_data_08_sig <= x"81";
--                    when x"82" => S_tx_data_08_sig <= x"82";
--                    when x"83" => S_tx_data_08_sig <= x"83";
--                    when x"84" => S_tx_data_08_sig <= x"84";
--                    when x"85" => S_tx_data_08_sig <= x"85";
--                    when x"86" => S_tx_data_08_sig <= x"86";
--                    when x"87" => S_tx_data_08_sig <= x"87";
--                    when x"88" => S_tx_data_08_sig <= x"88";
--                    when x"89" => S_tx_data_08_sig <= x"89";
--                    when x"8a" => S_tx_data_08_sig <= x"8a";
--                    when x"8b" => S_tx_data_08_sig <= x"8b";
--                    when x"8c" => S_tx_data_08_sig <= x"8c";
--                    when x"8d" => S_tx_data_08_sig <= x"8d";
--                    when x"8e" => S_tx_data_08_sig <= x"8e";
--                    when x"8f" => S_tx_data_08_sig <= x"8f";
--                    when x"90" => S_tx_data_08_sig <= x"90"
--                    when x"91" => S_tx_data_08_sig <= x"91";
--                    when x"92" => S_tx_data_08_sig <= x"92";
--                    when x"93" => S_tx_data_08_sig <= x"93";
--                    when x"94" => S_tx_data_08_sig <= x"94";
--                    when x"95" => S_tx_data_08_sig <= x"95";
--                    when x"96" => S_tx_data_08_sig <= x"96";
--                    when x"97" => S_tx_data_08_sig <= x"97";
--                    when x"98" => S_tx_data_08_sig <= x"98";
--                    when x"99" => S_tx_data_08_sig <= x"99";
--                    when x"9a" => S_tx_data_08_sig <= x"9a";
--                    when x"9b" => S_tx_data_08_sig <= x"9b";
--                    when x"9c" => S_tx_data_08_sig <= x"9c";
--                    when x"9d" => S_tx_data_08_sig <= x"9d";
--                    when x"9e" => S_tx_data_08_sig <= x"9e";
--                    when x"9f" => S_tx_data_08_sig <= x"9f";
--                    when x"a0" => S_tx_data_08_sig <= x"a0";
--                    when x"a1" => S_tx_data_08_sig <= x"a1";
--                    when x"a2" => S_tx_data_08_sig <= x"a2";
--                    when x"a3" => S_tx_data_08_sig <= x"a3";
--                    when x"a4" => S_tx_data_08_sig <= x"a4";
--                    when x"a5" => S_tx_data_08_sig <= x"a5";
--                    when x"a6" => S_tx_data_08_sig <= x"a6";
--                    when x"a7" => S_tx_data_08_sig <= x"a7";
--                    when x"a8" => S_tx_data_08_sig <= x"a8";
--                    when x"a9" => S_tx_data_08_sig <= x"a9";
--                    when x"aa" => S_tx_data_08_sig <= x"aa";
--                    when x"ab" => S_tx_data_08_sig <= x"ab";
--                    when x"ac" => S_tx_data_08_sig <= x"ac";
--                    when x"ad" => S_tx_data_08_sig <= x"ad";
--                    when x"ae" => S_tx_data_08_sig <= x"ae";
--                    when x"af" => S_tx_data_08_sig <= x"af";
--                    when x"b0" => S_tx_data_08_sig <= x"b0";
--                    when x"b1" => S_tx_data_08_sig <= x"b1";
--                    when x"b2" => S_tx_data_08_sig <= x"b2";
--                    when x"b3" => S_tx_data_08_sig <= x"b3";
--                    when x"b4" => S_tx_data_08_sig <= x"b4";
--                    when x"b5" => S_tx_data_08_sig <= x"b5";
--                    when x"b6" => S_tx_data_08_sig <= x"b6";
--                    when x"b7" => S_tx_data_08_sig <= x"b7";
--                    when x"b8" => S_tx_data_08_sig <= x"b8";
--                    when x"b9" => S_tx_data_08_sig <= x"b9";
--                    when x"ba" => S_tx_data_08_sig <= x"ba";
--                    when x"bb" => S_tx_data_08_sig <= x"bb";
--                    when x"bc" => S_tx_data_08_sig <= x"bc";
--                    when x"bd" => S_tx_data_08_sig <= x"bd";
--                    when x"be" => S_tx_data_08_sig <= x"be";
--                    when x"bf" => S_tx_data_08_sig <= x"bf";
--                    when x"c0" => S_tx_data_08_sig <= x"c0";
--                    when x"c1" => S_tx_data_08_sig <= x"c1";
--                    when x"c2" => S_tx_data_08_sig <= x"c2";
--                    when x"c3" => S_tx_data_08_sig <= x"c3";
--                    when x"c4" => S_tx_data_08_sig <= x"c4";
--                    when x"c5" => S_tx_data_08_sig <= x"c5";
--                    when x"c6" => S_tx_data_08_sig <= x"c6";
--                    when x"c7" => S_tx_data_08_sig <= x"c7";
--					             S_case_counter_sig<=(others=> '0');
					when others =>S_tx_data_08_sig<= x"AA" ;
			end case;
        ELSE ---not (s_delay_cnt > 46 and s_delay_cnt<=55 AND S_case_counter_sig < X"1b")
        IF S_case_counter_sig<X"16" THEN
            S_tx_data_08_sig<= x"F1";-- 1 IS WRITE 2 READ
        ELSE
             S_tx_data_08_sig<= x"F1";-- 1 IS WRITE 2 READ
        END IF;
        END IF;
END IF;
end process;

WR_TO_TEST_ERROR <= (others => '0');


  -- !debug: 19/02/2023
  regs2tx_pr: process is
    variable shedule_time_v : time;
  	variable test_reg_addr_v: std_logic_vector(23 downto 0);
	variable test_reg_data_v: std_logic_vector(31 downto 0);
	variable test_reg_cmd_v	: std_logic_vector(15 downto 0);
    variable packet_nocrc_v : std_logic_vector(9*8-1 downto 0);
  begin  -- process regs2tx_pr

    wait for 5 US;
    wait on S_clk_50MHz until (S_clk_50MHz = '1');
    wait for 200 PS;

    if (not DIAGNSOTIC_REGS) then

      prep_for_tx_l : for i in regs_operational_test_sig'range loop

        N_GO           <= '0';
        N_WR_EN        <= '0';
        N_SYNT_DATA_IN <= (others => '0');

        -- If special events, not WR/RD commands
        if (regs_operational_test_sig(i).cmd = "ST") then                                   -- all shedule pass
          wait;
        end if;

        -- Shedule, when send command
        shedule_time_v := regs_operational_test_sig(i).shedule_time;
        assert (now < shedule_time_v) report "Sheduler was not ready!!!" severity ERROR;
        wait for (shedule_time_v - now);

        wait on S_clk_50MHz until (S_clk_50MHz = '1');
        wait for 200 PS;

        if (regs_operational_test_sig(i).cmd = "WR") then
          test_reg_cmd_v := X"0001";                                            -- 2x bytes header
        elsif (regs_operational_test_sig(i).cmd = "RD") then
          test_reg_cmd_v := X"0002";
        elsif (regs_operational_test_sig(i).cmd = "OK") then
          next;
        end if;
        test_reg_data_v := regs_operational_test_sig(i).data;                               -- 4x bytes payload
        test_reg_addr_v := regs_operational_test_sig(i).footer;                             -- 3x bytes footer
        -- packet_nocrc_v := test_reg_addr_v & test_reg_data_v & test_reg_cmd_v; -- v1
        packet_nocrc_v  := test_reg_cmd_v & test_reg_data_v & test_reg_addr_v;  -- v2

        send_bytes_l : for n in 0 to 8 loop

          if (n = 8) then
            N_GO <= '1';
          else
            N_GO <= '0';
          end if;

          N_WR_EN        <= '1';

          -- N_SYNT_DATA_IN <= packet_nocrc_v(7 downto 0); -- v1: shr 8
          N_SYNT_DATA_IN <= packet_nocrc_v(9*8-1 downto 8*8);                   -- v2: shl 8

          wait on S_clk_50MHz until (S_clk_50MHz = '1');
          wait for 200 PS;

          -- packet_nocrc_v := X"00" & packet_nocrc_v(9*8-1 downto 8); -- v1: shr 8
          packet_nocrc_v := packet_nocrc_v(9*7 downto 0) & X"00";               -- v2: shl 8

        end loop;  -- send_bytes_l

        N_WR_EN <= '0';

      end loop;  -- prep_for_tx_l

    else

      prep_for_tx2_l : for i in regs_diag_test_sig'range loop

        N_GO           <= '0';
        N_WR_EN        <= '0';
        N_SYNT_DATA_IN <= (others => '0');

        -- If special events, not WR/RD commands
        if (regs_diag_test_sig(i).cmd = "ST") then                                   -- all shedule pass
          wait;
        end if;

        -- Shedule, when send command
        shedule_time_v := regs_diag_test_sig(i).shedule_time;
        assert (now < shedule_time_v) report "Sheduler was not ready!!!" severity ERROR;
        wait for (shedule_time_v - now);

        wait on S_clk_50MHz until (S_clk_50MHz = '1');
        wait for 200 PS;

        if (regs_diag_test_sig(i).cmd = "WR") then
          test_reg_cmd_v := X"0001";                                            -- 2x bytes header
        elsif (regs_diag_test_sig(i).cmd = "RD") then
          test_reg_cmd_v := X"0002";
        elsif (regs_diag_test_sig(i).cmd = "OK") then
          next;
        end if;
        test_reg_data_v := regs_diag_test_sig(i).data;                               -- 4x bytes payload
        test_reg_addr_v := regs_diag_test_sig(i).footer;                             -- 3x bytes footer
        -- packet_nocrc_v := test_reg_addr_v & test_reg_data_v & test_reg_cmd_v; -- v1
        packet_nocrc_v  := test_reg_cmd_v & test_reg_data_v & test_reg_addr_v;  -- v2

        send_bytes2_l : for n in 0 to 8 loop

          if (n = 8) then
            N_GO <= '1';
          else
            N_GO <= '0';
          end if;

          N_WR_EN        <= '1';

          -- N_SYNT_DATA_IN <= packet_nocrc_v(7 downto 0); -- v1: shr 8
          N_SYNT_DATA_IN <= packet_nocrc_v(9*8-1 downto 8*8);                   -- v2: shl 8

          wait on S_clk_50MHz until (S_clk_50MHz = '1');
          wait for 200 PS;

          -- packet_nocrc_v := X"00" & packet_nocrc_v(9*8-1 downto 8); -- v1: shr 8
          packet_nocrc_v := packet_nocrc_v(9*7 downto 0) & X"00";               -- v2: shl 8

        end loop;  -- send_bytes2_l

        N_WR_EN <= '0';

      end loop;  -- prep_for_tx2_l

    end if;

  end process regs2tx_pr;


end RX_TX_TESTER_ARC;
