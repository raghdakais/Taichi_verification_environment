--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
--USE ieee.std_logic_arith.all;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.std_logic_unsigned.all;
use work.channel_pack.all;
Library UNISIM;
use UNISIM.vcomponents.all;
-------------------------------------------------------------------------------

ENTITY RX_series7 IS
    Generic (
      IDLE_word      : std_logic_vector (7 downto 0):=x"B5";
	  StartWord      : std_logic_vector (7 downto 0):=x"21";
	  Stream_type1   : std_logic_vector (7 downto 0):=x"43";
	  Stream_type2   : std_logic_vector (7 downto 0):=x"DD";
	  TapWidth       : natural :=5;
	  ParallelWidth  : natural :=8;
      NumHeaderBytes : natural :=8;
	  NumDataBytes   : natural :=32;
	  NumFooterBytes : natural :=8

	  );
    PORT(
        RESET       		    : IN    std_logic;
        CLKDIV          	    : IN    std_logic;
		FCLK      		        : in    std_logic;   --serial clock input side
		channel_RDY   	        : in    std_logic;
		sDataIn                 : in    std_logic;
		IDLY_CNT  		        : out   std_logic_vector(TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count
                skip_IP_packet          : in    std_logic;          -- 09/03/2026 0x63A0 [8]
                skip_scan_header_packet : in    std_logic;          -- 09/03/2026 0x63A0 [9]
                ERR_INJ             : IN     std_logic; -- !debug: 03/03/2026 CRC error inject
		RX_det_o       	        : OUT   std_logic_vector (7 downto 0);
		start_valid             : OUT   std_logic;
		Headers_valid           : OUT   std_logic;
		data_valid              : OUT   std_logic;
		Footers_valid           : OUT   std_logic;
		IP_pckt_valid           : OUT   std_logic;
		packet_received         : OUT   std_logic;
		good_packet_received    : OUT   std_logic;
		bad_packet_received     : OUT   std_logic;
		RX_ERRs                 : OUT	std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error

    	);
END RX_series7;

ARCHITECTURE behave OF RX_series7 IS
------------------------------------------------------------------------------------------------------------------------------
    signal RX_det_sync 		        :STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);
	signal sDataInDly, FCLK_inv : std_logic;
	signal CNTVALUEIN: natural range 0 to 2**TapWidth - 1 ;
	type sm_state1 is (idle,clocks_rdy,Bit_align,set_load,pre_byte_align,byte_align,wait_st,look_for_sync,wait_for_sync,synced);
	signal sm4sync : sm_state1;
	signal Bitslip  : std_logic:='0';
	signal IDLY_LD  : std_logic:='0';  --IDELAYE2 Load
	signal IDLY_CE  : std_logic:='0';  --IDELAYE2 CE
	signal IDLY_INC : std_logic:='0';  --IDELAYE2 Tap Increment
	signal channel_RDY_stable : std_logic_vector(3 downto 0);
	signal pDataIn,pDataIn_q,pDataIn_prev  : STD_LOGIC_VECTOR (ParallelWidth-1 downto 0);
	Signal cnt_idle_byte           : natural range 0 to 7;
	constant cnt_num_byte          : natural range 0 to 7:=7;
	constant delay_num             : natural range 0 to 15:=15;
	Signal delay_cnt_byte          : natural range 0 to 15:=0;
	Signal channel_OK              : std_logic:='0';
	signal CNTVALUEIN_std          : std_logic_vector(TapWidth-1 downto 0);  --ISERDESE2 can do 1:14 at most
	signal delay_cnt               : std_logic_vector(1 downto 0):="00";
	signal change_det              : std_logic:='0';
	signal Channel_data_locked_int : std_logic:='0';
