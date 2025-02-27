--
-- VHDL Architecture CAN_CTL_lib.SPI2CAN.behave
--
-- Created:
--          by - ILQ00571.UNKNOWN (ILQHFAATC1NB350)
--          at - 13:37:14 04/01/2011
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY SPI_SM IS
   PORT( 
      EXE             : IN     std_logic;
      clk             : IN     std_logic;
      command         : IN     std_logic_vector (3 DOWNTO 0);
      num_bytes       : IN     std_logic_vector (3 DOWNTO 0);
      reset           : IN     std_logic;
      CS              : OUT    std_logic;
      IR              : OUT    std_logic_vector (7 DOWNTO 0);
      SCK_aux         : OUT    std_logic;
      SCK_ena         : OUT    std_logic;
      SPI_busy        : OUT    std_logic;
      load            : OUT    std_logic;
      sel             : OUT    std_logic_vector (3 DOWNTO 0);
      shift_ena       : OUT    std_logic;
      shift_ena_out   : OUT    std_logic;
      shift_IR        : BUFFER std_logic;
      shift_addr_byte : BUFFER std_logic;
      shift_data_in   : BUFFER std_logic;
      shift_data_out  : BUFFER std_logic;
      PP              : IN     std_logic;
      next4bytes      : BUFFER std_logic;
      load_fifo       : BUFFER std_logic;
      rd_en           : OUT    std_logic
   );

-- Declarations

END SPI_SM ;

--
ARCHITECTURE behave OF SPI_SM IS
constant WREN : std_logic_vector(7 downto 0) :=x"06";
constant WRDI : std_logic_vector(7 downto 0) :=x"04";
constant RDSR : std_logic_vector(7 downto 0) :=x"05";
constant WRSR : std_logic_vector(7 downto 0) :=x"01";
constant READ_bytes : std_logic_vector(7 downto 0) :=x"03";
constant Pageprog : std_logic_vector(7 downto 0) :=x"02";
constant SE : std_logic_vector(7 downto 0) :=x"D8";
constant BE : std_logic_vector(7 downto 0) :=x"C7";


signal num_bytes_s : std_logic_vector(3 downto 0);
signal exe_vec :std_logic_vector (1 downto 0);
signal sck_aux_int :std_logic;
signal sck_aux_cnt :std_logic_vector (1 downto 0);
type spi_fsm is(Toggling,IDLE,SOF,sh_IR,sh_addr,sh_data_in,sh_data_out,eof,finish);
signal spi :spi_FSM;
signal bit_cnt :std_logic_vector (5 downto 0);
signal byte_cnt :std_logic_vector (3 downto 0);
signal command_s:std_logic_vector (3 downto 0);
signal ena03,ena02,ena01,ena00,ena13,ena12,ena11,ena10 :std_logic;
signal byte_pp : std_logic_vector (7 downto 0);
signal delay   : std_logic_vector (15 downto 0);
BEGIN

process (reset,clk)                                     --assuming clk is 64Mhz
begin                            
if reset ='0' then               
   sck_aux_int <= '0';
   sck_aux_cnt <= "11";
   ena03<='0';ena02<='0';ena01<='0';ena00<='0';ena13<='0';ena12<='0';ena11<='0';ena10<='0';                    
elsif clk'event and clk ='1' then
   sck_aux_cnt<= sck_aux_cnt - 1; 
   if sck_aux_cnt = 0 then
      sck_aux_int <= not sck_aux_int;                                                --sck_clk_int is 8Mhz
   end if;
   if sck_aux_int ='0' and sck_aux_cnt= 3 then
   		ena03<='1';
   else		
        ena03<='0';
   end if;
   if sck_aux_int ='0' and sck_aux_cnt= 2 then
   		ena02<='1';                              
   else		                                     
        ena02<='0';                           
   end if;                                    
   if sck_aux_int ='0' and sck_aux_cnt= 1 then
   		ena01<='1';                              
   else		                                     
        ena01<='0';                           
   end if;                                    
   if sck_aux_int ='0' and sck_aux_cnt= 0 then
   		ena00<='1';                              
   else		                                     
        ena00<='0';                           
   end if;                                    
   if sck_aux_int ='1' and sck_aux_cnt= 3 then
   		ena13<='1';                              
   else		                                     
        ena13<='0';                           
   end if;                                    
   if sck_aux_int ='1' and sck_aux_cnt= 2 then
   		ena12<='1';                              
   else		                                     
        ena12<='0';                           
   end if;                                    
   if sck_aux_int ='1' and sck_aux_cnt= 1 then
   		ena11<='1';                              
   else		                                     
        ena11<='0';                           
   end if;                                    
   if sck_aux_int ='1' and sck_aux_cnt= 0 then
   		ena10<='1';                                 
   else		                                     
        ena10<='0';                           
   end if;                                       
