LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

--ENTITY clk_80_160MHz_TB IS END;
Entity clk_80_160MHz_TB  IS END;
ARCHITECTURE clk_80_160MHz_TB_arc of clk_80_160MHz_TB is 

------DUT Component Declaration-------
Component  clk_80_160MHz IS 
Port (
	Clk_IN: IN STD_LOGIC;
	RST: IN STD_LOGIC; 
	CLK_SEL: IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
	Clk_OUT: OUT STD_LOGIC);
	

End component;
------Signal Declaration-------
--Signal in
SIGNAL  s_Clk_IN:  STD_LOGIC:='0';
SIGNAL	s_RST:  STD_LOGIC; 
SIGNAL	s_CLK_SEL:  STD_LOGIC_VECTOR(3 DOWNTO 0); 
--Signal out
SIGNAL	s_Clk_OUT: STD_LOGIC;

Begin
DUT: clk_80_160MHz
Port map
	(	
	Clk_IN=> s_Clk_IN,
	RST=> s_RST,
	CLK_SEL=> s_CLK_SEL,
	Clk_OUT=>s_Clk_OUT);


------Signal Wave Creation-------
s_Clk_IN<=NOT s_Clk_IN AFTER 10 ns;
s_RST<='1', '0' after 50ns;
s_CLK_SEL<=x"7", x"3" after 200ns, x"1" after 500ns;



END clk_80_160MHz_TB_arc;
