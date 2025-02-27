-- hds interface_start
--  ***********************************************************
--  ******************* BARREL_SHIFT_32 ***********************
--  ***********************************************************
--  BARREL_SHIFT_LL uses tri-state buffers to reduce the amount
--  of logic required.  A 4020XL device has 28 CLBs in a row.
--  The shifter requires 1 of 32 signals to be muxed into each
--  of the output OVEC signals.  Therefore, the muxing function
--  is partitioned into 2 sets of eleven 16 to 1 muxes that use
--  tri-states.  This requires 16 CLB in the same row for each
--  bit, which is possible with a 4020XL.  The outputs of the 
--  first 2 sets of muxes are logically muxed using 2 to 1 muxes
--  to acheive the output.
-- 
-- 
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


ENTITY BARREL_SHIFT_32T IS
   PORT( 
      IVEC  : IN     STD_LOGIC_VECTOR (37 DOWNTO 0);
      SHIFT : IN     STD_LOGIC_VECTOR (4 DOWNTO 0);
      CLK   : IN     STD_LOGIC;
      RST   : IN     STD_LOGIC;
      OVEC  : OUT    STD_LOGIC_VECTOR (11 DOWNTO 0)
   );

-- Declarations

END BARREL_SHIFT_32T ;


-- hds interface_end


architecture BS32T_ARCH of BARREL_SHIFT_32T is

signal SEL: STD_LOGIC_VECTOR (15 downto 0);
signal MUXA, MUXB: STD_LOGIC_VECTOR (11 downto 0);

begin


	process (SHIFT)
	begin
		case SHIFT(3 downto 0) is
			when "0000" => 	SEL <= "0000000000000001";
			when "0001" => 	SEL <= "0000000000000010";
			when "0010" => 	SEL <= "0000000000000100";
			when "0011" => 	SEL <= "0000000000001000";
			when "0100" => 	SEL <= "0000000000010000";
			when "0101" => 	SEL <= "0000000000100000";
			when "0110" => 	SEL <= "0000000001000000";
			when "0111" => 	SEL <= "0000000010000000";
			when "1000" => 	SEL <= "0000000100000000";
			when "1001" => 	SEL <= "0000001000000000";
			when "1010" => 	SEL <= "0000010000000000";
			when "1011" => 	SEL <= "0000100000000000";
			when "1100" => 	SEL <= "0001000000000000";
			when "1101" => 	SEL <= "0010000000000000";
			when "1110" => 	SEL <= "0100000000000000";
			when others => 	SEL <= "1000000000000000";
		end case;
	end process;

	MUXA <= IVEC(36 downto 25) when SEL(0) ='1' else (others => 'Z');
	MUXA <= IVEC(35 downto 24) when SEL(1) ='1' else (others => 'Z');
	MUXA <= IVEC(34 downto 23) when SEL(2) ='1' else (others => 'Z');
	MUXA <= IVEC(33 downto 22) when SEL(3) ='1' else (others => 'Z');
	MUXA <= IVEC(32 downto 21) when SEL(4) ='1' else (others => 'Z');
	MUXA <= IVEC(31 downto 20) when SEL(5) ='1' else (others => 'Z');
	MUXA <= IVEC(30 downto 19) when SEL(6) ='1' else (others => 'Z');
	MUXA <= IVEC(29 downto 18) when SEL(7) ='1' else (others => 'Z');
	MUXA <= IVEC(28 downto 17) when SEL(8) ='1' else (others => 'Z');
	MUXA <= IVEC(27 downto 16) when SEL(9) ='1' else (others => 'Z');
	MUXA <= IVEC(26 downto 15) when SEL(10)='1' else (others => 'Z');
	MUXA <= IVEC(25 downto 14) when SEL(11)='1' else (others => 'Z');
	MUXA <= IVEC(24 downto 13) when SEL(12)='1' else (others => 'Z');
	MUXA <= IVEC(23 downto 12) when SEL(13)='1' else (others => 'Z');
	MUXA <= IVEC(22 downto 11) when SEL(14)='1' else (others => 'Z');
	MUXA <= IVEC(21 downto 10) when SEL(15)='1' else (others => 'Z');

	MUXB <= IVEC(20 downto  9) when SEL(0) ='1' else (others => 'Z');
	MUXB <= IVEC(19 downto  8) when SEL(1) ='1' else (others => 'Z');
	MUXB <= IVEC(18 downto  7) when SEL(2) ='1' else (others => 'Z');
	MUXB <= IVEC(17 downto  6) when SEL(3) ='1' else (others => 'Z');
	MUXB <= IVEC(16 downto  5) when SEL(4) ='1' else (others => 'Z');
	MUXB <= IVEC(15 downto  4) when SEL(5) ='1' else (others => 'Z');
	MUXB <= IVEC(14 downto  3) when SEL(6) ='1' else (others => 'Z');
	MUXB <= IVEC(13 downto  2) when SEL(7) ='1' else (others => 'Z');
	MUXB <= IVEC(12 downto  1) when SEL(8) ='1' else (others => 'Z');
	MUXB <= IVEC(11 downto  0) when SEL(9) ='1' else (others => 'Z');
	MUXB <= (IVEC(10 downto 0) & '0')      when SEL(10) ='1' else (others => 'Z');
	MUXB <= (IVEC(9 downto  0) & "00")     when SEL(11) ='1' else (others => 'Z');
	MUXB <= (IVEC(8 downto  0) & "000")    when SEL(12) ='1' else (others => 'Z');
	MUXB <= (IVEC(7 downto  0) & "0000")   when SEL(13) ='1' else (others => 'Z');
	MUXB <= (IVEC(6 downto  0) & "00000")  when SEL(14) ='1' else (others => 'Z');
	MUXB <= (IVEC(5 downto  0) & "000000") when SEL(15) ='1' else (others => 'Z');

	REG_OUT: process (CLK, RST)
	begin
		if (RST='1') then
			OVEC <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (SHIFT(4)='0') then
				OVEC <= MUXA;
			else
				OVEC <= MUXB;
			end if;
		end if;
	end process REG_OUT;

end;

--------------------------------------------


