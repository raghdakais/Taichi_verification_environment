-------------------------------------------------------------------------------
-- Title      : TX_ENGINE_tb
-- Project    : Acq4eG2
-------------------------------------------------------------------------------
-- File       : TX_ENGINE_tb.vhd
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
entity TX_ENGINE_tb is
end TX_ENGINE_tb;

-------------------------------------------------------------------------------
-- architecture section
-------------------------------------------------------------------------------
architecture rtl of TX_ENGINE_tb is

  signal i_clk_250m : std_logic := '0';

  type  fsm_type is (IDLE_STATE,FCC_STATE, HDER_STATE, DATA_STATE, FAKE_STATE, WAIT_STATE,SPLIT_REQ_STATE,SPLIT_REQ_DLY_STATE,ABC_STATE,DONE_STATE);
  signal curr_state               : fsm_type;
  signal pcie_txn_start_latch     : std_logic;
  signal pcie_txn_fifo_empty      : std_logic;
  signal pcie_cpl_txn_req_latch	  : std_logic;
  signal pcie_cpld_txn_req_latch  : std_logic;
 
  -- 29/04/2025 only for debug
  signal rate_1us_cnt : natural range 0 to 127 := 0;
  signal pcie_tx_rate_cnt : natural range 0 to 2**23 := 0;
  signal rate_1us_inc, pcie_tx_start : boolean := FALSE;
  signal pcie_tx_rate_reg : std_logic_vector(23 downto 0) := (others => '0');
    
begin

  i_clk_250m <= not i_clk_250m after 4 NS; -- @125MHz
  
  -- testbench

  tb_pr: process is
  begin  -- process tb_pr

    curr_state <= IDLE_STATE;
    pcie_txn_start_latch <= '0';
    pcie_txn_fifo_empty <= '0';
    pcie_cpl_txn_req_latch <= '0';
    pcie_cpld_txn_req_latch <= '0';
    pcie_txn_fifo_empty <= '0';

    wait for 10 MS;                     -- #1

    pcie_txn_start_latch <= '1';
    pcie_txn_fifo_empty <= '1';

    wait for 1 US;
    curr_state <= HDER_STATE;

    pcie_txn_start_latch <= '0';
    pcie_txn_fifo_empty <= '0';
    
    wait for 10 MS;                     -- #2

    curr_state <= IDLE_STATE;
    wait for 1 US;
    
    pcie_txn_start_latch <= '1';
    pcie_txn_fifo_empty <= '1';

    wait for 1 US;
    curr_state <= HDER_STATE;

    pcie_txn_start_latch <= '0';
    pcie_txn_fifo_empty <= '0';
    
    wait for 20 MS;                     -- #3

    curr_state <= IDLE_STATE;
    wait for 1 US;

    pcie_txn_start_latch <= '1';
    pcie_txn_fifo_empty <= '1';

    wait for 1 US;
    curr_state <= HDER_STATE;

    pcie_txn_start_latch <= '0';
    pcie_txn_fifo_empty <= '0';
    
    wait for 50 MS;                     -- #4

    curr_state <= IDLE_STATE;
    wait for 1 US;

    pcie_txn_start_latch <= '1';
    pcie_txn_fifo_empty <= '1';

    wait for 1 US;
    curr_state <= HDER_STATE;

    pcie_txn_start_latch <= '0';
    pcie_txn_fifo_empty <= '0';
    
    wait;
    
  end process tb_pr;

    
-- 29/04/2025 only for debug
test_pr: process (i_clk_250m) is
begin  -- process test_pr
  if (i_clk_250m'event and i_clk_250m = '1') then  -- rising clock edge

    if (rate_1us_cnt < 124) then
      rate_1us_cnt <= rate_1us_cnt + 1;
      rate_1us_inc <= FALSE;
    else
      rate_1us_cnt <= 0;
      rate_1us_inc <= TRUE;
    end if;

    if (curr_state = IDLE_STATE) then
      if ((pcie_txn_start_latch = '1' and pcie_txn_fifo_empty = '1') or
          ((pcie_cpl_txn_req_latch = '1' or pcie_cpld_txn_req_latch = '1') and pcie_txn_fifo_empty = '1')) then
        pcie_tx_start <= TRUE;
      end if;
    elsif (rate_1us_inc) then
      pcie_tx_start <= FALSE;
    end if;
                     
    if (rate_1us_inc) then
      if (pcie_tx_start) then                  -- FSM start send new packet to PCIe
        pcie_tx_rate_cnt <= 0;
        pcie_tx_rate_reg <= conv_std_logic_vector(pcie_tx_rate_cnt,pcie_tx_rate_reg'length);
      elsif (pcie_tx_rate_cnt < 2**23-1) then
        pcie_tx_rate_cnt <= pcie_tx_rate_cnt + 1; -- PCIe FSM rate cnt
      end if;
    end if;
    
  end if;
end process test_pr;


end rtl;
