----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/29/2022 09:35:05 AM
-- Design Name: 
-- Module Name: REGISTER_ENCODER - REGISTER_ENCODER_ARC
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


entity REGISTER_ENCODER is
GENERIC(
         G_STATUS_LENGTH: INTEGER:= 16;
         G_ADDR_LENGTH: INTEGER := 24;
         G_DATA_LENGTH: INTEGER := 32;
         G_DATA_OUT_LENGTH: INTEGER := 8
);
Port ( 
    CLK             :IN STD_LOGIC;
    RST             :IN STD_LOGIC; --Active @ '1'
    STATUS          :IN STD_LOGIC_VECTOR (G_STATUS_LENGTH-1 DOWNTO 0);
    DATA_IN         :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ADDR_IN         :IN STD_LOGIC_VECTOR (G_ADDR_LENGTH-1 DOWNTO 0);
    SEND            :IN STD_LOGIC; -- Active @ '1'
    DATA_OUT        :OUT STD_LOGIC_VECTOR (G_DATA_OUT_LENGTH-1 DOWNTO 0);
    STATn_DYN       :OUT STD_LOGIC; -- ('0' for Static, '1' for dynamic)
    GO              :OUT STD_LOGIC ;
    WR_EN           :OUT STD_LOGIC 
   

);
end REGISTER_ENCODER;

architecture REGISTER_ENCODER_ARC of REGISTER_ENCODER is
--constant declearation--
CONSTANT    C_IDLE:    STD_LOGIC_VECTOR (7 DOWNTO 0) := x"C5";
--CONSTANT    C_START_WORD:    STD_LOGIC_VECTOR (7 DOWNTO 0) := x"AB";
--CONSTANT    C_CMD_STATUS:    STD_LOGIC_VECTOR (15 DOWNTO 0) := x"1739";

--State machine declearation--
TYPE REG_ENC_SM_state_type IS (IDLE,  CMD_STATUS, ADDR, DATA);
--Signals declearation--
SIGNAL REG_ENC_SM :REG_ENC_SM_state_type;
SIGNAL rdy2go :STD_LOGIC:='0';
SIGNAL S_GO_DELAY_COUNTER :INTEGER RANGE 0 TO 250:=0;
SIGNAL S_SEND_R0 :STD_LOGIC:='0';
SIGNAL S_SEND_R1 :STD_LOGIC:='0';
SIGNAL S_BIT_CNT :INTEGER RANGE 0 TO 7:=0;

begin

PROCESS (CLK,RST)
--create S_SEND_ON<='1' signal for 10 clks

BEGIN 
    IF RST='1' THEN 
        S_SEND_R0<='0';
        S_SEND_R1<='0';
        
    ELSIF RISING_EDGE(CLK) then
        S_SEND_R0<=SEND;
        S_SEND_R1<=S_SEND_R0;
           
    END IF;
END PROCESS;

GO_PULSE_CREATION: PROCESS (CLK,RST)
BEGIN 
IF RST='1' THEN    
       S_GO_DELAY_COUNTER<=0; 
        GO<='0';
ELSIF RISING_EDGE(CLK) then
 IF rdy2go='1' OR S_GO_DELAY_COUNTER>1 THEN
    -- CASE S_GO_DELAY_COUNTER IS 
    --     WHEN 0 TO 50=> GO<='0';
    --                S_GO_DELAY_COUNTER<=S_GO_DELAY_COUNTER+1;
    --     WHEN 51=> GO<='1';
    --               S_GO_DELAY_COUNTER<=S_GO_DELAY_COUNTER+1;               
    --     WHEN 52=> GO<='0';
    --               S_GO_DELAY_COUNTER<=0;
    --     WHEN OTHERS=> GO<='0';
    -- END CASE;
    -- 
   -- !debug: 25/07/2024 Eugene Shinderman: S_GO_DELAY_COUNTER reduced from 50 to 16
    CASE S_GO_DELAY_COUNTER IS 
      WHEN 0 TO 30=>
        S_GO_DELAY_COUNTER<=S_GO_DELAY_COUNTER+1;
      WHEN 31=> 
        S_GO_DELAY_COUNTER<=0;
      WHEN OTHERS=> GO<='0';
    END CASE;
    if (S_GO_DELAY_COUNTER = 15) then
      GO<='1';
    else
      GO<='0';
    end if;
  END IF;    
