---------------------------------------------
-- Date : 01/10/2022
-- Company : Philips Medical
---------------------------------------------
-- Aothor  : Tzvika Sweetkin
---------------------------------------------
-- Block Name:tx_ctrl_serdes_wrap 
---------------------------------------------
-- simulation tool : Vivado Simulator
-- Synthesis&PnR tool : Vivado 2021.2 
-- Versions : 
-- 01/10/2022 :
-- 16/03/2023 : added signals go_wide_pulse_sig for widening go signal because of CDC and different clocks , maybe losing go signals on tx_zynq.
-- 15/06/2023: 
--              1) Added cnt for time delay between pop ip and headers sending  cnt_time_sig
--              2) Added reading cnt that not reseting each data valid DBG_READING_CNT
--              3)Added headers_ctrl_reg HEADERS_CTRL_REG
-- 10/09/2023: 
--              1) Added generic G_HEADERS when '1' connected to SYNC port and when '0' connected to BUFFER port,
--              2) Added one synced reset signal
--              3) Added registers inputs for BUFFER and footer of headears
-- Acro :

---------------------------------------------
---------------------------------------------
-- Block description:
-- Masters : CPU,RHOST
---------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
Library UNISIM;
use UNISIM.vcomponents.all;
Library xpm;
use xpm.vcomponents.all;
entity tx_ctrl_serdes_wrap is 
    generic(
        G_PARAMS_LEN                		:integer range 0 to 64:= 16;   --ip default 3msec +/-1.5usec (its count res is ACLK freq)
        G_TX_DATA_PACKET_SIZE               :std_logic_vector(32-1 downto 0 ):= x"00000020";   --header data packet bytes size is : 64*16 bits => 64*2Bytes => 128B 
        G_TX_HEADER_PACKET_SIZE             :std_logic_vector(8-1 downto 0 ):= x"08";   --header bytes number is : 8 bytes 
        G_TX_FOOTER_PACKET_SIZE             :std_logic_vector(8-1 downto 0 ):= x"08";   --footer bytes number is : 8 bytes 
        G_HEADERS             				:std_logic := '1'  ; -- sync or buffer signal
        G_RESET_POLARITY             		:std_logic := '1'   --ip default 3msec +/-1.5usec (its count res is ACLK freq)
    );
    port(
        CLK_50M             				: in std_logic := '0'; 
        CLK_100M             				: in std_logic := '0'; 
        CLK_200M             				: in std_logic := '0'; 
        ACLK             					: in std_logic := '0'; 
		INIT_DONE							: in std_logic := '0'; 	

        RESET           					: in std_logic := '0'; 

		SYNC_DEBUG_REG                      :in std_logic_vector(31 downto 0);

        NUMBER_OF_SLICES    				: in std_logic_vector(16-1 downto 0);
        MAKE_DATA        					: in std_logic := '0';
        IP_LONG          					: in std_logic := '0';
        DFS              					: in std_logic := '0';
        TX_TRI_IN           				: in std_logic := '0';
        TX_TRI_O            				: out std_logic := '0';
        TX_DATA_O           				: out std_logic := '0';

		CT_TYPE				                :in std_logic_vector(31 downto 0);
		DMS_STATUS_REG                      :in std_logic_vector(31 downto 0);
		DMS_ERROR 				            :in std_logic_vector(31 downto 0);
	 	INTEGRATION_TIME_IN_REG             :in std_logic_vector(31 downto 0);
	 	REF_CONVERTOR				        :in std_logic_vector(31 downto 0);
	 	L_DMS_TEMP				            :in std_logic_vector(31 downto 0);
	 	R_DMS_TEMP				            :in std_logic_vector(31 downto 0);
	 	FANS_SPEED_DMS_TROUBLESHOOTING      :in std_logic_vector(31 downto 0);
	 	READING_NUMBER_REG                  :in std_logic_vector(31 downto 0);	                    
	 	DETECTION_SETTING_1	                :in std_logic_vector(31 downto 0);
	 	DETECTION_SETTING_2	                :in std_logic_vector(31 downto 0);
	 	DETECTION_SETTING_3	                :in std_logic_vector(31 downto 0);
	 	DETECTION_SETTING_4	                :in std_logic_vector(31 downto 0);
	 	RESEND_COUNTER	                    :in std_logic_vector(31 downto 0);
	 	VERTICAL_COUCH_POSITION	            :in std_logic_vector(31 downto 0);
	 	HORIZONTAL_COUCH_POSITION	        :in std_logic_vector(31 downto 0);
	 	GANTRY_TILT	                        :in std_logic_vector(31 downto 0);
	 	ROTOR_ANGLE_ACQUISITION	            :in std_logic_vector(31 downto 0);
	 	ROTOR_ANGLE_DATA_SENDING	        :in std_logic_vector(31 downto 0);
	 	HW_LINES_1	                        :in std_logic_vector(31 downto 0);
	 	HW_LINES_2	                        :in std_logic_vector(31 downto 0);
	 	BAD_READING_DETAILS	                :in std_logic_vector(31 downto 0);
	 	UID_REG                             :in std_logic_vector(31 downto 0 );  
	 	SHOT_COUNTER	                    :in std_logic_vector(31 downto 0);
	 	ANGULAR_DENOMINATOR	                :in std_logic_vector(31 downto 0);
	 	TIME_STAMP_LOW	                    :in std_logic_vector(31 downto 0);
	 	TIME_STAMP_HIGH	                    :in std_logic_vector(31 downto 0);
	 	NUMBER_OF_DETECTORS	                :in std_logic_vector(31 downto 0);
	 	UTC_TIME_LSB	                    :in std_logic_vector(31 downto 0);
	 	UTC_TIME_MSB	                    :in std_logic_vector(31 downto 0);
	 	ADDR_DMS_TYPE_REG	                :in std_logic_vector(31 downto 0);
	 	CAPABILITY_BITS_H	                :in std_logic_vector(31 downto 0);
	 	TUBE_MA_COMMAND	                    :in std_logic_vector(31 downto 0);
	 	ACTUAL_TUBE_MA	                    :in std_logic_vector(31 downto 0);
	 	COLLIMATOR_1_REAR_BLADE	            :in std_logic_vector(31 downto 0);
	 	GRID_VOLTAGE_1	                    :in std_logic_vector(31 downto 0);
	 	GRID_VOLTAGE_2	                    :in std_logic_vector(31 downto 0);
	 	COLLIMATOR_2_FRONT_BLADE	        :in std_logic_vector(31 downto 0);
	 	CAPABILITY_BITS_M	                :in std_logic_vector(31 downto 0);
	 	DMS_TROUBLESHOOTING_1	            :in std_logic_vector(31 downto 0);
	 	DMS_TROUBLESHOOTING_2	            :in std_logic_vector(31 downto 0);
	 	FILAMENT_CURRENT	                :in std_logic_vector(31 downto 0);
	 	MA	                                :in std_logic_vector(31 downto 0);
	 	KV	                                :in std_logic_vector(31 downto 0);
	 	COLLIMATOR_3	                    :in std_logic_vector(31 downto 0);
	 	CAPABILITY_BITS_L	                :in std_logic_vector(31 downto 0);
	 	COLLIMATOR_4	                    :in std_logic_vector(31 downto 0);
	 	ECG	                                :in std_logic_vector(31 downto 0);
	 	DOM	                                :in std_logic_vector(31 downto 0);
	 	DATA_POINTER_0	                    :in std_logic_vector(31 downto 0);
	 	DATA_POINTER_1	                    :in std_logic_vector(31 downto 0);
	 	STAMP	                            :in std_logic_vector(31 downto 0);
		----------------------------------------------------------------------
	 	RLT_PTR_ADDRESS_REG		            :in std_logic_vector(31 downto 0);
	 	HD_PTR_ADDRESS_REG		            :in std_logic_vector(31 downto 0);
		BUF_PTR_ADDRESS                	    :in std_logic_vector(31 downto 0);
		STREAM_CTRL 	                	:in std_logic_vector(7 downto 0);
        RLT_SLICE_MERGE_FACTOR	            :in std_logic_vector(7 downto 0);
        FS_MERGE_FACTOR       	            :in std_logic_vector(7 downto 0);
        FQ_STREAM				            :in std_logic_vector(7 downto 0);
		 --------------------------------------------------------------------
		 HEADERS_CTRL_REG	                :in std_logic_vector(31 downto 0);
		 HEADERS_SAMP_TIME_REG	            :in std_logic_vector(31 downto 0);
		 DBG_READING_CNT	                :in std_logic_vector(15-1 downto 0);

		 --------------------------------------------------------------------		 
		 MASTERn_SLAVE                   	:in std_logic
    );
