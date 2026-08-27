-------------------------------------------------------------------------------
-- Title      : ECC calculation and check
-- Project    : Simulation of DDR2 part of peripheral FPGA (Ovation project)
-------------------------------------------------------------------------------
-- File       : ddr_hamming.vhd
-- Author     : Shinderman Eugene  <ilq00431@ILQHFAATC1DT213>
-- Company    :
-- Created    : 07/03/2006
-- Last update: 04/01/2023
-- Platform   :
-- Standard   : VHDL'93, Math Packages
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2006
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 07/03/2006  1.0      ilq00431	Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity ddr_hamming is
  generic (
    ENCODER : boolean := TRUE);                    -- encoder or decoder
  port (
    CLK      : in  std_logic;
    RESET_I  : in  std_logic;
    DATA_IN  : in  std_logic_vector(63 downto 0);    -- codeword info bits
    CHECK_BITS_IN : in std_logic_vector(7 downto 0); -- codeword check bits
    RD_DATA_READY : in  std_logic;
    DATA_OUT : out std_logic_vector(63 downto 0);
    CHECK_BITS_OUT : out std_logic_vector(7 downto 0);
    ECC_ERROR : out boolean;
    ECC_DOUBLE_ERROR : out boolean;
    ECC_ERROR_LOCATION : out natural range 0 to 127; -- Location in codeword, no in infoword
                                                     -- Valid if ECC_ERROR /= X"7F"
    DDR_HAMMING_TP : out std_logic_vector(7 downto 0));

end entity ddr_hamming;

architecture ddr_hamming_ar of ddr_hamming is
  signal data_in_i : unsigned(71 downto 0);
  signal data_out_i : unsigned(71 downto 0);
  signal check_bits, rd_check_bits : unsigned(7 downto 0);
  signal error_location : natural range 0 to 127 := 0;  -- !debug: 15/01/2020 was 127, temporary change
  signal error_location_std : unsigned(7 downto 1);

  function log2 (x : positive) return natural is
    variable temp, log : natural;
  begin
    temp := x / 2;
    log  := 0;
    while (temp /= 0) loop
      temp := temp/2;
      log  := log + 1;
    end loop;
    return log;
  end function log2;

  signal no_errors : boolean := TRUE;
  signal double_error, do_correct : boolean := FALSE;
  subtype c_row is string(1 to 7);
  type c_table is array (0 to 71) of c_row;
--  signal check_table : c_table;         -- for testbench only
  type PARITY_BITS_TYP is array (0 to 7) of integer;
  constant parity_bits : PARITY_BITS_TYP := (0,1,2,4,8,16,32,64);

