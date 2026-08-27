library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Register_IF_BroadCast_TB IS END;
ARCHITECTURE Register_IF_TB_arc of Register_IF_BroadCast_TB is 
------DUT Component Declaration-------
Component Register_IF IS 
Port(
	SClk: IN STD_LOGIC;
	SDO: IN STD_LOGIC; --FPGA to ASIC
	SCn: IN STD_LOGIC;
	Rst: IN STD_LOGIC;
	SDI: OUT STD_LOGIC -- ASIC to FPGA
);

End component;

--State Machion Declearation--
TYPE state_type is (Idle, SPI_DATA_WR, SPI_DATA_READ, Update_ADDR ,clear_Wait);

------SIGNAL Declaration-------
SIGNAL S_SClk: Std_logic:='0';
SIGNAL S_SDO : Std_logic:='0';--FPGA to ASIC (IN)
SIGNAL S_SCn : Std_logic:='1';
SIGNAL S_rst : Std_logic:='1';
SIGNAL S_SDI : Std_logic:='1';-- ASIC to FPGA


--State Machion Signals declearation--
SIGNAL TB_Cur_state: state_type;
SIGNAL TB_BIT_COUNTER : Integer range 0 to 32:=0;
SIGNAL ADDR_Pointer : std_logic_vector(15 downto 0):= x"000C"; -- starts at ADDR=000C
SIGNAL TB_BANK_BUFFER : std_logic_vector(31 downto 0):=(others=>'0'); --32 Bits that have the current 32 bit data
SIGNAL ADDR_ODD_TEST: std_logic :='0';
SIGNAL DATA_ODD_TEST: std_logic :='0';
SIGNAL IDLE_Wait: INTEGER:=0; -- start to send the data to SPI, when '1' => current state=END TO_SPI
SIGNAL Time_counter: Integer range 0 to 32:=0;
SIGNAL SPI_READ_WR_STATUS : std_logic:='0'; --=0 Write. 1 = Read --This signal is for changing between read mode and write mode

---FOR Sampling_SPI_In process
SIGNAL Sampling_SDI_In : std_logic_vector(31 downto 0):=(others=>'0');
SIGNAL Sampling_SDI_In_ADDR: std_logic_vector(15 downto 0):=(others=>'0');
SIGNAL Sampling_SDI_In_Data: std_logic_vector(15 downto 0):=(others=>'0');
SIGNAL Sampling_ADDR: std_logic_vector(13 downto 0):=(others=>'0');
SIGNAL Sampling_Data: std_logic_vector(14 downto 0):=(others=>'0');
----
Begin
DUT: Register_IF
Port map
	(SClk=>S_SCLK,
	SDO=>S_SDO,
	SCn=>S_SCn,
	Rst=>S_rst,
	SDI=>S_SDI 
	);

------SIGNAL Wave Creation-------
S_SClk<=NOT S_SClk AFTER 20 ns;
S_rst<='1', '0' after 200 ns;-- reset test



P1: PROCESS(s_rst, s_sclk)
constant ADDR_initialization: std_logic_vector(15 downto 0):= x"000C";--this is the first addr
constant Clk_wait_val: integer :=5;

VARIABLE ADDR_EVEN_TEST: std_logic :='0';
VARIABLE DATA_EVEN_TEST: std_logic :='0';

