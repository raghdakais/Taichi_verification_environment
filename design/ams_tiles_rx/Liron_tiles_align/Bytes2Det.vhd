--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.Phoebe.all;
-------------------------------------------------------------------------------

ENTITY Bytes2Det IS
    
    PORT( 
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		Bytes_per_det           : IN    integer  range 3 to 5;				
		RX_det_o       	        : IN   std_logic_vector (7 downto 0);
		Phoebe_data_locked		: IN    std_logic;
		data_valid              : IN   std_logic;	
		footer_valid            : IN   std_logic_vector (6 downto 1);
		footer_valid_o	     	: OUT   std_logic_vector (6 downto 1);
		det2load_o		        : OUT   std_logic_vector (39 downto 0);
		load_o	                : OUT    std_logic		
    );
END Bytes2Det;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ARCHITECTURE behave OF Bytes2Det IS
-------------------------------------------------------------------------------
 	
	SIGNAL RX_det_o_d       	       : std_logic_vector (7 downto 0);         
	SIGNAL RX_det_o_dd                 : std_logic_vector (7 downto 0);
	SIGNAL data_valid_d                : std_logic;
	SIGNAL data_valid_dd               : std_logic;  
	SIGNAL cnt2load                    : natural range 0 to 7:=2; 
    SIGNAL load_i 	                   : std_logic:='0';  
	Signal det2load                    : std_logic_vector (39 downto 0);
	signal footer_valid_d              : std_logic_vector (6 downto 1);
	signal footer_valid_dd             : std_logic_vector (6 downto 1);
	signal footer_valid_dd_i           : std_logic_vector (6 downto 1);
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
BEGIN

----------------------------------------------------

	process(RESET,CLKDIV)
	begin
		if (RESET = '1') then
			RX_det_o_d     <= (others=>'0');
            RX_det_o_dd    <= (others=>'0');
            data_valid_d   <= '0';
            data_valid_dd  <= '0';	
			footer_valid_d<= (others=>'0');
			footer_valid_dd<= (others=>'0');
			
		elsif rising_edge(CLKDIV) then		
			RX_det_o_d<=RX_det_o;
			RX_det_o_dd<=RX_det_o_d;
			data_valid_d<=data_valid;
			data_valid_dd<=data_valid_d;
			footer_valid_d<= footer_valid;
			footer_valid_dd<= footer_valid_d;
		end if;
	end process;
------------------------------------------------------
process(RESET,CLKDIV)
	begin
		if (RESET = '1') then		
			cnt2load<=2;			
			det2load<=(others=>'1');					
			det2load_o<=(others=>'1');			
			load_i<='0';
			load_o<='0';
			footer_valid_dd_i<= (others=>'0');
			footer_valid_o<= (others=>'0');
		elsif rising_edge(CLKDIV) then
----------------------------------------				    
			if Phoebe_data_locked='1' then
			load_o<=load_i;
			footer_valid_o <= footer_valid_dd_i;
			else 
			load_o<='0';
			footer_valid_o<= (others=>'0');
			end if;
-----------------------------------------------			
			if data_valid_dd='1' or footer_valid_dd >0 then--
			    if cnt2load=0 then
					cnt2load<=Bytes_per_det-1;
				else	
					cnt2load<=cnt2load-1;
				end if;
			else	
				cnt2load<=Bytes_per_det-1;
			end if;
------------------------------------------------------			
			if data_valid_dd='1'  or footer_valid_dd > 0 then --
				det2load(39 downto 32)<=RX_det_o_dd;
			    det2load(31 downto 24)<=det2load(39 downto 32);
				det2load(23 downto 16)<=det2load(31 downto 24);
				det2load(15 downto 8)<=det2load(23 downto 16);
				det2load(7 downto 0)<=det2load(15 downto 8);										
			end if;
---------------------------------------------------------
            
            if cnt2load=0 then	
				load_i<='1';
				footer_valid_dd_i<= footer_valid_dd;
			else	
			    load_i<='0';
				footer_valid_dd_i<= (others=>'0');
			end if;
			
			if load_i='1' then
				case Bytes_per_det is
					when 3      =>  det2load_o <= x"0000" & det2load(39 downto 16);
					When 4      =>  det2load_o <= x"00" & det2load(39 downto 8);	
					When 5      =>  det2load_o <= det2load(39 downto 0);
					when others =>  det2load_o <= x"0000" & det2load(39 downto 16); 
					end case;				
			end if;
--------------------------------------------------------------------------			
						
--------------------------------------------------------------				
		end if;
	end process;

------------------------------------------------------------------------------
END architecture behave;
-------------------------------------------------------------------------------
