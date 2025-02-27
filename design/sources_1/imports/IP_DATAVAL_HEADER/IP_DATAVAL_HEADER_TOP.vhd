

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity IP_DATAVAL_HEADER_TOP is
GENERIC (IP_DATA_OUT_VAL : INTEGER :=8;
         HEADER_DATA_OUT_VAL: INTEGER :=16;
         ADDR_BIT_VAL : INTEGER :=6;
         DATA_BIT_VAL : INTEGER :=16;
         NumFooterBytes : INTEGER :=11
         );
Port (
    CLK_200Mhz          : IN STD_LOGIC;
    CLK_50Mhz           : IN STD_LOGIC;
    RST                 : IN STD_LOGIC;
    sDataIn             : IN STD_LOGIC;
    Channel_RDY         : IN STD_LOGIC;
    IP_READY            : OUT STD_LOGIC;
    IP_DATA_OUT         : OUT STD_LOGIC_VECTOR(IP_DATA_OUT_VAL-1 DOWNTO 0);
    HEADER_DATA_OUT     : OUT STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);--HEADER_DATA_OUT_VAL-1 DOWNTO 0);
    --NOT USED:
    clkb                : IN STD_LOGIC;
    enb                 : IN STD_LOGIC;
    web                 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb               : IN STD_LOGIC_VECTOR(ADDR_BIT_VAL-1 DOWNTO 0);
    dinb                : IN STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);
    doutb               : OUT STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);
    rlt_address_from_sync    : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
    hd_ptr_address_from_sync : out STD_LOGIC_VECTOR(31 DOWNTO 0); -- 20/09/2023
    slice_merging_factor     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 11/10/2023
    fs_merging_factor        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    fs_sequence_counter      : out std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
    fq_stream_enable         : OUT STD_LOGIC;
    temp_Num_of_Slices       : out std_logic_vector(6 downto 0); -- 23/11/2023
    reading_number_freerun_cnt_o : out std_logic_vector(15 downto 0); -- 23/11/2023
    make_data_from_sync : out std_logic; -- 05/05/2024
    ---
    bad_packet_received : OUT   std_logic;
    RX_ERRs             : OUT	std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
 );
end IP_DATAVAL_HEADER_TOP;


architecture IP_DATAVAL_HEADER_TOP of IP_DATAVAL_HEADER_TOP is

SIGNAL  S_HEADER_DATA_OUT     :  STD_LOGIC_VECTOR(HEADER_DATA_OUT_VAL-1 DOWNTO 0);--HEADER_DATA_OUT_VAL-1 DOWNTO 0);
COMPONENT DPR_HEADER_CTRL is
generic (
         DIN_DATA_BIT_VAL : INTEGER :=8;
         ADDR_BIT_VAL : INTEGER :=6;
         DATA_BIT_VAL : INTEGER :=16  );
Port (

    CLK                 : IN STD_LOGIC;
    RST                 : IN STD_LOGIC;
    IP_Packet_valid     : IN STD_LOGIC;
    DATA_VALID          : IN STD_LOGIC;
    GOOD_PACKET_RECEIVED : IN STD_LOGIC;
    DIN                 :IN STD_LOGIC_VECTOR(DIN_DATA_BIT_VAL-1 DOWNTO 0);
    ADDRA               : OUT STD_LOGIC_VECTOR(ADDR_BIT_VAL-1 DOWNTO 0);
    DOUT                 :OUT STD_LOGIC_VECTOR(DATA_BIT_VAL-1 DOWNTO 0);
    ENA                 : OUT STD_LOGIC;
    WEA                 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
  END COMPONENT ;
  ------------------
COMPONENT IP_REG is
GENERIC (DATA_VAL : INTEGER :=8);
 Port (
    CLK                 : IN STD_LOGIC;
    RST                 : IN STD_LOGIC;
    IP_PACKET_VALID     : IN STD_LOGIC;
    GOOD_PACKET_RECEIVED : IN STD_LOGIC;
    IP_DATA_IN             : IN STD_LOGIC_VECTOR(DATA_VAL-1 DOWNTO 0);
    IP_READY               : OUT STD_LOGIC;
    IP_DATA_OUT            : OUT STD_LOGIC_VECTOR(DATA_VAL-1 DOWNTO 0)

 );
END COMPONENT ;
------------------
component RX_series7 is                                     --RX_IP_DATAVAL_HEADER IS
  generic (
    IDLE_word      : std_logic_vector (7 downto 0) := x"B5";
    StartWord      : std_logic_vector (7 downto 0) := x"21";
    Stream_type1   : std_logic_vector (7 downto 0) := x"43";
    Stream_type2   : std_logic_vector (7 downto 0) := x"DD";
    TapWidth       : natural                       := 5;
    ParallelWidth  : natural                       := 8;
    NumHeaderBytes : natural                       := 0;
    NumDataBytes   : natural                       := 128;  --64 Word of header data
    NumFooterBytes : natural                       := 0

    );
  port(
    RESET                : in  std_logic;
    CLKDIV               : in  std_logic;
    FCLK                 : in  std_logic;                     --serial clock input side
    channel_RDY          : in  std_logic;
    sDataIn              : in  std_logic;
    IDLY_CNT             : out std_logic_vector(TapWidth-1 downto 0);  --IDELAYE2 Current Tap Count
    RX_det_o             : out std_logic_vector (7 downto 0);
    start_valid          : out std_logic;
    Headers_valid        : out std_logic;
    data_valid           : out std_logic;
    Footers_valid        : out std_logic;
    IP_pckt_valid        : out std_logic;
    packet_received      : out std_logic;
    good_packet_received : out std_logic;
    bad_packet_received  : out std_logic;
    RX_ERRs              : out std_logic_vector (3 downto 0)  --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(3) '1' general st_error
    );

end component;
---------------------
COMPONENT blk_mem_gen_0 IS
  PORT (


    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 5 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 15 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 15 downto 0 );

    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 5 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 15 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 15 downto 0 )








  );

  END COMPONENT;