BEGIN
	IF s_rst = '1'  THEN 
		TB_BIT_COUNTER<=0;
		ADDR_Pointer <=ADDR_initialization;
		TB_BANK_BUFFER <=(others=>'0');
		IDLE_Wait <=0;
		ADDR_ODD_TEST<='0';	
		DATA_ODD_TEST<='0';	
		ADDR_EVEN_TEST:='0';  	-- set_odd_test to 0
		DATA_EVEN_TEST:='0';	-- set_odd_test to 0	
		Time_counter<=0;		
		SPI_READ_WR_STATUS<='0'; --starts the state mechine from SPI_DATA_WRITE 

		S_SCN<='1';
		TB_Cur_state<=Idle;	

	ELSIF rising_edge(S_SClk)  THEN 
	
	CASE TB_Cur_state IS
		WHEN Idle=>
		--Clear all counters:
			TB_BIT_COUNTER<=0;	--clear_Wait bit counter
			Time_counter<=0;	
			ADDR_ODD_TEST<='0';  	-- set_odd_test to 0
			DATA_ODD_TEST<='0';	-- set_odd_test to 0	
			ADDR_EVEN_TEST:='0';  	-- set_odd_test to 0
			DATA_EVEN_TEST:='0';	-- set_odd_test to 0	
			SPI_READ_WR_STATUS<='0'; --starts the state mechine from SPI_DATA_WRITE 
			TB_BANK_BUFFER <=(others=>'0');
			ADDR_Pointer <=ADDR_initialization;
			
			IF IDLE_Wait<Clk_wait_val then--only at the first time 
				IDLE_Wait<=IDLE_Wait+1;
			ELSE			
				IDLE_Wait<=0;
				S_SCN<='0';			
				IF SPI_READ_WR_STATUS='0' THEN --WRITE
				TB_Cur_state<=SPI_DATA_WR;
				ELSIF SPI_READ_WR_STATUS='1' THEN--READ
				TB_Cur_state<=SPI_DATA_READ;
				END IF;						
			END IF;

		

		WHEN SPI_DATA_WR=> --'0'
		-- At this state for 32 Clks
		-- Collecting 32 bits, 
		-- 1bit(R/W)13bit(ADDR)1bit(P),15bit(Data)1bit(P)
		-- Calculate and create ADDR and DATA ODD parity value
		
			Time_counter<=0;		
			S_SCN<='0';
					
			CASE TB_BIT_COUNTER IS

			WHEN 0 =>			
			TB_BANK_BUFFER(TB_BIT_COUNTER)<='0';--'0' write
			S_SDO<='0';
			
			WHEN 1 TO 14=>--Address pointer 
			--TB_BANK_BUFFER = 32 bit - lsb = R/W, 14 addr...
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-1);
			S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-1);
			ADDR_EVEN_TEST:=ADDR_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-1);
			ADDR_ODD_TEST<=NOT(ADDR_EVEN_TEST);

			WHEN 15=>--Address parity test
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_ODD_TEST;
			S_SDO<=ADDR_ODD_TEST;

			WHEN 16 TO 29=>--Data - 14 LSB Bits are equals to ADDR
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-16);
			S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-16);
			DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-16));
			DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

			WHEN 30=>--Data: 1 MSB Bit 
			TB_BANK_BUFFER(TB_BIT_COUNTER)<='0';
			S_SDO<='0';
			
			WHEN 31=>--Data parity test
			TB_BANK_BUFFER(TB_BIT_COUNTER)<=DATA_ODD_TEST;
			S_SDO<=DATA_ODD_TEST;
			--S_SCN<='1';
			TB_Cur_state<=Update_ADDR;
						
			WHEN OTHERS=> 
			S_SCN<='1';
			TB_Cur_state<=Idle;

		END CASE;
 			TB_BIT_COUNTER<=TB_BIT_COUNTER+1;

		WHEN SPI_DATA_READ=> 
		-- Collects 32 bits
		-- Only the first 16 bit are important, the rest are not relevant
		-- 1bit(R/W)13bit(ADDR)1bit(P),15bit(Data)1bit(P)
		-- Calculate and create ADDR and DATA ODD parity value
			Time_counter<=0;		
			S_SCN<='0';		
			CASE TB_BIT_COUNTER IS

				WHEN 0 =>
				TB_BANK_BUFFER(TB_BIT_COUNTER)<='1';--'1' Read
				S_SDO<='1';
						
				WHEN 1 TO 14=>--Address pointer 
				--TB_BANK_BUFFER = 32 bit - lsb = R/W, 14 addr...
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-1);
				S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-1);
				ADDR_EVEN_TEST:=ADDR_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-1);
				ADDR_ODD_TEST<=NOT(ADDR_EVEN_TEST);
			
				WHEN 15=>--Address parity test
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_ODD_TEST;
				S_SDO<=ADDR_ODD_TEST;
				
				--All the data from bit 16 to 31 is not relevant according SPI READ protocol
				WHEN 16 TO 29=>--data - 14 LSB Bits are equals to ADDR
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=ADDR_Pointer(TB_BIT_COUNTER-16);
				S_SDO<=ADDR_Pointer(TB_BIT_COUNTER-16);
				DATA_EVEN_TEST:=(DATA_EVEN_TEST XOR ADDR_Pointer(TB_BIT_COUNTER-16));
				DATA_ODD_TEST<=NOT(DATA_EVEN_TEST);

				--All the data from bit 16 to 31 is not relevant according SPI READ protocol
				WHEN 30=>--data: 1 MSB Bit 
				TB_BANK_BUFFER(TB_BIT_COUNTER)<='0';
				S_SDO<='0';

				--All the data from bit 16 to 31 is not relevant according SPI READ protocol		
				WHEN 31=>--Data parity test
				TB_BANK_BUFFER(TB_BIT_COUNTER)<=DATA_ODD_TEST;
				S_SDO<=DATA_ODD_TEST;
				--S_SCN<='1';
				TB_Cur_state<=Update_ADDR;		

				WHEN OTHERS=> -- when BIT COUNTER =32
				S_SCN<='1';
				TB_Cur_state<=Idle;

		END CASE;
 			TB_BIT_COUNTER<=TB_BIT_COUNTER+1;


		WHEN Update_ADDR=>	
			--Update the next address
			--Verify that the address values are according to R/W allowed registers (Page 64)
			IF ADDR_Pointer(15 downto 0)>= x"000C" AND ADDR_Pointer(15 downto 0)<= x"0024"  THEN
				ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );

			ELSIF ADDR_Pointer(15 downto 0)=  x"0025" THEN
			--4 Dummy registers for future use
			--Do not overwrite register, for ams only
				ADDR_Pointer<=x"002A";

			ELSIF  ADDR_Pointer>= x"002A" AND ADDR_Pointer<=x"004E"  THEN
				ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );
			
			ELSIF  ADDR_Pointer= x"004F"  THEN
			--Do not overwrite register, for ams only
				ADDR_Pointer<=x"0052";

			ELSIF ADDR_Pointer>= x"0052" AND ADDR_Pointer<=x"0058"  THEN
				ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );

			ELSIF ADDR_Pointer= x"0059"  THEN
			--Do not overwrite register, for ams only
				ADDR_Pointer<=x"0400";

			ELSIF ADDR_Pointer>= x"0400" AND ADDR_Pointer<x"08FF"  THEN
				ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );
			
			ELSIF ADDR_Pointer=  x"08FF" THEN 
			--Completed all addresses
			ADDR_Pointer<=	x"000C";
			--Change status not(status) -- from data read to write and opposite
			SPI_READ_WR_STATUS<=NOT(SPI_READ_WR_STATUS);   

			END IF;
			--S_SCN<='1';
			TB_Cur_state<=clear_Wait;



			when clear_Wait=>
			--Clear all counters
			--Wait before sending the next vector
			TB_BIT_COUNTER<=0;		--clear bit counter
			TB_BANK_BUFFER(31 downto 0)<=(others=>'0');
			ADDR_EVEN_TEST:='0';  	-- set_odd_test to 0
			DATA_EVEN_TEST:='0';	-- set_odd_test to 0	
			ADDR_ODD_TEST<='0';  	-- set_odd_test to 0
			DATA_ODD_TEST<='0';	-- set_odd_test to 0
			S_SCN<='1';
			IDLE_Wait<=0;
			IF time_counter< (Clk_wait_val) then		 
				time_counter<=time_counter+1;
			ELSE
				S_SCN<='0';			
				IF SPI_READ_WR_STATUS='0' THEN --WRITE
				TB_Cur_state<=SPI_DATA_WR;
				ELSIF SPI_READ_WR_STATUS='1' THEN--READ
				TB_Cur_state<=SPI_DATA_READ;
				END IF;
				
			END IF;
	END CASE;
	END IF;
