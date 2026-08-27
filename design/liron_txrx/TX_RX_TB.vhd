--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
use work.channel_pack.all;
Library UNISIM;
use UNISIM.vcomponents.all;
-------------------------------------------------------------------------------
 
ENTITY TX_RX_TB IS 
 
END TX_RX_TB;
-------------------------------------------------------------------------------
ARCHITECTURE behave OF TX_RX_TB is
---------------------------------------------------------------------------------
signal CLK_int: std_logic:='0';
signal CLK_int_n: std_logic:='0';
signal aRST,aRST1: std_logic:='0';
----------------------------------------------------------------------
component MMCM_200
 port
  (-- Clock in ports
   CLK_IN1_P         : in     std_logic;
   CLK_IN1_N         : in     std_logic;
   -- Clock out ports
   CLK_OUT1          : out    std_logic;
   CLK_OUT2          : out    std_logic;   
   -- Status and control signals
   INPUT_CLK_STOPPED : out    std_logic;
   LOCKED         : out    std_logic
  );
 end component;
 ---------------------------------------------------------------------
component TX_series7 IS
   Generic ( IDLE_WORD      : std_logic_vector (7 downto 0) :=x"B5";			
			 StartWord      : std_logic_vector (7 downto 0) :=x"21";
			 Stream_type1   : std_logic_vector (7 downto 0) :=x"43";
			 Stream_type2   : std_logic_vector (7 downto 0) :=x"DD";
			 			 
			 NumHeaderbytes : std_logic_vector (7 downto 0) :=x"08";
             NumDatabytes   : std_logic_vector (31 downto 0):=x"00000020";
			 NumFooterbytes : std_logic_vector (7 downto 0) :=x"08"
             			 
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
	 DATA_out          : OUT	std_logic	 
   );

