
library IEEE;
use ieee.std_logic_1164.all;
Entity SPIIFDecoderSM_TB IS END;
ARCHITECTURE SPIIFDecoderSM_TB_arc of SPIIFDecoderSM_TB is 
------DUT Component Declaration-------
Component  SPIIFDecoderSM IS 
Port (
	SClk: IN STD_LOGIC;
	SDO: IN STD_LOGIC;--FPGA to ASIC
	SCn: IN STD_LOGIC;
	rst: IN STD_LOGIC;
	SDI : OUT STD_LOGIC; -- ASIC to FPGA
	RD_WR: OUT STD_LOGIC;
	ADDR_SPI: OUT STD_LOGIC_VECTOR (13 DOWNTO 0); --SPI_Bank_Vector(1-14) -Address
	DATA: OUT STD_LOGIC_VECTOR (15 DOWNTO 0) ----SPI_Bank_Vector(16-31)- Data	

	);

End component;
------Signal Declaration-------
Signal S_SClk: Std_logic:='0';
Signal S_SDO: Std_logic:='0';
Signal S_SCn : Std_logic:='0';
Signal S_rst : Std_logic:='0';
Signal S_SDI: Std_logic;
---INTERNAL SIGNALS
Signal S_RD_WR: Std_logic;
Signal S_ADDR_SPI :STD_LOGIC_VECTOR (13 DOWNTO 0);
Signal S_DATA :STD_LOGIC_VECTOR (15 DOWNTO 0);


Begin
DUT: SPIIFDecoderSM
Port map
	(SClk=>S_SClk, 
	SDO=>S_SDO, 
	SCn=>S_SCn,
	rst=>S_rst,
	SDI=>S_SDI,
	RD_WR=>S_RD_WR,
	ADDR_SPI=>S_ADDR_SPI,
	DATA=>S_DATA
	);


------Signal Wave Creation-------
S_SClk<=NOT S_SClk AFTER 20 ns;
S_SDO<='1' , '0' after 120ns, '1' after 250ns, '0' after 410ns, '1' after 570ns, '0' after 610ns, '1' after 850ns, '0' after 1130ns, '1' after 1490ns, '0' after 1900ns; -- Pasted the odd parity test , 7 times '1'
--S_SDO<='1' , '0' after 120ns, '1' after 250ns, '0' after 410ns, '0' after 570ns,  '1' after 850ns, '0' after 1080ns, '1' after 1490ns, '0' after 1900ns; -- Failed the  odd parity test
S_SCn <='1' , '0' after 50ns, '1' after 6080ns;
S_rst<='1', '0' after 30 ns;
--S_rst<='1', '0' after 15 ns, '1' after 340 ns,'0' after 600 ns;-- reset test


END SPIIFDecoderSM_TB_arc;