---------------------------------------------------------------------------------------
--attribute IODELAY_GROUP        : STRING;
--attribute IODELAY_GROUP of InputDelay: label is "ams_rx_in_group";
---------------------------------------------------------------------------------------
    constant IP_WORD                   : std_logic_vector (7 downto 0):=x"1B";
	SIGNAL RX_det_sync_s               : std_logic_vector (7 downto 0);
	SIGNAL RX_det_sync_ss              : std_logic_vector (7 downto 0);

	type   sm_type2                     is (Idle,w4start1,w4start2,Headers,Data_st,footers,CRC,end_werr,end_st);
	SIGNAL channel_data_sm             : sm_type2;

	SIGNAL start_valid_int             : std_logic;
	SIGNAL Headers_valid_int           : std_logic;
	SIGNAL data_valid_int              : std_logic;
	SIGNAL Footers_valid_int           : std_logic;
	SIGNAL CRC_valid_int               : std_logic;
	SIGNAL IP_pckt_valid_int		   : std_logic;
	SIGNAL crc_calc                    : std_logic_vector (15 downto 0):=x"FFFF";

	SIGNAL good_packet                 : std_logic;
	SIGNAL bad_packet                  : std_logic;
	SIGNAL IP_pckt                     : std_logic;
	SIGNAL cnt_header                  : natural range 0 to 2047;
	SIGNAL cnt_data                    : std_logic_vector (31 downto 0):=x"00000000";
	SIGNAL cnt_footer                  : natural range 0 to 2047;
	SIGNAL cnt_crc                     : natural range 0 to 3;
	signal channel_data_locked_vec	   : std_logic_vector (3 downto 0):=x"0";
	signal NumOfBytesExpected          : std_logic_vector (31 downto 0):=x"00000000";
	signal dynamic_stream              : std_logic;
-------------------------------------------------------------------------------

    signal Idle_WORD_BAD : std_logic;    --  !debug: 26/12/2022  only for debug
    signal ready2synced_cnt : natural range 0 to 2**30 := 0;

    attribute DONT_TOUCH                    : string;
    attribute DONT_TOUCH of Idle_WORD_BAD, ready2synced_cnt : signal is "true";
    attribute mark_debug                    : string;
    attribute mark_debug of Idle_WORD_BAD, ready2synced_cnt : signal is "true";
 -------------------------------------------------------------------------------------
    constant plsexpndr      : natural :=3;
    signal RXERR0_int_vec   : std_logic_vector (plsexpndr-1 downto 0);
    signal RXERR1_int_vec   : std_logic_vector (plsexpndr-1 downto 0);
	signal RXERR2_int_vec   : std_logic_vector (plsexpndr-1 downto 0);
	signal RXERR3_int_vec   : std_logic_vector (plsexpndr-1 downto 0);
	signal RX_ERRs_int	    : std_logic_vector (3 downto 0);
	signal std_error        : std_logic;

    -- debug by Tzvika 26/02/2026
    type   crc_sm			   is (idle_st,wait_crc_st); -- ES: CRC inject FSM
    SIGNAL crc_sm_sig		   : crc_sm;
    signal en_synth_crc_sig	  : std_logic:='0';
    signal ff1_module_crc_err_sim_en   : std_logic:='0';

    signal skip_ip_inject, skip_scan_header_inject, skip_ip_inj_en, skip_scan_header_inj_en : boolean := FALSE;

