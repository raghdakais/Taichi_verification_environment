
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
use work.channel_pack.all;
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY TX_Zynq IS
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
	 DATA_out          : OUT	std_logic;
	 TX_ERRs           : OUT	std_logic_vector (1 downto 0) --TX_ERR(0) '1'  if empty when RD_REQ  ,RX_ERR(1) '1' if fifo not empty after packet transaction
   );

END TX_Zynq ;

Library UNISIMS_VER;

ARCHITECTURE behave OF TX_Zynq IS
constant IP_word        : std_logic_vector (7 downto 0):=x"1B" ;
Signal DATA_counter     : std_logic_vector (31 downto 0) ;
Signal bytes_cnt        : integer range 0 to 7;
type   sm_type          is (idle,START_WORD_STATE,STREAM1_STATE,STREAM2_STATE,headers,data,footers,CRC);
SIGNAL channel_data_sm  : sm_type;
SIGNAL channel_data_sm_d: sm_type; 
SIGNAL go_d             : std_logic_vector (2 downto 0):="000";
Signal crc_calc         : std_logic_vector (15 downto 0):=x"FFFF" ;
Signal TX_det_byte      : std_logic_vector (7 downto 0) ;
Signal TX_det_byte_o    : std_logic_vector (7 downto 0) ; 
signal Header_counter   : std_logic_vector (7 downto 0) ; 
signal footer_counter   : std_logic_vector (7 downto 0) ; 
signal PayloadSize_int  : std_logic_vector (31 downto 0);  
signal STATn_DYN_int    : std_logic:='0';
signal RD_REQ_int       : std_logic:='0';
signal RD_err           : std_logic:='0';
signal TotalNumBytes    : std_logic_vector (31 downto 0) ;
signal totalnumbytes_cnt: std_logic_vector (31 downto 0) ;
signal IP_int           : std_logic:='0';
signal TX_data_byte     : std_logic_vector (7 downto 0) ;
signal TX_ERRs_int      : std_logic_vector (1 downto 0);
signal fifo_not_empty   : std_logic:='0';
constant plsexpndr      : natural :=3;
signal TXERR0_int_vec   : std_logic_vector (plsexpndr-1 downto 0);
signal TXERR1_int_vec   : std_logic_vector (plsexpndr-1 downto 0);



 attribute DONT_TOUCH : string;
 attribute DONT_TOUCH of  TX_data_byte	  		: signal is "TRUE";
 attribute DONT_TOUCH of  channel_data_sm	  		: signal is "TRUE";



-- attribute MARK_DEBUG : string;
-- attribute MARK_DEBUG of  TX_data_byte	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  channel_data_sm	  		: signal is "TRUE";
-- attribute keep : string;
-- attribute KEEP of TX_data_byte 			: signal is "TRUE";
-- attribute KEEP of RESET 			: signal is "TRUE";
-- attribute KEEP of channel_data_sm 			: signal is "TRUE";
--attribute DONT_TOUCH : string;
--attribute DONT_TOUCH of TX_data_byte		: signal is "TRUE";
--attribute DONT_TOUCH of channel_data_sm		: signal is "TRUE";

--attribute mark_debug : string;
--attribute mark_debug of TX_data_byte		: signal is "TRUE";
--attribute mark_debug of channel_data_sm		: signal is "TRUE";

BEGIN
---------------------------------------------

 PROCESS (CLKDIV)
                                                                                                                                                                                                
    BEGIN
	
	if rising_edge (CLKDIV) then	
		if RESET='1' then
			TX_det_byte       <= (others=>'0');
			TX_det_byte_o     <= (others=>'0');
			channel_data_sm   <= idle ;
			channel_data_sm_d <= idle ;
			go_d              <= (others=>'0');				
			crc_calc          <= x"FFFF";	
			Header_counter    <= (others=>'0');	
			DATA_counter      <= (others=>'0');
			Footer_counter    <= (others=>'0');
			STATn_DYN_int     <= '0';
			PayloadSize_int   <= (others=>'0');	
			RD_REQ_int        <= '0';
			RD_err            <= '0';
			totalnumbytes_cnt <= (others=>'0');
			TotalNumBytes     <= (others=>'0');
			bytes_cnt		  <=  0;
			IP_int            <= '0';
			TX_ERRs_int       <= (others=>'0');
			TXERR0_int_vec    <= (others=>'0');
			TXERR1_int_vec    <= (others=>'0');
			fifo_not_empty    <= '0';
			
			
