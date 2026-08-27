LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY SPIIFDecoderSM IS

PORT(
	SCLK: IN STD_LOGIC;
	SDO: IN STD_LOGIC;--FPGA to ASIC
	SCn: IN STD_LOGIC;
	RST: IN STD_LOGIC;
	SDI : OUT STD_LOGIC; -- ASIC to FPGA
	RD_WR: OUT STD_LOGIC;--'1' Read
	ADDR_SPI: OUT STD_LOGIC_VECTOR (13 DOWNTO 0); --SPI_Bank_Vector_Buffer(1-14) -ADDRESS
	DATA_WR: OUT STD_LOGIC_VECTOR (15 DOWNTO 0); ----
	DATA_READ: IN STD_LOGIC_VECTOR (15 DOWNTO 0) ----

	);
END SPIIFDecoderSM;

ARCHITECTURE SPIIFDecoderSM_BroadCast_arc OF SPIIFDecoderSM IS
--state machion declearation--
TYPE state_type is (Idle, Sample, RD_WR_Vec_ODD_Par,Diagnose_New_SCn_pulse,Send_Bits_via_SDI);

--Signals declearation--
SIGNAL SPI_Cur_state: state_type;
SIGNAL SPI_Bit_counter : Integer range 0 to 32:=0;
SIGNAL SCn_wait_counter : Integer range 0 to 10:=0;
SIGNAL ODD_ADDR_Parity_Test : STD_logic:='0';
SIGNAL ODD_DATA_Parity_Test : STD_logic:='0';
SIGNAL Pulse_q : STD_logic:='0';
SIGNAL SPI_Bank_Vector_Buffer : STD_LOGIC_vector (31 DOWNTO 0):=(others => '0'); --32 Bits that have the current 32 bit data
SIGNAL SPI_Bank_Vector_FRead : std_logic_vector(31 downto 0):=(others=>'0'); --Are using at "read", send via SPI during read process



-- SIGNAL S_SCLK : STD_logic:='0';
SIGNAL S_SCLK_counter : Integer range -1 to 32:=0;

SIGNAL SDI_int : STD_LOGIC; -- ASIC to FPGA

BEGIN


SCLK_COUNTER : process (SCLK,RST,SCn)
BEGIN
IF RST='1'  then
	S_SCLK_counter<=0;
ELSIF FALLING_EDGE(SCn)  THEN
	S_SCLK_counter<=-1;
ELSIF RISING_EDGE(SCLK) AND SCn='0' THEN

		IF S_SCLK_counter<=31 THEN
			S_SCLK_counter<=S_SCLK_counter+1;

		ELSE
			S_SCLK_counter<=-1;

		END IF;

ELSIF SCn='1' THEN
	S_SCLK_counter<=-1;
END IF;
END PROCESS;

-- !debug: 10/12/2023 NU
-- IN_Clk_to_SCLK: process (RST,SCn )
-- begin
--
-- IF RST='1' THEN
--         S_SCLK<='0';
--
--
-- ELSIF FALLING_EDGE(SCn) THEN
--         S_SCLK<='0';
--
-- ELSIF RISING_edge(SCn) then
--
--  		S_SCLK<='0';
--
-- ELSIF SCn='0'  then
--
--         IF  S_SCLK_counter<31 THEN
--
--         	S_SCLK<=SCLK;
--         ELSE
--
--         	S_SCLK<='0';
--         END IF;
--
-- ELSIF SCn='1'  then
--
--         	S_SCLK<='0';
-- END IF;
--
-- END PROCESS;

