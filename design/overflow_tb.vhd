library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.STD_LOGIC_ARITH.all;

library work;

entity overflow_tb is
  
end entity overflow_tb;


architecture ar of overflow_tb is

  signal clk, rst_n : std_logic := '0';

  constant MINIMUM_POINTER_SEPERATION : std_logic_vector := X"000AA100";
  signal s_dque_overflow : std_logic;
  signal sv_current_length      : std_logic_vector(31 downto 0) := X"07f65f80";
  signal sv_next_buffer         : std_logic_vector(3 downto 0) := X"5";
  signal sv_current_buffer      : std_logic_vector(3 downto 0) := X"4";
  signal sv_dque_putptr : std_logic_vector(31 downto 0) := X"052b4c80";
  signal sv_dque_getptr    : std_logic_vector(31 downto 0) := X"45309d00";
  
begin  -- architecture ar

  clk <= not clk after 10 ns;
  rst_n <= '0', '1' after 1 US;
  
  test1_pr: process (clk) is
  begin  -- process test1_pr
    if (clk'event and clk = '1') then   -- rising clock edge
      if (rst_n = '0') then             -- synchronous reset (active low)
        s_dque_overflow                <= '0';
        
      else

              -- Pointers equal?

              if (sv_current_buffer & sv_dque_putptr(27 downto 0)) = (sv_dque_getptr) then
                s_dque_overflow <= '1';

                -- Put-pointer less than Get-Pointer?  If so, are they too close?
              elsif (sv_current_buffer & sv_dque_putptr(27 downto 0)) < (sv_dque_getptr) then
                -- Put and Get both in same buffer
                if (sv_current_buffer & sv_dque_putptr(27 downto 0)) + (MINIMUM_POINTER_SEPERATION) > (sv_dque_getptr) then
                  s_dque_overflow   <= '1';
                  -- Put Pointer ready for jump and Get Pointer in next buffer
                elsif (sv_dque_putptr(27 downto 0) = sv_current_length(27 downto 0)) then
                  if (sv_next_buffer = sv_dque_getptr(31 downto 28)) and (X"0" & sv_dque_getptr(27 downto 0) < (MINIMUM_POINTER_SEPERATION)) then
                    s_dque_overflow <= '1';
                  end if;
                  -- Put Pointer ready for jump and Get Pointer in next buffer
                elsif (sv_dque_putptr(27 downto 0) > sv_current_length(27 downto 0)) then
                  if (sv_next_buffer = sv_dque_getptr(31 downto 28)) and (X"0" & sv_dque_getptr(27 downto 0) < (MINIMUM_POINTER_SEPERATION)) then
                    s_dque_overflow <= '1';
                  end if;
                end if;

                -- Else Put-Pointer is greater than Get-Pointer. Put-Pointer at end?  If so, need
                -- additional space after wrap.
                -- H/W Buffers 0 thru 3 = Stream0, S/W Buffers 0 thru 3
                -- H/W Buffers 4 thru 7 = Stream1, S/W Buffers 0 thru 3                  
              elsif ((sv_next_buffer(1 downto 0) = "00") and (sv_dque_putptr = sv_current_length)) then
                if ("00" & sv_dque_getptr(29 downto 0)) < ( MINIMUM_POINTER_SEPERATION ) then
                  s_dque_overflow <= '1';
                end if;

                -- Else Put-Pointer is greater than Get-Pointer. Put-Pointer near end?  If so,need
                -- additional space after wrap.
                -- Only compare lower two bits of sv_next_buffer since H/W Buffers 0 thru 3 = Stream0, S/W Buffers 0 thru 3
                -- H/W Buffers 4 thru 7 = Stream1, S/W Buffers 0 thru 3
              elsif (sv_next_buffer(1 downto 0) = "00") and ( sv_dque_putptr + MINIMUM_POINTER_SEPERATION ) > (sv_current_length) then
                if ("00" & sv_dque_getptr(29 downto 0)) < ( MINIMUM_POINTER_SEPERATION ) then
                  s_dque_overflow <= '1';
                end if;
              end if;
        
      end if;
    end if;
  end process test1_pr;

end architecture ar;