end entity;

architecture tx_ctrl_serdes_wrap_arch of tx_ctrl_serdes_wrap is

 		
--------------------------------------------------------------   
--------------------------------------------------------------
component TX_Zynq IS
   Generic ( IDLE_WORD      : std_logic_vector (7 downto 0) :=x"B5";			
			 StartWord      : std_logic_vector (7 downto 0) :=x"21";
			 Stream_type1   : std_logic_vector (7 downto 0) :=x"43";
			 Stream_type2   : std_logic_vector (7 downto 0) :=x"DD";
			 			 
			 NumHeaderbytes : std_logic_vector (7 downto 0) :=x"08";
             NumDatabytes   : std_logic_vector (31 downto 0):=x"00000020";
			 NumFooterbytes : std_logic_vector (7 downto 0) :=x"08"
             			 
);			 
   PORT(    
	 RESET             : IN     std_logic;    	 
     CLKDIV     	   : IN     std_logic;
	 FCLK	           : IN     std_logic;	 
	 STATn_DYN         : IN     std_logic;	-- Packet size Static = '0' Dynamic = '1'
	 GO                : IN     std_logic;
	 IP                : IN     std_logic;
	 PayloadSize       : IN     std_logic_vector (31 downto 0);
	 DATA_IN           : IN     std_logic_vector (7 downto 0);
	 RD_EMPTY          : IN     std_logic;
	 RD_CLK   	       : OUT    std_logic;
	 RD_REQ            : OUT    std_logic;
	 Tristate_i        : IN     std_logic;
	 Tristate_o        : OUT    std_logic;
	 DATA_out          : OUT	std_logic	 
   );

  end component ;
  ------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
component tx_serdes_fifo
  PORT (
    rst : IN STD_LOGIC;
    wr_clk : IN STD_LOGIC;
    rd_clk : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    rd_data_count : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_data_count : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    wr_rst_busy : OUT STD_LOGIC;
    rd_rst_busy : OUT STD_LOGIC
  );
END COMPONENT;
-- -- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- -- The following code must appear in the VHDL architecture
-- -- body. Substitute your own instance name and net names.


-- -- The following code must appear in the VHDL architecture header.

-- ------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
-- COMPONENT rx_fifo_gen_8_32
--   PORT (
--     rd_clk : IN STD_LOGIC;
--     wr_clk : IN STD_LOGIC;
--     srst : IN STD_LOGIC;
--     din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--     wr_en : IN STD_LOGIC;
--     rd_en : IN STD_LOGIC;
--     dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--     full : OUT STD_LOGIC;
--     empty : OUT STD_LOGIC;
--     wr_rst_busy : OUT STD_LOGIC;
--     rd_rst_busy : OUT STD_LOGIC
--   );
-- END COMPONENT;
-----------------------------------------------------------
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.


-- COMP_TAG_END ------ End COMPONENT Declaration ------------

------------------------------------------------------------
---------------------------State Machine--------------------
type serdes_ctrl_sm is ( 
				init_st,
				idle_st,
				push_ip_word_st, 
				push_data_sync_st, 
				push_data_buffer_st, 
				-- push_data_st, 
				pop_ip_pack_st,
				pop_static_pack_st,
				resend_real_pack_st
				);

signal tx_ctrl_sm_sig : serdes_ctrl_sm;
------------------------------------------------------------
------------------------------------------------------------
--------------------------- Signals Start ------------------
--------------------------------------------------------------------------
        signal go_wide_pulse_sig    : std_logic;
        signal tx_serdes_go_vec_sig :std_logic_vector(3 downto 0);
----------------------------------------------------------
		signal rlt_slice_merge_factor_sig	 :std_logic_vector(7 downto 0);
		signal fs_merge_factor_sig	 :std_logic_vector(7 downto 0);
		signal fq_stream_sig				 :std_logic_vector(7 downto 0);
----------------------------------------------------------
            --headers
		signal ct_type_sig  :std_logic_vector(31 downto 0);
		signal dms_status_sig  :std_logic_vector(15 downto 0);
		signal dms_error_sig  :std_logic_vector(32-1 downto 0);
		signal integration_time_reg                       : std_logic_vector(31 downto 0);
		signal ref_convertor_sig                        : std_logic_vector(31 downto 0);
		signal l_dms_temp_sig                           : std_logic_vector(31 downto 0);
		signal r_dms_temp_sig                           : std_logic_vector(31 downto 0);
		signal fans_speed_dms_troubleshooting_sig       : std_logic_vector(31 downto 0);
		signal reading_number_sig                       :std_logic_vector(31 downto 0);
		signal detection_setting_1_sig	                :std_logic_vector(31 downto 0);        
		signal detection_setting_2_sig	                :std_logic_vector(31 downto 0);        
		signal detection_setting_3_sig	                :std_logic_vector(31 downto 0);        
		signal detection_setting_4_sig	                :std_logic_vector(31 downto 0);        
		signal resend_counter_sig	                      :std_logic_vector(31 downto 0);           
		signal vertical_couch_position_sig	            :std_logic_vector(31 downto 0);      
		signal horizontal_couch_position_sig            :std_logic_vector(31 downto 0);	    
		signal gantry_tilt_sig	                          :std_logic_vector(31 downto 0);        
		signal rotor_angle_acquisition_sig	            :std_logic_vector(31 downto 0);      
		signal rotor_angle_data_sending_sig	             :std_logic_vector(31 downto 0);   
		signal hw_lines_1_sig	                        :std_logic_vector(31 downto 0);            
		signal hw_lines_2_sig	                           :std_logic_vector(31 downto 0);         
		signal bad_reading_details_sig	               :std_logic_vector(31 downto 0);         
		signal uid_reg_sig                              :std_logic_vector(32-1 downto 0);
		signal shot_counter_sig	                    :std_logic_vector(32-1 downto 0);      
		signal angular_denominator_sig	            :std_logic_vector(32-1 downto 0);        
		signal time_stamp_low_sig	                  :std_logic_vector(32-1 downto 0);      
		signal time_stamp_high_sig	                :std_logic_vector(32-1 downto 0);        
		signal number_of_detectors_sig	            :std_logic_vector(32-1 downto 0);        
		signal utc_time_lsb_sig	                    :std_logic_vector(32-1 downto 0);      
		signal utc_time_msb_sig	                    :std_logic_vector(32-1 downto 0);      
		signal addr_dms_type_reg_sig	              :std_logic_vector(32-1 downto 0);        
		signal capability_bits_h_sig	              :std_logic_vector(32-1 downto 0);        
		signal tube_ma_command_sig	                :std_logic_vector(32-1 downto 0);        
		signal actual_tube_ma_sig	                  :std_logic_vector(32-1 downto 0);      
		signal collimator_1_rear_blade_sig	        :std_logic_vector(32-1 downto 0);        
		signal grid_voltage_1_sig	                  :std_logic_vector(32-1 downto 0);      
		signal grid_voltage_2_sig	                  :std_logic_vector(32-1 downto 0);      
		signal collimator_2_front_blade_sig	        :std_logic_vector(32-1 downto 0);      
		signal capability_bits_m_sig	              :std_logic_vector(32-1 downto 0);        
		signal dms_troubleshooting_1_sig	          :std_logic_vector(32-1 downto 0);        
		signal dms_troubleshooting_2_sig	          :std_logic_vector(32-1 downto 0);        
		signal filament_current_sig	                :std_logic_vector(32-1 downto 0);      
		signal ma_sig	                              :std_logic_vector(32-1 downto 0);      
		signal kv_sig	                              :std_logic_vector(32-1 downto 0);      
		signal collimator_3_sig	                    :std_logic_vector(32-1 downto 0);      
		signal capability_bits_l_sig	              :std_logic_vector(32-1 downto 0);        
		signal collimator_4_sig	                    :std_logic_vector(32-1 downto 0);      
		signal ecg_sig	                            :std_logic_vector(32-1 downto 0);        
		signal dom_sig	                            :std_logic_vector(32-1 downto 0);        
		signal data_pointer_0_sig	                  :std_logic_vector(32-1 downto 0);      
		signal data_pointer_1_sig	                  :std_logic_vector(32-1 downto 0);      
		signal stamp_sig	                           :std_logic_vector(32-1 downto 0);                                                                                       
		signal rlt_ptr_address_reg_sig				       :std_logic_vector(32-1 downto 0);                                                                                       
		signal hd_ptr_address_reg_sig			       :std_logic_vector(32-1 downto 0);                                                                                       
		signal buf_ptr_address_sig				       :std_logic_vector(32-1 downto 0);                                                                                       
		signal stream_ctrl_sig					       :std_logic_vector(8-1 downto 0);                                                                                       
