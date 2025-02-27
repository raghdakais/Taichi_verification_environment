-------------------------------------------------------------------------------
-- Title      : Testbench for design "axi4_master_vhdl_0"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axi4_master_vhdl_0_tb.vhd
-- Author     :   <Shinderman Eugene  <evgene@hbtech.co.il>>
-- Company    : HBtech
-- Created    : 20/11/2019
-- Last update: 26/11/2019
-- Platform   : VHDL-2008
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 HBtech
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 20/11/2019  1.0      310268386	Created
-------------------------------------------------------------------------------
-- - m00_axi_awaddr calculates as C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr, where
--   - C_M_TARGET_SLAVE_BASE_ADDR - IP constant
--   - axi_awaddr - incremented each burst by burst_size_bytes, cleared with init_txn_pulse
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi4_master_vhdl_0_tb is

end entity axi4_master_vhdl_0_tb;


architecture ar of axi4_master_vhdl_0_tb is

  component axi4_master_vhdl_0 is
    port (
      m00_axi_awid         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_awaddr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axi_awlen        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m00_axi_awsize       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_awburst      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m00_axi_awlock       : OUT STD_LOGIC;
      m00_axi_awcache      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_awprot       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_awqos        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_awuser       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_awvalid      : OUT STD_LOGIC;
      m00_axi_awready      : IN  STD_LOGIC; -- !TODO: 20/11/2019 connect
      m00_axi_wdata        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axi_wstrb        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_wlast        : OUT STD_LOGIC;
      m00_axi_wuser        : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_wvalid       : OUT STD_LOGIC;
      m00_axi_wready       : IN  STD_LOGIC;  -- !TODO: 20/11/2019 connect
      m00_axi_bid          : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_bresp        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- !TODO: 20/11/2019 connect
      m00_axi_buser        : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);  -- !TODO: 20/11/2019 connect
      m00_axi_bvalid       : IN  STD_LOGIC;
      m00_axi_bready       : OUT STD_LOGIC;
      m00_axi_arid         : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_araddr       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axi_arlen        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m00_axi_arsize       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_arburst      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m00_axi_arlock       : OUT STD_LOGIC;
      m00_axi_arcache      : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_arprot       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_arqos        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m00_axi_aruser       : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_arvalid      : OUT STD_LOGIC;
      m00_axi_arready      : IN  STD_LOGIC;
      m00_axi_rid          : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_rdata        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      m00_axi_rresp        : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      m00_axi_rlast        : IN  STD_LOGIC;
      m00_axi_ruser        : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      m00_axi_rvalid       : IN  STD_LOGIC;
      m00_axi_rready       : OUT STD_LOGIC;
      m00_axi_aclk         : IN  STD_LOGIC;
      m00_axi_aresetn      : IN  STD_LOGIC;
      m00_axi_init_axi_txn : IN  STD_LOGIC;
      m00_axi_txn_done     : OUT STD_LOGIC;
      m00_axi_error        : OUT STD_LOGIC);
  end component axi4_master_vhdl_0;
  
  -- component ports
  signal m00_axi_awid         : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_awaddr       : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m00_axi_awlen        : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal m00_axi_awsize       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_awburst      : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal m00_axi_awlock       : STD_LOGIC;
  signal m00_axi_awcache      : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal m00_axi_awprot       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_awqos        : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal m00_axi_awuser       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_awvalid      : STD_LOGIC;
  signal m00_axi_awready      : STD_LOGIC;
  signal m00_axi_wdata        : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m00_axi_wstrb        : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal m00_axi_wlast        : STD_LOGIC;
  signal m00_axi_wuser        : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_wvalid       : STD_LOGIC;
  signal m00_axi_wready       : STD_LOGIC;
  signal m00_axi_bid          : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  signal m00_axi_bresp        : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  signal m00_axi_buser        : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  signal m00_axi_bvalid       : STD_LOGIC;
  signal m00_axi_bready       : STD_LOGIC;
  signal m00_axi_arid         : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  signal m00_axi_araddr       : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m00_axi_arlen        : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal m00_axi_arsize       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_arburst      : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal m00_axi_arlock       : STD_LOGIC;
  signal m00_axi_arcache      : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal m00_axi_arprot       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_arqos        : STD_LOGIC_VECTOR(3 DOWNTO 0);
  signal m00_axi_aruser       : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_arvalid      : STD_LOGIC;
  signal m00_axi_arready      : STD_LOGIC;
  signal m00_axi_rid          : STD_LOGIC_VECTOR(2 DOWNTO 0) := "000";
  signal m00_axi_rdata        : STD_LOGIC_VECTOR(31 DOWNTO 0);
  signal m00_axi_rresp        : STD_LOGIC_VECTOR(1 DOWNTO 0);
  signal m00_axi_rlast        : STD_LOGIC;
  signal m00_axi_ruser        : STD_LOGIC_VECTOR(2 DOWNTO 0);
  signal m00_axi_rvalid       : STD_LOGIC;
  signal m00_axi_rready       : STD_LOGIC;
  signal m00_axi_aclk         : STD_LOGIC := '0';
  signal m00_axi_aresetn      : STD_LOGIC;
  signal m00_axi_init_axi_txn : STD_LOGIC;
  signal m00_axi_txn_done     : STD_LOGIC;
  signal m00_axi_error        : STD_LOGIC;

  -- clock
  signal Clk : std_logic := '1';

  signal burst_len_cnt : natural range 0 to 1023;
  
