-------------------------------------------------------------------------------
-- Title      : Merging related package
-- Project    : Taichi
-------------------------------------------------------------------------------
-- File       : fs_merge_pack.vhd
-- Author     : Shinderman Eugene  <eugene.shinderman@philips.com>
-- Company    : Philips Medical
-- Created    : 20/03/2024
-- Last update: 16/01/2025
-- Platform   :
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;

package fs_merge_pack is

  procedure fs_avg (
    signal data_in             :       std_logic_vector;
    signal fs_sequence_counter :       std_logic_vector(2 DOWNTO 0);
    signal fs_merge_factor     :       std_logic_vector(3 downto 0);
    signal fs_merging_factor   :       std_logic_vector(1 DOWNTO 0);
    signal temp_val            : inout std_logic_vector;
    signal data_out            : out   std_logic_vector);

  procedure fs_or (
    signal data_in             :       std_logic_vector;
    signal fs_sequence_counter :       std_logic_vector(2 DOWNTO 0);
    signal fs_merge_factor     :       std_logic_vector(3 downto 0);
    signal fs_merging_factor   :       std_logic_vector(1 DOWNTO 0);
    signal temp_val            : inout std_logic_vector;
    signal data_out            : out   std_logic_vector);

end package fs_merge_pack;


package body fs_merge_pack is

  procedure fs_avg (signal data_in : std_logic_vector;
                    signal fs_sequence_counter : std_logic_vector(2 DOWNTO 0);
                    signal fs_merge_factor : std_logic_vector(3 downto 0);
                    signal fs_merging_factor : std_logic_vector(1 DOWNTO 0);
                    signal temp_val : inout std_logic_vector;
                    signal data_out : out std_logic_vector) is
    -- variable temp_val_v : std_logic_vector := temp_val;
    variable data_out_v : std_logic_vector(temp_val'HIGH downto 0);
  begin

    if (fs_merging_factor = "00") then
      temp_val <= resize(data_in,temp_val'length); -- forget sum
    elsif (to_integer(unsigned(fs_sequence_counter)) = 0) then
      temp_val <= resize(data_in,temp_val'length); -- forget sum
    else                                           -- calc sum
      temp_val <= std_logic_vector(unsigned(temp_val(data_in'HIGH+3 downto 0)) + unsigned(data_in));
    end if;

    if (fs_merging_factor = "00") then
      data_out <= data_in;              -- same as input, also prevent delay +1 reading
    elsif (to_integer(unsigned(fs_sequence_counter)) = (to_integer(unsigned(fs_merge_factor)) - 1)) then
      data_out_v := std_logic_vector(unsigned(temp_val(data_in'HIGH+3 downto 0)) + unsigned(data_in)) srl to_integer(unsigned(fs_merging_factor)); -- !debug: 15/01/2025
      data_out <= resize(data_out_v,data_out'length);
    else
      data_out <= resize("0",data_out'length);
    end if;

  end procedure fs_avg;


  procedure fs_or (signal data_in : std_logic_vector;
                    signal fs_sequence_counter : std_logic_vector(2 DOWNTO 0);
                    signal fs_merge_factor : std_logic_vector(3 downto 0);
                    signal fs_merging_factor : std_logic_vector(1 DOWNTO 0);
                    signal temp_val : inout std_logic_vector;
                    signal data_out : out std_logic_vector) is
  begin

    if (fs_merging_factor = "00") then
      temp_val <= resize(data_in,temp_val'length); -- forget or
    elsif (to_integer(unsigned(fs_sequence_counter)) = 0) then
      temp_val <= resize(data_in,temp_val'length); -- forget or
    else                                           -- calc or
      temp_val <= temp_val or data_in;
    end if;

    if (fs_merging_factor = "00") then
      data_out <= data_in;              -- same as input, also prevent delay +1 reading
    elsif (to_integer(unsigned(fs_sequence_counter)) = (to_integer(unsigned(fs_merge_factor)) - 1)) then
      data_out <= temp_val or data_in;  -- OR() result
    else
      data_out <= resize("0",data_out'length);
    end if;

  end procedure fs_or;


end package body fs_merge_pack;
