--------------------------------------------------------------------------------
-- Copyright (C) 1999-2008 Easics NV.
-- This source file may be used and distributed without restriction
-- provided that this copyright statement is not removed from the file
-- and that any derivative work contains the original copyright notice
-- and the associated disclaimer.
--
-- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
--
-- Purpose : synthesizable CRC function
--   * polynomial: x^16 + x^15 + x^2 + 1
--   * data width: 8
--
-- Info : tools@easics.be
--        http://www.easics.com
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package Phoebe is
  -- polynomial: x^16 + x^15 + x^2 + 1
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function nextCRC16_D8
    (Data: std_logic_vector(7 downto 0);
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector;
  -- polynomial: x^16 + x^15 + x^2 + 1
  -- data width: 26
  -- convention: the first serial bit is D[25]
  function nextCRC16_D26
    (Data: std_logic_vector(25 downto 0);
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector;
------------------------------------------------------	
  function nextCRC1_D1
    (Data: std_logic;
     crc:  std_logic)
    return std_logic;
	
constant IDLE_WORD              : std_logic_vector (7 downto 0) :=x"B5";	
constant START_WORD             : std_logic_vector (39 downto 0) :=x"5544332211";
constant NumOfTiles             : integer range 2 to 16 :=4;	-- !debug: 30/03/2021 was  8
-- constant enable_next_tile_delay : std_logic_vector (15 downto 0):=x"00FF";	 -- it is the number of cnt from deasserting reset to each tiles
-- constant Settle_time            : std_logic_vector(15 downto 0):= x"00ff";
constant enable_next_tile_delay : std_logic_vector (15 downto 0):=x"007F";	 -- it is the number of cnt from deasserting reset to each tiles
constant Settle_time            : std_logic_vector(15 downto 0):= x"007f";
-- CONSTANT C_CLK_MAX              : NATURAL RANGE 0 TO 127 := 96;  --ACLK frequency is clk/C_CLK_MAX
-- CONSTANT C_CLK_MAX_SPI          : NATURAL RANGE 0 TO 15 := 8;     --SCLK frequency is clk/C_CLK_MAX_SPI
CONSTANT C_CLK_MAX              : NATURAL RANGE 0 TO 127 := 48;  --ACLK frequency is clk/C_CLK_MAX
CONSTANT C_CLK_MAX_SPI          : NATURAL RANGE 0 TO 15 := 4;     --SCLK frequency is clk/C_CLK_MAX_SPI
end Phoebe;


package body Phoebe is

  -- polynomial: x^16 + x^15 + x^2 + 1
  -- data width: 8
  -- convention: the first serial bit is D[0]
  function nextCRC16_D8
    (Data: std_logic_vector(7 downto 0);
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector is

    variable d:      std_logic_vector(7 downto 0);
    variable c:      std_logic_vector(15 downto 0);
    variable newcrc: std_logic_vector(15 downto 0);

  begin
    d := Data;
    c := crc;
	
    newcrc(0) := (c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15) xor d(0) xor d(1) xor d(2) xor d(3) xor d(4) xor d(5) xor d(6) xor d(7));
	newcrc(1) := (c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15) xor d(1) xor d(2) xor d(3) xor d(4) xor d(5) xor d(6) xor d(7));
	newcrc(2) := (c(8) xor c(9) xor d(0) xor d(1));
	newcrc(3) := (c(9) xor c(10) xor d(1) xor d(2));
	newcrc(4) := (c(10) xor c(11) xor d(2) xor d(3));
	newcrc(5) := (c(11) xor c(12) xor d(3) xor d(4));
	newcrc(6) := (c(12) xor c(13) xor d(4) xor d(5));
	newcrc(7) := (c(13) xor c(14) xor d(5) xor d(6));
	newcrc(8) := (c(0) xor c(14) xor c(15) xor d(6) xor d(7));
	newcrc(9) := (c(1) xor c(15) xor d(7));
    newcrc(10) := c(2);
	newcrc(11) := c(3);
	newcrc(12) := c(4);
	newcrc(13) := c(5);
	newcrc(14) := c(6);
	newcrc(15) := (c(7) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15) xor d(0) xor d(1) xor d(2) xor d(3) xor d(4) xor d(5) xor d(6) xor d(7));



    return newcrc;
  end nextCRC16_D8;

  -- polynomial: x^16 + x^15 + x^2 + 1
  -- data width: 26
  -- convention: the first serial bit is D[25]
  function nextCRC16_D26
    (Data: std_logic_vector(25 downto 0);
     crc:  std_logic_vector(15 downto 0))
    return std_logic_vector is

    variable d:      std_logic_vector(25 downto 0);
    variable c:      std_logic_vector(15 downto 0);
    variable newcrc: std_logic_vector(15 downto 0);

  begin
    d := Data;
    c := crc;

    newcrc(0) := d(25) xor d(24) xor d(23) xor d(22) xor d(21) xor d(20) xor d(19) xor d(18) xor d(17) xor d(16) xor d(15) xor d(13) xor d(12) xor d(11) xor d(10) xor d(9) xor d(8) xor d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(0) xor c(1) xor c(2) xor c(3) xor c(5) xor c(6) xor c(7) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
    newcrc(1) := d(25) xor d(24) xor d(23) xor d(22) xor d(21) xor d(20) xor d(19) xor d(18) xor d(17) xor d(16) xor d(14) xor d(13) xor d(12) xor d(11) xor d(10) xor d(9) xor d(8) xor d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor c(0) xor c(1) xor c(2) xor c(3) xor c(4) xor c(6) xor c(7) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
    newcrc(2) := d(16) xor d(14) xor d(1) xor d(0) xor c(4) xor c(6);
    newcrc(3) := d(17) xor d(15) xor d(2) xor d(1) xor c(5) xor c(7);
    newcrc(4) := d(18) xor d(16) xor d(3) xor d(2) xor c(6) xor c(8);
    newcrc(5) := d(19) xor d(17) xor d(4) xor d(3) xor c(7) xor c(9);
    newcrc(6) := d(20) xor d(18) xor d(5) xor d(4) xor c(8) xor c(10);
    newcrc(7) := d(21) xor d(19) xor d(6) xor d(5) xor c(9) xor c(11);
    newcrc(8) := d(22) xor d(20) xor d(7) xor d(6) xor c(10) xor c(12);
    newcrc(9) := d(23) xor d(21) xor d(8) xor d(7) xor c(11) xor c(13);
    newcrc(10) := d(24) xor d(22) xor d(9) xor d(8) xor c(12) xor c(14);
    newcrc(11) := d(25) xor d(23) xor d(10) xor d(9) xor c(0) xor c(13) xor c(15);
    newcrc(12) := d(24) xor d(11) xor d(10) xor c(0) xor c(1) xor c(14);
    newcrc(13) := d(25) xor d(12) xor d(11) xor c(1) xor c(2) xor c(15);
    newcrc(14) := d(13) xor d(12) xor c(2) xor c(3);
    newcrc(15) := d(25) xor d(24) xor d(23) xor d(22) xor d(21) xor d(20) xor d(19) xor d(18) xor d(17) xor d(16) xor d(15) xor d(14) xor d(12) xor d(11) xor d(10) xor d(9) xor d(8) xor d(7) xor d(6) xor d(5) xor d(4) xor d(3) xor d(2) xor d(1) xor d(0) xor c(0) xor c(1) xor c(2) xor c(4) xor c(5) xor c(6) xor c(7) xor c(8) xor c(9) xor c(10) xor c(11) xor c(12) xor c(13) xor c(14) xor c(15);
    return newcrc;
  end nextCRC16_D26;

-----------------------------------------------------------
function nextCRC1_D1
    (Data: std_logic;
     crc:  std_logic)
    return std_logic is

    variable d:      std_logic;
    variable c:      std_logic;
    variable newcrc: std_logic;

  begin
    d := Data;
    c := crc;

    newcrc := d xor c;
   
    return newcrc;
  end nextCRC1_D1;
------------------------------------------------------------



end Phoebe;
