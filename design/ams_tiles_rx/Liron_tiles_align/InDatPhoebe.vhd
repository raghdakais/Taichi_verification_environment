--

-- Purpose:
-- This module instantiates the Xilinx 7-series primitives necessary for
-- de-serializing the LVDS_25 data stream.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity InDatPhoebe is
   Generic (
      TapWidth : natural := 5;   -- number of bits for IDELAYE2 tap counter
      ParallelWidth : natural := 8); -- number of parallel bits
   Port (

	  CLKDIV   			 : in std_logic;   --parallel clock output side and control CLK (CLKDIV)
      FCLK      		 : in std_logic;    --serial clock input side
      TILE_RDY   		 :  in std_logic;
      --Encoded serial data
      -- sDataIn_p          : in  std_logic;  -- data channel positive
      -- sDataIn_n          : in  std_logic;  -- data channel negative
      sDataIn_i          : in  std_logic;  -- 28/06/2022 IBUFDS moved to top

      --Encoded parallel data (raw)
      pDataIn_O 		 : out STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);

      IDLY_CNT  		 : out std_logic_vector(TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count
      aRst      		 : in STD_LOGIC;
	  Phoebe_data_locked : out std_logic
   );
end InDatPhoebe;

architecture Behavioral of InDatPhoebe is

signal sDataIn, sDataInDly, FCLK_inv : std_logic;
signal CNTVALUEIN: natural range 0 to 2**TapWidth - 1 ;
type sm_state is (idle,clocks_rdy,Bit_align,pre_byte_align,byte_align,wait_st,look_for_sync,wait_for_sync,synced);
signal sm4sync : sm_state;
signal Bitslip  : std_logic:='0';
signal IDLY_LD  : std_logic:='0';  --IDELAYE2 Load
signal IDLY_CE  : std_logic:='0';  --IDELAYE2 CE
signal IDLY_INC : std_logic:='0';  --IDELAYE2 Tap Increment
signal TILE_RDY_stable : std_logic_vector(3 downto 0);
signal pDataIn,pDataIn_q,pDataIn_prev  : STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);

Signal cnt_idle_byte           : natural range 0 to 7;
constant cnt_num_byte          : natural range 0 to 7:=7;
constant delay_num             : natural range 0 to 15:=15;
Signal delay_cnt_byte          : natural range 0 to 15:=0;
constant IDLE_WORD             : std_logic_vector(7 downto 0):=x"B5";
Signal TILE_OK                 : std_logic:='0';
signal CNTVALUEIN_std          : std_logic_vector(TapWidth-1 downto 0);  --ISERDESE2 can do 1:14 at most
signal delay_cnt               : std_logic_vector(1 downto 0):="00";
signal change_det              : std_logic:='0';
signal Phoebe_data_locked_int      : std_logic:='0';
-- attribute IODELAY_GROUP : STRING;
-- attribute IODELAY_GROUP of InputDelay: label is "ams_rx_in_group";

 attribute DONT_TOUCH : string;
 attribute DONT_TOUCH of pDataIn : signal is "TRUE";
 attribute mark_debug : string;
 attribute mark_debug of pDataIn : signal is "true";


BEGIN




-- -- Differential input buffer for TMDS I/O standard
-- InputBuffer: IBUFDS
--    generic map (
--       DIFF_TERM  => TRUE,
--       IOSTANDARD => "LVDS_25")
--    port map (
--       I          => sDataIn_p,
--       IB         => sDataIn_n,
--       O          => sDataIn);
sDataIn <= sDataIn_i; -- ES: 28/06/2022 IBUFDS moved to top


-- Delay element for phase alignment of serial data
InputDelay: IDELAYE2
   generic map (
      CINVCTRL_SEL           => "FALSE",       -- TRUE, FALSE
      DELAY_SRC              => "IDATAIN",     -- IDATAIN, DATAIN
      HIGH_PERFORMANCE_MODE  => "TRUE",        -- TRUE, FALSE
      IDELAY_TYPE            => "VAR_LOAD",    -- FIXED, VARIABLE, or VAR_LOADABLE
      IDELAY_VALUE           => 0,             -- 0 to 31
      REFCLK_FREQUENCY       => 200.0,         -- values can be range 190-210, 290-310 ,390-410
                                               -- !debug: 26/07/2022 was 192.0
      PIPE_SEL               => "FALSE",
      SIGNAL_PATTERN         => "DATA")        -- CLOCK, DATA
   port map (
      DATAOUT                => sDataInDly,    -- Delayed signal
      DATAIN                 => '0',           -- Not used; IDATAIN instead
      C                      => CLKDIV,        -- Clock for control signals (CE,INC...)
      CE                     => IDLY_CE,
      INC                    => IDLY_INC,
      IDATAIN                => sDataIn,       -- Driven by IOB
      LD                     => IDLY_LD,
      REGRST                 => aRst, -- !debug: 17/07/2022 '0',           -- not used in VARIABLE mode
      LDPIPEEN               => '0',
      CNTVALUEIN             => CNTVALUEIN_std,-- not used in VARIABLE mode
      CNTVALUEOUT            => IDLY_CNT,      -- current tap value
      CINVCTRL               => '0');

