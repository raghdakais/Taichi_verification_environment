--
-- VHDL Architecture access_config_lib.prime_dec_sm.behave
--
-- Created:
--          by - ilq00571.UNKNOWN (ILQHFAATC1NB350)
--          at - 14:58:42 27/04/2011
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY prime_dec_sm IS
   PORT( 
      EXE_p           : IN     std_logic;
      PP_CRC_error    : IN     std_logic;
      SPI_busy        : IN     std_logic;
      addr_byte_p     : IN     std_logic_vector (23 DOWNTO 0);
      clk             : IN     std_logic;
      command_p       : IN     std_logic_vector (3 DOWNTO 0);
      rd_data_count   : IN     STD_LOGIC_VECTOR (6 DOWNTO 0);
      reset           : IN     std_logic;
      reset_fifo      : IN     std_logic;
      EXE             : OUT    std_logic;
      PP              : OUT    std_logic;
      addr_byte       : OUT    std_logic_vector (23 DOWNTO 0);
      busy            : OUT    std_logic;
      capture_r_crc   : OUT    std_logic;
      capture_w_crc   : OUT    std_logic;
      command         : OUT    std_logic_vector (3 DOWNTO 0);
      conf_status_reg : OUT    std_logic_vector (15 DOWNTO 0);
      num_bytes       : OUT    std_logic_vector (3 DOWNTO 0)
   );

-- Declarations

END prime_dec_sm ;

--
ARCHITECTURE behave OF prime_dec_sm IS
signal delay_counter : std_logic_vector (32 downto 0);
type sm_state is (idle,get_ready,go);
signal command_aux :std_logic_vector (3 downto 0);
signal sm : sm_state;
signal spi_busy_vec :std_logic_vector(7 downto 0);
type sm2_state is (idle,ongoing1,delay,delay2,stop,ongoing2,ongoing3,delay3);
signal sm2 : sm2_state; 
signal end_sm :std_logic;
signal start_sm2 : std_logic;
signal again :std_logic_vector (1 downto 0);
signal PP_EXE_error, PP_GT_EXE_error, ERASE_EXE_error : std_logic; 
signal exe_pvec: std_logic_vector (1 downto 0);
signal busy_int: std_logic;
signal conf_status_reg_int :std_logic_vector (15 downto 0);
signal conf_error_live :std_logic_vector (15 downto 0);
signal conf_status_live :std_logic_vector (15 downto 0);

signal one_us_cnt : natural range 0 to 32767; -- max 1 uS
signal prog_us_cnt, max_prog_us_cnt : natural range 0 to 32767; -- max 32 Sec
signal erase_sw_req_us_cnt, min_erase_sw_req_us_cnt : natural range 0 to 2**20-1; -- ~30 min
  
attribute DONT_TOUCH : string;
attribute DONT_TOUCH of prog_us_cnt, max_prog_us_cnt, command_aux, erase_sw_req_us_cnt, min_erase_sw_req_us_cnt, exe_pvec : signal is "TRUE";

attribute mark_debug : string;
attribute mark_debug of prog_us_cnt, max_prog_us_cnt, command_aux, erase_sw_req_us_cnt, min_erase_sw_req_us_cnt, exe_pvec : signal is "true";

BEGIN