END component ;
--------------------------------------------------------------------------
component RX_series7 IS
    Generic (
      IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
	  StartWord      : std_logic_vector (7 downto 0):=x"21";
	  Stream_type1   : std_logic_vector (7 downto 0):=x"43";
	  Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
	  TapWidth       : natural :=5;
	  ParallelWidth  : natural :=8;
      NumHeaderBytes : natural :=8;
	  NumDataBytes   : natural :=32;
	  NumFooterBytes : natural :=8
------------------------------------------------------------------------------------	  
	  );
    PORT( 
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		FCLK      		        : in    std_logic;   --serial clock input side
		channel_RDY   	        : in    std_logic;     
		sDataIn                 : in    std_logic;  		
		IDLY_CNT  		        : out   std_logic_vector(TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count								
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
END component;
---------------------------------------------------------------------
component TX_Zynq IS
   Generic ( IDLE_WORD      : std_logic_vector (7 downto 0) :=x"B5";			
			 StartWord      : std_logic_vector (7 downto 0) :=x"21";
			 Stream_type1   : std_logic_vector (7 downto 0) :=x"43";
			 Stream_type2   : std_logic_vector (7 downto 0) :=x"DD";			 			 
			 NumHeaderbytes : std_logic_vector (7 downto 0) :=x"08";
             NumDatabytes   : std_logic_vector (31 downto 0):=x"00000020";
			 NumFooterbytes : std_logic_vector (7 downto 0) :=x"08"            			 
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
	 Tristate_i        : IN     std_logic;
	 Tristate_o        : OUT    std_logic;
	 DATA_out          : OUT	std_logic	 
   );

END component ;
--------------------------------------------------------------------
component RX_Zynq IS
    Generic (
      IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
	  StartWord      : std_logic_vector (7 downto 0):=x"21";
	  Stream_type1   : std_logic_vector (7 downto 0):=x"43";
	  Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
	  TapWidth       : natural := 9;      
	  ParallelWidth  : natural := 8;
      NumHeaderBytes : natural :=8;
	  NumDataBytes   : natural :=32;
	  NumFooterBytes : natural :=8	  
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
END component;
---------------------------------------------------------------------------
component fifo_TX  is
   PORT( 
  rst     : IN    std_logic;
  wr_clk  : IN    std_logic;				
  rd_clk  : IN    std_logic;
  din     : IN    std_logic_vector (7 downto 0);
  wr_en   : IN    std_logic;	
  rd_en   : IN    std_logic;	
  dout    : out   std_logic_vector (7 downto 0);		
  full    : OUT   std_logic;
  empty   : OUT   std_logic
);        			
END component;
---------------------------------------------------------------------------
signal DATA1                 : std_logic  :='0';
signal FCLK,FCLK1            : std_logic  :='0'; 
signal CLKDIV,CLKDIV2,locked : std_logic  :='0';          
signal Channel_data_locked   : std_logic  :='0'; 
signal Channel_RDY           : std_logic  :='0'; 
signal RX_det_o              : sTD_LOGIC_VECTOR (7 downto 0);     						
signal start_valid           : std_logic:='0';
signal Headers_valid         : std_logic:='0';
signal data_valid            : std_logic:='0';
signal Footers_valid         : std_logic:='0';							
signal crc_error             : std_logic:='0';
signal std_error             : std_logic:='0';
signal PCKT_start            : std_logic:='0';
signal header_valid_o        : std_logic:='0';
signal data_valid_o          : std_logic:='0';
signal footer_valid_o        : std_logic:='0';
signal det2load_o	         : sTD_LOGIC_VECTOR (31 downto 0);     
signal load_o	             : std_logic:='0'; 
signal packet_received       : std_logic; 
signal good_packet_received  : std_logic;
signal bad_packet_received   : std_logic;  
signal din     				 : sTD_LOGIC_VECTOR (7 downto 0); 
signal wr_en   				 : std_logic;
signal rd_en   				 : std_logic;
signal dout	   				 : sTD_LOGIC_VECTOR (7 downto 0); 
signal empty   				 : std_logic;
signal IP_pckt_valid         : std_logic;
signal DATA_out,DATA_out2              : std_logic;
signal RESET                 : std_logic;
-------------------------------------------------------------------------------
BEGIN
------------------------------------------------
CLK_int     <= not CLK_int after 2.5 ns;
CLK_int_n   <= not CLK_int;
RESET       <= '1' , '0' after 1 us;
Channel_RDY <= '0', '1' after 2 us;
FCLK1       <= FCLK ;
CLKDIV2     <= CLKDIV ;
DATA_out2   <= DATA_out after 2.6 ns;
------------------------------------------------
PROCESS
   BEGIN    
WAIT FOR 400 Us; 
--For i in 1 to 100 Loop
--	        PCKT_start <= '1';       	     								
	  		Wait until CLKDIV 'event and CLKDIV = '1';
			PCKT_start <= '1';		
	  		Wait until CLKDIV 'event and CLKDIV = '1';
	        PCKT_start <= '0';
--			WAIT FOR 100 Us; 
--End Loop;
end process;	
 
---------------------------------------------------  
M_DCM1 : MMCM_200
  port map
   (-- Clock in ports
    CLK_IN1_P          => CLK_int,
    CLK_IN1_N          => CLK_int_n,
    -- Clock out ports
    CLK_OUT1           => FCLK,
    CLK_OUT2           => CLKDIV,    
    INPUT_CLK_STOPPED  => open,
    LOCKED             => LOCKED);
----------------------------------------------------
--RX_Zynq_inst: RX_Zynq 
--    Generic map (
--      IDLE_word      => x"B5",
--	  StartWord      => x"21",
--	  Stream_type1   => x"43",
--	  Stream_type2   => x"DD",
--	  TapWidth       =>  9   ,   
--	  ParallelWidth  =>  8   ,
--      NumHeaderBytes =>  8   ,
--	  NumDataBytes   =>  32  ,
--	  NumFooterBytes =>  8   	  
--	  )
--    PORT map ( 
--        RESET       		  =>  RESET                ,
--        CLKDIV          	  =>  CLKDIV               ,
--		FCLK      		      =>  FCLK                 ,
--		Channel_RDY   	      =>  Channel_RDY          ,
--		sDataIn               =>  DATA_out2             ,
--		IDLY_CNT  		      =>  open                 ,							       		                        
--		RX_det_o       	      =>  RX_det_o             ,		                       
--		start_valid           =>  start_valid          , 
--		Headers_valid         =>  Headers_valid        , 
--		data_valid            =>  data_valid           , 
--		Footers_valid         =>  Footers_valid        , 
--		IP_pckt_valid         =>  IP_pckt_valid        , 
--		packet_received       =>  packet_received      , 
--		good_packet_received  =>  good_packet_received , 
--		bad_packet_received   =>  bad_packet_received  , 
--		crc_error             =>  crc_error            ,
--        std_error             =>  std_error              
--		                                    
--    	);
---------------------------------------------------------------------------------
-- TX_series7_inst: TX_series7 
   -- Generic map ( IDLE_WORD      =>x"B5"		  ,
			     -- StartWord      =>x"21"        ,
			     -- Stream_type1   =>x"43"        ,
			     -- Stream_type2   =>x"DD"        ,											   
			     -- NumHeaderbytes =>x"08"        ,
                 -- NumDatabytes   =>x"00000020"  ,
			     -- NumFooterbytes =>x"08"            			 
-- )			 
   -- PORT map(    
	 -- RESET             => RESET        ,
     -- CLKDIV     	      => CLKDIV       ,
	 -- FCLK	          => FCLK	      ,
	 -- STATn_DYN         => '0'          ,
	 -- GO                => PCKT_start   ,
	 -- IP                => '0'          ,
	 -- PayloadSize       => x"00000006"  ,
	 -- DATA_IN           => dout         ,
	 -- RD_EMPTY          => empty        ,
	 -- RD_CLK   	      => open   	  ,
	 -- RD_REQ            => rd_en        ,
	 -- DATA_out          => DATA_out     
   -- );
----------------------------------------------------------------------------------
RX_series7_inst: RX_series7 
    Generic map (
      IDLE_word      =>x"B5" , 
	  StartWord      =>x"21" ,
	  Stream_type1   =>x"43" ,
	  Stream_type2   =>x"DD" ,
	  TapWidth       =>5     ,
	  ParallelWidth  =>8     ,
      NumHeaderBytes =>8     ,
	  NumDataBytes   =>32    ,
	  NumFooterBytes =>8	  
	  )
    PORT map( 
        RESET       		    =>  RESET                ,
        CLKDIV          	    =>  CLKDIV               ,
		FCLK      		        =>  FCLK                 ,
		channel_RDY   	        =>  Channel_RDY          ,
		sDataIn                 =>  DATA_out             ,
		IDLY_CNT  		        =>  open                 ,									
		RX_det_o       	        =>  RX_det_o             ,		 
		start_valid             =>  start_valid          , 
		Headers_valid           =>  Headers_valid        , 
		data_valid              =>  data_valid           , 
		Footers_valid           =>  Footers_valid        , 
		IP_pckt_valid           =>  IP_pckt_valid        , 
		packet_received         =>  packet_received      , 
		good_packet_received    =>  good_packet_received , 
		bad_packet_received     =>  bad_packet_received  , 
		crc_error               =>  crc_error            ,
        std_error               =>  std_error              		
    	);
-------------------------------------------------------------------------------
TX_Zynq_inst: TX_Zynq 
   Generic map (IDLE_WORD      => x"B5"        ,			
				StartWord      => x"21"        ,
				Stream_type1   => x"43"        ,
				Stream_type2   => x"DD"        ,							  
				NumHeaderbytes => x"08"        ,
				NumDatabytes   => x"00000020"  ,
				NumFooterbytes => x"08"        
             			 
)			 
   PORT map(    
	 RESET             => RESET        ,
     CLKDIV     	   => CLKDIV       ,
	 FCLK	           => FCLK	       ,
	 STATn_DYN         => '0'          ,
	 GO                => PCKT_start   ,
	 IP                => '0'          ,
	 PayloadSize       => x"00000006"  ,
	 DATA_IN           => dout         ,
	 RD_EMPTY          => empty        ,
	 RD_CLK   	       => open   	   ,
	 RD_REQ            => rd_en        ,
	 Tristate_i        => '1'          ,
	 Tristate_o        => open         ,
	 DATA_out          => DATA_out
   );
----------------------------------------------------------------------------

PROCESS
   BEGIN
din<=(others=>'0'); 
wr_en <= '0';   
WAIT FOR 250 Us; 
For i in 1 to 49 Loop	               	     								
	  		Wait until CLKDIV 'event and CLKDIV = '1';
			wr_en <= '1';
			if i=1 then
			din<=x"06";
			elsif i>1 and i<=4	then
			din<=x"00";
			else
			din   <=din+1;
			end if;
End Loop;

wr_en <= '0';
end process;	

fifo_TX_inst: fifo_TX 
   PORT MAP( 
  rst     => aRST     ,
  wr_clk  => CLKDIV   ,
  rd_clk  => CLKDIV   ,
  din     => din      ,
  wr_en   => wr_en    ,
  rd_en   => rd_en    ,
  dout    => dout	  ,
  full    => open     ,
  empty   => empty
);        			

	
end behave;





