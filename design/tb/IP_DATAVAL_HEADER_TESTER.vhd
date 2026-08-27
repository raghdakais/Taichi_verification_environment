
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity IP_DATAVAL_HEADER_TESTER is
GENERIC (
         G_DATA_LENGTH:INTEGER:=32 );
Port ( 
    START_TEST  : IN STD_LOGIC ;
    RST         : IN STD_LOGIC ;
    RX_IN     : IN STD_LOGIC ;
    TX_DATA_out : OUT STD_LOGIC; 
    CHANNEL_RDY : OUT STD_LOGIC ;
    clk_200MHz : IN STD_LOGIC;
    clk_50MHz : IN STD_LOGIC;
    STATUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        --BANK REGISTER OUTPUTS:
    MU_CTRL                 :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ADD_CONST_OFST_TO_MU    :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONST_OFST_VAL_TO_MU    :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_TST_CAL_CTRL_TEST  :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    TEST_ERROR              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    DIAGNSOTICS             :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    GLOBL_IP_COEF           :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    DIAGNSOTICS_TMP         :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_DATA_ALIGNMENT     :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    MODULE_DATA_OUT_SELCTION:IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_HL              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_LL              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_PER_TILE        :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    --INDICATION FOR BAD RECEIVED 
    BAD_PACKET_RECEIVED     :IN STD_LOGIC;
    CRC_ERROR               :IN STD_LOGIC;
    STD_ERROR               :IN STD_LOGIC
    
    );
    
end IP_DATAVAL_HEADER_TESTER;

architecture IP_DATAVAL_HEADER_TESTER_ARC of IP_DATAVAL_HEADER_TESTER is