begin  -- architecture ar

  -- component instantiation
  DUT: axi4_master_vhdl_0
    port map (
      m00_axi_awid         => m00_axi_awid,
      m00_axi_awaddr       => m00_axi_awaddr,
      m00_axi_awlen        => m00_axi_awlen,
      m00_axi_awsize       => m00_axi_awsize,
      m00_axi_awburst      => m00_axi_awburst,
      m00_axi_awlock       => m00_axi_awlock,
      m00_axi_awcache      => m00_axi_awcache,
      m00_axi_awprot       => m00_axi_awprot,
      m00_axi_awqos        => m00_axi_awqos,
      m00_axi_awuser       => m00_axi_awuser,
      m00_axi_awvalid      => m00_axi_awvalid,
      m00_axi_awready      => m00_axi_awready,
      m00_axi_wdata        => m00_axi_wdata,
      m00_axi_wstrb        => m00_axi_wstrb,
      m00_axi_wlast        => m00_axi_wlast,
      m00_axi_wuser        => m00_axi_wuser,
      m00_axi_wvalid       => m00_axi_wvalid,
      m00_axi_wready       => m00_axi_wready,
      m00_axi_bid          => m00_axi_bid,
      m00_axi_bresp        => m00_axi_bresp,
      m00_axi_buser        => m00_axi_buser,
      m00_axi_bvalid       => m00_axi_bvalid,
      m00_axi_bready       => m00_axi_bready,
      m00_axi_arid         => m00_axi_arid,
      m00_axi_araddr       => m00_axi_araddr,
      m00_axi_arlen        => m00_axi_arlen,
      m00_axi_arsize       => m00_axi_arsize,
      m00_axi_arburst      => m00_axi_arburst,
      m00_axi_arlock       => m00_axi_arlock,
      m00_axi_arcache      => m00_axi_arcache,
      m00_axi_arprot       => m00_axi_arprot,
      m00_axi_arqos        => m00_axi_arqos,
      m00_axi_aruser       => m00_axi_aruser,
      m00_axi_arvalid      => m00_axi_arvalid,
      m00_axi_arready      => m00_axi_arready,
      m00_axi_rid          => m00_axi_rid,
      m00_axi_rdata        => m00_axi_rdata,
      m00_axi_rresp        => m00_axi_rresp,
      m00_axi_rlast        => m00_axi_rlast,
      m00_axi_ruser        => m00_axi_ruser,
      m00_axi_rvalid       => m00_axi_rvalid,
      m00_axi_rready       => m00_axi_rready,
      m00_axi_aclk         => m00_axi_aclk,
      m00_axi_aresetn      => m00_axi_aresetn,
      m00_axi_init_axi_txn => m00_axi_init_axi_txn,
      m00_axi_txn_done     => m00_axi_txn_done,
      m00_axi_error        => m00_axi_error);

  -- clock generation
  Clk <= not Clk after 10 ns;
  m00_axi_aclk <= not m00_axi_aclk after 10 ns;
    
  m00_axi_aresetn <= '0', '1' after 1 US;

  m00_axi_init_axi_txn <= '0', '1' after 10 US, '0' after 100 US; -- detect pulse when rise
  
  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    
    wait until Clk = '1';
  end process WaveGen_Proc;


  s00_ctl_pr: process (m00_axi_aclk, m00_axi_aresetn) is
  begin  -- process s00_ctl_pr
    if (m00_axi_aresetn = '0') then     -- asynchronous reset (active low)
      m00_axi_awready <= '1';           -- default state of HIGH
      m00_axi_wready <= '0';
      m00_axi_bvalid <= '0';
      burst_len_cnt <= 0;
      m00_axi_arready <= '1';           -- default state of HIGH
      m00_axi_rvalid <= '0';
      m00_axi_rdata <= (others => '0');
      m00_axi_rlast <= '0';
    elsif (m00_axi_aclk'event and m00_axi_aclk = '1') then  -- rising clock edge

      if (m00_axi_awvalid = '1' or m00_axi_arvalid = '1') then
        burst_len_cnt <= to_integer(unsigned(m00_axi_awlen)); -- when counter goes to 0, m00_axi_wlast arrives  - OK
      elsif (burst_len_cnt /= 0) then
        if ((m00_axi_wready = '1' and m00_axi_wvalid = '1') or
            (m00_axi_rready = '1' and m00_axi_rvalid = '1')) then
          burst_len_cnt <= burst_len_cnt - 1;
        end if;
      end if;
      
      -- note: quick controls for testbench as in DS844
      -- !TODO: connect VIP slave or real AXI slave
      m00_axi_awready <= not m00_axi_awvalid;

      if (m00_axi_wvalid = '1') then
        m00_axi_wready <= '1';
      elsif (burst_len_cnt = 0) then    -- !debug: 26/11/2019 or after m00_axi_bvalid ?
        m00_axi_wready <= '0';
      end if;

      if (m00_axi_wready = '1' and  m00_axi_wlast = '1' and  m00_axi_wvalid = '1') then
        m00_axi_bvalid <= '1';
      elsif (m00_axi_bready = '1') then -- BVALID must remain asserted until the rising clock edge after the master asserts BREADY
        m00_axi_bvalid <= '0';
      end if;

      m00_axi_arready <= not m00_axi_arvalid;
      if (m00_axi_arvalid = '1') then
        m00_axi_rvalid <= '1';
        -- m00_axi_rdata <= (0 => '1', others => '0');
        m00_axi_rdata <= std_logic_vector(unsigned(m00_axi_rdata) + 1);
      elsif (burst_len_cnt /= 0) then
        if (m00_axi_rready = '1' and m00_axi_rvalid = '1') then
          m00_axi_rdata <= std_logic_vector(unsigned(m00_axi_rdata) + 1); 
        end if;
      else
        m00_axi_rvalid <= '0';
      end if;

      m00_axi_rlast <= '1' when (m00_axi_rready = '1' and burst_len_cnt = 1) else '0';
      
    end if;
  end process s00_ctl_pr;
  

  m00_axi_ruser <= m00_axi_aruser;
  m00_axi_rresp <= "00";
  
end architecture ar;

