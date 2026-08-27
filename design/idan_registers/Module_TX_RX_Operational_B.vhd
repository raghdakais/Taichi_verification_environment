----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/12/2022 10:12:23 AM
-- Design Name:
-- Module Name: Module_TX_RX_Operational_B
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created - Module_TX_RX
-- Revision 0.02 - modify to Module_TX_RX_Operational_B   18/7/2023
-- Additional Comments:
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;



entity Module_TX_RX_Operational_B is
GENERIC (DATA_ZISE : INTEGER:=8;
         G_DATA_LENGTH:INTEGER:=32 );
Port (
    S_clk_200MHz    : IN  STD_LOGIC;       -- !debug: 08/12/2022
    S_clk_50MHz     : IN  STD_LOGIC;       -- !debug: 08/12/2022
    S_locked        : IN  STD_LOGIC;       -- !debug: 08/12/2022
    RST                      : IN STD_LOGIC ;
    channel_RDY              : IN STD_LOGIC ;
    RX_IN                    : IN STD_LOGIC ;

    TX_OUT                  : OUT STD_LOGIC;
    STATUS                  : IN std_logic_vector (15 downto 0) ;
    --BANK REGISTER OUTPUTS:
    MU_CTRL                 :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ADD_CONST_OFST_TO_MU    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONST_OFST_VAL_TO_MU    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_TST_CAL_CTRL_TEST  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    TEST_ERROR              :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_TEST_ERROR        :IN  STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    DIAGNSOTICS             :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    GLOBL_IP_COEF           :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_DATA_ALIGNMENT     :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    MODULE_DATA_OUT_SELCTION:OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NOT_VALID_ADDR_OUT      :OUT STD_LOGIC;
    --RX_series7
    BAD_PACKET_RECEIVED     :OUT STD_LOGIC;
    RX_ERRs                 : OUT	std_logic_vector (3 downto 0);
    TX_ERRs                 : OUT	std_logic_vector (1 downto 0); ---add by Dalit 10/10/2023
    ams_asics_reset         :OUT STD_LOGIC;
	Power_en_mask			:OUT STD_LOGIC_VECTOR(1 downto 0);
	asic_rdwr_exe			:OUT STD_LOGIC;
	asic_rdwr_ops			:OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
	AMS_DATA2R				:in std_logic_vector (15 downto 0);
	asics_read_sel			:OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    skip_IP_packet          : in    std_logic;          -- 09/03/2026 0x63A0 [8]
    skip_scan_header_packet : in    std_logic;          -- 09/03/2026 0x63A0 [9]
    sel_dbg1                :in std_logic -- 25/06/2024
);
end Module_TX_RX_Operational_B;

architecture Module_TX_RX_ARC of Module_TX_RX_Operational_B is

SIGNAL S_EN : STD_LOGIC;
CONSTANT C_HEADER_LENGTH : INTEGER      := 16;
SIGNAL S_HEADER          : STD_LOGIC;--:STD_LOGIC_VECTOR (C_HEADER_LENGTH-1 DOWNTO 0);
CONSTANT C_PAYLOAD_LENGTH: INTEGER     := 32;
SIGNAL S_PAYLOAD          : STD_LOGIC;--:STD_LOGIC_VECTOR (C_PAYLOAD_LENGTH-1 DOWNTO 0);
CONSTANT C_FOOTER_LENGTH: INTEGER      := 24;
SIGNAL S_FOOTER         : STD_LOGIC;--:STD_LOGIC_VECTOR (C_FOOTER_LENGTH-1 DOWNTO 0);
SIGNAL S_CRC_OK         :STD_LOGIC; --Active @ '1'
SIGNAL S_ALIGNED        :STD_LOGIC; -- Active @ '1'

