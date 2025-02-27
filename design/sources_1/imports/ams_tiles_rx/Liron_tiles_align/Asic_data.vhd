--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.Phoebe.all;
-------------------------------------------------------------------------------

ENTITY Asic_data IS

    PORT(
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		Phoebe_data_locked      : in    std_logic;
		Bytes_per_det           : IN    integer  range 3 to 5;
		IDLE_word		        : IN    std_logic_vector (7 downto 0);
		SYNC                    : IN    std_logic;
		Footer_optional_en      : IN    std_logic;
		RX_det_sync             : IN    std_logic_vector (7 downto 0);
		RX_det_o       	        : OUT   std_logic_vector (7 downto 0);
		start_valid             : OUT   std_logic;
		data_valid              : OUT   std_logic;
		-- Footer_valid            : OUT   std_logic;
		Footer_optional_valid   : OUT   std_logic;
		Footer_val              : OUT   std_logic_vector (6 downto 1);
		crc_error               : OUT   std_logic;
		crc_ok                   : OUT   std_logic;        --Dalit 19/9/2023
        std_error               : OUT   std_logic;
		asic_data_good_read     : OUT   std_logic -- 05/09/2023
    	);
END Asic_data;

ARCHITECTURE Asic_data_arc OF Asic_data IS

	type   sm_type                     is (Idle,w4start1,w4start2,w4start3,w4start4,w4start5,data_st,footer1,footer2,footer3,footer4,footer5,footer6,CRC,end_werr,end_st);
	SIGNAL asic_data_sm                : sm_type	;
	SIGNAL RX_det_sync_s               : std_logic_vector (7 downto 0);
	SIGNAL RX_det_sync_ss              : std_logic_vector (7 downto 0);
	SIGNAL start_valid_int             : std_logic;
	SIGNAL data_valid_int              : std_logic;
	SIGNAL Footer_valid_int            : std_logic;
	SIGNAL Footer_optional_valid_int   : std_logic;
	SIGNAL CRC_valid_int               : std_logic;
	SIGNAL cnt_data,cnt_datav          : integer range 0 to 2047;
	SIGNAL cnt_footer,cnt_footerv      : integer range 0 to 15;
	SIGNAL cnt_crc,cnt_crcv            : integer range 0 to 15;
	SIGNAL crc_calc                    : std_logic_vector (15 downto 0):=x"FFFF";
	SIGNAL good_read                   : std_logic;
	SIGNAL bad_read                    : std_logic;
    signal SYNC_sample_vec             : std_logic_vector (3 downto 0):=x"0";
	signal Footer_val_int              : std_logic_vector (6 downto 1):="000000";
	signal RX_det_sync_s_q             : std_logic_vector (7 downto 0);
	signal crc_calc_aux                : std_logic_vector (15 downto 0):=x"FFFF";
	signal crc_calc_r                  : std_logic_vector (15 downto 0):=x"FFFF";
-------------------------------------------------------------------------------

constant ParallelWidth : natural := 8;

-- 20/07/2022 inject CRC error test !TODO: remove after test
signal packet_cnt : natural range 0 to 2**14;
signal bad_packet_inj : std_logic;

attribute DONT_TOUCH : string;
attribute DONT_TOUCH of asic_data_sm, CRC_error, crc_calc, crc_calc_r, good_read, bad_read, cnt_crc, RX_det_sync_s_q : signal is "TRUE";

attribute mark_debug : string;
attribute mark_debug of asic_data_sm, CRC_error, crc_calc, crc_calc_r, good_read, bad_read, cnt_crc, RX_det_sync_s_q : signal is "TRUE";

BEGIN

SliceISERDES_q: for slice_count in 0 to ParallelWidth-1 generate begin
   -- This places the first data in time on the right
   RX_det_sync_s_q(slice_count) <= RX_det_sync_s(ParallelWidth-slice_count-1);
