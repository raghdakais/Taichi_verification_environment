--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
USE work.Phoebe.all;
-------------------------------------------------------------------------------

ENTITY SPI_AMS_CORE IS
    GENERIC(
    	WORD_WIDTH1	: integer  := 14;
		WORD_WIDTH2	: integer  := 15
    );
    PORT(
        RESET_N       	: IN    std_logic;
        clk          	: IN    std_logic;
		EXE             : IN    std_logic;
        Address			: IN	std_logic_vector(WORD_WIDTH1-1 downto 0);
		DATA2W			: IN	std_logic_vector(WORD_WIDTH2-1 downto 0);
		RWn             : IN    std_logic;
		SYNC            : IN    std_logic;   --Rev 2, Lock up, Yonatan, 23Nov2020		
		SCLK            : OUT    std_logic;
		SDI             : OUT	std_logic;
		SDO             : IN	std_logic;
		SCSn            : OUT	std_logic;
		BUSY            : OUT	std_logic;
		READ_OUT_ready  : OUT	std_logic;
        spi_err_status  : OUT	std_logic_vector(2 downto 0);      --change to vector by Dalit 10/10/2023    --bit 0 - sdo_transaction_wait            -- 24/06/2021
        Inst_4R		    : OUT	std_logic_vector(15 downto 0);						--	Instruction for read
        DATA2R		    : OUT	std_logic_vector(WORD_WIDTH2-1 downto 0)
    );
END SPI_AMS_CORE;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
ARCHITECTURE behave OF SPI_AMS_CORE IS
-------------------------------------------------------------------------------


--	CONSTANT C_CLK_MAX_SPI          : NATURAL RANGE 0 TO 15 := 8;     --SCLK frequency is clk/C_CLK_MAX_SPI


	SIGNAL clk_cnt 	           : integer range 0 to 15;
	SIGNAL clk_cnt_pos_edge    : std_logic;
	SIGNAL clk_cnt_pos_edge_s  : std_logic;
	SIGNAL clk_cnt_pos_edge_ss : std_logic;
	SIGNAL clk_cnt_neg_edge    : std_logic;
	signal timer               : integer range 0 to 31;
	signal bit_cnt,bit_cnt_r   : integer range 0 to 16;

	SIGNAL busy_int            : std_logic;
	SIGNAL Address_d,Address_s : std_logic_vector(WORD_WIDTH1 downto 0);
	SIGNAL Instruc_s 		   : std_logic_vector(WORD_WIDTH1 downto 0);				-- instruction saved
	SIGNAL DATA2W_d			   : std_logic_vector(WORD_WIDTH2-1 downto 0);
	SIGNAL RWn_s               : std_logic;												-- save on exe read or write command

	SIGNAL parity_t,parity_r   : std_logic;
	SIGNAL now_read_turn       : std_logic;

	type   sm_type              is (idle,coordinator,init_spi,ADDR_trans,DATA_trans,ADDR_trans_r,DATA_rec,DATA_trans_rec,finish,AMS_busy,go_read);
	SIGNAL sm_spi              : sm_type			;
    SIGNAL spi_clki            : std_logic;
	SIGNAL spi_csni            : std_logic;
	SIGNAL spi_di              : std_logic;
	SIGNAL spi_do, spi_do_r    : std_logic;
	signal spi_data_read       : std_logic_vector(WORD_WIDTH2 downto 0);