---------------------


signal S_RX_det_o               :  std_logic_vector (7 DOWNTO 0);
signal S_data_valid, S_FOOTER_VALID  :  std_logic;
signal S_IP_pckt_valid          :  std_logic;
signal S_good_packet_received   :  std_logic;
signal S_ADDRA                  :  std_logic_vector (5 DOWNTO 0);--  std_logic_vector (6 DOWNTO 0);
signal S_ENA                    :  std_logic;
signal S_WEA                  :  std_logic_vector (0 DOWNTO 0);
SIGNAL S_DPR_CTRL_OUT       :STD_LOGIC_VECTOR(15 DOWNTO 0);

  -- 20/03/2023
  signal reading_number_sampled      :STD_LOGIC_VECTOR(15 DOWNTO 0) := (others => '0');
  signal reading_number_err1 : std_logic := '0';
  signal data_packet_received : std_logic;
  signal s_addra_from_dpr_header_ctrl, s_addra_tmp :  std_logic_vector (5 DOWNTO 0);
  signal read_seq_cnt : natural range 0 to 15;
  signal read_seq_cnt_inc, read_seq_cnt_inc_r : boolean;
  signal s_addra_sel : std_logic;
  signal reading_number_freerun_cnt : unsigned(15 downto 0) := (others => '0');
  signal IP_READY_i               : STD_LOGIC;

  component FOOTER_CTRL is
    generic (
      DIN_DATA_BIT_VAL : INTEGER;
      ADDR_BIT_VAL     : INTEGER;
      DATA_BIT_VAL     : INTEGER;
      NumFooterBytes   : INTEGER
      );
    port (
      CLK                      : IN  STD_LOGIC;
      RST                      : IN  STD_LOGIC;
      DATA_VALID               : IN  STD_LOGIC;
      GOOD_PACKET_RECEIVED     : IN  STD_LOGIC;
      DIN                      : IN  STD_LOGIC_VECTOR(DIN_DATA_BIT_VAL-1 DOWNTO 0);
      rlt_address_from_sync    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      hd_ptr_address_from_sync : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      slice_merging_factor     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 11/10/2023
      fs_merging_factor        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      fs_sequence_counter      : out std_logic_vector(2 DOWNTO 0); -- 07/02/2024 max value: <FS Factor> - 1
      fq_stream_enable         : OUT STD_LOGIC
      );
  end component FOOTER_CTRL;


-- !debug: 18/12/2022
 SIGNAL IDLY_CNT  		    : std_logic_vector(5-1 downto 0);
 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of bad_packet_received, IDLY_CNT, reading_number_sampled, S_DPR_CTRL_OUT, reading_number_err1, S_ADDRA : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of bad_packet_received, IDLY_CNT, reading_number_sampled, S_DPR_CTRL_OUT, reading_number_err1, S_ADDRA : signal is "true";

 signal fs_sequence_counter_i : std_logic_vector(2 DOWNTO 0); -- 27/03/2024
 signal temp_Num_of_Slices_i  : std_logic_vector(6 downto 0);
 signal rlt_address_from_sync_i	 : STD_LOGIC_VECTOR(31 DOWNTO 0);
 signal hd_ptr_address_from_sync_i : STD_LOGIC_VECTOR(31 DOWNTO 0);
 signal slice_merging_factor_i	 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal fs_merging_factor_i		 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal fq_stream_enable_i		 : STD_LOGIC;

begin

