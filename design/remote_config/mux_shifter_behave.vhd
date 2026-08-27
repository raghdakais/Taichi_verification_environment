--
-- VHDL Architecture CAN_CTL_lib.mux_shifter.behave
--
-- Created:
--          by - ILQ00571.UNKNOWN (ILQHFAATC1NB350)
--          at - 11:48:09 05/01/2011
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY mux_shifter IS
   PORT( 
      IR              : IN     std_logic_vector (7 DOWNTO 0);
      SCK_aux         : IN     std_logic;
      SCK_ena         : IN     std_logic;
      so              : IN     std_logic;
      addr_byte       : IN     std_logic_vector (23 DOWNTO 0);
      clk             : IN     std_logic;
      data_in         : IN     std_logic_vector (63 DOWNTO 0);
      load            : IN     std_logic;
      reset           : IN     std_logic;
      sel             : IN     std_logic_vector (3 DOWNTO 0);
      shift_IR        : IN     std_logic;
      shift_addr_byte : IN     std_logic;
      shift_data_in   : IN     std_logic;
      shift_data_out  : IN     std_logic;
      shift_ena       : IN     std_logic;
      shift_ena_out   : IN     std_logic;
      SCK             : OUT    std_logic;
      si              : OUT    std_logic;
      data_out        : OUT    std_logic_vector (63 DOWNTO 0);
      next4bytes      : IN     std_logic;
      load_fifo       : IN     std_logic
   );

-- Declarations

END mux_shifter ;

--
ARCHITECTURE behave OF mux_shifter IS
signal IR_s : std_logic_vector(7 downto 0);
signal addr_byte_s : std_logic_vector(23 downto 0); 
signal data_in_s,data_out_s:std_logic_vector (63 downto 0);
signal load_fifo_s :std_logic;
signal next4bytes_s:std_logic;
-----------------------------------------------------------------------------------------------------------------
BEGIN

process(clk,reset)
begin
if reset='0' then
	addr_byte_s<=x"000000";
	IR_s<=x"00";
	data_in_s <=(others =>'0');
	load_fifo_s<='0';
	next4bytes_s<='0';
	data_out_s<=(others =>'0');
elsif clk'event and clk='1' then
    load_fifo_s<=load_fifo;
    next4bytes_s<=next4bytes;
        
	if load='1' then
		addr_byte_s<=addr_byte;
		IR_s<=IR;
		data_out_s<=(others =>'0');		
	else
		if shift_IR='1' and shift_ena='1' then
		IR_S<=IR_s(6 downto 0)&'0';
		end if;
		if shift_addr_byte='1'and shift_ena='1' then       
		addr_byte_s<=addr_byte_s(22 downto 0)&'0';
		end if;						
		if shift_data_out='1'and shift_ena_out='1' then
		   data_out_s<=data_out_s(62 downto 0)& so;
		end if;
		
		if load_fifo_s='1' or next4bytes_s='1' then
			data_in_s<=data_in;				
		elsif shift_data_in='1'and shift_ena='1' then
		   data_in_s<=data_in_s(62 downto 0)&'0';
		end if;
		
		if shift_ena='1' then
		case sel is
		when "0000"=> SI<= IR_s(7)        ;
		when "1001"=> SI<= addr_byte_s(23);
		when "0001"=> SI<= data_in_s(7)   ;
		when "0010"=> SI<= data_in_s(15)  ;
		when "0011"=> SI<= data_in_s(23)  ;
		when "0100"=> SI<= data_in_s(31)  ;
		when "0101"=> SI<= data_in_s(39)  ;
		when "0110"=> SI<= data_in_s(47)  ;
		when "0111"=> SI<= data_in_s(55)  ;
		when "1000"=> SI<= data_in_s(63)  ;
		when others=> SI<= '1'            ;
		end case;   
		end if;   
	end if;
end if;
end process;
----------------------------------------------------------------------------------		                    
SCK<=sck_aux when SCK_ena='1' else '0';
data_out<=data_out_s; 	
END ARCHITECTURE behave;

