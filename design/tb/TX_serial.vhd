LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
-------------------------------------------------------------------------------------
ENTITY TX_serial IS
              	  
Generic (NumDataBits   : natural range 0 to 255 := 32;
	     cnt_clk_max   : natural range 0 to 15  := 4	  
	     );
    PORT( 
        RESET       		    : IN   std_logic;
        CLK          	        : IN   std_logic;	
		serial_out              : OUT  std_logic;		 													
		valid_TX_VEC            : IN   std_logic_vector (NumDataBits-1 downto 0);
		TRIG                    : IN   std_logic
					
    	);
END TX_serial;

ARCHITECTURE behave OF TX_serial IS
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
type sm_state1 is (idle,TRIGGER,Train_OUT,CRC_Train_OUT,Train_END);
--------------------------------------------------------------------------------------------------------------------
	SIGNAL serial_out_vec                 : std_logic_vector (2 downto 0);
	SIGNAL serial_out_i                   : std_logic_vector (0 downto 0);
	SIGNAL crc_calc,crc_calc_f            : std_logic_vector (7 downto 0):=x"FF";		
	SIGNAL bit_cnt                        : natural range 0 to 255;
    SIGNAL cnt_clk                        : natural range 0 to 15;
	signal valid_TX_VEC_s,valid_TX_VEC_ss : std_logic_vector (NumDataBits-1 downto 0);
	signal TX_VEC                         : std_logic_vector (NumDataBits-1 downto 0);
	signal TRIG_s,TRIG_ss                 : std_logic;
	signal TRIG_VEC                       : std_logic_vector (2 downto 0);
	signal TX_SM                          : sm_state1;
-------------------------------------------------------------------------------
BEGIN
-------------------------------------------------------------------------------
	process(RESET,CLK)
	begin
		if (RESET = '1') then
			serial_out_vec <= (others=>'0');							
		elsif rising_edge(CLK) then
		    serial_out_vec <= serial_out_vec(1 downto 0)& serial_out_i(0);
				if TRIG_vec(2 downto 1) ="01" then
					cnt_clk<=0;
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
serial_out<=serial_out_vec(2);	
----------------------------------------------------------------------------------	
	process(RESET,CLK)
	begin
		
	    if RESET ='1' then
			TX_SM<=IDLE;
			bit_cnt<=0;								   
			crc_calc <=x"ff";
            TX_VEC   <= (others=>'1');
			valid_TX_VEC_s<=(others=>'1');
			valid_TX_VEC_ss<=(others=>'1');			
            TRIG_vec <="000";
			TRIG_s<='0';
			TRIG_ss<='0';
			serial_out_i(0)<='0';
		elsif rising_edge(CLK) then
		    if TRIG='1' then
				valid_TX_VEC_s<=valid_TX_VEC;
			end if;		    
			valid_TX_VEC_ss<=valid_TX_VEC_s;
			TRIG_s<=TRIG;
			TRIG_ss<=TRIG_s;
		    TRIG_vec<=TRIG_vec(1 downto 0)& TRIG_ss;					
--------------------------------------------------------------------------------------------										
				case TX_SM is
												
					When Idle       	=>  if TRIG_vec(2 downto 1) ="01" then
												TX_SM <= Train_OUT;
												serial_out_i(0)<='1';
												TX_VEC<=valid_TX_VEC_ss;
												bit_cnt<=0;
											else
											serial_out_i(0)<='0';
											end if;
											crc_calc <=x"ff";											
												
--------------------------------------------------------------------------------------------											
					when Train_OUT		=>  if cnt_clk=cnt_clk_max-1 then					                        
												TX_VEC   <= TX_VEC(NumDataBits-2 downto 0)& '0';	
												serial_out_i(0)<=TX_VEC(NumDataBits-1);												
												bit_cnt<=bit_cnt+1;
											end if;
											if cnt_clk=0 and bit_cnt/=0 then					                        																								
												crc_calc <=	nextCRC8_D1(serial_out_i,crc_calc);											
											end if;
																						
											if bit_cnt >= NumDataBits and cnt_clk=cnt_clk_max-1 then																																														
												bit_cnt<=0;
												TX_SM<=CRC_Train_OUT;
												serial_out_i(0)<=crc_calc(7);
												crc_calc <=crc_calc(6 downto 0) &'0';
											end if;																						
--------------------------------------------------------------------------------------------------------											
					when CRC_Train_OUT  =>  
											if cnt_clk=cnt_clk_max-1 then											
												crc_calc <=	crc_calc(6 downto 0) &'0';
												bit_cnt<=bit_cnt+1;
												serial_out_i(0)<=crc_calc(7);
											end if;
											if bit_cnt >= 7 and cnt_clk=cnt_clk_max-1  then
												TX_SM<=Train_end;
												bit_cnt<=0;
											end if; 	
																																		
-----------------------------------------------------------------------------------------------------------																																									
					when Train_end		=>   TX_SM <= Idle;																									 					                        																					             											
------------------------------------------------------------------------------------------------------------																																																				
					when  others 		=>	TX_SM	<=	Idle; 
------------------------------------------------------------------------------------------------------------																			    				
				end case;			
		end if;
	end process; 
-----------------------------------------------------------------------------------------------------------
END architecture behave;