RX_IP_DATAVAL_HEADER_PINS: RX_series7--RX_IP_DATAVAL_HEADER
    Generic MAP(
      IDLE_word      =>x"B5",
	  StartWord      =>x"21",
	  Stream_type1   =>x"43",
	  Stream_type2   =>x"DD",
	  TapWidth       =>5    ,
	  ParallelWidth  =>8    ,
      NumHeaderBytes =>2    , -- !debug: 08/01/2023 was 0 Tzvika: change in SYNC generics header/footer size = 2
	  NumDataBytes   =>128  ,--64 Word of header data
	  NumFooterBytes => NumFooterBytes -- !debug: 11/10/2023 0 -> 2 -> 8 -> 11

	  )
    PORT MAP(
        RESET       		   => RST,
        CLKDIV          	   => clk_50MHz,
		FCLK      		       => clk_200MHz,
		channel_RDY   	       => channel_RDY, -- !debug: ES: 02/01/2023  '1',
		sDataIn                => sDataIn,
		IDLY_CNT  		       => IDLY_CNT, -- ES: 02/01/2023
		RX_det_o       	       => S_RX_det_o,
		start_valid            => open,
		Headers_valid          => open,
		data_valid             => S_data_valid,
		Footers_valid          => S_FOOTER_VALID, -- ES: 18/09/2023
		IP_pckt_valid          => S_IP_pckt_valid,
		packet_received        => open,
		good_packet_received   => S_good_packet_received,
		bad_packet_received    =>bad_packet_received    ,
                RX_ERRs              =>RX_ERRs
     );
-------------
IP_REG_PINS: IP_REG
GENERIC MAP (DATA_VAL => 8)
 Port MAP(
    CLK                 => CLK_50Mhz                 ,
    RST                 => RST                       ,
    IP_PACKET_VALID     => S_IP_pckt_valid           ,
    GOOD_PACKET_RECEIVED => S_good_packet_received   ,
    IP_DATA_IN          => S_RX_det_o                ,
    IP_READY            => IP_READY_i                ,
    IP_DATA_OUT         => IP_DATA_OUT

 );
 -------------

DPR_HEADER_CTRL_PINS: DPR_HEADER_CTRL


GENERIC MAP(
            DIN_DATA_BIT_VAL =>8,
            ADDR_BIT_VAL=>6,
            DATA_BIT_VAL =>16  )



Port MAP(

    CLK                     =>CLK_50Mhz                     ,
    RST                     =>RST                           ,
    IP_Packet_valid         =>S_IP_pckt_valid               ,
    DATA_VALID              =>S_DATA_VALID                  ,
    GOOD_PACKET_RECEIVED    =>S_good_packet_received        ,
    ADDRA                   =>s_addra_from_dpr_header_ctrl  , -- 23/11/2023 was S_ADDRA
    DIN                    =>S_RX_det_o                     ,
    DOUT                   =>S_DPR_CTRL_OUT                 ,
    ENA                    =>S_ENA                          ,
    WEA                    =>S_WEA
    );
 ---------------


 blk_mem_gen_0_PINS: blk_mem_gen_0
  PORT MAP(
    clka =>CLK_50Mhz            ,
    ena  =>S_ENA                ,
    wea   =>  S_WEA             ,
    addra=>S_ADDRA              ,
    dina=>S_DPR_CTRL_OUT        ,
    douta=>S_HEADER_DATA_OUT    ,

    clkb =>CLK_50Mhz            ,
    enb  =>'1'                  ,
    web(0)  =>'0'               ,
    addrb=>addrb        ,
    dinb => (others=>'0')       ,
    doutb=>HEADER_DATA_OUT
  );

 ---------------


