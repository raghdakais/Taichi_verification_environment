library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity date_in_bcd is
    port (
        bin:    in  std_logic_vector (31 downto 0);
        bcd:    out std_logic_vector (31 downto 0)
    );
end entity;

architecture ar of date_in_bcd is

  component bin2bcd is
    port (
      bin : in  std_logic_vector (7 downto 0);
      bcd : out std_logic_vector (11 downto 0)
    );
  end component bin2bcd;

  signal dd_bcd, mm_bcd, yy_bcd : std_logic_vector (11 downto 0);
    
begin


    bin2bcd_dd: bin2bcd
    port map (
      bin => bin(23 downto 16),
      bcd => dd_bcd
      );
  
  bin2bcd_mm: bin2bcd
    port map (
      bin => bin(15 downto 8),
      bcd => mm_bcd
      );
  
  bin2bcd_yy: bin2bcd
    port map (
      bin => bin(7 downto 0),
      bcd => yy_bcd
      );

    bcd <= X"00" & dd_bcd(7 downto 0) & mm_bcd(7 downto 0) & yy_bcd(7 downto 0);

end architecture;