------------------------------------------------------------ 
--counters:
signal case_counter_sig 	: std_logic_vector (8-1 downto 0);                                                                           
signal st_num_sig 			: std_logic_vector (4-1 downto 0);                                                                           
signal resend_pack_cnt_sig : std_logic_vector (4-1 downto 0); 
signal rd_data_count_sig : std_logic_vector (8-1 downto 0); 
-- signal ff_rd_data_count_sig : std_logic_vector (8-1 downto 0); 
-- signal ff2_rd_data_count_sig : std_logic_vector (8-1 downto 0); 
signal int_clk_50M_cnt_sig 			:std_logic_vector (8-1 downto 0):= (others=> '0'); 
signal first_ip_sig 				:	std_logic:= '0';

------------------------------------------------------------ 
-- shift registers:
signal ip_vec_sig : std_logic_vector (24-1 downto 0);                                                                           
                                                                                                                                                  
------------------------------------------------------------
-- tx fifo:
signal tx_data_16_sig 			:	 std_logic_vector (G_PARAMS_LEN-1 downto 0);   
signal tx_fifo_data_out_8_sig 	: std_logic_vector (G_PARAMS_LEN/2-1 downto 0);   
-- signal tx_fifo_empty_100M_sig 	:std_logic_vector (8-1 downto 0);
signal tx_fifo_empty_8_sig 		:std_logic;
signal tx_fifo_full_8_sig 		:std_logic;
signal tx_fifo_rd_en_8_sig 			:std_logic:= '0';
signal tx_fifo_tx_wr_en 			:std_logic:= '0';
signal clear_rd_en_tx_fifo_sig 			:std_logic:= '0';
signal clear_flag_sig 			:std_logic:= '0';
signal tx_fifo_rd_en_mux_sig 			:std_logic:= '0';

signal empty_flag_sig		:std_logic:= '0';
signal fifo_empty_flag_sig		:std_logic:= '0';
-- serdes:
-- signal tx_fifo_go_buff_sig 			:std_logic:= '0';
-- signal tx_fifo_go_sr_sig 			:std_logic_vector (8-1 downto 0):= (others=> '0'); 
-- signal tx_fifo_ip_buff_sig 			:std_logic:= '0';
signal tx_fifo_ip_sr_sig 			:std_logic_vector (16-1 downto 0):= (others=> '0'); 
signal tx_serdes_ip_sig 			:std_logic:= '0';
signal tx_serdes_go_sig 			:std_logic:= '0';
signal int_clk_50M_sig 			:std_logic:= '0';
signal serdes_rd_req_sr_sig 			:std_logic_vector (4-1 downto 0):= (others=> '0'); 

signal tx_fifo_mux_sig 			:std_logic_vector(8-1 downto 0):=(others=> '0');
signal ff_tx_fifo_go_sig 			:std_logic:= '0';
signal ff_tx_fifo_ip_sig 			:std_logic:= '0';
signal ff_tx_fifo_mux_sig 			:std_logic_vector(8-1 downto 0):= (others=> '0');
signal sync_go_vec_sig 				:std_logic_vector(4-1 downto 0):= (others=> '0');
signal sync_ip_vec_sig 				:std_logic_vector(4-1 downto 0):= (others=> '0');	

signal sync_make_data_vec_sig		:std_logic_vector(4-1 downto 0):= (others=> '0');
signal sw_reset_tx_reg_sig		:std_logic_vector(4-1 downto 0):= (others=> '0');
signal sync_serdes_ip_sig		:std_logic_vector(4-1 downto 0):= (others=> '0');
signal ff_init_done_sig		:std_logic_vector(3-1 downto 0):= (others=> '0');
signal tri_state_en_vec_sig		:std_logic_vector(4-1 downto 0):= (others=> '0');
signal tristate_m_sig		:std_logic;
signal tristate_s_sig		:std_logic;

------------------------------------------------------------
-- error:
signal wrong_st_flag_sig 			:std_logic:= '0';

------------------------------------------------------------
signal start_cnt_time_sig       :std_logic:= '0';
signal clr_cnt_time_sig         :std_logic:= '0';
signal cnt_time_sig             :std_logic_vector (32-1 downto 0):= (others=> '0');
signal header_samp_time_reg_sig :std_logic_vector (32-1 downto 0):= (others=> '0');     
-- resets:
signal sr_reset_sig 			:std_logic_vector (4-1 downto 0):= (others=> '0');
signal lreset 			:std_logic:= '1';
signal lresetn 			:std_logic:= '0';
signal sr_reset_100M_sig 			:std_logic_vector (4-1 downto 0):= (others=> '0');
signal lreset_100M 			:std_logic:= '1';
signal lresetn_100M 			:std_logic:= '0';

attribute ASYNC_REG : string;
attribute ASYNC_REG of serdes_rd_req_sr_sig    : signal is "true";
attribute ASYNC_REG of sync_go_vec_sig    : signal is "true";
attribute ASYNC_REG of sync_ip_vec_sig    : signal is "true";
attribute ASYNC_REG of sync_serdes_ip_sig   : signal is "true";
attribute ASYNC_REG of sync_make_data_vec_sig    : signal is "true";
attribute ASYNC_REG of sw_reset_tx_reg_sig   : signal is "true";
attribute ASYNC_REG of tri_state_en_vec_sig    : signal is "true";
attribute ASYNC_REG of ff_init_done_sig   : signal is "true";


------------------------------------------------------------
--------------------------------------------------------------
--attribute DONT_TOUCH : string;
--attribute DONT_TOUCH of tx_serdes_go_sig 			: signal is "TRUE";
--attribute DONT_TOUCH of dms_status_sig 	: signal is "TRUE";
--attribute DONT_TOUCH of tx_data_16_sig 			: signal is "TRUE";
--attribute DONT_TOUCH of tx_fifo_data_out_8_sig 	: signal is "TRUE";

 
 		