--	signal spi_addr_read       : std_logic_vector(WORD_WIDTH1+1 downto 0);
	signal spi_addr_read       : std_logic_vector(15 downto 0);
	signal spi_addr_read_ready_int : std_logic;
	signal spi_data_read_ready_int : std_logic;
	signal sample : boolean;
	signal sdo_transaction_wait : std_logic; -- 24/06/2021
	-- signal sync_sample         : std_logic_vector(7 downto 0);         -- Rev2 lock up, Yonatan, 23Nov2020 
	-- signal delay_count         : std_logic_vector(11 downto 0);        -- Rev2 lock up, Yonatan, 23Nov2020 
	-- signal sync_fall_detected  : std_logic;                            -- Rev2 lock up, Yonatan, 23Nov2020 
	-- signal sampled_exe         : std_logic;                           --  Rev2 lock up, Yonatan, 24Nov2020

 attribute DONT_TOUCH                    : string;
 attribute DONT_TOUCH of DATA2R, spi_data_read, RWn_s, sm_SPI : signal is "true";
 attribute mark_debug                    : string;
 attribute mark_debug of DATA2R, spi_data_read, RWn_s, sm_SPI : signal is "true";

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
BEGIN
-------------------------------------------------------------------------------


	process(RESET_N,clk)
	begin
		if (RESET_N = '0') then

			Instruc_s 	<=(others=>'1');
			Address_d 	<=(others=>'1');
			Address_s  	<=(others=>'0');
			DATA2W_d  	<= (others=>'0');
			Inst_4R  	<= X"0AAA";
			RWn_s 		<= '1';
			sm_SPI		<=idle;
			clk_cnt		<=0;
			spi_clki  <='0';
			spi_csni  <='1';
			spi_di    <='0';
			timer	<=2;
			now_read_turn<='0';
			parity_t<='1';
			parity_r<='1';
			spi_data_read<=(others=>'0');
			spi_addr_read<= (others=>'0');
			bit_cnt_r<=0;
			bit_cnt<=0;
			busy_int<='0';
			clk_cnt_pos_edge<='0';
			clk_cnt_neg_edge<='0';
			spi_addr_read_ready_int<='0';
			spi_data_read_ready_int<='0';
			clk_cnt_pos_edge_s<='0';
			clk_cnt_pos_edge_ss<='0';
			sample<=false;
      sdo_transaction_wait <= '0';
      spi_do_r <= '0';
      spi_err_status <= (others=>'0'); --change by Dalit 10/10/2023

		elsif rising_edge(clk) then

		    spi_addr_read_ready_int<='0';
			spi_data_read_ready_int<='0';

			IF (clk_cnt = (C_CLK_MAX_SPI-1)) THEN
				clk_cnt <= 0;
			ELSE
				clk_cnt <= clk_cnt +1;
			END IF;

			IF (clk_cnt = 0) THEN
				clk_cnt_pos_edge <= '1';
			ELSE
				clk_cnt_pos_edge <= '0';
			END IF;

			IF (clk_cnt = ((C_CLK_MAX_SPI) /2)) THEN
				clk_cnt_neg_edge <= '1';
			ELSE
				clk_cnt_neg_edge <= '0';
			END IF;

		    clk_cnt_pos_edge_s<=clk_cnt_pos_edge;
			clk_cnt_pos_edge_ss<=clk_cnt_pos_edge_s;


			case sm_SPI is

			when idle =>    now_read_turn<='0';
							spi_clki  <='0';
							spi_csni  <='1';
							spi_di    <='0';
							timer<=2;
							busy_int<='0';
							parity_t<='1';
							parity_r<='1';
							bit_cnt<=0;
							sample<=false;
							if exe='1' then                                       -- Comment, Rev2 lock up, Yonatan, 24Nov2020
								Instruc_s <= Address&RWn;
								DATA2W_d <= DATA2W;
								RWn_s <= RWn;
								busy_int<='1';
                                  sm_SPI <=  init_SPI; 
							end if;
			when init_SPI =>	IF (clk_cnt_neg_edge = '1') THEN
									spi_csni <= '0';
									sm_SPI<= coordinator;
								end if;
								bit_cnt<=0;

			when coordinator =>	IF (clk_cnt_pos_edge = '1') THEN
									spi_csni 	<= '0';
									Address_d 	<= Instruc_s;

									if RWn_s='1' then
										if now_read_turn='0' then
											DATA2W_d <= "000" & X"999";
										else
											DATA2W_d <= "000" & X"666";
										end if;
									end if;

									sm_SPI<= ADDR_trans;
								end if;

								bit_cnt<=0;


			when ADDR_trans =>
								if clk_cnt_pos_edge ='1' then

									spi_clki 		<= 	'1';
									spi_addr_read	<=	spi_do & spi_addr_read(WORD_WIDTH1+1 downto 1);

								elsif clk_cnt_neg_edge ='1' then
									spi_clki    <= '0';
									Address_d <= '0'& Address_d (WORD_WIDTH1 downto 1);
									spi_di<=Address_d(0);
									parity_t <= nextCRC1_D1(Address_d(0),parity_t);

									IF (bit_cnt = 15) THEN
										sm_SPI 		<= DATA_trans_rec;
										bit_cnt 	<= 0;
										parity_t	<='1';
										spi_di		<=parity_t;
									ELSE
										bit_cnt <= bit_cnt +1;
									END IF;
								end if;


			when DATA_trans_rec =>
									if clk_cnt_pos_edge ='1' then

										spi_clki 		<= '1';
									 	spi_data_read	<=	spi_do & spi_data_read(15 downto 1);  --DEBUG!!!
									 	parity_r 		<= 	nextCRC1_D1(spi_do,parity_r);

									elsif clk_cnt_neg_edge ='1' then
										spi_clki    <= '0';
										DATA2W_d <= '0'& DATA2W_d (WORD_WIDTH2-1 downto 1);
										spi_di<=DATA2W_d(0);
										parity_t <= nextCRC1_D1(DATA2W_d(0),parity_t);

										IF (bit_cnt = 15) THEN
											sm_SPI      <= 	finish;
											spi_di		<=	parity_t;
											parity_t	<=	'1';
										ELSE
											bit_cnt <= bit_cnt +1;
										END IF;
									end if;










