
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
-- 12/2023 Dalit Cohen
-- 12/01/2025 Eugene Shinderman
------------------------------------------------------------
------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
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
			HD_buffer_free_size	    : OUT    STD_LOGIC_VECTOR(31 DOWNTO 0);
			HD_buffer_free_size_change : OUT   STD_LOGIC;
			HD_buffer_OverRun		: OUT   STD_LOGIC	
    );

--------------------------------------------------------------------------------------------------------------------------------
END Buffer_Calculator_HD;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF Buffer_Calculator_HD IS
--------------------------------------------------------------------------------------------------------------------------------

signal buffer_deep 		 	    : unsigned(31 downto 0):=(others =>'0');
signal s_HD_buffer_OverRun 		: std_logic:='0';   
signal size_change 		        : std_logic:='0';
signal s_HD_read_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0');
signal s_HD_write_addr 		 	: std_logic_vector (31 downto 0):=(others =>'0');
signal s_OverRun_HD_reset_flag  : std_logic_vector (2 downto 0):=(others =>'0');
-- signal s_IP                     : std_logic_vector (3 downto 0):=(others =>'0');
signal IP_count                     :integer range 0 to 12;
signal Start_checking_overrun 		: std_logic:='0';
signal HD_buffer_free_size_i	    : unsigned(31 DOWNTO 0);

attribute DONT_TOUCH                    : string;
attribute DONT_TOUCH of HD_write_addr, HD_read_addr, HD_write_pointer, HD_read_pointer,HD_buffer_start_pointer,HD_buffer_end_pointer,buffer_deep,size_change,OverRun_HD_reset_flag,HD_buffer_free_size_i,HD_buffer_free_size_change,HD_buffer_OverRun : signal is "true"; 
attribute mark_debug                    : string;
attribute mark_debug of HD_write_addr, HD_read_addr, HD_write_pointer, HD_read_pointer,HD_buffer_start_pointer,HD_buffer_end_pointer,buffer_deep,size_change,OverRun_HD_reset_flag,HD_buffer_free_size_i,HD_buffer_free_size_change,HD_buffer_OverRun : signal is "true";
   

BEGIN

 
 PROCESS(CLK, RESET)
	BEGIN
		IF (RESET ='1') THEN

            buffer_deep  <=  HD_BUFFER_DEEP;  -- 22/08/2024
			s_HD_buffer_OverRun <= '0'; 
			s_HD_write_addr  <=  (others => '0'); 
			s_HD_read_addr  <=  (others => '0'); 
			s_OverRun_HD_reset_flag  <=  (others => '0'); 
			size_change <= '0'; 
			HD_buffer_free_size_change <= '0'; 
			HD_buffer_free_size_i <=  (others => '0'); 
			-- s_IP  <= (others=>'0'); 
			IP_count <=0; 
			Start_checking_overrun <='0'; 
			 
		ELSIF CLK'EVENT AND CLK ='1' THEN
		
            buffer_deep  <=  HD_BUFFER_DEEP;  -- 22/08/2024
            s_HD_write_addr<= HD_write_addr;
            s_HD_read_addr<= HD_read_addr;
            s_OverRun_HD_reset_flag<= s_OverRun_HD_reset_flag(1 downto 0) & OverRun_HD_reset_flag;
			-- s_IP<=s_IP(2 downto 0) & IP; 
			
			if ( HD_write_addr/=s_HD_write_addr or HD_read_addr/=s_HD_read_addr) then
                 size_change<='1';
                if HD_write_addr> HD_read_addr  THEN									
                    HD_buffer_free_size_i<=buffer_deep-(unsigned(HD_write_addr)-unsigned(HD_read_addr));
                elsif HD_read_addr>HD_write_addr then  							---when the write get to the end of the buffer and start again to write at the start of the buffer but the read still read from the end of the buffer,--no possible option that the read will over the write
                    HD_buffer_free_size_i<=unsigned(HD_read_addr)-unsigned(HD_write_addr);
                elsif HD_read_addr=HD_write_addr then 
                    HD_buffer_free_size_i<=unsigned(HD_write_addr)-unsigned(HD_read_addr);
                end if;
            else
              size_change<='0';
            end if;
                
			if size_change='1' then
			     HD_buffer_free_size_change<='1';
			else
				 HD_buffer_free_size_change<='0';
		    end if;
		    
            --	if HD_write_pointer-HD_read_pointer >= Min_reading_pointer_gap_reg then  --defult x"00000005"--- less then 5 buffer pointers (Doron wait 8 pointers of write before start read, therfore if i will start checking overrun at the begining i will get an error)
	        if ((unsigned(HD_write_pointer)-unsigned(HD_read_pointer)) >= resize(Min_reading_pointer_gap_reg,32)) then 
			    Start_checking_overrun<='1';
			end if;
			
			-- if s_overrun_HD_reset_flag(2)='1' then 
			--     s_HD_buffer_OverRun<='0';
			-- elsif  Start_checking_overrun='1' and  HD_write_pointer-HD_read_pointer>=x"00000000" and HD_write_pointer-HD_read_pointer<std_logic_vector(resize(Min_reading_pointer_gap_reg,32)) then --defult x"00000005"-- less then 5 buffer pointers (Doron wait 5 pointers of write before start read)
			--     s_HD_buffer_OverRun<='1';
			-- else
			--     s_HD_buffer_OverRun<=s_HD_buffer_OverRun;
			-- end if;
			-- !debug: 12/01/2025 was overflow calc check PTR, now overflow calc check HD space
			if s_overrun_HD_reset_flag(2)='1' then 
				s_HD_buffer_OverRun<='0';
			elsif (Start_checking_overrun='1') then
              if (HD_buffer_free_size_i < (resize(Min_reading_pointer_gap_reg,32)*X"00001080")) then
				s_HD_buffer_OverRun<='1'; -- hold if no reset or overrun_HD_reset_flag
              end if;
			end if;

	   END IF;
	END PROCESS;

    HD_buffer_free_size <= std_logic_vector(HD_buffer_free_size_i);	
    HD_buffer_OverRun<=s_HD_buffer_OverRun;

 END ARCHITECTURE BEHAVE;