begin
tx_zynq_inst:component TX_Zynq 
   Generic MAP( IDLE_WORD    => x"B5",			
			 	StartWord    => x"21",
			 	Stream_type1 => x"43",
			 	Stream_type2 => x"DD",
			 			 
			 	NumHeaderbytes => G_TX_HEADER_PACKET_SIZE,
             	NumDatabytes   => G_TX_DATA_PACKET_SIZE, --32
			 	NumFooterbytes => G_TX_FOOTER_PACKET_SIZE
             			 
	)	 
   PORT MAP(    
	 RESET            => RESET,   	 
     CLKDIV     	  => CLK_50M,
	 FCLK	          => CLK_200M ,  
	 STATn_DYN        => '0',
	 GO               => sync_go_vec_sig(2),
--     GO               => go_wide_pulse_sig,
	 IP               => sync_serdes_ip_sig(2),
	 PayloadSize      => x"00000001",
	 DATA_IN          => tx_fifo_mux_sig,

	 RD_EMPTY         => tx_fifo_empty_8_sig,
	 RD_CLK   	      => int_clk_50M_sig,
	 RD_REQ           => tx_fifo_rd_en_8_sig,
	 Tristate_i       => tristate_m_sig,
	 Tristate_o       => TX_TRI_O ,
	 DATA_out         => TX_DATA_O 
   );
    --------------------------------------------------------
	-- mux_ip_headers: muxing between IP data and Headers

	tx_fifo_mux_sig <= tx_fifo_data_out_8_sig when sync_serdes_ip_sig = x"0" else x"0" & "00" & sync_make_data_vec_sig(2) & sync_ip_vec_sig(2);
    --------------------------------------------------------
	mux_ip_headers_proc:process(CLK_50M) is
  	begin
		if rising_edge(CLK_50M) then
			if (RESET = G_RESET_POLARITY ) then
				sync_go_vec_sig 		<= (others => '0');
				sync_ip_vec_sig 		<= (others => '0');
				sync_make_data_vec_sig <= (others => '0');
			else
				sync_ip_vec_sig <= sync_ip_vec_sig(2 downto 0) &IP_LONG;
				sync_go_vec_sig <= sync_go_vec_sig(2 downto 0) &(go_wide_pulse_sig );	
				sync_serdes_ip_sig <= sync_serdes_ip_sig(2 downto 0) &tx_serdes_ip_sig;
				sync_make_data_vec_sig <= sync_make_data_vec_sig(2 downto 0) &MAKE_DATA;

			end if;
		end if;
	end process;


	-- lreset_proc:process(CLK_50M) is
	-- begin

	-- if rising_edge (CLK_50M) then 
	-- 	if (RESET = G_RESET_POLARITY ) then
	-- 		lreset <= '1';
	-- 		lresetn <= '0';
	-- 	else
	-- 		sr_reset_sig <= sr_reset_sig(2 downto 0)&'1';
	-- 		if sr_reset_sig(3) = '1' then
	-- 			lreset <= '0';
	-- 			lresetn <= '1';
	-- 		end if;
	-- 	end if;
	-- end If;
	-- end process ;
	-- lreset_100M_proc:process(CLK_100M) is
	-- begin

	-- if rising_edge (CLK_100M) then 
	-- 	if (RESET = G_RESET_POLARITY ) then
	-- 		lreset_100M <= '1';
	-- 		lresetn_100M <= '0';
	-- 	else
	-- 		sr_reset_100M_sig <= sr_reset_sig(2 downto 0)&'1';
	-- 		if sr_reset_100M_sig(3) = '1' then
	-- 			lreset_100M <= '0';
	-- 			lresetn_100M <= '1';
	-- 		end if;
	-- 	end if;
	-- end If;
	-- end process ;
  
  ------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
tx_fifo_gen_16_8_inst : tx_serdes_fifo
  PORT MAP (
    rd_clk => CLK_50M,
    wr_clk => CLK_100M,
    rst => RESET ,
    din => tx_data_16_sig,
    wr_en => tx_fifo_tx_wr_en,
    rd_en => tx_fifo_rd_en_mux_sig,
    dout => tx_fifo_data_out_8_sig,

    full => tx_fifo_full_8_sig,
    empty => tx_fifo_empty_8_sig,
	rd_data_count => rd_data_count_sig,
	wr_data_count => open,
    wr_rst_busy => open,
    rd_rst_busy => open
  );
-----------------------------------------------------------

-----------------------------------------------------------
-- INST_TAG_END ------ End INSTANTIATION Template ---------	
	sample_proc:process(CLK_100M) is 
  	begin
		if  rising_edge(CLK_100M) then
			if (RESET = G_RESET_POLARITY ) then
				ip_vec_sig <= (others => '0');
				tx_serdes_go_vec_sig <= (others => '0');
			else
			    tx_serdes_go_vec_sig <= tx_serdes_go_vec_sig(2 downto 0)&tx_serdes_go_sig;
			    go_wide_pulse_sig <= tx_serdes_go_sig or tx_serdes_go_vec_sig(0) or tx_serdes_go_vec_sig(1) ;
				ip_vec_sig <= ip_vec_sig(22 downto 0 )&IP_LONG;
			end if;
		end if;
	end process;
-----------------------------------------------------------
-- INST_TAG_END ------ End INSTANTIATION Template ---------	
	cnt_proc:process(CLK_100M) is 
  	begin
		if  rising_edge(CLK_100M) then
			if (RESET = G_RESET_POLARITY ) then
                cnt_time_sig <= (others => '0');
			else
                if (start_cnt_time_sig = '1') then
                    cnt_time_sig <= std_logic_vector(unsigned(cnt_time_sig)+"1");
                elsif (clr_cnt_time_sig = '1') then
                    cnt_time_sig <= (others => '0');
                else
                    cnt_time_sig <= cnt_time_sig;
                end if;
			end if;
		end if;
	end process;
-- INST_TAG_END ------ End INSTANTIATION Template ---------	
-----------------------------------------------------------
	create_empty_proc:process(CLK_50M) is 
  	begin
		if  rising_edge(CLK_50M) then
			if (RESET = G_RESET_POLARITY ) then
				fifo_empty_flag_sig <= '0';
			else
				if (rd_data_count_sig = x"00") then
					fifo_empty_flag_sig <= '1';
				else 
					fifo_empty_flag_sig <= '0';
				end if;
			end if;
		end if;
	end process;
-----------------------------------------------------------
-----------------------------------------------------------
	xpm_cdc_empty_reg : xpm_cdc_single
	generic map (
	   DEST_SYNC_FF => 4,   -- DECIMAL; range: 2-10
	   INIT_SYNC_FF => 0,   -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
	   SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
	   SRC_INPUT_REG => 1   -- DECIMAL; 0=do not register input, 1=register input
	)
	port map (
	   dest_out => empty_flag_sig, -- 1-bit output: src_in synchronized to the destination clock domain. This output
							 -- is registered.
 
	   dest_clk => CLK_100M, -- 1-bit input: Clock signal for the destination clock domain.
	   src_clk => CLK_50M,   -- 1-bit input: optional; required when SRC_INPUT_REG = 1
	   src_in => fifo_empty_flag_sig        -- 1-bit input: Input signal to be synchronized to dest_clk domain.
	);