COMPONENT TX_Zynq 
   Generic ( IDLE_WORD      : std_logic_vector (7 downto 0) :=x"B5";			
			 StartWord      : std_logic_vector (7 downto 0) :=x"21";
			 Stream_type1   : std_logic_vector (7 downto 0) :=x"43";
			 Stream_type2   : std_logic_vector (7 downto 0) :=x"DD";
			 			 
			 NumHeaderbytes : std_logic_vector (7 downto 0) :=x"00";
             NumDatabytes   : std_logic_vector (31 downto 0):=x"00000080";
			 NumFooterbytes : std_logic_vector (7 downto 0) :=x"00"
             			 
);			 
   PORT(    
	 RESET             : IN     std_logic;    	 
     CLKDIV     	   : IN     std_logic;
	 FCLK	           : IN     std_logic;	 
	 STATn_DYN         : IN     std_logic;
	 GO                : IN     std_logic;
	 IP                : IN     std_logic;
	 PayloadSize       : IN     std_logic_vector (31 downto 0);
	 TX_DATA_IN        : IN     std_logic_vector (7 downto 0);
	 RD_EMPTY          : IN     std_logic;
	 RD_CLK   	       : OUT    std_logic;
	 RD_REQ            : OUT    std_logic;
	 Tristate_i        : IN     std_logic;
	 Tristate_o        : OUT    std_logic;
	 TX_DATA_out       : OUT	std_logic	 
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

---------tx_fifo---------       
 COMPONENT fifo_generator_8bit_128depth--tx_fifo
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
constant Max_s_delay_cnt_val : integer :=500;  
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

SIGNAL S_CLKDIV     	 : std_logic;
SIGNAL S_FCLK	         : std_logic;	 
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

SIGNAL S_IP_DONE: STD_LOGIC;

signal sync_delay_done : boolean;

begin
U2_8_128_TX_FIFO: fifo_generator_8bit_128depth--tx_fifo
  PORT MAP (
    rst => RST,
    wr_clk => S_CLKDIV,
    rd_clk => S_RD_CLK,
    din => S_SYNT_DATA_IN,
    wr_en => S_WR_EN, 
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
			 			                    
			 NumHeaderbytes =>X"00"              ,
             NumDatabytes   =>X"00000080"        ,--128
			 NumFooterbytes =>X"00"
             			 
)		 
   PORT map(    
	 RESET             =>  RST                 ,
     CLKDIV     	   =>  S_CLKDIV              ,--50
	 FCLK	           =>  S_FCLK	               ,--200
	 STATn_DYN         =>  S_STATn_DYN         ,
	 GO                =>  S_GO                ,
	 IP                =>  S_IP                ,
	 PayloadSize       =>  S_PayloadSize       ,
	 TX_DATA_IN           =>  S_TX_FIFO_OUT           ,
	 RD_EMPTY          => S_RD_EMPTY ,
	 RD_CLK   	       =>  S_RD_CLK   	       ,
	 RD_REQ            =>  S_RD_REQ            ,
	 Tristate_i        =>  '0'        ,
	 Tristate_o        =>  S_Tristate_o        ,
	 TX_DATA_out          =>  TX_DATA_out   
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
        CLKDIV          	   =>  S_CLKDIV ,
		FCLK      		       =>  S_FCLK,
		channel_RDY   	       =>  S_channel_RDY , 	                   
		sDataIn                =>  RX_IN     ,                        		 								
		RX_det_o       	       =>  S_DATA_FROM_ZTNQTX	
	
    	);
----for tests: 
S_STATn_DYN     <= '0';   

S_PayloadSize   <=(others=>'0');    
S_DATAIN        <='1' ;   
S_CHANNEL_RDY   <= '1' ; 
CHANNEL_RDY   <= '0', '1' after 1 US; -- !debug: 17/01/2023 ES
S_FCLK<=clk_200MHz;
status<=X"DCBA";

S_CLKDIV <= clk_50MHz;                  -- !debug: 19/01/2023

S_GO_CNT: process (clk_200MHz, RST) --200MHz clk 
--counts the bits of each data byte (9 bits)
begin
IF RST='1' THEN 
     S_bit_counter<=0;   
ELSIF RISING_EDGE(clk_200MHz)  then
    IF S_bit_counter<7 THEN
            S_bit_counter <= S_bit_counter +1;
     ELSE   S_bit_counter<=0; 
     END IF;    
END IF;
end process;

sync_delay_done <= FALSE, TRUE after 10 US;   -- !debug: 17/01/2023 ES


GO_SIGNAL: process (S_CLKDIV, RST)
begin
IF RST='1' THEN 
     S_GO<='0';
     
ELSIF RISING_EDGE(S_CLKDIV) then

  if (sync_delay_done) then             -- !debug: 17/01/2023 ES
     
           CASE s_delay_cnt IS 
           WHEN 0 TO 326 => S_GO<='0';
           WHEN 328 to 333=>S_GO<='1';-- AFTER 9 BYTES CREATE ONE PULSE
           --WHEN 334 TO 395 => S_GO<='0';
          -- WHEN 396 =>S_GO<='1';-- AFTER 9 BYTES CREATE ONE PULSE
           WHEN 334 TO Max_s_delay_cnt_val=>S_GO<='0';
               
           WHEN OTHERS=>S_GO<='0';
           END CASE;
    
   end if;
           
END IF;
end process;

IP_SIGNAL: process (S_CLKDIV, RST)
begin
IF RST='1' THEN
     S_IP<='0';
      S_IP_DONE<='0';
ELSIF RISING_EDGE(S_CLKDIV) then 
   
           CASE s_delay_cnt IS     
           WHEN 0 TO 320 => S_IP<='0';--
           WHEN 321 TO 340 =>
                            if S_IP_DONE ='0' then 
                                S_IP<='1';    
                            else
                                S_IP<='0';
                            END IF; 
           WHEN 341 TO Max_s_delay_cnt_val=>S_IP<='0';
                                            S_IP_DONE <='1';
               
           WHEN OTHERS=>S_IP<='0';
           END CASE;
    
          
END IF;
end process;



wr_en_process:process(S_CLKDIV, RST)
begin
IF RST='1' THEN 
    S_WR_EN<='0';
    s_delay_cnt<=0;
ELSIF RISING_EDGE(S_CLKDIV) THEN
    IF s_delay_cnt <= 46 THEN 
        S_WR_EN<='0';
        s_delay_cnt<=s_delay_cnt+1;
    ELSIF  s_delay_cnt > 46 AND s_delay_cnt<175 then --175----56 THEN
        S_WR_EN<='1';
         s_delay_cnt<=s_delay_cnt+1;
    ELSIF  s_delay_cnt >= 175 AND s_delay_cnt <Max_s_delay_cnt_val  THEN --56 AND s_delay_cnt <Max_s_delay_cnt_val  THEN 
         S_WR_EN<='0';
         s_delay_cnt<=s_delay_cnt+1;
    ELSIF  s_delay_cnt =Max_s_delay_cnt_val  THEN 
            s_delay_cnt<=0;
    END IF;
END IF;
end process;




SYNTHETIC_DATA_PRO: PROCESS(S_CLKDIV, RST) --50MHz clk
BEGIN 


IF RST='1' THEN 
     S_case_counter_sig<=x"00"; 
     S_tx_data_08_sig<= x"f5";
     S_SYNT_DATA_IN<=(others=>'0');
    
ELSIF RISING_EDGE(S_CLKDIV) then
        IF s_delay_cnt > 46 and s_delay_cnt<175 AND S_case_counter_sig < X"82" THEN
            S_case_counter_sig <= std_logic_vector(unsigned(S_Case_counter_sig)+ "1");
             S_SYNT_DATA_IN<=S_tx_data_08_sig;  
         
         
                case S_case_counter_sig is 											
					when x"00" => S_tx_data_08_sig <= x"ff";
					when x"01" => S_tx_data_08_sig <= x"01";            
					when x"02" => S_tx_data_08_sig <= x"02";--          
					when x"03" => S_tx_data_08_sig <= x"03";--          
					when x"04" => S_tx_data_08_sig <= x"04";--          
					when x"05" => S_tx_data_08_sig <= x"05";--          
					when x"06" => S_tx_data_08_sig <= x"06";--          
					when x"07" => S_tx_data_08_sig <= x"07";--          
					when x"08" => S_tx_data_08_sig <= x"08";            
					when x"09" => S_tx_data_08_sig <= x"09";--          
					when x"0A" => S_tx_data_08_sig <= x"10";--             
					when x"0B" => S_tx_data_08_sig <= x"11";--                                   
					when x"0C" => S_tx_data_08_sig <= x"12";--                                      
					when x"0D" => S_tx_data_08_sig <= x"13";--                                      
					when x"0E" => S_tx_data_08_sig <= x"14";--                                      
					when x"0F" => S_tx_data_08_sig <= x"15";--                                      
					when x"10" => S_tx_data_08_sig <= x"16";--                                     
					when x"11" => S_tx_data_08_sig <= x"17";                
					when x"12" => S_tx_data_08_sig <= x"18";--                                         
					when x"13" => S_tx_data_08_sig <= x"19";--                                        
					when x"14" => S_tx_data_08_sig <= x"20";--                                      
					when x"15" => S_tx_data_08_sig <= x"21";--                                      
					when x"16" => S_tx_data_08_sig <= x"22";--                                      
					when x"17" => S_tx_data_08_sig <= x"23";--                                      
					when x"18" => S_tx_data_08_sig <= x"24";--                                      
					when x"19" => S_tx_data_08_sig <= x"25";--                                      
					when x"1A" => S_tx_data_08_sig <= X"26";--                 
  					when x"1B" => S_tx_data_08_sig <= x"27";--             
        			when x"1C" => S_tx_data_08_sig <= x"28";--     
        			when x"1D" => S_tx_data_08_sig <= x"29";--      
        			when x"1E" => S_tx_data_08_sig <= x"30";--      
        			when x"1F" => S_tx_data_08_sig <= x"31";--      
        			when x"20" => S_tx_data_08_sig <= x"32";--      
        			when x"21" => S_tx_data_08_sig <= x"33";--      
        			when x"22" => S_tx_data_08_sig <= x"34";--      
        			when x"23" => S_tx_data_08_sig <= x"35";        
        			when x"24" => S_tx_data_08_sig <= x"36";--      
        			when x"25" => S_tx_data_08_sig <= x"37";--      
					when x"26" => S_tx_data_08_sig <= x"38";--      
					when x"27" => S_tx_data_08_sig <= x"39";--      
					when x"28" => S_tx_data_08_sig <= x"40";--      
					when x"29" => S_tx_data_08_sig <= x"41";--      
					when x"2A" => S_tx_data_08_sig <= x"42";--      
					when x"2B" => S_tx_data_08_sig <= x"43";--       
					when x"2C" => S_tx_data_08_sig <= x"44";--       
					when x"2D" => S_tx_data_08_sig <= x"45";--       
					when x"2E" => S_tx_data_08_sig <= x"46";--       
					when x"2F" => S_tx_data_08_sig <= x"47";--       
					when x"30" => S_tx_data_08_sig <= x"48";--       
					when x"31" => S_tx_data_08_sig <= x"49";--       
					when x"32" => S_tx_data_08_sig <= x"50";--       
					when x"33" => S_tx_data_08_sig <= x"51";--       
					when x"34" => S_tx_data_08_sig <= x"52";--       
					when x"35" => S_tx_data_08_sig <= x"53";--       
					when x"36" => S_tx_data_08_sig <= x"54";--       
					when x"37" => S_tx_data_08_sig <= x"55";--       
					when x"38" => S_tx_data_08_sig <= x"56";--       
					when x"39" => S_tx_data_08_sig <= x"57";--       
					when x"3A" => S_tx_data_08_sig <= x"58";--       
					when x"3B" => S_tx_data_08_sig <= x"59";--       
					when x"3C" => S_tx_data_08_sig <= x"60";--       
					when x"3D" => S_tx_data_08_sig <= x"61";--       
					when x"3E" => S_tx_data_08_sig <= x"62";--       
                    when x"3f" => S_tx_data_08_sig <= x"63";--       
                    when x"40" => S_tx_data_08_sig <= x"64";--
                    when x"41" => S_tx_data_08_sig <= x"65";--
                    when x"42" => S_tx_data_08_sig <= x"66";--
                    when x"43" => S_tx_data_08_sig <= x"67";--
                    when x"44" => S_tx_data_08_sig <= x"68";--
                    when x"45" => S_tx_data_08_sig <= x"69";--
                    when x"46" => S_tx_data_08_sig <= x"70";--
                    when x"47" => S_tx_data_08_sig <= x"71";--
                    when x"48" => S_tx_data_08_sig <= x"72";--
                    when x"49" => S_tx_data_08_sig <= x"73";--
                    when x"4a" => S_tx_data_08_sig <= x"74";--
                    when x"4b" => S_tx_data_08_sig <= x"75";--
                    when x"4c" => S_tx_data_08_sig <= x"76";--
                    when x"4d" => S_tx_data_08_sig <= x"77";--
                    when x"4e" => S_tx_data_08_sig <= x"78";--
                    when x"4f" => S_tx_data_08_sig <= x"79";--
                    when x"50" => S_tx_data_08_sig <= x"80";--
                    when x"51" => S_tx_data_08_sig <= x"81";--
                    when x"52" => S_tx_data_08_sig <= x"82";--
                    when x"53" => S_tx_data_08_sig <= x"83";--
                    when x"54" => S_tx_data_08_sig <= x"84";--
                    when x"55" => S_tx_data_08_sig <= x"85";--
                    when x"56" => S_tx_data_08_sig <= x"86";--
                    when x"57" => S_tx_data_08_sig <= x"87";--
                    when x"58" => S_tx_data_08_sig <= x"88";--
                    when x"59" => S_tx_data_08_sig <= x"89";--
                    when x"5a" => S_tx_data_08_sig <= x"90";--
                    when x"5b" => S_tx_data_08_sig <= x"91";--
                    when x"5c" => S_tx_data_08_sig <= x"92";--
                    when x"5d" => S_tx_data_08_sig <= x"93";--
                    when x"5e" => S_tx_data_08_sig <= x"94";--
                    when x"5f" => S_tx_data_08_sig <= x"95";--
                    when x"60" => S_tx_data_08_sig <= x"96";--
                    when x"61" => S_tx_data_08_sig <= x"97";--
                    when x"62" => S_tx_data_08_sig <= x"98";
                    when x"63" => S_tx_data_08_sig <= x"99";
                    when x"64" => S_tx_data_08_sig <= x"00";
                    when x"65" => S_tx_data_08_sig <= x"01";
                    when x"66" => S_tx_data_08_sig <= x"02";
                    when x"67" => S_tx_data_08_sig <= x"03";
                    when x"68" => S_tx_data_08_sig <= x"04";
                    when x"69" => S_tx_data_08_sig <= x"05";
                    when x"6a" => S_tx_data_08_sig <= x"06";
                    when x"6b" => S_tx_data_08_sig <= x"07";
                    when x"6c" => S_tx_data_08_sig <= x"08";
                    when x"6d" => S_tx_data_08_sig <= x"09";
                    when x"6e" => S_tx_data_08_sig <= x"10";
                    when x"6f" => S_tx_data_08_sig <= x"11";
                    when x"70" => S_tx_data_08_sig <= x"12";
                    when x"71" => S_tx_data_08_sig <= x"13";
                    when x"72" => S_tx_data_08_sig <= x"14"; 
                    when x"73" => S_tx_data_08_sig <= x"15"; 
                    when x"74" => S_tx_data_08_sig <= x"16"; 
                    when x"75" => S_tx_data_08_sig <= x"17";
                    when x"76" => S_tx_data_08_sig <= x"18";
                    when x"77" => S_tx_data_08_sig <= x"19";
                    when x"78" => S_tx_data_08_sig <= x"20";
                    when x"79" => S_tx_data_08_sig <= x"21";
                    when x"7a" => S_tx_data_08_sig <= x"22";
                    when x"7b" => S_tx_data_08_sig <= x"23";
                    when x"7c" => S_tx_data_08_sig <= x"24";
                    when x"7d" => S_tx_data_08_sig <= x"25";
                    when x"7e" => S_tx_data_08_sig <= x"26";
                    when x"7f" => S_tx_data_08_sig <= x"27";
                    when x"80" => S_tx_data_08_sig <= x"28";
                    when x"81" => S_tx_data_08_sig <= x"99";
                                 S_case_counter_sig<=(others=>'0');
                    when x"82" => S_tx_data_08_sig <= x"99";
                    when x"83" => S_tx_data_08_sig <= x"99";
                    when x"84" => S_tx_data_08_sig <= x"99";
                    when x"85" => S_tx_data_08_sig <= x"99";
                    when x"86" => S_tx_data_08_sig <= x"99";
                    when x"87" => S_tx_data_08_sig <= x"99";
                    when x"88" => S_tx_data_08_sig <= x"99";
                    when x"89" => S_tx_data_08_sig <= x"99";
                    when x"8a" => S_tx_data_08_sig <= x"99";
                    when x"8b" => S_tx_data_08_sig <= x"99";
                    when x"8c" => S_tx_data_08_sig <= x"99";
                    when x"8d" => S_tx_data_08_sig <= x"99";
                    when x"8e" => S_tx_data_08_sig <= x"99";
                    when x"8f" => S_tx_data_08_sig <= x"99" ;
                    when x"90" => S_tx_data_08_sig <= x"99"  ;
                    when x"91" => S_tx_data_08_sig <= x"99"  ;
                    when x"92" => S_tx_data_08_sig <= x"99"  ;
                    when x"93" => S_tx_data_08_sig <= x"99";
                    when x"94" => S_tx_data_08_sig <= x"99";
                    when x"95" => S_tx_data_08_sig <= x"99";
                    when x"96" => S_tx_data_08_sig <= x"99";
                    when x"97" => S_tx_data_08_sig <= x"99";
                    when x"98" => S_tx_data_08_sig <= x"99";
                    when x"99" => S_tx_data_08_sig <= x"99";
                    when x"9a" => S_tx_data_08_sig <= x"99";
                    when x"9b" => S_tx_data_08_sig <= x"99";
                    when x"9c" => S_tx_data_08_sig <= x"99";
                    when x"9d" => S_tx_data_08_sig <= x"99";
                    when x"9e" => S_tx_data_08_sig <= x"99";
                    when x"9f" => S_tx_data_08_sig <= x"99";
                    when x"a0" => S_tx_data_08_sig <= x"99";
                    when x"a1" => S_tx_data_08_sig <= x"99";
                    when x"a2" => S_tx_data_08_sig <= x"99";
                    when x"a3" => S_tx_data_08_sig <= x"99";
                    when x"a4" => S_tx_data_08_sig <= x"99";
                    when x"a5" => S_tx_data_08_sig <= x"99";
                    when x"a6" => S_tx_data_08_sig <= x"99";
                    when x"a7" => S_tx_data_08_sig <= x"99";
                    when x"a8" => S_tx_data_08_sig <= x"99";
                    when x"a9" => S_tx_data_08_sig <= x"99";
                    when x"aa" => S_tx_data_08_sig <= x"99";
                    when x"ab" => S_tx_data_08_sig <= x"99";
                    when x"ac" => S_tx_data_08_sig <= x"99";
                    when x"ad" => S_tx_data_08_sig <= x"99";
                    when x"ae" => S_tx_data_08_sig <= x"99";
                    when x"af" => S_tx_data_08_sig <= x"99";
                    when x"b0" => S_tx_data_08_sig <= x"99";
                    when x"b1" => S_tx_data_08_sig <= x"99";
                    when x"b2" => S_tx_data_08_sig <= x"99";
                    when x"b3" => S_tx_data_08_sig <= x"99";
                    when x"b4" => S_tx_data_08_sig <= x"99";
                    when x"b5" => S_tx_data_08_sig <= x"99";
                    when x"b6" => S_tx_data_08_sig <= x"99";
                    when x"b7" => S_tx_data_08_sig <= x"99";
                    when x"b8" => S_tx_data_08_sig <= x"99";
                    when x"b9" => S_tx_data_08_sig <= x"99";
                    when x"ba" => S_tx_data_08_sig <= x"99";
                    when x"bb" => S_tx_data_08_sig <= x"99";
                    when x"bc" => S_tx_data_08_sig <= x"99";
                    when x"bd" => S_tx_data_08_sig <= x"99";
                    when x"be" => S_tx_data_08_sig <= x"99";
                    when x"bf" => S_tx_data_08_sig <= x"99";
                    when x"c0" => S_tx_data_08_sig <= x"99";
                    when x"c1" => S_tx_data_08_sig <= x"99";
                    when x"c2" => S_tx_data_08_sig <= x"99";
                    when x"c3" => S_tx_data_08_sig <= x"99";
                    when x"c4" => S_tx_data_08_sig <= x"99";
                    when x"c5" => S_tx_data_08_sig <= x"99";
                    when x"c6" => S_tx_data_08_sig <= x"99";
                    when x"c7" => S_tx_data_08_sig <= x"99";					
--					             S_case_counter_sig<=(others=> '0');    
					when others =>S_tx_data_08_sig<= x"AA" ;
			end case;
--        ELSE ---not (s_delay_cnt > 46 and s_delay_cnt<=55 AND S_case_counter_sig < X"1b")
--        IF S_case_counter_sig<X"16" THEN
--            S_tx_data_08_sig<= x"F1";-- 1 IS WRITE 2 READ
--        ELSE
--             S_tx_data_08_sig<= x"F1";-- 1 IS WRITE 2 READ
--        END IF;
        END IF;
END IF;
end process;
end IP_DATAVAL_HEADER_TESTER_ARC;
