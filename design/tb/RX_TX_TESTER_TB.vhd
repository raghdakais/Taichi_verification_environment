
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RX_TX_TESTER_TB is
--  Port ( );
end RX_TX_TESTER_TB;

architecture RX_TX_TESTER_TB_ARC of RX_TX_TESTER_TB is
SIGNAL S_START_TEST  : STD_LOGIC ;
SIGNAL S_RST         : STD_LOGIC ;
SIGNAL S_RX_IN       : STD_LOGIC ;
SIGNAL S_TX_DATA_out : STD_LOGIC; 
SIGNAL S_CHANNEL_RDY : STD_LOGIC ;
SIGNAL S_CLKp_200MHz : STD_LOGIC ;
SIGNAL S_CLKn_200MHz : STD_LOGIC ;
--SIGNAL S_TX_OUT      : STD_LOGIC;
SIGNAL S_STATUS      : std_logic_vector (15 downto 0) ;

--BANK REDISTER OUTPUTS
SIGNAL S_MU_CTRL                    :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_ADD_CONST_OFST_TO_MU       :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_CONST_OFST_VAL_TO_MU       :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_ASIC_TST_CAL_CTRL_TEST     :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_TEST_ERROR                 :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_DIAGNSOTICS                :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_GLOBL_IP_COEF              :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_DIAGNSOTICS_TMP            :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_ASIC_DATA_ALIGNMENT        :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_MODULE_DATA_OUT_SELCTION   :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_BAD_PIX_HL                 :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_BAD_PIX_LL                 :STD_LOGIC_VECTOR (31 DOWNTO 0); 
SIGNAL S_BAD_PIX_PER_TILE           :STD_LOGIC_VECTOR (31 DOWNTO 0) ;
--INDICATION FOR BAD RECEIVED 
SIGNAL S_bad_packet_received        : STD_LOGIC;
SIGNAL S_crc_error                  : STD_LOGIC;
SIGNAL S_std_error                  : STD_LOGIC;

signal div4cnt : natural range 0 to 3 := 0;
signal sys_clk : std_logic;
signal S_locked : std_logic;

begin

RX_TX_TESTER: entity work.RX_TX_TESTER
Port MAP (
     START_TEST    =>   S_START_TEST    ,
     RST           =>   S_RST           ,
     RX_IN         =>   S_RX_IN         ,
     TX_DATA_out   =>   S_TX_DATA_out   ,
     CHANNEL_RDY   =>   S_CHANNEL_RDY   ,
     CLKp_200MHz   =>   S_CLKp_200MHz,
     CLKn_200MHz   =>   S_CLKn_200MHz,
     STATUS       =>   S_STATUS         ,
     --BANK REGISTER OUTPUTS:
     MU_CTRL                 => S_MU_CTRL                 ,
     ADD_CONST_OFST_TO_MU    => S_ADD_CONST_OFST_TO_MU    ,
     CONST_OFST_VAL_TO_MU    => S_CONST_OFST_VAL_TO_MU    ,
     ASIC_TST_CAL_CTRL_TEST  => S_ASIC_TST_CAL_CTRL_TEST  ,
     TEST_ERROR              => S_TEST_ERROR              ,
     DIAGNSOTICS             => S_DIAGNSOTICS             ,
     GLOBL_IP_COEF           => S_GLOBL_IP_COEF           ,
     DIAGNSOTICS_TMP         => S_DIAGNSOTICS_TMP         ,
     ASIC_DATA_ALIGNMENT     => S_ASIC_DATA_ALIGNMENT     ,
     MODULE_DATA_OUT_SELCTION=> S_MODULE_DATA_OUT_SELCTION,
     BAD_PIX_HL              => S_BAD_PIX_HL              ,
     BAD_PIX_LL              => S_BAD_PIX_LL              ,
     BAD_PIX_PER_TILE        => S_BAD_PIX_PER_TILE        ,
     --INDICATION FOR BAD RECEIVED 
     bad_packet_received     =>  S_bad_packet_received,
     crc_error               =>  S_crc_error          ,
     std_error               =>  S_std_error          
);
  
  
     
 S_RST<='1', '0' AFTER 0.3 us;   
 S_START_TEST<='0' , '1' AFTER 0.4 ns; 
 S_locked <= '0', '1' after 100 ns;     -- 27/12/2022
 
 MODULE_TX_RX: entity work.MODULE_TX_RX
Port MAP (
      S_clk_200MHz => S_CLKp_200MHz,
      S_clk_50MHz => sys_clk,
      S_locked => S_locked,
      -- CLKp_200MHz              => S_CLKp_200MHz,
      -- CLKn_200MHz              => S_CLKn_200MHz,
    RST            =>    S_RST         ,
    channel_RDY    =>    S_channel_RDY ,
    RX_IN          =>    S_TX_DATA_out,
                         
    TX_OUT         =>    S_RX_IN,
    STATUS         =>    S_STATUS   ,
          --BANK REGISTER OUTPUTS:
    MU_CTRL                 =>S_MU_CTRL                 , 
    ADD_CONST_OFST_TO_MU    =>S_ADD_CONST_OFST_TO_MU    , 
    CONST_OFST_VAL_TO_MU    =>S_CONST_OFST_VAL_TO_MU    , 
    ASIC_TST_CAL_CTRL_TEST  =>S_ASIC_TST_CAL_CTRL_TEST  , 
    TEST_ERROR              =>S_TEST_ERROR              , 
    DIAGNSOTICS             =>S_DIAGNSOTICS             , 
    GLOBL_IP_COEF           =>S_GLOBL_IP_COEF           , 
    DIAGNSOTICS_TMP         =>S_DIAGNSOTICS_TMP         , 
    ASIC_DATA_ALIGNMENT     =>S_ASIC_DATA_ALIGNMENT     , 
    MODULE_DATA_OUT_SELCTION=>S_MODULE_DATA_OUT_SELCTION, 
    BAD_PIX_HL              =>S_BAD_PIX_HL              , 
    BAD_PIX_LL              =>S_BAD_PIX_LL              , 
    BAD_PIX_PER_TILE        =>S_BAD_PIX_PER_TILE        ,     
    bad_packet_received     =>S_bad_packet_received                  ,--OUTPUT FAILURE INDICATION      
    crc_error               =>S_crc_error                            ,--OUTPUT FAILURE INDICATION      
    std_error               =>S_std_error                             --OUTPUT FAILURE INDICATION
    
    
    
);
     

-- !debug: 26/12/2022 ES
misc_pr: process (S_CLKp_200MHz) is
begin  -- process misc_pr
  if (S_CLKp_200MHz'event and S_CLKp_200MHz = '1') then  -- rising clock edge
    div4cnt <= (div4cnt + 1) mod 4;
    if (div4cnt > 1) then
      sys_clk <= '1';
    else
      sys_clk <= '0';
    end if;
  end if;
end process misc_pr;
 
 
 
 
 
 end RX_TX_TESTER_TB_ARC;