END IF;

END PROCESS;



PROCESS (CLK,RST)
BEGIN 
     IF RST='1' THEN --Active @ '1',
        REG_ENC_SM<=IDLE;
        DATA_OUT<=C_IDLE;
        --Signals declearation--
        rdy2go<='0';
        S_BIT_CNT<=0;
        --outputs
        DATA_OUT<=(others=>'0');
        STATn_DYN<='0';
        WR_EN<='0';
        
     ELSIF RISING_EDGE(CLK) THEN --RST='0'
       	CASE REG_ENC_SM IS 
            WHEN IDLE=> 
                STATn_DYN<='0';
                WR_EN<='0';
                
                IF S_SEND_R1 = '1' THEN  
                    REG_ENC_SM <=CMD_STATUS;   
                ELSE 
                    REG_ENC_SM <=IDLE;
                    rdy2go<='0';
                     WR_EN<='0';
                END IF;
                  

            WHEN CMD_STATUS=> 
                    WR_EN<='1';              
                    CASE S_BIT_CNT IS      
                      WHEN 0 => 
                            DATA_OUT<=STATUS(15 DOWNTO 8);--DATA_OUT<=STATUS(7 DOWNTO 0);
                            S_BIT_CNT<=S_BIT_CNT+1;
                            REG_ENC_SM <=CMD_STATUS;
                      WHEN 1 =>
                            DATA_OUT<=STATUS(7 DOWNTO 0);--DATA_OUT<=STATUS(15 DOWNTO 8);
                            
                            S_BIT_CNT<=0;
                            REG_ENC_SM <=DATA;
                      WHEN OTHERS => 
                         S_BIT_CNT<=0;
                         REG_ENC_SM <=CMD_STATUS;                       
                      END CASE;

            
            WHEN DATA=>  
                    --32 BITS 
                    rdy2go<='1';
                    CASE S_BIT_CNT IS      
                      WHEN 0 => 
                        S_BIT_CNT<=S_BIT_CNT+1;
                        DATA_OUT<=DATA_IN(31 DOWNTO 24);--DATA_IN(7 DOWNTO 0); 
                         REG_ENC_SM <=DATA;  
                      WHEN 1=>
                        S_BIT_CNT<=S_BIT_CNT+1;
                        DATA_OUT<=DATA_IN(23 DOWNTO 16);--DATA_IN(15 DOWNTO 8); 
                         REG_ENC_SM <=DATA; 
                       WHEN 2=>
                        S_BIT_CNT<=S_BIT_CNT+1;
                        DATA_OUT<=DATA_IN(15 DOWNTO 8);--DATA_IN(23 DOWNTO 16); 
                         REG_ENC_SM <=DATA; 
                        WHEN 3=>
                        S_BIT_CNT<=0;
                        DATA_OUT<=DATA_IN(7 DOWNTO 0);--DATA_IN(31 DOWNTO 24);  
                        REG_ENC_SM <=ADDR;
                         WHEN OTHERS => 
                         S_BIT_CNT<=0;  
                         REG_ENC_SM <=IDLE;                     
                    END CASE;
                         
               WHEN ADDR=>         
                    CASE S_BIT_CNT IS      
                      WHEN 0 => 
                        S_BIT_CNT<=S_BIT_CNT+1;
                        DATA_OUT<=ADDR_IN(23 DOWNTO 16);--ADDR_IN(7 DOWNTO 0); 
                         REG_ENC_SM <=ADDR;  
                      WHEN 1=>
                        S_BIT_CNT<=S_BIT_CNT+1;
                        DATA_OUT<=ADDR_IN(15 DOWNTO 8); 
                         REG_ENC_SM <=ADDR; 
                        WHEN 2=>
                        S_BIT_CNT<=0;
                        DATA_OUT<=ADDR_IN(7 DOWNTO 0);--ADDR_IN(23 DOWNTO 16); 
                         REG_ENC_SM <=IDLE;
                      WHEN OTHERS => 
                         S_BIT_CNT<=0; 
                         REG_ENC_SM <=IDLE;                      
                    END CASE;                      
                               
            WHEN OTHERS=> 
                REG_ENC_SM <=IDLE;               
        END CASE;        
    END IF;


END PROCESS;
end REGISTER_ENCODER_ARC;
