-- hds interface_start
-- - ***********************************************************
--  ******************* FIND_ONE_VHDL *************************
--  ***********************************************************
--  Output Y is the bit location from the MSB of I where the
--  first '1' resides.
--
--
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

--LIBRARY UNISIM;

ENTITY FIND_ONE_VHDL IS
   PORT(
      I      : IN     std_logic_vector (15 DOWNTO 0);
      Y      : OUT    std_logic_vector (3 DOWNTO 0);
      FOUND1 : OUT    std_logic
   );

-- Declarations

END FIND_ONE_VHDL ;


-- hds interface_end


architecture FIND_ONE_VHDL of FIND_ONE_VHDL is
signal Z15_12, Z11_8, Z7_4, Z3_0: STD_LOGIC;

-- component NOR4 port (
--   I:  in STD_LOGIC_VECTOR(3 downto 0);
--   O:  out STD_LOGIC );
-- end component;

begin

	-- -- the NOR4 component is used to partion thed logic
	-- -- since the synthesizer partions at component boundaries.
	-- N3:  NOR4 port map (
	--   	I => I(15 downto 12),
	--   	O => Z15_12 );
	-- N2:  NOR4 port map (
	--   	I => I(11 downto 8),
	--   	O => Z11_8 );
	-- N1:  NOR4 port map (
	--   	I => I(7 downto 4),
	--   	O => Z7_4 );
	-- N0:  NOR4 port map (
	--   	I => I(3 downto 0),
	--   	O => Z3_0 );

	-- Z15_12 <= '1' when (I(15 downto 12) = X"0") else '0';
	-- Z11_8 <= '1' when (I(11 downto 8) = X"0") else '0';
	-- Z7_4 <= '1' when (I(7 downto 4) = X"0") else '0';
	-- Z3_0 <= '1' when (I(3 downto 0) = X"0") else '0';

  -- !debug: 07/06/2021
  Z15_12 <= not (I(15) or I(14) or I(13) or I(12));
  Z11_8 <= not (I(11) or I(10) or I(9) or I(8));
  Z7_4 <= not (I(7) or I(6) or I(5) or I(4));
  Z3_0 <= not (I(3) or I(2) or I(1) or I(0));

	FOUND1 <= '1' when (Z15_12='0' or Z11_8='0' or Z7_4='0'
						or Z3_0='0') else '0';

	Y(3) <= '0' when (Z15_12='0' or Z11_8='0') else '1';
	Y(2) <= '0' when (Z15_12='0' or (Z11_8='1' and Z7_4='0') ) else '1';
	Y(1) <= '0' when ( (I(15)='1' or I(14)='1' )
					or (Z15_12='1' and (I(11)='1' or I(10)='1') )
					or (Z15_12='1' and Z11_8='1' and (I(7)='1' or I(6)='1') )
					or (Z15_12='1' and Z11_8='1' and Z7_4='1'
								and (I(3)='1' or I(2)='1') ) )
				else '1';
	Y(0) <= '0' when ( (I(15)='1' or (I(14)='0' and I(13)='1') )
					or (Z15_12='1' and (I(11)='1' or (I(10)='0' and I(9)='1') ) )
					or (Z15_12='1' and Z11_8='1'
								and (I(7)='1' or (I(6)='0' and I(5)='1') ) )
					or (Z15_12='1' and Z11_8='1' and Z7_4='1'
								and (I(3)='1' or (I(2)='0' and I(1)='1') ) ) )
				else '1';
end;