-----------------------------------------------------------
-----------------------------------------------------------
	lat_params_proc:process(CLK_100M) is 
  	begin
		if  rising_edge(CLK_100M) then
			if (RESET = G_RESET_POLARITY ) then
				ct_type_sig  						  <= (others => '0');            	
				dms_status_sig  					  <= (others => '0');            		
				dms_error_sig  						  <= (others => '0');            	
				integration_time_reg            	  <= (others => '0');            	  
				ref_convertor_sig               	  <= (others => '0');            	  
				l_dms_temp_sig                  	  <= (others => '0');            	  
				r_dms_temp_sig                  	  <= (others => '0');            	  
				fans_speed_dms_troubleshooting_sig    <= (others => '0');          
				reading_number_sig                    <= (others => '0');          
				detection_setting_1_sig	              <= (others => '0');         
				detection_setting_2_sig	              <= (others => '0');         
				detection_setting_3_sig	              <= (others => '0');         
				detection_setting_4_sig	              <= (others => '0');         
				resend_counter_sig	                  <= (others => '0');         
				vertical_couch_position_sig	          <= (others => '0');         
				horizontal_couch_position_sig         <= (others => '0');                          
				gantry_tilt_sig	                      <= (others => '0');                         
				rotor_angle_acquisition_sig	          <= (others => '0');                         
				rotor_angle_data_sending_sig	      <= (others => '0');                             
				hw_lines_1_sig	                      <= (others => '0');                         
				hw_lines_2_sig	                      <= (others => '0');                         
				bad_reading_details_sig	              <= (others => '0');                         
				uid_reg_sig                           <= (others => '0');                          
				shot_counter_sig	                  <= (others => '0');                             
				angular_denominator_sig	              <= (others => '0');                         
				time_stamp_low_sig	                  <= (others => '0');                         
				time_stamp_high_sig	                  <= (others => '0');                         
				number_of_detectors_sig	              <= (others => '0');                         
				utc_time_lsb_sig	                  <= (others => '0');                             
				utc_time_msb_sig	                  <= (others => '0');                             
				addr_dms_type_reg_sig	              <= (others => '0');                         
				capability_bits_h_sig	              <= (others => '0');                         
				tube_ma_command_sig	                  <= (others => '0');                         
				actual_tube_ma_sig	                  <= (others => '0');                         
				collimator_1_rear_blade_sig	          <= (others => '0');                         
				grid_voltage_1_sig	                  <= (others => '0');                         
				grid_voltage_2_sig	                  <= (others => '0');                         
				collimator_2_front_blade_sig	      <= (others => '0');                             
				capability_bits_m_sig	              <= (others => '0');                         
				dms_troubleshooting_1_sig	          <= (others => '0');                         
				dms_troubleshooting_2_sig	          <= (others => '0');                         
				filament_current_sig	              <= (others => '0');                             
				ma_sig	                              <= (others => '0');                         
				kv_sig	                              <= (others => '0');                         
				collimator_3_sig	                  <= (others => '0');                             
				capability_bits_l_sig	              <= (others => '0');                         
				collimator_4_sig	                  <= (others => '0');                             
				ecg_sig	                              <= (others => '0');                         
				dom_sig	                              <= (others => '0');                         
				data_pointer_0_sig	                  <= (others => '0');                         
				data_pointer_1_sig	                  <= (others => '0');                                                     
				stamp_sig	                          <= (others => '0');                              
				rlt_ptr_address_reg_sig			          <= (others => '0');                              
				hd_ptr_address_reg_sig		          <= (others => '0');                              
				buf_ptr_address_sig			          <= (others => '0');                              
				stream_ctrl_sig				          <= (others => '0');                              
				rlt_slice_merge_factor_sig	          <= (others => '0');                              
				fs_merge_factor_sig			          <= (others => '0');                              
				fq_stream_sig				          <= (others => '0');                                                         
