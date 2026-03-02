-- hds interface_start
--
-- VHDL Architecture I2C_for_tmcore_lib.I2C_TMOR.behave
--
-- Created:
--          by - ilq00571.UNKNOWN (ILQHFAATC1WS159)
--          at - 14:43:05 16/01/2008
--  
-- using Mentor Graphics HDL Designer(TM) 2005.3 (Build 74)
--  100KHz mode IIC
--  1M Flash
-- Versions:
--  26/07/2023: 1. Tzvika Sweetkin added rd_done and wr_done output ports
--              2. Tzvika Sweetkin added G_IIC_CLKS_NUM for creating SCLK frequency.for 100K with 50MHz clock its 500 and for 400K its 125
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.ALL;

ENTITY I2C_TMOR IS
   GENERIC (
		G_IIC_CLKS_NUM : integer := 250 -- 100K with 50MHz clk
   );
   PORT( 
      E             : IN     std_logic_vector (1 DOWNTO 0); -- chip select represent slave hw number
      address       : IN     std_logic_vector (16 DOWNTO 0);
      clk           : IN     std_logic;
      data2write    : IN     std_logic_vector (15 DOWNTO 0);
      ena           : IN     std_logic;
      ena_wp        : IN     std_logic; -- represent write protect enable
      reset         : IN     std_logic;
      rw            : IN     std_logic;
      wp            : OUT    std_logic; -- write protect
      sda           : INOUT  std_logic; -- for multi master connection when data is '1' output will be 'z' and need to constrain pin with pull-up
      scl           : inout std_logic;
	  read_ready    : OUT    std_logic; -- when rising read data ready
	  rd_done       : out  std_logic;
	  wr_done       : out  std_logic;
	  WP_DONE       : out std_logic; -- added by Tzvika Sweetkin 10/08/2023
      data2read_out : OUT    std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END I2C_TMOR ;


-- hds interface_end


--
ARCHITECTURE behave OF I2C_TMOR IS 


type main_state is (
					idle,
					coordinator,
					read_process ,
					write_process,
					wp_delay
					);
type second_state is ( 
					idle_s,
					start1,
					start2,
					prestart,
					dev_sel1,
					dev_sel2,
					byte_add_m,
					byte_add_l,
					data_read1,
					data_read2,
					data_write1,
					data_write2,
					prestop, 
					stop);
signal m_state        : main_state;							                --   SIGNAL DESCRIBING THE MAIN STATE MACHINE	
signal m_state_s      : main_state;                                         --   SIGNAL OF THE MAIN MACHINE SAMPLES WITH OTHER CLOCK  
signal m_state_ss     : main_state;                                         --   SIGNAL OF THE MAIN MACHINE SAMPLES SECOND TIME WITH OTHER CLOCK
signal s_state        : second_state;                                       --   SIGNAL DESCRIBING THE SECONDARY STATE MACHINE


signal scl_aux        : std_logic;
signal scl_aux_s      : std_logic;                                          --   AUX CLOCK
signal counter        : integer range 0 to 600;                              --   COUNTER FOR CREATING AUX CLOCK
signal cnt_clk        : integer range 0 to 3; 
signal address_int    : std_logic_vector (15 downto 0);                     --   THE ADDRESS SAMPLES
signal data2write_int : std_logic_vector (15 downto 0);                     --   THE DATA FROM FIFO IS SAMPLED 
signal rw_int         : std_logic;                                          --   THE RW IS SAMPLED
-- signal E_int          : std_logic_vector (2 downto 0);
signal data2read      : std_logic_vector (15 downto 0); 
------------------------------------------------------------                     
signal read_finish    : std_logic;
-----------------------------------------------------------
signal write_finish   : std_logic;
signal wp_done_sig   : std_logic;

 ------------------------------------------------------------
signal index          : integer range 0 to 15;
 ----------------------------------------------------------------
constant i_d_prom     : std_logic_vector (3 downto 0) := "1010";
signal dev_sel_reg1   : std_logic_vector (7 downto 0);
signal dev_sel_reg2   : std_logic_vector (7 downto 0);
------------------------------------------------------------------
signal ena_s : std_logic; 

signal delay_wp_cnt   :  std_logic_vector (11 downto 0);
 attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of m_state : signal is "true";
  attribute DONT_TOUCH of s_state : signal is "true";
  attribute DONT_TOUCH of read_finish : signal is "true";
  attribute DONT_TOUCH of write_finish : signal is "true";
  attribute DONT_TOUCH of address_int : signal is "true";
  attribute DONT_TOUCH of data2write : signal is "true";


BEGIN

process (reset, clk)

	begin	
	if reset ='1' then
		counter <= 0;
		scl_aux <= '0';                          -- last changed 201106 1523		
	elsif clk'event and clk='1' then					
			counter <= counter + 1;			
			-- if counter >= 19 then 			
			if counter >= G_IIC_CLKS_NUM - 1 then 			
				scl_aux <= not scl_aux;				
			    counter <= 0;			    
			end if;					
	end if;	
end process;
----------------------------------------------------------------------------
process (clk,reset)
	begin
	
	if reset = '1' then	
		m_state <= idle;		
		wp <= 'Z';																						
		ena_s <= '0';				
		delay_wp_cnt <=	X"0A0";
		read_ready <='0';		
		wp_done_sig <= '0'; -- added by Tzvika Sweetkin 10/08/2023

	elsif clk'event and clk ='1' then	    								    	            
	    ena_s <= ena;	
		 read_ready <='0';	
		 wp_done_sig <= '0'; -- added by Tzvika Sweetkin 10/08/2023	 
		case m_state is
					   					
			when idle  	         => 		wp <= 'Z';                                --- wp will written in here 			
											delay_wp_cnt <=	X"0A0";			
											if ena = '1' and ena_s = '0'  then											
											    rw_int         <=    rw;			                                    
 -- 		                                    E_int          <=    E;			                                   			                                 			                                 
--		   								 	    address_int    <=   "000" & address & '0' ;	 --Tzvika Sweetkin	
                                                address_int    <=   address(15 downto 0);	 --Tzvika Sweetkin	   								 	    		   								 			   								    				   								 
			   							        dev_sel_reg1   <=    i_d_prom & E &address(16) & '0'; -- write start condition			                                 			                                    			                                 
			                                    dev_sel_reg2   <=    i_d_prom & E &address(16) & '1'; -- read start condition
												data2write_int <=    data2write;												
												m_state     <=    coordinator;																																				
											else                                              											 
											 	m_state     <=    idle;											 	
											end if;																																																					 											 											 					          					                                 			                                  			                                 		   								 	 		   								 	 		   								 	 			   								 		 			   							     			                                 			                                   			                                 			                                 			                                 			                                 			                                 			                                 			                                 			                                 
----------------------------------------------------------------------------------------------------------------------------------------------------			                                 
			when coordinator     =>          if rw_int = '0' then																		
												m_state <= write_process;
																								                                 
											 else											  
											 	m_state <= read_process;											 	
											 end if;											 
------------------------------------------------------------------------------------------------------------------------------------------------------											 			 											 
			when write_process   =>			 m_state        <=    write_process;																					 										 
											 if  write_finish ='1' then											 										 
 -- 											m_state <= idle;											 	 
											 	m_state        <=    wp_delay;											 	 
											 end if;											 
											 if ena_wp = '1' then											 
											 	wp <= '0';											 	
											 else											 
											 	wp <= 'Z';											 	
											 end if;
------------------------------------------------------------------------------------------------------------------------------------------------------											 												 
			when read_process    =>      	 wp <=  'Z' ;               			
											 m_state        <=    read_process;			 											 
											 if read_finish = '1' then      --changing the state											 											 
											 	  m_state <= idle;
											 	  data2read_out <= data2read;	
												  read_ready <='1';
											 end if;
------------------------------------------------------------------------------------------------------------------------------------------------------											 													 		 											 											 														 											 
			when wp_delay       =>			 wp <= '0';
											 delay_wp_cnt  <=	delay_wp_cnt -1 ;
											 if delay_wp_cnt = X"000" then
											    m_state        <=    idle;
											    delay_wp_cnt <= X"0A0";
											    wp_done_sig <= '1'; -- added by Tzvika Sweetkin 10/08/2023
											 end if;   
			                                 
		end case;									 		 							  											 	
	end if;
end process;

---------------------------------------------------------------------------------
WP_DONE <= wp_done_sig;
---------------------------------------------------------------------------------
process (reset,clk)
	begin
	
		if reset= '1' then		
			s_state <= idle_s;			
			m_state_s <= idle;			
			m_state_ss <= idle;			
			sda <= 'Z';			
			scl <= '1';			                               -- check if '1' or 'Z'						
			data2read <= (others => '0');																
			write_finish <='0';			
			read_finish  <= '0';			
-- 			wp <= 'Z';					
			Scl_aux_S<='0';			
			index <= 0;											 	
		elsif clk'event and clk ='1' then				    
	    
		    scl_aux_S <= scl_aux;	
------------------------------------------------------------------------------------------------------------------------		   	   	    		   	   	
		    write_finish <='0';           	   	    
           	read_finish  <='0';
------------------------------------------------------------------------------------------------------------------------		   	   	    		   	   	  	
			if scl_aux = '1' and scl_aux_S ='0' then -- Rising every 40 64MHz clks => 1.6M => 625nsec. 100KHz mode
									
			    if cnt_clk < 3 then		          
		        	cnt_clk <=  cnt_clk + 1 ;		        	
		        	else		        	 
		        	cnt_clk  <= 0;		        	
		       	end if;	
		       														
		      m_state_s <= m_state;		      
		      m_state_ss <= m_state_s;		      
		      		      		      		   	   
		   	   if m_state_ss = write_process then
		   	   
		   	   	case s_state is
		   	   	
		   	   	    when idle_s      =>         scl <='1';		   	   	    		   	   	    								   	   	    							
		   	   	    							index <= 0;		   	   	                             
		   	   	    							sda <='Z';		   	   	    									   	   	    									   	   	    									      	    							
		   	   	    							if cnt_clk = 0 then		   	   	    							
		   	   	    								s_state <= start1;		   	   	    								
		   	   	    							end if; 		   	   	    												   		   	   	    					   		 	
------------------------------------------------------------------------------------------------------------------------		   	   	    		   	   	
		   	   		when start1       =>       if cnt_clk = 1 then		   	   		
		   	   		                             sda <= '0';		   	   		                             
		   	   								     index <= 0;		   	   								     
		   	   		 						   end if;
		   	   		 						  
		   	   							       if cnt_clk = 2 then
		   	   							      	scl <= not scl;		   	   							      	
		   	   							      	s_state <= dev_sel1;		   	   							      	
		   	   							       end if;	
---------------------------------------------------------------------------------------------------------------------------
					-- send initiate start condition byte
					--										|		b7		|		b6		|		b5		|		b4		|		b3		|		b2		|		b1		|		b0		|
					--Access Memory							|		'1'		|		'0'		|		'1'		|		'0'		|		E2		|		E1		|		XX		|		R/Wn	|
					--Access identification page			|		'1'		|		'0'		|		'1'		|		'1'		|		E2		|		E1		|		XX		|		R/Wn	|
	       	         when dev_sel1     =>    if cnt_clk = 3 then           	       	         					   	                                		
	       	         					   		if index < 8 then              			       	         					   		                               		
	       	         							    index <= index + 1;	       	         							    
	       	         							    if dev_sel_reg1 (7-index) = '1' then	       	         							    
	       	         							    	sda <= 'Z';	       	         							    	
	       	         							    else 
	       	         							    	sda <= '0';	       	         							    
	       	         							    end if;	        					         	 
	       	         					   		elsif index = 8  then  --slave ack        			       	         					   		                               		
	       	         					   			index <= 0;                   	 	       	         					   				                		             
	       	         					   		 	sda <= 'Z';	       	         					   		 	
	       	         					   		 	s_state <= byte_add_m;	       	         					   		 	
	       	         					        end if;	       	         					        	                					   	                					        
	       	         					     end if;           	       	         
	       	                                 if cnt_clk = 0 or cnt_clk = 2 then
	       	                                		scl <= not scl;	       	                                		
	       	                                 end if;
------------------------------------------------------------------------------------------------------------------------------
					-- send address msb byte
	       	         when byte_add_m   =>    if cnt_clk = 3 then           	       	         					   	                                		
	       	         					   		if index < 8 then              			       	         					   		                               		
	       	         							    index <= index + 1;	       	         							    
	       	         							    if address_int (15-index) = '1' then	       	         							    
	       	         							    	sda <= 'Z';	       	         							    	
	       	         							    else 
	       	         							    	sda <= '0';	       	         							    
	       	         							    end if;	        						       	         					   			                              	 
	       	         					   		elsif index = 8  then          			       	         					   		                               		
	       	         					   			index <= 0;                   	 	       	         					   				                		             
	       	         					   		 	sda <= 'Z';	       	         					   		 		                					   		 		                					   		 	
	       	         					   		 	s_state <= byte_add_l;	       	         					   		 		       	         					   		 	
	       	         					        end if;	         					        
	       	         					     end if;           	       	         
	       	                                 if cnt_clk = 0 or cnt_clk = 2 then	       	                                	       	                                    	       	                                	                                       	                                       	                                       	       	                                
	       	                                 		scl <= not scl;	       	                                		
	       	                                 end if;
---------------------------------------------------------------------------------------------------------------------------------	
					-- send address lsb byte
	       	         when byte_add_l   =>   if cnt_clk = 3 then           	       	        					   	                                		
	       	        					   			if index < 8 then              			       	        					   		                               		
	       	        							    	index <= index + 1;	       	        							    	
	       	        							    	if address_int (7-index) = '1' then	       	         							    
	       	         							    	sda <= 'Z';	       	         							    	
	       	         							    else 
	       	         							    	sda <= '0';	       	         							    
	       	         							    end if;        						       	        							                               					       	        					   					 	       	        					   			                              	 
	       	        					   			elsif index = 8  then          			       	        					   		                               		
	       	        					   				index <= 0;                   	 	       	        					   				                		             
	       	        					   		 		sda <= 'Z';	       	        					   		 			       	        					   		 		      	        					   		 	
	       	        					   		 		s_state <= data_write1;	       	        					   		 			               					   		 			               					   		 		
	       	        					        	end if;	               					      	               					   	   	       	        					        
	       	        					   	  end if;           
	       	        
	       	                               if cnt_clk = 0 or cnt_clk = 2 then
	       	                               		scl <= not scl;	       	                               		
	       	                               end if;
--------------------------------------------------------------------------------------------------------------------------------------	       	                                                                               					    	       	        					    
	       	         -- send address msb byte	       	         
	       	         when data_write1   =>	if cnt_clk = 3 then           	       	        					   	                                		
	       	        					   			if index < 8 then              			       	        					   		                               		
	       	        							    	index <= index + 1;	       	        							    	
	       	        							    	if data2write_int (15-index) = '1' then  -- 15 instead of 7	       	         							    
	       	         							    		sda <= 'Z';	       	         							    	
	       	         							    	else 
	       	         							    		sda <= '0';	       	         							    
	       	         							    	end if;        						       	        							                               					       	        					   					 	       	        					   			                              	 
	       	        					   			elsif index = 8  then          			       	        					   		                               		
	       	        					   				index <= 0;                   	 	       	        					   				                		             
	       	        					   		 		sda <= 'Z';	       	        					   		 		
	       	        					   		 		s_state <= data_write2;	               					   		 		       	        					   		 	
	       	        					        	end if;	               					        	               					   
	       	        					             
	       	        					    end if;	               					        	               					             	       	        
	       	                               	if cnt_clk = 0 or cnt_clk = 2 then      	                               
	       	                               		scl <= not scl;	       	                               		
	       	                               	end if;                             
----------------------------------------------------------------------------------------------------------------------------------------
					-- send data lsb byte
	       	         when data_write2   =>	if cnt_clk = 3 then           	       	        					   	                                		
	       	        					   			if index < 8 then              			       	        					   		                               		
	       	        							    	index <= index + 1;	       	        							    
	       	        							    	if data2write_int (7-index) = '1' then --- 7 instead of 15	       	         							    
	       	         							    		sda <= 'Z';	       	         							    	
	       	         							    	else 
	       	         							    		sda <= '0';	       	         							    
	       	         							    	end if;        						       	        							                               					       	        					   				 	       	        					   			                              	 
	       	        					   			elsif index = 8  then          			       	        					   		                               		
	       	        					   				index <= 0;                   	 	       	        					   				                		             
	       	        					   		 		sda <= 'Z';	       	        					   		 			       	        					   		 			       	        					   		 		
	       	        					   		 		s_state <= prestop;	       	        					   		 				       	        					   		 		       	        					   		 				       	        					   		 			 	       	        					   		 					   		 			
	       	        					        	end if;	               					        	               					   			       	        					        
	       	        					   	end if;           	       	        
	       	                               	if cnt_clk = 0 or cnt_clk = 2 then
	       	                               		scl <= not scl;	       	                               		
	       	                               	end if;	       	                               
----------------------------------------------------------------------------------------------------------------------------------------	       	                                                                                     
	       	         -- pull down sda for stop comm	      	         
	       	         when prestop     =>   	if cnt_clk = 3 then	       	         
	       	         								sda <= '0';	       	         								
	       	         								s_state <= stop;	       	         							
	       	         				      	end if;		       	         							                       
	       	                              	if cnt_clk = 0 or cnt_clk = 2 then
	       	                              			scl <= not scl; 	       	                                    	                                            
	       	                              	end if;
-----------------------------------------------------------------------------------------------------------------------------------------
	       	         when stop       => 	if cnt_clk = 1 then	       	                            	
	       	         							sda <= 'Z' ;	       	          							
	       	          							s_state <= idle_s;           
	       	          							write_finish <= '1';	       	          							 	       	        						   		 				       	          									                 							                  						   		                 							                 							                 						
	       	          				    	end if;	       	          				   
	       	          				   		if cnt_clk = 0 or cnt_clk = 2 then	       	          				   			       	          				   			       	                           		        
	       	                           		   		scl <= not scl; 	       	                           		         	                                            
	       	                           		end if;

	       	                           		
-----------------------------------------------------------------------------------------------------------------------------------------------
	       	         when others    =>  null;  				   	                       	       	                                 	       	                                 
           	    end case;           	    
           	    
           	   elsif m_state_ss = read_process then	--read IIC	   	     
		   	     	case s_state is		   	     	
		   	     	    when idle_s      =>         scl <='1';		   	     	    
		   	     	                                --scl <= 'Z';		   	     	    
		   	     	    							sda <='Z';		   	     	    							
		   	     	    							if cnt_clk = 0 then		   	     	    							
		   	     	    								s_state <= start1;		   	     	    								
		   	     	    							end if; 
-----------------------------------------------------------------------------------------------------------------------------------
						-- get permission to write start condiotion on bus
		   	     		when start1       =>      if cnt_clk = 1 then		   	     		
		   	     		                             sda <= '0';		   	     		                             
		   	     								     index <= 0;		   	     								     
		   	     		 						  end if;		   	     		 						  
		   	     							      if cnt_clk = 2 then		   	     							      		   	     							      			   	     							        		        
		   	     							      	scl <= not scl;		   	     							      	
		   	     							      	s_state <= dev_sel1;		   	     							      	
		   	     							      end if;
------------------------------------------------------------------------------------------------------------------------------------
						-- get permission to read start condiotion on bus		   	     							      
		   	     		when start2       =>      if cnt_clk = 1 then		   	     		
		   	     		                             sda <= '0';		   	     		                             
		   	     								     index <= 0;		   	     								     
		   	     								     s_state <= dev_sel2;		      								     		   	     								     
		   	     		 						  end if;		   	     		 						  
		   	     							      if cnt_clk = 0 or cnt_clk = 2 then		   	     							      		   	     							         		   	     							                   
		   	     							      	scl <= not scl;		      							      			      							      			   	     							      	
		   	     							      end if;					      
-------------------------------------------------------------------------------------------------------------------------------------
						-- write ack on bus
		   	     		when prestart    =>		if cnt_clk = 3 then		   	     		
		   	     									sda <= 'Z';			   		   	     							    
		   	     									s_state <= start2;		   	     											   	     									
		   	     								end if;		   	     								
		   	     								if cnt_clk = 0 or cnt_clk = 2 then
	       	                                  		scl <= not scl;		   	     								
	       	                                  	end if;
-------------------------------------------------------------------------------------------------------------------------------------
					  -- Random address Read:dummy write start condiotion for loading address counter
	       	           when dev_sel1     =>     if cnt_clk = 3 then           
	       	           					   	                                		
	       	           					   			if index < 8 then              			       	           					   			                               		
	       	           								    index <= index + 1;	       	           								    
	       	           								    if dev_sel_reg1 (7-index) = '1' then	       	           								    
	       	           								    	sda <= 'Z';	       	           								    	
	       	           								    else 
	       	           								    	sda <= '0';	       	           								    
	       	           								    end if;        						       	           								                               					       	           					   					 	       	           					   				                              	 
	       	           					   			elsif index = 8  then          			       	           					   			                               		
	       	           					   				index <= 0;                   	 	       	           					   					                		             
	       	           					   			 	sda <= 'Z';	       	           					   			 	
	       	           					   			 	s_state <= byte_add_m;	       	           					   			 	
	       	           					        	end if;	       	           					        	                					   	                					        
	       	           					     	end if;           	       	           
	       	                                  	if cnt_clk = 0 or cnt_clk = 2 then   	       	                                  
	       	                                  			scl <= not scl;	       	                                  		
	       	                                  	end if;
-------------------------------------------------------------------------------------------------------------------------------------	
						-- write read start condiotion on bus       	                                  	       	           
	       	            when dev_sel2     =>    if cnt_clk = 3 then           	       	           					   	                                		
	       	           					   			if index < 8 then              			       	           					   			                               		
	       	           								    index <= index + 1;	       	           								    
	       	           								    if dev_sel_reg2 (7-index) = '1' then	       	           								    
	       	           								    	sda <= 'Z';	       	           								    	
	       	           								    else 
	       	           								    	sda <= '0';	       	           								    
	       	           								    end if;        						       	           								                               					       	           					   					 	       	           					   				                              	 
	       	           					   			elsif index = 8  then          			       	           					   		                               		
	       	           					   				index <= 9;                   	 	       	           					   				                		             
	       	           					   		 		sda <= 'Z';	  --ack to slave     	           					   		 	
	       	           					   	 		elsif index = 9 then	       	           					   	 	
	       	           					   	 			index <= 0 ;	       	           					   	 	
	       	           					   	 			s_state <= data_read1;	                					   		       	           					   	 	 		                					   		 		                					   		 	
	       	           					        	end if;	       	           					        	                					   	                					        
	       	           					   		end if;           	       	           
	       	                                  	if cnt_clk = 0 or cnt_clk = 2 then	       	                                                 
	       	                                  		scl <= not scl;	       	                                  		
	       	                                  	end if;                      	 
---------------------------------------------------------------------------------------------------------------------------------------	 
						-- send address msb
	       	           when byte_add_m   =>    if cnt_clk = 3 then           	       	           					   	                                		
	       	           					   			if index < 8 then              			       	           					   			                               		
	       	           								    index <= index + 1;	       	           								    
	       	           								    if address_int (15-index) = '1' then	       	           								    
	       	           								    	sda <= 'Z';	       	           								    	
	       	           								    else 
	       	           								    	sda <= '0';	       	           								    
	       	           								    end if;        						       	           								                               					       	           					   					 	       	           					   				                              	 
	       	           					   			elsif index = 8  then          			       	           					   			                               		
	       	           					   				index <= 0;                   	 	       	           					   					                		             
	       	           					   			 	sda <= 'Z';	       	           					   			 	
	       	           					   			 	s_state <= byte_add_l;	       	           					   			 		       	           					   			 	
	       	           					        	end if;	       	           					        	       	           					   	       	           					        
	       	           					   	   end if;           	       	           
	       	                                   if cnt_clk = 0 or cnt_clk = 2 then	       	                                  
	       	                                  		scl <= not scl;	       	                                  		
	       	                                   end if;
---------------------------------------------------------------------------------------------------------------------------------------	 
					   --send address lsb
	       	           when byte_add_l   =>   	if cnt_clk = 3 then           	       	          					   	                                		
	       	          					   			if index < 8 then              			       	          					   		                               		
	       	          							    	index <= index + 1;	       	          							    	
	       	          							    	if address_int (7-index) = '1' then	       	           							    
	       	           							    		sda <= 'Z';	       	           							    	
	       	           							    	else 
	       	           							    		sda <= '0';	       	           							    
	       	           							    	end if;        						       	          							                               					       	          					   					 	       	          					   			                              	 
	       	          					   			elsif index = 8  then          			       	          					   		                               		
	       	          					   				index <= 0;                   	 	       	          					   				                		             
	       	          					   		 		sda <= 'Z';	  -- start read bit     	          					   		 	
	       	          					   		 		s_state <= prestart;	       	          					   		 		
	       	          					        	end if;	               					      	               					   	   	       	          					        
	       	          					   	  	end if;                  	          
	       	                                 	if cnt_clk = 0 or cnt_clk = 2 then	       	                                 
	       	                                 		scl <= not scl;	       	                                 		
	       	                                	end if;                                                					    
-----------------------------------------------------------------------------------------------------------------------------------------------	       	          					    
	       	           	       	           
	       	           when data_read1   =>	if cnt_clk = 0 then           	       	          					   	                                		
	       	          					   			if index < 8 then              			       	          					   		                               		
	       	          							    	index <= index + 1;        						       	          							                               				
	       	          					   				data2read (15-index) <= sda;	       	          					   				
	       	          					   			elsif index = 8 then	       	          					   			
	       	          					   		    	index <= 9;	       	          					   						 
	       	          					   			end if;	       	          					   			
	       	          					   	end if;	       	          					   			                              	 
	       	          					   	if index = 8 then	       	          					   		
	       	          					   	   	if cnt_clk = 3 then	       	          					   	    	   
	       	          					   	    	sda <= '0';	       	          					   	    		
	       	          					   	    end if;	       	          					   	    	
	       	          					   	elsif index = 9 then	       	          					   	     
	       	          					   	   	if cnt_clk = 3 then	       	          					   	    		
	       	          					   	   	   sda <='Z';	       	          					   	    		   
	       	          					   	   	   s_state <= data_read2;	       	          					   	    		   
	       	          					   	   	   index <= 0;	       	          					   	    		    		   
	       	          					        end if;
	       	          					    end if;		   	       	          					   		
	       	          					   		if cnt_clk = 0 or cnt_clk = 2 then	       	          					   			       	                                       	       	                                                
	       	                                 		scl <= not scl;	       	                                 		
	       	                                 	end if;
------------------------------------------------------------------------------------------------------------------------------------------------	       	                                 	      	       	          					   			               					   		 		       	          					   		 	
	       	          	   	       	          	
	       	          	when data_read2   =>   if index < 8 then	       	          	
	       	          								if cnt_clk = 0 then 	       	          									
	       	          									data2read (7-index) <= sda;	       	          									
	       	          									index <= index + 1;	       	          									
	       	          								end if;	       	          								
	       	          						   elsif index = 8 then	       	          						   	 	               						                 						   	               						     	               						   	 
	       	          						   	 	if cnt_clk = 3 then	       	          						   	 	       	          						   	 	 	       	          						   	 	       	          						   	 		       	          						   	 	
	       	          						   	 		sda <= 'Z';	       	          						   	 		
	       	          						   	 		s_state <= prestop;	       	          						   	 			       	          						   	 			       	          						   	 			       	          						   	 			       	          						   	 		
	       	          						   	 		index <= 0 ;       	          						   	 			       	          						   	 	       	          						   	 			       	          						   	        	          						   	 
	       	          						   	 	end if;				       	          						   	 			    	
	       	          						   elsif index = 9 then	       	          						   		
	       	          						   		if cnt_clk = 3 then	       	          						   		
	       	          						   			sda <= 'Z';	       	          						   			
	       	          						   			index <= 0 ;	       	          						   			
	       	          						   			s_state <= data_read1;	       	          						   				       	          						   			       	          						   				       	          						   			
	       	          						   		end if;	       	          						   		
	       	          						   end if;						 	       	          									
           	                                   if cnt_clk = 0 or cnt_clk = 2 then               	                                  
 	       	                                  		scl <= not scl; 	       	                                 		
	       	                                   end if;	               	
---------------------------------------------------------------------------------------------------------------------------------------------------                                       
	       	            		       	            
	       	           when prestop     =>	if cnt_clk = 3 then	       	           
	       	           							sda <= '0';	       	           								
	       	           							s_state <= stop;	       	           							
	       	           				     	end if;		       	           							                       
	       	                                if cnt_clk = 0 or cnt_clk = 2 then
	       	                                		scl <= not scl; 	       	                                      	                                            
	       	                                end if;
------------------------------------------------------------------------------------------------------------------------------------
	       	           when stop       => 	if cnt_clk = 1 then	       	            
	       	           							sda <= 'Z' ;	       	            						
	       	            						s_state <= idle_s;              	       	            						
	       	            						read_finish <= '1';	       	            						      	            							                 						
	       	            				   	end if;	       	            				   
	       	            				   	if cnt_clk = 0 or cnt_clk = 2 then	       	            				   
	       	                                		scl <= not scl; 	       	                                      	                                            
	       	                                end if;

	       	                           		
---------------------------------------------------------------------------------------------------------------------------------------------------	       	                                	       	                              	       	                           	       	            				   
	       	          when others    =>     null;  				   	                       	       	                                   	       	                                   
           	      end case;           	      
           	   else          	   
           	   	    write_finish <='0';           	   	    
           	   	    read_finish  <='0';           	   	          	   	           	   	      
           	   end if;          	   
            end if;            
        end if;        
end process;     
---------------------------------------------------------------------------------- added by Tzvika Sweetkin 26/07/2023
rd_done <= read_finish;
wr_done <= write_finish;
----------------------------------------------------------------------------------                       
END ARCHITECTURE behave;




