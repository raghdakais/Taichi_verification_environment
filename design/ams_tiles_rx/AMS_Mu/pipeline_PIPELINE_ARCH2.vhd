
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
  
ENTITY PIPELINE2 IS
   PORT(
      --input control
      CLK            : IN     STD_LOGIC;
      RST            : IN     STD_LOGIC;
      DELTA_EN       : IN     STD_LOGIC;						-- Switch - Register bit
      OSUB_EN        : IN     STD_LOGIC;						-- Switch - Register bit
      LOG_EN         : IN     STD_LOGIC;						-- Switch - Register bit
      TCSUB_EN       : IN     STD_LOGIC;						-- Switch - Register bit
      PASST          : IN     STD_LOGIC;						-- Switch - Register bit
      ZERO_BAD_POINT : IN     STD_LOGIC;						-- Switch - Register bit
      DSTROBE        : IN     STD_LOGIC;						-- Mu Calculation Trigger
	  AMS_Charge     : IN     STD_LOGIC_VECTOR (25 DOWNTO 0);	-- 26 bit detector charge Data from AMS Asic (a.k.a "Count")
	  AMS_Time       : IN     STD_LOGIC_VECTOR (15 DOWNTO 0);	-- Time value from AMS Asic = number of Aclk pulses from previous Sync until current Sync
	  AMS_Offset     : IN     STD_LOGIC_VECTOR (15 DOWNTO 0);	-- Constant Charge Offset value (Register) to add to all AMS_Charge detector values in order to eliminate negative values
	  Global_IP_Time : IN     STD_LOGIC_VECTOR (15 DOWNTO 0);	-- Constant Time value to Normalize AMS_Offset to (Register).
      sync_ip : in STD_LOGIC;                                 -- 10/06/2021
      gain           : in STD_LOGIC_VECTOR(3 downto 0);		-- 24/06/2021 CREG[15..12] - Crst
      diag_in        : in STD_LOGIC_VECTOR(3 downto 0);		-- 12/04/2022
      --pipeline output
      MU_OUT         : OUT    STD_LOGIC_VECTOR (15 DOWNTO 0);	-- Mu Calculation Result (16 bit)
      MU_VAL         : OUT    STD_LOGIC;						-- Mu_Out valid when '1'
      MU_BAD         : OUT    STD_LOGIC							-- Mu_Out has Error when '1'
   );

-- Declarations

END PIPELINE2 ;


-- hds interface_end



architecture PIPELINE_ARCH of PIPELINE2 is

-- Normalized_Offset = AMS_Offset * AMS_Time / Global_IP_Time; To be Calculated ONCE every IP (taking "AMS_Time" from Asic Footer)
-- Mu_input_Count = (AMS_Charge & "0000000000") + (Normalized_Offset & "0000000000");

constant OCOR_DP: integer := 22;  --decimal point to the left of this bit for
								  --calc offset value and corrected counted
								  --This value changes for different offset
								  --collection integration period.  Set to
								  --22 for 0.5243 sec

-- constant Ten_Bits: integer := 10;
-- signal Ten_Bits : integer range 0 to 15 := 10; -- !debug: 15/08/2021 was constant
-- signal pad_bits : integer range 0 to 15 := 0; -- !debug: 15/08/2021

-- constant STG_IR:  integer := 1;	--stage input registers
-- constant STG_DD:  integer := 2; --stage delta data
-- constant STG_MO:  integer := 3; --stage multiplier output
-- constant STG_OS:  integer := 4; --stage offset subtractor
-- constant STG_FO:  integer := 5; --stage find one
-- constant STG_BS:  integer := 6; --stage barrell shifter
-- constant STG_LUT: integer := 7; --stage Log LUT input registers
-- constant STG_TCS: integer := 8; --stage time/count subtractor
-- constant STG_OR:  integer := 8; --stage output registers   !debug: 17/08/2021 now this no num of stage, but simple output latency
constant STG_IR:  integer := 1;	--stage input registers
constant STG_DD:  integer := 2; --stage delta data I: in this time sampled STD_Charge_Added_Offset
constant STG_FO:  integer := 3; --stage find one
constant STG_BS:  integer := 4; --stage barrell shifter
constant STG_LUT: integer := 5; --stage Log LUT input registers
constant STG_TCS: integer := 6; --stage time/count subtractor
constant STG_OR:  integer := 7; --stage output registers   !debug: 17/08/2021 now this no num of stage, but simple output latency

constant DATA_ERR :  STD_LOGIC_VECTOR (15 downto 0) := X"FBAD";

--miscellaneous control signals
signal delta_en_reg:   STD_LOGIC;
signal osub_en_reg:    STD_LOGIC;
signal log_en_reg:     STD_LOGIC;
signal tcsub_en_reg:   STD_LOGIC;
--signal passa_reg:      STD_LOGIC;
signal passt_reg:      STD_LOGIC;
--stage STG_IR signals (input registers)
---------------------
-- signal time_reg1:       STD_LOGIC_VECTOR (15 downto 0);
-- signal ptime_reg1:      STD_LOGIC_VECTOR (15 downto 0);
-- signal cnt_reg1:        STD_LOGIC_VECTOR (15 downto 0);
-- signal pcnt_reg1:       STD_LOGIC_VECTOR (15 downto 0);
-- signal noff_ir1:        STD_LOGIC_VECTOR (15 downto 0);
-- signal time_reg2:       STD_LOGIC_VECTOR (15 downto 0);
-- signal ptime_reg2:      STD_LOGIC_VECTOR (15 downto 0);
-- signal cnt_reg2:        STD_LOGIC_VECTOR (15 downto 0);
-- signal pcnt_reg2:       STD_LOGIC_VECTOR (15 downto 0);
-- signal noff_ir2:        STD_LOGIC_VECTOR (15 downto 0);
Signal S_AMS_Charge:	STD_LOGIC_VECTOR (25 downto 0);
Signal S_AMS_Time:		STD_LOGIC_VECTOR (15 downto 0);
Signal S_AMS_Offset:	STD_LOGIC_VECTOR (15 downto 0);
Signal S_Global_IP_Time: STD_LOGIC_VECTOR (15 downto 0);

