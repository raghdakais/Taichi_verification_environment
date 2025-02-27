--
-- VHDL Architecture I2C_for_tmcore_lib.I2C_TMOR.behave
--
-- Created:
--          by - ilq00571.UNKNOWN (ILQHFAATC1WS159)
--          at - 14:43:05 16/01/2008
--
-- using Mentor Graphics HDL Designer(TM) 2005.3 (Build 74)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.all;

ENTITY ini_SM_TMP IS
   PORT(
      RESET         : IN    std_logic;
      clk           : IN    std_logic;
      data2write    : OUT   std_logic_vector (15 DOWNTO 0);
      ena           : buffer   std_logic;
      rw            : OUT   std_logic;
      address       : OUT   std_logic_vector (7 DOWNTO 0);
      busy          : IN    std_logic;
      ini_sm_done   : OUT   std_logic   -- 08/03/2023
   );

-- Declarations

END ini_SM_TMP ;

--
ARCHITECTURE behave OF ini_SM_TMP IS

type SM_state is (idle,wait_after_reset,wait_after_conf,conf1,conf2,conf3,rd_tmp);
signal SM             : SM_state;
signal cnt_dwn        : std_logic_vector (19 downto 0);
signal busy_vec       : std_logic_vector (2 downto 0);
signal data2read      : std_logic_vector (15 downto 0);
signal index          : integer range 0 to 3;
 ----------------------------------------------------------------


BEGIN

process (reset, clk)

	begin
	if RESET ='0' then
		SM <= IDLE;
		data2write <=x"0000";
		ena <= '0';
		rw  <='0';
		address  <= x"00";
		cnt_dwn <= x"FFFFF";
		busy_vec <="000";
		index <= 0;
	elsif clk'event and clk='1' then
		    --SM <= IDLE;
    		data2write <=x"0000";
    		--ena <= '0';
    		--rw  <='0';
    		address  <= x"00";
    		cnt_dwn <= x"FFFFF";
                -- synthesis translate_off
                cnt_dwn <= x"01FFF";
                -- synthesis translate_on
    		--busy_vec <="000";
    		--index <= 0;

		busy_vec <= busy_vec (1 downto 0) & busy;

		case SM is

		when IDLE =>
			         SM <= wait_after_reset;
			         data2write <=x"0000";
			         ena <= '0';
			         rw  <='0';
			         address  <= x"00";
	    	         cnt_dwn <= x"FFFFF";
                         -- synthesis translate_off
                         cnt_dwn <= x"01FFF";
                         -- synthesis translate_on
	    when wait_after_reset =>
	    			 index <=0;
	   		         cnt_dwn <= cnt_dwn - 1;
			         if cnt_dwn = x"00000" then
			         	SM <= conf1;
						ena<='1';
			         	cnt_dwn <= x"FFFFF";
                                        -- synthesis translate_off
                                        cnt_dwn <= x"01FFF";
                                        -- synthesis translate_on
			         end if;

		when conf1 =>
		             data2write <=x"A068";      --x"6860"                  --configuration register      OS R1 R0 F1 - F0 POL TM SD - CR1 CR0 AL EM - 0 0 0 0
		             ena <= '0';            						--							0  1  1  0  - 0  0   0  0  - 0   1   1  0  - 0 0 0 0
		             rw  <='0';
		             address  <= x"01";
		             cnt_dwn <= x"FFFFF";
                             -- synthesis translate_off
                             cnt_dwn <= x"01FFF";
                             -- synthesis translate_on
		 	         if busy_vec = "100" then
		 	         	SM <= wait_after_conf;
		 	         	ena <= '0';
		 	         end if;

		when wait_after_conf =>
		             cnt_dwn <= cnt_dwn - 1;
					 if cnt_dwn = x"00000" then
					    ena <='1';
					 	case index is
					 	when 0 =>      SM <= conf2;rw  <='0';
					 	when 1 =>      SM <= conf3;rw  <='0';
					 	when 2 =>      SM <= rd_tmp;rw  <='1';
					 	when others => SM <= rd_tmp;rw  <='1';
					 	end case;
		        		cnt_dwn <= x"FFFFF";
                                        -- synthesis translate_off
                                        cnt_dwn <= x"01FFF";
                                        -- synthesis translate_on
					 end if;

		when conf2 =>
					 data2write <=x"0037";   --x"3700"			--  lower temp  register is 55 celsius
		             ena <= '0';
		             rw  <='0';
					 address  <= x"02";
					 cnt_dwn <= x"FFFFF";
                                         -- synthesis translate_off
                                         cnt_dwn <= x"01FFF";
                                         -- synthesis translate_on
					 if busy_vec = "100" then
					 	SM <= wait_after_conf;
					 	index <= 1;
					 	ena <= '0';
					 end if;

		when conf3 =>
					 data2write <=x"003c";   	--x"3c00"		--  high temp  register is 60 celsius
	                 ena <= '0';
					 rw  <='0';
					 address  <= x"03";
					 cnt_dwn <= x"FFFFF";
                                         -- synthesis translate_off
                                         cnt_dwn <= x"01FFF";
                                         -- synthesis translate_on
					 if busy_vec = "100" then
					 	SM <= wait_after_conf;
					 	index <= 2;
					 	ena <= '0';
					 end if;

		when rd_tmp =>
					 data2write <=X"0000";
		             ena <= '0';
					 rw  <='1';
					 address  <= x"00";
					 cnt_dwn <= x"FFFFF";
                                         -- synthesis translate_off
                                         cnt_dwn <= x"01FFF";
                                         -- synthesis translate_on
					 if busy_vec = "100" then
					 	SM <= wait_after_conf;
					 	index <= 2;
					 	ena <= '0';
					 end if;
		end case;

	end if;
end process;


misc_pr: process (clk, reset) is
begin  -- process misc_pr
  if (reset = '0') then                 -- asynchronous reset (active low)
    ini_sm_done <= '0';
  elsif (clk'event and clk = '1') then  -- rising clock edge

    if (SM = wait_after_conf and index = 2 and cnt_dwn < x"000FF") then
      ini_sm_done <= '1';
    else
      ini_sm_done <= '0';              
    end if;
    
  end if;
end process misc_pr;


----------------------------------------------------------------------------
END ARCHITECTURE behave;
