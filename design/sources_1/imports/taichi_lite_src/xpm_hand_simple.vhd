-------------------------------------------------------------------------------
-- Title      : generic handshake
-- Project    :
-------------------------------------------------------------------------------
-- File       : xpm_hand_simple.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    : Philips Medical
-- Created    : 16/01/2024
-- Last update: 30/05/2024
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
Library xpm;
use xpm.vcomponents.all;

entity xpm_hand_simple is
  generic (
    SLOW2FAST      : boolean := TRUE;
    WIDTH          : integer := 2
  );
  port (
    rst_n                  : in  std_logic;
    slow_clk               : in  std_logic;
    fast_clk               : in  std_logic;
    src_in                 : in  std_logic_vector(WIDTH-1 downto 0);
    dest_out               : out std_logic_vector(WIDTH-1 downto 0)
);
end entity xpm_hand_simple;


architecture ar of xpm_hand_simple is

  signal src_in_r          : std_logic_vector(WIDTH-1 downto 0);
  signal src_send, src_rcv : std_logic;


begin  -- architecture ar


  gen_1: if (SLOW2FAST) generate

    -- slow to fast clock
    sync_slow2fast_pr : process (rst_n, slow_clk) is
    begin  -- process sync_slow2fast_pr
      if rst_n = '0' then
        src_in_r <= (others => '1');    -- init max value
        src_send <= '0';
      elsif slow_clk'EVENT and slow_clk = '1' then

        if (src_send = '0' and src_rcv = '0') then -- !debug: 17/01/2024 handshake complete, latch next
          src_in_r <= src_in;
        elsif (src_send = '1' and src_rcv = '1') then  -- latch next
          src_in_r <= src_in;
        end if;

        if (src_in_r = src_in) then
          if (src_rcv = '1') then                      -- Acknowledgement from destination logic that src_in has been received
            src_send <= '0';                           -- end handshake
          else
            null;                                      -- keep previous
          end if;
        else                                           -- data changed
          src_send <= '1';                             -- start handshake, expected src_rcv = '0'
        end if;

      end if;
    end process sync_slow2fast_pr;

  else generate

    -- fast to slow clock
    sync_fast2slow_pr : process (rst_n, fast_clk) is
    begin  -- process sync_fast2slow_pr
      if rst_n = '0' then
        src_in_r <= (others => '1');    -- init max value
        src_send <= '0';
      elsif fast_clk'EVENT and fast_clk = '1' then

        if (src_send = '0' and src_rcv = '0') then -- !debug: 17/01/2024 handshake complete, latch next
          src_in_r <= src_in;
        elsif (src_send = '1' and src_rcv = '1') then  -- latch next
          src_in_r <= src_in;
        end if;

        if (src_in_r = src_in) then
          if (src_rcv = '1') then                      -- Acknowledgement from destination logic that src_in has been received
            src_send <= '0';                           -- end handshake
          else
            null;                                      -- keep previous
          end if;
        else                                           -- data changed
          src_send <= '1';                             -- start handshake, expected src_rcv = '0'
        end if;

      end if;
    end process sync_fast2slow_pr;


  end generate gen_1;


  gen_2 : if (SLOW2FAST) generate

    -- slow to fast clock
    xpm_cdc_handshake_1 : xpm_cdc_handshake
      generic map (
        DEST_EXT_HSK   => 0,                    -- DECIMAL; 0=internal handshake, 1=external handshake
        DEST_SYNC_FF   => 2,                    -- DECIMAL; range: 2-10
        INIT_SYNC_FF   => 0,                    -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        SIM_ASSERT_CHK => 0,                    -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        SRC_SYNC_FF    => 2,                    -- DECIMAL; range: 2-10
        WIDTH          => WIDTH                 -- DECIMAL; range: 1-1024
        )
      port map (
        dest_out => dest_out,
        dest_req => open,
        src_rcv  => src_rcv, -- 1-bit output: Acknowledgement from destination
        dest_ack => '0',
        dest_clk => fast_clk,
        src_clk  => slow_clk,
        src_in   => src_in,
        src_send => src_send -- 1-bit input: Assertion of this signal allows the src_in bus to be synchronized
                             -- to the destination clock domain
        );

  else generate

    -- fast to slow clock
    xpm_cdc_handshake_1 : xpm_cdc_handshake
      generic map (
        DEST_EXT_HSK   => 0,               -- DECIMAL; 0=internal handshake, 1=external handshake
        DEST_SYNC_FF   => 2,               -- DECIMAL; range: 2-10
        INIT_SYNC_FF   => 0,               -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        SIM_ASSERT_CHK => 0,               -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        SRC_SYNC_FF    => 2,               -- DECIMAL; range: 2-10
        WIDTH          => WIDTH            -- DECIMAL; range: 1-1024
        )
      port map (
        dest_out => dest_out,
        dest_req => open,
        src_rcv  => src_rcv,
        dest_ack => '0',
        dest_clk => slow_clk,
        src_clk  => fast_clk,
        src_in   => src_in,
        src_send => src_send
        );

  end generate gen_2;


end architecture ar;
