
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
-- 12/2023 Dalit Cohen
-- 12/01/2025 Eugene Shinderman
------------------------------------------------------------
------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.tbuf_pack.all;
	
ENTITY Buffer_Calculator_RTL IS  
PORT( 
--------------------------------------------------------------------------------------------------------------------------------
			
			CLK           		  				    	 : IN   STD_LOGIC;
			RESET         	     					     : IN   STD_LOGIC;		
		    RTL_write_addr   	 	 					 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address					
			RTL_read_addr  	         				     : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address			
			OverRun_RTL_reset_flag 					     : IN   STD_LOGIC;
			RTL_buffer_start_pointer 					 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address		
			RTL_buffer_end_pointer   					 : IN   STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address		
			IP 			                                 : IN   STD_LOGIC;
			RTL_buffer_free_size	   					 : OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);  
			RTL_buffer_free_size_change                  : OUT  STD_LOGIC;
			RTL_buffer_OverRun		   					 : OUT  STD_LOGIC
    );

--------------------------------------------------------------------------------------------------------------------------------
END Buffer_Calculator_RTL;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF Buffer_Calculator_RTL IS
--------------------------------------------------------------------------------------------------------------------------------

  signal buffer_deep 		 	 :  unsigned(31 downto 0) := (others =>'0'); 
  signal s_RTL_buffer_OverRun 		 	: std_logic:='0';        
  signal size_change 		        : std_logic:='0';
  signal s_RTL_read_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0');
  signal s_RTL_write_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0');
  signal s_OverRun_RTL_reset_flag    : std_logic_vector (2 downto 0):=(others =>'0'); 
  -- signal s_IP                         : std_logic_vector (3 downto 0):=(others =>'0'); 
  signal IP_count                     :integer range 0 to 12; 
  signal Start_checking_overrun 		: std_logic:='0'; 
  signal RTL_buffer_free_size_i : unsigned(31 DOWNTO 0);  -- 12/01/2025

  attribute DONT_TOUCH                    : string; 
  attribute DONT_TOUCH of RTL_write_addr,  RTL_read_addr, RTL_buffer_start_pointer, RTL_buffer_end_pointer, buffer_deep, size_change, OverRun_RTL_reset_flag, RTL_buffer_free_size_i, RTL_buffer_free_size_change, RTL_buffer_OverRun : signal is "true";  
  attribute mark_debug                    : string; 
  attribute mark_debug of RTL_write_addr,  RTL_read_addr,  RTL_buffer_start_pointer, RTL_buffer_end_pointer, buffer_deep, size_change, OverRun_RTL_reset_flag, RTL_buffer_free_size_i, RTL_buffer_free_size_change, RTL_buffer_OverRun : signal is "true"; 
   

BEGIN


 PROCESS(CLK, RESET)
	BEGIN
		IF (RESET ='1') THEN

            buffer_deep <= RTL_BUFFER_DEEP; -- 12/01/2025
			s_RTL_buffer_OverRun<='0';
			s_RTL_write_addr <= (others=>'0');
			s_RTL_read_addr <= (others=>'0'); 
			s_OverRun_RTL_reset_flag <= (others=>'0');
			size_change<='0';
			RTL_buffer_free_size_change<='0';
			RTL_buffer_free_size_i<= (others=>'0');
			-- s_IP <=(others=>'0');
			IP_count <=0;
			Start_checking_overrun <='0';
			
		ELSIF CLK'EVENT AND CLK ='1' THEN
				
            buffer_deep <= RTL_BUFFER_DEEP; -- 12/01/2025
          
			s_RTL_write_addr<= RTL_write_addr;
            s_RTL_read_addr<= RTL_read_addr;
            s_OverRun_RTL_reset_flag<= s_OverRun_RTL_reset_flag(1 downto 0) & OverRun_RTL_reset_flag;
            -- s_IP<=s_IP(2 downto 0) & IP; 
			
			if ( RTL_write_addr/=s_RTL_write_addr or RTL_read_addr/=s_RTL_read_addr) then
                size_change<='1';
                if RTL_write_addr> RTL_read_addr  THEN				
                    RTL_buffer_free_size_i<=buffer_deep-(unsigned(RTL_write_addr)-unsigned(RTL_read_addr));

                elsif RTL_read_addr>RTL_write_addr then  								---when the write get to the end of the buffer and start again to write at the start of the buffer but the read still read from the end of the buffer,--no possible option that the read will over the write
                    RTL_buffer_free_size_i<=unsigned(RTL_read_addr)-unsigned(RTL_write_addr);
                elsif RTL_read_addr=RTL_write_addr then
                  RTL_buffer_free_size_i<= unsigned(RTL_write_addr)-unsigned(RTL_read_addr);
                end if;
              else
                  size_change<='0';
             end if;
                
			if size_change='1' then
			     RTL_buffer_free_size_change<='1';
			else
				 RTL_buffer_free_size_change<='0';
		    end if;


           if ((unsigned(RTL_write_addr)-unsigned(RTL_read_addr)) >= (resize(Min_reading_gap,32)*X"00001080")) then
            Start_checking_overrun<='1';
           end if;
			
            -- reading size=((32 detector(X) * 64 slices (Z))+64 header )* 16 bits (word) --> 33792/32bit =1056b ->420hex *4 (32 bit addrres increamented by 4) =1080hex
            -- 5 * 1080hex  -- less then 5 readings
			-- if s_OverRun_RTL_reset_flag(2)='1' then 
			--     s_RTL_buffer_OverRun<='0';
            -- elsif (Start_checking_overrun='1' and (unsigned(RTL_write_addr)-unsigned(RTL_read_addr))>=0 and
            --        (unsigned(RTL_write_addr)-unsigned(RTL_read_addr))<(resize(Min_reading_gap,32)*X"00001080")) then	
			--     s_RTL_buffer_OverRun<='1';
			-- else
			--     s_RTL_buffer_OverRun<=s_RTL_buffer_OverRun;
			-- end if;
            -- !debug: 12/01/2025
			if s_OverRun_RTL_reset_flag(2)='1' then 
				s_RTL_buffer_OverRun<='0';
            elsif (Start_checking_overrun='1') then
              if (RTL_buffer_free_size_i < (resize(Min_reading_gap,32)*X"00001080")) then
				s_RTL_buffer_OverRun<='1'; -- hold if no reset or OverRun_RTL_reset_flag
              end if;
			end if;
			

	   END IF;
	END PROCESS;

	RTL_buffer_free_size <= std_logic_vector(RTL_buffer_free_size_i);
    RTL_buffer_OverRun<=s_RTL_buffer_OverRun;
    
 END ARCHITECTURE BEHAVE;






