--Invert locally for ISERDESE2
FCLK_inv <= not FCLK;

-- De-serializer, 1:8 (1:8 SDR), master-slave cascaded
DeserializerMaster: ISERDESE2
   generic map (
      DATA_RATE         => "SDR",
      DATA_WIDTH        => ParallelWidth,
      INTERFACE_TYPE    => "NETWORKING",
	  INIT_Q1           => '0',
	  INIT_Q2           => '0',
	  INIT_Q3           => '0',
	  INIT_Q4           => '0',
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      NUM_CE            => 1,
      OFB_USED          => "FALSE",
      IOBDELAY          => "IFD",      -- Use input at DDLY to output the data on Q1-Q8
      SERDES_MODE       => "MASTER")
   port map (
      Q1                => pDataIn_q(0),
      Q2                => pDataIn_q(1),
      Q3                => pDataIn_q(2),
      Q4                => pDataIn_q(3),
      Q5                => pDataIn_q(4),
      Q6                => pDataIn_q(5),
      Q7                => pDataIn_q(6),
      Q8                => pDataIn_q(7),
      SHIFTOUT1         => open,       -- unused  Cascade connection to Slave ISERDES
      SHIFTOUT2         => open,       -- unused  Cascade connection to Slave ISERDES
      BITSLIP           => Bitslip,    -- 1-bit Invoke Bitslip. This can be used with any
      CE1               => '1',        -- 1-bit Clock enable input
      CE2               => '1',        -- 1-bit Clock enable input
      CLK               => FCLK,       -- Fast Source Synchronous SERDES clock from BUFIO
      CLKB              => FCLK_inv,   -- Locally inverted clock
      CLKDIV            => CLKDIV,     -- Slow clock driven by BUFR
      CLKDIVP           => '0',        -- Not used here
      D                 => '0',
      DDLY              => sDataInDly, -- 1-bit Input signal from IODELAYE1.
      RST               => aRst,       -- 1-bit Asynchronous reset only.
      SHIFTIN1          => '0',
      SHIFTIN2          => '0',
      -- unused connections
      DYNCLKDIVSEL      => '0',
      DYNCLKSEL         => '0',
      OFB               => '0',
      OCLK              => '0',
      OCLKB             => '0',
      O                 => open);      -- unregistered output of ISERDESE1

-------------------------------------------------------------
-- Concatenate the serdes outputs together. Keep the timesliced
-- bits together, and placing the earliest bits on the right
-- ie, if data comes in 0, 1, 2, 3, 4, 5, 6, 7, ...
-- the output will be 3210, 7654, ...
-------------------------------------------------------------
SliceISERDES_q: for slice_count in 0 to ParallelWidth-1 generate begin
   -- This places the first data in time on the right
   pDataIn(slice_count) <= pDataIn_q(ParallelWidth-slice_count-1);
   -- pDataIn(slice_count) <= pDataIn_q(slice_count); -- 17/07/2022 Liron
  end generate SliceISERDES_q;

--idle,clocks_rdy,Bit_align,byte_align,wait_st,sync_rdy

