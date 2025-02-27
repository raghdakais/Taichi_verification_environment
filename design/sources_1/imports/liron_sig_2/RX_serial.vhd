--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
-------------------------------------------------------------------------------
ENTITY RX_serial IS
    Generic (
          	  
	  NumDataBits   : natural := 32;
	  cnt_clk_max   : natural := 4	  
	  );
    PORT( 
        RESET       		    : IN    std_logic;
        CLK          	        : IN    std_logic;	
		serial_in               : IN    std_logic;		 													
		valid_RX_VEC            : OUT   std_logic_vector (NumDataBits-1 downto 0);				
		packet_received         : OUT   std_logic;
		good_packet             : OUT   std_logic;
		bad_packet              : OUT   std_logic			
    	);
END RX_serial;
-------------------------------------------------------------------------------------
ARCHITECTURE behave OF RX_serial IS
--------------------------------------------------------------------------------------
function nextCRC8_D1
    (d          : std_logic_vector(0 downto 0);
     c          : std_logic_vector(7 downto 0))
    return std_logic_vector is

    variable data   :  std_logic_vector(0 downto 0);
    variable crcIn  :  std_logic_vector(7 downto 0);
    variable crcOut :  std_logic_vector(7 downto 0);

  begin
    data  := d;
    crcIn := c;

    crcOut(0) := (crcIn(7) xor data(0));
    crcOut(1) := (crcIn(0) xor crcIn(7) xor data(0));
    crcOut(2) := (crcIn(1) xor crcIn(7) xor data(0));
    crcOut(3) := crcIn(2);
    crcOut(4) := crcIn(3);
    crcOut(5) := crcIn(4);
    crcOut(6) := crcIn(5);
    crcOut(7) := crcIn(6);
    return crcOut;
  end nextCRC8_D1;

------------------------------------------------------------------------------------
type sm_state1 is (idle,Train_in,CRC_Train_IN,IS_Train_OK,Data_vaid,BAD_IDLE);
------------------------------------------------------------------------------------

	SIGNAL serial_in_vec               : std_logic_vector (4 downto 0);		 	
	SIGNAL crc_calc                    : std_logic_vector (7 downto 0):=x"FF";		
	SIGNAL bit_cnt                     : natural range 0 to 255;
    SIGNAL cnt_clk                     : natural range 0 to 15;
    signal RX_SM                       : sm_state1;
	signal RX_VEC,valid_RX_VEC_int     : std_logic_vector (NumDataBits-1 downto 0);
	signal good_packet_int             : std_logic;	
	signal bad_packet_int              : std_logic;	
	signal packet_received_int         : std_logic;	
	signal good_packet_int_s           : std_logic;
	signal bad_packet_int_s            : std_logic;
	signal packet_received_int_s       : std_logic;
	
	
-----------------------------------------------------------------------------------
BEGIN
-----------------------------------------------------------------------------------
	process(RESET,CLK)
	begin
		if (RESET = '1') then
			serial_in_vec <= (others=>'1');							
		elsif rising_edge(CLK) then
		    serial_in_vec <= serial_in_vec(3 downto 0)& serial_in;		
				if  serial_in_vec (4 downto 3)="01" and RX_SM=IDLE then
					cnt_clk <= 0;
				else 
					if cnt_clk>= cnt_clk_max-1 then
					cnt_clk<=0;
					else   
					cnt_clk<=cnt_clk+1;
					end if;
				end if;			
		end if;			
	end process; 
----------------------------------------------------------------------------------	
	process(RESET,CLK)
	begin
		
	    if RESET ='1' then
			RX_SM<=IDLE;
			bit_cnt<=0;
			good_packet_int <='0';
			bad_packet_int  <='0';
			packet_received_int <= '0';
			
			good_packet_int_s <='0';
            bad_packet_int_s  <='0';
            packet_received_int_s <= '0';
			
			crc_calc <=x"ff";
            RX_VEC <= (others=>'1');
			valid_RX_VEC<=(others=>'0');
			valid_RX_VEC_int<=(others=>'0');
			good_packet<='0';
			bad_packet <='0'; 
			packet_received <='0';			
		elsif rising_edge(CLK) then
			good_packet_int     <= '0';
			bad_packet_int      <= '0';
            packet_received_int <= '0';
			 								
			good_packet_int_s         <= good_packet_int;	
			bad_packet_int_s          <= bad_packet_int ;
			packet_received_int_s     <= packet_received_int;
			
			good_packet    <= good_packet_int_s     ;
			bad_packet     <= bad_packet_int_s      ;
			packet_received<= packet_received_int_s ;
			
			
			if packet_received_int='1' and  good_packet_int='1' then 
				valid_RX_VEC_int    <= RX_VEC;		
			end if;
			valid_RX_VEC <= valid_RX_VEC_int;
							
--------------------------------------------------------------------------------------------										
				case RX_SM is
												
					When Idle       	=>  if serial_in_vec (4 downto 3)="01" then
					                           RX_SM<=Train_in;
											   bit_cnt<=0;
											end if;
											crc_calc <=x"ff";
--------------------------------------------------------------------------------------------											
					when Train_in		=>  if cnt_clk=cnt_clk_max/2-1 then
										    RX_VEC   <= RX_VEC(NumDataBits-2 downto 0)&serial_in_vec(4);												
											bit_cnt<=bit_cnt+1;
											end if;
											
											if bit_cnt >= NumDataBits+1 then
											 RX_SM<=CRC_Train_IN;
											 bit_cnt<=0;											 
											end if;
											
											if cnt_clk=cnt_clk_max/2-1 and  bit_cnt/=0 then									    
											crc_calc <=	nextCRC8_D1(serial_in_vec(4 downto 4),crc_calc);											
											end if;											
--------------------------------------------------------------------------------------------											
					when CRC_Train_IN   =>	if cnt_clk=cnt_clk_max/2-1 then													
												crc_calc <=	nextCRC8_D1(serial_in_vec(4 downto 4),crc_calc);
												bit_cnt<=bit_cnt+1;
											end if;
					                        if bit_cnt >= 8 then
												RX_SM<=IS_Train_OK;
												bit_cnt<=0;
											end if; 	
--------------------------------------------------------------------------------------------------------											
					when IS_Train_OK    =>  if crc_calc =x"00"  then
												good_packet_int <='1';												
											else	
												bad_packet_int <='1' ;    
										    end if;	
											packet_received_int <='1';
											RX_SM <= Data_vaid;
-----------------------------------------------------------------------------------------------------------																																									
					when Data_vaid		=>  if good_packet_int='1' then
					                            valid_RX_VEC_int<=RX_VEC;
												RX_SM <= Idle;
											else
											    RX_SM <= BAD_IDLE;
										    end if;											
					when BAD_IDLE		=>  RX_SM <= Idle;					                        																					             											
------------------------------------------------------------------------------------------------------------																																																				
					when  others 		=>	RX_SM	<=	Idle; 
------------------------------------------------------------------------------------------------------------																			    				
				end case;			
		end if;
	end process; 

END architecture behave;
