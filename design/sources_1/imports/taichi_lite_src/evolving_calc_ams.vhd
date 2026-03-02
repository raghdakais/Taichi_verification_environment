-------------------------------------------------------------------------------
-- Title      : Taichi TMB evolving calculation
-- Project    : Taichi module board, TMB
-------------------------------------------------------------------------------
-- File       : evolving_calc_ams.vhd
-- Author     : Shinderman Eugene  <eu1@localhost-localdomain>
-- Company    : HBtech
-- Created    : 20/08/2023
-- Last update: 29/03/2024
-- Platform   : Vivado v.2022.2, Device : xc7s75fgga484-2
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description: evolving calculation after AMS slices sorter
-------------------------------------------------------------------------------
-- Copyright (c) 2023
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 20/08/2023  1.0      eu1
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


entity evolving_calc_ams is
  port (
    sys_clk            : in  std_logic;  -- system clock @50MHz
    rst_n              : in  std_logic;
    slice_merge_en     : in  std_logic;                   -- slice merging enable
    fs_merge_en        : in  std_logic;                   -- slice merging enable
    num_of_slices      : in std_logic_vector(6 downto 0); -- slice number before merge
    ev_num_of_slices   : out std_logic_vector(6 downto 0); -- slice number after merge
    shift_val_o        : out natural range 0 to 7;
    merge_factor       : in std_logic_vector(4 downto 0); -- 1,2,4,8,16
    fs_merging_factor  : in std_logic_vector(1 DOWNTO 0);
    fs_merge_factor    : in std_logic_vector(3 downto 0);
    fs_sequence_counter: in std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
    start_over_1st     : in  std_logic;                     -- 03/03/2024
    fq_data_valid      : in std_logic;
    fq_data_in         : in std_logic_vector(31 downto 0);
    ev_header_en       : out std_logic;
    -- skip_wait2ev       : out std_logic; -- 31/12/2023
    ev_data_valid      : out std_logic;
    ev_data            : out std_logic_vector(31 downto 0)
  );
end entity evolving_calc_ams;


architecture ar of evolving_calc_ams is

  signal num_of_slices_after_merge : std_logic_vector(6 downto 0); -- must be even
  signal shift_val, fs_shift_val : natural range 0 to 7;

  component slice_buffer_dpr is
  Port (
    clka : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 5 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 19 downto 0 );
    clkb : in STD_LOGIC;
    addrb : in STD_LOGIC_VECTOR ( 5 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 19 downto 0 )
  );
  end component slice_buffer_dpr;

  signal slice_buffer_addra : std_logic_vector(5 downto 0);
  signal slice_buffer_addrb_r0, slice_buffer_addrb_r1, slice_buffer_addrb : std_logic_vector(5 downto 0); -- slice_buffer_addrb_r2

  signal merge_cnt, merge_cnt_r0, merge_cnt_r1, merge_cnt_r2 : natural range 0 to 16; -- , fs_merge_cnt
  signal fq_data_valid_shr, merge_valid_shr : std_logic_vector(3 downto 0);
  signal data_in_cnt, slice_in_cnt : natural range 0 to 127;
  signal slice_buffer_doutb_lsw, slice_buffer_doutb_msw : std_logic_vector(19 downto 0);
  signal slice_buffer_din_lsw, slice_buffer_din_msw : std_logic_vector(19 downto 0);
  signal fq_data_in_r0, fq_data_in_r1 : std_logic_vector(31 downto 0); -- fq_data_in_r2

  signal slice_ev_data_valid      : std_logic;
  signal slice_ev_data, slice_ev_data_r0, slice_ev_data_r1, slice_ev_data_r2 : std_logic_vector(31 downto 0);
  signal slice_merging_wait_cnt : natural range 0 to 7;
  signal slice_merging_complete : boolean;
  signal slice_ev_data_valid_shr : std_logic_vector(3 downto 0);
  signal fs_buffer_din_lsw, fs_buffer_din_msw : std_logic_vector(19 downto 0);
  signal fs_buffer_doutb_lsw, fs_buffer_doutb_msw : std_logic_vector(19 downto 0);
  signal fs_buffer_addra, fs_buffer_addrb, fs_buffer_addrb_r0, fs_buffer_addrb_r1 : std_logic_vector(9 downto 0);
  signal fs_merge_result2out : boolean;

  component fs_buffer_dpr is
    port (
      clka  : in  std_logic;
      wea   : in  std_logic_vector (0 to 0);
      addra : in  std_logic_vector (9 downto 0);
      dina  : in  std_logic_vector (19 downto 0);
      clkb  : in  std_logic;
      addrb : in  std_logic_vector (9 downto 0);
      doutb : out std_logic_vector (19 downto 0)
      );
  end component fs_buffer_dpr;

  signal load_fs_merge_cnt : boolean;
  signal num_of_slices_r : std_logic_vector(6 downto 0); -- slice number before merge