signal twoscomp_charge : STD_LOGIC_VECTOR(25 downto 0); -- 29/09/2021

------------------------
--sateg STG_DD signals (delta data subtractor)
-- signal delta_cnt1:      STD_LOGIC_VECTOR (15 downto 0);
-- signal delta_time1:     STD_LOGIC_VECTOR (15 downto 0);
-- signal noff_dd1:        STD_LOGIC_VECTOR (15 downto 0);
-- signal delta_cnt2:      STD_LOGIC_VECTOR (15 downto 0);
-- signal delta_time2:     STD_LOGIC_VECTOR (15 downto 0);
-- signal noff_dd2:        STD_LOGIC_VECTOR (15 downto 0);
-- signal noff_dd:        STD_LOGIC_VECTOR (15 downto 0);

--stage STG_MA throught STG_MO signals (multiplier)
-- signal cnt_ma1:         STD_LOGIC_VECTOR (OCOR_DP+16 downto 0);
-- signal time_ma1:        STD_LOGIC_VECTOR (15 downto 0);
-- signal cnt_ma2:         STD_LOGIC_VECTOR (OCOR_DP+16 downto 0);
-- signal time_ma2:        STD_LOGIC_VECTOR (15 downto 0);
signal ccnt_os1_4div:    STD_LOGIC_VECTOR (39 downto 0);
signal time_os1_4div:    STD_LOGIC_VECTOR (16 downto 0);
-- signal div_result_4mult: STD_LOGIC_VECTOR (22 downto 0);
signal div_result, div_result_r  :    STD_LOGIC_VECTOR (39 downto 0);
-- signal product:          STD_LOGIC_VECTOR(38 downto 0);
-- signal sum_of_cnts:      STD_LOGIC_VECTOR(39 downto 0);
-- signal avg_sum_of_cnts:      STD_LOGIC_VECTOR(OCOR_DP+16 downto 0);
Signal STD_Charge_Added_Offset: STD_LOGIC_VECTOR(OCOR_DP+15 downto 0);
Signal Charge_Added_Offset: STD_LOGIC_VECTOR(OCOR_DP+16 downto 0);
Signal Charge_Shift_10b: STD_LOGIC_VECTOR(37 downto 0); -- !debug: 31/08/2021 was 35
-- signal rdy_vec:         STD_LOGIC_VECTOR(7 downto 0);--7 downto 0
-- signal product2sum:         STD_LOGIC_VECTOR(39 downto 0);
-- signal ccnt_os22sum:         STD_LOGIC_VECTOR(39 downto 0);
-- signal offset:         STD_LOGIC_VECTOR (31 downto 0);
signal ams_time_tmp, ams_time_mult8, ams_time_mult4 : STD_LOGIC_VECTOR(15 downto 0);
signal offset1:         STD_LOGIC_VECTOR(31 downto 0);
-- signal offset2:         STD_LOGIC_VECTOR (31 downto 0);
-- signal off_div:        STD_LOGIC_VECTOR (OCOR_DP+16 downto 0);
signal off_div1:        STD_LOGIC_VECTOR(OCOR_DP+17 downto 0); -- !debug: 31/08/2021 was +16
-- signal off_div2:        STD_LOGIC_VECTOR (OCOR_DP+16 downto 0);
--stage STG_OS signals (offset subtractor)
-- signal ccnt_os1:        STD_LOGIC_VECTOR (OCOR_DP+16 downto 0);
-- signal time_os1:        STD_LOGIC_VECTOR (15 downto 0);
-- signal ccnt_os2:        STD_LOGIC_VECTOR (OCOR_DP+16 downto 0);
-- signal time_os2:        STD_LOGIC_VECTOR (15 downto 0);
-- signal bad_ccnt1:       STD_LOGIC;
-- signal bad_ccnt2:       STD_LOGIC;
signal bad_ccnt:       STD_LOGIC;
--stage STG_FO signals (find one)
--(decimal point to right of bit 23)
signal time_fo:        STD_LOGIC_VECTOR (15 downto 0);
signal ccnt_fo:        STD_LOGIC_VECTOR (OCOR_DP+15 downto 0);
signal shift_hi_t, shift_hi_c:   STD_LOGIC_VECTOR (3 downto 0);
signal shift_lo_c:         STD_LOGIC_VECTOR (3 downto 0);
signal fnd1_hi_t, fnd1_hi_c, fnd1_lo_c:    STD_LOGIC;
signal shift_t, shift_c:  STD_LOGIC_VECTOR (4 downto 0);
--stage STG_BS signals (barrell shifter)
signal exp_t, exp_c:   STD_LOGIC_VECTOR (4 downto 0);
signal pass_time_bs:   STD_LOGIC_VECTOR (15 downto 0);
signal pass_cnt_bs:    STD_LOGIC_VECTOR (15 downto 0);
signal log_at_reg, log_ac_reg:  STD_LOGIC_VECTOR (11 downto 0);
--stage STG_LUT signals (Log LUT input registers)
signal log_time, log_cnt:   STD_LOGIC_VECTOR (17 downto 0);
signal log_t, log_c:   STD_LOGIC_VECTOR (18 downto 0);
signal pass_time_lut:  STD_LOGIC_VECTOR (15 downto 0);
signal pass_cnt_lut:   STD_LOGIC_VECTOR (15 downto 0);
--stage STG_TCS signals (time/count subtractors)
signal mu_unrnd:       STD_LOGIC_VECTOR (18 downto 0);
signal rnd_val:        STD_LOGIC_VECTOR (17 downto 1);
signal mu_rnd:         STD_LOGIC_VECTOR (17 downto 1);
signal mu:             STD_LOGIC_VECTOR (15 downto 0);
--stage STG_OR signals

