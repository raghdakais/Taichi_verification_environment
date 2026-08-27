----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2021 11:58:54 AM
-- Design Name: 
-- Module Name: SYSTEXT - Behavioral
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


library ieee;----https://www.youtube.com/watch?v=vneVDMEtoL8
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SYSTEXT is
    Port ( ABC : in STD_LOGIC_VECTOR (2 downto 0);
           F : out STD_LOGIC);
end SYSTEXT;

architecture Behavioral of SYSTEXT is

begin
PROCESS (ABC)
begin
    IF (ABC = "001") then 
    	F<='1';
    ELSIF (ABC = "100") then 
      F<='1';
    ELSIF (ABC = "101") then 
      F<='1';
    ELSE
      F<='0';
    END IF;
end process;

end Behavioral;
