--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
Library UNISIM;
use UNISIM.vcomponents.all;
-------------------------------------------------------------------------------


ENTITY Phoebe_dat_IF IS
    PORT(
        RESET       		    : IN    std_logic;
		TILE_RDY                 : IN    std_logic;
		FCLK	                : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		Bytes_per_det           : IN    integer  range 3 to 5;
		IDLE_word               : IN    std_logic_vector (7 downto 0);
		SYNC                    : IN    std_logic;
		Footer_optional_en      : IN    std_logic;
		det2load_o		        : OUT   std_logic_vector (39 downto 0);
		load_o	                : OUT   std_logic;
		footer_valid_o     		: OUT   std_logic_vector (6 downto 1);
    -- sDataIn_p          : in  std_logic;  -- data channel positive
    -- sDataIn_n          : in  std_logic;  -- data channel negative
        sDataIn_i          : in  std_logic;  -- 28/06/2022 IBUFDS moved to top
		crc_ok             : out   std_logic;        -- add by Dalit 19/9/2023
		crc_error               : OUT   std_logic;		
		std_error               : OUT   std_logic;
        asic_data_good_read     : OUT   std_logic; -- 05/09/2023
		Phoebe_data_locked      : out std_logic
);
END Phoebe_dat_IF;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ARCHITECTURE behave OF Phoebe_dat_IF IS
-----------------------------------------------------------------------------


component Asic_data IS

    PORT(
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
	Phoebe_data_locked	: IN	std_logic;
	Bytes_per_det		: IN	integer	 range 3 to 5;
	IDLE_word			: IN	std_logic_vector (7 downto 0);
	SYNC			: IN	std_logic;
	Footer_optional_en	: IN	std_logic;
	RX_det_sync		: IN	std_logic_vector (7 downto 0);
	RX_det_o		: OUT	std_logic_vector (7 downto 0);
	start_valid		: OUT	std_logic;
	data_valid		: OUT	std_logic;
	-- Footer_valid		: OUT	std_logic;
	Footer_optional_valid	: OUT	std_logic;
	Footer_val		: OUT	std_logic_vector (6 downto 1);
	crc_error		: OUT	std_logic;
    crc_ok                  : OUT   std_logic;    --add by Dalit 19/9/2023  
    std_error               : OUT   std_logic;
    asic_data_good_read     : OUT   std_logic -- 05/09/2023
  );

END component;
component Bytes2Det IS

    PORT(
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		Bytes_per_det           : IN    integer  range 3 to 5;
		RX_det_o       	        : IN    std_logic_vector (7 downto 0);
		Phoebe_data_locked		: IN    std_logic;
		data_valid              : IN    std_logic;
		Footer_valid            : IN    std_logic_vector (6 downto 1);
		footer_valid_o	     	: OUT   std_logic_vector (6 downto 1);
		det2load_o		        : OUT   std_logic_vector (39 downto 0);
		load_o	                : OUT   std_logic
    );
END component;

component InDatPhoebe is
   Generic (
      TapWidth : natural := 5;   -- number of bits for IDELAYE2 tap counter
      ParallelWidth : natural := 8); -- number of parallel bits
   Port (

	  CLKDIV    : in std_logic;   --parallel clock output side and control CLK (CLKDIV)
      FCLK      : in std_logic;    --serial clock input side
      tile_rdy  :  in std_logic;
      --Encoded serial data
      -- sDataIn_p          : in  std_logic;  -- data channel positive
      -- sDataIn_n          : in  std_logic;  -- data channel negative
      sDataIn_i          : in  std_logic;  -- 28/06/2022 IBUFDS moved to top

      --Encoded parallel data (raw)
      pDataIn_O : out STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);

      IDLY_CNT  : out std_logic_vector(TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count
      aRst      : in STD_LOGIC;
	  Phoebe_data_locked : out STD_LOGIC
   );
end component;


signal RX_det_sync           :std_logic_vector (7 downto 0);
signal RX_det_o       	     :std_logic_vector (7 downto 0);
signal data_valid            :std_logic;
-- signal Footer_valid          :std_logic;
signal Footer_optional_valid :std_logic;
signal Phoebe_data_locked_int:std_logic;
signal Footer_val            :std_logic_vector (6 downto 1);
signal start_valid           :std_logic;

signal Phoebe_data_locked_r  : std_logic; -- 13/10/2022

-------------------------------------------------------------------------------

BEGIN

--------------------------------------------------
 ---------------------------------------------------
InDatPhoebe_inst: InDatPhoebe
   Generic map (
      TapWidth => 5,   -- number of bits for IDELAYE2 tap counter
      ParallelWidth => 8)       -- number of parallel bits
   Port map (

	  CLKDIV    => CLKDIV,
      FCLK      => FCLK,
      TILE_RDY   => TILE_RDY,
      --Encoded serial data
      -- sDataIn_p => sDataIn_p,
      -- sDataIn_n => sDataIn_n,
      sDataIn_i => sDataIn_i,
      --Encoded parallel data (raw)
      pDataIn_O  => RX_det_sync,
      IDLY_CNT   => open,
      aRst => RESET,
	  Phoebe_data_locked=>Phoebe_data_locked_int

   );
asic_data_inst: Asic_data

    PORT map (
        RESET       		=> RESET       		  ,
        CLKDIV          	=> CLKDIV                ,
	Phoebe_data_locked	=> Phoebe_data_locked_r, -- !debug: 13/10/2022 was	 Phoebe_data_locked_int,
	Bytes_per_det		=> Bytes_per_det	      ,
	IDLE_word		         =>	IDLE_word	      ,
	SYNC			=> SYNC		      ,
	Footer_optional_en	=> Footer_optional_en	,
	RX_det_sync		=> RX_det_sync	      ,
	RX_det_o		=> RX_det_o	      ,
	start_valid		=> start_valid	      ,
	data_valid		=> data_valid	      ,
	-- Footer_valid		=> open	      ,
	Footer_optional_valid	=> Footer_optional_valid ,
	Footer_val		=> Footer_val	      ,
	crc_error		=> crc_error	      ,
	crc_ok          =>	crc_ok            ,  --add by Dalit 19/9/2023
	std_error		=> std_error,
        asic_data_good_read     => asic_data_good_read -- 05/09/2023

    	);
Bytes2Det_inst: Bytes2Det

    PORT map(
        RESET       		    => RESET,
        CLKDIV          	    => CLKDIV,
		Bytes_per_det           => Bytes_per_det,
		RX_det_o       	        => RX_det_o,
		Phoebe_data_locked		=> Phoebe_data_locked_int,
		data_valid              => data_valid,
		footer_valid            => Footer_val,
		footer_valid_o          => footer_valid_o,
		det2load_o		        => det2load_o,
		load_o	                => load_o
    );
Phoebe_data_locked<=Phoebe_data_locked_int;

misc_pr: process (CLKDIV) is
begin  -- process misc_pr
  if (CLKDIV'event and CLKDIV = '1') then  -- rising clock edge
    Phoebe_data_locked_r <= Phoebe_data_locked_int; -- 13/10/2022 delayed
  end if;
end process misc_pr;

end behave;
