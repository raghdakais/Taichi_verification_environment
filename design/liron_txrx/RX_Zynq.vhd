--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_unsigned.all;
use work.channel_pack.all;
Library UNISIM;
use UNISIM.vcomponents.all;

-------------------------------------------------------------------------------

ENTITY RX_Zynq IS
    Generic (
      IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
	  StartWord      : std_logic_vector (7 downto 0):=x"21";
	  Stream_type1   : std_logic_vector (7 downto 0):=x"43";
	  Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
	  TapWidth       : natural := 9;      
	  ParallelWidth  : natural := 8;
      NumHeaderBytes : natural := 8;
	  NumDataBytes   : natural := 32;
	  NumFooterBytes : natural := 8
	  
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
		CHANNEL_DATA_LOCKED     : OUT   std_logic;
        std_error               : OUT   std_logic
		
    	);
END RX_Zynq;

ARCHITECTURE behave OF RX_Zynq IS
------------------------------------------------------------------------------------
signal sDataInDly, FCLK_inv : std_logic;
signal CNTVALUEIN,cntvaluein_t       : natural range 0 to 2**TapWidth - 1 ;
type sm_state1 is (idle,clocks_rdy,set_load,Bit_align,pre_byte_align,byte_align,wait_st,look_for_sync,wait_for_sync,synced);
signal sm4sync : sm_state1;
signal Bitslip  					 : std_logic:='0';
signal IDLY_LD  					 : std_logic:='0';  --IDELAYE3 Load
signal IDLY_CE  					 : std_logic:='0';  --IDELAYE3 CE
signal IDLY_INC 					 : std_logic:='0';  --IDELAYE3 Tap Increment
signal Channel_RDY_stable 		     : std_logic_vector(3 downto 0);
signal pDataIn,pDataIn_prev: STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);

Signal cnt_idle_byte           		 : natural range 0 to 7;
constant cnt_num_byte          		 : natural range 0 to 7:=7;
constant delay_num             		 : natural range 0 to 15:=15;
Signal delay_cnt_byte          		 : natural range 0 to 15:=0;
Signal Channel_OK                    : std_logic:='0';
signal CNTVALUEIN_std          		 : std_logic_vector(TapWidth-1 downto 0);
signal delay_cnt               		 : std_logic_vector(2 downto 0):="000";
constant delay_cnt_value             : std_logic_vector(2 downto 0):="111";
signal bit_slp_value                 : std_logic_vector(2 downto 0):="000";
signal change_det              		 : std_logic:='0';
signal ByteSlp_REG0                  : STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);
signal ByteSlp_REG1,ByteSlp_REG2     : STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);
signal Channel_data_locked_int       : std_logic:='0';

--attribute IODELAY_GROUP 			 : STRING;
--attribute IODELAY_GROUP of InputDelay: label is "channel_rx_in_group";
--------------------------------------------------------------------------------------------------------------------

    constant IP_WORD                   : std_logic_vector (7 downto 0):=x"1B";
	SIGNAL RX_det_sync                 : std_logic_vector (7 downto 0);
	SIGNAL RX_det_sync_s               : std_logic_vector (7 downto 0);
	SIGNAL RX_det_sync_ss              : std_logic_vector (7 downto 0);
	
	type   sm_type2                     is (Idle,w4start1,w4start2,Headers,Data_st,footers,CRC,end_werr,end_st);
	SIGNAL channel_data_sm             : sm_type2; 
	
	SIGNAL start_valid_int             : std_logic;
	SIGNAL Headers_valid_int           : std_logic;  
	SIGNAL data_valid_int              : std_logic;  
	SIGNAL Footers_valid_int           : std_logic;  	
	SIGNAL CRC_valid_int               : std_logic;  	
	SIGNAL IP_pckt_valid_int		   : std_logic; 
	SIGNAL crc_calc                    : std_logic_vector (15 downto 0):=x"FFFF";	
	
	SIGNAL good_packet                 : std_logic;
	SIGNAL bad_packet                  : std_logic;
	SIGNAL IP_pckt                     : std_logic;
	SIGNAL cnt_header                  : natural range 0 to 2047;	
	SIGNAL cnt_data                    : std_logic_vector (31 downto 0):=x"00000000";
	SIGNAL cnt_footer                  : natural range 0 to 2047;	
	SIGNAL cnt_crc                     : natural range 0 to 3;
	signal channel_data_locked_vec	   : std_logic_vector (3 downto 0):=x"0";
	signal NumOfBytesExpected          : std_logic_vector (31 downto 0):=x"00000000";
	signal dynamic_stream              : std_logic;

