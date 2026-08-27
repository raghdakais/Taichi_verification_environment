
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RX_TX_TESTER_VER01_TB is
--  Port ( );
end RX_TX_TESTER_VER01_TB;

architecture RX_TX_TESTER_VER01_TB_ARC of RX_TX_TESTER_VER01_TB is
SIGNAL S_START_TEST  : STD_LOGIC ;
SIGNAL S_RST         : STD_LOGIC ;
----                                           
SIGNAL S_RX_IN       : STD_LOGIC ;
SIGNAL S_TX_OUT      : STD_LOGIC ;
                                              
SIGNAL S_TX_DATA_out : STD_LOGIC;                                               
SIGNAL S_CHANNEL_RDY : STD_LOGIC ;                                              
SIGNAL S_CLKDIV_50MHz      :  STD_LOGIC ;--50MHZ--CLKp_200MHz : IN STD_LOGIC;     
SIGNAL S_FCLK_200MHz       :  STD_LOGIC ;--200MHz--CLKn_200MHz : IN STD_LOGIC;    
SIGNAL S_STATUS            :  STD_LOGIC_VECTOR(15 DOWNTO 0);                     
--BANK REGISTER OUTPUTS:                                               
SIGNAL S_MU_CTRL                 : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_ADD_CONST_OFST_TO_MU    : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_CONST_OFST_VAL_TO_MU    : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_ASIC_TST_CAL_CTRL_TEST  : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_TEST_ERROR              : STD_LOGIC_VECTOR (31 DOWNTO 0);
SIGNAL S_WR_TO_TEST_ERROR        : STD_LOGIC_VECTOR (31 DOWNTO 0);  
SIGNAL S_DIAGNSOTICS             : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_GLOBL_IP_COEF           : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_DIAGNSOTICS_TMP         : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_ASIC_DATA_ALIGNMENT     : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_MODULE_DATA_OUT_SELCTION: STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_BAD_PIX_HL              : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_BAD_PIX_LL              : STD_LOGIC_VECTOR (31 DOWNTO 0);   
SIGNAL S_BAD_PIX_PER_TILE        : STD_LOGIC_VECTOR (31 DOWNTO 0);   
--INDICATION FOR BAD RECEIVED                                              
SIGNAL S_BAD_PACKET_RECEIVED     : STD_LOGIC;                                     
SIGNAL S_CRC_ERROR               : STD_LOGIC;                                     
SIGNAL S_STD_ERROR               : STD_LOGIC;                                     
SIGNAL S_OUT_CLKDIV_50MHz        : STD_LOGIC ;--50MHZ--CLKp_200MHz : IN STD_LOGIC;
SIGNAL S_OUT_FCLK_200MHz         : STD_LOGIC;--200MHz--CLKn_200MHz : IN STD_LOGIC;
SIGNAL S_PLL_locked             :   STD_LOGIC;
--


SIGNAL S_data_to_uut               : STD_LOGIC; 
SIGNAL S_data_from_uut             : STD_LOGIC; 
SIGNAL S_NOT_VALID_ADDR            : STD_LOGIC; 
--SIGNAL S_locked : STD_LOGIC; 


---clk_wiz_1-----------
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


--SIGNAL S_clk_50MHz         :     std_logic;
--SIGNAL S_clk_200MHz         :     std_logic;
SIGNAL S_CLKp_200MHz         :     std_logic;
SIGNAL S_CLKn_200MHz         :     std_logic;

-- !debug: 20/02/2023

  -- Flash remote update
  component access_config_top is
    port(
      clk             : in  std_logic;
      config_ctl_reg  : in  std_logic_vector (31 downto 0);
      din             : in  std_logic_vector (63 downto 0);
      reset           : in  std_logic;
      reset_fifo      : in  std_logic;
      so              : in  std_logic;
      wr_en           : in  std_logic;
      CS              : out std_logic;
      SCK             : out std_logic;
      busy            : out std_logic;
      conf_status_reg : out std_logic_vector (15 downto 0);
      data_out        : out std_logic_vector (63 downto 0);
      rd_data_count   : out std_logic_vector(6 downto 0);
      si              : out std_logic
      );
  end component;

  signal config_ctl_reg : std_logic_vector(31 downto 0) := (others => '0'); -- !TODO: 01/02/2023 connect to register
  signal reset_fifo_reg : std_logic := '0'; -- !TODO: 01/02/2023 connect to register
  signal conf_status_reg : std_logic_vector(15 downto 0);
  signal conf_fifo_rd_cnt_reg : std_logic_vector(15 downto 0);

  signal FIFO_RESET : std_logic_vector (31 downto 0);
  signal config_wr_en : std_logic := '0';
  signal config_data_in  : std_logic_vector (31 downto 0) := (others => '0');
  signal config_data_out : std_logic_vector (63 downto 0); -- data_out
  signal rd_data_count   : std_logic_vector (6 downto 0);

  signal CONTROL_REGISTER_LSB        : std_logic_vector (31 downto 0);
  signal CONTROL_REGISTER_MSB        : std_logic_vector (31 downto 0);

