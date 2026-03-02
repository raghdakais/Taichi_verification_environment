
-----------------------------------------------------------
-----------------------------------------------------------

-- Date : 19/09/2023
-----------------------------------------------------------
-- Designer  : Dalit Cohen
-----------------------------------------------------------
-- Block Name:Buffer Calculator HD (full quality)
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
	
ENTITY Buffer_Calculator_HD IS  ---HD (full)
GENERIC (MAX_buffer_size: integer :=104);
PORT( 
--------------------------------------------------------------------------------------------------------------------------------
			
			CLK           		    : IN     STD_LOGIC;
			RESET         	        : IN     STD_LOGIC;		
		    HD_write_addr   	    : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address					
			HD_read_addr  	        : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address	
			HD_write_pointer   	    : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address					
			HD_read_pointer  	    : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --32 bit vector pointer of address				
			HD_buffer_start_pointer : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address		
			HD_buffer_end_pointer   : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);   --32 bit vector pointer of address		
			OverRun_HD_reset_flag   : IN   STD_LOGIC;
			IP 			            : IN   STD_LOGIC;
		--	Min_reading_pointer_gap_reg : IN     STD_LOGIC_VECTOR(31 DOWNTO 0);  --add by  Dalit 18/12/2023
			HD_buffer_free_size	    : OUT    STD_LOGIC_VECTOR(31 DOWNTO 0);
			HD_buffer_free_size_change : OUT   STD_LOGIC;  --add by  Dalit 6/12/2023
			HD_buffer_OverRun		: OUT   STD_LOGIC	
		--	HD_buffer_deep	    : OUT    STD_LOGIC_VECTOR(31 DOWNTO 0)	--add by  Dalit 19/12/2023	
		
    );

--------------------------------------------------------------------------------------------------------------------------------
END Buffer_Calculator_HD;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF Buffer_Calculator_HD IS
--------------------------------------------------------------------------------------------------------------------------------

signal buffer_deep 		 	    : std_logic_vector (31 downto 0):=(others =>'0');
constant BUFFER_DEEP_C : std_logic_vector (31 downto 0):= std_logic_vector(resize(FOUR_G_END_ADDR,32)) - std_logic_vector(resize(RAW_DATA_BASE_ADDR,32)); -- 22/08/2024
signal s_HD_buffer_OverRun 		: std_logic:='0';   
signal size_change 		        : std_logic:='0';  --add by  Dalit 6/12/2023
signal s_HD_read_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0'); --add by  Dalit 6/12/2023
signal s_HD_write_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0'); --add by  Dalit 6/12/2023
signal s_OverRun_HD_reset_flag  : std_logic_vector (2 downto 0):=(others =>'0'); --add by  Dalit 6/12/2023   
signal s_IP                     : std_logic_vector (3 downto 0):=(others =>'0'); --add by  Dalit 13/12/2023 
signal IP_count                     :integer range 0 to 12; --add by  Dalit 13/12/2023 
signal Start_checking_overrun 		: std_logic:='0';  --add by  Dalit 13/12/2023 

attribute DONT_TOUCH                    : string;
attribute DONT_TOUCH of HD_write_addr, HD_read_addr, HD_write_pointer, HD_read_pointer,HD_buffer_start_pointer,HD_buffer_end_pointer,buffer_deep,size_change,OverRun_HD_reset_flag,HD_buffer_free_size,HD_buffer_free_size_change,HD_buffer_OverRun : signal is "true"; 
attribute mark_debug                    : string;
attribute mark_debug of HD_write_addr, HD_read_addr, HD_write_pointer, HD_read_pointer,HD_buffer_start_pointer,HD_buffer_end_pointer,buffer_deep,size_change,OverRun_HD_reset_flag,HD_buffer_free_size,HD_buffer_free_size_change,HD_buffer_OverRun : signal is "true";
   