--	attribute DONT_TOUCH : string;
--attribute DONT_TOUCH of good_packet		: signal is "TRUE";
--attribute DONT_TOUCH of bad_packet		: signal is "TRUE";
--attribute DONT_TOUCH of RX_det_sync			: signal is "TRUE";
--attribute DONT_TOUCH of sm4sync			: signal is "TRUE";
--attribute DONT_TOUCH of channel_data_locked_vec			: signal is "TRUE";
--attribute DONT_TOUCH of channel_data_locked_int			: signal is "TRUE";
--attribute DONT_TOUCH of Channel_RDY			: signal is "TRUE";

--attribute mark_debug : string;
--attribute mark_debug of good_packet		: signal is "TRUE";
--attribute mark_debug of bad_packet		: signal is "TRUE";
--attribute mark_debug of RX_det_sync			: signal is "TRUE";
--attribute mark_debug of sm4sync			: signal is "TRUE";
--attribute mark_debug of channel_data_locked_vec			: signal is "TRUE";
--attribute mark_debug of channel_data_locked_int			: signal is "TRUE";
--attribute mark_debug of Channel_RDY			: signal is "TRUE";
-- 	attribute DONT_TOUCH : string;
-- attribute DONT_TOUCH of  RX_det_sync	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  channel_data_sm	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  start_valid_int	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  Headers_valid_int	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  data_valid_int	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  Footers_valid_int	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  IP_pckt_valid_int	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  good_packet	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  bad_packet	  		: signal is "TRUE";
-- attribute DONT_TOUCH of  RX_det_sync_ss	  		: signal is "TRUE";



-- attribute MARK_DEBUG : string;
-- attribute MARK_DEBUG of  RX_det_sync	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  channel_data_sm	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  start_valid_int	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  Headers_valid_int	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  data_valid_int	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  Footers_valid_int	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  IP_pckt_valid_int	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  good_packet	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  bad_packet	  		: signal is "TRUE";
-- attribute MARK_DEBUG of  RX_det_sync_ss	  		: signal is "TRUE";