-- 			when ADDR_trans_r =>if clk_cnt_pos_edge ='1' then
-- 									spi_clki <= '1';
-- 									IF (bit_cnt_r = 16) THEN
-- 										sm_SPI      <= DATA_rec;
-- 										sample<=false;
-- 										parity_r<='1';
-- 										bit_cnt_r<=0;
-- 									ELSE
-- 										bit_cnt_r <= bit_cnt_r +1;
-- 									END IF;
--
-- 									if bit_cnt_r>0 then
-- 									spi_addr_read<=spi_do & spi_addr_read(WORD_WIDTH1+1 downto 1);
-- 									parity_r <= nextCRC1_D1(spi_do,parity_r);
-- 									end if;
-- 								-- elsif clk_cnt_pos_edge_ss='1' then
-- 									-- IF (bit_cnt_r = 16) THEN
-- 										-- sm_SPI      <= DATA_rec;
-- 										-- parity_r<='0';
-- 										-- bit_cnt_r<=0;
-- 									-- ELSE
-- 										-- bit_cnt_r <= bit_cnt_r +1;
-- 									-- END IF;
--
-- 									-- if bit_cnt_r>0 then
-- 									-- spi_addr_read<=spi_do & spi_addr_read(WORD_WIDTH1+1 downto 1);
-- 									-- parity_r <= nextCRC1_D1(spi_do,parity_r);
-- 									-- end if;

