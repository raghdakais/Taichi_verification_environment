----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2022 12:37:04 PM
-- Design Name: 
-- Module Name: REGISTER_CTRL - REGISTER_CTRL_ARC
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

entity REGISTER_CTRL is
GENERIC(
         G_CMD_LENGTH: INTEGER     := 16
         );
PORT(
    CLK :IN STD_LOGIC;
    RST :IN STD_LOGIC;
    EXE :IN STD_LOGIC;
    CMD :IN STD_LOGIC_VECTOR (G_CMD_LENGTH-1 DOWNTO 0);
    WRITE :OUT STD_LOGIC;-- active :'1'
    READ :OUT STD_LOGIC;-- active :'1'
    SEND :OUT STD_LOGIC -- active :'1'
    );
end REGISTER_CTRL;

architecture REGISTER_CTRL_ARC of REGISTER_CTRL is
type   sm_type          is (IDLE, CMD_STATUS, SEND_PULSE_ON,SEND_PULSE_OFF,SEND_PULSE_DELAY1,SEND_PULSE_DELAY2);
SIGNAL delay_sm  : sm_type;
begin
process (CLK, RST)
BEGIN 
	
     IF RST='1' THEN --Active @ '1'

        WRITE<='0';
        READ<='0';
        
     ELSIF RISING_EDGE(CLK) THEN
        IF EXE ='0' THEN 

            WRITE<='0';
            READ<='0'; 

         ELSIF EXE ='1' THEN  
           WRITE<=CMD(0); 
           READ<=CMD(1); 

          END IF;
     END IF;

END PROCESS; 


process (CLK, RST)
BEGIN 
	
     IF RST='1' THEN --Active @ '1'
        delay_sm <=IDLE;
        --OUTPUTS 
        SEND<='0';

 
     ELSIF RISING_EDGE(CLK) THEN
     CASE delay_sm IS 
     WHEN IDLE => 
        SEND<='0';
           IF EXE='1' THEN 
                delay_sm<= CMD_STATUS;
            ELSE 
                delay_sm<=IDLE;
           END IF;
     
     WHEN CMD_STATUS=>  
            SEND<='0';  
            IF CMD(0)='1' THEN --WRITE 
                delay_sm<=SEND_PULSE_DELAY2;--SEND_PULSE_ON;--two clks delay
               
            ELSIF CMD(1) = '1' THEN --READ , ONE CLK DELAY
                delay_sm<=SEND_PULSE_DELAY1; 
            END IF;      
     WHEN SEND_PULSE_OFF =>
            SEND<='0';
            delay_sm<=IDLE;

      WHEN SEND_PULSE_DELAY2 =>           
            --SEND<='0';
            delay_sm<=SEND_PULSE_DELAY1;--SEND_PULSE_ON;
     WHEN SEND_PULSE_DELAY1 =>           
            --SEND<='0';
            delay_sm<=SEND_PULSE_ON;--SEND_PULSE_DELAY2; 
     WHEN SEND_PULSE_ON =>
            SEND<='1';
            delay_sm<=SEND_PULSE_OFF;       
            

     WHEN OTHERS  =>
            SEND<='0';
            delay_sm<=IDLE;     
     END CASE;

     END IF;

END PROCESS; 


end REGISTER_CTRL_ARC;