-- attribute keep : string;
-- attribute KEEP of channel_data_sm 			: signal is "TRUE";
-- attribute KEEP of RX_det_sync 			: signal is "TRUE";
-- attribute KEEP of start_valid_int 			: signal is "TRUE";
-- attribute KEEP of Headers_valid_int 			: signal is "TRUE";
-- attribute KEEP of data_valid_int  			: signal is "TRUE";
-- attribute KEEP of Footers_valid_int  			: signal is "TRUE";
-- attribute KEEP of RESET  			: signal is "TRUE";
-------------------------------------------------------------------------------
BEGIN
-------------------------------------------------------------------

	process(CLKDIV)
	begin
		
		if rising_edge(CLKDIV) then
			if (RESET = '1') then
				RX_det_sync_s           <=(others=>'1');
				RX_det_sync_ss          <=(others=>'1');
				channel_data_locked_vec <=(others=>'0');	
			else
			-----------------------------------
				channel_data_locked_vec <=channel_data_locked_vec(2 downto 0)&channel_data_locked_int;
				if channel_data_locked_vec(3)='1' then 
					RX_det_sync_s  <= RX_det_sync;
					RX_det_sync_ss <= RX_det_sync_s;
				else 
					RX_det_sync_s  <= (others=>'1');
					RX_det_sync_ss <= (others=>'1');	
				end if;	
			end if;
		end if;
	end process; 
	
	process(CLKDIV)
	begin
		
	   
		if rising_edge(CLKDIV) then	
			if RESET ='1' then
			
				channel_data_sm		<=	Idle;									
				cnt_header          <=	0 ; 
				cnt_data 	    	<= (others=>'0'); 
				cnt_footer 			<=	0 ; 
				cnt_crc 			<=	0 ;
				
				start_valid_int		<=	'0';
				Headers_valid_int	<=	'0';    
				data_valid_int 		<=	'0';          
				Footers_valid_int	<=	'0';
				IP_pckt_valid_int	<=	'0';	
				CRC_valid_int		<=	'0';
										
				good_packet			<=	'0'; 
				bad_packet          <=	'0'; 			 
				crc_calc			<=	x"FFFF";					
				CRC_error           <=  '0';
				std_error           <=  '0';
				packet_received     <=  '0';	
				NumOfBytesExpected  <= (others=>'0');
				dynamic_stream      <= '0';	
				IP_pckt             <= '0';
			--------------------------------------------------------------
			else
				bad_packet	      <='0';
				good_packet       <='0';
				start_valid_int	  <='0';
				Headers_valid_int <='0';
				data_valid_int    <='0';
				Footers_valid_int <='0';
				IP_pckt_valid_int <='0';
				CRC_valid_int     <='0';
				CRC_error         <='0';
				std_error         <='0';
				cnt_crc 	      <=0;
				packet_received   <='0';
	--------------------------------------------------------------------------------------------			
				if channel_data_locked_vec(3)='1' then	
					
					case channel_data_sm is
													
						When Idle       	=>  
												cnt_header 	   <= 0; 
												cnt_data 	   <= (others=>'0'); 
												cnt_footer 	   <= 0  ; 
												cnt_crc 	   <= 0  ;										
												good_packet	   <= '0';
												bad_packet	   <= '0';											
												crc_calc	   <= x"FFFF"; 																														
												channel_data_sm<= w4start1;
												dynamic_stream <= '0';
												IP_pckt        <= '0';
	--------------------------------------------------------------------------------------------											
						when w4start1		=> 	if RX_det_sync_s=StartWord then 					
													channel_data_sm	<=	w4start2;
													start_valid_int	<=	'1';
													crc_calc		<=	nextCRC16_D8(RX_det_sync_s,crc_calc);												
												elsif RX_det_sync_s=Idle_WORD then 											
													channel_data_sm <= w4start1; 
												else 
													channel_data_sm <=end_werr; 
												end if;											
												dynamic_stream <= '0';
	--------------------------------------------------------------------------------------------											
						when w4start2		=>	if RX_det_sync_s=IP_WORD then
													IP_pckt<='1';
													channel_data_sm <= Data_st;
													crc_calc		<=	nextCRC16_D8(RX_det_sync_s,crc_calc);
												elsif RX_det_sync_s=Stream_type1 or RX_det_sync_s=Stream_type2  then
													if RX_det_sync_s=Stream_type2 then
														dynamic_stream<='1';
													else 
														dynamic_stream<='0';
													end if;													
													start_valid_int	<=	'1';												
													crc_calc		<=	nextCRC16_D8(RX_det_sync_s,crc_calc);												
													if NumHeaderBytes =0 and NumDataBytes=0 and NumFooterBytes=0  then
														channel_data_sm <= CRC;
													elsif NumHeaderBytes =0 and NumDataBytes=0 then
														channel_data_sm <= Footers;									
													elsif NumHeaderBytes =0 then
														channel_data_sm <= Data_st;	
													else
														channel_data_sm <= Headers;
													end if;												
												else
													channel_data_sm<=end_werr;
												end if;
	--------------------------------------------------------------------------------------------------------											
						when Headers 		=>  if  cnt_header>=(NumHeaderBytes-1)  then											
													channel_data_sm<=Data_st;
													cnt_header<=0;
													if NumDataBytes =0 and NumFooterBytes=0 then
														channel_data_sm <= CRC;
													elsif NumDataBytes =0 then
														channel_data_sm <= Footers;
													end if;																														
												else
													cnt_header<=cnt_header+1;
												end if;
												
												if dynamic_stream='1' and cnt_header>=0 and cnt_header<=3 then
													NumOfBytesExpected<=RX_det_sync_s & NumOfBytesExpected(31 downto 8);
												end if;
												Headers_valid_int	<=	'1';									
												crc_calc			<=	nextCRC16_D8(RX_det_sync_s,crc_calc);															
	-----------------------------------------------------------------------------------------------------------																																									
						when Data_st		=>  if  (cnt_data>=(NumDataBytes-1) and dynamic_stream='0') or (cnt_data>=(NumOfBytesExpected-1) and dynamic_stream='1') or IP_pckt='1'  then																							
													cnt_data <= (others=>'0');
													dynamic_stream<='0';
													if NumFooterBytes=0 or IP_pckt='1' then
													channel_data_sm	<= CRC	;
													else
														channel_data_sm	<=	footers;												
													end if;																										
												else
													cnt_data<=cnt_data+1;										
												end if;	
												
												if IP_pckt='0' then 
													data_valid_int<='1';
												else 
													IP_pckt_valid_int  <='1';
												end if;
												crc_calc	<=	nextCRC16_D8(RX_det_sync_s,crc_calc);
											
						when footers 		=>  if  cnt_footer>=(NumFooterBytes-1)  then											
													channel_data_sm<=CRC;
													cnt_footer<=0;
												else
													cnt_footer<=cnt_footer+1;
												end if;
												Footers_valid_int	<=	'1';	
												crc_calc			<=	nextCRC16_D8(RX_det_sync_s,crc_calc);
	------------------------------------------------------------------------------------------------------------															
						when CRC        	=>  if  cnt_crc=2  then											
													channel_data_sm	<=	end_st;
													packet_received<='1';
													if crc_calc =x"0000" then											
														good_packet	<=	'1';
														crc_calc<=x"FFFF";
													else 
														channel_data_sm	<=	end_werr;
														bad_packet	<=	'1';
													end if;	
												else
													cnt_crc<=cnt_crc+1;										
												end if;
												
												if cnt_crc<2 then
													crc_calc<=nextCRC16_D8(RX_det_sync_s,crc_calc);										
													CRC_valid_int<='1'; 
												end if;	
	----------------------------------------------------------------------------------------------------------																															
						when end_werr 		=>										    
												good_packet		<=	'0';
												channel_data_sm	<=	end_st; 
												if bad_packet='1' then
													CRC_error<='1';
												else
													STD_error<='1';
												end if;
																					
						when  end_st		=>	channel_data_sm	<=	Idle; 
		
						when  others 		=>	channel_data_sm	<=	Idle; 
	------------------------------------------------------------------------------------------------------------																			    				
					end case;
				else
					bad_packet	      <='0';
					good_packet       <='0';
					start_valid_int	  <='0';
					Headers_valid_int <='0';
					data_valid_int    <='0';
					Footers_valid_int <='0';
					IP_pckt_valid_int <='0';
					IP_pckt           <='0';
					CRC_valid_int     <='0';
					CRC_error         <='0';
					std_error         <='0';
					cnt_crc 	      <=0;
					channel_data_sm   <=idle;						
				end if;	
			end if;		
		end if;
	end process; 
