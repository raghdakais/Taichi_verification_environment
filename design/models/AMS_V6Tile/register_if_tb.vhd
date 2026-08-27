library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Register_IF_TB IS END;
ARCHITECTURE Register_IF_TB_arc of Register_IF_TB is 
------DUT Component Declaration-------
Component Register_IF IS 
Port(
	SClk	: IN STD_LOGIC;
	SDO	: IN STD_LOGIC; --FPGA to ASIC
	SCn	: IN STD_LOGIC;
	Rst	: IN STD_LOGIC;
	SDI	: OUT STD_LOGIC; -- ASIC to FPGA
	Calibration	: OUT STD_LOGIC;	
	OperationMode	: OUT STD_LOGIC;		
	set_up		: OUT STD_LOGIC;	
--Configuration Registers outputs
--LVDS_CONFIG_1
	num_data_lines	: OUT STD_LOGIC; --LVDS_CONFIG_1(0)
	legacy_mode	: OUT STD_LOGIC; --LVDS_CONFIG_1(1)
	data_word_length: OUT STD_LOGIC_VECTOR (3 DOWNTO 0); --LVDS_CONFIG_1(5 DOWNTO 2)
	idle_word	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0); --LVDS_CONFIG_1(13 DOWNTO 6)
	
--LVDS_CONFIG_2 
	start_delay_14DownTo0	:OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3 
	start_delay_17DownTo15	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --LVDS_CONFIG_3(2 DOWNTO 0)
	scrambler_rst		: OUT STD_LOGIC; --LVDS_CONFIG_3(3)
	scrambler_en		: OUT STD_LOGIC; --LVDS_CONFIG_3(4)
	footer_disable		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0); --LVDS_CONFIG_3(10 DOWNTO 5)
	tm_aci_data		: OUT STD_LOGIC; --LVDS_CONFIG_3(11)
	raw_data_bypass		: OUT STD_LOGIC; --LVDS_CONFIG_3(12)

--Clock_CTRL
	hclk_div_cfg	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0); --Clock_CTRL(2 DOWNTO 0)

--PADS_CONFIG_2
	itest_dis	: OUT STD_LOGIC; --PADS_CONFIG_2(0)
	d_start_oen	: OUT STD_LOGIC; --PADS_CONFIG_2(1)
	data1_en	: OUT STD_LOGIC; --PADS_CONFIG_2(2)
	data2_en	: OUT STD_LOGIC; --PADS_CONFIG_2(3)
	clk_en 		: OUT STD_LOGIC; --PADS_CONFIG_2(9)
	daisy_chain	: OUT STD_LOGIC; --PADS_CONFIG_2(10)

--START_WORD_0
	LVDS_start_word_14DownTo0	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--START_WORD_1
	LVDS_start_word_29DownTo15	: OUT STD_LOGIC_VECTOR (14 DOWNTO 0); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--START_WORD_2
	LVDS_start_word_39DownTo30	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0) --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>

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