process (clk,reset)
begin
	if reset ='0' then
	    spi_busy_vec <=x"00";
		delay_counter <= (others=>'0');
		EXE         <= '0';
		addr_byte   <=(others=>'0');
		command     <=(others=>'0');
		num_bytes   <=(others=>'0');
		busy_int <='0';
		sm<=idle;
		sm2 <=idle;
		end_sm <='0';
		again <="00";
		start_sm2 <='0';
		command_aux<="0000";
		PP<='0';
		capture_w_crc<='0'; 
		capture_r_crc<='0'; 
		PP_EXE_error<= '0';
        PP_GT_EXE_error <= '0';
        ERASE_EXE_error <= '0';
		exe_pvec <="00";
		conf_status_reg_int<= (others=>'0');				
	elsif clk'event and clk='1' then
		spi_busy_vec <= spi_busy_vec(6 downto 0) & spi_busy;
		start_sm2 <='0';
		capture_w_crc<='0'; 
		capture_r_crc<='0'; 
		PP_EXE_error<='0';
        ERASE_EXE_error<='0';
        PP_GT_EXE_error <= '0';
		exe_pvec<= exe_pvec(0)&exe_p;
		-----------------------------------------------------------------------------------------------------------------
		if reset_fifo ='1' then
			conf_status_reg_int (15 downto 1) <= (others=>'0');
		else	
			conf_status_reg_int (15 downto 1) <= conf_status_reg_int(15 downto 1) or conf_status_live(15 downto 1);
		end if;
		conf_status_reg_int(0)<=conf_status_live(0);
	    -----------------------------------------------------------------------------------------------------------------
		if exe_pvec = "01"  and command_p = 4 and rd_data_count < 64 then
		   PP_EXE_error<='1';
		else
		   PP_EXE_error<='0';  
		end if;   
		if exe_pvec = "01"  and command_p = 4 and rd_data_count > 64 then -- ES: 30/06/2022
		   PP_GT_EXE_error <= '1';
		else
		   PP_GT_EXE_error <= '0';  
		end if;
        -- !debug: 06/03/2023
		if (exe_pvec = "01"  and command_p = 5 and conf_status_live(0) = '1') then
		   ERASE_EXE_error<='1';
		else
		   ERASE_EXE_error<='0';  
		end if;   
        
		-------------------------------------------------------------------------------------------------------------------		
		case sm is
		when idle =>	  busy_int <='0';
						  if exe_pvec ="01" then
							addr_byte <=addr_byte_p ;
	                        command_aux <= command_p;
	                        busy_int <='1';
	                        sm <= get_ready;
	                      end if;
	                      	                        
	    when get_ready => if (PP_CRC_error = '1' or PP_EXE_error='1') and command_aux = 4 then
	    					 sm <= idle; 
	    				  else
	    				  	 sm <= go;	                     
			              end if;
						  
		when go =>        start_sm2 <='1';
						  if end_sm ='1' then
						  	sm<=idle;
						  	start_sm2 <='0';						  	
						  end if;	                                          
		                                                                      
		end case;                                                             
		--------------------------------------------------------------------------------------------------------------------                                                                      
		case sm2 is                                                           
		 when idle =>   end_sm <='0';
		 				again <="00" ;
		 				PP<='0'; 
		 				if start_sm2 ='1' then
		 				 sm2 <= ongoing1;
		 				 exe<='1';
		 				 case command_aux is
		 				 when "0000" =>  command <= "0010"; num_bytes<="0001";      --RDSR
		 				 when "0001" =>  command <= "0000"; num_bytes<="0001";      --WRSR
		 				 when "0010" =>  command <= "0000"; num_bytes<="0001";      --4 bytes write
		 				 when "0011" =>  command <= "0100"; num_bytes<="0100";      --4 bytes read
		 				 when "0100" =>  command <= "0000"; num_bytes<="0001";      --write pp + read+crc
		 				 when "0101" =>  command <= "0000"; num_bytes<="0001";      --sector_erase
		 				 when "0110" =>  command <= "0000"; num_bytes<="0001";      --bulk_erase
		 				 when others =>  command <= "0010"; num_bytes<="0001";      --RDSR
		 				 end case;
		 			    end if;	 
		 				 
		 when ongoing1=> exe <='0'; 
		                 if spi_busy_vec =x"f0" then
		                    sm2 <= delay;
		                 	case command_aux is                                                               
		 				    when "0000" =>  command <= "0010"; num_bytes<="0001" ;      --RDSR                                               				 
		 				    when "0001" =>  command <= "0000"; num_bytes<="0001" ;      --WRSR               
		 				    when "0010" =>  command <= "0000"; num_bytes<="0001" ;      --4 bytes write      
		 				    when "0011" =>  command <= "0010"; num_bytes<="0100" ;      --4 bytes read       
		 				    when "0100" =>  command <= "0000"; num_bytes<="0001" ;      --write pp + read+crc
		                    when "0101" =>  command <= "0000"; num_bytes<="0001" ;      --sector_erase       
		                    when "0110" =>  command <= "0000"; num_bytes<="0001" ;      --bulk_erase 
		                    when others =>  command <= "0010"; num_bytes<="0001" ;      --RDSR        
		                    end case;
		                 end if; 
						 
		 when delay =>      delay_counter <= delay_counter + 1;
		                    if delay_counter >=31 then
		                       delay_counter <=(others=>'0');
		                    end if;   
		 					case command_aux is                                                                
		                    when "0000" =>  if delay_counter >=31 then end_sm<='1';sm2<= stop    ; end if;      --RDSR                 
		                    when "0001" =>  if delay_counter >=31 then end_sm<='0';sm2<= ongoing2; end if;      --WRSR                 
		                    when "0010" =>  if delay_counter >=31 then end_sm<='0';sm2<= ongoing2; end if;      --4 bytes write        
		                    when "0011" =>  if delay_counter >=31 then end_sm<='1';sm2<= stop    ; end if;      --4 bytes read         
		                    when "0100" =>  if delay_counter >=31 then end_sm<='0';sm2<= ongoing2; end if;      --write pp + read+crc  
		                    when "0101" =>  if delay_counter >=31 then end_sm<='0';sm2<= ongoing2; end if;      --sector_erase         
		                    when "0110" =>  if delay_counter >=31 then end_sm<='0';sm2<= ongoing2; end if;      --bulk_erase   
		                    when others =>  if delay_counter >=31 then end_sm<='1';sm2<= stop    ; end if;      --RDSR         
		                    end case; 
		                                                                                             
		 when stop =>       sm2 <= idle;delay_counter <= (others=>'0');
		 					
		                    		                    		                    		                    		                    		                    		                    		                    
		 when ongoing2 =>   exe<='1';                                                                                    
		                    case command_aux is                                                              
		                    when "0000" =>  command <= "0010"; num_bytes<="0001";        --RDSR               
		                    when "0001" =>  command <= "0011"; num_bytes<="0001";        --WRSR               
		                    when "0010" =>  command <= "0101"; num_bytes<="0100";        --4 bytes write      
		                    when "0011" =>  command <= "0010"; num_bytes<="0100";        --4 bytes read       
		                    when "0100" =>  command <= "0101"; num_bytes<="0100";PP<='1'; --write pp + read+crc
		                    when "0101" =>  command <= "0110"; num_bytes<="0001";        --sector_erase       
		                    when "0110" =>  command <= "0111"; num_bytes<="0001";        --bulk_erase   
		                    when others =>  command <= "0010"; num_bytes<="0001";        --RDSR              
		                    end case; 
		                    if spi_busy_vec = x"f0" then                                                                                                                   
		                       sm2 <= delay2;
		                       capture_w_crc<='1';		                        
		                    end if;
							
		when delay2 =>      delay_counter <= delay_counter +'1';                                                               
		                    exe<='0';

                            -- !debug: 17/05/2023 delays corrected for 50MHz clock
		                    case command_aux is                                                                               
		                    when "0000" =>  if delay_counter(6)='1'                 then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --RDSR                --1 us                           
		                    when "0001" =>  if delay_counter(19)='1'                then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --WRSR                --8 ms 
		                    when "0010" =>  if delay_counter(14)='1'                then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --4 bytes write       --256 us 
		                    when "0011" =>  if delay_counter(7)='1'                 then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --4 bytes read        --2 us 
		                    when "0100" =>  if delay_counter(18)='1'                then end_sm<='0';sm2<= ongoing3 ;delay_counter<=(others=>'0'); end if; --write pp + read+crc --6.144 ms        
		                    when "0101" =>  if delay_counter(27 downto 24)=x"3"     then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --sector_erase        --1.04 sec 
		                    when "0110" =>  if delay_counter(31 downto 20)=x"d97"   then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --bulk_erase          --114 sec !debug: value > 32 bits
		                    when others =>  if delay_counter(6)='1'                 then end_sm<='1';sm2<= stop     ;delay_counter<=(others=>'0'); end if; --RDSR                --1 us       
		                    end case;
							
	    when ongoing3 =>    exe<='1';command <= "0100"; num_bytes<="0100"; delay_counter <=(others=>'0');
	    					if spi_busy_vec = x"f0" then                                                                                                                   
		                       sm2 <= delay3;
		                       capture_r_crc<='1';exe<='0';		                        
		                    end if;
		                    
		when delay3=>       delay_counter <= delay_counter + 1;
		                    if delay_counter >=31 then         
		                       delay_counter <=(others=>'0'); 
		                       end_sm<='1';sm2<= stop;exe<='0'; 
		                    end if;                            
		                    		                    		                  	    	                                                                                        
		end case;
	end if;
