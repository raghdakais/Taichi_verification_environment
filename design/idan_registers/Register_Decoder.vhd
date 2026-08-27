----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/29/2022 09:35:05 AM
-- Design Name: 
-- Module Name: REGISTER_DECODER - REGISTER_DECODER_ARC
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


entity REGISTER_DECODER is
GENERIC(
         G_HEADER_LENGTH: INTEGER  := 16;
         G_PAYLOAD_LENGTH: INTEGER := 32;
         G_FOOTER_LENGTH: INTEGER  := 24;
         G_CRC_LENGTH: INTEGER     := 8;
         G_DATA_IN_LENGTH: INTEGER := 8;
         G_CMD_LENGTH: INTEGER     := 16;
         G_ADDR_LENGTH: INTEGER    := 24;
         G_DATA_OUT_LENGTH: INTEGER:= 32
);
Port ( 
    CLK :IN STD_LOGIC;
    RST :IN STD_LOGIC; --Active @ '1'
    EN  :IN STD_LOGIC; --Active @ '1', -- start_valid
    HEADER    :IN STD_LOGIC; --Active @ '1'--:IN STD_LOGIC_VECTOR (G_HEADER_LENGTH-1 DOWNTO 0);
    PAYLOAD   :IN STD_LOGIC; --Active @ '1'--:IN STD_LOGIC_VECTOR (G_PAYLOAD_LENGTH-1 DOWNTO 0);
    FOOTER    :IN STD_LOGIC; --Active @ '1'-- :IN STD_LOGIC_VECTOR (G_FOOTER_LENGTH-1 DOWNTO 0);
    CRC_OK    :IN STD_LOGIC; --Active @ '1'
    ALIGNED   :IN STD_LOGIC; -- Active @ '1'
    DATA_nBIT :IN STD_LOGIC_VECTOR (G_DATA_IN_LENGTH-1 DOWNTO 0);
    
    EXE       :OUT STD_LOGIC; --Active @ '1'
    CMD       :OUT STD_LOGIC_VECTOR (G_CMD_LENGTH-1 DOWNTO 0); --Active @ '1'
    DATA_OUT  :OUT STD_LOGIC_VECTOR (G_DATA_OUT_LENGTH-1 DOWNTO 0);
    ADDR_OUT  :OUT STD_LOGIC_VECTOR (G_ADDR_LENGTH-1 DOWNTO 0)

);
end REGISTER_DECODER;

architecture REGISTER_DECODER_ARC of REGISTER_DECODER is
--constant declearation--
CONSTANT    C_ADDR_BITS_AMOUNT:    INTEGER:= 24;
CONSTANT    C_DATA_BITS_AMOUNT:    INTEGER:= 32;
CONSTANT    C_VAL :    INTEGER:= 8;

---
SIGNAL S_PAYLOAD_CNT :INTEGER RANGE 0 TO 3:=0;
SIGNAL S_PAYLOAD_WAS_ON :STD_LOGIC:='0';
SIGNAL S_PAYLOAD:STD_LOGIC_VECTOR (4*C_VAL-1 DOWNTO 0);
---- 
SIGNAL S_HEADER:STD_LOGIC_VECTOR (2*C_VAL-1 DOWNTO 0); 
SIGNAL S_HEADER_WAS_ON :STD_LOGIC:='0';
SIGNAL S_HEADER_CNT :INTEGER RANGE 0 TO 1:=0;
--
SIGNAL S_FOOTER_CNT :INTEGER RANGE 0 TO 2:=0;
SIGNAL S_FOOTER_WAS_ON :STD_LOGIC:='0';
SIGNAL S_FOOTER:STD_LOGIC_VECTOR (3*C_VAL-1 DOWNTO 0); 
--
--SIGNAL S_EN_CNT :INTEGER RANGE 0 TO 10:=0;
SIGNAL S_EN_ON :STD_LOGIC:='0';
SIGNAL S_ALIGNED_R1 :STD_LOGIC:='0';
SIGNAL S_ALIGNED_R2 :STD_LOGIC:='0';
SIGNAL S_ALIGNED_APPROVED :STD_LOGIC:='0';

-- !debug: 18/12/2022
 signal regs_packet_cnt : natural range 0 to 1023 := 0;
 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of S_ALIGNED_APPROVED,EXE,CMD,DATA_OUT,ADDR_OUT,regs_packet_cnt : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of S_ALIGNED_APPROVED,EXE,CMD,DATA_OUT,ADDR_OUT,regs_packet_cnt : signal is "true";

begin


EN_PRO: PROCESS(CLK,RST) 
BEGIN 
 IF RST='1' THEN --Active @ '1'
    
    S_EN_ON<='0';
