
-----------------------------------------------------------
-----------------------------------------------------------

-- Date : 19/09/2023
-----------------------------------------------------------
-- Designer  : Dalit Cohen
-----------------------------------------------------------
-- Block Name:Buffer Calculator RTL
-----------------------------------------------------------
-- simulation tool : ModelSim PE 10.7a
------------------------------------------------------------
-- Versions :
--  --01.01 First version

------------------------------------------------------------
------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
use work.tbuf_pack.all;
	
ENTITY Buffer_Calculator_RTL IS  
PORT( 
--------------------------------------------------------------------------------------------------------------------------------
			
			CLK           		  				    	 : IN   STD_LOGIC;
			RESET         	     					     : IN   STD_LOGIC;		
		    RTL_write_addr   	 	 					 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address					
			RTL_read_addr  	         				     : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address			
		--	Min_reading_gap                              : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address	 --eadit by Dalit 17/12/2023	
			OverRun_RTL_reset_flag 					     : IN   STD_LOGIC;
			RTL_buffer_start_pointer 					 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address		
			RTL_buffer_end_pointer   					 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address		
			IP 			                                 : IN   STD_LOGIC;
			RTL_buffer_free_size	   					 : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);  
			RTL_buffer_free_size_change                  : OUT  STD_LOGIC;  --add by  Dalit 6/12/2023 
			RTL_buffer_OverRun		   					 : OUT  STD_LOGIC
		--	RTL_buffer_deep	   					         : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0) --add by  Dalit 19/12/2023  

    );

--------------------------------------------------------------------------------------------------------------------------------
END Buffer_Calculator_RTL;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF Buffer_Calculator_RTL IS
--------------------------------------------------------------------------------------------------------------------------------

signal buffer_deep 		 	: std_logic_vector (31 downto 0):=(others =>'0');
constant BUFFER_DEEP_C : std_logic_vector (31 downto 0):= std_logic_vector(resize(EV_DATA_END_ADDR,32)) - std_logic_vector(resize(EV_DATA_BASE_ADDR,32)); -- 22/08/2024  
--signal s_number_of_reding_size_for_RTL_OverRun_offset 		 	: std_logic_vector (63 downto 0):=(others =>'0'); 
--signal number_of_reding_size_for_RTL_OverRun_offset_conv :integer range 0 to 30;
signal s_RTL_buffer_OverRun 		 	: std_logic:='0';       
signal size_change 		        : std_logic:='0';  --add by  Dalit 6/12/2023
signal s_RTL_read_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0'); --add by  Dalit 6/12/2023
signal s_RTL_write_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0'); --add by  Dalit 6/12/2023
signal s_OverRun_RTL_reset_flag    : std_logic_vector (2 downto 0):=(others =>'0'); --add by  Dalit 6/12/2023                       
signal s_IP                         : std_logic_vector (3 downto 0):=(others =>'0'); --add by  Dalit 13/12/2023 
signal IP_count                     :integer range 0 to 12; --add by  Dalit 13/12/2023 
signal Start_checking_overrun 		: std_logic:='0';  --add by  Dalit 13/12/2023 

attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of RTL_write_addr, RTL_read_addr,RTL_buffer_start_pointer,RTL_buffer_end_pointer,buffer_deep,size_change,OverRun_RTL_reset_flag,RTL_buffer_free_size,RTL_buffer_free_size_change,RTL_buffer_OverRun : signal is "true"; 
  attribute mark_debug                    : string;
  attribute mark_debug of RTL_write_addr, RTL_read_addr, RTL_buffer_start_pointer,RTL_buffer_end_pointer,buffer_deep,size_change,OverRun_RTL_reset_flag,RTL_buffer_free_size,RTL_buffer_free_size_change,RTL_buffer_OverRun : signal is "true";
   
--------------------------------------------------------------------------------------------------------------------------------
BEGIN
--------------------------------------------------------------------------------------------------------------------------------