end if;
end process;
----------------------------------------------------------------------------------------------------------------------------         
process (reset,clk)
begin
if reset ='0' then
   exe_vec <= "00";
   command_s <="0000";
   bit_cnt  <="000000";
   byte_cnt <="0000";
   SPI <=Toggling;
   shift_IR       <='0';
   shift_addr_byte<='0';
   shift_data_in  <='0';
   shift_data_out <='0';
   command_s<="0000";
   num_bytes_s<="0000";
   SCK_ena<='0';
   cs<='1';
   IR<=WRDI;
   sel <="0001";
   load <='0';
   SPI_busy<='0';
   next4bytes<='0';
   load_fifo<='0';
   delay <=(others=>'0');
elsif clk'event and clk ='1' then
   exe_vec<= exe_vec(0) & exe ;
   load<='0'; 
   next4bytes<='0';
   load_fifo<='0';                    
-----------------------------------------------------------------------------------------------------   	 	       	   	
   	case spi is
   	when Toggling => cs <='1';SCK_ena<='1';shift_addr_byte<='0'; shift_data_in <='0';shift_data_out<='0';
   				  byte_cnt<="0000";bit_cnt<="000000";SPI_busy<='0';shift_IR <='0';byte_pp<=x"00"; 				  
   				  if delay = x"ffff" then
   				     delay <= (others=>'0');
   				     spi<=idle;
   				     SCK_ena<='0';
   				  else 
   				    delay <=delay +1; 
   				  end if;
   				  
   	when idle =>  cs <='1';SCK_ena<='0';shift_addr_byte<='0'; shift_data_in <='0';shift_data_out<='0';
   				  byte_cnt<="0000";bit_cnt<="000000";SPI_busy<='0';shift_IR <='0';byte_pp<=x"00";
   				  if exe_vec ="01" then
   				  	num_bytes_s <= num_bytes;
   				  	command_s<=command;                                                      
   				  	load<='1';                                                               
   				  	spi <= SOF;
   				  	SPI_busy<='1';                                                     
   				  		case command is                                                       
   				  		when "0000"=> IR <= WREN            ;
   				  		when "0001"=> IR <= WRDI            ;
   				  		when "0010"=> IR <= RDSR            ;
   				  		when "0011"=> IR <= WRSR            ;
   				  		when "0100"=> IR <= READ_bytes      ;
   				  		when "0101"=> IR <= pageprog              ;
   				  		when "0110"=> IR <= SE              ;
   				  		when "0111"=> IR <= BE              ;   				  	
   				  		when others=> IR <= READ_bytes      ;
   				  		end case; 
   				  	if command="0101" or command="0011" then
   				  	 	load_fifo<='1';
   				  	end if; 	
   				  		
   				  		  				  		   				  		                                                     				  	   				  	   				  	
   				  end if;	
-------------------------------------------------------------------------------------------------------------------------   				  
   	when SOF => if ena12='1' then
   					cs<= '0';
   					spi <= sh_IR; shift_IR<='1';
   					sel<="0000";  					
   				end if;