ELSIF RISING_EDGE(CLK) THEN
    IF EN='1' THEN
         S_EN_ON<='1';
    ELSIF S_ALIGNED_APPROVED='1'  THEN  
          S_EN_ON<='0';      
    END IF;
 END IF;
END PROCESS;






PROCESS (CLK,RST)
BEGIN 
IF RST='1' THEN --Active @ '1'
        S_ALIGNED_R1<='0';    
        S_ALIGNED_R2<='0';        
        S_ALIGNED_APPROVED<='0'; 
       
     ELSIF RISING_EDGE(CLK) THEN 
            S_ALIGNED_R1<=ALIGNED;
            S_ALIGNED_R2<=S_ALIGNED_R1;
             IF S_ALIGNED_R2 = '1' and S_ALIGNED_R1 = '0' THEN
            --verify that signal got off
                S_ALIGNED_APPROVED <='1';
             ELSE 
                S_ALIGNED_APPROVED <='0';
            END IF; 

END IF;
END PROCESS;


HEADER_CNT_PRO:PROCESS (CLK,RST)
BEGIN 
     IF RST='1' THEN --Active @ '1'
     S_HEADER_CNT<=0;
      ELSIF RISING_EDGE(CLK) THEN 
           IF  HEADER='1' THEN 
            --16 bits of header, 8*2=16
                IF S_HEADER_CNT<1 THEN --Two pulses for 16 bits, each pulse for 8 bits
                    S_HEADER_CNT<=S_HEADER_CNT+1;
                END IF;
          END IF;
                --CLEAR CNT
          IF S_HEADER_WAS_ON='1' AND S_PAYLOAD_WAS_ON  ='1' AND S_FOOTER_WAS_ON  ='1' AND S_ALIGNED_APPROVED ='1' THEN 
                    S_HEADER_CNT<=0;
          ELSIF S_EN_ON='0' THEN
                    S_HEADER_CNT<=0;
          END IF;

END IF;
END PROCESS;

PAYLOAD_CNT_PRO:PROCESS (CLK,RST)
BEGIN 
     IF RST='1' THEN --Active @ '1'
     S_PAYLOAD_CNT<=0;
     ELSIF RISING_EDGE(CLK) THEN 
        IF  PAYLOAD='1' THEN 
                IF S_PAYLOAD_CNT<3 THEN  
                    S_PAYLOAD_CNT<=S_PAYLOAD_CNT+1;
                END IF;
                
        END IF; 
                --CLEAR CNT
                IF S_HEADER_WAS_ON='1' AND S_PAYLOAD_WAS_ON  ='1' AND S_FOOTER_WAS_ON  ='1' AND S_ALIGNED_APPROVED ='1' THEN 
                    S_PAYLOAD_CNT<=0;
                ELSIF S_EN_ON='0' THEN
                    S_PAYLOAD_CNT<=0;
                END IF;
                

END IF;
END PROCESS;

FOOTER_CNT_PRO:PROCESS (CLK,RST)
BEGIN 
     IF RST='1' THEN --Active @ '1'
     S_FOOTER_CNT<=0;
     ELSIF RISING_EDGE(CLK) THEN 
            IF  FOOTER='1' THEN 
                 IF S_FOOTER_CNT<2 THEN  
                    S_FOOTER_CNT<=S_FOOTER_CNT+1;

                END IF; 
            END IF;          
                --CLEAR CNT
                IF S_HEADER_WAS_ON='1' AND S_PAYLOAD_WAS_ON  ='1' AND S_FOOTER_WAS_ON  ='1' AND S_ALIGNED_APPROVED ='1' THEN 
                    S_FOOTER_CNT<=0;
                ELSIF S_EN_ON='0' THEN
                    S_FOOTER_CNT<=0;
                END IF;

    END IF;
END PROCESS;