--Configuration Registers outputs
--LVDS_CONFIG_1
SIGNAL S_num_data_lines		: STD_LOGIC:='0'; --LVDS_CONFIG_1(0)
SIGNAL S_legacy_mode		: STD_LOGIC:='0'; --LVDS_CONFIG_1(1)
SIGNAL S_data_word_length	: STD_LOGIC_VECTOR (3 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_1(5 DOWNTO 2)
SIGNAL S_idle_word		: STD_LOGIC_VECTOR (7 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_1(13 DOWNTO 6)
	
--LVDS_CONFIG_2 
SIGNAL S_start_delay_14DownTo0	:STD_LOGIC_VECTOR (14 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_2(14 DOWNTO 0)

--LVDS_CONFIG_3 
SIGNAL S_start_delay_17DownTo15	: STD_LOGIC_VECTOR (2 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_3(2 DOWNTO 0)
SIGNAL S_scrambler_rst		: STD_LOGIC:='0'; --LVDS_CONFIG_3(3)
SIGNAL S_scrambler_en		: STD_LOGIC:='0'; --LVDS_CONFIG_3(4)
SIGNAL S_footer_disable		: STD_LOGIC_VECTOR (5 DOWNTO 0):=(others=>'0'); --LVDS_CONFIG_3(10 DOWNTO 5)
SIGNAL S_tm_aci_data		: STD_LOGIC:='0'; --LVDS_CONFIG_3(11)
SIGNAL S_raw_data_bypass	: STD_LOGIC:='0'; --LVDS_CONFIG_3(12)

--Clock_CTRL
SIGNAL S_hclk_div_cfg		: STD_LOGIC_VECTOR (2 DOWNTO 0):=(others=>'0'); --Clock_CTRL(2 DOWNTO 0)

--PADS_CONFIG_2
SIGNAL S_itest_dis		: STD_LOGIC:='0'; --PADS_CONFIG_2(0)
SIGNAL S_d_start_oen		: STD_LOGIC:='0'; --PADS_CONFIG_2(1)
SIGNAL S_data1_en		: STD_LOGIC:='0'; --PADS_CONFIG_2(2)
SIGNAL S_data2_en		: STD_LOGIC:='0'; --PADS_CONFIG_2(3)
SIGNAL S_clk_en 		: STD_LOGIC:='0'; --PADS_CONFIG_2(9)
SIGNAL S_daisy_chain		: STD_LOGIC:='0'; --PADS_CONFIG_2(10)

--START_WORD_0
SIGNAL S_LVDS_start_word_14DownTo0	: STD_LOGIC_VECTOR (14 DOWNTO 0):=(others=>'0'); --START_WORD_0(14 DOWNTO 0), Start Word bits <14:0>

--START_WORD_1
SIGNAL S_LVDS_start_word_29DownTo15	: STD_LOGIC_VECTOR (14 DOWNTO 0):=(others=>'0'); --START_WORD_1(14 DOWNTO 0), Start Word bits <29:15>

--START_WORD_2
SIGNAL S_LVDS_start_word_39DownTo30	: STD_LOGIC_VECTOR (9 DOWNTO 0):=(others=>'0'); --START_WORD_2(9 DOWNTO 0), Start Word bits <39:30>



--State Machion Signals declearation--
SIGNAL TB_Cur_state		: state_type;
SIGNAL TB_BIT_COUNTER		: Integer range 0 to 32:=0;
SIGNAL ADDR_Pointer		: std_logic_vector(15 downto 0):= x"000C"; -- starts at ADDR=000C
SIGNAL TB_BANK_BUFFER 		: std_logic_vector(31 downto 0):=(others=>'0'); --32 Bits that have the current 32 bit data
SIGNAL ADDR_ODD_TEST		: std_logic :='0';
SIGNAL DATA_ODD_TEST		: std_logic :='0';
SIGNAL IDLE_Wait		: INTEGER:=0; -- start to send the data to SPI, when '1' => current state=END TO_SPI
SIGNAL Time_counter		: Integer range 0 to 32:=0;
SIGNAL SPI_READ_WR_STATUS 	: std_logic:='0'; --=0 Write. 1 = Read --This signal is for changing between read mode and write mode

---FOR Sampling_SPI_In process
SIGNAL Sampling_SDI_In 		: std_logic_vector(31 downto 0):=(others=>'0');
SIGNAL Sampling_SDI_In_ADDR	: std_logic_vector(15 downto 0):=(others=>'0');
SIGNAL Sampling_SDI_In_Data	: std_logic_vector(15 downto 0):=(others=>'0');
SIGNAL Sampling_ADDR		: std_logic_vector(13 downto 0):=(others=>'0');
SIGNAL Sampling_Data		: std_logic_vector(14 downto 0):=(others=>'0');
----
Begin
DUT: Register_IF
Port map
	(SClk=>S_SCLK,
	SDO=>S_SDO,
	SCn=>S_SCn,
	Rst=>S_rst,
	SDI=>S_SDI ,

--LVDS_CONFIG_1
	num_data_lines	=>S_num_data_lines,
	legacy_mode	=>S_legacy_mode,
	data_word_length=>S_data_word_length,
	idle_word	=>S_idle_word,
	

--LVDS_CONFIG_2 
	start_delay_14DownTo0=>S_start_delay_14DownTo0,

--LVDS_CONFIG_3 
	start_delay_17DownTo15	=>S_start_delay_17DownTo15,
	scrambler_rst		=>S_scrambler_rst,
	scrambler_en		=>S_scrambler_en,
	footer_disable		=>S_footer_disable,
	tm_aci_data		=>S_tm_aci_data,
	raw_data_bypass		=>S_raw_data_bypass,

--Clock_CTRL
	hclk_div_cfg		=>S_hclk_div_cfg,
	

--PADS_CONFIG_2
	itest_dis		=>S_itest_dis,
	d_start_oen		=>S_d_start_oen,
	data1_en		=>S_data1_en,
	data2_en		=>S_data2_en,
	clk_en			=>S_clk_en,
	daisy_chain		=>S_daisy_chain,
	

--LVDS_START_WORD_0
	LVDS_start_word_14DownTo0	=>S_LVDS_start_word_14DownTo0,

--LVDS_START_WORD_1
	LVDS_start_word_29DownTo15	=>S_LVDS_start_word_29DownTo15,

--LVDS_START_WORD_2
	LVDS_start_word_39DownTo30	=>S_LVDS_start_word_39DownTo30

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
			
			TB_BIT_COUNTER<=0;		--clear_Wait bit counter
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
			S_SCN<='1';
			TB_Cur_state<=Update_ADDR;
						
			WHEN OTHERS=> 
			S_SCN<='1';
			TB_Cur_state<=Idle;

		END CASE;
 			TB_BIT_COUNTER<=TB_BIT_COUNTER+1;

		WHEN SPI_DATA_READ=> 

		-- At this state for 32 Clks
		-- Creating/collecting 32 bits
		-- Only the first 16 bit are immportant, the rest are not relevant
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
			S_SCN<='1';
			TB_Cur_state<=Update_ADDR;		

			WHEN OTHERS=> -- when BIT COUNTER =32
			S_SCN<='1';
			TB_Cur_state<=Idle;

		END CASE;
 			TB_BIT_COUNTER<=TB_BIT_COUNTER+1;


		WHEN Update_ADDR=>	
			--Update the next address
			--verify that the address are accordding to R/W allowed registers (p64)
			IF ADDR_Pointer(15 downto 0)>= x"000C" AND ADDR_Pointer(15 downto 0)<= x"0024"  THEN
				--ADDR_Pointer(15 downto 0)<=ADDR_Pointer(15 downto 0)+X"0001";
				ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );

--add this part for testing Write and read functinality
			ELSIF ADDR_Pointer(15 downto 0)=  x"0025" THEN
			--next step change Read Write status
				ADDR_Pointer<=x"08FF";		
--this section tested at previos tests
		--	ELSIF ADDR_Pointer(15 downto 0)=  x"0025" THEN
			--4 Dummy registers for future use
			--Do not overwrite register, for ams only
		--		ADDR_Pointer<=x"002A";

		--	ELSIF  ADDR_Pointer>= x"002A" AND ADDR_Pointer<=x"004E"  THEN
		--		ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );
			
		--	ELSIF  ADDR_Pointer= x"004F"  THEN
			--Do not overwrite register, for ams only
		--		ADDR_Pointer<=x"0052";

		--	ELSIF ADDR_Pointer>= x"0052" AND ADDR_Pointer<=x"0058"  THEN
		--		ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );

		--	ELSIF ADDR_Pointer= x"0059"  THEN
			--Do not overwrite register, for ams only
		--		ADDR_Pointer<=x"0400";

		--	ELSIF ADDR_Pointer>= x"0400" AND ADDR_Pointer<x"08FF"  THEN
		--		ADDR_Pointer(15 downto 0)<= std_logic_vector( unsigned(ADDR_Pointer(15 downto 0)) + 1 );
			
			ELSIF ADDR_Pointer=  x"08FF" THEN 
			--Completed all addresses
			ADDR_Pointer<=	x"000C";
			--Change status not(status) -- from data read to write and opposite
			SPI_READ_WR_STATUS<=NOT(SPI_READ_WR_STATUS);   

			END IF;
			S_SCN<='1';
			TB_Cur_state<=clear_Wait;



			when clear_Wait=>
			--Clear all counters
			--Wait before send the next vector
			TB_BIT_COUNTER<=0;		--clear bit counter
			TB_BANK_BUFFER(31 downto 0)<=(others=>'0');
			ADDR_EVEN_TEST:='0';  	-- set_odd_test to 0
			DATA_EVEN_TEST:='0';	-- set_odd_test to 0	
			ADDR_ODD_TEST<='0';  	-- set_odd_test to 0
			DATA_ODD_TEST<='0';	-- set_odd_test to 0
			
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