BEGIN
-------------------------------------------------------------------
process(RESET,CLKDIV)
	begin
		if (RESET = '1') then
			RXERR0_int_vec <= (others=>'0');
			RXERR1_int_vec <= (others=>'0');
			RXERR2_int_vec <= (others=>'0');
			RXERR3_int_vec <= (others=>'0');
			RX_ERRs_int    <= (others=>'0');
		elsif rising_edge(CLKDIV) then
		RXERR0_int_vec<=RXERR0_int_vec(RXERR0_int_vec'high-1 downto 0) & not channel_data_locked_vec(3);
			if RXERR0_int_vec > 0 then
				RX_ERRs_int(0)<='1';
			else
				RX_ERRs_int(0)<='0';
			end if;
        RXERR1_int_vec<=RXERR1_int_vec(RXERR1_int_vec'high-1 downto 0) & Idle_WORD_BAD;
			if RXERR1_int_vec > 0 then
				RX_ERRs_int(1)<='1';
			else
				RX_ERRs_int(1)<='0';
			end if;
		RXERR2_int_vec<=RXERR2_int_vec(RXERR2_int_vec'high-1 downto 0) & bad_packet;
			if RXERR2_int_vec > 0 then
				RX_ERRs_int(2)<='1';
			else
				RX_ERRs_int(2)<='0';
			end if;
		RXERR3_int_vec<=RXERR3_int_vec(RXERR3_int_vec'high-1 downto 0) & std_error;
			if RXERR2_int_vec > 0 then
				RX_ERRs_int(3)<='1';
			else
				RX_ERRs_int(3)<='0';
			end if;

		end if;
	end process;
RX_ERRs<=RX_ERRs_int;
-------------------------------------------------------------------------------
	process(RESET,CLKDIV)
	begin
		if (RESET = '1') then
			RX_det_sync_s           <=(others=>'1');
			RX_det_sync_ss          <=(others=>'1');
			channel_data_locked_vec <=(others=>'0');
		elsif rising_edge(CLKDIV) then
		    channel_data_locked_vec <=channel_data_locked_vec(2 downto 0)&channel_data_locked_int;
		    if channel_data_locked_vec(3)='1' then
				RX_det_sync_s  <= RX_det_sync;
				RX_det_sync_ss <= RX_det_sync_s;
			else
			    RX_det_sync_s  <= (others=>'1');
			    RX_det_sync_ss <= (others=>'1');
			end if;
		end if;
	end process;

	process(RESET,CLKDIV)
          variable crc_calc_v :  std_logic_vector (15 downto 0):=x"FFFF";
	begin

	    if RESET ='1' then

			channel_data_sm		<=	Idle;
			cnt_header          <=	0 ;
			cnt_data 	    	<= (others=>'0');
			cnt_footer 			<=	0 ;
			cnt_crc 			<=	0 ;

			start_valid_int		<=	'0';
			Headers_valid_int	<=	'0';
			data_valid_int 		<=	'0';
			Footers_valid_int	<=	'0';
			IP_pckt_valid_int	<=	'0';
			CRC_valid_int		<=	'0';

			good_packet			<=	'0';
			bad_packet          <=	'0';
			crc_calc			<=	x"FFFF";

			std_error           <=  '0';
			packet_received     <=  '0';
			NumOfBytesExpected  <= (others=>'0');
			dynamic_stream      <= '0';
			IP_pckt             <= '0';
            Idle_WORD_BAD <= '0';

		elsif rising_edge(CLKDIV) then

		    bad_packet	      <='0';
			good_packet       <='0';
			start_valid_int	  <='0';
			Headers_valid_int <='0';
		    data_valid_int    <='0';
			Footers_valid_int <='0';
			IP_pckt_valid_int <='0';
			CRC_valid_int     <='0';

			std_error         <='0';
			cnt_crc 	      <=0;
			packet_received   <='0';
--------------------------------------------------------------------------------------------
			if channel_data_locked_vec(3)='1' then

 				case channel_data_sm is

					When Idle       	=>
										    cnt_header 	   <= 0;
											cnt_data 	   <= (others=>'0');
											cnt_footer 	   <= 0  ;
											cnt_crc 	   <= 0  ;
											good_packet	   <= '0';
											bad_packet	   <= '0';
											crc_calc	   <= x"FFFF";
										    channel_data_sm<= w4start1;
											dynamic_stream <= '0';
											IP_pckt        <= '0';
--------------------------------------------------------------------------------------------
					when w4start1		=> 	if RX_det_sync_s=StartWord then
												channel_data_sm	<=	w4start2;
												start_valid_int	<=	'1';
												crc_calc		<=	nextCRC16_D8(RX_det_sync_s,crc_calc);
											elsif RX_det_sync_s=Idle_WORD then
                                              channel_data_sm <= w4start1;
                                              Idle_WORD_BAD <= '0';

											else
												channel_data_sm <=end_werr;
                                              Idle_WORD_BAD <= '1';

											end if;
										    dynamic_stream <= '0';
--------------------------------------------------------------------------------------------
                                  when w4start2 =>
                                          if RX_det_sync_s = IP_WORD then
                                            if (skip_ip_inject) then  -- !debug: 09/03/2026 skip IP packet
                                              IP_pckt         <= '0';
                                              channel_data_sm <= end_werr;
                                            else
                                              IP_pckt         <= '1';
                                              channel_data_sm <= Data_st;
                                              crc_calc        <= nextCRC16_D8(RX_det_sync_s, crc_calc);
                                            end if;

                                          elsif RX_det_sync_s = Stream_type1 or RX_det_sync_s = Stream_type2 then
                                            if RX_det_sync_s = Stream_type2 then
                                              dynamic_stream <= '1';
                                            else
                                              dynamic_stream <= '0';
                                            end if;
                                            start_valid_int <= '1';
                                            crc_calc        <= nextCRC16_D8(RX_det_sync_s, crc_calc);
                                            if NumHeaderBytes = 0 and NumDataBytes = 0 and NumFooterBytes = 0 then
                                              channel_data_sm <= CRC;
                                            elsif NumHeaderBytes = 0 and NumDataBytes = 0 then
                                              channel_data_sm <= Footers;
                                            elsif NumHeaderBytes = 0 then
                                              channel_data_sm <= Data_st;
                                            else
                                              if (skip_scan_header_inject) then -- !debug: 09/03/2026 skip scan header packet
                                                channel_data_sm <= end_werr;
                                              else
                                                channel_data_sm <= Headers;
                                              end if;
                                            end if;
                                          else
                                            channel_data_sm <= end_werr;
                                          end if;
--------------------------------------------------------------------------------------------------------
					when Headers 		=>  if  cnt_header>=(NumHeaderBytes-1)  then
												channel_data_sm<=Data_st;
												cnt_header<=0;
												if NumDataBytes =0 and NumFooterBytes=0 then
													channel_data_sm <= CRC;
												elsif NumDataBytes =0 then
													channel_data_sm <= Footers;
												end if;
											else
												cnt_header<=cnt_header+1;
											end if;

											if dynamic_stream='1' and cnt_header>=0 and cnt_header<=3 then
												NumOfBytesExpected<=RX_det_sync_s & NumOfBytesExpected(31 downto 8);
											end if;
											Headers_valid_int	<=	'1';
											crc_calc			<=	nextCRC16_D8(RX_det_sync_s,crc_calc);
-----------------------------------------------------------------------------------------------------------
					when Data_st		=>  if  (cnt_data>=(NumDataBytes-1) and dynamic_stream='0') or (cnt_data>=(NumOfBytesExpected-1) and dynamic_stream='1') or IP_pckt='1'  then
												cnt_data <= (others=>'0');
												dynamic_stream<='0';
												if NumFooterBytes=0 or IP_pckt='1' then
												   channel_data_sm	<= CRC	;
												else
													channel_data_sm	<=	footers;
												end if;
											else
												cnt_data<=cnt_data+1;
											end if;

											if IP_pckt='0' then
												data_valid_int<='1';
										    else
												IP_pckt_valid_int  <='1';
											end if;
											crc_calc	<=	nextCRC16_D8(RX_det_sync_s,crc_calc);

					when footers 		=>  if  cnt_footer>=(NumFooterBytes-1)  then
												channel_data_sm<=CRC;
												cnt_footer<=0;
											else
												cnt_footer<=cnt_footer+1;
											end if;
											Footers_valid_int	<=	'1';
											crc_calc			<=	nextCRC16_D8(RX_det_sync_s,crc_calc);
------------------------------------------------------------------------------------------------------------
					when CRC        	=>  if  cnt_crc=2  then
												channel_data_sm	<=	end_st;
												packet_received<='1';
												if crc_calc =x"0000" then
													good_packet	<=	'1';
													crc_calc<=x"FFFF";
												else
													channel_data_sm	<=	end_werr;
													bad_packet	<=	'1';
												end if;
											else
												cnt_crc<=cnt_crc+1;
											end if;

											if cnt_crc<2 then
                                                                                           if (en_synth_crc_sig = '1') then -- !debug: 03/03/2026 in Tzvika code - replace last byte (CRC), here broke CRC calc
                                                                                             crc_calc_v := crc_calc(15 downto 1) & "not"(crc_calc(0));
                                                                                             crc_calc<=nextCRC16_D8(RX_det_sync_s,crc_calc_v);
                                                                                           else
                                                                                             crc_calc<=nextCRC16_D8(RX_det_sync_s,crc_calc);
                                                                                           end if;
                                                                                           CRC_valid_int<='1';
											end if;
----------------------------------------------------------------------------------------------------------
					when end_werr 		=>	Idle_WORD_BAD<='0';
											good_packet		<=	'0';
											channel_data_sm	<=	end_st;
											if bad_packet='1' then
												 STD_error<='0';
											else
												 STD_error<='1';
											end if;

					when  end_st		=>	channel_data_sm	<=	Idle;

					when  others 		=>	channel_data_sm	<=	Idle;
------------------------------------------------------------------------------------------------------------
				end case;
			else
				bad_packet	      <='0';
				good_packet       <='0';
				start_valid_int	  <='0';
				Headers_valid_int <='0';
				data_valid_int    <='0';
				Footers_valid_int <='0';
				IP_pckt_valid_int <='0';
				IP_pckt           <='0';
				CRC_valid_int     <='0';

				std_error         <='0';
				cnt_crc 	      <=0;
				channel_data_sm   <=idle;
			end if;
		end if;
	end process;
----------------------------------------------------------------------------------------------------------
 start_valid            <=  start_valid_int;
 Headers_valid          <= 	Headers_valid_int;
 data_valid 	        <=  data_valid_int;
 Footers_valid 	        <= 	Footers_valid_int;
 IP_pckt_valid          <=  IP_pckt_valid_int;
 RX_det_o		        <=	RX_det_sync_ss;
 good_packet_received   <=  good_packet;
 bad_packet_received    <=  bad_packet;
 ---------------------------------------------------------------------------------------------------------
-- Delay element for phase alignment of serial data
InputDelay: IDELAYE2
   generic map (
      CINVCTRL_SEL           => "FALSE",       -- TRUE, FALSE
      DELAY_SRC              => "IDATAIN",     -- IDATAIN, DATAIN
      HIGH_PERFORMANCE_MODE  => "TRUE",        -- TRUE, FALSE
      IDELAY_TYPE            => "VAR_LOAD",    -- FIXED, VARIABLE, or VAR_LOADABLE
      IDELAY_VALUE           => 0,             -- 0 to 31
      REFCLK_FREQUENCY       => 200.0,         -- values can be range 190-210, 290-310 ,390-410
      PIPE_SEL               => "FALSE",
      SIGNAL_PATTERN         => "DATA")        -- CLOCK, DATA
   port map (
      DATAOUT                => sDataInDly,    -- Delayed signal
      DATAIN                 => '0',           -- Not used; IDATAIN instead
      C                      => CLKDIV,        -- Clock for control signals (CE,INC...)
      CE                     => IDLY_CE,
      INC                    => IDLY_INC,
      IDATAIN                => sDataIn,       -- Driven by IOB
      LD                     => IDLY_LD,
      REGRST                 => RESET,
      LDPIPEEN               => '0',
      CNTVALUEIN             => CNTVALUEIN_std,-- not used in VARIABLE mode
      CNTVALUEOUT            => IDLY_CNT,      -- current tap value
      CINVCTRL               => '0');

--Invert locally for ISERDESE2
FCLK_inv <= not FCLK;
----------------------------------------------------------
--Invert locally for ISERDESE2
FCLK_inv <= not FCLK;

DeserializerMaster: ISERDESE2
   generic map (
      DATA_RATE         => "DDR",
      DATA_WIDTH        => ParallelWidth,
      INTERFACE_TYPE    => "NETWORKING",
	  INIT_Q1           => '0',
	  INIT_Q2           => '0',
	  INIT_Q3           => '0',
	  INIT_Q4           => '0',
      DYN_CLKDIV_INV_EN => "FALSE",
      DYN_CLK_INV_EN    => "FALSE",
      NUM_CE            => 2,
      OFB_USED          => "FALSE",
      IOBDELAY          => "IFD",      -- Use input at DDLY to output the data on Q1-Q8
      SERDES_MODE       => "MASTER")
   port map (
      Q1                => pDataIn_q(0),
      Q2                => pDataIn_q(1),
      Q3                => pDataIn_q(2),
      Q4                => pDataIn_q(3),
      Q5                => pDataIn_q(4),
      Q6                => pDataIn_q(5),
      Q7                => pDataIn_q(6),
      Q8                => pDataIn_q(7),
      SHIFTOUT1         => open,       -- unused  Cascade connection to Slave ISERDES
      SHIFTOUT2         => open,       -- unused  Cascade connection to Slave ISERDES
      BITSLIP           => Bitslip,    -- 1-bit Invoke Bitslip. This can be used with any
      CE1               => '1',        -- 1-bit Clock enable input
      CE2               => '1',        -- 1-bit Clock enable input
      CLK               => FCLK,       -- Fast Source Synchronous SERDES clock from BUFIO
      CLKB              => FCLK_inv,   -- Locally inverted clock
      CLKDIV            => CLKDIV,     -- Slow clock driven by BUFR
      CLKDIVP           => '0',        -- Not used here
      D                 => '0',
      DDLY              => sDataInDly, -- 1-bit Input signal from IODELAYE1.
      RST               => RESET,       -- 1-bit Asynchronous reset only.
      SHIFTIN1          => '0',
      SHIFTIN2          => '0',
      -- unused connections
      DYNCLKDIVSEL      => '0',
      DYNCLKSEL         => '0',
      OFB               => '0',
      OCLK              => '0',
      OCLKB             => '0',
      O                 => open);      -- unregistered output of ISERDESE1

-------------------------------------------------------------
 SliceISERDES_q: for slice_count in 0 to ParallelWidth-1 generate begin
   -- This places the first data in time on the right
   pDataIn(slice_count) <= pDataIn_q(ParallelWidth-slice_count-1);
   -- pDataIn(slice_count) <= pDataIn_q(slice_count); -- 17/07/2022 Liron
  end generate SliceISERDES_q;

--idle,clocks_rdy,Bit_align,byte_align,wait_st,sync_rdy

IDLY_CE <='0'; --IDELAYE2 CE
IDLY_INC<='0'; --IDELAYE2 Tap Increment
CNTVALUEIN_std <= std_logic_vector (to_unsigned(CNTVALUEIN,CNTVALUEIN_std'length));

process (CLKDIV,RESET)
begin
	if RESET ='1' then
	Bitslip <='0';
	IDLY_LD <='0'; --IDELAYE2 Load
    channel_RDY_stable <= (others=>'0');
	channel_OK<='0';
    delay_cnt <="00";
	change_det <='0';
	cnt_idle_byte<=0;
	delay_cnt_byte<=0;
	channel_data_locked_int<='0';
	sm4sync<=idle;
	CNTVALUEIN<=0;
	pDataIn_prev<= (others=>'0');
	elsif CLKDIV'event and CLKDIV='1' then
	    IDLY_LD<='0';
		channel_RDY_stable<= channel_RDY_stable(2 downto 0) & channel_RDY;
		if channel_RDY_stable(3 downto 2) ="11" then
		   channel_OK<='1';
		else
		   channel_OK<='0';
		end if;

		-------------------------------------------------------------------------------------------------------------------
		if channel_OK='1' then
			case sm4sync is
			when idle           =>	    cnt_idle_byte<=0;
										delay_cnt_byte<=0;
										sm4sync <=clocks_rdy ;
										IDLY_LD<='1';
										CNTVALUEIN<=0;
										delay_cnt<="00";
										change_det<='0';

			when clocks_rdy     =>   	IDLY_LD<='0';
										if delay_cnt="11" then
											sm4sync<=Bit_align;
											delay_cnt<="00";
										else
											delay_cnt<=delay_cnt+1;
										end if;

			when Bit_align      =>  	IDLY_LD<='0';
										sm4sync<= set_load;
										if change_det ='0' then
											sm4sync<= wait_st;
											if CNTVALUEIN=31 then
												CNTVALUEIN<=16;
												sm4sync <= pre_byte_align;
											else
												CNTVALUEIN<= CNTVALUEIN+1;
												sm4sync<= set_load;
											end if;
										else
											sm4sync<= pre_byte_align;
											change_det <='0';
											if CNTVALUEIN< 16 then
												CNTVALUEIN<=CNTVALUEIN+16;
											else
												CNTVALUEIN<= CNTVALUEIN-16;
											end if;
										end if;
										pDataIn_prev<= pDataIn;
										delay_cnt<="00";

			when set_load       =>  	IDLY_LD<='1';
										CNTVALUEIN<=CNTVALUEIN;
										sm4sync<= wait_st;


			when wait_st   		=>	  	IDLY_LD<='0';
										delay_cnt<=delay_cnt+1;
										if delay_cnt="11" then
											sm4sync<= Bit_align;
											if pDataIn_prev = pDataIn then
												delay_cnt<="00";
												change_det <='0';
											else
												change_det <='1';
												delay_cnt<="00";
											end if;
										end if;

			when pre_byte_align =>  	if delay_cnt="00" then
											IDLY_LD<='1';
										else
											IDLY_LD<='0';
										end if;

										delay_cnt<=delay_cnt+1;
										if delay_cnt="11" then
											sm4sync<=byte_align;
											delay_cnt<="00";
										end if;

			when byte_align 	=>  	if pDataIn = IDLE_WORD then
											if (cnt_idle_byte < 7) then
											cnt_idle_byte	<=cnt_idle_byte+1;
											end if;
										else
											cnt_idle_byte	<=0;
										end if;
										if (delay_cnt_byte < 15) then
											delay_cnt_byte<=delay_cnt_byte+1;
										end if;
										if cnt_idle_byte = cnt_num_byte then

											sm4sync	<=	synced;
											delay_cnt_byte		<=	0;
											cnt_idle_byte		<=	0;

										elsif delay_cnt_byte = delay_num then

											sm4sync	<= 	look_for_sync;
											delay_cnt_byte		<=	0;
										end if;

			when look_for_sync	=>		Bitslip	<=	'1';
										sm4sync			<= 	wait_for_sync;
										channel_data_locked_int		<=	'0';

			when wait_for_sync	=>		Bitslip	<=	'0';
										if (delay_cnt_byte < 15) then
											delay_cnt_byte	<=	delay_cnt_byte+1;
										end if;
										channel_data_locked_int	<=	'0';

										if pDataIn = IDLE_WORD then
											if (cnt_idle_byte < 7) then
											cnt_idle_byte	<=cnt_idle_byte+1;
											end if;
										else
											cnt_idle_byte<=0;
										end if;

										if cnt_idle_byte=cnt_num_byte then
											sm4sync<=synced;

										elsif delay_cnt_byte = delay_num then
											sm4sync<= look_for_sync;
											delay_cnt_byte<=0;
										end if;

			when synced	        =>	    channel_data_locked_int	<='1';
										cnt_idle_byte			<=0;
										change_det              <='0';

			end case;
		else
			Bitslip <='0';
            IDLY_LD <='0';
            delay_cnt <="00";
            change_det <='0';
            cnt_idle_byte<=0;
            delay_cnt_byte<=0;
            channel_data_locked_int<='0';
            sm4sync<=idle;
            CNTVALUEIN<=0;
            pDataIn_prev<= (others=>'0');
		end if;

		--------------------------------------------------------------------------------------------------------------------
		if channel_data_locked_int ='1' then
			RX_det_sync<= pDataIn;
		else
			RX_det_sync<= (others=>'1');
		end if;

	end if;
end process;


 misc_pr: process (CLKDIV) is
   begin  -- process misc_pr
     if (CLKDIV'event and CLKDIV = '1') then  -- rising clock edge

       if (channel_RDY = '1' and channel_data_locked_int = '0') then
         if (ready2synced_cnt < 2**30) then
           ready2synced_cnt <= ready2synced_cnt + 1; -- time from channel_RDY to IP_DATAVAL_HEADER_TOP_1/RX_IP_DATAVAL_HEADER_PINS/channel_data_locked_vec_reg_n_0_[0]
         end if;
       end if;

       if (skip_IP_packet = '0') then
         skip_ip_inject <= FALSE;
         skip_ip_inj_en <= TRUE;
       elsif (skip_IP_packet = '1') then
         if (channel_data_sm = end_werr) then
           skip_ip_inject <= FALSE;
           skip_ip_inj_en <= FALSE;
         elsif (skip_ip_inj_en) then
           skip_ip_inject <= TRUE;
         end if;
       end if;

       if (skip_scan_header_packet = '0') then
         skip_scan_header_inject <= FALSE;
         skip_scan_header_inj_en <= TRUE;
       elsif (skip_scan_header_packet = '1') then
         if (channel_data_sm = end_werr) then
           skip_scan_header_inject <= FALSE;
           skip_scan_header_inj_en <= FALSE;
         elsif (skip_scan_header_inj_en) then
           skip_scan_header_inject <= TRUE;
         end if;
       end if;

     end if;
   end process misc_pr;


  -- !debug: 03/03/2026 CRC injection FSM:
  synth_crc_proc : process(CLKDIV)
  begin
    if rising_edge(CLKDIV) then
      if (RESET = '1') then
        en_synth_crc_sig          <= '0';
        ff1_module_crc_err_sim_en <= '0';
        crc_sm_sig                <= idle_st;
      else
        -------------------------------------------
        ff1_module_crc_err_sim_en <= ERR_INJ; -- ES: 0xA0105794 [0] - when SYNC channel, [1] - when BUFFER channel
        -------------------------------------------
        case crc_sm_sig is
          when idle_st =>
            en_synth_crc_sig <= '0';
            if (ERR_INJ = '1' and ff1_module_crc_err_sim_en = '0') then -- ES: ERR_INJ'rising
              crc_sm_sig <= wait_crc_st;
            else
              crc_sm_sig <= idle_st;
            end if;
          when wait_crc_st =>
            en_synth_crc_sig <= '1';    -- ES: CRC inject
            -- if (channel_data_sm_d = crc and IP = '0') then -- ES: stop CRC inject after TX FSM send packet
            if (channel_data_sm = end_st or channel_data_sm = end_werr) then -- after CRC state
              crc_sm_sig <= idle_st;
            else
              crc_sm_sig <= wait_crc_st;
            end if;

        end case;
      end if;
    end if;
  end process;


END architecture behave;
