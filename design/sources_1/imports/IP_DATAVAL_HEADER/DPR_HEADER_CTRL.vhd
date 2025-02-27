
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity DPR_HEADER_CTRL is
GENERIC (
         DIN_DATA_BIT_VAL : INTEGER :=8;
         ADDR_BIT_VAL : INTEGER :=6;
         DATA_BIT_VAL : INTEGER :=16  );
Port (

    CLK                 : IN STD_LOGIC; 
    RST                 : IN STD_LOGIC; 
    IP_Packet_valid     : IN STD_LOGIC;
    DATA_VALID          : IN STD_LOGIC;
    GOOD_PACKET_RECEIVED : IN STD_LOGIC; 
    DIN                 :IN STD_LOGIC_VECTOR(DIN_DATA_BIT_VAL-1 DOWNTO 0); 
    ADDRA               : OUT STD_LOGIC_VECTOR(ADDR_BIT_VAL-1 DOWNTO 0); 
    DOUT                 :OUT STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);  
    ENA                 : OUT STD_LOGIC;
    WEA                 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
     
    );
end DPR_HEADER_CTRL;

architecture DPR_HEADER_CTRL of DPR_HEADER_CTRL is
--SIGNAL S_WAIT4HDR   : STD_LOGIC;
SIGNAL S_IP_ACCEPTED : STD_LOGIC;
SIGNAL S_DATA_ACCEPTED : STD_LOGIC;


SIGNAL S_ADDRA     :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL S_DIN     :  STD_LOGIC_VECTOR(DIN_DATA_BIT_VAL-1 DOWNTO 0);  
CONSTANT C_MAX_S_ADDR_VAL :  STD_LOGIC_VECTOR(7 DOWNTO 0) :=x"80";

-- 20/03/2023
signal header_timeout_cnt : natural range 0 to 25000 := 25000;
signal header_timeout_err : std_logic := '0';
 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of header_timeout_cnt, header_timeout_err : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of header_timeout_cnt, header_timeout_err : signal is "true";

BEGIN


ENA_PRO: PROCESS (CLK, RST)
BEGIN 
IF RST='1' THEN 
    ENA <='0';
    WEA<=(OTHERS=>'0');
    S_IP_ACCEPTED<='0';
    S_DATA_ACCEPTED <='0';
    DOUT<=(OTHERS=>'0');
    --
    ADDRA<=(OTHERS=>'0');
 
    S_ADDRA<=(OTHERS=>'0');
    S_DIN<=(OTHERS=>'0'); 
    --
ELSIF CLK'EVENT AND CLK='1' THEN 
    
    IF GOOD_PACKET_RECEIVED ='0' AND IP_Packet_valid ='1'   THEN 
        WEA<=(OTHERS=>'0');
        S_IP_ACCEPTED<='1';
        S_DATA_ACCEPTED <='0';
        ADDRA<=(OTHERS=>'0');
        
        S_ADDRA<=(OTHERS=>'0');  
        S_DIN<=(OTHERS=>'0');   
        ENA <='1'; 
    ELSIF GOOD_PACKET_RECEIVED ='1' AND S_IP_ACCEPTED ='1' THEN    
        
        WEA<=(OTHERS=>'0');
        S_IP_ACCEPTED <='0';
        
    ELSIF GOOD_PACKET_RECEIVED ='0' AND DATA_VALID ='1' THEN 
        S_DATA_ACCEPTED <='1';
        WEA<=(OTHERS=>'1');    

       IF S_ADDRA(0) ='0' then
           IF  S_ADDRA<C_MAX_S_ADDR_VAL THEN 
                ADDRA<=S_ADDRA(ADDR_BIT_VAL DOWNTO 1);
                S_ADDRA<=std_logic_vector ( unsigned ( S_ADDRA ) + 1 );
                S_DIN<=DIN;  
            ELSIF S_ADDRA=C_MAX_S_ADDR_VAL THEN  
                ADDRA<=S_ADDRA(ADDR_BIT_VAL DOWNTO 1); 
                S_DIN<=DIN;                
                S_ADDRA<=(OTHERS=>'0');   
            END IF;
            
        ELSIF S_ADDRA(0) ='1' then 
            IF  S_ADDRA<C_MAX_S_ADDR_VAL THEN     
                S_ADDRA<=std_logic_vector ( unsigned ( S_ADDRA ) + 1 );
                DOUT<=DIN&S_DIN; 
            ELSIF S_ADDRA=C_MAX_S_ADDR_VAL THEN  
               DOUT<=DIN&S_DIN;                
                S_ADDRA<=(OTHERS=>'0');   
            END IF;
        

        END IF;
        

    ELSIF GOOD_PACKET_RECEIVED ='1' AND S_DATA_ACCEPTED ='1' THEN          
        WEA<=(OTHERS=>'0');
        S_DATA_ACCEPTED <='0';
        
       -- ENA <='0';
   -- ELSE 
    
    END IF;

END IF;

END PROCESS;


misc_test_pr: process (clk) is
begin  -- process misc_test_pr
  if (clk'event and clk = '1') then  -- rising clock edge

    if (GOOD_PACKET_RECEIVED ='1' and S_IP_ACCEPTED ='1') then
      header_timeout_cnt <= 25000;
    elsif (header_timeout_cnt /= 0) then
      header_timeout_cnt <= header_timeout_cnt - 1;
    end if;      
    if (header_timeout_cnt = 0) then	   
      header_timeout_err <= '1';
    else
      header_timeout_err <= '0';
    end if;  
          
  end if;
end process misc_test_pr;


end DPR_HEADER_CTRL;