--address and tag pipeline registers
signal val_data:       STD_LOGIC_VECTOR (STG_OR downto 1);
signal bad_data:       STD_LOGIC_VECTOR (STG_OR downto 1);
signal rdy, Sticky_Bad:       STD_LOGIC;
--components


component FIND_ONE_VHDL port (
	I:      in std_logic_vector(15 downto 0);
	Y:      out std_logic_vector(3 downto 0);
	FOUND1: out std_logic );
end component;

component BARREL_SHIFT_16 port (
	IVEC:	in STD_LOGIC_VECTOR(15 downto 0);
	SHIFT:	in STD_LOGIC_VECTOR(3 downto 0);
	CLK:	in STD_LOGIC;
	RST:	in STD_LOGIC;
	OVEC:	out STD_LOGIC_VECTOR(11 downto 0) );
end component;

component BARREL_SHIFT_32T port (
	IVEC:	in STD_LOGIC_VECTOR(37 downto 0);
	SHIFT:	in STD_LOGIC_VECTOR(4 downto 0);
	CLK:	in STD_LOGIC;
	RST:	in STD_LOGIC;
	OVEC:	out STD_LOGIC_VECTOR(11 downto 0) );
end component;

component log_lut
	port (
	addra: IN std_logic_VECTOR(11 downto 0);
	clka: IN std_logic;
	douta: OUT std_logic_VECTOR(12 downto 0));
END component log_lut;

-- component div40by17
--   port (
--   clk: in std_logic;
--   nd: in std_logic;
--   rdy: out std_logic;
--   rfd: out std_logic;
--   dividend: in std_logic_vector(39 downto 0);
--   divisor: in std_logic_vector(16 downto 0);
--   quotient: out std_logic_vector(39 downto 0));
-- end component;

component div40by17 is
  port (
    aclk : in STD_LOGIC;
    s_axis_divisor_tvalid : in STD_LOGIC;
    s_axis_divisor_tready : out STD_LOGIC;
    s_axis_divisor_tdata : in STD_LOGIC_VECTOR ( 23 downto 0 );
    s_axis_dividend_tvalid : in STD_LOGIC;
    s_axis_dividend_tready : out STD_LOGIC;
    s_axis_dividend_tdata : in STD_LOGIC_VECTOR ( 39 downto 0 );
    m_axis_dout_tvalid : out STD_LOGIC;
    m_axis_dout_tdata : out STD_LOGIC_VECTOR ( 39 downto 0 )
    );
end component;
signal s_axis_divisor_tdata : STD_LOGIC_VECTOR ( 23 downto 0 );

COMPONENT mult23x16
  PORT (
    clk : IN STD_LOGIC;
    a : IN STD_LOGIC_VECTOR(22 DOWNTO 0);
    b : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    p : OUT STD_LOGIC_VECTOR(38 DOWNTO 0)
  );
END COMPONENT;

-- 10/06/2021
signal div_en : std_logic;
signal powerup_cnt : natural range 0 to 255;

signal FBAD_Error_Bit : std_logic;      -- 29/09/2021
-- signal mu_val_cnt : natural range 0 to 511; -- !debug: 18/10/2021


begin


-- ========== REGISTER CONTROL BITS =========
--When PIPELINE is integrated into DSC_PIPE the control
--bits do not need registered.  If PIPELINE is in a separate
--device from DSC_PIPE then the control bit should use I/O FFs.
	delta_en_reg <= DELTA_EN;
	osub_en_reg  <= OSUB_EN;
	log_en_reg   <= LOG_EN;
	tcsub_en_reg <= TCSUB_EN;
	passt_reg    <= PASST;