------------------------------------------------------------
		else
		    TXERR0_int_vec<=TXERR0_int_vec(TXERR0_int_vec'high-1 downto 0) & RD_err;
			if TXERR0_int_vec > 0 then
				TX_ERRs_int(0)<='1';
			else
				TX_ERRs_int(0)<='0';
			end if;
		
			TXERR1_int_vec<=TXERR1_int_vec(TXERR1_int_vec'high-1 downto 0) & fifo_not_empty;
			if TXERR1_int_vec > 0 then
				TX_ERRs_int(1)<='1';
			else
				TX_ERRs_int(1)<='0';
			end if;
--------------------------------------------------------------		
		
			if RD_EMPTY='1' and RD_REQ_int='1' then
			RD_err <='1';
			else
			RD_err <='0';
			end if;
			
			if channel_data_sm = idle and channel_data_sm_d = crc and RD_EMPTY='0' then
				fifo_not_empty <= '1';
			else 
				fifo_not_empty <= '0';
			end if;
-------------------------------------------------------------			
			
			go_d<=go_d(1 downto 0) & GO;
			channel_data_sm_d<=channel_data_sm;
			
			if channel_data_sm_d = crc then
				TX_det_byte_o<=crc_calc(7 downto 0);
				crc_calc(7 downto 0)<=crc_calc(15 downto 8);
				crc_calc(15 downto 8)<=(others=>'0');						
			else
				TX_det_byte_o<=TX_det_byte;
			end if;	
			
	-------------------------------------------------------------------		
			if channel_data_sm_d /= idle and  channel_data_sm_d /= crc then
				crc_calc<=nextCRC16_D8(TX_det_byte,crc_calc);
			end if;
	-------------------------------------------------------------------		
			case channel_data_sm is
			
			when idle 				=> 	TX_det_byte    <= IDLE_WORD;
										crc_calc       <= x"FFFF";
										Header_counter <= x"00";
										DATA_counter   <= (others=>'0');
										Footer_counter <= x"00";																									
										if go_d (2 downto 1) ="01" then
											channel_data_sm <= START_WORD_STATE;
											PayloadSize_int<= PayloadSize;
											STATn_DYN_int<=STATn_DYN;
											IP_int<=IP;
										end if;
									
	-----------------------------------------------------------------------
			when START_WORD_STATE 	=>  TX_det_byte<= StartWord;
										
										if STATn_DYN_int='0' then									
											channel_data_sm <= STREAM1_STATE;
										else
											channel_data_sm <= STREAM2_STATE;
										end if;																									
	-----------------------------------------------------------------------								
			when STREAM1_STATE 		=>  if IP_int='0' then
											TX_det_byte<= Stream_type1;
											channel_data_sm <= Headers;
										else
											TX_det_byte<= IP_word;
											channel_data_sm <= DATA;
										end if;	
										
										Header_counter<= x"00";
										if NumHeaderBytes =0 and NumDataBytes=0 and NumFooterBytes=0  then
											channel_data_sm <= CRC;										
										elsif NumHeaderBytes =0 and NumDataBytes=0 then
											channel_data_sm <= Footers;									
										elsif NumHeaderBytes =0 then
											channel_data_sm <= DATA;								
										end if;									
	-----------------------------------------------------------------------
			when STREAM2_STATE 		=>  TX_det_byte<= Stream_type2;								
										channel_data_sm <= Headers;
										Header_counter<= x"00";
										if NumHeaderBytes =0 and NumDataBytes=0 and NumFooterBytes=0  then
											channel_data_sm <= CRC;									
										elsif NumHeaderBytes =0 and NumDataBytes=0 then
											channel_data_sm <= Footers;									
										elsif NumHeaderBytes =0 then
											channel_data_sm <= DATA;								
										end if;	
	-----------------------------------------------------------------------									
			when Headers 		    =>  TX_det_byte<= DATA_IN;							
										if Header_counter=NumHeaderBytes-1  then					
											channel_data_sm <= DATA;
											Header_counter<= x"00";
											if NumDataBytes =0 and NumFooterBytes=0 then
												channel_data_sm <= CRC;										
											elsif NumDataBytes =0 then
												channel_data_sm <= Footers;
											end if;									
										else
											Header_counter<=Header_counter+1;
										end if;		
	-------------------------------------------------------------------------								
			when DATA               =>  TX_det_byte <= DATA_IN;								
										if (DATA_counter=NumDataBytes-1 and STATn_DYN_int = '0') or 
										(DATA_counter=PayloadSize_int-1 and STATn_DYN_int = '1') or IP_int='1' then														
											DATA_counter  <= (others=>'0');
											if NumFooterBytes =0 or IP_int='1'   then
												channel_data_sm <= CRC;											
											else 
												channel_data_sm <= Footers;
											end if;	
										else
											DATA_counter<=DATA_counter+1;
										end if;								
	------------------------------------------------------------------------								
			when Footers        	=>  TX_det_byte <= DATA_IN; 		
										if Footer_counter=NumFooterBytes-1  then					
											channel_data_sm <= CRC;										
											Footer_counter <= x"00";
										else								
										Footer_counter<=Footer_counter+1;
										end if;					
	------------------------------------------------------------------------								
			when CRC				=>  TX_det_byte<=x"CC";
										if bytes_cnt=1 then
											channel_data_sm <= idle;
											bytes_cnt<=0;
										else
											bytes_cnt<=bytes_cnt+1;	
										end if;			 
			end case;
	--------------------------------------------------------------------------		
			if RD_err ='1' then
				channel_data_sm <= idle;
			end if;
	-------------------------------------------------------------------------		
			if go_d (2 downto 1) ="01" then
			case STATn_DYN is 
				when '0'    => TotalNumBytes <= NumHeaderbytes+NumDatabytes+NumFooterbytes; 
				when '1'    => TotalNumBytes <= NumHeaderbytes+PayloadSize +NumFooterbytes;
				when others => TotalNumBytes <= NumHeaderbytes+NumDatabytes+NumFooterbytes;
			end case;		 
			end if;
	--------------------------------------------------------------------------------		
			if channel_data_sm=START_WORD_STATE and RD_EMPTY='0' then
				RD_REQ_int  <= '1';	
				totalnumbytes_cnt <= (others=>'0');			
			elsif TotalNumBytes_cnt>= TotalNumBytes-1 or IP_int='1'  then
				RD_REQ_int  <= '0';
				totalnumbytes_cnt <= (others=>'0');			
			elsif  RD_REQ_int  = '1' then
				TotalNumBytes_cnt<=TotalNumBytes_cnt+1;	
			else
				RD_REQ_int  <= '0';
				totalnumbytes_cnt <= (others=>'0');
			end if;	
	--------------------------------------------------------------------------------	
		end if;
	end if;
end process;	
TX_data_byte <= TX_det_byte_o;		 
RD_CLK       <= CLKDIV;
RD_REQ       <= RD_REQ_int;	
TX_ERRs      <= TX_ERRs_int;
--------------------------------------------------------------------------------

OSERDESE3_inst : OSERDESE3
generic map (
		DATA_WIDTH         => 8          ,      -- Parallel Data Width (4-8)
		INIT               => '0'        ,      -- Initialization value of the OSERDES flip-flops
		ODDR_MODE          => "FALSE"    ,
		OSERDES_D_BYPASS   => "FALSE"    ,
		OSERDES_T_BYPASS   => "FALSE"    ,
		IS_CLKDIV_INVERTED => '0'        ,  	-- Optional inversion for CLKDIV
		IS_CLK_INVERTED    => '0'        , 		-- Optional inversion for CLK
		IS_RST_INVERTED    => '0'        , 	    -- Optional inversion for RST
		SIM_DEVICE         => "ULTRASCALE_PLUS" -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
-- ULTRASCALE_PLUS_ES2)
)
	port map (
		OQ 				   => DATA_out   ,      -- 1-bit output: Serial Output Data
		T_OUT              => Tristate_o , 		-- 1-bit output: 3-state control output to IOB
		CLK                => FCLK       , 		-- 1-bit input: High-speed clock
		CLKDIV             => CLKDIV     , 		-- 1-bit input: Divided Clock
		D                  => TX_data_byte, 		-- 8-bit input: Parallel Data Input
		RST                => RESET      ,      -- 1-bit input: Asynchronous Reset
		T                  => Tristate_i 		-- 1-bit input: Tristate input from fabric
		);
-- End of OSERDESE3_inst instantiation
END ARCHITECTURE behave;

