----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/05/2022 10:40:43 AM
-- Design Name: 
-- Module Name: IP_REG - IP_REG_ARC
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IP_REG is
GENERIC (DATA_VAL : INTEGER :=8);
 Port ( 
    CLK                 : IN STD_LOGIC; 
    RST                 : IN STD_LOGIC; 
    IP_PACKET_VALID     : IN STD_LOGIC;
    GOOD_PACKET_RECEIVED : IN STD_LOGIC; 
    IP_DATA_IN             : IN STD_LOGIC_VECTOR(DATA_VAL-1 DOWNTO 0);
    IP_READY               : OUT STD_LOGIC;
    IP_DATA_OUT            : OUT STD_LOGIC_VECTOR(DATA_VAL-1 DOWNTO 0)  

 );
end IP_REG;

architecture IP_REG_ARC of IP_REG is
SIGNAL S_IP_VEC: STD_LOGIC_VECTOR(DATA_VAL-1 DOWNTO 0);
SIGNAL S_IP :STD_LOGIC;
BEGIN
PROCESS (CLK, RST)
BEGIN 
IF RST='1' THEN 
    IP_DATA_OUT<=(OTHERS=>'0');
    S_IP_VEC<=(OTHERS=>'0');
    IP_READY<='0';
    S_IP<='0';
ELSIF CLK'EVENT AND CLK='1' THEN 
        S_IP<=IP_PACKET_VALID;
        IF IP_PACKET_VALID ='1' AND S_IP='0' THEN 
            S_IP_VEC<=IP_DATA_IN;
            IP_READY <='1';
         
         ELSIF IP_PACKET_VALID ='0' AND S_IP='1' THEN 
            IP_READY <='0';
            
         ELSIF GOOD_PACKET_RECEIVED='1' THEN 
            IP_DATA_OUT<=S_IP_VEC;
         
--         ELSIF S_IP='0' AND IP_PACKET_VALID ='1' THEN 
--                IP_READY <='1';
--         ELSIF S_IP='1' AND IP_PACKET_VALID ='0' THEN 
--                IP_READY <='0';
   
         END IF;
    
END IF;
END PROCESS; 
end IP_REG_ARC;