begin
----------------------------------------------------
--clk_wiz_200MHz_50MHz : clk_wiz_1
--   port map ( 
--  -- Clock out ports  
--   clk_200MHz => S_clk_200MHz,--200
--   clk_50MHz =>  S_clk_50MHz,--50MHz
--  -- Status and control signals                
--   reset => S_RST,
--   locked => S_locked,
--   -- Clock in ports
--   clk_in1_p => S_CLKp_200MHz,
--   clk_in1_n => S_CLKn_200MHz
-- );

clk200MHz_proc: PROCESS
             
   BEGIN 
    S_CLKp_200MHz <= '1';
    S_CLKn_200MHz <= '0';
    wait for 2.5 ns;
    S_CLKp_200MHz <= '0';
    S_CLKn_200MHz <= '1';
    wait for 2.5 ns;
end process;


 S_RST<='1', '0' AFTER 0.3 us;   
 S_START_TEST<='0' , '1' AFTER 100 us; 

RX_TX_TESTER: entity work.RX_TX_TESTER
GENERIC MAP(
         G_DATA_LENGTH => 32 )
Port MAP ( 
    START_TEST                        =>  S_START_TEST                         ,
    RST                               =>  S_RST                                ,
    RX_IN                             =>  S_data_from_uut                      ,
    clk_inPLL_p                       =>    S_CLKp_200MHz,
    clk_inPLL_n                       =>   S_CLKn_200MHz ,
    
    TX_DATA_out                       =>  S_data_to_uut                        ,
    CHANNEL_RDY                       =>  S_CHANNEL_RDY                        ,
--    CLKDIV_50MHz                      =>  S_CLKDIV_50MHz                       ,
--    FCLK_200MHz                       =>  S_FCLK_200MHz                        ,
    STATUS                            =>  S_STATUS                             ,
        --BANK REGISTER OUTPUTS:      =>      --BANK REGISTER OUTPUTS:         
    MU_CTRL                           =>  S_MU_CTRL                            ,
    ADD_CONST_OFST_TO_MU              =>  S_ADD_CONST_OFST_TO_MU               ,
    CONST_OFST_VAL_TO_MU              =>  S_CONST_OFST_VAL_TO_MU               ,
    ASIC_TST_CAL_CTRL_TEST            =>  S_ASIC_TST_CAL_CTRL_TEST             ,
    TEST_ERROR                        =>  S_TEST_ERROR                         ,
    WR_TO_TEST_ERROR                  => S_WR_TO_TEST_ERROR                     ,
    DIAGNSOTICS                       =>  S_DIAGNSOTICS                        ,
    GLOBL_IP_COEF                     =>  S_GLOBL_IP_COEF                      ,
    DIAGNSOTICS_TMP                   =>  S_DIAGNSOTICS_TMP                    ,
    ASIC_DATA_ALIGNMENT               =>  S_ASIC_DATA_ALIGNMENT                ,
    MODULE_DATA_OUT_SELCTION          =>  S_MODULE_DATA_OUT_SELCTION           ,
    BAD_PIX_HL                        =>  S_BAD_PIX_HL                         ,
    BAD_PIX_LL                        =>  S_BAD_PIX_LL                         ,
    BAD_PIX_PER_TILE                  =>  S_BAD_PIX_PER_TILE                   ,
    -- NOT_VALID_ADDR                    =>  S_NOT_VALID_ADDR                     ,
    --INDICATION FOR BAD RECEIVED     =>  --INDICATION FOR BAD RECEIVED        
    BAD_PACKET_RECEIVED               =>  S_BAD_PACKET_RECEIVED                ,
    CRC_ERROR                         =>  S_CRC_ERROR                          ,
    STD_ERROR                         =>  S_STD_ERROR                          ,
    OUT_CLKDIV_50MHz                  =>  S_OUT_CLKDIV_50MHz                   ,
    OUT_FCLK_200MHz                   =>  S_OUT_FCLK_200MHz                    ,
    PLL_locked                        =>S_PLL_locked
    );

  

 
 MODULE_TX_RX: entity work.MODULE_TX_RX

GENERIC map (DATA_ZISE =>8,
         G_DATA_LENGTH=>32 )