end generate SliceISERDES_q;
-------------------------------------------------------------------
crc_calc_aux<= crc_calc(7 downto 0) & crc_calc (15 downto 8);
-------------------------------------------------------------------
	process(RESET,CLKDIV)
	begin
		if (RESET = '1') then
			RX_det_sync_s<=(others=>'1');
			RX_det_sync_ss<=(others=>'1');
            packet_cnt <= 0;
            bad_packet_inj <= '0';
		elsif rising_edge(CLKDIV) then
			RX_det_sync_s<=RX_det_sync;
			RX_det_sync_ss<=RX_det_sync_s;

            if (asic_data_sm = w4start5) then
              packet_cnt <= (packet_cnt + 1) mod 2**14;
            end if;
            if (packet_cnt = 2**13) then
              bad_packet_inj <= '1';
            else
              bad_packet_inj <= '0';
            end if;

		end if;
	end process;

	process(RESET,CLKDIV)
	begin

	    if RESET ='1' then
			asic_data_sm		<=	Idle;
			SYNC_sample_vec     <=	x"0";
			cnt_datav 			<=	767 ;
			cnt_footerv 		<=	2 ;
			cnt_crcv 			<=	2 ;
			cnt_data 			<=	0  ;
			cnt_footer 			<=	0 ;
			cnt_crc 			<=	0 ;
			start_valid_int		<=	'0';
			data_valid_int 		<=	'0';
			Footer_valid_int	<=	'0';
			CRC_valid_int		<=	'0';
			good_read			<=	'0';
			bad_read            <=	'0';
			crc_calc			<=	x"FFFF";
			crc_calc_r          <=	x"FFFF";
			CRC_error<='0';
			std_error<='0';
			Footer_optional_valid_int	<=	'0';
		    Footer_val_int <=	(others=>'0') ;
		elsif rising_edge(CLKDIV) then

			SYNC_sample_vec<=SYNC_sample_vec(2 downto 0)&SYNC;
		    bad_read	<=	'0';
		    data_valid_int<='0';
			CRC_error<='0';
			std_error<='0';
			good_read<='0';
			Footer_val_int <= (others=>'0');
			if (SYNC_sample_vec (3 downto 2) = "01") then

				asic_data_sm		<=	Idle;
				cnt_datav 			<=	767 ;
				cnt_footerv 		<=	2 ;
				cnt_crcv 			<=	2 ;
				cnt_data 			<=	0  ;
				cnt_footer 			<=	0 ;
				cnt_crc 			<=	0 ;
				start_valid_int		<=	'0';
				data_valid_int 		<=	'0';
				Footer_valid_int	<=	'0';
				CRC_valid_int		<=	'0';
				good_read			<=	'0';

				crc_calc			<=	x"FFFF";
				Footer_optional_valid_int	<=	'0';


			else

			    start_valid_int	<=	'0';
				data_valid_int	<=	'0';
				Footer_valid_int<=	'0';
				CRC_valid_int	<=	'0';
				Footer_optional_valid_int	<=	'0';


				case asic_data_sm is

					When Idle       =>  if Phoebe_data_locked='1' then
											asic_data_sm	<=	w4start1;
										end if;

										cnt_data 	<=	0 ;
										cnt_footer 	<=	0 ;
										cnt_crc 	<=	0 ;
										good_read	<=	'0';
										crc_calc	<=	x"FFFF";
										crc_calc_r  <=	x"FFFF";

										case Bytes_per_det is
											when 3      => cnt_datav <=767    ; cnt_footerv <=2 ;cnt_crcv <=2 ;
											when 4      => cnt_datav <=1023   ; cnt_footerv <=3 ;cnt_crcv <=2 ;--3
											when 5      => cnt_datav <=1279   ; cnt_footerv <=4; cnt_crcv <=2 ;--4			-- 256 * 5 = 1280  + 2*5  + 3  = 1293,  have to be changed for footers,  was 1279
											when others => cnt_datav <=767    ; cnt_footerv <=2 ;cnt_crcv <=2 ;
										end case;


					when w4start1		=> 	if RX_det_sync_s=start_word(7 downto 0) then

												asic_data_sm	<=	w4start2;
												start_valid_int	<=	'1';
												crc_calc		<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);

											elsif RX_det_sync_s=Idle_WORD then

													asic_data_sm<=w4start1;
											else
													asic_data_sm<=end_werr;
											end if;

					when w4start2	=>	if RX_det_sync_s=start_word(15 downto 8) then
											start_valid_int	<=	'1';
											asic_data_sm	<=	w4start3;
											crc_calc		<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);
										else
											asic_data_sm<=end_werr;
										end if;

					when w4start3	=>	if RX_det_sync_s = start_word(23 downto 16) then
											start_valid_int	<=	'1';
											crc_calc		<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);

											if  Bytes_per_det = 3 then

												asic_data_sm	<=	Data_st;
												cnt_data		<=	cnt_datav;
											else
												asic_data_sm	<=	w4start4;
											end if;
										else
											asic_data_sm<=end_werr;
										end if;

					when w4start4	=>	if RX_det_sync_s=start_word(31 downto 24) then
											start_valid_int	<=	'1';
											crc_calc		<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);

											if  Bytes_per_det = 4 then

												asic_data_sm	<=	Data_st;

												cnt_data		<=	cnt_datav;
											else
												asic_data_sm	<=	w4start5;
											end if;
										else
											asic_data_sm<=end_werr;
										end if;

					when w4start5	=>	if RX_det_sync_s=start_word(39 downto 32) then
											start_valid_int	<=	'1';
											crc_calc		<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);

											asic_data_sm	<=	Data_st;

											cnt_data		<=	cnt_datav;
										else
											asic_data_sm	<=	end_werr;
										end if;


					when Data_st	=>  if  cnt_data=0  then
											asic_data_sm<=footer1;
											cnt_footer<=cnt_footerv;
										else
											cnt_data<=cnt_data-1;
										end if;
										data_valid_int<='1';

										crc_calc	<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);

					when footer1 	=>  if  cnt_footer=0  then
											asic_data_sm<=footer2;
											cnt_footer<=cnt_footerv;
										else
											cnt_footer<=cnt_footer-1;
										end if;
				                        Footer_valid_int	<=	'1';
										Footer_val_int(1)	<=	'1';
										crc_calc			<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);

					when footer2 	=> 	if Footer_optional_en='1'and cnt_footer=0  then
											asic_data_sm<=footer3;
											cnt_footer<=cnt_footerv;
											Footer_valid_int<='1';
										elsif cnt_footer=0 then
											asic_data_sm		<=		CRC;

											Footer_valid_int	<=		'0';
											cnt_crc				<=		cnt_crcv;
										else
											cnt_footer<=cnt_footer-1;
										end if;
									    Footer_valid_int<='1';
										Footer_val_int(2)	<=	'1';
									    crc_calc<=nextCRC16_D8(RX_det_sync_s_q,crc_calc);

					when footer3 	=> 	if  cnt_footer=0  then
											asic_data_sm<=footer4;
											cnt_footer<=cnt_footerv;
										else
											cnt_footer<=cnt_footer-1;
										end if;
										Footer_optional_valid_int	<=	'1';
										crc_calc	<=	nextCRC16_D8(RX_det_sync_s_q,crc_calc);
										Footer_val_int(3)	<=	'1';
					when footer4 	=>  if  cnt_footer=0  then
											asic_data_sm<=footer5;
											cnt_footer<=cnt_footerv;
										else
											cnt_footer<=cnt_footer-1;
										end if;
										Footer_optional_valid_int<='1';
										crc_calc<=nextCRC16_D8(RX_det_sync_s_q,crc_calc);
										Footer_val_int(4)	<=	'1';
					when footer5 	=>  if  cnt_footer=0  then
											asic_data_sm<=footer6;
											cnt_footer<=cnt_footerv;
										else
											cnt_footer<=cnt_footer-1;
										end if;
										Footer_optional_valid_int<='1';
										crc_calc<=nextCRC16_D8(RX_det_sync_s_q,crc_calc);
										Footer_val_int(5)	<=	'1';
					when footer6	=>  if  cnt_footer=0  then
											asic_data_sm		<=		CRC;
											cnt_crc				<=		cnt_crcv;
										else
											cnt_footer<=cnt_footer-1;
										end if;
										Footer_optional_valid_int<='1';
										crc_calc<=nextCRC16_D8(RX_det_sync_s_q,crc_calc);
										Footer_val_int(6)	<=	'1';
					when CRC        =>  if  cnt_crc=0  then
											asic_data_sm	<=	end_st;
											--if crc_calc =x"0000" then
											if (crc_calc =crc_calc_r) then --  and bad_packet_inj = '0'  !TODO: remove after test bad_packet_inj
												good_read	<=	'1';
												crc_ok      <=  '1';  --Dalit 19/9/2023
											else
											asic_data_sm	<=	end_werr;
											bad_read	<=	'1';
											end if;
										else
											cnt_crc<=cnt_crc-1;
										end if;

										if cnt_crc>cnt_crcv-2 then
											--crc_calc<=nextCRC16_D8(RX_det_sync_s,crc_calc_aux);
											crc_calc_r<=RX_det_sync_s &crc_calc_r(15 downto 8);
										end if;

									    CRC_valid_int<='1';

					when end_werr 	=>
										good_read		<=	'0';
										crc_ok          <=  '0';  --Dalit 19/9/2023
										asic_data_sm	<=	end_st;
									    if bad_read='1' then
											CRC_error<='1';
										else
											STD_error<='1';
										end if;


                  when  end_st	=>
                        crc_ok          <=  '0';  --Dalit 19/9/2023
                      if (Phoebe_data_locked= '0') then -- !debug: 10/05/2023 Eugene Shinderman
                        asic_data_sm <= Idle;
                      else
                        asic_data_sm	<=	end_st;
                      end if;

					when  others 	=>	asic_data_sm	<=	Idle;

				end case;
			end if;
		end if;
	end process;

 start_valid            <= start_valid_int;
 data_valid 	        <=  data_valid_int;
 -- Footer_valid 	        <= 	Footer_valid_int;
 RX_det_o		        <=	RX_det_sync_ss;
 Footer_optional_valid 	<= 	Footer_optional_valid_int;
 Footer_val             <= 	Footer_val_int;

 asic_data_good_read <= good_read;      -- 05/09/2023

END architecture Asic_data_arc;