end process;
--------------------------------------------------------------------------------------------------------------------------------------	                           
busy<= busy_int;		                 
conf_status_reg                <= conf_status_reg_int;
conf_status_live(0)            <= busy_int;
conf_status_live(1)            <= PP_CRC_error;
conf_status_live(2)            <= PP_EXE_error;
conf_status_live(3)            <= PP_GT_EXE_error; -- ES: 30/06/2022
conf_status_live(4)            <= ERASE_EXE_error; -- ES: 06/03/2023
conf_status_live(15 downto 5)  <= (others=>'0');


-- !debug: 05/03/2023
misc_checks_pr: process (clk, reset) is
begin  -- process misc_checks_pr
  if (reset = '0') then                 -- asynchronous reset (active low)
    one_us_cnt <= 0;
    prog_us_cnt <= 0;
    max_prog_us_cnt <= 0;
    min_erase_sw_req_us_cnt <= 2**20-1;
    erase_sw_req_us_cnt <= 0;
  elsif (clk'event and clk = '1') then  -- rising clock edge

    if (one_us_cnt < 32000) then
      one_us_cnt <= one_us_cnt + 1;
    else
      one_us_cnt <= 0;
    end if;

    -- if (command_p = "0101" and command_aux /= "0101") then  -- sector_erase exec
    if (command_aux = "0101" and conf_status_reg_int(0) = '0' and conf_status_live(0) = '1') then  -- sector_erase exec
      prog_us_cnt <= 0;
    elsif (conf_status_live(0) = '1' and one_us_cnt = 32000) then -- busy
      prog_us_cnt <= prog_us_cnt + 1; -- measure erase time
    end if;
    
    if (reset_fifo = '1') then
      max_prog_us_cnt <= 0;
    elsif (prog_us_cnt > max_prog_us_cnt) then
      max_prog_us_cnt <= prog_us_cnt;
    end if;

    if (command_p = "0101" and exe_pvec = "01") then
      erase_sw_req_us_cnt <= 0;
    elsif (erase_sw_req_us_cnt < 2**20-1 and one_us_cnt = 32000) then
      erase_sw_req_us_cnt <= erase_sw_req_us_cnt + 1;
    end if;

    if (reset_fifo = '1') then
      min_erase_sw_req_us_cnt <= 2**20-1;
    elsif (min_erase_sw_req_us_cnt > erase_sw_req_us_cnt and
           (command_p = "0101" and exe_pvec = "01") and erase_sw_req_us_cnt > 1) then
      min_erase_sw_req_us_cnt <= erase_sw_req_us_cnt;
    end if;
    
  end if;
end process misc_checks_pr;


END ARCHITECTURE behave;