--number_of_reding_size_for_RTL_OverRun_offset_conv <= conv_integer(number_of_reding_size_for_RTL_OverRun_offset);
 
 PROCESS(CLK, RESET)
	BEGIN
		IF (RESET ='1') THEN

            -- buffer_deep <= RTL_buffer_end_pointer - RTL_buffer_start_pointer;
            buffer_deep <= BUFFER_DEEP_C; -- 22/08/2024
			s_RTL_buffer_OverRun<='0';
			s_RTL_write_addr <= (others=>'0');        --add by  Dalit 6/12/2023
			s_RTL_read_addr <= (others=>'0');        --add by  Dalit 6/12/2023
			s_OverRun_RTL_reset_flag <= (others=>'0');  --add by  Dalit 6/12/2023
			size_change<='0';  --add by  Dalit 6/12/2023
			RTL_buffer_free_size_change<='0'; --add by  Dalit 6/12/2023
			RTL_buffer_free_size<= (others=>'0');        --add by  Dalit 6/12/2023
			s_IP <=(others=>'0');  --add by  Dalit 13/12/2023
			IP_count <=0;
			Start_checking_overrun <='0';
			
		ELSIF CLK'EVENT AND CLK ='1' THEN
		
			
			buffer_deep <= RTL_buffer_end_pointer - RTL_buffer_start_pointer;
			
			s_RTL_write_addr<= RTL_write_addr; --add by  Dalit 6/12/2023
            s_RTL_read_addr<= RTL_read_addr; --add by  Dalit 6/12/2023
            s_OverRun_RTL_reset_flag<= s_OverRun_RTL_reset_flag(1 downto 0) & OverRun_RTL_reset_flag; --add by  Dalit 6/12/2023
            s_IP<=s_IP(2 downto 0) & IP; 
			
			if ( RTL_write_addr/=s_RTL_write_addr or RTL_read_addr/=s_RTL_read_addr) then  --add by  Dalit 6/12/2023
                size_change<='1';                                                          --add by  Dalit 6/12/2023
            --	if RTL_write_addr> RTL_read_addr and s_RTL_buffer_OverRun<='0' THEN	
                if RTL_write_addr> RTL_read_addr  THEN				
                    RTL_buffer_free_size<=buffer_deep-(RTL_write_addr-RTL_read_addr);
                -- elsif RTL_write_addr> RTL_read_addr and s_RTL_buffer_OverRun<='1' THEN										---if write is biger then read but there is overrun the buffer size is 0
                    -- RTL_buffer_free_size<=x"00000000";
                elsif RTL_read_addr>RTL_write_addr then  								---when the write get to the end of the buffer and start again to write at the start of the buffer but the read still read from the end of the buffer,--no possible option that the read will over the write
                    RTL_buffer_free_size<=RTL_read_addr-RTL_write_addr-1;
                elsif RTL_read_addr=RTL_write_addr then
                  RTL_buffer_free_size<= RTL_write_addr-RTL_read_addr;
                end if;
              else                               --add by  Dalit 6/12/2023
                  size_change<='0';             --add by  Dalit 6/12/2023
             end if;                            --add by  Dalit 6/12/2023
                
			--add by  Dalit 6/12/2023
			if size_change='1' then
			     RTL_buffer_free_size_change<='1';
			else
				 RTL_buffer_free_size_change<='0';
		    end if;


			--add by  Dalit 13/12/2023
--			if (s_IP(2)='1' and s_IP(3)='0') and IP_count<10  then 
--			   IP_count <=IP_count+1;
--			   Start_checking_overrun<='0';
--			elsif (s_IP(2)='1' and s_IP(3)='0') and IP_count=10 then 
--			    Start_checking_overrun<='1';
--			else
--			     IP_count<=IP_count;
--			end if;

           --add by  Dalit 18/12/2023
        --   if RTL_write_addr-RTL_read_addr >= (Min_reading_gap)*(x"00001080")) then
           if RTL_write_addr-RTL_read_addr >= (std_logic_vector(resize(Min_reading_gap,32))*(x"00001080")) then
            Start_checking_overrun<='1';
           end if;
			
			if s_OverRun_RTL_reset_flag(2)='1' then 
				s_RTL_buffer_OverRun<='0';
		--	elsif  Start_checking_overrun='1' and RTL_write_addr-RTL_read_addr>=0 and RTL_write_addr-RTL_read_addr<((Min_reading_gap)*(x"00001080")) then  ----5 * 420hex  -- less then 5 readings - --reading size=((32 detector(X) * 64 slices (Z))+64 header )* 16 bits (word) --> 33792/32bit =1056b ->420hex *4 (32 bit addrres increamented by 4) =1080hex
		      elsif  Start_checking_overrun='1' and RTL_write_addr-RTL_read_addr>=0 and RTL_write_addr-RTL_read_addr<(std_logic_vector(resize(Min_reading_gap,32))*(x"00001080")) then	
				s_RTL_buffer_OverRun<='1';
			else
				s_RTL_buffer_OverRun<=s_RTL_buffer_OverRun;
			end if;
			

	   END IF;
	END PROCESS;
	
RTL_buffer_OverRun<=s_RTL_buffer_OverRun;
--RTL_buffer_deep <= buffer_deep;
--------------------------------------------------------------------------------------------------------------------------------
END ARCHITECTURE BEHAVE;
--------------------------------------------------------------------------------------------------------------------------------





















