-------------------------------------------------------------------------------
-- Title      : Memory buffer package
-- Project    : DDR2 part of peripheral FPGA (Ovation project)
-------------------------------------------------------------------------------
-- File       : tbuf_pack.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    :
-- Created    : 22/01/2006
-- Last update: 09/06/2024
-- Platform   :
-- Standard   : VHDL'93, Math Packages
-------------------------------------------------------------------------------
-- Description: v. 4D02
-------------------------------------------------------------------------------
-- Copyright (c) 2006
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 22/01/2006  1.0      ilq00431  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ddr3_model_pack.all;

package tbuf_pack is

  constant DDR3_ADDR_WIDTH : positive := C_S_AXI_ADDR_WIDTH;
  subtype DDR3_ADDR_BUS_TYP is unsigned(DDR3_ADDR_WIDTH-1 downto 0);

  -- Address_map for 4 Giga bit chip  &  8 G
  -- 09/06/2024 after increase RT buffer and instead decreas HD buffer
  constant EV_DATA_BASE_ADDR   : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"00000000", DDR3_ADDR_WIDTH);
  constant EV_DATA_END_ADDR    : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"06D7A480", DDR3_ADDR_WIDTH);		-- up to 27,177 Readings, Supporting 3.50 Sec Hold-Off
  constant ADDR_FIFO_BASE_ADDR : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"06D7B500", DDR3_ADDR_WIDTH);		--ptr start address
  constant ADDR_FIFO_END_ADDR  : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"0751C700", DDR3_ADDR_WIDTH);		--ptr end address
  constant RAW_DATA_BASE_ADDR  : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"0751C708", DDR3_ADDR_WIDTH);
  constant FOUR_G_END_ADDR     : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"1FFFEF7C", DDR3_ADDR_WIDTH);
  constant EIGHT_G_END_ADDR    : unsigned(DDR3_ADDR_WIDTH-1 downto 0) := resize(X"3FFFFFFF", DDR3_ADDR_WIDTH);
 
  constant RTL_BUFFER_DEEP    : unsigned(31 downto 0) :=unsigned( std_logic_vector(resize(EV_DATA_END_ADDR,32)))-unsigned( std_logic_vector(resize(EV_DATA_BASE_ADDR,32))); --add by Dalit 20/12/2023
  constant HD_BUFFER_DEEP     : unsigned(31 downto 0) :=unsigned( std_logic_vector(resize(FOUR_G_END_ADDR,32)))-unsigned( std_logic_vector(resize(RAW_DATA_BASE_ADDR,32))); --add by Dalit 20/12/2023
  constant Min_reading_gap     : unsigned(31 downto 0) := x"00000002";
  constant Min_reading_pointer_gap_reg     : unsigned(31 downto 0)  := x"00000005";

  constant EV_NUM_OF_SLOTS : natural := 27177; -- 09/06/2024 was 1024;
  constant EV_READING_SIZE : positive := 4224; -- 13/11/2023 <slice size (DW)> * <num_of_slices> / <merge factor> + <header size>  was 1056
  constant EV_LAST_SLOT_ADDR : positive := to_integer(EV_DATA_END_ADDR) - EV_READING_SIZE;

  constant HEADER_NUM_DWORDS : natural := 32;  -- 21/06/2023 was 4

end package tbuf_pack;


--package body tbuf_pack is
--end package body tbuf_pack;