CONSTANT C_DEC_DATA_LENGTH  : INTEGER    := 8;
SIGNAL S_DEC_DATA           :STD_LOGIC_VECTOR (C_DEC_DATA_LENGTH-1 DOWNTO 0);
CONSTANT C_ENC_DATA_LENGTH  : INTEGER    := 8;
SIGNAL S_ENC_DATA           :STD_LOGIC_VECTOR (C_ENC_DATA_LENGTH-1 DOWNTO 0);

-- SIGNAL S_CLK_200MHz:STD_LOGIC:='0';
SIGNAL S_RD_EMPTY       :STD_LOGIC:='0';
SIGNAL S_TX_RD_CLK      :STD_LOGIC:='0';
SIGNAL S_RD_REQ         :STD_LOGIC:='0';
SIGNAL S_GO             :STD_LOGIC:='0';
SIGNAL S_WR_EN          :STD_LOGIC:='0';
SIGNAL S_TX_IN          :std_logic_vector (DATA_ZISE-1 downto 0);
SIGNAL S_STATn_DYN      :STD_LOGIC:='0';

SIGNAL S_STATUS             :std_logic_vector (15 downto 0);
--SIGNAL S_WR_TO_TEST_ERROR   :STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);

------------TX_series7----
COMPONENT TX_series7
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
	 DATA_IN           : IN     std_logic_vector (7 downto 0);
	 RD_EMPTY          : IN     std_logic;
	 RD_CLK   	       : OUT    std_logic;
	 RD_REQ            : OUT    std_logic;
	 DATA_out          : OUT	std_logic;
	 TX_ERRs           : OUT	std_logic_vector (1 downto 0) --TX_ERR(0) '1'  if empty when RD_REQ  ,RX_ERR(1) '1' if fifo not empty after packet transaction

   );

END COMPONENT ;