-- ========== STAGE STG_IR (input reg) ==============
--This stage is not necessary for model L but is left
--in for 120 MHz operation for model M.  It serves 2
--functions. 1) allows the muxing of pipe_adr onto
--TIME bus in a single stage without the mux feeding
--directly into the delta data subtractor. 2) allows
--better fitting since I/O FF do not feed directly into
--the delta data subtractor.
	IN_REG:	 process (CLK, RST)
	begin
		if (RST='1') THEN
			S_AMS_Charge		<= (others => '0');
			S_AMS_Time			<= (others => '0');
			S_AMS_Offset		<= (others => '0');
			S_Global_IP_Time	<= (others => '0');

		elsif (CLK'event and CLK='1') then
			S_AMS_Charge		<= AMS_Charge;
			S_AMS_Time      	<= AMS_Time;
			S_AMS_Offset    	<= AMS_Offset;
			S_Global_IP_Time	<= Global_IP_Time;

		end if;
	end process IN_REG;


-- ========== STAGE STG_DD (delta data) ==============
-- DELTA DATA SUBTRACTION FOR TIME AND COUNT IN
-- PARALLEL.  ALSO, REGISTER THE NORMALIZED OFFSET VALUE.

-- 	DELTA_DATA: process (RST, CLK)
-- 	begin
-- 		if RST='1' then
-- 			delta_time1 <= (others => '0');
-- 			delta_cnt1  <= (others => '0');
-- 			noff_dd1    <= (others => '0');
-- 			delta_time2 <= (others => '0');
-- 			delta_cnt2  <= (others => '0');
-- 			noff_dd2    <= (others => '0');
--
--
-- 		elsif (CLK'event and CLK='1') then
-- 			if (delta_en='1') then
-- 				delta_time1 <= time_reg1 - ptime_reg1;
-- 				delta_cnt1 <= cnt_reg1 - pcnt_reg1;
-- 				delta_time2 <= time_reg2 - ptime_reg2;
-- 				delta_cnt2 <= cnt_reg2 - pcnt_reg2;
-- 			else
-- 				delta_time1 <= time_reg1;
-- 				delta_cnt1 <= cnt_reg1;
-- 				delta_time2 <= time_reg2;
-- 				delta_cnt2 <= cnt_reg2;
-- 			end if;
--
-- 			noff_dd1 <= noff_ir1;
-- 			noff_dd2 <= noff_ir2;
-- 		end if;
-- 	end process DELTA_DATA;
--------------------------------------------------------------------------------

-- ========== STAGE STG_MO (multiplier) ===========
-- MULTIPLY OF NORMALIZED OFFSET BY TIME.  ALSO,
-- 1 PIPELINE DELAY FOR TIME AND COUNT.

-- The maximum value out of the multiplier is 0xFFFE0001

	mult_p : process (RST, CLK)
-- 		variable arg1, arg2 : integer range 0 to 2**16-1;
-- 		variable result : integer 0 to 2**32 -1; -- 32 bits
	begin

		if RST='1' then
			--offset <= (others => '0');
			offset1 <= (others => '0');
			ams_time_tmp <= (others => '0');
			ams_time_mult4 <= (others => '0');
			ams_time_mult8 <= (others => '0');
            -- Ten_Bits <= 10;
            -- pad_bits <= 0;
		elsif (CLK'event and CLK='1') then

-- 			arg1 := CONV_INTEGER( UNSIGNED( delta_time ) );
-- 			arg2 := CONV_INTEGER( UNSIGNED( noff_dd ) );
-- 			result := arg1*arg2;

--			offset <= CONV_STD_LOGIC_VECTOR( result, offset'length );

--			offset <= CONV_STD_LOGIC_VECTOR( CONV_INTEGER( UNSIGNED( delta_time ) ) * CONV_INTEGER( UNSIGNED( noff_dd ) ), offset'length );
			--offset <= delta_time * noff_dd;
--			offset1 <= delta_time1 * noff_dd1;
            ams_time_mult8 <= S_AMS_Time(12 downto 0) & "000";
            ams_time_mult4 <= S_AMS_Time(13 downto 0) & "00";
            ams_time_tmp <= ams_time_mult8 + ams_time_mult4; -- 13/09/2021
			offset1 <= ams_time_tmp * S_AMS_Offset;	-- Miki 13/9/2021 Multiply by 12 (*12) 

            case gain is
              when x"1"   => off_div1 <= "00000" & offset1(27 downto 0) & "0000000";
              when x"2"   => off_div1 <= "0000" & offset1(27 downto 0) & "00000000";
              when x"4"   => off_div1 <= "000" & offset1(27 downto 0) & "000000000";
              when x"8"   => off_div1 <= "00" & offset1(27 downto 0) & "0000000000";
              when others => off_div1 <= "00000" & offset1(27 downto 0) & "0000000";
            end case;
            
            -- off_div1 <= resize(offset1,off_div1'length); -- 23/12/2021
            
		end if;
	end process mult_p;
--------------------------------------------------------------------------------

--	off_div1(offset1'high downto 0) <= offset1;
--	off_div1(off_div1'high downto offset1'high+1) <= (others => '0');

  -- off_div1(off_div1'high-1 downto Ten_Bits) <= offset1(27 downto 0);
  -- off_div1(off_div1'high) <= '0';
  -- off_div1(Ten_Bits-1 downto 0) <= (others => '0');


-- ========== STAGE STG_OS (offset subtraction) ==============
-- OFFSET SUBTRACTION FOR COUNTS AND PIPELINE DELAY FOR TIME

	-- Add one MSB to the values input to the offset subtractor
	-- so that the MSB of the output is the carry bit.  If the
	-- carry bit is '1' then the data was bad because the count
	-- value should never be less than the offset.

--	cnt_ma1(cnt_ma1'high) <= '0';



	--Bad corrected COUNT if offset subtract result is negative

--	bad_ccnt1 <= '1' when (ccnt_os1(ccnt_os1'high)='1' and osub_en_reg='1') else '0';
--	bad_ccnt <= bad_ccnt1;
	bad_ccnt <= '0';

-- mult_p : process (RST, CLK)
-- -- 		variable arg1, arg2 : integer range 0 to 2**16-1;
-- -- 		variable result : integer 0 to 2**32 -1; -- 32 bits
	-- begin

		-- if RST='1' then
			-- ccnt_os1xtime_os2 <= (others => '0');
			-- ccnt_os2xtime_os1 <= (others => '0');
			-- time_os1xtime_os2 <= (others => '0');

		-- elsif (CLK'event and CLK='1') then

-- --
			-- ccnt_os1xtime_os2 <= ccnt_os1 * time_os2;
			-- ccnt_os2xtime_os1 <= ccnt_os2 * time_os1;
			-- time_os1xtime_os2 <= time_os1 * time_os2;

		-- end if;

ccnt_os1_4div <=off_div1;
time_os1_4div <='0'& S_Global_IP_Time;



-- div40by17_inst: div40by17
--   port map (
--   clk          =>  CLK,
--   nd           =>  val_data(5),
--   rdy          =>  rdy,
--   rfd          =>  open,
--   dividend     =>  ccnt_os1_4div,
--   divisor      =>  time_os1_4div,
--   quotient     =>  div_result                               --(39 downto 0)  ccnt_os1/time_os1
--
-- );

  -- 07/06/2021
  div40by17_1 : div40by17
    port map (
      aclk                   => clk,
      s_axis_divisor_tvalid  => div_en, -- !debug: 10/06/2021 was  val_data(5), div_en
      s_axis_divisor_tready  => open,
      s_axis_divisor_tdata   => s_axis_divisor_tdata,
      s_axis_dividend_tvalid => div_en, -- !debug: 10/06/2021 was  val_data(5), div_en
      s_axis_dividend_tready => open,
      s_axis_dividend_tdata  => ccnt_os1_4div,
      m_axis_dout_tvalid     => rdy,
      m_axis_dout_tdata      => div_result
      );

  s_axis_divisor_tdata <= "0000000" & time_os1_4div;

  Sample_Divider_Result: process (RST, CLK)
  begin
  if RST='1' then
	Charge_Added_Offset <= (others => '0');
	Charge_Shift_10b	<= (others => '0');
    twoscomp_charge	    <= (others => '0');
    FBAD_Error_Bit <= '0';
  elsif	 (CLK'event and CLK = '1') then
	if (rdy='1') then
	  div_result_r <= div_result;
      -- if (gain = X"1") then -- 23/12/2021
      --   div_result_r <= "00000" & div_result(27 downto 0) & "0000000";
      -- elsif (gain = X"2") then
      --   div_result_r <= "0000" & div_result(27 downto 0) & "00000000";
      -- elsif (gain = X"4") then
      --   div_result_r <= "000" & div_result(27 downto 0) & "000000000";
      -- elsif (gain = X"8") then
      --   div_result_r <= "00" & div_result(27 downto 0) & "0000000000";
      -- else
      --   div_result_r <= "00000" & div_result(27 downto 0) & "0000000";  -- Miki 13/9/2021 default position 7, shl
      -- end if;
	end if;
	Charge_Added_Offset <= div_result_r(38 downto 0); --signed(ccnt_os1) + signed(div_result(38 downto 0));
    if (osub_en_reg = '1') then            -- 29/09/2021
      if (S_AMS_Charge(25) = '1') then
        FBAD_Error_Bit <= '1';
      else
        FBAD_Error_Bit <= '0';
      end if;
    else
      if (S_AMS_Charge(25) = '1') then
        case gain is
          when x"1" => if (("00000" & twoscomp_charge & "0000000") > div_result_r) then    -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         FBAD_Error_Bit <= '1';
                       else
                         FBAD_Error_Bit <= '0';
                       end if;
          when x"2" => if (("0000" & twoscomp_charge & "00000000") > div_result_r) then    -- 29/09/2021 (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         FBAD_Error_Bit <= '1';
                       else
                         FBAD_Error_Bit <= '0';
                       end if;
          when x"4" => if (("000" & twoscomp_charge & "000000000") > div_result_r) then    -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         FBAD_Error_Bit <= '1';
                       else
                         FBAD_Error_Bit <= '0';
                       end if;
          when x"8" => if (("00" & twoscomp_charge & "0000000000") > div_result_r) then    -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         FBAD_Error_Bit <= '1';
                       else
                         FBAD_Error_Bit <= '0';
                       end if;
          when others => if (("00000" & twoscomp_charge & "0000000") > div_result_r) then  -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                           FBAD_Error_Bit <= '1';
                         else
                           FBAD_Error_Bit <= '0';
                         end if;
        end case;
      else
        FBAD_Error_Bit <= '0';
      end if;
    end if;

    if (osub_en_reg = '1') then -- 16/12/2021 offset substraction disabled
      if (S_AMS_Charge(25) = '0') then 
        case gain is
          when x"1"   => Charge_Shift_10b <= ("00000" & S_AMS_Charge & "0000000");
          when x"2"   => Charge_Shift_10b <= ("0000" & S_AMS_Charge & "00000000");
          when x"4"   => Charge_Shift_10b <= ("000" & S_AMS_Charge & "000000000");
          when x"8"   => Charge_Shift_10b <= ("00" & S_AMS_Charge & "0000000000");
          when others => Charge_Shift_10b <= ("00000" & S_AMS_Charge & "0000000");
        end case;
      else                              -- clip negative numbers 
        Charge_Shift_10b <= (others => '0');
      end if;
    else
      -- calc 2sComp_Charge -> calc (2sComp_Charge X 128 X Gain) -> calc Charge_Shift_10b (depend from positive or negative charge)
      if (AMS_Charge(25) = '1') then            -- 29/09/2021
        twoscomp_charge <= not(AMS_Charge) + 1; -- 2's complement
      else
        twoscomp_charge <= AMS_Charge;  -- time aligned to S_AMS_Charge
      end if;
      if (S_AMS_Charge(25) = '0') then    -- positive charge
        case gain is
          when x"1"   => Charge_Shift_10b <= ("00000" & S_AMS_Charge & "0000000") + div_result_r(35 downto 0);
          when x"2"   => Charge_Shift_10b <= ("0000" & S_AMS_Charge & "00000000") + div_result_r(35 downto 0);
          when x"4"   => Charge_Shift_10b <= ("000" & S_AMS_Charge & "000000000") + div_result_r(35 downto 0);
          when x"8"   => Charge_Shift_10b <= ("00" & S_AMS_Charge & "0000000000") + div_result_r(35 downto 0);
          when others => Charge_Shift_10b <= ("00000" & S_AMS_Charge & "0000000") + div_result_r(35 downto 0);
        end case;          
      else                              -- negative charge
        case gain is
          when x"1" => if (("00000" & twoscomp_charge & "0000000") > div_result_r) then    -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         Charge_Shift_10b <= (others => '0');
                       else
                         Charge_Shift_10b <= div_result_r(35 downto 0) - ("00000" & twoscomp_charge & "0000000");
                       end if;
          when x"2" => if (("0000" & twoscomp_charge & "00000000") > div_result_r) then    -- 29/09/2021 (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         Charge_Shift_10b <= (others => '0');
                       else
                         Charge_Shift_10b <= div_result_r(35 downto 0) - ("0000" & twoscomp_charge & "00000000");
                       end if;
          when x"4" => if (("000" & twoscomp_charge & "000000000") > div_result_r) then    -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         Charge_Shift_10b <= (others => '0');
                       else
                         Charge_Shift_10b <= div_result_r(35 downto 0) - ("000" & twoscomp_charge & "000000000");
                       end if;
          when x"8" => if (("00" & twoscomp_charge & "0000000000") > div_result_r) then    -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                         Charge_Shift_10b <= (others => '0');
                       else
                         Charge_Shift_10b <= div_result_r(35 downto 0) - ("00" & twoscomp_charge & "0000000000");
                       end if;
          when others => if (("00000" & twoscomp_charge & "0000000") > div_result_r) then  -- (2sComp_Charge X 128 X Gain)> Normalized_Offset
                           Charge_Shift_10b <= (others => '0');
                         else
                           Charge_Shift_10b <= div_result_r(35 downto 0) - ("00000" & twoscomp_charge & "0000000");
                         end if;
        end case;		    	          
      end if;     
    end if;
  end if;
  end process Sample_Divider_Result;



STD_Charge_Added_Offset <= Charge_Shift_10b;

-- ========== STAGE STG_FO (find one) ==============   
BSV_T: FIND_ONE_VHDL port map (
				I      => ams_time_tmp, -- 13/09/2021 was  S_AMS_Time,
				Y      => shift_hi_t,
				FOUND1 => fnd1_hi_t );

	BSV_CHI: FIND_ONE_VHDL port map (
				I      => STD_Charge_Added_Offset(OCOR_DP+15 downto OCOR_DP), --STD_Charge_Added_Offset(OCOR_DP+15 downto OCOR_DP),
				Y      => shift_hi_c,
				FOUND1 => fnd1_hi_c );

	BSV_CLO: FIND_ONE_VHDL port map (
				I      => STD_Charge_Added_Offset(OCOR_DP-1 downto OCOR_DP-16), --STD_Charge_Added_Offset(OCOR_DP-1 downto OCOR_DP-16),
				Y      => shift_lo_c,
				FOUND1 => fnd1_lo_c );



	FINDONE: process (RST, CLK)
	begin
		if (RST='1') then
			shift_t(3 downto 0) <= (others => '0');
			time_fo <= (others => '0');
			shift_c <= (others => '0');
			ccnt_fo <= (others => '0');
		elsif  (CLK'event and CLK='1') then

			shift_t(3) <= shift_hi_t(3);
			shift_t(2) <= shift_hi_t(2);
			shift_t(1) <= shift_hi_t(1);
			shift_t(0) <= shift_hi_t(0);

			if (fnd1_hi_c = '1') then
				shift_c(4) <= '0';
				shift_c(3 downto 0) <= shift_hi_c(3 downto 0);
			else
				shift_c(4) <= '1';
				shift_c(3 downto 0) <= shift_lo_c(3 downto 0);
			end if;

			time_fo <= ams_time_tmp; -- 13/09/2021 was  S_AMS_Time;
			ccnt_fo <= STD_Charge_Added_Offset; --STD_Charge_Added_Offset(ccnt_fo'range);

		end if;
	end process FINDONE;

	shift_t(4) <= '0';

-- ========== STAGE STG_BS (barrell shift) ==============
-- BARREL SHIFT TIME/COUNT BY THE EXP VALUE TO GET THE
-- ADDRESS FOR THE LOG MANTISSA LOOK-UP.  ALSO REGISTER
-- THE TIME/COUNT VALUE FOR BYPASSING THE LOGGER.

	SHFT_T : BARREL_SHIFT_16 port map(
				IVEC   => time_fo,
				SHIFT  => shift_t(3 downto 0),
				CLK    => CLK,
				RST    => RST,
				OVEC   => log_at_reg );
	--use the following line when using external LUT RAM that is
	--accessible by the Micro when a scan is not in progress.  The
	--pipeline will only drive the address when a scan is active.

	SHFT_C : BARREL_SHIFT_32T port map(
				IVEC   => ccnt_fo,
				SHIFT  => shift_c,
				CLK    => CLK,
				RST    => RST,
				OVEC   => log_ac_reg );
	--use the following line when using external LUT RAM that is
	--accessible by the Micro when a scan is not in progress.  The
	--pipeline will only drive the address when a scan is active.

	SHIFTER: process(CLK, RST)
	begin
		if (RST='1') then
			exp_t  <= (others => '0');
			exp_c  <= (others => '0');
			pass_time_bs <= (others => '0');
			pass_cnt_bs  <= (others => '0');
		elsif (CLK'event and CLK='1') then
			--take 1's compliment of the SHIFT value to obtain the exponent
			-- The exponent in EXP_C and EXP_T has a bias of X"10".  This
			-- offset will get eliminated when the log(corrected count) is
			-- subtracted form the log(time).

			for I in shift_t'low to shift_t'high loop
				exp_t(I) <= not shift_t(I);
				exp_c(I) <= not shift_c(I);
			end loop;

			--following 2 values used to pass TIME and COUNT value
			--when logger is not used
			pass_time_bs <= time_fo;
			pass_cnt_bs <= ccnt_fo(OCOR_DP+15 downto OCOR_DP);

		end if;
	end process SHIFTER;

-- ========== STAGE STG_LUT (Log LUT opertation) ==============
-- LOOK UP MANTISSA VALUE FROM INTERNAL LUT
-- The output of stage STG_LUT has the decimal point
-- to the right of bit 13.

	EXP_REG: process (CLK, RST)
	begin
		if (RST='1') then
			log_time(17 downto 13) <= "00000";
			log_cnt(17 downto 13)  <= "00000";
			pass_time_lut <= (others => '0');
			pass_cnt_lut  <= (others => '0');
		elsif (CLK'event and CLK='1') then
			log_time(17 downto 13) <= exp_t(4 downto 0);
			log_cnt(17 downto 13)  <= exp_c(4 downto 0);

			pass_time_lut <= pass_time_bs;
			pass_cnt_lut  <= pass_cnt_bs;
		end if;
	end process EXP_REG;

	TIME_LUT : log_lut
		port map (
			addra => log_at_reg,
			clka => CLK,
			douta => log_time(12 downto 0)
			 ); -- TIME_LUT


	CNT_LUT : log_lut
		port map (
			addra => log_ac_reg,
			clka => CLK,
			douta => log_cnt(12 downto 0)
			);

	--select either log value or logger bypassed value.  The extra
	--MSB is set to zero and used to check for an underflow condition
	--in the TIME-COUNT subtractor
	log_t <= '0' & log_time when (log_en_reg='1') else ('0' & pass_time_lut & "00");
	log_c <= '0' & log_cnt  when (log_en_reg='1') else ('0' & pass_cnt_lut  & "00");

-- ========== STAGE STG_TCS (time - count) ==============
-- PERFORM THE TIME - COUNT SUBTRACTION

-- Add 2 to the log of TIME, LOG_T, when the time/count
-- subtractor is used so the output of TC_SUB is rounded
-- and the 2 LSB can truncated to provide a 16-bit rounded
-- value.
-- When the TC_SUB is not used and the unlogged time value
-- is passed, the 2 LSB are of the time value are zero
-- filled (to create the 18-bit value LOG) prior to the
-- addition of 2.  Therefore, truncating the 2 LSB at the
-- output of the subtractor will not preserve the 16-bit
-- time value.
-- When the TC_SUB is not used and the logged time value is
-- passed, the output of the subtractor will contain a rounded
-- log of time value.

	TC_SUB: process (CLK, RST)
	begin
		if (RST='1') then
			mu_unrnd <= (others => '0');
		elsif (CLK'event and CLK='1') then
			if (tcsub_en_reg='1') then
				mu_unrnd <= log_t - log_c;
			else
				if (passt_reg='1') then
					mu_unrnd <= log_t;
				else
					mu_unrnd <= log_c;
				end if;
			end if;
		end if;
	end process TC_SUB;

	--The log of both TIME and COUNT both have a DC bias of 16
	--due to the way the exponent is determined.  When the log
	--of COUNT is subtracted from the log of TIME, the DC bias
	--is subtracted out.
	--
	--When the TIME/COUNT subtrator is disabled to pass either the
	--log of TIME or COUNT, the DC bias of 16 must be removed.  This
	--is done by adding the 5-bit 2's compliment of 16 to MU_UNRND.
	--The 5-bit 2's compliment of "10000" is "10000".
	--
	--When both the TIME-COUNT subtractor and the logger is turned off,
	--then mu_unrnd contains an address, TIME or COUNT value that is
	--being passed.  For this case there is no DC bias to be removed.
	rnd_val(rnd_val'high) <= '1' when (tcsub_en_reg='0' and log_en_reg='1') else '0';
	rnd_val(rnd_val'high-1 downto 1) <= (1 => '1', others => '0');

--	mu_rnd(17 downto 1) <= mu_unrnd(17 downto 1) + rnd_val;
	mu_rnd(17 downto 1) <= mu_unrnd(17 downto 1);-- + rnd_val;
	mu(15 downto 0) <= mu_rnd(17 downto 2);

-- ========== STAGE STG_OR (output registers) ==============
-- OUTPUT MUX SELECTS BETWEEN DATA AND ADDRESSES

	-- Chip output values should be registered at upper levels.  These
	-- values do not use I/O registers to permit easier placement.
	-- Note also that control signals, except MU_BAD, precede data by one cycle.
	OUT_MUX: process (CLK, RST)
	begin
		if (RST = '1') then
			MU_OUT   <= (others => '0');
			MU_VAL   <= '0';
			MU_BAD   <= '0';
		elsif (CLK'event and CLK='1') then
            -- if (ZERO_BAD_POINT='1' and ((mu_unrnd(18)='1' and val_data(STG_OR-1)='1')
			--     		or bad_data(STG_OR-1)='1') ) then
            if (ZERO_BAD_POINT='1' and ((diag_in(0) = '0' and mu_unrnd(18)='1' and val_data(STG_OR-1)='1') -- !debug: 30/09/2021
						or bad_data(STG_OR-1)='1') ) then
              MU_OUT <= DATA_ERR;
            -- elsif (FBAD_Error_Bit = '1') then -- 29/09/2021
            --   MU_OUT <= DATA_ERR;
			else
				MU_OUT <= mu;
			end if;
			MU_VAL  <= val_data(STG_OR-1);
			--MU_BAD is coincident with bad data.
			-- if ((mu_unrnd(18)='1' and val_data(STG_OR-1)='1')
			--     		or bad_data(STG_OR-1)='1') then -- !debug: 11/08/2021
			--     MU_BAD  <= '1';
			if ((diag_in(0) = '0' and mu_unrnd(18)='1' and val_data(STG_OR)='1')
						or bad_data(STG_OR)='1') then -- !debug: 11/08/2021
				MU_BAD  <= '1';
			else
				MU_BAD <= '0';
			end if;


		end if;
	end process OUT_MUX;

-- ========= DATA Tag Pipeline
	REG_TAG: process (RST, CLK)
	begin
		if (RST='1') then
			val_data  <= (others => '0');
			bad_data  <= (others => '0');
			-- rdy_vec   <= (others => '0');
			Sticky_Bad <= '0';
      div_en <= '0';                    -- 10/06/2021
      powerup_cnt <= 0;
		elsif (CLK'event and CLK='1') then
          -- if (val_data(1) = '0' and DSTROBE = '1') then -- !debug: 18/10/2021
          --  mu_val_cnt <= 0;
          -- elsif (val_data(STG_OR-1) = '1') then
          --  mu_val_cnt <= mu_val_cnt + 1;
          -- end if;  
          -- !debug: 10/06/2021	rdy_vec<= rdy_vec(rdy_vec'high-1 downto 0)&rdy;
          -- rdy_vec<= rdy_vec(rdy_vec'high-1 downto 0) & val_data(5); -- 10/06/2021
			-- STAGE 1
			-- compute tag values, output to stage 1
			-- (rest of stage 1 tags reg in IREG_TAG process)
			val_data(1)  <= DSTROBE;
			bad_data(1)  <= '0';

			--STAGES 2 AND ABOVE
			--for I in 2 to 5 loop
			--	val_data(I)     <= val_data(I-1);
--			--	bad_data(I)	    <= bad_data(I-1);
			--end loop;
			for I in 2 to STG_OR loop
			 val_data(I)     <= val_data(I-1);
			 bad_data(I)	    <= bad_data(I-1);
			end loop;

			-- val_data(6)<=rdy_vec(rdy_vec'high);
            -- !debug: 10/06/2021 val_data(6)<=val_data(5); -- 10/06/2021

			--for I in 2 to STG_OR loop
			--	bad_data(I)	    <= bad_data(I-1);
			--end loop;

            -- !debug: 10/06/2021
			-- If DSTROBE = '1' then
			--   Sticky_Bad <= '0';
			-- ElsIf rdy_vec(rdy_vec'high)='1' then
			--   Sticky_Bad <= '0';
			--   bad_data(6) <= Sticky_Bad;
			-- End If;

			--for I in 7 to STG_OR loop
			--	val_data(I)     <= val_data(I-1);
--			--	bad_data(I)	    <= bad_data(I-1);
			--end loop;



			if (bad_ccnt='1' and val_data(STG_FO-1)='1') then
				bad_data(STG_FO) <= '1';
				Sticky_Bad <= '1';
			end if;

			--tag data as bad if no '1' is found during barrell shift
			--when logger is enabled.
			if (log_en_reg='1' and val_data(STG_FO-1)='1' and
					((diag_in(1) = '0' and fnd1_hi_t='0') or (diag_in(2) = '0' and (fnd1_hi_c='0' and fnd1_lo_c='0')) ) ) then
				bad_data(STG_FO) <= '1';
				Sticky_Bad <= '1';
			end if;

            -- !debug: 30/09/2021 FBAD_Error_Bit
			if (FBAD_Error_Bit = '1' and val_data(STG_DD)='1') then
				bad_data(STG_FO) <= '1';
				Sticky_Bad <= '1';
			end if;
            
      if (powerup_cnt < 255) then
        powerup_cnt <= powerup_cnt + 1;
      end if;

      if (powerup_cnt = 254) then
        div_en <= '1';
      else
        div_en <= sync_ip;
      end if;

		end if;
	end process REG_TAG;

end PIPELINE_ARCH;