--------------------------------------------------------------------------------------------------------------------------------
BEGIN
--------------------------------------------------------------------------------------------------------------------------------

 
 PROCESS(CLK, RESET)
	BEGIN
		IF (RESET ='1') THEN

          -- buffer_deep <= HD_buffer_end_pointer - HD_buffer_start_pointer;
          buffer_deep <= BUFFER_DEEP_C; -- 22/08/2024
			s_HD_buffer_OverRun<='0';
			s_HD_write_addr <= (others=>'0');        --add by  Dalit 6/12/2023
			s_HD_read_addr <= (others=>'0');        --add by  Dalit 6/12/2023
			s_OverRun_HD_reset_flag <= (others=>'0');  --add by  Dalit 6/12/2023
			size_change<='0';  --add by  Dalit 6/12/2023
			HD_buffer_free_size_change<='0'; --add by  Dalit 6/12/2023
			HD_buffer_free_size<= (others=>'0');        --add by  Dalit 6/12/2023
			s_IP <=(others=>'0');  --add by  Dalit 13/12/2023
			IP_count <=0;
			Start_checking_overrun <='0';
			 
		ELSIF CLK'EVENT AND CLK ='1' THEN
		
			buffer_deep <= HD_buffer_end_pointer - HD_buffer_start_pointer;
            s_HD_write_addr<= HD_write_addr; --add by  Dalit 6/12/2023
            s_HD_read_addr<= HD_read_addr; --add by  Dalit 6/12/2023
            s_OverRun_HD_reset_flag<= s_OverRun_HD_reset_flag(1 downto 0) & OverRun_HD_reset_flag; --add by  Dalit 6/12/2023
			 s_IP<=s_IP(2 downto 0) & IP; 
			
			if ( HD_write_addr/=s_HD_write_addr or HD_read_addr/=s_HD_read_addr) then --add by  Dalit 6/12/2023
                 size_change<='1';                                                      --add by  Dalit 6/12/2023
            --	if HD_write_addr> HD_read_addr and s_HD_buffer_OverRun='0' THEN	
                if HD_write_addr> HD_read_addr  THEN									
                    HD_buffer_free_size<=buffer_deep-(HD_write_addr-HD_read_addr);
                -- elsif HD_write_addr> HD_read_addr and s_HD_buffer_OverRun='1' THEN									---if write is biger then read but there is overrun the buffer size is 0
                    -- HD_buffer_free_size<=x"00000000";
                elsif HD_read_addr>HD_write_addr then  							---when the write get to the end of the buffer and start again to write at the start of the buffer but the read still read from the end of the buffer,--no possible option that the read will over the write
                    HD_buffer_free_size<=HD_read_addr-HD_write_addr-1;
                elsif HD_read_addr=HD_write_addr then 
                    HD_buffer_free_size<=HD_write_addr-HD_read_addr;
                end if;
             else                               --add by  Dalit 6/12/2023
                  size_change<='0';             --add by  Dalit 6/12/2023
             end if;                            --add by  Dalit 6/12/2023
                
			--add by  Dalit 6/12/2023
			if size_change='1' then
			     HD_buffer_free_size_change<='1';
			else
				 HD_buffer_free_size_change<='0';
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
		--	if HD_write_pointer-HD_read_pointer >= Min_reading_pointer_gap_reg then  --defult x"00000005"--- less then 5 buffer pointers (Doron wait 8 pointers of write before start read, therfore if i will start checking overrun at the begining i will get an error)
	        if HD_write_pointer-HD_read_pointer >= std_logic_vector(resize(Min_reading_pointer_gap_reg,32)) then 
			    Start_checking_overrun<='1';
			end if;
			
			if s_overrun_HD_reset_flag(2)='1' then 
				s_HD_buffer_OverRun<='0';
			elsif  Start_checking_overrun='1' and  HD_write_pointer-HD_read_pointer>=x"00000000" and HD_write_pointer-HD_read_pointer<std_logic_vector(resize(Min_reading_pointer_gap_reg,32)) then --defult x"00000005"-- less then 5 buffer pointers (Doron wait 5 pointers of write before start read)
				s_HD_buffer_OverRun<='1';
			else
				s_HD_buffer_OverRun<=s_HD_buffer_OverRun;
			end if;
			

	   END IF;
	END PROCESS;
	
HD_buffer_OverRun<=s_HD_buffer_OverRun;
--HD_buffer_deep<= buffer_deep;
--------------------------------------------------------------------------------------------------------------------------------
END ARCHITECTURE BEHAVE;
--------------------------------------------------------------------------------------------------------------------------------
















