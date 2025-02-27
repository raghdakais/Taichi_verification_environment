-- hds interface_start
--  ***********************************************************
--  ******************* BARREL_SHIFT_16 ***********************
--  ***********************************************************
--  BARREL_SHIFT_LL uses tri-state buffers to reduce the amount
--  of logic required.  A 4020XL device has 28 CLBs in a row.
--  The shifter requires 1 of 16 signals to be muxed into each
--  of the output OVEC signals.  Therefore, the muxing function
--  can be performed with one level of muxing.  This requires 
--  16 CLB in the same row for each bit, which is possible with 
--  a 4020XL.  
-- 
-- 
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;


ENTITY BARREL_SHIFT_16 IS
   PORT( 
      IVEC  : IN     STD_LOGIC_VECTOR (15 DOWNTO 0);
      SHIFT : IN     STD_LOGIC_VECTOR (3 DOWNTO 0);
      CLK   : IN     STD_LOGIC;
      RST   : IN     STD_LOGIC;
      OVEC  : OUT    STD_LOGIC_VECTOR (11 DOWNTO 0)
   );

-- Declarations

END BARREL_SHIFT_16 ;


-- hds interface_end


architecture BS16_ARCH of BARREL_SHIFT_16 is

signal SEL: STD_LOGIC_VECTOR (15 downto 0);
signal MUX: STD_LOGIC_VECTOR (11 downto 0);

begin

	process (SHIFT)
	begin
		case SHIFT is
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

	MUX <= IVEC(14 downto  3)                  when SEL( 0) ='1' else (others => 'Z');
	MUX <= IVEC(13 downto  2)                  when SEL( 1) ='1' else (others => 'Z');
	MUX <= IVEC(12 downto  1)                  when SEL( 2) ='1' else (others => 'Z');
	MUX <= IVEC(11 downto  0)                  when SEL( 3) ='1' else (others => 'Z');
	MUX <= (IVEC(10 downto  0) & '0')          when SEL( 4) ='1' else (others => 'Z');
	MUX <= (IVEC( 9 downto  0) & "00")         when SEL( 5) ='1' else (others => 'Z');
	MUX <= (IVEC( 8 downto  0) & "000")        when SEL( 6) ='1' else (others => 'Z');
	MUX <= (IVEC( 7 downto  0) & "0000")       when SEL( 7) ='1' else (others => 'Z');
	MUX <= (IVEC( 6 downto  0) & "00000")      when SEL( 8) ='1' else (others => 'Z');
	MUX <= (IVEC( 5 downto  0) & "000000")     when SEL( 9) ='1' else (others => 'Z');
	MUX <= (IVEC( 4 downto  0) & "0000000")    when SEL(10) ='1' else (others => 'Z');
	MUX <= (IVEC( 3 downto  0) & "00000000")   when SEL(11) ='1' else (others => 'Z');
	MUX <= (IVEC( 2 downto  0) & "000000000")  when SEL(12) ='1' else (others => 'Z');
	MUX <= (IVEC( 1 downto  0) & "0000000000") when SEL(13) ='1' else (others => 'Z');
	MUX <= (IVEC(0) &           "00000000000") when SEL(14) ='1' else (others => 'Z');
	MUX	<= (others => '0')                     when SEL(15) ='1' else (others => 'Z');

	REG_OUT: process (CLK, RST)
	begin
		if (RST='1') then
			OVEC <= (others => '0');
		elsif (CLK'event and CLK='1') then
			OVEC <= MUX;
		end if;
	end process REG_OUT;

end;