---------------------------------------
			else
				if (ip_vec_sig(1)= '1' and ip_vec_sig(2) = '0' ) then	--sample data from resend block
					rlt_ptr_address_reg_sig					  	<= RLT_PTR_ADDRESS_REG				;
					hd_ptr_address_reg_sig				  	<= HD_PTR_ADDRESS_REG			;	
					buf_ptr_address_sig					  <= BUF_PTR_ADDRESS 		;
					stream_ctrl_sig						  <= STREAM_CTRL(8-1 downto 0) 			;		
				else
					rlt_ptr_address_reg_sig						<= rlt_ptr_address_reg_sig		;
					hd_ptr_address_reg_sig					<= hd_ptr_address_reg_sig	;
					buf_ptr_address_sig					<= buf_ptr_address_sig	;
					stream_ctrl_sig						<= stream_ctrl_sig	;
				end if;
				if (std_logic_vector(unsigned(cnt_time_sig)) = std_logic_vector(unsigned(header_samp_time_reg_sig))) then					
				    ct_type_sig  					      <= CT_TYPE				              ;    
					dms_status_sig  				      <= DMS_STATUS_REG(15 downto 0)                    ;    	
					dms_error_sig  					      <= DMS_ERROR 				          ;    
					integration_time_reg                  <= INTEGRATION_TIME_IN_REG         ;      
					ref_convertor_sig                     <= REF_CONVERTOR				      ;      
					l_dms_temp_sig                        <= L_DMS_TEMP				          ;      
					r_dms_temp_sig                        <= R_DMS_TEMP				          ;      
					fans_speed_dms_troubleshooting_sig    <= FANS_SPEED_DMS_TROUBLESHOOTING    ;
					reading_number_sig                    <= READING_NUMBER_REG                ;         
					detection_setting_1_sig	              <= DETECTION_SETTING_1	              ;        
					detection_setting_2_sig	              <= DETECTION_SETTING_2	              ;        
					detection_setting_3_sig	              <= DETECTION_SETTING_3	              ;        
					detection_setting_4_sig	              <= DETECTION_SETTING_4	              ;        
					resend_counter_sig	                  <= RESEND_COUNTER	                  ;        
					vertical_couch_position_sig	          <= VERTICAL_COUCH_POSITION	          ;        
					horizontal_couch_position_sig         <= HORIZONTAL_COUCH_POSITION	      ;         
					gantry_tilt_sig	                      <= GANTRY_TILT	                      ;        
					rotor_angle_acquisition_sig	          <= ROTOR_ANGLE_ACQUISITION	          ;        
					rotor_angle_data_sending_sig	      <= ROTOR_ANGLE_DATA_SENDING	      ;            
					hw_lines_1_sig	                      <= HW_LINES_1	                      ;        
					hw_lines_2_sig	                      <= HW_LINES_2	                      ;        
					bad_reading_details_sig	              <= BAD_READING_DETAILS	              ;        
					uid_reg_sig                           <= UID_REG                           ;         
					shot_counter_sig	                  <= SHOT_COUNTER	                  ;            
					angular_denominator_sig	              <= ANGULAR_DENOMINATOR	              ;        
					time_stamp_low_sig	                  <= TIME_STAMP_LOW	                  ;        
					time_stamp_high_sig	                  <= TIME_STAMP_HIGH	                  ;        
					number_of_detectors_sig	              <= NUMBER_OF_DETECTORS	              ;        
					utc_time_lsb_sig	                  <= UTC_TIME_LSB	                  ;            
					utc_time_msb_sig	                  <= UTC_TIME_MSB	                  ;            
					addr_dms_type_reg_sig	              <= ADDR_DMS_TYPE_REG	              ;        
					capability_bits_h_sig	              <= CAPABILITY_BITS_H	              ;        
					tube_ma_command_sig	                  <= TUBE_MA_COMMAND	                  ;        
					actual_tube_ma_sig	                  <= ACTUAL_TUBE_MA	                  ;        
					collimator_1_rear_blade_sig	          <= COLLIMATOR_1_REAR_BLADE	          ;        
					grid_voltage_1_sig	                  <= GRID_VOLTAGE_1	                  ;        
					grid_voltage_2_sig	                  <= GRID_VOLTAGE_2	                  ;        
					collimator_2_front_blade_sig	      <= COLLIMATOR_2_FRONT_BLADE	      ;            
					capability_bits_m_sig	              <= CAPABILITY_BITS_M	              ;        
					dms_troubleshooting_1_sig	          <= DMS_TROUBLESHOOTING_1	          ;        
					dms_troubleshooting_2_sig	          <= DMS_TROUBLESHOOTING_2	          ;        
					filament_current_sig	              <= FILAMENT_CURRENT	              ;            
					ma_sig	                              <= MA	                              ;        
					kv_sig	                              <= KV	                              ;        
					collimator_3_sig	                  <= COLLIMATOR_3	                  ;            
					capability_bits_l_sig	              <= CAPABILITY_BITS_L	              ;        
					collimator_4_sig	                  <= COLLIMATOR_4	                  ;            
					ecg_sig	                              <= ECG	                              ;        
					dom_sig	                              <= DOM	                              ;        
					data_pointer_0_sig	                  <= DATA_POINTER_0	                  ;        
					data_pointer_1_sig	                  <= DATA_POINTER_1	                  ;        
					stamp_sig	                          <= STAMP	                          ;	
					fs_merge_factor_sig					<= FS_MERGE_FACTOR	;	
					rlt_slice_merge_factor_sig			<= RLT_SLICE_MERGE_FACTOR	;	
					fq_stream_sig						<= FQ_STREAM				;	
					-- rlt_address_reg_sig					  <= RLT_ADDRESS_REG				;
					-- hd_ptr_address_reg_sig				  <= HD_PTR_ADDRESS_REG			;	
				else
					ct_type_sig  					   <=ct_type_sig  					    ;
					dms_status_sig  				   <=dms_status_sig  				    ;
					dms_error_sig  					   <=dms_error_sig  					    ;
					integration_time_reg               <=integration_time_reg                ;
					ref_convertor_sig                  <=ref_convertor_sig                   ;
					l_dms_temp_sig                     <=l_dms_temp_sig                      ;
					r_dms_temp_sig                     <=r_dms_temp_sig                      ;
					fans_speed_dms_troubleshooting_sig <=fans_speed_dms_troubleshooting_sig  ;
					reading_number_sig                 <=reading_number_sig                  ;
					detection_setting_1_sig	           <=detection_setting_1_sig	            ;
					detection_setting_2_sig	           <=detection_setting_2_sig	            ;
					detection_setting_3_sig	           <=detection_setting_3_sig	            ;
					detection_setting_4_sig	           <=detection_setting_4_sig	            ;
					resend_counter_sig	               <=resend_counter_sig	                ;
					vertical_couch_position_sig	       <=vertical_couch_position_sig	        ;
					horizontal_couch_position_sig      <=horizontal_couch_position_sig       ;
					gantry_tilt_sig	                   <=gantry_tilt_sig	                    ;
					rotor_angle_acquisition_sig	       <=rotor_angle_acquisition_sig	        ;
					rotor_angle_data_sending_sig	   <=rotor_angle_data_sending_sig	    ;
					hw_lines_1_sig	                   <=hw_lines_1_sig	                    ;
					hw_lines_2_sig	                   <=hw_lines_2_sig	                    ;
					bad_reading_details_sig	           <=bad_reading_details_sig	            ;
					uid_reg_sig                        <=uid_reg_sig                         ;
					shot_counter_sig	               <=shot_counter_sig	                ;
					angular_denominator_sig	           <=angular_denominator_sig	            ;
					time_stamp_low_sig	               <=time_stamp_low_sig	                ;
					time_stamp_high_sig	               <=time_stamp_high_sig	                ;
					number_of_detectors_sig	           <=number_of_detectors_sig	            ;
					utc_time_lsb_sig	               <=utc_time_lsb_sig	                ;
					utc_time_msb_sig	               <=utc_time_msb_sig	                ;
					addr_dms_type_reg_sig	           <=addr_dms_type_reg_sig	            ;
					capability_bits_h_sig	           <=capability_bits_h_sig	            ;
					tube_ma_command_sig	               <=tube_ma_command_sig	                ;
					actual_tube_ma_sig	               <=actual_tube_ma_sig	                ;
					collimator_1_rear_blade_sig	       <=collimator_1_rear_blade_sig	        ;
					grid_voltage_1_sig	               <=grid_voltage_1_sig	                ;
					grid_voltage_2_sig	               <=grid_voltage_2_sig	                ;
					collimator_2_front_blade_sig	   <=collimator_2_front_blade_sig	    ;
					capability_bits_m_sig	           <=capability_bits_m_sig	            ;
					dms_troubleshooting_1_sig	       <=dms_troubleshooting_1_sig	        ;
					dms_troubleshooting_2_sig	       <=dms_troubleshooting_2_sig	        ;
					filament_current_sig	           <=filament_current_sig	            ;
					ma_sig	                           <=ma_sig	                            ;
					kv_sig	                           <=kv_sig	                            ;
					collimator_3_sig	               <=collimator_3_sig	                ;
					capability_bits_l_sig	           <=capability_bits_l_sig	            ;
					collimator_4_sig	               <=collimator_4_sig	                ;
					ecg_sig	                           <=ecg_sig	                            ;
					dom_sig	                           <=dom_sig	                            ;
					data_pointer_0_sig	               <=data_pointer_0_sig	                ;
					data_pointer_1_sig	               <=data_pointer_1_sig	                ;
					stamp_sig	                       <=stamp_sig	                        ;
					fs_merge_factor_sig			<= 					fs_merge_factor_sig	;
					rlt_slice_merge_factor_sig	<= 					rlt_slice_merge_factor_sig	;
					fq_stream_sig				<= 					fq_stream_sig	;	
					-- rlt_address_reg_sig					<= rlt_address_reg_sig			;
					-- hd_ptr_address_reg_sig				<= hd_ptr_address_reg_sig		;

				end if;
			end if;
		end if;
	end process;
	-- critical path : check luts
	tx_fifo_rd_en_mux_sig <=clear_rd_en_tx_fifo_sig or tx_fifo_rd_en_8_sig;

	clear_fifo_proc:process(CLK_50M) is
  	begin
		if rising_edge(CLK_50M) then
			if (RESET = G_RESET_POLARITY ) then
				clear_rd_en_tx_fifo_sig <= '0';
				int_clk_50M_cnt_sig <= (others => '0');
			else
				int_clk_50M_cnt_sig <= std_logic_vector(unsigned(int_clk_50M_cnt_sig)+ "1");
				if (clear_flag_sig = '1' ) then
					clear_rd_en_tx_fifo_sig <= '1';
				else
					clear_rd_en_tx_fifo_sig <= '0';
				end if;
			end if;
		end if;
  	end process;
  	
	fifo_wr_proc:process(CLK_100M) is
	begin

		if  rising_edge(CLK_100M) then
			if (RESET = G_RESET_POLARITY ) then
				case_counter_sig <= (others => '0');
				resend_pack_cnt_sig <= (others => '0');
				-- serdes:
				tx_serdes_ip_sig <='0';
				tx_serdes_go_sig <= '0';
				serdes_rd_req_sr_sig <=  (others => '0');
				ff_init_done_sig <=  (others => '0');
				st_num_sig <=  (others => '0');
				-- tx fifo:
				-- tx_fifo_empty_100M_sig <=  (others => '0');
				
				tx_data_16_sig <= (others => '0');
				
				tx_fifo_tx_wr_en <= '0';
				clear_flag_sig <= '0';
				-----------------------------
				start_cnt_time_sig  <= '0';
                clr_cnt_time_sig    <= '0';
				-- sm:
				tx_ctrl_sm_sig <= init_st;
			else
	---------------------------------------------------------
				-- tx_serdes_ip_sig <='0';
				tx_serdes_go_sig <= '0';
				tx_fifo_tx_wr_en <= '0';
				st_num_sig <= x"0";
	---------------------------------------------------------
				-- tx_fifo_empty_100M_sig <= tx_fifo_empty_100M_sig(6 downto 0)&tx_fifo_empty_8_sig;
				ff_init_done_sig <= ff_init_done_sig(1 downto 0)&INIT_DONE;
				serdes_rd_req_sr_sig <= serdes_rd_req_sr_sig(2 downto 0)&tx_fifo_rd_en_8_sig;

	---------------------------------------------------------
				case tx_ctrl_sm_sig is
					when init_st => 
						st_num_sig <= x"1";
						-- 	tx_ctrl_sm_sig <= init_st;
						if (ff_init_done_sig(2) = '1') then 
							tx_ctrl_sm_sig <= idle_st;
						else
							tx_ctrl_sm_sig <= init_st;
						end if;
					when idle_st =>
						st_num_sig <= x"2";
						if (ip_vec_sig(1)= '1' and ip_vec_sig(2) = '0' and G_HEADERS = '1') then
							-- tx_ctrl_sm_sig <= push_ip_word_st;
							tx_ctrl_sm_sig <= pop_ip_pack_st;
							tx_serdes_go_sig <= '1';
							tx_serdes_ip_sig <='1';
							header_samp_time_reg_sig <= HEADERS_SAMP_TIME_REG;
						elsif (ip_vec_sig(1)= '1' and ip_vec_sig(2) = '0' and G_HEADERS = '0') then
							tx_ctrl_sm_sig <= push_data_buffer_st;
						else
							tx_ctrl_sm_sig <= idle_st;
						end if;

					when pop_ip_pack_st => 
						st_num_sig <= x"3";

                        if (std_logic_vector(unsigned(cnt_time_sig)) = std_logic_vector(unsigned(header_samp_time_reg_sig)) and resend_pack_cnt_sig = x"1") then