Port MAP( 
    S_clk_200MHz            =>S_OUT_fclk_200MHz ,    
    S_clk_50MHz             =>S_OUT_CLKDIV_50MHz  ,    
    S_locked                =>S_PLL_locked     ,     
--    CLKp_200MHz              : IN  STD_LOGIC;
--    CLKn_200MHz              : IN  STD_LOGIC;
    RST                      => S_RST          ,
    channel_RDY              => S_channel_RDY  ,
    RX_IN                    => S_data_to_uut        ,                   
    TX_OUT                   => S_data_from_uut       ,
    STATUS                   => S_STATUS       ,
    --BANK REGISTER OUTPUTS:
    MU_CTRL                 =>S_MU_CTRL                 ,
    ADD_CONST_OFST_TO_MU    =>S_ADD_CONST_OFST_TO_MU    ,
    CONST_OFST_VAL_TO_MU    =>S_CONST_OFST_VAL_TO_MU    ,
    ASIC_TST_CAL_CTRL_TEST  =>S_ASIC_TST_CAL_CTRL_TEST  ,
    TEST_ERROR              =>S_TEST_ERROR              ,   
    WR_TO_TEST_ERROR        =>S_WR_TO_TEST_ERROR         ,
    DIAGNSOTICS             =>S_DIAGNSOTICS             ,
    GLOBL_IP_COEF           =>S_GLOBL_IP_COEF           ,
    DIAGNSOTICS_TMP         =>S_DIAGNSOTICS_TMP         ,
    ASIC_DATA_ALIGNMENT     =>S_ASIC_DATA_ALIGNMENT     ,
    MODULE_DATA_OUT_SELCTION=>S_MODULE_DATA_OUT_SELCTION,
    BAD_PIX_HL              =>S_BAD_PIX_HL              ,
    BAD_PIX_LL              =>S_BAD_PIX_LL              ,
    BAD_PIX_PER_TILE        =>S_BAD_PIX_PER_TILE        ,
    CREG                    => open, 
    PCREG                   => open,    
    CONTROL_REGISTER_LSB    => CONTROL_REGISTER_LSB,
    CONTROL_REGISTER_MSB    => CONTROL_REGISTER_MSB,
    FIFO_RESET              => FIFO_RESET, 
    CONFIGURATION_STATUS    => open, 
    WR_TO_CONFIGURATION_STATUS(15 downto 0) => conf_status_reg,
    WR_TO_CONFIGURATION_STATUS(31 downto 16) => (others => '0'),
    CONFIGURATION_FIFO_RD_CNT  => open, 
    WR_TO_CONFIGURATION_FIFO_RD_CNT(15 downto 0) => conf_fifo_rd_cnt_reg,
    WR_TO_CONFIGURATION_FIFO_RD_CNT(31 downto 16) => (others => '0'),
    REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER  => config_data_in,
    CONFIG_WR_EN   => config_wr_en,                                   
    REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER   => config_data_out(31 downto 0),
    WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER => config_data_out(31 downto 0),
    TEST                                                 => open, 
    WR_TO_TEST                                           => (others => '0'),
    NOT_VALID_ADDR_out          =>S_NOT_VALID_ADDR          ,
    --INDICATION FOR BAD RECEIVED 
    --RX_series7
    BAD_PACKET_RECEIVED     =>S_BAD_PACKET_RECEIVED ,
    CRC_ERROR               =>S_CRC_ERROR           ,
    STD_ERROR               =>S_STD_ERROR           
    
);

    
-- !debug: 20/02/2023

  access_config_top_inst:  access_config_top
     port map (
        clk             => S_OUT_CLKDIV_50MHz, -- sys_clk            , -- !TODO: 01/02/2023 check if requires @32MHz
        config_ctl_reg  =>  config_ctl_reg     ,--connect to registers             std_logic_vector (31 DOWNTO 0);
        din             =>  std_logic_vector'(X"00000000" & config_data_in(15 downto 0) & config_data_in(31 downto 16)), --connect to registers             STD_LOGIC_VECTOR (63 DOWNTO 0);
        reset           =>  "not"(S_RST)              ,
        reset_fifo      =>  reset_fifo_reg     ,--connect to registers             std_logic;
        so              =>  '0', -- SO_FLASH           ,--connect to TOP										--Liron added for remote programming
        wr_en           =>  config_wr_en       ,--connect to registers             STD_LOGIC;
        CS              =>  open, -- CS_FLASH           ,--connect to TOP
        SCK             =>  open, -- SCK_FLASH          ,--connect to primitive strartupe2  std_logic;
        busy            =>  open, -- busy               ,--connect to registers             std_logic; !debug: 01/06/2022 NU?
        conf_status_reg =>  conf_status_reg    ,--connect to registers             std_logic_vector (15 DOWNTO 0);
        data_out        =>  config_data_out    ,--connect to registers             std_logic_vector (63 DOWNTO 0);
        rd_data_count   =>  rd_data_count      ,--connect to registers
        si              =>  open -- SI_FLASH           --connect to TOP
     );

  conf_fifo_rd_cnt_reg(6 downto 0) <= rd_data_count; -- !TODO: 01/02/2023 connect to register
  conf_fifo_rd_cnt_reg(15 downto 7) <= (others => '0');
  config_ctl_reg <= CONTROL_REGISTER_MSB(15 downto 0) & CONTROL_REGISTER_LSB(15 downto 0);
  reset_fifo_reg <= FIFO_RESET(1);
 
 end RX_TX_TESTER_VER01_TB_ARC;