--
-- 								elsif clk_cnt_neg_edge ='1' then
-- 									spi_clki    <= '0';
-- 									Address_s <= '0'& Address_s (WORD_WIDTH1 downto 1);
-- 									spi_di<=Address_s(0);
-- 									parity_t <= nextCRC1_D1(Address_s(0),parity_t);
-- 									IF (bit_cnt = 15) THEN
-- 										bit_cnt<=0;
-- 										spi_di<=parity_t;
-- 										parity_t<='1';
-- 									ELSE
-- 										bit_cnt <= bit_cnt +1;
-- 									END IF;
-- 								end if;
--
-- 			when data_rec =>  	if clk_cnt_pos_edge ='1' then
-- 									spi_clki <= '1';
-- 									sample<=true;
-- 									 --spi_data_read<=SDO & spi_data_read(15 downto 1);  --DEBUG!!!
-- 									 --parity_r <= nextCRC1_D1(spi_do,parity_r);
-- -- 									 IF (bit_cnt_r = 15) THEN
-- -- 									     spi_clki <= '0';
-- -- 										 -- sm_SPI      <= finish;
-- -- 										  -- parity_r<='0';
-- -- 										  -- bit_cnt_r<=0;
-- -- 									  -- ELSE
-- -- 										  -- bit_cnt_r <= bit_cnt_r +1;
-- -- 									 END IF;
--
-- 								 elsif clk_cnt_pos_edge_s='1' and sample then
-- 									 spi_data_read<=spi_do & spi_data_read(15 downto 1);  --DEBUG!!!
-- 									 parity_r <= nextCRC1_D1(spi_do,parity_r);
-- 									 IF (bit_cnt_r = 15) THEN
-- 									    --spi_clki <= '0';
-- 										 sm_SPI      <= finish;
-- 										 parity_r<='1';
-- 										 bit_cnt_r<=0;
-- 									 ELSE
-- 										bit_cnt_r <= bit_cnt_r +1;
-- 									 END IF;
--
-- 								elsif clk_cnt_neg_edge ='1' then
-- 									spi_clki    <= '0';
-- 									DATA2W_d <= '0'& DATA2W_d (WORD_WIDTH2-1 downto 1);
-- 									spi_di<=DATA2W_d(0);
-- 									parity_t <= nextCRC1_D1(DATA2W_d(0),parity_t);
-- 									IF (bit_cnt = 15) THEN
-- 										spi_di<=parity_t;
-- 										parity_t<='1';
-- 										bit_cnt <= 0;
-- 									ELSE
-- 										bit_cnt <= bit_cnt +1;
-- 									END IF;
-- 									if bit_cnt_r=0 	 then
-- 									spi_addr_read_ready_int<='1';  --- check what about parity here
-- 									parity_r <='1';
-- 									end if;
--
-- 								end if;
--
-- 			when DATA_trans =>  if clk_cnt_pos_edge ='1' then
-- 									spi_clki <= '1';
-- 								elsif clk_cnt_neg_edge ='1' then
-- 									spi_clki    <= '0';
-- 									DATA2W_d <= '0'& DATA2W_d (WORD_WIDTH2-1 downto 1);
-- 									spi_di<=DATA2W_d(0);
-- 									parity_t <= nextCRC1_D1(DATA2W_d(0),parity_t);
-- 									IF (bit_cnt = 15) THEN
-- 										sm_SPI      <= finish;
-- 										spi_di<=parity_t;
-- 										parity_t<='1';
-- 									ELSE
-- 										bit_cnt <= bit_cnt +1;
-- 									END IF;
-- 								end if;

			when finish =>  	if clk_cnt_pos_edge ='1' then
									spi_clki <= '1';
								elsif clk_cnt_neg_edge ='1' then

									spi_clki 	<= 	'0';
									bit_cnt		<=	0;
									bit_cnt_r	<=	0;
									timer		<=	31;

									sm_SPI		<= 	AMS_busy;

									if RWn_s='1' and now_read_turn='1' then

 										spi_addr_read_ready_int	<=	'1';  								--- check what about parity here
										spi_data_read_ready_int	<=	'1';
										Inst_4R					<=	"00" & spi_addr_read(15 downto 2);						--
										DATA2R					<=	spi_data_read(15 downto 1);			--	(14 downto 0)
									end if;
								end if;


			when AMS_busy =>

								spi_data_read_ready_int	<=	spi_data_read_ready_int;

							  	if clk_cnt_pos_edge ='1' then
									spi_csni <= '1';
								end if;

								if timer=0 then
									if RWn_s='0' or (RWn_s='1' and now_read_turn='1')then
										sm_SPI	<=	idle;
									else
										sm_SPI<=go_read;
									end if;
								else
									timer<=timer-1;
								end if;

			when go_read =>  	timer	<=	31;
								bit_cnt	<=	0;

								IF (clk_cnt_neg_edge = '1')  THEN 								--	and now_read_turn<='0'

									spi_csni 		<= 	'0';
									sm_SPI			<= 	coordinator;
									now_read_turn	<=	'1';
								end if;

			when others =>
								sm_SPI	<=	idle;


			end case;

        -- 24/06/2021
        spi_do_r <= spi_do;

        if (sm_SPI	=	go_read) then
          sdo_transaction_wait <= '1'; -- 24/06/2021
        elsif (sdo_transaction_wait = '1' and spi_do_r /= spi_do) then
          sdo_transaction_wait <= '0';
        -- elsif (sm_SPI	= AMS_busy) then
        --   sdo_transaction_wait <= '0';
        end if;
        if (sm_SPI	=	finish) then
          if (RWn = '1') then
            -- if (sdo_transaction_wait = '1') then
            --   spi_err_status <= '1';
            -- else
            --   spi_err_status <= '0';
            -- end if;
            spi_err_status(0) <= sdo_transaction_wait; --change by Dalit 10/10/2023
          end if;
        end if;

		end if;
	end process;



 busy			<=	busy_int;
 SCLK			<=	spi_clki;
 SCSn			<=	spi_csni;
 SDI			<=	spi_di;
 spi_do			<=	SDO;
 READ_OUT_ready	<=	spi_data_read_ready_int;


END architecture behave;
