--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
Library UNISIM;
use UNISIM.vcomponents.all;
-------------------------------------------------------------------------------


ENTITY REAL_TILE IS
    Generic ( --Bytes_per_det  : IN     integer range 3 to 5;
 			 IDLE_WORD       : IN     std_logic_vector (7 downto 0);
 			 START_WORD      : IN     std_logic_vector (39 downto 0);
 			 optional_footer : IN     std_logic
 );
    PORT(
     Bytes_per_det     : IN     integer range 3 to 5;
     RESET             : IN     std_logic;
 	 ACLK              : IN     std_logic;
 	 SYNC              : IN     std_logic;
     DISCARD           : IN     std_logic;
     CLKDIV     	   : IN     std_logic;
	 FCLK	           : IN     std_logic;
 	 SCSn	           : IN	    std_logic;
 	 SDI	           : IN	    std_logic;
 	 SCLK              : IN	    std_logic;
 	 SDO 	           : OUT	std_logic;
	 DATA1             : OUT	std_logic
    );

END REAL_TILE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ARCHITECTURE behave OF REAL_TILE IS
-----------------------------------------------------------------------------
signal DUMMY_DATA : std_logic_vector (7 downto 0);
-------------------------------------------------------------------------------
Component Dummy_TILE_data IS
   Generic ( --Bytes_per_det  : IN     integer range 3 to 5;
			 IDLE_WORD      : IN     std_logic_vector (7 downto 0);
			 START_WORD     : IN     std_logic_vector (39 downto 0);
			 optional_footer: IN     std_logic
);
   PORT(
     Bytes_per_det     : IN     integer range 3 to 5;
     RESET            : IN     std_logic;
	 ACLK              : IN     std_logic;
	 SYNC              : IN     std_logic;
     DISCARD           : IN     std_logic;
     CLKDIV     	   : IN     std_logic;
	 DUMMY_DATA        : OUT    std_logic_vector (7 downto 0);
	 SCSn	           : IN	    std_logic;
	 SDI	           : IN	    std_logic;
	 SCLK              : IN	    std_logic;
	 SDO 	           : OUT	std_logic
   );

END Component ;
------------------------------------------------------

BEGIN

----------------------------------------------------


---------------------------------------------------
Dummy_TILE_data_inst: Dummy_TILE_data
   Generic map  ( --Bytes_per_det   => 4,
			      IDLE_WORD       => x"B5",
			      START_WORD      => START_WORD, -- !debug: 28/06/2022 was  x"a987654321",
			      optional_footer => '1'
)
   PORT map(
     Bytes_per_det     => Bytes_per_det  ,
     RESET            => RESET         ,
	 ACLK              => ACLK           ,
	 SYNC              => SYNC           ,
     DISCARD           => DISCARD        ,
     CLKDIV     	   => CLKDIV     	 ,
	 DUMMY_DATA        => DUMMY_DATA     ,
	 SCSn	           => SCSn	         ,
	 SDI	           => SDI	         ,
	 SCLK              => SCLK           ,
	 SDO 	           => SDO
   );

-- OSERDESE2: Output SERial/DESerializer with bitslip
--            7 Series
-- Xilinx HDL Language Template, version 2021.2

OSERDESE2_inst : OSERDESE2
generic map (
   DATA_RATE_OQ => "SDR",   -- DDR, SDR
   DATA_RATE_TQ => "SDR",   -- DDR, BUF, SDR
   DATA_WIDTH => 8,         -- Parallel data width (2-8,10,14)
   INIT_OQ => '0',          -- Initial value of OQ output (1'b0,1'b1)
   INIT_TQ => '0',          -- Initial value of TQ output (1'b0,1'b1)
   SERDES_MODE => "MASTER", -- MASTER, SLAVE
   SRVAL_OQ => '0',         -- OQ output value when SR is used (1'b0,1'b1)
   SRVAL_TQ => '0',         -- TQ output value when SR is used (1'b0,1'b1)
   TBYTE_CTL => "FALSE",    -- Enable tristate byte operation (FALSE, TRUE)
   TBYTE_SRC => "FALSE",    -- Tristate byte source (FALSE, TRUE)
   TRISTATE_WIDTH => 1      -- 3-state converter width (1,4)
)
port map (
   OFB => open,             -- 1-bit output: Feedback path for data
   OQ => DATA1,               -- 1-bit output: Data path output
   -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
   SHIFTOUT1 => open,
   SHIFTOUT2 => open,
   TBYTEOUT => open,   -- 1-bit output: Byte group tristate
   TFB => open,             -- 1-bit output: 3-state control
   TQ => open,               -- 1-bit output: 3-state control
   CLK => FCLK,             -- 1-bit input: High speed clock
   CLKDIV => CLKDIV,       -- 1-bit input: Divided clock
   -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
   D1 => DUMMY_DATA(0),
   D2 => DUMMY_DATA(1),
   D3 => DUMMY_DATA(2),
   D4 => DUMMY_DATA(3),
   D5 => DUMMY_DATA(4),
   D6 => DUMMY_DATA(5),
   D7 => DUMMY_DATA(6),
   D8 => DUMMY_DATA(7),
   OCE => '1',             -- 1-bit input: Output data clock enable
   RST => RESET,             -- 1-bit input: Reset
   -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
   SHIFTIN1 => '0',
   SHIFTIN2 => '0',
   -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
   T1 => '0',
   T2 => '0',
   T3 => '0',
   T4 => '0',
   TBYTEIN => '0',     -- 1-bit input: Byte group tristate
   TCE => '0'              -- 1-bit input: 3-state clock enable
);

-- End of OSERDESE2_inst instantiation
































































end behave;
