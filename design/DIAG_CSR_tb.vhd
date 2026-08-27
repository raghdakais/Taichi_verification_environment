-------------------------------------------------------------------------------
-- Title      : Diag_csr_tb
-- Project    : Acq4eG2
-------------------------------------------------------------------------------
-- File       : DIAG_CSR_tb.vhd
-- Author     : Saida Reddy Annapureddy
-- Company    : Philips
-- Created    : 2013-05-16
-- Last update: 06/05/2025
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Copyright (c) 2012 : Philips
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;

-------------------------------------------------------------------------------
-- entity section
-------------------------------------------------------------------------------
entity DIAG_CSR_tb is
end DIAG_CSR_tb;

-------------------------------------------------------------------------------
-- architecture section
-------------------------------------------------------------------------------
architecture rtl of DIAG_CSR_tb is

  signal ip_clk          : std_logic := '0';
  signal rate_1us_cnt : natural range 0 to 127 := 0;
  signal odl_fifo_near_full_time_cnt : natural range 0 to 2**23 := 0;
  signal rate_1us_inc : boolean := FALSE;
  signal odl_fifo_near_full_time_reg : std_logic_vector(23 downto 0) := (others => '0');

  signal under_threshold, clear_sv : boolean;
  
begin

  ip_clk <= not ip_clk after 4 NS; -- @125MHz
  under_threshold <= TRUE, FALSE after 5 MS, TRUE after 9.76 MS; -- 0.5mS -> odl_fifo_near_full_time_reg = 0x1F4, 4.76mS -> 0x1298
  clear_sv <= TRUE, FALSE after 100 NS;
  
  -- testbench

-- 05/05/2025 only for debug
test_pr: process (ip_clk) is
begin  -- process test_pr
  if (ip_clk'event and ip_clk = '1') then  -- rising clock edge

    if (rate_1us_cnt < 124) then
      rate_1us_cnt <= rate_1us_cnt + 1;
      rate_1us_inc <= FALSE;
    else
      rate_1us_cnt <= 0;
      rate_1us_inc <= TRUE;
    end if;
                    
    if (rate_1us_inc) then
      -- if (odl_out_fifo_rd_count(11 downto 0) < sv_misc0_reg(11 downto 0)) then -- ODL FIFO used  < threshold
      if (under_threshold) then -- ODL FIFO used under threshold
        odl_fifo_near_full_time_cnt <= 0;
      elsif (odl_fifo_near_full_time_cnt < 2**23-1) then
        odl_fifo_near_full_time_cnt <= odl_fifo_near_full_time_cnt + 1; -- PCIe FSM rate cnt
      end if;
    end if;

    -- if (sv_misc0_reg(31) = '1') then    -- clear sampled value
    if (clear_sv) then    -- clear sampled value
      odl_fifo_near_full_time_reg <= (others => '0');
    -- elsif (odl_out_fifo_rd_count(11 downto 0) < sv_misc0_reg(11 downto 0)) then -- ODL FIFO used under threshold
    elsif (under_threshold) then -- ODL FIFO used under threshold
      if (odl_fifo_near_full_time_reg < conv_std_logic_vector(odl_fifo_near_full_time_cnt,odl_fifo_near_full_time_reg'length)) then
        odl_fifo_near_full_time_reg <= conv_std_logic_vector(odl_fifo_near_full_time_cnt,odl_fifo_near_full_time_reg'length); -- max value
      end if;
    end if;
    
  end if;
end process test_pr;


end rtl;