---------------------------------------------------------------------------------------------------------- 
 start_valid            <=  start_valid_int;
 Headers_valid          <= 	Headers_valid_int;
 data_valid 	        <=  data_valid_int;         
 Footers_valid 	        <= 	Footers_valid_int; 
 IP_pckt_valid          <=  IP_pckt_valid_int;
 RX_det_o		        <=	RX_det_sync_ss;  
 good_packet_received   <=  good_packet;
 bad_packet_received    <=  bad_packet;
---------------------------------------------------------------------------------------------------------
IDLY_CE <='0'; --IDELAYE3 CE
IDLY_INC<='0'; --IDELAYE3 Tap Increment
CNTVALUEIN_std <= std_logic_vector (to_unsigned(CNTVALUEIN,CNTVALUEIN_std'length));
----------------------------------------------------------
IDELAYE3_inst : IDELAYE3
generic map (
CASCADE 		 => "NONE", 	       -- Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
DELAY_FORMAT     => "COUNT", 	       -- Units of the DELAY_VALUE (COUNT, TIME)
DELAY_SRC        => "IDATAIN",         -- Delay input (DATAIN, IDATAIN)
DELAY_TYPE       => "VAR_LOAD",        -- Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
DELAY_VALUE      => 0,                 -- Input delay value setting
IS_CLK_INVERTED  => '0',               -- Optional inversion for CLK
IS_RST_INVERTED  => '0',               -- Optional inversion for RST
REFCLK_FREQUENCY => 300.0,             -- IDELAYCTRL clock input frequency in MHz (200.0-2667.0)
SIM_DEVICE       => "ULTRASCALE_PLUS", -- Set the device version (ULTRASCALE, ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1,
								       -- ULTRASCALE_PLUS_ES2)
UPDATE_MODE      => "ASYNC"            -- Determines when updates to the delay will take effect (ASYNC,MANUAL,SYNC)
)
port map (
CASC_OUT 		 => open,              -- 1-bit output: Cascade delay output to ODELAY input cascade
CNTVALUEOUT 	 => open,              -- 9-bit output: Counter value output
DATAOUT 		 => sDataInDly,        -- 1-bit output: Delayed data output
CASC_IN 		 => '0',               -- 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
CASC_RETURN      => '0',               -- 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
CE               => IDLY_CE,           -- 1-bit input: Active high enable increment/decrement input
CLK              => CLKDIV,            -- 1-bit input: Clock input
CNTVALUEIN       => CNTVALUEIN_std,    -- 9-bit input: Counter value input
DATAIN           => '0',               -- 1-bit input: Data input from the logic
EN_VTC           => '0',               -- 1-bit input: Keep delay constant over VT
IDATAIN          => sDataIn,           -- 1-bit input: Data input from the IOBUF
INC              => IDLY_INC,          -- 1-bit input: Increment / Decrement tap delay input
LOAD             => IDLY_LD,           -- 1-bit input: Load DELAY_VALUE input
RST              => RESET               -- 1-bit input: Asynchronous Reset to the DELAY_VALUE
);
-- End of IDELAYE3_inst instantiation
-------------------------------------
FCLK_inv <= not FCLK;
-------------------------------------
-- ISERDESE3: Input SERial/DESerializer
-- UltraScale
-- Xilinx HDL Language Template, version 2018.1
ISERDESE3_inst : ISERDESE3
generic map (
DATA_WIDTH        => 8,                -- Parallel data width (4,8)
FIFO_ENABLE       => "FALSE",          -- Enables the use of the FIFO
FIFO_SYNC_MODE    => "FALSE",          -- Enables the use of internal 2-stage synchronizers on the FIFO
IS_CLK_B_INVERTED => '0',              -- Optional inversion for CLK_B
IS_CLK_INVERTED   => '0',              -- Optional inversion for CLK
IS_RST_INVERTED   => '0',              -- Optional inversion for RST
SIM_DEVICE        => "ULTRASCALE_PLUS" -- Set the device version (ULTRASCALE,ULTRASCALE_PLUS,ULTRASCALE_PLUS_ES1,ULTRASCALE_PLUS_ES2)
)
port map (
FIFO_EMPTY        => open,               -- 1-bit output: FIFO empty flag
INTERNAL_DIVCLK   => open,               -- 1-bit output: Internally divided down clock used when FIFO is
                                       -- disabled (do not connect)
									   
Q                 => ByteSlp_REG0,       -- 8-bit registered output
CLK               => FCLK,               -- 1-bit input: High-speed clock
CLKDIV            => CLKDIV,             -- 1-bit input: Divided Clock
CLK_B             => FCLK_inv,           -- 1-bit input: Inversion of High-speed clock CLK
D                 => sDataInDly,         -- 1-bit input: Serial Data Input
FIFO_RD_CLK       => '0',                -- 1-bit input: FIFO read clock
FIFO_RD_EN        => '0',                -- 1-bit input: Enables reading the FIFO when asserted
RST               => RESET                -- 1-bit input: Asynchronous Reset
);
-- End of ISERDESE3_inst instantiation
----------------------------------------------------------------------------

SliceISERDES_q: for slice_count in 0 to ParallelWidth-1 generate begin    	
--pDataIn(slice_count) <= pDataIn_q(ParallelWidth-slice_count-1);
--pDataIn(slice_count) <= pDataIn_q(slice_count); 
	pDataIn(slice_count) <= ByteSlp_REG2(slice_count); 
end generate SliceISERDES_q;
----------------------------------------------------------------------------
process (CLKDIV)
begin

	if CLKDIV'event and CLKDIV='1' then
		if RESET ='1' then
			Bitslip <='0';
			IDLY_LD <='0'; 
			Channel_RDY_stable <= (others=>'0');
			Channel_OK<='0';
			delay_cnt <="000";
			change_det <='0';
			cnt_idle_byte<=0;
			delay_cnt_byte<=0;
			Channel_data_locked_int<='0';
			sm4sync<=idle;
			CNTVALUEIN<=0;
			pDataIn_prev<= (others=>'0');
			RX_det_sync <= (others=>'1');
		--------------------------------------------------------
		else
			IDLY_LD<='0';
			Channel_RDY_stable<= Channel_RDY_stable(2 downto 0) & Channel_RDY;
			if Channel_RDY_stable(3 downto 2) ="11" then
			Channel_OK<='1';
			else
			Channel_OK<='0';
			end if;
	-------------------------------------------------------------------------------------------------------------------
			if Channel_OK='1' then
				case sm4sync is
				when idle           =>	    cnt_idle_byte<=0;
											delay_cnt_byte<=0;
											sm4sync <=clocks_rdy ;
											IDLY_LD<='1';
											CNTVALUEIN<=0;										
											delay_cnt<="000";
											change_det<='0';

				when clocks_rdy     =>   	IDLY_LD<='0';
											if delay_cnt=delay_cnt_value then
												sm4sync<=Bit_align;
												delay_cnt<="000";
											else
												delay_cnt<=delay_cnt+1;
											end if;

				when Bit_align      =>  	IDLY_LD<='0';
											sm4sync<= set_load;
											
											if change_det ='0' then
												sm4sync<= set_load;
												if CNTVALUEIN=511 then
													CNTVALUEIN_t<=256;
													sm4sync <= pre_byte_align;
												else
													CNTVALUEIN<= CNTVALUEIN+1;
													sm4sync<= set_load;
												end if;
											else
												change_det <='0';
												sm4sync<= pre_byte_align;
												if CNTVALUEIN< 256 then										
													CNTVALUEIN_t<=CNTVALUEIN+256;
												else
													CNTVALUEIN_t<=CNTVALUEIN-256;
												end if;
											end if;
											pDataIn_prev<= pDataIn;
											delay_cnt<="000";
											
				when set_load       =>  	IDLY_LD<='1';
											CNTVALUEIN<=CNTVALUEIN;
											sm4sync<= wait_st;
											
				when wait_st   		=>	  	IDLY_LD<='0';
											delay_cnt<=delay_cnt+1;
											
											if delay_cnt=delay_cnt_value then
												sm4sync<= Bit_align;
												if pDataIn_prev = pDataIn then
													delay_cnt<="000";
													change_det <='0';
												else
													change_det <='1';
													delay_cnt<="000";
												end if;
											end if;
																															
				when pre_byte_align =>		case delay_cnt is 
											when "000" => delay_cnt<=delay_cnt+1;   
														if CNTVALUEIN_t > CNTVALUEIN  then
															delay_cnt <="010";     
															if CNTVALUEIN_t >= CNTVALUEIN + 8 then
															CNTVALUEIN<= CNTVALUEIN+8;
															else
															CNTVALUEIN<= CNTVALUEIN+1;
															end if;
														end if;
											when "001" => delay_cnt<=delay_cnt+1;
														if CNTVALUEIN_t < CNTVALUEIN  then
															if CNTVALUEIN_t <= CNTVALUEIN - 8 then
															CNTVALUEIN<= CNTVALUEIN-8;
															else
															CNTVALUEIN<= CNTVALUEIN-1;
															end if;
														end if;
														delay_cnt<=delay_cnt+1;
											when "010" => IDLY_LD<='1';delay_cnt<=delay_cnt+1;
											when "011" => IDLY_LD<='0';delay_cnt<=delay_cnt+1;
											when "100" => IDLY_LD<='0';delay_cnt<=delay_cnt+1;
											when "101" => IDLY_LD<='0';delay_cnt<=delay_cnt+1;
											when "110" => IDLY_LD<='0';delay_cnt<=delay_cnt+1;
											when "111" => delay_cnt <= "000";
														if CNTVALUEIN_t=CNTVALUEIN then														
															sm4sync <= byte_align; 														
														end if;
											when others=> IDLY_LD<='0';delay_cnt<=delay_cnt+1;			  
											end case;			  

				when byte_align 	=>  	if pDataIn = IDLE_WORD then
												if (cnt_idle_byte < 7) then 
													cnt_idle_byte <= cnt_idle_byte+1;
												end if;
											else
												cnt_idle_byte	<=0;
											end if;
											
											if (delay_cnt_byte < 15) then
												delay_cnt_byte<=delay_cnt_byte+1;
											end if;
											
											if cnt_idle_byte = cnt_num_byte then
												sm4sync	<=	synced;
												delay_cnt_byte		<=	0;
												cnt_idle_byte		<=	0;
											elsif delay_cnt_byte = delay_num then
												sm4sync	<= 	look_for_sync;
												delay_cnt_byte		<=	0;
											end if;

				when look_for_sync	=>		Bitslip	<=	'1';
											sm4sync			<= 	wait_for_sync;
											Channel_data_locked_int		<=	'0';

				when wait_for_sync	=>		Bitslip	<=	'0';
											Channel_data_locked_int		<=	'0';
											
											if (delay_cnt_byte < 15) then 
												delay_cnt_byte	<=	delay_cnt_byte+1;
											end if;
											
											if pDataIn = IDLE_WORD then
												if (cnt_idle_byte < 7) then 
												cnt_idle_byte	<=cnt_idle_byte+1;
												end if;
											else
												cnt_idle_byte<=0;
											end if;

											if cnt_idle_byte=cnt_num_byte then
												sm4sync<=synced;

											elsif delay_cnt_byte = delay_num then
												sm4sync<= look_for_sync;
												delay_cnt_byte<=0;
											end if;

				when synced	        =>		channel_data_locked_int	<='1';
											cnt_idle_byte			<=0;
											change_det              <='0';

				end case;
			else
				Bitslip <='0';
				IDLY_LD <='0';
				delay_cnt <="000";
				change_det <='0';
				cnt_idle_byte <=0;
				delay_cnt_byte <=8;
				channel_data_locked_int <='0';
				sm4sync <=idle;
				CNTVALUEIN <=0;
				pDataIn_prev <= (others=>'0');           
			end if;

			--------------------------------------------------------------------------------------------------------------------
			if channel_data_locked_int ='1' then
			RX_det_sync<= pDataIn;
			else
			RX_det_sync<= (others=>'1');
			end if;
		end if;
	end if;
end process;

CHANNEL_DATA_LOCKED <= channel_data_locked_int;
process (CLKDIV)
begin

	if CLKDIV'event and CLKDIV='1' then
		if RESET ='1' then
			bit_slp_value <="000";
			ByteSlp_REG1  <=(others=>'0');
			ByteSlp_REG2  <=(others=>'0');
		-----------------------------------------------------------
		else
			ByteSlp_REG1<=ByteSlp_REG0	;	
			if Bitslip ='1' then		   
			if bit_slp_value="111" then
					bit_slp_value<="000";
				else
					bit_slp_value<=bit_slp_value+1; 
			end if;	 
			end if;
			
			case bit_slp_value is
				when "000"    => 	ByteSlp_REG2<= ByteSlp_REG1;    
				when "001"    => 	ByteSlp_REG2<= ByteSlp_REG0(0)          & ByteSlp_REG1(7 downto 1);
				when "010"    => 	ByteSlp_REG2<= ByteSlp_REG0(1 downto 0) & ByteSlp_REG1(7 downto 2);
				when "011"    => 	ByteSlp_REG2<= ByteSlp_REG0(2 downto 0) & ByteSlp_REG1(7 downto 3);
				when "100"    => 	ByteSlp_REG2<= ByteSlp_REG0(3 downto 0) & ByteSlp_REG1(7 downto 4);
				when "101"    => 	ByteSlp_REG2<= ByteSlp_REG0(4 downto 0) & ByteSlp_REG1(7 downto 5);
				when "110"    => 	ByteSlp_REG2<= ByteSlp_REG0(5 downto 0) & ByteSlp_REG1(7 downto 6);
				when "111"    => 	ByteSlp_REG2<= ByteSlp_REG0(6 downto 0) & ByteSlp_REG1(7);
				when others   => 	ByteSlp_REG2<= ByteSlp_REG1;  
			end case;		
		end if;						
	end if;
end process;																		
 
END architecture behave;
