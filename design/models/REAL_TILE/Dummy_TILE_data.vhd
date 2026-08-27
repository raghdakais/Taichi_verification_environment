--

--
-- Created:
--          by - ilq00571.UNKNOWN (ILQHFAATC1WS159)
--          at - 17:44:18 11/12/2006
--
-- using Mentor Graphics HDL Designer(TM) 2005.3 (Build 74)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.Phoebe.all;

ENTITY Dummy_TILE_data IS
   Generic ( --Bytes_per_det  : IN     integer range 3 to 5;
			 IDLE_WORD      : IN     std_logic_vector (7 downto 0);
			 START_WORD     : IN     std_logic_vector (39 downto 0);
			 optional_footer: IN     std_logic
);			 
   PORT( 
     Bytes_per_det     : IN     integer range 3 to 5;
	 RESET            : IN     std_logic;    
	 ACLK              : IN     std_logic;
	 SYNC              : IN     std_logic;
     DISCARD           : IN     std_logic;
     CLKDIV     	   : IN     std_logic;	 	  
	 DUMMY_DATA        : OUT    std_logic_vector (7 downto 0);
	 DATA_valid        : OUT    std_logic;
	 SCSn	           : IN	    std_logic;
	 SDI	           : IN	    std_logic;
	 SCLK              : IN	    std_logic;
	 SDO 	           : OUT	std_logic
   );

-- Declarations

END Dummy_TILE_data ;

--
ARCHITECTURE behave OF Dummy_TILE_data IS

Signal DATA_counter     : std_logic_vector (7 downto 0) ;
Signal bytes_cnt        :   integer range 0 to 7;
type   sm_type          is (idle,start_word1,start_word2,start_word3,start_word4,start_word5,data,footer1,footer2,footer3,footer4,footer5,footer6,CRC);
SIGNAL asic_data_sm     : sm_type	;
SIGNAL asic_data_sm_d   : sm_type	; 
SIGNAL SYNC_s           : std_logic_vector (3 downto 0);
Signal crc_calc         : std_logic_vector (15 downto 0):=x"FFFF" ;
Signal SYNC_d           : std_logic;
Signal RX_det_sync      : std_logic_vector (7 downto 0) ;
Signal RX_det_sync_o    : std_logic_vector (7 downto 0) ; 
Signal shift_bits_in    : std_logic_vector (31 downto 0) :=x"00000000" ;	
Signal shift_bits_out   : std_logic_vector (31 downto 0) :=x"00000000" ;
signal SDO_int          : std_logic;
signal parity           : std_logic:='0';
signal DATA_valid_int   : std_logic:='0';
--signal DATA_valid       : std_logic:='0';
BEGIN
---------------------------------------------
PROCESS (RESET,ACLK)
                                                                                                                                                                                                
    BEGIN
	if RESET='1' then
		SYNC_d<='0';	
	elsif rising_edge (ACLK) then 
		SYNC_d<=SYNC;
	end if;
end process;	
---------------------------------------------

 PROCESS (RESET,CLKDIV)
                                                                                                                                                                                                
    BEGIN
	if RESET='1' then
		RX_det_sync  <= (others=>'0');
		asic_data_sm <= idle ;
		asic_data_sm_d <= idle ;
		SYNC_s       <= (others=>'0');
		DATA_counter <= (others=>'0');
		RX_det_sync_o<= (others=>'0');
		crc_calc<=x"FFFF";
		DATA_valid_int<='0';
		DATA_valid<='0';
		--DUMMY_DATA<=(others=>'0');
	elsif rising_edge (CLKDIV) then
		SYNC_s<= SYNC_s(2 downto 0)&SYNC_d;	
		asic_data_sm_d<=asic_data_sm;
		if asic_data_sm_d = crc then
			RX_det_sync_o<=crc_calc(7 downto 0);
			crc_calc(7 downto 0)<=crc_calc(15 downto 8);
			crc_calc(15 downto 8)<=(others=>'0');
			--RX_det_sync_o<=crc_calc(15 downto 8);
			--crc_calc(15 downto 8)<=crc_calc(7 downto 0);
			--crc_calc(7 downto 0)<=(others=>'0');
		elsif asic_data_sm_d /= idle and  asic_data_sm_d /= crc then
			RX_det_sync_o<=RX_det_sync;			
		else
			RX_det_sync_o<=RX_det_sync;
		end if;			
		DATA_valid_int<='0';
		DATA_valid<=DATA_valid_int;
-------------------------------------------------------------------		
		if asic_data_sm_d /= idle and  asic_data_sm_d /= crc then
			crc_calc<=nextCRC16_D8(RX_det_sync,crc_calc);
		end if;
-------------------------------------------------------------------		
		case asic_data_sm is
		
		when idle 			=> 	RX_det_sync<= IDLE_WORD;
								crc_calc<=x"FFFF";
								if SYNC_s (2 downto 1) ="01" then
								asic_data_sm <= START_WORD1;
								end if;
								