begin  -- architecture ar


  misc_pr: process (sys_clk, rst_n) is
  begin  -- process misc_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      num_of_slices_after_merge <= (others => '0');
      shift_val <= 0;
      fs_shift_val <= 0;
      fq_data_valid_shr <= (others => '0');
      merge_valid_shr <= (others => '0');
      slice_buffer_addra <= (others => '0');
      slice_buffer_addrb_r0 <= (others => '0');
      slice_buffer_addrb_r1 <= (others => '0');
      -- slice_buffer_addrb_r2 <= (others => '0');
      fq_data_in_r0 <= (others => '0');
      fq_data_in_r1 <= (others => '0');
      -- fq_data_in_r2 <= (others => '0');
      num_of_slices_r <= (others => '0');
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      num_of_slices_r <= num_of_slices;

      -- option: use log2
      if (slice_merge_en = '1' and  -- enable merge
          unsigned(num_of_slices) = unsigned(num_of_slices_r)) then -- not num_of_slices changed, prevent glitch
        case to_integer(unsigned(merge_factor)) is
          when 2      => shift_val <= 1;
          when 4      => shift_val <= 2;
          when 8      => shift_val <= 3;
          when 16     => shift_val <= 4;
          when others => shift_val <= 0;  -- invalid merge factor
        end case;
      else
        shift_val <= 0;                 -- no merge
      end if;

      fs_shift_val <= to_integer(unsigned(fs_merging_factor));

      num_of_slices_after_merge <= std_logic_vector(unsigned(num_of_slices) srl shift_val);

      assert (num_of_slices_after_merge(0) = '0') report "Error: slice number after merge must be even" severity ERROR;

      fq_data_valid_shr <= fq_data_valid_shr(2 downto 0) & fq_data_valid;
      merge_valid_shr <= merge_valid_shr(2 downto 0) & fq_data_valid_shr(1);

      slice_buffer_addrb_r0 <= slice_buffer_addrb;
      slice_buffer_addrb_r1 <= slice_buffer_addrb_r0;
      -- slice_buffer_addrb_r2 <= slice_buffer_addrb_r1; -- NU
      slice_buffer_addra <= slice_buffer_addrb_r1; -- write address is delayed read address

      fq_data_in_r0 <= fq_data_in;
      fq_data_in_r1 <= fq_data_in_r0;
      -- fq_data_in_r2 <= fq_data_in_r1;   -- NU delayed write data

    end if;
  end process misc_pr;


  slice_buffer_dpr_lsw: slice_buffer_dpr
    port map (
      clka  => sys_clk,
      wea(0) => fq_data_valid_shr(2),
      addra => slice_buffer_addra,
      dina  => slice_buffer_din_lsw,
      clkb  => sys_clk,
      addrb => slice_buffer_addrb,
      doutb => slice_buffer_doutb_lsw
      );

  slice_buffer_dpr_msw: slice_buffer_dpr
    port map (
      clka  => sys_clk,
      wea(0) => fq_data_valid_shr(2),
      addra => slice_buffer_addra,
      dina  => slice_buffer_din_msw,
      clkb  => sys_clk,
      addrb => slice_buffer_addrb,
      doutb => slice_buffer_doutb_msw
      );


  merge_ctl_pr: process (sys_clk, rst_n) is
    variable slice_inc_v : boolean;
  begin  -- process merge_ctl_pr
    if (rst_n = '0') then               -- asynchronous reset (active low)
      merge_cnt <= 0;
      merge_cnt_r0 <= 0;
      merge_cnt_r1 <= 0;
      merge_cnt_r2 <= 0;
      slice_buffer_addrb <= (others => '0');
      slice_in_cnt <= 0;
      data_in_cnt <= 0;
      slice_inc_v := FALSE;
      slice_buffer_din_lsw <= (others => '0');
      slice_buffer_din_msw <= (others => '0');
      slice_ev_data_valid <= '0';
      slice_ev_data <= (others => '0');
    elsif (sys_clk'event and sys_clk = '1') then  -- rising clock edge

      -- incr data_in_cnt -> ? data_in_cnt = 32 -> slice_inc -> merge_cnt dec -> ? merge_cnt = 0

      -- stage 1:
      -- get FQ slice and count, slice size: 32 16bit detectors or 16 DW
      if (fq_data_valid = '1') then
        if (data_in_cnt < 15) then      -- end of slice
          data_in_cnt <= data_in_cnt + 1;
          slice_inc_v := FALSE;
        else
          data_in_cnt <= 0;
          if (slice_in_cnt /= 127) then
            slice_in_cnt <= slice_in_cnt + 1;
          end if;
          slice_inc_v := TRUE;            -- next slice
        end if;
      else
        slice_in_cnt <= 0;
        slice_inc_v := FALSE;
      end if;

      -- merge controls
      if (slice_merge_en = '1' and shift_val /= 0) then -- enable merge
        if (fq_data_valid = '0') then
          merge_cnt <= to_integer(unsigned(merge_factor)) - 1; -- init first
        elsif (merge_cnt = 0 and data_in_cnt = 15) then
          merge_cnt <= to_integer(unsigned(merge_factor)) - 1; -- init next
        elsif (slice_inc_v) then                                 -- slice_inc
          merge_cnt <= merge_cnt - 1;   -- count slices in merge loop
        end if;
      else
        merge_cnt <= 0;
      end if;

      merge_cnt_r0 <= merge_cnt;
      merge_cnt_r1 <= merge_cnt_r0;
      merge_cnt_r2 <= merge_cnt_r1;

      -- slice buffer controls
      if (fq_data_valid = '0') then  -- no data  !debug: 11/09/2023  and fq_data_valid_shr = X"0"
        slice_buffer_addrb <= (others => '0');
      elsif (slice_inc_v) then                                    -- slice_inc
        slice_buffer_addrb <= (others => '0');
      else
        slice_buffer_addrb <= std_logic_vector(unsigned(slice_buffer_addrb) + 1);
      end if;

      -- slice merge next
      if (merge_cnt_r1 = (to_integer(unsigned(merge_factor)) - 1)) then -- new merge start, ignore old data in DPR
        slice_buffer_din_lsw <= X"0" & fq_data_in_r1(15 downto 0);
        slice_buffer_din_msw <= X"0" & fq_data_in_r1(31 downto 16);
      else
        slice_buffer_din_lsw <= std_logic_vector(unsigned(fq_data_in_r1(15 downto 0)) + unsigned(slice_buffer_doutb_lsw));
        slice_buffer_din_msw <= std_logic_vector(unsigned(fq_data_in_r1(31 downto 16)) + unsigned(slice_buffer_doutb_msw));
      end if;

      -- slice merge ready, send slice to FS merge
      if (merge_cnt_r2 = 0) then
        slice_ev_data_valid <= merge_valid_shr(shift_val);
        slice_ev_data(15 downto 0) <= slice_buffer_din_lsw(shift_val+15 downto shift_val);
        slice_ev_data(31 downto 16) <= slice_buffer_din_msw(shift_val+15 downto shift_val);
      else
        slice_ev_data_valid <= '0';
        slice_ev_data <= (others => '0');
      end if;

      if (fq_data_valid = '0' and fq_data_valid_shr(0) = '1') then -- last data
        assert (slice_in_cnt = (to_integer(unsigned(num_of_slices)))) report "Error: reading data size not match to slice number" severity ERROR;
      end if;

    end if;
  end process merge_ctl_pr;

  fs_merge_ctl_pr: process (sys_clk) is
  begin  -- process fs_merge_ctl_pr
    if (sys_clk'event and sys_clk = '1') then  -- rising clock edge
      if (rst_n = '0') then             -- synchronous reset (active low)
        slice_merging_wait_cnt <= 0;
        slice_merging_complete <= FALSE;
        slice_ev_data_valid_shr <= (others => '0');
        slice_ev_data_r0 <= (others => '0');
        slice_ev_data_r1 <= (others => '0');
        slice_ev_data_r2 <= (others => '0');
        -- fs_merge_cnt <= 0;
        fs_buffer_addrb <= (others => '0');
        fs_buffer_addrb_r0 <= (others => '0');
        fs_buffer_addrb_r1 <= (others => '0');
        fs_buffer_addra <= (others => '0');
        fs_buffer_din_lsw <= (others => '0');
        fs_buffer_din_msw <= (others => '0');
        ev_data_valid <= '0';
        fs_merge_result2out <= FALSE;
        ev_header_en <= '0';
        load_fs_merge_cnt <= FALSE;
      else

        if (fq_data_valid = '0' and fq_data_valid_shr(0) = '1') then -- last data in reading
          slice_merging_wait_cnt <= 7;
        else
          if (slice_merging_wait_cnt /= 0) then
            slice_merging_wait_cnt <= slice_merging_wait_cnt - 1;
          end if;
        end if;
        slice_merging_complete <= (slice_merging_wait_cnt = 1);

        if (fs_shift_val /= 0) then
          if (load_fs_merge_cnt) then
            -- fs_merge_cnt <= to_integer(unsigned(fs_merge_factor)) - 1; -- init first
            fs_merge_result2out <= FALSE;
          elsif (fq_data_valid = '1' and fq_data_valid_shr(0) = '0') then -- first data
            -- if (fs_merge_cnt /= 0) then
            --   fs_merge_cnt <= fs_merge_cnt - 1;
            -- end if;
            -- fs_merge_result2out <= (fs_merge_cnt = 1);
             fs_merge_result2out <= (to_integer(unsigned(fs_sequence_counter)) = (to_integer(unsigned(fs_merge_factor)) - 1)); -- !debug: 07/02/2024
          end if;
        else
          -- fs_merge_cnt <= 0;
          fs_merge_result2out <= TRUE;
        end if;

        slice_ev_data_valid_shr <= slice_ev_data_valid_shr(2 downto 0) & slice_ev_data_valid;

        if (slice_merging_complete) then
          fs_buffer_addrb <= (others => '0');
        elsif (slice_ev_data_valid = '1') then
          fs_buffer_addrb <= std_logic_vector(unsigned(fs_buffer_addrb) + 1);
        end if;

        fs_buffer_addrb_r0 <= fs_buffer_addrb;
        fs_buffer_addrb_r1 <= fs_buffer_addrb_r0;
        fs_buffer_addra <= fs_buffer_addrb_r1; -- write address is delayed read address

        slice_ev_data_r0 <= slice_ev_data;
        slice_ev_data_r1 <= slice_ev_data_r0;
        slice_ev_data_r2 <= slice_ev_data_r1;

        -- note:
        --   V fs_data_valid <- delayed slice_ev_data_valid  note: same as in slice_buffer
        --   V fs_buffer_addra <- delayed fs_buffer_addrb  note: same as in slice_buffer
        --   fs_buffer_din_lsw/_msw <- slice_ev_data
        --   V fs_buffer_addrb <- init when complete, increment when slice_ev_data_valid
        --   fs_buffer_doutb_lsw/_msw <- from fs_buffer_dpr

        -- FS merge next
        -- if (fs_merge_cnt = (to_integer(unsigned(fs_merge_factor)) - 1)) then -- !debug: 25/12/2023
        if (load_fs_merge_cnt) then -- !debug: 07/02/2024
          fs_buffer_din_lsw <= X"0" & slice_ev_data_r1(15 downto 0);
          fs_buffer_din_msw <= X"0" & slice_ev_data_r1(31 downto 16);
        else
          fs_buffer_din_lsw <= std_logic_vector(unsigned(slice_ev_data_r1(15 downto 0)) + unsigned(fs_buffer_doutb_lsw));
          fs_buffer_din_msw <= std_logic_vector(unsigned(slice_ev_data_r1(31 downto 16)) + unsigned(fs_buffer_doutb_msw));

        end if;

        -- FS merge ready, send slice to EV buffer
        if (fs_merge_result2out) then
          if (slice_ev_data_valid_shr(2) = '1') then
            if (start_over_1st = '0' or fs_merge_en = '0') then               -- 03/03/2024
              ev_data_valid <= '1';
            else
              ev_data_valid <= '0';
            end if;
          else
            ev_data_valid <= '0';
          end if;
          if (fs_merge_en = '1') then
            ev_data(15 downto 0) <= fs_buffer_din_lsw(fs_shift_val+15 downto fs_shift_val);
            ev_data(31 downto 16) <= fs_buffer_din_msw(fs_shift_val+15 downto fs_shift_val);
          else
            ev_data <= slice_ev_data_r2; -- 17/03/2024
          end if;
        else
          ev_data_valid <= '0';
          ev_data <= (others => '0');
        end if;

        if (fs_merge_en = '1' and fs_merging_factor = "00" and to_integer(unsigned(fs_sequence_counter)) = 0) then -- !debug: 25/02/2024 when FS merge, this case NOT end of merge
          ev_header_en <= '0';
        elsif (fs_merging_factor /= "00") then
          if (to_integer(unsigned(fs_sequence_counter)) = (to_integer(unsigned(fs_merge_factor)) - 1)) then  -- !debug: 26/03/2024
            if (start_over_1st = '0') then               -- 03/03/2024
              ev_header_en <= '1';
            else
              ev_header_en <= '0';
            end if;
          else
            ev_header_en <= '0';
          end if;
        else
          ev_header_en <= '0';
        end if;

        load_fs_merge_cnt <= fs_merging_factor /= "00" and fs_sequence_counter = "000";

      end if;
    end if;
  end process fs_merge_ctl_pr;


  fs_buffer_dpr_lsw: fs_buffer_dpr
    port map (
      clka  => sys_clk,
      wea(0) => slice_ev_data_valid_shr(2),
      addra => fs_buffer_addra,
      dina  => fs_buffer_din_lsw,
      clkb  => sys_clk,
      addrb => fs_buffer_addrb,
      doutb => fs_buffer_doutb_lsw
    );

  fs_buffer_dpr_msw: fs_buffer_dpr
    port map (
      clka  => sys_clk,
      wea(0) => slice_ev_data_valid_shr(2),
      addra => fs_buffer_addra,
      dina  => fs_buffer_din_msw,
      clkb  => sys_clk,
      addrb => fs_buffer_addrb,
      doutb => fs_buffer_doutb_msw
    );

  ev_num_of_slices <= num_of_slices_after_merge;
  shift_val_o <= shift_val;
  -- skip_wait2ev <= '1' when (not fs_merge_result2out) else '0';

end architecture ar;