--------------------------------------------------------------------------------------------------------------------------   					
   	when sh_IR =>   if ena03='1' then
   						SCK_ena<='1';
   					end if;	
   				    if ena11 ='1' then
   				 		bit_cnt <= bit_cnt+ 1;
   				    end if;
   				    if bit_cnt = 8 and ena12='1'   then
   				    	bit_cnt<="000000" ;   				    	   				    	  				 	
  			    		case command_s is                                                         --  "0000"=> IR <= WREN            ;
  						when "0000"=> spi<= EOF;                                                  --  "0001"=> IR <= WRDI            ;
  						when "0001"=> spi<= EOF;                                                  --  "0010"=> IR <= RDSR            ;
  						when "0010"=> spi<= sh_data_out;     shift_data_out <='1';                --  "0011"=> IR <= WRSR            ;
  						when "0011"=> spi<= sh_data_in;      shift_data_in  <='1';                --  "0100"=> IR <= READ_bytes      ;
  						when "0100"=> spi<= sh_addr;         shift_addr_byte<='1';                --  "0101"=> IR <= PP               ;
  						when "0101"=> spi<= sh_addr;         shift_addr_byte<='1';                --  "0110"=> IR <= SE              ;
  						when "0110"=> spi<= sh_addr;         shift_addr_byte<='1';                --  "0111"=> IR <= BE              ;
  						when "0111"=> spi<= EOF;                                                   
  						when others=> spi<= EOF;              
  						end case; 			 	
   				    end if;
   				    
   				    if bit_cnt = 8 and ena12='1' then   				    	       				    	  		        
   				    	if command_s="0011" then                   
   				            sel <="0001";	   				         	   				         	   				               				               				               				          				                 				               				            			                      				                         
   				        else                                    
   				        	sel <="1001";
   				        end if;			   	                    
   				    end if;   				       				                       				      				       				      				       				     				     
---------------------------------------------------------------------------------------------------------------------------------   				 
   	when EOF => if ena03 ='1' then
   					cs<='1';   					
   				   spi <= finish;
   				   sck_ena<='0';  -- check it !!!
   				   byte_pp<=(others=>'0');   				      				   
   				end if;
---------------------------------------------------------------------------------------------------------------------------------   				
    when finish=>if ena10='1' then
    				spi<=idle;
    				sck_ena<='0';
    			 end if;	       	 	   	  	   				
---------------------------------------------------------------------------------------------------------------------------------   							    	
	when sh_addr =>	                                                                            	                                                                                                 
   	                if ena11 ='1' then
   				 		bit_cnt <= bit_cnt+ 1;
   				    end if;                                                                                 
   	                if bit_cnt = 24 and ena12='1'  then 
   	                  	bit_cnt<="000000" ;                                                                                    
   	                	case command_s is                                                       --  "0000"=> IR <= WREN            ;
   	                	when "0000"=> spi<= EOF;                                                --  "0001"=> IR <= WRDI            ;
   	                	when "0001"=> spi<= EOF;                                                --  "0010"=> IR <= RDSR            ;
   	                	when "0010"=> spi<= EOF;                                                --  "0011"=> IR <= WRSR            ;
   	                	when "0011"=> spi<= EOF;                                                --  "0100"=> IR <= READ_bytes      ;
   	                	when "0100"=> spi<= sh_data_out;     shift_data_out <='1';              --  "0101"=> IR <= PP              ;
   	                	when "0101"=> spi<= sh_data_in;      shift_data_in  <='1';              --  "0110"=> IR <= SE              ;
   	                	when "0110"=> spi<= EOF ;    							                --  "0111"=> IR <= BE              ;
   	                	when "0111"=> spi<= EOF;                                                  	                	            
   			        	when others=> spi<= EOF ;                                       
   				    	end case;    				    	   				    	   				    	   				       				      				       				    	   				    	   				    	 				    	 			 	                                                                          
   				    end if;
   				    if bit_cnt = 24 and ena12='1' then
   				    	if command_s="0101" then
   	                     	case num_bytes_s is
   	                     	when "0001"=> sel <= num_bytes_s; 
   	                     	when "0010"=> sel <= num_bytes_s;
   	                        when "0011"=> sel <= num_bytes_s;
   	                        when "0100"=> sel <= num_bytes_s;
   	                        when "0101"=> sel <= num_bytes_s;
   	                        when "0110"=> sel <= num_bytes_s;
   	                        when "0111"=> sel <= num_bytes_s;
   	                        when "1000"=> sel <= num_bytes_s;
   	                        when others=> sel <= num_bytes_s; 
   	                        end case;                     	                      	                       	                    
   	                    else 
   	                    		sel <="1111";
   	                    end if;			   	                    	  
   				    end if;   				       				     				       				       				       				       				     				       				   				       				    