IDLY_CE <='0'; --IDELAYE2 CE
IDLY_INC<='0'; --IDELAYE2 Tap Increment
CNTVALUEIN_std <= std_logic_vector (to_unsigned(CNTVALUEIN,CNTVALUEIN_std'length));
process (CLKDIV,aRST)
begin
	if aRST ='1' then
	Bitslip <='0';
	IDLY_LD <='0'; --IDELAYE2 Load
    TILE_RDY_stable <= (others=>'0');
	TILE_OK<='0';
    delay_cnt <="00";
	change_det <='0';
	cnt_idle_byte<=0;
	delay_cnt_byte<=0;
	Phoebe_data_locked_int<='0';
	sm4sync<=idle;
	CNTVALUEIN<=0;
	pDataIn_prev<= (others=>'0');
	pDataIn_O <= (others=>'1');
	elsif CLKDIV'event and CLKDIV='1' then
	    IDLY_LD<='0';
		TILE_RDY_stable<= TILE_RDY_stable(2 downto 0) & TILE_RDY;
		if TILE_RDY_stable(3 downto 2) ="11" then
		   TILE_OK<='1';
		else
		   TILE_OK<='0';
		end if;

		-------------------------------------------------------------------------------------------------------------------
		if TILE_OK='1' then
			case sm4sync is
			when idle           =>	    cnt_idle_byte<=0;
										delay_cnt_byte<=0;
										sm4sync <=clocks_rdy ;
										IDLY_LD<='1';
										CNTVALUEIN<=0;
										-- if TILE_OK ='1' then
											-- sm4sync <=clocks_rdy ;
											-- IDLY_LD<='1';
											-- CNTVALUEIN<=0;
										-- end if;
										delay_cnt<="00";
										change_det<='0';

			when clocks_rdy     =>   	IDLY_LD<='0';
										if delay_cnt="11" then
											sm4sync<=Bit_align;
											delay_cnt<="00";
										else
											delay_cnt<=delay_cnt+1;
										end if;

			when Bit_align      =>  	IDLY_LD<='1';
										sm4sync<= wait_st;
										if change_det ='0' then
											sm4sync<= wait_st;
											if CNTVALUEIN=31 then
												CNTVALUEIN<=16;
												sm4sync <= pre_byte_align;
											else
												CNTVALUEIN<= CNTVALUEIN+1;
												sm4sync<= wait_st;
											end if;
										else
											sm4sync<= pre_byte_align; -- !debug: 28/07/2022 Liron: wait_st -> pre_byte_align
											if CNTVALUEIN< 16 then
												CNTVALUEIN<=CNTVALUEIN+16;
											else
												CNTVALUEIN<= CNTVALUEIN-16;
											end if;
										end if;
										pDataIn_prev<= pDataIn;
										delay_cnt<="00";

			when wait_st   		=>	  	IDLY_LD<='0';
										delay_cnt<=delay_cnt+1;
										if delay_cnt="11" then
											sm4sync<= Bit_align;
											if pDataIn_prev = pDataIn then
												delay_cnt<="00";
												change_det <='0';
											else
												change_det <='1';
												delay_cnt<="00";
											end if;
										end if;

			when pre_byte_align =>  	IDLY_LD<='0';
										delay_cnt<=delay_cnt+1;
										if delay_cnt="11" then
											sm4sync<=byte_align;
											delay_cnt<="00";
										end if;

			when byte_align 	=>  	if pDataIn = IDLE_WORD then
											if (cnt_idle_byte < 7) then -- !debug: 28/06/2022
											cnt_idle_byte	<=cnt_idle_byte+1;
											end if;
										else
											cnt_idle_byte	<=0;
										end if;
										
										if (delay_cnt_byte < 15) then -- !debug: 28/06/2022
											delay_cnt_byte<=delay_cnt_byte+1;
										end if;
										
										if cnt_idle_byte = cnt_num_byte then

											sm4sync	<=	synced;
											delay_cnt_byte		<=	0;
											cnt_idle_byte		<=	0;

										elsif delay_cnt_byte = delay_num then
	
												sm4sync	<= 	look_for_sync;
												delay_cnt_byte		<=	0;
										end if;

			when look_for_sync	=>		Bitslip	<=	'1';
										sm4sync			<= 	wait_for_sync;
										Phoebe_data_locked_int		<=	'0';

			when wait_for_sync	=>		Bitslip	<=	'0';
										if (delay_cnt_byte < 15) then -- !debug: 28/06/2022
												delay_cnt_byte	<=	delay_cnt_byte+1;
										end if;
										Phoebe_data_locked_int		<=	'0';

										if pDataIn = IDLE_WORD then
											if (cnt_idle_byte < 7) then -- !debug: 28/06/2022
												cnt_idle_byte	<=cnt_idle_byte+1;
											end if;
										else
											cnt_idle_byte<=0;
										end if;

										if cnt_idle_byte=cnt_num_byte then
											sm4sync<=synced;

										elsif delay_cnt_byte = delay_num then
											sm4sync<= look_for_sync;
											delay_cnt_byte<=0;
										end if;

			when synced	=>				Phoebe_data_locked_int	<='1';
										cnt_idle_byte			<=0;

			end case;
		else
			Bitslip <='0';
            IDLY_LD <='0';
            delay_cnt <="00";
            change_det <='0';
            cnt_idle_byte<=0;
            delay_cnt_byte<=0;
            Phoebe_data_locked_int<='0';
            sm4sync<=idle;
            CNTVALUEIN<=0;
            pDataIn_prev<= (others=>'0');
            pDataIn_O <= (others=>'1');
		end if;


		--------------------------------------------------------------------------------------------------------------------
		if Phoebe_data_locked_int = '1' then -- Liron: 14/08/2022
		pDataIn_O<= pDataIn;
		else
		pDataIn_O<= (others=>'1');
		end if;

	end if;
end process;

Phoebe_data_locked<= Phoebe_data_locked_int;


end Behavioral;