begin  -- architecture ddr_hamming_ar

  data_in_i <= unsigned(DATA_IN(63 downto 57) & CHECK_BITS_IN(7) &
                DATA_IN(56 downto 26) & CHECK_BITS_IN(6) &
                DATA_IN(25 downto 11) & CHECK_BITS_IN(5) &
                DATA_IN(10 downto 4) & CHECK_BITS_IN(4) &
                DATA_IN(3 downto 1) & CHECK_BITS_IN(3) &
                DATA_IN(0) & CHECK_BITS_IN(2 downto 0));


  calc_ecc_pr : process (CHECK_BITS_IN, DATA_IN, data_in_i) is
    variable check_bits_v : unsigned(7 downto 0);
  begin  -- process calc_ecc_pr

    check_bits_v := unsigned(CHECK_BITS_IN);

    for i in 0 to data_in_i'LEFT loop            -- 0..71

      for c_i in 0 to log2(data_in_i'LEFT) loop  -- to 6


--         check_table(i)(c_i+1) <= character'(' ');

        if (to_unsigned(i, 7)(c_i) = '1') then
--          check_table(i)(c_i+1) <= character'('x');
          check_bits_v(c_i+1) := check_bits_v(c_i+1) xor data_in_i(i);
        end if;

      end loop;  -- c_i

      if (ENCODER) then
        check_bits_v(0) := XOR_REDUCE(std_logic_vector(DATA_IN)) xor
                           XOR_REDUCE(std_logic_vector(check_bits_v(7 downto 1)));
      else
        check_bits_v(0) := XOR_REDUCE(std_logic_vector(DATA_IN)) xor
                           XOR_REDUCE(CHECK_BITS_IN(7 downto 1));
      end if;

    end loop;  -- i

    check_bits <= check_bits_v;

  end process calc_ecc_pr;



  encoder_gen : if (ENCODER) generate

    add_ecc_pr : process (CLK, RESET_I) is
    begin  -- process   add_ecc_pr

      if (RESET_I = '0') then
        data_out_i <= (others => '0');
      elsif rising_edge(CLK) then

        data_out_i <= data_in_i;

        data_out_i(0) <= check_bits(0);

        for i in 0 to log2(data_out_i'LEFT) loop  -- to 6
          data_out_i(2**i) <= check_bits(i + 1);
        end loop;  -- i

      end if;
    end process add_ecc_pr;

  end generate encoder_gen;



  decoder_gen : if (not ENCODER) generate

    -- check income codeword for errors
    -- no_errors <= TRUE when (rd_data_ready = '0') else STD_MATCH(rd_check_bits, check_bits);
    no_errors <= TRUE when (rd_data_ready = '0') else (rd_check_bits = check_bits); -- 04/01/2023

    check_error_pr : process (check_bits, data_in_i, no_errors, rd_check_bits) is
    begin  -- process check_error_pr

      -- read check bits from codeword
      rd_check_bits(0) <= data_in_i(0);
      for i in 0 to log2(data_in_i'LEFT) loop  -- to 6
        rd_check_bits(i + 1) <= data_in_i(2**i);
      end loop;  -- i

      if (no_errors) then
        error_location_std <= (others => '1');
        do_correct <= FALSE;
        double_error <= FALSE;
      else
        if (rd_check_bits(0) /= check_bits(0)) then   -- single error
          error_location_std <= rd_check_bits(7 downto 1) xor check_bits(7 downto 1);
          double_error <= FALSE;
          do_correct <= TRUE;
        else                            -- double error
          error_location_std <= (others => '1');
          double_error <= TRUE;
          do_correct <= FALSE;
        end if;
      end if;

    end process check_error_pr;

	-- Error location valid only when single error detected
	-- !debug: 15/01/2020 temporary disabled   error_location <= to_integer(error_location_std);


    correct_error_pr : process (CLK, RESET_I) is
    begin  -- process correct_error_pr
      if RESET_I = '0' then               -- asynchronous reset (active low)
        data_out_i <= (others => '0');
      elsif CLK'EVENT and CLK = '1' then  -- rising clock edge

        data_out_i <= data_in_i;
        if (do_correct) then
          data_out_i(error_location) <= not data_in_i(error_location);
        end if;

      end if;
    end process correct_error_pr;


    sync_dec_pr : process (CLK, RESET_I) is
    begin  -- process sync_dec_pr
      if RESET_I = '0' then               -- asynchronous reset (active low)
        ECC_ERROR_LOCATION <= 16#7F#;     -- !debug, was 0
        ECC_ERROR          <= FALSE;
        ECC_DOUBLE_ERROR   <= FALSE;

      elsif CLK'event and CLK = '1' then  -- rising clock edge

        if (ENCODER) then
          ECC_ERROR_LOCATION <= 16#7F#;   -- !debug, was 0
          ECC_ERROR          <= FALSE;
          ECC_DOUBLE_ERROR   <= FALSE;
        else
          ECC_ERROR_LOCATION <= error_location;
          ECC_ERROR          <= (not no_errors);
          ECC_DOUBLE_ERROR   <= double_error;
        end if;

      end if;
    end process sync_dec_pr;

  end generate decoder_gen;


  DATA_OUT <= std_logic_vector(data_out_i(71 downto 65) &
                data_out_i(63 downto 33)& data_out_i(31 downto 17) &
                data_out_i(15 downto 9) & data_out_i(7 downto 5) & data_out_i(3));

  CHECK_BITS_OUT <= data_out_i(64) & data_out_i(32) & data_out_i(16) & data_out_i(8) &
                    data_out_i(4) & data_out_i(2) & data_out_i(1) & data_out_i(0);


--   DDR_HAMMING_TP(0) <= '1' when double_error else '0';
  DDR_HAMMING_TP(0) <= check_bits(0);
  DDR_HAMMING_TP(1) <= check_bits(1);
  DDR_HAMMING_TP(2) <= check_bits(2);
  DDR_HAMMING_TP(3) <= check_bits(3);
  DDR_HAMMING_TP(4) <= check_bits(4);
  DDR_HAMMING_TP(5) <= check_bits(5);
  DDR_HAMMING_TP(6) <= check_bits(6);
  DDR_HAMMING_TP(7) <= check_bits(7);


end architecture ddr_hamming_ar;
