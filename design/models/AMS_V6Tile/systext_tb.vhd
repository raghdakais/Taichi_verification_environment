----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2021 11:56:35 AM
-- Design Name: 
-- Module Name: systext_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

--https://www.youtube.com/watch?v=vneVDMEtoL8
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;


entity systext_tb is

end systext_tb;

architecture Behavioral of systext_tb is
constant t_delay:time :=10 ns;
component SYSTEXT 
    Port ( ABC : in STD_LOGIC_VECTOR (2 downto 0);
           F : out STD_LOGIC);
end component;

signal ABC_TB :STD_LOGIC_VECTOR (2 downto 0);
SIGNAL  F_TB :  STD_LOGIC;

begin
DUT: SYSTEXT 
PORT MAP (
	ABC=>ABC_TB,
	F=>F_TB);
PROCESS

FILE Fin: text open READ_MODE is "input_vectors.txt";
variable current_read_line : line ; -- read line from the file
variable current_read_field : STD_LOGIC_VECTOR (2 downto 0) ;--read from the read line, the same type as we would like to use
variable current_write_line :line;
BEGIN
while (not endfile(Fin))loop -- (1 to 127) loop
    readline(Fin,current_read_line);-- read line from the file
    read(  current_read_line,current_read_field);--read from the txt line and put the info at the pleased type (vector (2..0))
    ABC_TB<=current_read_field;--feed ABC_TB in current_read_field value
    Wait for 100 ns;
    
    write(current_write_line, string '("input vector ABC_TB="));
    write(current_write_line, abc_tb);
    write(current_write_line, string '("  Out f_TB ="));
    write(current_write_line, F_TB);
    writeline(OUTPUT, current_write_line);
    
end loop;
END PROCESS;
end Behavioral;