-- !debug: 20/03/2023 non-incremental reading number check
misc_test_pr: process (CLK_50Mhz) is
 begin  -- process misc_test_pr
   if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge

     if (S_WEA(0) = '1' and to_integer(unsigned(S_ADDRA)) = 8) then -- !debug: 16/04/2023 9 -> 8
       reading_number_sampled <= S_DPR_CTRL_OUT;
       if ((unsigned(reading_number_sampled) + 1) /= unsigned(S_DPR_CTRL_OUT)) then
         reading_number_err1 <= '1';
       else
         reading_number_err1 <= '0';
       end if;
     end if;

   end if;
 end process misc_test_pr;


 -- 18/09/2023
 FOOTER_CTRL_1: FOOTER_CTRL
   generic map (
     DIN_DATA_BIT_VAL => 8,
     ADDR_BIT_VAL     => 4,
     DATA_BIT_VAL     => 16,
     NumFooterBytes   => NumFooterBytes) -- !debug: 11/10/2023 11
   port map (
     CLK                      => CLK_50Mhz,
     RST                      => RST,
     DATA_VALID               => S_FOOTER_VALID,
     GOOD_PACKET_RECEIVED     => S_good_packet_received,
     DIN                      => S_RX_det_o,
     rlt_address_from_sync    => rlt_address_from_sync_i,
     hd_ptr_address_from_sync => hd_ptr_address_from_sync_i,
     slice_merging_factor => slice_merging_factor_i,
     fs_merging_factor => fs_merging_factor_i,
     fs_sequence_counter => fs_sequence_counter_i,
     fq_stream_enable => fq_stream_enable_i
   );


 get_w_from_header_pr: process (CLK_50Mhz) is
 begin  -- process get_w_from_header_pr
   if (CLK_50Mhz'event and CLK_50Mhz = '1') then  -- rising clock edge
     if (RST = '1') then                -- synchronous reset (active high)
       data_packet_received <= '0';
       read_seq_cnt <= 0;
       read_seq_cnt_inc <= FALSE;
       read_seq_cnt_inc_r <= FALSE;
       s_addra_sel <= '0';
       temp_Num_of_Slices_i <= 7UX"20";
       temp_Num_of_Slices <= 7UX"20";
       rlt_address_from_sync <= (others => '0');
       hd_ptr_address_from_sync <= (others => '0');
       slice_merging_factor <= (others => '0');
       fs_merging_factor <= (others => '0');
       fs_sequence_counter <= (others => '0');
       fq_stream_enable <= '0';
       reading_number_freerun_cnt <= (others => '0');
       reading_number_freerun_cnt_o <= (others => '0');
       make_data_from_sync <= '0';
     else

       read_seq_cnt_inc_r <= read_seq_cnt_inc;

       if (read_seq_cnt_inc) then
         read_seq_cnt <= read_seq_cnt + 1;
       end if;

       data_packet_received <= S_good_packet_received and S_WEA(0); -- 23/11/2023 Eugene Shinderman
       if (data_packet_received = '1') then
         s_addra_sel <= '1';            -- set control from this process
         read_seq_cnt <= 1;
         read_seq_cnt_inc <= TRUE;
       elsif (read_seq_cnt = 1) then
         s_addra_tmp <= std_logic_vector(to_unsigned(0,6)); -- W#1 of header
       elsif (read_seq_cnt = 2) then
         s_addra_tmp <= std_logic_vector(to_unsigned(62,6)); -- W#63 of header
       elsif (read_seq_cnt = 3) then
         s_addra_tmp <= std_logic_vector(to_unsigned(1,6)); -- W#2 of header
       elsif (read_seq_cnt = 4) then    -- 2 + latency 2
         if (S_HEADER_DATA_OUT(6 downto 0) /= 7UX"00") then
           temp_Num_of_Slices_i <= S_HEADER_DATA_OUT(6 downto 0);
         end if;
         s_addra_tmp <= std_logic_vector(to_unsigned(63,6)); -- end address
       elsif (read_seq_cnt = 5) then
         if (S_HEADER_DATA_OUT(15) = '1') then    -- 3 + latency 2
           reading_number_freerun_cnt <= '0' & unsigned(S_HEADER_DATA_OUT(14 downto 0)); -- load from header
         end if;
       elsif (read_seq_cnt = 6) then
         if (S_HEADER_DATA_OUT(4) = '1') then
           make_data_from_sync <= '1';
         else
           make_data_from_sync <= '0';
         end if;
         read_seq_cnt_inc <= FALSE;
       elsif (read_seq_cnt = 7) then
         s_addra_sel <= '0';            -- unset control from this process
         read_seq_cnt <= 0;
       end if;

       if (IP_READY_i = '1') then
         reading_number_freerun_cnt <= reading_number_freerun_cnt + 1;
       end if;

       reading_number_freerun_cnt_o <= std_logic_vector(reading_number_freerun_cnt);

       if (read_seq_cnt /= 0) then
         assert (S_WEA(0) = '0') report "Error: write to blk_mem_gen_0 not completed" severity ERROR;
       end if;


       -- if (data_packet_received = '1') then
       if (read_seq_cnt_inc_r and not read_seq_cnt_inc) then -- !debug: 04/08/2024 wait for temp_Num_of_Slices_i update
         temp_Num_of_Slices <= temp_Num_of_Slices_i;
         fs_sequence_counter <= fs_sequence_counter_i;
         rlt_address_from_sync <= rlt_address_from_sync_i;
         hd_ptr_address_from_sync <= hd_ptr_address_from_sync_i;
         slice_merging_factor <= slice_merging_factor_i;
         fs_merging_factor <= fs_merging_factor_i;
         fs_sequence_counter <= fs_sequence_counter_i;
         fq_stream_enable <= fq_stream_enable_i;
       end if;

     end if;
   end if;
 end process get_w_from_header_pr;

 S_ADDRA <= s_addra_from_dpr_header_ctrl when (s_addra_sel = '0') else s_addra_tmp;

 IP_READY <= IP_READY_i;

end IP_DATAVAL_HEADER_TOP;