-----------------------------------------------------------------------
		when START_WORD1 	=>  RX_det_sync<= START_WORD(7 downto 0);
								asic_data_sm <= START_WORD2;
-----------------------------------------------------------------------								
		when START_WORD2 	=>  RX_det_sync<= START_WORD(15 downto 8);
								asic_data_sm <= START_WORD3;
-----------------------------------------------------------------------								
		when START_WORD3 	=>  RX_det_sync<= START_WORD(23 downto 16);
								if Bytes_per_det=3 then
								asic_data_sm <= DATA;
								elsif Bytes_per_det>=3 then
								asic_data_sm <= START_WORD4;
								end if;	
-----------------------------------------------------------------------								
		when START_WORD4 	=>  RX_det_sync<= START_WORD(31 downto 24);
								if Bytes_per_det=4 then
								asic_data_sm <= DATA;
								elsif Bytes_per_det>=4 then
								asic_data_sm <= START_WORD5;
								end if;	
------------------------------------------------------------------------								
		when START_WORD5 	=>  RX_det_sync<= START_WORD(39 downto 32);
								asic_data_sm <= DATA;
------------------------------------------------------------------------								
		when DATA           =>  RX_det_sync <= DATA_counter;
								DATA_valid_int<='1';
								if DATA_counter=x"FF" and bytes_cnt=Bytes_per_det-1 then					
								asic_data_sm <= Footer1;
								DATA_counter <= x"F1";
								bytes_cnt<=0;
								elsif bytes_cnt=Bytes_per_det-1 then
								DATA_counter<=DATA_counter+1;								
								bytes_cnt<=0;
								else
								bytes_cnt<=bytes_cnt+1;
								end if;								
------------------------------------------------------------------------								
		when Footer1         => RX_det_sync <= DATA_counter;             								
								if bytes_cnt=Bytes_per_det-1 then
								DATA_counter <= x"F2";
								asic_data_sm <= Footer2;
								bytes_cnt<=0;
								else
								bytes_cnt<=bytes_cnt+1;
								end if;
		when Footer2         =>  RX_det_sync <= DATA_counter;             								
								if bytes_cnt=Bytes_per_det-1 then
								DATA_counter <= x"F3";
								bytes_cnt<=0;
									if optional_footer='1' then
										asic_data_sm <= Footer3;
									else
										asic_data_sm <= CRC;
									end if;									
								else
								bytes_cnt<=bytes_cnt+1;
								end if;
		when Footer3         => RX_det_sync <= DATA_counter;             								
								if bytes_cnt=Bytes_per_det-1 then
								DATA_counter <= x"F4";
								asic_data_sm <= Footer4;
								bytes_cnt<=0;
								else
								bytes_cnt<=bytes_cnt+1;
								end if;
        when Footer4         => RX_det_sync <= DATA_counter;             								
								if bytes_cnt=Bytes_per_det-1 then
								DATA_counter <= x"F5";
								asic_data_sm <= Footer5;
								bytes_cnt<=0;
								else
								bytes_cnt<=bytes_cnt+1;
								end if;

		when Footer5         => RX_det_sync <= DATA_counter;             								
								if bytes_cnt=Bytes_per_det-1 then
								DATA_counter <= x"F6";
								asic_data_sm <= Footer6;
								bytes_cnt<=0;
								else
								bytes_cnt<=bytes_cnt+1;
								end if;
		when Footer6         => RX_det_sync <= DATA_counter;             								
								if bytes_cnt=Bytes_per_det-1 then
								DATA_counter<=x"00";
								asic_data_sm <= CRC;
								bytes_cnt<=0;
								else
								bytes_cnt<=bytes_cnt+1;
								end if;

------------------------------------------------------------------------								
		when CRC =>    			RX_det_sync<=x"CC";
								if bytes_cnt=Bytes_per_det-1 then
									asic_data_sm <= idle;
									bytes_cnt<=0;
								else
									bytes_cnt<=bytes_cnt+1;	
								end if;	
--------------------------------------------------------------------------		 
		end case;
	end if;
end process;	
DUMMY_DATA<=RX_det_sync_o;		 

PROCESS (SCSn,SCLK)
                                                                                                                                                                                                
    BEGIN
	-- if SCSn='1' then		
		-- shift_bits_out<=shift_bits_in;
	if rising_edge (SCLK) then		
		if SCSn='0' then
		shift_bits_in<= shift_bits_in(30 downto 0) & SDI;
		parity <= nextCRC1_D1(SDI,parity);
		end if;
	end if;
end process;	

PROCESS (SCSn,SCLK)
                                                                                                                                                                                                
    BEGIN
	if SCSn='1' then
		SDO_int<='Z';
       shift_bits_out<=shift_bits_in;		
	elsif falling_edge (SCLK) then		
		if SCSn='0' then
		shift_bits_out<=  shift_bits_out(30 downto 0) & '0';
		SDO_int<= shift_bits_out(31);
		end if;
	end if;
end process;
SDO<=SDO_int;




END ARCHITECTURE behave;