--BEGIN
State_machine_pro: PROCESS (SCLK,RST,SCn) -- !debug: 29/04/2021 try fix wrong SCLK problem
VARIABLE EVEN_ADDR_Parity_Test : STD_logic:='0';
VARIABLE EVEN_DATA_Parity_Test : STD_logic:='0';
BEGIN

	IF RST = '1'  THEN
		--Clear all signals
		SPI_Bit_counter<=0;
		ODD_ADDR_Parity_Test <='0';
		ODD_DATA_Parity_Test <='0';
		SPI_Bank_Vector_Buffer<=(OTHERS=>'0');
		EVEN_ADDR_Parity_Test:='0';
		EVEN_DATA_Parity_Test:='0';
		ADDR_SPI <= (others => '0'); --Address
		Pulse_q<='0';
		DATA_WR<=(OTHERS=>'0');-- Data
		RD_WR<='0';
		SDI_int<='1';
		SPI_Cur_state<=Idle;

	ELSIF rising_edge(SCLK)  THEN

		CASE SPI_Cur_state IS

		WHEN Idle=>
			--Clear all flags, similar to reset mode
			SPI_Bit_counter<=0;
			ODD_ADDR_Parity_Test <='0';
			SPI_Bank_Vector_Buffer<=(OTHERS=>'0');
			EVEN_ADDR_Parity_Test:='0';
			EVEN_DATA_Parity_Test:='0';
			ADDR_SPI<=(OTHERS=>'0'); --Address
			DATA_WR<=(OTHERS=>'0');-- Data
			RD_WR<='0';

			--The next part is to identify the falling csn signal
			--Pulse_q remembers the previous value, scn identify the current, if the sequence is 10 it meant that the
			--pulse fell down
			Pulse_q<=scn;
                        -- 10/12/2023 was: delayed SCN, then sample. this bad, because no SCLK, when SCN falling
			-- IF scn='0' and Pulse_q='1' THEN
			--         Pulse_q<='0';
			--         SPI_Cur_state<=Sample;
			-- END IF;
                        -- !debug: 10/12/2023 try fix wrong SCLK problem
                        -- new: go sample data, when 1st SCLK in packet
                        if (TRUE) then -- new block
                          SPI_Cur_state<=Sample;
                          SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC
                          SPI_Bit_counter<=SPI_Bit_counter+1;
                          IF SDO='1' THEN --READ
                                          --FPGA to ASIC
                            SDI_int<='1';
                          END IF;
                        end if;

		WHEN Sample=> -- Sampling 32 bit
			--SPI_Bank_Vector_Buffer(0) - Read/Write
			--SPI_Bank_Vector_Buffer(1-14) -Address
			--SPI_Bank_Vector_Buffer(15) - Parity test
			--SPI_Bank_Vector_Buffer(16-30)- Data
			--SPI_Bank_Vector_Buffer(31)- Data parity

			--Note:
			--(0/1) + (ADDR) .... therefore the ADDR value and SPI_Bank_Vector_Buffer value look different.

			IF SPI_Bit_counter=0 THEN -- Read or Write
				SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC
				SPI_Bit_counter<=SPI_Bit_counter+1;
				IF SDO='1' THEN --READ
					--FPGA to ASIC
					SDI_int<='1';
				END IF;

			ELSIF SPI_Bit_counter<15  and  SPI_Bit_counter>0 THEN -- 14 bits of ADDR, Calculate Parity bit
				SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC
				EVEN_ADDR_Parity_Test:= SDO xor EVEN_ADDR_Parity_Test;
				ODD_ADDR_Parity_Test<=NOT(EVEN_ADDR_Parity_Test);
				SPI_Bit_counter<=SPI_Bit_counter+1;


			ELSIF SPI_Bit_counter=15   THEN -- Parity Bit
				SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC
				SPI_Bit_counter<=SPI_Bit_counter+1;


			ELSIF SPI_Bit_counter<=29  and  SPI_Bit_counter>=16 THEN -- -- 15 bits of DATA, Calculate Parity bit
				SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC
				EVEN_DATA_Parity_Test:= SDO xor EVEN_DATA_Parity_Test;
				ODD_DATA_Parity_Test<=NOT(EVEN_DATA_Parity_Test);
				SPI_Bit_counter<=SPI_Bit_counter+1;

			ELSIF SPI_Bit_counter=30 THEN -- -- 15 bits of DATA, Calculate Parity bit
				SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC
				EVEN_DATA_Parity_Test:= SDO xor EVEN_DATA_Parity_Test;
				ODD_DATA_Parity_Test<=NOT(EVEN_DATA_Parity_Test);
				SPI_Bit_counter<=SPI_Bit_counter+1;
                                -- SPI_Cur_state<=RD_WR_Vec_ODD_Par; -- !debug: 11/12/2023
                                -- SPI_Bank_Vector_FRead<=SPI_Bank_Vector_Buffer; -- !debug: 11/12/2023
				-- SPI_Bit_counter<=0; -- !debug: 11/12/2023

			ELSIF SPI_Bit_counter=31  THEN --  Parity bit
				SPI_Bank_Vector_Buffer(SPI_Bit_counter)<=SDO;--FPGA to ASIC

				SPI_Bit_counter<=0;
				IF SPI_Bank_Vector_Buffer(0)='1' THEN --READ
					SPI_Bank_Vector_FRead(SPI_Bit_counter)<=not(SPI_Bank_Vector_Buffer(16) xor SPI_Bank_Vector_Buffer(17) xor SPI_Bank_Vector_Buffer(18) xor SPI_Bank_Vector_Buffer(19) xor SPI_Bank_Vector_Buffer(20) xor SPI_Bank_Vector_Buffer(21) xor SPI_Bank_Vector_Buffer(22) xor SPI_Bank_Vector_Buffer(23) xor SPI_Bank_Vector_Buffer(24) xor SPI_Bank_Vector_Buffer(25) xor SPI_Bank_Vector_Buffer(26) xor SPI_Bank_Vector_Buffer(27) xor SPI_Bank_Vector_Buffer(28) xor SPI_Bank_Vector_Buffer(29) xor SPI_Bank_Vector_Buffer(30));
				END IF;
				SPI_Cur_state<=RD_WR_Vec_ODD_Par;
                                -- !debug: 10/12/2023 early read from R_W_Bank_Reg
                                ADDR_SPI(13 DOWNTO 0)<=SPI_Bank_Vector_Buffer(14 DOWNTO 1); --Address
                                RD_WR<='1';

			END IF;
			SPI_Bank_Vector_FRead<=SPI_Bank_Vector_Buffer;

		WHEN RD_WR_Vec_ODD_Par=>

			--Verify odd parity test ADDR, compare to Internal_ADDR_Parity_Test

				IF (
				   (ODD_ADDR_Parity_Test = '1' and SPI_Bank_Vector_Buffer(15)='1'  and  ODD_DATA_Parity_Test = '1' and SPI_Bank_Vector_Buffer(31)='1' )
					OR
				   (ODD_ADDR_Parity_Test = '1' and SPI_Bank_Vector_Buffer(15)='1'  and  ODD_DATA_Parity_Test = '0' and SPI_Bank_Vector_Buffer(31)='0' )
					OR
				   (ODD_ADDR_Parity_Test = '0' and SPI_Bank_Vector_Buffer(15)='0' AND ODD_DATA_Parity_Test = '1' and SPI_Bank_Vector_Buffer(31)='1')
					OR
				   (ODD_ADDR_Parity_Test = '0' and SPI_Bank_Vector_Buffer(15)='0' AND ODD_DATA_Parity_Test = '0' and SPI_Bank_Vector_Buffer(31)='0')
          or TRUE                       -- !debug: 04/05/2021 skip parity test
						)
				THEN -- Passed the Parity tests

					IF SPI_Bank_Vector_Buffer(0)= '0' THEN --SPI_Bank_Vector_Buffer(0) - Write
						ADDR_SPI(13 DOWNTO 0)<=SPI_Bank_Vector_Buffer(14 DOWNTO 1); --Address
						-- DATA_WR(15 DOWNTO 0)<=SPI_Bank_Vector_Buffer(31 DOWNTO 16);-- Data
            DATA_WR(15 DOWNTO 0)<='0'&SPI_Bank_Vector_Buffer(30 DOWNTO 16);-- Data !debug: 06/05/2021 removed parity
						RD_WR<='0';
						SDI_int<='1';
						SPI_Cur_state<=IDLE; --Write

					ELSE --SPI_Bank_Vector_Buffer(0)= "1" - Read
						ADDR_SPI(13 DOWNTO 0)<=SPI_Bank_Vector_Buffer(14 DOWNTO 1); --Address
						SPI_Bank_Vector_Buffer(30 DOWNTO 16)<=DATA_READ(14 downto 0);--example
						SPI_Bank_Vector_FRead<=SPI_Bank_Vector_Buffer;-- Load the first read vector
						RD_WR<='1';
						SDI_int<='1';
						SPI_Bit_counter<=0;--Reset bit counter before the data will be sent via SPI and bit counter will be needed
						SPI_Cur_state<=Diagnose_New_SCn_pulse;
					END IF;

				ELSE --Failed during the parity test

					SPI_Cur_state<=IDLE;

				END IF;

		WHEN Diagnose_New_SCn_Pulse =>
			--Looking for new fell CSn signal
			--Before sending out the data (according to ADDR) and sampling new 32 bit, the mode will wait
			--for new SCn
			--calculate SPI_Bank_Vector_FRead(31) odd parity value
				SDI_int <='1';
				SPI_Bank_Vector_FRead(15 downto 0)<=SPI_Bank_Vector_Buffer(15 downto 0);-- set the addr of the last request
				-- SPI_Bank_Vector_FRead(30 downto 16)<=DATA_READ(14 downto 0);-- set the data of relavent addr
                                SPI_Bank_Vector_FRead(30 downto 16)<=DATA_READ(15 downto 1);-- set the data of relavent addr !debug: 10/12/2023
				SPI_Bank_Vector_FRead(31)<=not(DATA_READ(0) xor DATA_READ(1) xor DATA_READ(2) xor DATA_READ(3) xor DATA_READ(4) xor DATA_READ(5) xor DATA_READ(6) xor DATA_READ(7) xor DATA_READ(8) xor DATA_READ(9) xor DATA_READ(10) xor DATA_READ(11) xor DATA_READ(12) xor DATA_READ(13) xor DATA_READ(14));
				ADDR_SPI(13 DOWNTO 0)<=SPI_Bank_Vector_Buffer(14 DOWNTO 1); --Address

				--Dignose new SCn falling edge
				Pulse_q<=scn;
                                -- 10/12/2023 was: delayed SCN, then sample. this bad, because no SCLK, when SCN falling
                                --            new: go sample data, when 1st SCLK in packet
				-- IF scn='0' and Pulse_q='1' THEN
                                --  Pulse_q<='0';
                                --  --clear SPI_Bank_Vector_Buffer
                                --  SPI_Bank_Vector_Buffer<=(others=>'0');
                                --  SPI_Cur_state<=Send_Bits_via_SDI; --Read data
				-- END IF;
                        if (TRUE) then -- new block
                          SPI_Cur_state<=Send_Bits_via_SDI; --Read data
                          SDI_int<=SPI_Bank_Vector_FRead(SPI_Bit_counter+1);-- ASIC to FPGA !debug: 10/12/2023 from here to end was SPI_Bank_Vector_FRead(SPI_Bit_counter+1)
                          SPI_Bit_counter<=SPI_Bit_counter+1;
                        end if;


		WHEN Send_Bits_via_SDI=>
			-- Send and receive DATA_READ and Data_WR&SPI_ADDR vectors simultaneously

		Case SPI_Bit_counter IS
			--SPI_Bank_Vector_Buffer(0) - Read/Write
			--SPI_Bank_Vector_Buffer(1-14) -Address
			--SPI_Bank_Vector_Buffer(15) - Parity test
			--SPI_Bank_Vector_Buffer(16-30)- Data
			--SPI_Bank_Vector_Buffer(31)- Data parity

			WHEN 0 =>--THEN -- Read mode

				--load SPI_Bank_Vector_FRead in SPI_Bank_Vector_Buffer value

				SDI_int<=SPI_Bank_Vector_FRead(SPI_Bit_counter+1);-- ASIC to FPGA
				SPI_Bit_counter<=SPI_Bit_counter+1;

			WHEN  1 TO 14 => -- 14 bits of ADDR, Calculate Parity bit
				SDI_int<=SPI_Bank_Vector_FRead(SPI_Bit_counter+1);-- ASIC to FPGA
				EVEN_ADDR_Parity_Test:= SDO xor EVEN_ADDR_Parity_Test;
				ODD_ADDR_Parity_Test<=NOT(EVEN_ADDR_Parity_Test);
				SPI_Bit_counter<=SPI_Bit_counter+1;

			WHEN 15  => -- Parity Bit
				SDI_int<=SPI_Bank_Vector_FRead(SPI_Bit_counter+1);-- ASIC to FPGA
				SPI_Bit_counter<=SPI_Bit_counter+1;

			WHEN  16 TO 30 => -- 15 bits of DATA, Calculate Parity bit
				SDI_int<=SPI_Bank_Vector_FRead(SPI_Bit_counter+1);-- ASIC to FPGA
				EVEN_DATA_Parity_Test:= SDO xor EVEN_DATA_Parity_Test;
				ODD_DATA_Parity_Test<=NOT(EVEN_DATA_Parity_Test);
				SPI_Bit_counter<=SPI_Bit_counter+1;

			-- WHEN 30  => -- !debug: 11/12/2023 send before, because also send data on previous state
			--         SDI_int<='1';-- ASIC to FPGA
			--         SPI_Bit_counter<=0;
			--         SPI_Cur_state<=idle;

			WHEN 31  => --  Parity data flag
				SDI_int<='1';-- ASIC to FPGA
				SPI_Bit_counter<=0;
				SPI_Cur_state<=idle;


			WHEN  OTHERS=>
				SPI_Bit_counter<=0; --reset bit counter ;
				SPI_Cur_state<=IDLE;
			END CASE;


		WHEN OTHERS=>
			SPI_Cur_state<=Idle;

		END CASE;

			END IF;


END PROCESS;


sdo_polarity_pr: process (SCLK) is
begin  -- process sdo_polarity_pr
  if falling_edge(SCLK) then   -- falling clock edge

    SDI <= SDI_int;                     -- 10/12/2023 Eugene Shinderman: SDO changes at the falling edge of SCLK

  end if;
end process sdo_polarity_pr;


END SPIIFDecoderSM_BroadCast_arc;