------------------------------------------------------------------------------------------------------------------------------------   				                                                                                       
   	when sh_data_out=>                                                     			    				                                                       				                                                         	                                                                           	                                                                        	                                                                       	                                                                        	                                                                       
   	                 if ena01 ='1' then                                                                   
   	                 	bit_cnt <= bit_cnt+ 1;
   	                 end if;	
   	                 if bit_cnt = 7 and ena01='1' then
   	   	                byte_cnt <= byte_cnt+1;
   	   	                bit_cnt <="000000";
   	                 end if; 
   	                   	                 
   	                 if bit_cnt = 7 and ena01='1' then
   	   	                byte_pp <= byte_pp+1;   	   	                
   	                 end if;
   	                 
   	                 
   	                 	                                                                         	                                                                                                     
   	                 if (bit_cnt = 7 and ena01='1' and byte_cnt=num_bytes_s-1 and PP='0' )or(bit_cnt = 7 and ena01='1' and byte_pp=x"FF" and PP='1') then
   	                 	spi<= EOF;
   	                 	shift_data_out <='0';                                                                              	                     	                     	                     	                     	                     	                        	                     	                        	                        	                     	                     	                             
   	                 end if; 
-----------------------------------------------------------------------------------------------------------------------------------------------                                                                  
   	 when sh_data_in=>                                                         	                                                                	                                                                --   	 addr_byte_s(7)when "1001",     	                        	                        	                        	                        	                        	                        	                        	                        	                        	                       	                       	                        	                        	                                                            	                      	                      	                      	                   
   	                 if ena12 ='1' then
   				 	 	bit_cnt <= bit_cnt+ 1;
   				     end if;  
   	                 if bit_cnt = 7 and ena12='1' then   -- ena12                                                    
   	                    --byte_cnt <= byte_cnt+1;
   	                    bit_cnt<="000000" ;                                                               
   	                 end if;
					 ---------------------------------------------
   	                 if bit_cnt = 7 and ena12='1'and PP ='1' then                                                         
   	                    byte_pp <= byte_pp+1;   	                                                                                
   	                 end if;
   	                 if bit_cnt = 7 and ena01='1'and PP ='1'  and byte_cnt=num_bytes_s-1 and byte_pp < x"FF" then                                                         
   	                    next4bytes <='1';   	                    	                        	                      	                     	                                                                                   	                    	                 
   	                 end if;
   	                 ---------------------------------------------
   	                 if bit_cnt = 7 and ena12='1' and byte_cnt=num_bytes_s-1 and PP='1'then--and pp='1'
   	                 	byte_cnt <= "0000";
   	                 elsif bit_cnt = 7 and ena12='1' then
   	                 	byte_cnt <= byte_cnt+1;	
   	                 end if;
   	                 ------------------------------------------------------------------------------------   	                 	    	                    	                    	                  	                    	                                                                                                                                              	                     
   	                 if bit_cnt = 7 and ena12='1' and byte_pp=x"FF" then    	                   	 	                
   				      	spi<=EOF;
   				      	shift_data_in <='0';  
   				     elsif bit_cnt = 7 and ena12='1' and byte_cnt=num_bytes_s-1 and PP='0' then
   				     	spi<=EOF;
   				     	shift_data_in <='0';  
   				     end if;    				          				                                                          	                                                                                                                                                                                                                                                  	   	   	    	          				                                                                                               			  			   				 	   	  					 			  			
   	end case;   	  	
end if;   		
end process;  
rd_en<=load_fifo or next4bytes;       
SCK_aux<=SCK_aux_int;
shift_ena<=ena11;
shift_ena_out<=ena01;
END ARCHITECTURE behave;