--                        if (std_logic_vector(unsigned(cnt_time_sig)) = x"00000003") then							
                            -- tx_ctrl_sm_sig <= is_debug_st;
                            tx_ctrl_sm_sig <= resend_real_pack_st;
							start_cnt_time_sig <= '0';
                        	clr_cnt_time_sig <= '1';
						elsif (std_logic_vector(unsigned(cnt_time_sig)) = x"0000000f" and resend_pack_cnt_sig /= x"1") then
							tx_ctrl_sm_sig <= resend_real_pack_st;
							start_cnt_time_sig <= '0';
                        	clr_cnt_time_sig <= '1';
						else
							tx_ctrl_sm_sig <= pop_ip_pack_st;
							start_cnt_time_sig <= '1';
							clr_cnt_time_sig <= '0';
						
						end if;
					when push_data_sync_st => 
						st_num_sig <= x"6";
						case_counter_sig <= std_logic_vector(unsigned(case_counter_sig)+ "1");
						tx_fifo_tx_wr_en <= '1';
						case case_counter_sig is --send here latched signals								
								when x"00" =>  tx_data_16_sig <= x"ba5e"; -- header					 
								when x"01" =>  tx_data_16_sig <= ct_type_sig(7 downto 0)& ct_type_sig(15 downto 8); 					 
								when x"02" =>  tx_data_16_sig <= dms_status_sig(7 downto 0)&dms_status_sig(15 downto 8);  				 
								when x"03" =>  tx_data_16_sig <= dms_error_sig(7 downto 0)&dms_error_sig(15 downto 8);  					 
								when x"04" =>  tx_data_16_sig <= integration_time_reg(7 downto 0)&integration_time_reg(15 downto 8);            
								when x"05" =>  tx_data_16_sig <= ref_convertor_sig(7 downto 0)&ref_convertor_sig(15 downto 8);               
								when x"06" =>  tx_data_16_sig <= l_dms_temp_sig(7 downto 0)&    l_dms_temp_sig(15 downto 8);                  
								when x"07" =>  tx_data_16_sig <= r_dms_temp_sig(7 downto 0)&    r_dms_temp_sig(15 downto 8);                  
								when x"08" =>  tx_data_16_sig <= fans_speed_dms_troubleshooting_sig(7 downto 0)&fans_speed_dms_troubleshooting_sig(15 downto 8);
								when x"09" =>  tx_data_16_sig <= reading_number_sig(7 downto 0)&reading_number_sig(15 downto 8);               
								when x"0a" =>  tx_data_16_sig <= reading_number_sig(23 downto 16)&reading_number_sig(31 downto 24);  	         
								when x"0b" =>  tx_data_16_sig <= detection_setting_1_sig(7 downto 0)&detection_setting_1_sig(15 downto 8);	         
								when x"0c" =>  tx_data_16_sig <= detection_setting_2_sig(7 downto 0)&detection_setting_2_sig(15 downto 8);	         
								when x"0d" =>  tx_data_16_sig <= detection_setting_3_sig(7 downto 0)&detection_setting_3_sig(15 downto 8);	         
								when x"0e" =>  tx_data_16_sig <= detection_setting_4_sig(7 downto 0)&detection_setting_4_sig(15 downto 8);            
								when x"0f" =>  tx_data_16_sig <= resend_counter_sig(7 downto 0)&resend_counter_sig(15 downto 8)	 ;
								when x"10" =>  tx_data_16_sig <= vertical_couch_position_sig(7 downto 0)&vertical_couch_position_sig(15 downto 8);	        
								when x"11" =>  tx_data_16_sig <= horizontal_couch_position_sig(7 downto 0)&horizontal_couch_position_sig(15 downto 8);                 
								when x"12" =>  tx_data_16_sig <= gantry_tilt_sig(7 downto 0)& gantry_tilt_sig(15 downto 8);	                 
								when x"13" =>  tx_data_16_sig <= rotor_angle_acquisition_sig(7 downto 0)&rotor_angle_acquisition_sig(15 downto 8);	     
								when x"14" =>  tx_data_16_sig <= rotor_angle_data_sending_sig(7 downto 0)&rotor_angle_data_sending_sig(15 downto 8)	 ;
								when x"15" =>  tx_data_16_sig <= hw_lines_1_sig(7 downto 0)&hw_lines_1_sig(15 downto 8);	                     
								when x"16" =>  tx_data_16_sig <= hw_lines_2_sig(7 downto 0)&hw_lines_2_sig(15 downto 8);tx_serdes_ip_sig <='0';tx_serdes_go_sig <= '1';	                 
								when x"17" =>  tx_data_16_sig <= x"0000";
								when x"18" =>  tx_data_16_sig <= bad_reading_details_sig(7 downto 0)& bad_reading_details_sig(15 downto 8);
								when x"19" =>  tx_data_16_sig <= uid_reg_sig(7 downto 0)& uid_reg_sig(15 downto 8);
								when x"1a" =>  tx_data_16_sig <= shot_counter_sig(7 downto 0)& shot_counter_sig(15 downto 8);
								when x"1b" =>  tx_data_16_sig <= x"0000";
								when x"1c" =>  tx_data_16_sig <= angular_denominator_sig(7 downto 0)&angular_denominator_sig(15 downto 8);
								when x"1d" =>  tx_data_16_sig <= time_stamp_low_sig(7 downto 0)&time_stamp_low_sig(15 downto 8);
								when x"1e" =>  tx_data_16_sig <= time_stamp_high_sig(7 downto 0)&time_stamp_high_sig(15 downto 8);
								when x"1f" =>  tx_data_16_sig <= number_of_detectors_sig(7 downto 0)&number_of_detectors_sig(15 downto 8);
								when x"20" =>  tx_data_16_sig <= utc_time_lsb_sig(7 downto 0)&utc_time_lsb_sig(15 downto 8);   
								when x"21" =>  tx_data_16_sig <= utc_time_lsb_sig(23 downto 16)&utc_time_lsb_sig(31 downto 24);   
								when x"22" =>  tx_data_16_sig <= utc_time_msb_sig(7 downto 0)&utc_time_msb_sig(15 downto 8); 
								when x"23" =>  tx_data_16_sig <= utc_time_msb_sig(23 downto 16)&utc_time_msb_sig(31 downto 24); 
								when x"24" =>  tx_data_16_sig <= x"0000";
								when x"25" =>  tx_data_16_sig <= x"0000";              
								when x"26" =>  tx_data_16_sig <= addr_dms_type_reg_sig(7 downto 0)&addr_dms_type_reg_sig(15 downto 8);       
								when x"27" =>  tx_data_16_sig <= capability_bits_h_sig(7 downto 0)&capability_bits_h_sig(15 downto 8);
								when x"28" =>  tx_data_16_sig <= tube_ma_command_sig(7 downto 0)&tube_ma_command_sig(15 downto 8);
								when x"29" =>  tx_data_16_sig <= actual_tube_ma_sig(7 downto 0)&actual_tube_ma_sig(15 downto 8);
								when x"2a" =>  tx_data_16_sig <= collimator_1_rear_blade_sig(7 downto 0)&collimator_1_rear_blade_sig(15 downto 8);  
								when x"2b" =>  tx_data_16_sig <= grid_voltage_1_sig(7 downto 0)&grid_voltage_1_sig(15 downto 8);
								when x"2c" =>  tx_data_16_sig <= grid_voltage_2_sig(7 downto 0)&grid_voltage_2_sig(15 downto 8);
								when x"2d" =>  tx_data_16_sig <= collimator_2_front_blade_sig(7 downto 0)&collimator_2_front_blade_sig(15 downto 8);
								when x"2e" =>  tx_data_16_sig <= capability_bits_m_sig(7 downto 0)&capability_bits_m_sig(15 downto 8);
								when x"2f" =>  tx_data_16_sig <= dms_troubleshooting_1_sig(7 downto 0)&dms_troubleshooting_1_sig(15 downto 8);
								when x"30" =>  tx_data_16_sig <= dms_troubleshooting_2_sig(7 downto 0)&dms_troubleshooting_2_sig(15 downto 8);
								when x"31" =>  tx_data_16_sig <= filament_current_sig(7 downto 0)&filament_current_sig(15 downto 8);
								when x"32" =>  tx_data_16_sig <= ma_sig(7 downto 0)&ma_sig(15 downto 8);
								when x"33" =>  tx_data_16_sig <= kv_sig(7 downto 0)&kv_sig(15 downto 8);
								when x"34" =>  tx_data_16_sig <= collimator_3_sig(7 downto 0)&collimator_3_sig(15 downto 8);
								when x"35" =>  tx_data_16_sig <= capability_bits_l_sig(7 downto 0)&capability_bits_l_sig(15 downto 8);
								when x"36" =>  tx_data_16_sig <= collimator_4_sig(7 downto 0)&collimator_4_sig(15 downto 8);
								when x"37" =>  tx_data_16_sig <= ecg_sig(7 downto 0)&ecg_sig(15 downto 8);
								when x"38" =>  tx_data_16_sig <= dom_sig(7 downto 0)&dom_sig(15 downto 8);
								when x"39" =>  tx_data_16_sig <= reading_number_sig(7 downto 0)&reading_number_sig(15 downto 8);          
								when x"3a" =>  tx_data_16_sig <= reading_number_sig(23 downto 16)&reading_number_sig(31 downto 24);  	  
								when x"3b" =>  tx_data_16_sig <= data_pointer_0_sig(7 downto 0)& data_pointer_0_sig(15 downto 8);
								when x"3c" =>  tx_data_16_sig <= data_pointer_1_sig(7 downto 0)& data_pointer_1_sig(15 downto 8);
								when x"3d" =>  tx_data_16_sig <= x"0000";
								when x"3e" =>  tx_data_16_sig <= x"0000";
								when x"3f" =>  tx_data_16_sig <= x"0000";
								when x"40" =>  tx_data_16_sig <= stamp_sig(7 downto 0)& stamp_sig(15 downto 8);
								when x"41" =>  tx_data_16_sig <= rlt_ptr_address_reg_sig(7 downto 0)&rlt_ptr_address_reg_sig(15 downto 8);tx_serdes_ip_sig <='0';tx_serdes_go_sig <= '0'; -- Footers
								when x"42" =>  tx_data_16_sig <= rlt_ptr_address_reg_sig(23 downto 16)&rlt_ptr_address_reg_sig(31 downto 24); -- Footers
								when x"43" =>  tx_data_16_sig <= hd_ptr_address_reg_sig(7 downto 0)&hd_ptr_address_reg_sig(15 downto 8); -- Footers
								when x"44" =>  tx_data_16_sig <= hd_ptr_address_reg_sig(23 downto 16)&hd_ptr_address_reg_sig(31 downto 24); --tx_ctrl_sm_sig <= pop_static_pack_st;case_counter_sig <= (others=> '0'); -- Footers
								when x"45" =>  tx_data_16_sig <= fs_merge_factor_sig(7 downto 0)&rlt_slice_merge_factor_sig(7 downto 0);--tx_ctrl_sm_sig <= pop_static_pack_st;case_counter_sig <= (others=> '0'); -- Footers
								when x"46" =>  tx_data_16_sig <= x"00"&fq_stream_sig(7 downto 0);tx_ctrl_sm_sig <= pop_static_pack_st;case_counter_sig <= (others=> '0'); -- Footers
								when others => tx_data_16_sig <= x"DEA1";tx_ctrl_sm_sig <= idle_st;case_counter_sig <= (others=> '0'); 

							end case;
					when push_data_buffer_st =>
						st_num_sig <= x"7"; 
						case_counter_sig <= std_logic_vector(unsigned(case_counter_sig)+ "1");
						tx_fifo_tx_wr_en <= '1';
						case case_counter_sig is --send here latched signals								
							when x"00" =>  tx_data_16_sig <= x"ba5e"; -- header					 
							when x"01" =>  tx_data_16_sig <= buf_ptr_address_sig(7 downto 0)&buf_ptr_address_sig(15 downto 8); 					 
							when x"02" =>  tx_data_16_sig <= buf_ptr_address_sig(23 downto 16)&buf_ptr_address_sig(31 downto 24);tx_serdes_ip_sig <='0';tx_serdes_go_sig <= '1';  				 
							when x"03" =>  tx_data_16_sig <= uid_reg_sig(7 downto 0)&uid_reg_sig(15 downto 8);  					 
							when x"04" =>  tx_data_16_sig <= stream_ctrl_sig(7 downto 0)&x"00";  -- !debug: 13/10/2023 byte swap for stream_ctrl_sig
                                                                                         tx_serdes_ip_sig <='0';tx_serdes_go_sig <= '0';
							when x"05" =>  tx_data_16_sig <= x"beef";tx_ctrl_sm_sig <= pop_static_pack_st;case_counter_sig <= (others=> '0'); -- Footers
							when others => tx_data_16_sig <= x"DEAA";tx_ctrl_sm_sig <= idle_st;case_counter_sig <= (others=> '0'); 
						end case;
					when pop_static_pack_st => 
						st_num_sig <= x"a";
						-- tx_serdes_go_sig <= '1';
						
						if (serdes_rd_req_sr_sig(2) = '0' and serdes_rd_req_sr_sig(3) = '1') then
							tx_ctrl_sm_sig <= resend_real_pack_st;
						else
							tx_ctrl_sm_sig <= pop_static_pack_st;
						end if;
					when resend_real_pack_st =>
						st_num_sig <= x"c";
						clear_flag_sig <= '1';
						-- if (ff2_rd_data_count_sig = x"00") then
						if (empty_flag_sig = '1' and G_HEADERS = '1') then
							clear_flag_sig <= '0';
							resend_pack_cnt_sig <= std_logic_vector(unsigned(resend_pack_cnt_sig)+ "1");
						     case resend_pack_cnt_sig is