PROCESS (CLK,RST)
BEGIN 
     IF RST='1' THEN --Active @ '1'
        
        ADDR_OUT<=(OTHERS=>'0');
        DATA_OUT<=(OTHERS=>'0');
        EXE<='0';
        CMD<=(OTHERS=>'0');
        S_HEADER_WAS_ON<='0';
        S_PAYLOAD_WAS_ON<='0';
        S_FOOTER_WAS_ON<='0'; 
        S_HEADER<=(others=>'0');
        S_PAYLOAD<=(others=>'0');
        S_FOOTER<=(others=>'0');
     ELSIF RISING_EDGE(CLK) THEN 
        IF S_EN_ON='1' THEN -- start_valid
            
            IF  HEADER='1' THEN 
            
                CASE S_HEADER_CNT IS 
                    WHEN 0=> S_HEADER(15 downto 8)<=DATA_nBIT; --MSB--CHANGE FROM LSB TO MSB -- S_HEADER(7 downto 0)<=DATA_nBIT; --LSB
                    WHEN 1=> S_HEADER(7 downto 0)<=DATA_nBIT; --LSB--CHANGE FROM MSB TO LSB-- S_HEADER(15 downto 8)<=DATA_nBIT; --MSB
                              S_HEADER_WAS_ON<='1';
                    WHEN OTHERS=> NULL;
                END CASE;
                
            ELSIF  PAYLOAD ='1'  THEN        
            --32 bits of data, 8*4= 32
                CASE S_PAYLOAD_CNT IS 
                    
                   WHEN 0=> S_PAYLOAD(4*C_VAL-1 DOWNTO 3*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB --S_PAYLOAD(1*C_VAL-1 DOWNTO 0*C_VAL)<=DATA_nBIT;
                   WHEN 1=> S_PAYLOAD(3*C_VAL-1 DOWNTO 2*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB --S_PAYLOAD(2*C_VAL-1 DOWNTO 1*C_VAL)<=DATA_nBIT;
                   WHEN 2=> S_PAYLOAD(2*C_VAL-1 DOWNTO 1*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB --S_PAYLOAD(3*C_VAL-1 DOWNTO 2*C_VAL)<=DATA_nBIT;
                   WHEN 3=> S_PAYLOAD(1*C_VAL-1 DOWNTO 0*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB --S_PAYLOAD(4*C_VAL-1 DOWNTO 3*C_VAL)<=DATA_nBIT;
                            S_PAYLOAD_WAS_ON<='1';
                   WHEN OTHERS=> NULL;
                END CASE;
                
            ELSIF  FOOTER ='1'  THEN    --3 BITS OF ADDR          
                  
                CASE S_FOOTER_CNT IS                  
                   WHEN 0=> S_FOOTER(3*C_VAL-1 DOWNTO 2*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB--S_FOOTER(1*C_VAL-1 DOWNTO 0*C_VAL)<=DATA_nBIT;
                   WHEN 1=> S_FOOTER(2*C_VAL-1 DOWNTO 1*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB--S_FOOTER(2*C_VAL-1 DOWNTO 1*C_VAL)<=DATA_nBIT;                           
                   WHEN 2=> S_FOOTER(1*C_VAL-1 DOWNTO 0*C_VAL)<=DATA_nBIT;--CHANGE FROM LSB TO MSB--S_FOOTER(3*C_VAL-1 DOWNTO 2*C_VAL)<=DATA_nBIT;
                            S_FOOTER_WAS_ON<='1';                 
                   WHEN OTHERS=> NULL;
                END CASE;
              
             

           
            END IF;  

            IF S_HEADER_WAS_ON='1' AND S_PAYLOAD_WAS_ON  ='1' AND S_FOOTER_WAS_ON  ='1' AND S_ALIGNED_APPROVED ='1' THEN  
                    --SEND DATA OUT
                    CMD<=S_HEADER;--16 BITS
                    ADDR_OUT<=S_FOOTER;--24 BITS
                    DATA_OUT<=S_PAYLOAD; -- 32 BITS
                    
                    EXE<='1';
                    
                    --CLEAR FLAGS
                    S_HEADER_WAS_ON<='0';
                    S_PAYLOAD_WAS_ON<='0';
                    S_FOOTER_WAS_ON<='0';

                    --CLEAR SAVED REGISTERS 
                    S_HEADER<=(others=>'0');
                    S_PAYLOAD<=(others=>'0');
                    S_FOOTER<=(others=>'0');
                    
                 ELSE 
                    EXE<='0';
            END IF;
            
        ELSE --S_EN_ON='0'
              
            EXE<='0';
            S_HEADER_WAS_ON<='0';
            S_PAYLOAD_WAS_ON<='0';
            S_FOOTER_WAS_ON<='0';
           
              
              
        END IF;
    END IF;


END PROCESS;


-- !debug: 18/12/2022
misc_pr: process (clk) is
begin  -- process misc_pr
  if (clk'event and clk = '1') then  -- rising clock edge

    if (S_HEADER_WAS_ON='1' AND S_PAYLOAD_WAS_ON  ='1' AND S_FOOTER_WAS_ON  ='1' AND S_ALIGNED_APPROVED ='1') then -- EXE = '1'
      regs_packet_cnt <= regs_packet_cnt + 1; -- note: clears after 1024 packets
    end if;
      
  end if;
end process misc_pr;

end REGISTER_DECODER_ARC;