END PROCESS;


Sampling_SPI_In:Process (s_rst, s_sclk)
begin
if S_rst='1' then
--Clear signals
Sampling_SDI_In <=(others=>'0');
Sampling_SDI_In_ADDR<=(others=>'0');
Sampling_SDI_In_Data <=(others=>'0');
Sampling_ADDR<=(others=>'0');
Sampling_Data<=(others=>'0');

elsif SPI_READ_WR_STATUS='1' then --read mode	
	if falling_edge(S_SCLK) AND (TB_CUR_STATE=SPI_DATA_READ or TB_CUR_STATE=UPDATE_ADDR)  then -- sample SDI input
		--Sample SDI at Falling edge (sclk) and the right states	
		--Sampling SDI signal snd shift right the selected data
		Sampling_SDI_In(0)<= S_SDI ;-- Shift register
		Sampling_SDI_In(31 downto 0)<=S_SDI & Sampling_SDI_In(31 downto 1)  ;-- Shift register right
	
	elsif TB_CUR_STATE=UPDATE_ADDR  then
		-- Present the collected signals as vectors
		Sampling_SDI_In_ADDR<=Sampling_SDI_In(15 downto 0);
		Sampling_SDI_In_Data<=Sampling_SDI_In(31 downto 16);
		Sampling_ADDR<=Sampling_SDI_In(14 downto 1);
		Sampling_Data<=Sampling_SDI_In(30 downto 16);

	elsif TB_CUR_STATE=clear_wait  then
		--Clear signals
		Sampling_SDI_In <=(others=>'0');
		Sampling_SDI_In_ADDR<=(others=>'0');
		Sampling_SDI_In_Data <=(others=>'0');
		Sampling_ADDR<=(others=>'0');
		Sampling_Data<=(others=>'0');

	end if;
end if;

end process;


END Register_IF_TB_arc;