--								when x"0" => tx_ctrl_sm_sig <= pop_ip_pack_st;tx_serdes_go_sig <= '1';
--								when x"1" => tx_ctrl_sm_sig <= pop_ip_pack_st;tx_serdes_go_sig <= '1'; 
								when x"0" => tx_ctrl_sm_sig <= push_data_sync_st; tx_serdes_ip_sig <='0';
--								when x"3" => tx_ctrl_sm_sig <= push_data_sync_st;
--								when x"4" => tx_ctrl_sm_sig <= push_data_sync_st;
								when x"1" => tx_ctrl_sm_sig <= idle_st;resend_pack_cnt_sig <= x"0"; 
								when others =>tx_ctrl_sm_sig <= idle_st;resend_pack_cnt_sig <= x"F";
							end case;
						elsif (empty_flag_sig = '1' and G_HEADERS = '0') then
							clear_flag_sig <= '0';
							tx_ctrl_sm_sig <= idle_st;
							resend_pack_cnt_sig <= x"0";
						else
							tx_ctrl_sm_sig <= resend_real_pack_st;
						end if; 
					when others => wrong_st_flag_sig <= '1';tx_ctrl_sm_sig <= idle_st;st_num_sig <= x"d";
				end case;
			end if;
		end if;
	end process;
------------------------------------------------------------------------------------------------------------------------
tristate_m_sig <= tri_state_en_vec_sig(3);
tristate_s_sig <= not tri_state_en_vec_sig(3);
------------------------------------------------------------------------------------------------------------------------

PROCESS (CLK_100M)
BEGIN   		

--------------------------------------------------------------------------------------------------------------------------------		 
	IF rising_edge(CLK_100M) THEN

	---------------------------------------------------------------------------------
		IF (RESET = G_RESET_POLARITY ) THEN		 		
			tri_state_en_vec_sig <= "0000";		 
		else
			tri_state_en_vec_sig(2 downto 0)<= tri_state_en_vec_sig(1 downto 0)& MASTERn_SLAVE;
			tri_state_en_vec_sig(3)<=  tri_state_en_vec_sig(2);
		end if;
		
	end if;
end process;
end architecture;