------------RX_series7----
 COMPONENT RX_series7 IS
    Generic (
      IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
	  StartWord      : std_logic_vector (7 downto 0):=x"21";
	  Stream_type1   : std_logic_vector (7 downto 0):=x"43";
	  Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
	  TapWidth       : natural :=5;
	  ParallelWidth  : natural :=8;
      NumHeaderBytes : natural :=2;
	  NumDataBytes   : natural :=4;
	  NumFooterBytes : natural :=3

	  );
    PORT(
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		FCLK      		        : in    std_logic;   --serial clock input side
		channel_RDY   	        : in    std_logic;
		sDataIn                 : in    std_logic;
		IDLY_CNT  		        : out   std_logic_vector(TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count
                skip_IP_packet          : in    std_logic;          -- 09/03/2026 0x63A0 [8]
                skip_scan_header_packet : in    std_logic;          -- 09/03/2026 0x63A0 [9]
		RX_det_o       	        : OUT   std_logic_vector (7 downto 0);
		start_valid             : OUT   std_logic;
		Headers_valid           : OUT   std_logic;
		data_valid              : OUT   std_logic;
		Footers_valid           : OUT   std_logic;
		IP_pckt_valid           : OUT   std_logic;
		packet_received         : OUT   std_logic;
		good_packet_received    : OUT   std_logic;
		bad_packet_received     : OUT   std_logic;
                RX_ERRs                 : OUT	std_logic_vector (3 downto 0)
    	);
    	END COMPONENT;

SIGNAL S_IDLY_CNT  		            :STD_LOGIC_VECTOR(4 DOWNTO 0):=(OTHERS=>'0');  --TapWidth=5
SIGNAL S_RX_det_o       	        : std_logic_vector (DATA_ZISE-1 downto 0);
SIGNAL S_start_valid                :STD_LOGIC:='0';
SIGNAL S_Headers_valid              :STD_LOGIC:='0';
SIGNAL S_data_valid                 :STD_LOGIC:='0';
SIGNAL S_Footers_valid              :STD_LOGIC:='0';
SIGNAL S_IP_pckt_valid              :STD_LOGIC:='0';
SIGNAL S_packet_received            :STD_LOGIC:='0';
--SIGNAL S_good_packet_received       :STD_LOGIC:='0';
SIGNAL S_bad_packet_received        :STD_LOGIC:='0';
-- SIGNAL S_crc_error                  :STD_LOGIC:='0';
-- SIGNAL S_std_error                  :STD_LOGIC:='0';

SIGNAL S_EXE : STD_LOGIC;
CONSTANT  C_CMD_LENGTH: INTEGER     := 16;
SIGNAL S_CMD : STD_LOGIC_VECTOR (C_CMD_LENGTH-1 DOWNTO 0);
SIGNAL S_SEND : STD_LOGIC;
SIGNAL S_WRITE : STD_LOGIC;
SIGNAL S_READ : STD_LOGIC;

CONSTANT  C_STATUS_LENGTH: INTEGER    := 16;
CONSTANT  C_ADDR_LENGTH: INTEGER     := 24;
SIGNAL    S_ADDR : STD_LOGIC_VECTOR (C_ADDR_LENGTH-1 DOWNTO 0);
CONSTANT  C_DATA_LENGTH: INTEGER     := 32;
SIGNAL    S_REG_BANK_DATA_OUT: STD_LOGIC_VECTOR (C_DATA_LENGTH-1 DOWNTO 0);
SIGNAL    S_DEC_DATA_OUT: STD_LOGIC_VECTOR (C_DATA_LENGTH-1 DOWNTO 0);

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

   SIGNAL S_TX_FIFO_din  :STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL S_TX_FIFO_dout :  STD_LOGIC_VECTOR(7 DOWNTO 0);
   SIGNAL S_TX_FIFO_full :  STD_LOGIC;
   SIGNAL S_TX_FIFO_empty :  STD_LOGIC;
   SIGNAL S_TX_FIFO_wr_rst_busy :  STD_LOGIC;
   SIGNAL S_TX_FIFO_rd_rst_busy :  STD_LOGIC;
----------------------
SIGNAL S_NOT_VALID_ADDR : STD_LOGIC;

-------clk_wiz_1-----------
--component clk_wiz_1
--port
-- (-- Clock in ports
--  -- Clock out ports
--  clk_200MHz        : out    std_logic;
--  clk_50MHz         : out    std_logic;
--  -- Status and control signals
--  reset             : in     std_logic;
--  locked            : out    std_logic;
--  clk_in1_p         : in     std_logic;
--  clk_in1_n         : in     std_logic
-- );
--end component;

-- SIGNAL S_clk_50MHz         :     std_logic;
-- SIGNAL S_locked            :     std_logic;

-- !debug: 18/12/2022
 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of S_packet_received, S_IDLY_CNT, S_GO, S_TX_FIFO_dout, S_RD_REQ : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of S_packet_received, S_IDLY_CNT, S_GO, S_TX_FIFO_dout, S_RD_REQ : signal is "true";


BEGIN
----------------------------------------------------
-- clk_wiz_200MHz_50MHz : clk_wiz_1
--    port map (
--   -- Clock out ports
--    clk_200MHz => S_clk_200MHz,
--    clk_50MHz =>  S_clk_50MHz,--50MHz
--   -- Status and control signals
--    reset => RST,
--    locked => S_locked,
--    -- Clock in ports
--    clk_in1_p => CLKp_200MHz,
--    clk_in1_n => CLKn_200MHz
--  );

---------------------------------------------------

NOT_VALID_ADDR_OUT<=S_NOT_VALID_ADDR;


TX_FIFO_INS : TX_FIFO
  PORT MAP (
    rst => "not"(S_locked),
    wr_clk => S_clk_50MHz,--50MHz
    rd_clk => S_TX_RD_CLK,--200MHZz
    din => S_TX_FIFO_din,
    wr_en => S_WR_EN,
    rd_en => S_RD_REQ,--S_TX_FIFO_rd_en,
    dout => S_TX_FIFO_dout,
    full => S_TX_FIFO_full,
    empty => S_TX_FIFO_empty

  );

-----------------------------------------------

REGISTER_ENCODER :  entity work.REGISTER_ENCODER
GENERIC MAP (
         G_STATUS_LENGTH=> 16,
         G_ADDR_LENGTH  => 24,
         G_DATA_LENGTH  => 32,
         G_DATA_OUT_LENGTH=> 8
)
Port MAP(

    CLK      =>S_clk_50MHz,
    RST      =>RST, --Active @ '1'
    STATUS   =>STATUS ,
    DATA_IN  => S_REG_BANK_DATA_OUT, -- !debug: 26/12/2022  only for debug

    ADDR_IN  => S_ADDR, -- !debug: 26/12/2022  only for debug
    SEND     => S_SEND, -- Active @ '1' -- !debug: 26/12/2022  only for debug
    DATA_OUT  =>S_TX_FIFO_din,

    GO        => S_GO ,
    WR_EN     =>S_WR_EN

);

-------------------------------------
REGISTER_DECODER: entity work.REGISTER_DECODER
GENERIC MAP(
         G_HEADER_LENGTH    => 16,
         G_PAYLOAD_LENGTH   => 32,
         G_FOOTER_LENGTH    => 24,
         G_CRC_LENGTH       => 8 ,
         G_DATA_IN_LENGTH   => 8 ,
         G_CMD_LENGTH       => 16,
         G_ADDR_LENGTH      => 24,
         G_DATA_OUT_LENGTH  => 32
)
PORT MAP(
    CLK      => S_clk_50MHz        ,
    RST      => RST        ,  --Active @ '1'
    EN       => S_EN         , --Active @ '1'
    HEADER   => S_HEADER     ,
    PAYLOAD  => S_PAYLOAD    ,
    FOOTER   => S_FOOTER     ,
    CRC_OK   => S_CRC_OK     ,--Active @ '1'
    ALIGNED  => S_ALIGNED    , -- Active @ '1'
    DATA_nBIT=> S_RX_det_o  ,

    EXE       => S_EXE     ,--Active @ '1'
    CMD       => S_CMD     ,--Active @ '1'
    DATA_OUT  => S_DEC_DATA_OUT    ,
    ADDR_OUT  => S_ADDR

);
-------------------------------------
REGISTER_CTRL: ENTITY WORK.REGISTER_CTRL
    GENERIC MAP(
               G_CMD_LENGTH => 16
               )
     PORT MAP(
          CLK =>S_clk_50MHz    ,
          RST =>RST    ,
          EXE =>S_EXE  ,
          CMD =>S_CMD  ,

          WRITE =>S_WRITE  , -- active :'1'
          READ=>S_READ,
          SEND =>S_SEND -- active :'1'
          );

-------------------------------------


REGISTER_BANK_B: entity WORK.REGISTER_BANK_B
GENERIC MAP(
         G_Module_ADDR_LENGTH=>16,
         G_DATA_LENGTH=>32
         )

Port MAP(
    CLK         =>S_clk_50MHz      ,
    RST         =>RST      ,
    WRITE       =>S_WRITE    ,
    READ        =>S_READ,
    ADDR        =>S_ADDR(15 downto 0)   ,
    DATA_IN     =>S_DEC_DATA_OUT,
    REG_ADDR_NOT_VALID   =>S_NOT_VALID_ADDR,-- OPEN, --NOT_VALID_ADDR_OUT,      --VALID AT '0';
    DATA_OUT    => S_REG_BANK_DATA_OUT  ,

    --WRITE ONLY FROM MODULE

    --OUTPUTS FROM REGISTER BANK
    MU_CTRL                      =>MU_CTRL                  ,
    ADD_CONST_OFST_TO_MU         =>ADD_CONST_OFST_TO_MU     ,
    CONST_OFST_VAL_TO_MU         =>CONST_OFST_VAL_TO_MU     ,
    ASIC_TST_CAL_CTRL_TEST       =>ASIC_TST_CAL_CTRL_TEST   ,
    TEST_ERROR                   =>TEST_ERROR               ,
    WR_TO_TEST_ERROR             => WR_TO_TEST_ERROR        ,
    DIAGNSOTICS                  => DIAGNSOTICS             ,
    GLOBL_IP_COEF                =>GLOBL_IP_COEF            ,
  --  DIAGNSOTICS_TMP              =>DIAGNSOTICS_TMP          ,
    ASIC_DATA_ALIGNMENT          =>ASIC_DATA_ALIGNMENT      ,
    MODULE_DATA_OUT_SELCTION     =>MODULE_DATA_OUT_SELCTION ,
    -- BAD_PIX_HL                   =>BAD_PIX_HL               ,
    -- BAD_PIX_LL                   =>BAD_PIX_LL               ,
    -- BAD_PIX_PER_TILE             =>BAD_PIX_PER_TILE         ,
    -- CONTROL_REGISTER_LSB                                   =>CONTROL_REGISTER_LSB                                ,
  --  CONTROL_REGISTER_MSB                                   =>CONTROL_REGISTER_MSB                                ,
    -- FIFO_RESET                                             =>FIFO_RESET                                          ,
    -- CONFIGURATION_STATUS                                   =>CONFIGURATION_STATUS                                ,
    -- WR_TO_CONFIGURATION_STATUS                             =>WR_TO_CONFIGURATION_STATUS                          ,
    -- CONFIGURATION_FIFO_RD_CNT                              =>CONFIGURATION_FIFO_RD_CNT                           ,
    -- WR_TO_CONFIGURATION_FIFO_RD_CNT                        =>WR_TO_CONFIGURATION_FIFO_RD_CNT                     ,
    -- REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER            =>REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER         ,
    -- CONFIG_WR_EN                                           =>CONFIG_WR_EN                                        ,
    -- REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER         =>REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER      ,
    -- WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER   =>WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER,
   -- TEST                                                   =>TEST                                                ,
   -- WR_TO_TEST                                             =>WR_TO_TEST,
    -- 21/03/2023
    -- Tile1_Temperature => Tile1_Temperature,
    -- Tile2_Temperature => Tile2_Temperature,
    -- Tile3_Temperature => Tile3_Temperature,
    -- Tile4_Temperature => Tile4_Temperature,
    -- Module_Inlet_Temperature => Module_Inlet_Temperature,
    -- Module_Outlet_Temperature => Module_Outlet_Temperature,
    -- Module_Average_Temperature => Module_Average_Temperature,
    -- kP_reg => kP_reg,
    -- kI_reg => kI_reg,
    -- kD_reg => kD_reg,
    -- kAW_reg => kAW_reg,
    -- Heater_Control => Heater_Control,
    -- SetPoint => SetPoint,
    -- Temperature_Weighted_Average_CFG => Temperature_Weighted_Average_CFG,
    -- PID_Stable_Tolerance => PID_Stable_Tolerance,
    -- Temperature_Sample_and_rates => Temperature_Sample_and_rates,
    -- Integral_and_Derivative_rates => Integral_and_Derivative_rates,
    -- Status_and_Errors => Status_and_Errors,
    -- PWM_Duty_Cycle_IN => PWM_Duty_Cycle_IN,
    -- temporary_reg1 => temporary_reg1,
    -- temporary_reg2 => temporary_reg2,
    ams_asics_reset => ams_asics_reset,
    Power_en_mask => Power_en_mask,
    asic_rdwr_exe => asic_rdwr_exe,
    asic_rdwr_ops => asic_rdwr_ops,
    AMS_DATA2R => AMS_DATA2R,
    asics_read_sel => asics_read_sel,
    sel_dbg1 => sel_dbg1               -- 25/06/2024
    -- timestamp => timestamp,
    -- fw_ver => fw_ver,                   -- 23/04/2023
    -- board_ver => board_ver,
    -- Num_of_Slices => Num_of_Slices
);







TX_series7_COMPONENT:  entity work.TX_series7
   GENERIC MAP ( IDLE_WORD  =>x"B5",
			 StartWord      =>x"21",
			 Stream_type1   =>x"43",
			 Stream_type2   =>x"DD",
			 NumHeaderbytes =>x"02",
             NumDatabytes   =>x"00000004",
			 NumFooterbytes =>x"03"

)
   PORT MAP(
	 RESET    =>"not"(S_locked),--active @ '1'
     CLKDIV   =>S_clk_50MHz,--DATA 8 bits' clk of 50Mbps (400M/8= 50Mbps)
	 FCLK	  =>S_clk_200MHz,--Serial clk of 400mbps
	 STATn_DYN=>'0',-- Static or dynamic ('0' for Static, '1' for dynamic)
	 GO       =>S_GO,
	 IP       =>'0',
	 PayloadSize=>(others=>'0'),--used only in dynamic option
	 DATA_IN  =>S_TX_FIFO_dout,--8 BITS at 50MHZ
	 RD_EMPTY =>S_TX_FIFO_empty,
	 RD_CLK   =>S_TX_RD_CLK  ,
	 RD_REQ   =>S_RD_REQ  ,
	 DATA_out =>TX_OUT,--1 BITS at 400Mbps
     TX_ERRs => TX_ERRs  --add by Dalit 10/10/2023
   );


RX_series_COMPONENT:  entity work.RX_series7
    GENERIC MAP (
      IDLE_word     =>x"B5",
	  StartWord     =>x"21",
	  Stream_type1  =>x"43",
	  Stream_type2  =>x"DD",
	  TapWidth       =>5,
	  ParallelWidth  =>8,
      NumHeaderBytes =>2,
	  NumDataBytes   =>4,
	  NumFooterBytes =>3

	  )
    PORT MAP(
        --INPUTS
        RESET       	=>"not"(S_locked),
        CLKDIV          =>S_CLK_50MHz,	        --DATA 8 bits' clk of 50Mbps (400M/8= 50MHz)
		FCLK      		=>S_CLK_200MHz,         --serial clock input side 400Mpbs (8*50)
		channel_RDY   	=>channel_RDY,          --Used to initiate the locking sequence of the receiver on the serial line.
		                                          --As long as Channel_RDY is '0' the Receiver is in the IDLE state, once Channel_RDY asserted the receiver is trying to lock on the serial line Data when Channel_RDY is asserted the Idle word (i.e. x"B5") shall be transmitted on serial line for proper lock.
		sDataIn         =>RX_IN,             	  --SERIAL DATA, 400Mbps, 200MHz
		--OUTPUTS
		IDLY_CNT  		           =>S_IDLY_CNT  		   		          ,--Current delay that is load in Idelay primitive it can be used for R&D purposes but can be left open
        skip_IP_packet => skip_IP_packet,                   -- 09/03/2026
        skip_scan_header_packet => skip_scan_header_packet, -- 09/03/2026
                ERR_INJ => '0',                                     -- 03/03/2026
		RX_det_o       	       	   =>S_RX_det_o      	                 ,--8 BITS DATA, 50Mbps
		start_valid                =>S_EN                                ,--Signals can be used as write request for FIFO.
		Headers_valid              =>S_HEADER                            ,--Signals can be used as write request for FIFO.
		data_valid                 =>S_PAYLOAD                           ,--Signals can be used as write request for FIFO.
		Footers_valid              =>S_FOOTER                             ,--Signals can be used as write request for FIFO.
		IP_pckt_valid              =>S_IP_pckt_valid                      ,--Signals can be used as write request for FIFO.
		packet_received            =>S_packet_received                    ,--Indicate packet arrival it is accompanied by either bad/good_packet received signal those can be used for either assure the packet or disqualifying it (for example by reset the FIFO the packet was being written to.
		good_packet_received       =>S_ALIGNED                            ,
		bad_packet_received        =>bad_packet_received                  ,--OUTPUT FAILURE INDICATION
    RX_ERRs => RX_ERRs
    	);


end Module_TX_RX_ARC;
