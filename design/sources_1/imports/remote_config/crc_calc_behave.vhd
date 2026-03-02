--
-- VHDL Architecture access_config_lib.crc_calc.behave
--
-- Created:
--          by - ilq00571.UNKNOWN (ILQHFAATC1NB350)
--          at - 10:59:39 04/05/2011
--
-- using Mentor Graphics HDL Designer(TM) 2009.2 (Build 10)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.STD_LOGIC_UNSIGNED.all;

ENTITY crc_calc IS
   PORT( 
      EXE            : IN     std_logic;
      EXE_p          : IN     std_logic;
      capture_r_crc  : IN     std_logic;
      capture_w_crc  : IN     std_logic;
      clk            : IN     std_logic;
      command_p      : IN     std_logic_vector (3 DOWNTO 0);
      reset          : IN     std_logic;
      sel            : IN     std_logic_vector (3 DOWNTO 0);
      shift_data_in  : IN     std_logic;
      shift_data_out : IN     std_logic;
      shift_ena      : IN     std_logic;
      shift_ena_out  : IN     std_logic;
      si             : IN     std_logic;
      so             : IN     std_logic;
      PP_CRC_error   : OUT    std_logic
   );

-- Declarations

END crc_calc ;

--
ARCHITECTURE behave OF crc_calc IS

  function nextCRC16_D1
    (Data: std_logic;
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector;

  -- polynomial: (0 2 15 16)
  -- data width: 1
  -- convention: the first serial bit is D[0]
  function nextCRC16_D1
    (Data: std_logic;
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector is

    variable d:      std_logic_vector(0 downto 0);
    variable c:      std_logic_vector(15 downto 0);
    variable newcrc: std_logic_vector(15 downto 0);

  begin
    d(0) := Data;
    c := crc;

    newcrc(0) := d(0) xor c(15);
    newcrc(1) := c(0);
    newcrc(2) := d(0) xor c(1) xor c(15);
    newcrc(3) := c(2);
    newcrc(4) := c(3);
    newcrc(5) := c(4);
    newcrc(6) := c(5);
    newcrc(7) := c(6);
    newcrc(8) := c(7);
    newcrc(9) := c(8);
    newcrc(10) := c(9);
    newcrc(11) := c(10);
    newcrc(12) := c(11);
    newcrc(13) := c(12);
    newcrc(14) := c(13);
    newcrc(15) := d(0) xor c(14) xor c(15);
    return newcrc;
  end nextCRC16_D1;
  signal crc16,crc16r : std_logic_vector(15 downto 0);
  signal exe_vec: std_logic_vector (1 downto 0);
  signal shift_data_in_s :std_logic;
  signal crc_capture : std_logic_vector(15 downto 0);
  signal counter4shift :std_logic_vector (4 downto 0);
  signal command_paux : std_logic_vector (3 downto 0);
  signal exe_pvec : std_logic_vector (1 downto 0);
BEGIN

process (clk,reset)
begin
if reset ='0' then
	crc16<=(others=>'0');
	exe_vec <="00";
	shift_data_in_s<='0';
	crc16r<=(others=>'0');
	crc_capture<=(others=>'0');
	counter4shift<=(others=>'0');
	PP_CRC_error<='0';
	command_paux<="0000";
	exe_pvec <="00";
elsif clk'event and clk='1' then
	shift_data_in_s<=shift_data_in;
	exe_vec<=exe_vec(0)&exe;
	exe_pvec<=exe_pvec(0)&exe_p;
	if exe_pvec="01" then
		command_paux<=command_p;
	end if;	
	if exe_pvec ="01" then
		crc16<=(others=>'0');
		command_paux<=command_p;
	elsif (shift_data_in='1'or shift_data_in_s='1')  and shift_ena_out='1' and command_paux="0100" then 
		crc16<=nextCRC16_D1(si,crc16);
	end if;
	if exe_pvec ="01" then                                                                            
		crc16r<=(others=>'0');                                                                           
	elsif shift_data_out='1'  and shift_ena_out='1' and command_paux="0100" then 
		crc16r<=nextCRC16_D1(so,crc16r);                                                                  
	end if; 
	
	if exe_pvec ="01" then                                                        
		crc16r<=(others=>'0');                                                       
	elsif shift_data_out='1'  and shift_ena_out='1' and command_paux="0100" then  
		crc16r<=nextCRC16_D1(so,crc16r);
	elsif counter4shift > 0  then                               
		   counter4shift<=counter4shift-1;
		   if counter4shift > 1  then
				crc16r<=nextCRC16_D1(crc_capture(15),crc16r);          
				crc_capture<=crc_capture(14 downto 0)&crc_capture(15);
		   end if;
	end if;                                                                       
	                                                                                         
	if capture_w_crc ='1' then
	   crc_capture<=crc16;
	end if;
	if capture_r_crc ='1' then
	   counter4shift<="10001";    
	end if;                   
	--if counter4shift > 0  then
	--   counter4shift<=counter4shift-1;
	--   crc16r<=nextCRC16_D1(crc_capture(15),crc16r);
	--   crc_capture<=crc_capture(14 downto 0)&crc_capture(15);
	--end if;
	if counter4shift = 1 and crc16r=0 then
	   PP_CRC_error<='0';
	elsif counter4shift = 1 then
	   PP_CRC_error<='1';
	else
	   PP_CRC_error<='0';
	end if;   
	  
	
	   							
end if;
end process;		
	




END ARCHITECTURE behave;

