---------------------------------------------
-- Date : 26/03/2022
-- Company : Philips Medical
---------------------------------------------
-- Aothor  : Tzvika Sweetkin
---------------------------------------------
-- Block Name:cdm_registers_pack 
---------------------------------------------
-- simulation tool : Vivado Simulator
-- Synthesis&PnR tool : Vivado 2021.2 
-- Versions : 
-- 01/03/2022 : 
-- 26/03/2022 : footer registers architecture 
-- Acro :

---------------------------------------------
---------------------------------------------
-- Block description:
-- Masters : CPU,RHOST
---------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- registers package
package cdm_registers_pack is
    
---------------------------------------

    
    type module_rec is record
        ack :std_logic;
        verify : std_logic;
        data_in :std_logic_vector(31 downto 0);
    end record module_rec;
    -- init records
    constant inst_mod_rec : module_rec := (
        ack => '0',
        verify => '0',
        data_in => (others =>'0')
    );
    type brams_size is array (0 to 4) of std_logic_vector(12-1 downto 0);
    type init_arr is array (0 to 35) of std_logic_vector(16-1 downto 0);
    type init_addr_arr is array (0 to 24) of std_logic_vector(24-1 downto 0);
    -- init_addr_arr[i][20] - This bit represent calib start
    constant C_init_addr_arr : init_addr_arr := 
    (
        0=>  x"046700",
        1=>  x"046780", --6msec
        2 => x"046650",	
        3 => x"046650",	
        4 => x"046650",	
        5 => x"046650",	
        6 => x"046650",	
        7 => x"046650",	
        8 =>x"046650",	
        9 =>x"046650",	
        10 =>x"046650",	
        11 =>x"046650",	
        12 =>x"046650",
        13=> x"046650" , 
        14=> x"046750",
        15=> x"046650",
        16=> x"046650" ,--2sec
        17=> x"046650", --6msec
        18=> x"046780" ,--6msec
        19=> x"046780" ,
        20=> x"046790" , 
        21=> x"146790",
        22=> x"046730",
        23=> x"046730",
        24=> x"EEEEEE"
        -- 7=> x"0625E100" --2sec
    );
    type init_data_arr is array (0 to 24) of std_logic_vector(32-1 downto 0);
    constant C_init_data_arr : init_data_arr := 
    (
        0=> x"000BF173",
        1=> x"0000000a", --6msec
        2=> x"80100003",
        3=> x"80122D60",
        4=> x"801F0355",
        5=> x"80132211",
        6=> x"80140866",
        7=> x"80150155",
        8=> x"80160098",
        9=> x"80170000",
        10=> x"80202200",
        11=> x"80210866",
        12=> x"80220011",
        13=> x"80531000" , 
        14=> x"00000004",
        15=> x"801A000E",
        16=> x"801B0017", --2sec
        17=> x"801C0058", --6msec
        18=> x"0000000E" ,--6msec
        19=> x"0000000F" ,
        20=> x"00000003" , 
        21=> x"00000001",
        22=> x"00000000",
        23=> x"00008007",
        24=> x"EEEEEEEE"
        -- 7=> x"0625E100" --2sec
    );
    constant C_CALIB_START    		        : integer := 24 ; -- need to change according to calibration register index change
    constant C_TIME_OFFSET_STEP     		 : std_logic_vector(32-1 downto 0) := x"000493E0" ; -- 6msec with 50MHz clock
    type init_time_dly_arr is array (0 to 24) of std_logic_vector(32-1 downto 0);
    constant C_init_time_DLY : init_time_dly_arr := 
    (
        0=> x"002DC6C0" , --
        1=> x"005B8D80" , ---6msec
        2=> x"00895440" , --
        3=> x"00B71B00" , --
        4=> x"00E4E1C0" , --
        5=> x"0112A880" , ---2sec
        6=> x"01406F40" , ---6msec
        7=> x"016E3600" , ----6msec
        8=> x"019BFCC0" , --
        9=> x"01C9C380" , -- 
        10=>x"01F78A40" , --
        11=>x"02255100" , --
        12=>x"025317C0" , --
        13=>x"0280DE80" , --
        14=>x"02AEA540" , --
        15=>x"02DC6C00" , --
        16=>x"030A32C0" , --
        17=>x"0337F980" , --
        18=>x"0365C040" , --
        19=>x"03938700" , --
        20=>x"03C14DC0" , --
        21=>x"03EF1480" , --
        22=>x"041CDB40" , --
        23=>x"044AA200" , --
        24=> x"EEEEEEEE"
        -- 7=> x"0625E100" --2sec
    );

    -- type init_time_arr is array (0 to 55) of std_logic_vector(32-1 downto 0);
    type init_time_constnats is array (0 to 7) of std_logic_vector(32-1 downto 0);
    constant C_INIT_ARRAY : init_arr := 
    (
        --reg1 - modules 
        0=> x"0001",
        1=> x"000B",
        2=> x"F173" ,
        3=> x"0467" ,
        4=> x"0000" , 
          --reg2 - off calibration for tiles
        5=> x"0001",
        6=> x"0000",
        7=> x"0000" ,
        8=> x"0467" ,
        9 => x"3000" , 
          --reg3 - start init calibration for tiles (cfg headers/raw etc. of tiles)
        10 => x"0001",
        11 => x"0000",
        12 => x"8810" ,
        13 => x"0467" ,
        14 => x"3000" , 
          --reg4 - toggle rdy to data communication of modules<->tiles
        15=> x"0001",
        16=> x"0000",
        17=> x"000A" ,
        18=> x"0467" ,
        19=> x"8000" , 
          --reg5 - toggle rdy to data communication of modules<->tiles
        20 => x"0001",
        21 => x"0000",
        22 => x"000B" ,
        23 => x"0467" ,
        24 => x"8000" , 
          --reg6 - off calibration for tiles
        25 => x"0001",
        26 => x"0000",
        27 => x"0000" ,
        28 => x"0467" ,
        29 => x"3000" , 
          --reg7 - start linear/voltage/ calibration for tiles 2sec ("7"=> |0|1|2|=> |offset voltage calibration |linear calibration|current leakage calibration|)
        30 => x"0001",
        31 => x"0000",
        32 => x"8007" ,
        33 => x"0467" ,
        34 => x"3000"  ,
        35 => x"EEEE"  
        
        --- 1 register

    );
    constant C_init_contant_time : init_time_constnats := 
    (
        0=> x"00000000",
        1=> x"00050000", --6msec
        2=> x"00100000" ,--6msec
        3=> x"00150000" ,
        4=> x"00200000" , 
        5=> x"00250000",
        6=> x"00300000",
        7=> x"00350000" --2sec
        -- 7=> x"0625E100" --2sec
    );

--    constant C_INIT_time : init_time_arr := 
--    (
--        --reg1 - modules 
--        0=> x"00000000",
--        1=> x"00000001",
--        2=> x"00000002" ,
--        3=> x"00000003" ,
--        4=> x"00000004" , 
--        5=> x"00000005",
--        6=> x"00000010",
--        7=> std_logic_vector(unsigned(C_init_contant_time(1)) - "1"),
--        8=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000000"),
--        9=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000001"),
--        10=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000002") ,
--        11=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000003") ,
--        12=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000004") , 
--        13=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000005"),
--        14=> std_logic_vector(unsigned(C_init_contant_time(1))+ x"00000010"),
--        15=> std_logic_vector(unsigned(C_init_contant_time(2))- x"1") ,
--        16=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000000"),
--        17=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000001"),
--        18=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000002") ,
--        19=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000003") ,
--        20=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000004") , 
--        21=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000005"),
--        22=> std_logic_vector(unsigned(C_init_contant_time(2))+ x"00000010"),
--        23=> std_logic_vector(unsigned(C_init_contant_time(3))- x"1") ,
--        24=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000000"),
--        25=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000001"),
--        26=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000002") ,
--        27=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000003") ,
--        28=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000004") , 
--        29=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000005"),
--        30=> std_logic_vector(unsigned(C_init_contant_time(3))+ x"00000010"),
--        31=> std_logic_vector(unsigned(C_init_contant_time(4))- x"1") ,
--        32=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000000"),
--        33=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000001"),
--        34=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000002") ,
--        35=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000003") ,
--        36=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000004") , 
--        37=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000005"),
--        38=> std_logic_vector(unsigned(C_init_contant_time(4))+ x"00000010"),
--        39=> std_logic_vector(unsigned(C_init_contant_time(5))- x"1") ,
--        40=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000000"),
--        41=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000001"),
--        42=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000002") ,
--        43=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000003") ,
--        44=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000004") , 
--        45=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000005"),
--        46=> std_logic_vector(unsigned(C_init_contant_time(5))+ x"00000010"),
--        47=> std_logic_vector(unsigned(C_init_contant_time(6))- x"1") ,
--        48=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000000"),
--        49=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000001"),
--        50=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000002") ,
--        51=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000003") ,
--        52=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000004") , 
--        53=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000005"),
--        54=> std_logic_vector(unsigned(C_init_contant_time(6))+ x"00000010"),
--        55=> std_logic_vector(unsigned(C_init_contant_time(7))- x"1") 

    
        
--        --- 1 register

--    );
    constant C_BRAMS_SIZE_ARR : brams_size := 
    (
        0 => x"FFF",
        1 => x"040",
        2 => x"200" ,
        3 => x"FFF" ,
        4 => x"200"
    );
    -- constants --
    constant C_BYTE_LEN              : integer := 8;
    constant C_MEM_DEPTH : integer := 8192;
    constant C_MEM_WIDTH : integer := 32;
    constant C_MEM_ADDR_WIDTH : integer := 32;
    -- rhost constants
	constant C_CTRL_XRAY      		 :integer range 0 to 31:= 0 ;
	constant C_CTRL_HV_DROP      	 :integer range 0 to 31:= 1 ;
	constant C_CTRL_REGISTER_OP      :integer range 0 to 31:= 4 ;	
	constant C_CTRL_WR_N      		 :integer range 0 to 31:= 5 ;
	constant C_CTRL_REG_VERIFY       :integer range 0 to 31:= 6 ;
	constant C_CTRL_RHOST_GRANT_CAL  :integer range 0 to 31:= 12 ;  
	constant C_CTRL_GANTRY_AT_IDLE   :integer range 0 to 31:= 14 ;  
	constant C_CTRL_GET_READ_FOR_SCAN:integer range 0 to 31:= 18 ; 
	constant C_M_CDM_ADDR_INDEX:integer range 0 to 31:= 16 ; 
	constant C_S_CDM_ADDR_INDEX:integer range 0 to 31:= 17 ; 
	constant C_M_MODULE_ADDR_INDEX:integer range 0 to 31:= 18 ; 
	constant C_S_MODULE_ADDR_INDEX:integer range 0 to 31:= 19 ; 
	--------------------------------------------------
				-- CDM version reg : --
	--------------------------------------------------
    constant C_VERSION_REG                      : std_logic_vector(31 downto 0):=   x"14080001"; -- 0 --version register                                             

	--------------------------------------------------
				-- CDM address offsets: --
	--------------------------------------------------
    constant C_LSB_ADDR_VERSION_REG_OFFSET                      : std_logic_vector(15 downto 0):=   x"5000"; -- 0 --version register                                             
    constant C_LSB_ADDR_TSTAMP_LSB_DATE_REG_OFFSET              : std_logic_vector(15 downto 0):=   x"5004"; -- 0 --DATE register                                             
    constant C_LSB_ADDR_TSTAMP_MSB_DATE_REG_OFFSET              : std_logic_vector(15 downto 0):=   x"5008"; -- 0 --DATE register                                             
    constant C_LSB_ADDR_IP_GENERATION_REG_OFFSET                : std_logic_vector(15 downto 0):=   x"500C"; -- 3 
    constant C_LSB_ADDR_DMS_RESET_REG_OFFSET                    : std_logic_vector(15 downto 0):=   x"5010"; -- 4 --write only
    constant C_LSB_ADDR_RESET_LENGTH_REG_OFFSET                  : std_logic_vector(15 downto 0):=   x"5018"; -- 6 --read only
    constant C_LSB_ADDR_SWAP_REG_OFFSET                        : std_logic_vector(15 downto 0):=   x"501c"; -- 6 --read only
    constant C_LSB_ADDR_AND_REG_OFFSET                        : std_logic_vector(15 downto 0):=   x"5020"; -- 6 --read only
    constant C_LSB_ADDR_OR_REG_OFFSET                        : std_logic_vector(15 downto 0):=   x"5024"; -- 6 --read only
    constant C_LSB_MODULE_MASK_WR_REG_OFFSET				    : std_logic_vector(15 downto 0) :=  x"503c";
   	constant C_LSB_SLICE_NUM_REG_OFFSET                       	: std_logic_vector(15 downto 0):=   x"5040"; -- 8
   	constant C_LSB_MODULE_MASK_RD_REG_OFFSET                       : std_logic_vector(15 downto 0):=   x"5044"; -- 8
   	constant C_LSB_ASIC_MASK_REG_OFFSET                        	: std_logic_vector(15 downto 0):=   x"5048"; -- 8
   	constant C_LSB_INTRPTS_MASK_REG_OFFSET                      : std_logic_vector(15 downto 0):=   x"504C"; -- 8
   	constant C_LSB_INTRPTS_PRE_MASK_STAT_REG_OFFSET             : std_logic_vector(15 downto 0):=   x"5050"; -- 8
   	constant C_LSB_INTRPTS_POST_MASK_STAT_REG_OFFSET            : std_logic_vector(15 downto 0):=   x"5054"; -- 8
   	constant C_LSB_PACKET_RECIEVED_REG_OFFSET                   : std_logic_vector(15 downto 0):=   x"5058"; -- 8
   	constant C_LSB_CRC_STATUS_REG_OFFSET                        : std_logic_vector(15 downto 0):=   x"505C"; -- 8
   	constant C_LSB_CRC_OUT_REG_OFFSET                           : std_logic_vector(15 downto 0):=   x"5060"; -- 8
	constant C_LSB_ADF_STATUS_OFFSET							: std_logic_vector(15 downto 0) :=  x"5064";   
	constant C_LSB_ADF_SELECTOR_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5068";
	constant C_LSB_DBG_RESET_CTRL_OFFSET					    : std_logic_vector(15 downto 0) :=  x"5070";
	constant C_LSB_CNT10_OFFSET					                : std_logic_vector(15 downto 0) :=  x"5074";
	constant C_LSB_CNT11_OFFSET					                : std_logic_vector(15 downto 0) :=  x"5078";
	constant C_LSB_CNT12_OFFSET					                : std_logic_vector(15 downto 0) :=  x"507C";
	constant C_LSB_CNT13_OFFSET					                : std_logic_vector(15 downto 0) :=  x"5080";
	constant C_LSB_CNT14_OFFSET					                : std_logic_vector(15 downto 0) :=  x"5084";
    constant C_LSB_SCAN_PARAMS_STATUS_OFFSET					: std_logic_vector(15 downto 0) :=  x"50A4";   
	constant C_LSB_PRIVATE_STATUS_OFFSET						: std_logic_vector(15 downto 0) :=  x"50A8";   
	constant C_LSB_PROG_STATUS_OFFSET							: std_logic_vector(15 downto 0) :=  x"50AC";   
	constant C_LSB_ENABLE_BRAM_OFFSET							: std_logic_vector(15 downto 0) :=  x"50B0";
	constant C_LSB_RESET_INTRPTS_OFFSET						    : std_logic_vector(15 downto 0) :=  x"50B4";
	constant C_LSB_SET_INTRPT_OFFSET							: std_logic_vector(15 downto 0) :=  x"50B8";
	constant C_LSB_WRONG_CRC_OFFSET								: std_logic_vector(15 downto 0) :=  x"50BC";
	constant C_LSB_SYNTH_DATA_METHOD_OFFSET						: std_logic_vector(15 downto 0) :=  x"50C0";
	constant C_LSB_DEBUG_SM_STATUS_OFFSET					    : std_logic_vector(15 downto 0) :=  x"50C4";
    constant C_LSB_SYNC_DEBUG_REG_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"50CC";
	constant C_LSB_MOD_DATA_CTRL_OFFSET					        : std_logic_vector(15 downto 0) :=  x"50D0";
	constant C_LSB_RHOST_DEBUG_OFFSET					        : std_logic_vector(15 downto 0) :=  x"50D4";
	constant C_LSB_SW_RESET_OFFSET					            : std_logic_vector(15 downto 0) :=  x"50D8";
	constant C_LSB_SW_INIT_STATUS_OFFSET				        : std_logic_vector(15 downto 0) :=  x"50F0";
	constant C_LSB_SYNCED_DATA_MODULES_OFFSET				        : std_logic_vector(15 downto 0) :=  x"50F4";
	constant C_LSB_SYNCED_REGS_MODULES_OFFSET				    : std_logic_vector(15 downto 0) :=  x"50F8";
	constant C_LSB_CPU_M00_DLY_RD_TIMESTAMP_OFFSET				: std_logic_vector(15 downto 0) :=  x"50FC";
    constant C_LSB_SCAN_DONE_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5100";
	constant C_LSB_PRIVATE_DONE_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5104";
	constant C_LSB_PROG_DONE_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5108";
	constant C_LSB_HEADERS_SAMP_TIME_REG_OFFSET				    : std_logic_vector(15 downto 0) :=  x"5110";
	constant C_LSB_PROGRAMMING_RHOST_CTRL_OFFSET				: std_logic_vector(15 downto 0) :=  x"5114";
	constant C_LSB_PROGRAMMING_PROGRESS_OFFSET				    : std_logic_vector(15 downto 0) :=  x"5118";
	constant C_LSB_PROGRAMMING_DEST_OFFSET					    : std_logic_vector(15 downto 0) :=  x"511C";
	constant C_LSB_PROGRAMMING_FILE_SIZE_OFFSET					: std_logic_vector(15 downto 0) :=  x"5120";
	constant C_LSB_PROGRAMMING_PACK_SIZE_OFFSET					: std_logic_vector(15 downto 0) :=  x"5124";
	constant C_LSB_PROGRAMMING_SW_CTRL_OFFSET					: std_logic_vector(15 downto 0) :=  x"5128";
    constant C_LSB_SW_VERSIONS0_OFFSET					        : std_logic_vector(15 downto 0) :=  x"512c";
    constant C_LSB_SW_VERSIONS1_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5130";
    constant C_LSB_SW_VERSIONS2_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5134";
    constant C_LSB_SW_VERSIONS3_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5138";
    constant C_LSB_SW_VERSIONS4_OFFSET					        : std_logic_vector(15 downto 0) :=  x"513c";
    constant C_LSB_SW_VERSIONS5_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5140";
    constant C_LSB_SW_VERSIONS6_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5144";
    constant C_LSB_SW_VERSIONS7_OFFSET					        : std_logic_vector(15 downto 0) :=  x"5148";
    constant C_LSB_RHOST_SELECTOR_OFFSET				        : std_logic_vector(15 downto 0) :=  x"514C";
    constant C_LSB_HEADERS_CTRL_REG_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5150";
    constant C_LSB_SCAN_STATUS_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5154";
    constant C_LSB_SCAN_CTRL_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5158";
    constant C_LSB_S_IP_LENGTH_OFFSET				            : std_logic_vector(15 downto 0) :=  x"515C";
    constant C_LSB_L_IP_LENGTH_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5160";
    constant C_LSB_T_IP_LENGTH_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5164";
    constant C_LSB_SYNTH_MAKE_DATA_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5168";
    constant C_LSB_SYNTH_END_SERIES_OFFSET				        : std_logic_vector(15 downto 0) :=  x"516C";
    constant C_LSB_IP_STATUS_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5170";
    constant C_LSB_IP_ANGLE_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5174";
    constant C_LSB_IP_CTRL_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5178";
    constant C_LSB_ANGLE_UPPER_OFFSET				            : std_logic_vector(15 downto 0) :=  x"517C";
    constant C_LSB_SCRAMBLER_CTRL_OFFSET				   : std_logic_vector(15 downto 0) :=  x"51FC";
    constant C_LSB_DATA_CTRL_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5200";
    constant C_LSB_DATA_RESET_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5204";
    constant C_LSB_ADF_INTRPT_TIME_REG_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5208";
    constant C_LSB_DBG_T_BLOCK_RECIEVED_REG_OFFSET				        : std_logic_vector(15 downto 0) :=  x"520C";
    constant C_LSB_DMS_ERRORS_REG_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5290"; -- will use for Errors
    
    -- Headers
        -- Older Addresses
        constant C_LSB_REF_CONVERTOR_OFFSET				            : std_logic_vector(15 downto 0) :=  x"533c";
        constant C_LSB_VERTICAL_COUCH_POSITION_OFFSET	            : std_logic_vector(15 downto 0) :=  x"5364";
        constant C_LSB_HORIZONTAL_COUCH_POSITION_OFFSET	            : std_logic_vector(15 downto 0) :=  x"5368";
        constant C_LSB_GANTRY_TILT_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"536c";
        constant C_LSB_TUBE_MA_COMMAND_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53ac";
        constant C_LSB_ACTUAL_TUBE_MA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53b0";
        constant C_LSB_COLLIMATOR_1_REAR_BLADE_OFFSET	            : std_logic_vector(15 downto 0) :=  x"53b4";
        constant C_LSB_GRID_VOLTAGE_1_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53b8";
        constant C_LSB_GRID_VOLTAGE_2_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53bc";
        constant C_LSB_COLLIMATOR_2_FRONT_BLADE_OFFSET	            : std_logic_vector(15 downto 0) :=  x"53c0";
        constant C_LSB_FILAMENT_CURRENT_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53d0";
        constant C_LSB_MA_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"53d4";
        constant C_LSB_KV_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"53d8";
        constant C_LSB_ECG_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"53e8";
        constant C_LSB_DOM_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"53ec";

        constant C_LSB_TSTAMP_RLT_HIGH_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5304";
        constant C_LSB_TSTAMP_RLT_INC_DEC_OFFSET				    : std_logic_vector(15 downto 0) :=  x"5308";
        constant C_LSB_CT_TYPE_OFFSET				                : std_logic_vector(15 downto 0) :=  x"532c";
        constant C_LSB_DMS_STATUS_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5330";
        constant C_LSB_DMS_ERROR_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5334";
        constant C_LSB_ADDR_INTEGRATION_PERIOD_REG_OFFSET           : std_logic_vector(15 downto 0):=   x"5338"; -- 7 --read only   
        constant C_LSB_L_DMS_TEMP_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5340";
        constant C_LSB_R_DMS_TEMP_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5344";
        constant C_LSB_FANS_SPEED_DMS_TROUBLESHOOTING_OFFSET	    : std_logic_vector(15 downto 0) :=  x"5348";
        constant C_LSB_READING_NUMBER_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"534c";
        constant C_LSB_DETECTION_SETTING_1_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5350";
        constant C_LSB_DETECTION_SETTING_2_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5354";
        constant C_LSB_DETECTION_SETTING_3_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5358";
        constant C_LSB_DETECTION_SETTING_4_OFFSET	                : std_logic_vector(15 downto 0) :=  x"535c";
        constant C_LSB_RESEND_COUNTER_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5360";
        constant C_LSB_ROTOR_ANGLE_ACQUISITION_OFFSET	            : std_logic_vector(15 downto 0) :=  x"5370";
        constant C_LSB_ROTOR_ANGLE_DATA_SENDING_OFFSET	            : std_logic_vector(15 downto 0) :=  x"5374";
        constant C_LSB_HW_LINES_1_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5378";
        constant C_LSB_HW_LINES_2_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"537c";
        constant C_LSB_BAD_READING_DETAILS_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5380";
        constant C_LSB_ADDR_UNIQUE_ID_REG_OFFSET                    : std_logic_vector(15 downto 0):=   x"5384"; -- 5 --UID 
        constant C_LSB_SHOT_COUNTER_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5388";
        constant C_LSB_ANGULAR_DENOMINATOR_OFFSET	                : std_logic_vector(15 downto 0) :=  x"538c";
        constant C_LSB_TIME_STAMP_LOW_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5390";
        constant C_LSB_TIME_STAMP_HIGH_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5394";
        constant C_LSB_NUMBER_OF_DETECTORS_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5398";
        constant C_LSB_UTC_TIME_LSB_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"539c";
        constant C_LSB_UTC_TIME_MSB_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"53a0";
        constant C_LSB_ADDR_DMS_TYPE_REG_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53a4";
        constant C_LSB_CAPABILITY_BITS_H_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53a8";
        constant C_LSB_CAPABILITY_BITS_M_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53c4";
        constant C_LSB_DMS_TROUBLESHOOTING_1_OFFSET	                : std_logic_vector(15 downto 0) :=  x"53c8";
        constant C_LSB_DMS_TROUBLESHOOTING_2_OFFSET	                : std_logic_vector(15 downto 0) :=  x"53cc";
        constant C_LSB_COLLIMATOR_3_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"53dc";
        constant C_LSB_CAPABILITY_BITS_L_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53e0";
        constant C_LSB_COLLIMATOR_4_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"53e4";
        constant C_LSB_DATA_POINTER_0_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53f0";
        constant C_LSB_DATA_POINTER_1_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53f4";
        constant C_LSB_STAMP_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"53f8";
        -- WIP24 RHOST headears update Addresses
    -- constant C_HEADER_WORD_5_OFFSET				                : std_logic_vector(15 downto 0) :=  x"530C"; --Reference Detector Ch1 Data                => C_LSB_REF_CONVERTOR_OFFSET
    -- constant C_HEADER_WORD_17_16_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5310"; -- Horizontal Couch |Vertical Couch          => C_LSB_HORIZONTAL_COUCH_POSITION_OFFSET|C_LSB_VERTICAL_COUCH_POSITION_OFFSET
    -- constant C_HEADER_WORD_40_18_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5314"; -- Commanded Tube mA  |Gantry Tilt           => C_LSB_TUBE_MA_COMMAND_OFFSET|C_LSB_GANTRY_TILT_OFFSET
    -- constant C_HEADER_WORD_42_41_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5318"; -- A-Plane Blade B  |Actual measured Tube mA => C_LSB_COLLIMATOR_1_REAR_BLADE_OFFSET|C_LSB_ACTUAL_TUBE_MA_OFFSET
    -- constant C_HEADER_WORD_44_43_OFFSET				            : std_logic_vector(15 downto 0) :=  x"531C"; -- HV Grid V2 |HV Grid V1                    => C_LSB_GRID_VOLTAGE_2_OFFSET|C_LSB_GRID_VOLTAGE_1_OFFSET
    -- constant C_HEADER_WORD_49_45_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5320"; -- HV Filament |A-Plane Blade A              => C_LSB_FILAMENT_CURRENT_OFFSET|C_LSB_COLLIMATOR_2_FRONT_BLADE_OFFSET
    -- constant C_HEADER_WORD_51_50_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5324"; -- HV kV  |HV mA                             => C_LSB_KV_OFFSET|C_LSB_MA_OFFSET
    -- constant C_HEADER_WORD_56_55_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5328"; -- Scan Abort & mA CMD during DOM  |ECG      => C_LSB_DOM_OFFSET|C_LSB_ECG_OFFSET
    -- -- FW&SW HEADERS
    -- constant C_LSB_TSTAMP_RLT_HIGH_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5304";
    -- constant C_LSB_TSTAMP_RLT_INC_DEC_OFFSET				    : std_logic_vector(15 downto 0) :=  x"5308";
    -- constant C_LSB_CT_TYPE_OFFSET				                : std_logic_vector(15 downto 0) :=  x"532c";
    -- constant C_LSB_DMS_STATUS_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5330";
    -- constant C_LSB_DMS_ERROR_OFFSET				                : std_logic_vector(15 downto 0) :=  x"5334";
    -- constant C_LSB_ADDR_INTEGRATION_PERIOD_REG_OFFSET           : std_logic_vector(15 downto 0):=   x"5338"; -- 7 --read only   
    -- constant C_LSB_L_DMS_TEMP_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5340";
    -- constant C_LSB_R_DMS_TEMP_OFFSET				            : std_logic_vector(15 downto 0) :=  x"5344";
    -- constant C_LSB_FANS_SPEED_DMS_TROUBLESHOOTING_OFFSET	    : std_logic_vector(15 downto 0) :=  x"5348";
    -- constant C_LSB_READING_NUMBER_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"534c";
    -- constant C_LSB_DETECTION_SETTING_1_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5350";
    -- constant C_LSB_DETECTION_SETTING_2_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5354";
    -- constant C_LSB_DETECTION_SETTING_3_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5358";
    -- constant C_LSB_DETECTION_SETTING_4_OFFSET	                : std_logic_vector(15 downto 0) :=  x"535c";
    -- constant C_LSB_RESEND_COUNTER_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5360";
    -- constant C_LSB_ROTOR_ANGLE_ACQUISITION_OFFSET	            : std_logic_vector(15 downto 0) :=  x"5370";
    -- constant C_LSB_ROTOR_ANGLE_DATA_SENDING_OFFSET	            : std_logic_vector(15 downto 0) :=  x"5374";
    -- constant C_LSB_HW_LINES_1_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5378";
    -- constant C_LSB_HW_LINES_2_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"537c";
    -- constant C_LSB_BAD_READING_DETAILS_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5380";
    -- constant C_LSB_ADDR_UNIQUE_ID_REG_OFFSET                    : std_logic_vector(15 downto 0):=   x"5384"; -- 5 --UID 
    -- constant C_LSB_SHOT_COUNTER_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5388";
    -- constant C_LSB_ANGULAR_DENOMINATOR_OFFSET	                : std_logic_vector(15 downto 0) :=  x"538c";
    -- constant C_LSB_TIME_STAMP_LOW_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5390";
    -- constant C_LSB_TIME_STAMP_HIGH_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5394";
    -- constant C_LSB_NUMBER_OF_DETECTORS_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5398";
    -- constant C_LSB_UTC_TIME_LSB_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"539c";
    -- constant C_LSB_UTC_TIME_MSB_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"53a0";
    -- constant C_LSB_ADDR_DMS_TYPE_REG_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53a4";
    -- constant C_LSB_CAPABILITY_BITS_H_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53a8";
    -- constant C_LSB_CAPABILITY_BITS_M_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53c4";
    -- constant C_LSB_DMS_TROUBLESHOOTING_1_OFFSET	                : std_logic_vector(15 downto 0) :=  x"53c8";
    -- constant C_LSB_DMS_TROUBLESHOOTING_2_OFFSET	                : std_logic_vector(15 downto 0) :=  x"53cc";
    -- constant C_LSB_COLLIMATOR_3_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"53dc";
    -- constant C_LSB_CAPABILITY_BITS_L_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53e0";
    -- constant C_LSB_COLLIMATOR_4_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"53e4";
    -- constant C_LSB_DATA_POINTER_0_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53f0";
    -- constant C_LSB_DATA_POINTER_1_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"53f4";
    -- constant C_LSB_TSTAMP_RLT_LOW_OFFSET				        : std_logic_vector(15 downto 0) :=  x"5300";
    -- constant C_LSB_STAMP_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"53f8";

    constant C_LSB_DMS_STATUS_OUT_OFFSET	                     : std_logic_vector(15 downto 0) :=  x"53fC";
    constant C_LSB_FAN_CTRL_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5500";
    constant C_LSB_FAN_DATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5504";
    constant C_LSB_INIT_C2M_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5508";
    constant C_LSB_INIT_RX_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"550C";
    constant C_LSB_INIT_IP_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5510";
    constant C_LSB_INIT_MODULES_CFG_REG_OFFSET	                : std_logic_vector(15 downto 0) :=  x"5514";
    constant C_LSB_INIT_FOOTERS_REG_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5518";
    constant C_LSB_SIG2_OUT_DATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"55A0";
    constant C_LSB_SIG2_IN_DATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"55A4";
    constant C_LSB_MOD_CFG_DLY_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"55A8";
    constant C_LSB_SIG2_STATUS_OFFSET					        : std_logic_vector(15 downto 0) :=  x"50DC";
    constant C_LSB_IP_DLY_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"55B0";
    constant C_LSB_MOD0_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5400";
    constant C_LSB_MOD1_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5404";
    constant C_LSB_MOD2_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5408";
    constant C_LSB_MOD3_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"540c";
    constant C_LSB_MOD4_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5410";
    constant C_LSB_MOD5_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5414";
    constant C_LSB_MOD6_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5418";
    constant C_LSB_MOD7_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"541c";
    constant C_LSB_MOD8_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5420";
    constant C_LSB_MOD9_READDATA_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"5424";
    constant C_LSB_MOD10_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5428";
    constant C_LSB_MOD11_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"542c";
    constant C_LSB_MOD12_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5430";
    constant C_LSB_MOD13_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5434";
    constant C_LSB_MOD14_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5438";
    constant C_LSB_MOD15_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"543c";
    constant C_LSB_MOD16_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5440";
    constant C_LSB_MOD17_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5444";
    constant C_LSB_MOD18_READDATA_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5448";
    constant C_LSB_MODULES_DONE_OFFSET	                            : std_logic_vector(15 downto 0) :=  x"544c";
    constant C_LSB_MODULES_VERIFY_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5450";
    constant C_LSB_MODULES_ERROR_RESET_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5454";
    constant C_LSB_DIAG_MOD0_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5458";
    constant C_LSB_DIAG_MOD1_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"545c";
    constant C_LSB_DIAG_MOD2_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5460";
    constant C_LSB_DIAG_MOD3_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5464";
    constant C_LSB_DIAG_MOD4_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5468";
    constant C_LSB_DIAG_MOD5_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"546c";
    constant C_LSB_DIAG_MOD6_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5470";
    constant C_LSB_DIAG_MOD7_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5474";
    constant C_LSB_DIAG_MOD8_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5478";
    constant C_LSB_DIAG_MOD9_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"547c";
    constant C_LSB_DIAG_MOD10_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5480";
    constant C_LSB_DIAG_MOD11_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5484";
    constant C_LSB_DIAG_MOD12_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5488";
    constant C_LSB_DIAG_MOD13_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"548c";
    constant C_LSB_DIAG_MOD14_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5490";
    constant C_LSB_DIAG_MOD15_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5494";
    constant C_LSB_DIAG_MOD16_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"5498";
    constant C_LSB_DIAG_MOD17_READDATA_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"549c";
    constant C_LSB_DIAG_MODULES_DONE_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"54a0";
    constant C_LSB_DIAG_MODULES_VERIFY_OFFSET	                    : std_logic_vector(15 downto 0) :=  x"54a4";
    constant C_LSB_DIAG_MODULES_ERROR_RESET_OFFSET	                : std_logic_vector(15 downto 0) :=  x"54a8";
    constant C_LSB_MODULES_FOOTER_FORMAT_STATUS_OFFSET	            : std_logic_vector(15 downto 0) :=  x"54aC";
    constant C_LSB_MODULES_FOOTER_CAL_DONE_STATUS_OFFSET	        : std_logic_vector(15 downto 0) :=  x"54B0";
    constant C_LSB_MODULES_FOOTER_TEMP_STATUS_OFFSET	            : std_logic_vector(15 downto 0) :=  x"54B4";
    constant C_LSB_RX_REG_SYNCED_TOUT_REG_OFFSET_OFFSET	            : std_logic_vector(15 downto 0) :=  x"54B8";
    constant C_LSB_HD_LSB_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5600";
    constant C_LSB_HD_MSB_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5604";
    constant C_LSB_HD_DONE_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5608";
    constant C_LSB_RLT_LSB_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"560c";
    constant C_LSB_RLT_MSB_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5610";
    constant C_LSB_RLT_DONE_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5614";
    constant C_LSB_UHD_LSB_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5618";
    constant C_LSB_UHD_MSB_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"561c";
    constant C_LSB_UHD_DONE_OFFSET	                                : std_logic_vector(15 downto 0) :=  x"5620";
    constant C_LSB_OSD2RHOST_ERRORS_OFFSET	                        : std_logic_vector(15 downto 0) :=  x"5624"; 
	constant C_LSB_RST_ERROR_OFFSET     					            : std_logic_vector(15 downto 0) :=  x"5700";
	constant C_LSB_ERROR_MASK_OFFSET    					            : std_logic_vector(15 downto 0) :=  x"5704";
	constant C_LSB_ERROR_INJECT_OFFSET  					            : std_logic_vector(15 downto 0) :=  x"5708";
	constant C_LSB_RLT_ERROR_SRC_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"570c";
    constant C_LSB_LAT_ERROR_SRC_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"5710";
    constant C_LSB_AUX_ERROR_SRC_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"5714";
    constant C_LSB_DATAPATH_ERROR_SRC_OFFSET 					        : std_logic_vector(15 downto 0) :=  x"5718";
    constant C_LSB_DATAPATH_ERROR_1_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"571c";
    constant C_LSB_DATAPATH_ERROR_2_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"5720";
    constant C_LSB_DATAPATH_ERROR_3_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"5724";
    constant C_LSB_DATAPATH_ERROR_4_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"5728";
    constant C_LSB_MISC_ERROR_SRC_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"572c";
    constant C_LSB_SW_SFP_STATUS_ERROR_SRC_OFFSET 					    : std_logic_vector(15 downto 0) :=  x"5730";
	constant C_LSB_BUFFER_ERRORS_OFFSET     			                : std_logic_vector(15 downto 0) :=  x"5734";
	constant C_LSB_SYNC_ERRORS_OFFSET    					            : std_logic_vector(15 downto 0) :=  x"5738";
	constant C_LSB_DIAG_REGS_TX_EMPTY_BEFORE_OFFSET  	                : std_logic_vector(15 downto 0) :=  x"573c";
	constant C_LSB_DIAG_REGS_TX_NOT_EMPTY_AFTER_OFFSET 		            : std_logic_vector(15 downto 0) :=  x"5740";
	constant C_LSB_DIAG_REGS_RX_CRC_ERROR_OFFSET  	                    : std_logic_vector(15 downto 0) :=  x"5744";
	constant C_LSB_DIAG_REGS_RX_NOT_LOCKED_OFFSET 		                : std_logic_vector(15 downto 0) :=  x"5748";
	constant C_LSB_DIAG_REGS_RX_NO_IDLE_OFFSET 		                    : std_logic_vector(15 downto 0) :=  x"574c";
    constant C_LSB_OP_REGS_TX_EMPTY_BEFORE_OFFSET   		            : std_logic_vector(15 downto 0) :=  x"5750";
    constant C_LSB_OP_REGS_TX_NOT_EMPTY_AFTER_OFFSET                    : std_logic_vector(15 downto 0) :=  x"5754";
	constant C_LSB_OP_REGS_RX_CRC_ERROR_OFFSET  	                    : std_logic_vector(15 downto 0) :=  x"5758";
	constant C_LSB_OP_REGS_RX_NOT_LOCKED_OFFSET 		                : std_logic_vector(15 downto 0) :=  x"575c";
	constant C_LSB_OP_REGS_RX_NO_IDLE_OFFSET 		                    : std_logic_vector(15 downto 0) :=  x"5760";
    constant C_LSB_RHOST_LAT_RST_ERROR_OFFSET     					    : std_logic_vector(15 downto 0) :=  x"5764";
    constant C_LSB_DATAPATH_RX_CRC_ERROR_OFFSET      					: std_logic_vector(15 downto 0) :=  x"5768";
    constant C_LSB_DATAPATH_RX_NOT_LOCKED_OFFSET     					: std_logic_vector(15 downto 0) :=  x"576c";
    constant C_LSB_DATAPATH_RX_NO_IDLE_OFFSET 	    					: std_logic_vector(15 downto 0) :=  x"5770";
    constant C_LSB_DATAPATH_RESEND_COUNTER_OFFSET     					: std_logic_vector(15 downto 0) :=  x"5774";
    constant C_LSB_DATAPATH_HOLDOFF_COUNTER_OFFSET 					    : std_logic_vector(15 downto 0) :=  x"5778";
    constant C_LSB_BUFFER_ERR1_OFFSET     					            : std_logic_vector(15 downto 0) :=  x"577c";
    constant C_LSB_BUFFER_ERR2_OFFSET     					            : std_logic_vector(15 downto 0) :=  x"5780";
    constant C_LSB_SYNC_ERR1_OFFSET    					                : std_logic_vector(15 downto 0) :=  x"5784";
    constant C_LSB_SYNC_ERR2_OFFSET    					                : std_logic_vector(15 downto 0) :=  x"5788";
    constant C_LSB_HEADER_MUX_CTRL_OFFSET 					            : std_logic_vector(15 downto 0) :=  x"5800"; --header 47 word starting from 1
    constant C_LSB_ADF_SET1_DATA0_OFFSET							    : std_logic_vector(15 downto 0) :=  x"580c";
    constant C_LSB_ADF_SET1_DATA1_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5810";
    constant C_LSB_ADF_SET1_DATA2_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5814";
    constant C_LSB_ADF_SET1_DATA3_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5818";
    constant C_LSB_ADF_SET1_DATA4_OFFSET							    : std_logic_vector(15 downto 0) :=  x"581c";
    constant C_LSB_ADF_SET1_DATA5_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5820";
    constant C_LSB_ADF_SET1_DATA6_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5824";
    constant C_LSB_ADF_SET1_DATA7_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5828";
    constant C_LSB_ADF_SET1_DATA8_OFFSET							    : std_logic_vector(15 downto 0) :=  x"582c";
    constant C_LSB_ADF_SET1_DATA9_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5830";
    constant C_LSB_ADF_SET1_DATA10_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5834";
    constant C_LSB_ADF_SET1_DATA11_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5838";
    constant C_LSB_ADF_SET1_DATA12_OFFSET							    : std_logic_vector(15 downto 0) :=  x"583c";
    constant C_LSB_ADF_SET1_DATA13_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5840";
    constant C_LSB_ADF_SET1_DATA14_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5844";
    constant C_LSB_ADF_SET1_DATA15_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5848";
    constant C_LSB_ADF_SET2_DATA0_OFFSET							    : std_logic_vector(15 downto 0) :=  x"584c";
    constant C_LSB_ADF_SET2_DATA1_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5850";
    constant C_LSB_ADF_SET2_DATA2_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5854";
    constant C_LSB_ADF_SET2_DATA3_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5858";
    constant C_LSB_ADF_SET2_DATA4_OFFSET							    : std_logic_vector(15 downto 0) :=  x"585c";
    constant C_LSB_ADF_SET2_DATA5_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5860";
    constant C_LSB_ADF_SET2_DATA6_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5864";
    constant C_LSB_ADF_SET2_DATA7_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5868";
    constant C_LSB_ADF_SET2_DATA8_OFFSET							    : std_logic_vector(15 downto 0) :=  x"586c";
    constant C_LSB_ADF_SET2_DATA9_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5870";
    constant C_LSB_ADF_SET2_DATA10_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5874";
    constant C_LSB_ADF_SET2_DATA11_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5878";
    constant C_LSB_ADF_SET2_DATA12_OFFSET							    : std_logic_vector(15 downto 0) :=  x"587c";
    constant C_LSB_ADF_SET2_DATA13_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5880";
    constant C_LSB_ADF_SET2_DATA14_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5884";
    constant C_LSB_ADF_SET2_DATA15_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5888";
    constant C_LSB_ADF_SET3_DATA0_OFFSET							    : std_logic_vector(15 downto 0) :=  x"588c";
    constant C_LSB_ADF_SET3_DATA1_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5890";
    constant C_LSB_ADF_SET3_DATA2_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5894";
    constant C_LSB_ADF_SET3_DATA3_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5898";
    constant C_LSB_ADF_SET3_DATA4_OFFSET							    : std_logic_vector(15 downto 0) :=  x"589c";
    constant C_LSB_ADF_SET3_DATA5_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58a0";
    constant C_LSB_ADF_SET3_DATA6_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58a4";
    constant C_LSB_ADF_SET3_DATA7_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58a8";
    constant C_LSB_ADF_SET3_DATA8_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58ac";
    constant C_LSB_ADF_SET3_DATA9_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58b0";
    constant C_LSB_ADF_SET3_DATA10_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58b4";
    constant C_LSB_ADF_SET3_DATA11_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58b8";
    constant C_LSB_ADF_SET3_DATA12_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58bc";
    constant C_LSB_ADF_SET3_DATA13_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58c0";
    constant C_LSB_ADF_SET3_DATA14_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58c4";
    constant C_LSB_ADF_SET3_DATA15_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58c8";
    constant C_LSB_ADF_SET4_DATA0_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58cc";
    constant C_LSB_ADF_SET4_DATA1_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58d0";
    constant C_LSB_ADF_SET4_DATA2_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58d4";
    constant C_LSB_ADF_SET4_DATA3_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58d8";
    constant C_LSB_ADF_SET4_DATA4_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58dc";
    constant C_LSB_ADF_SET4_DATA5_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58e0";
    constant C_LSB_ADF_SET4_DATA6_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58e4";
    constant C_LSB_ADF_SET4_DATA7_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58e8";
    constant C_LSB_ADF_SET4_DATA8_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58ec";
    constant C_LSB_ADF_SET4_DATA9_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58f0";
    constant C_LSB_ADF_SET4_DATA10_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58f4";
    constant C_LSB_ADF_SET4_DATA11_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58f8";
    constant C_LSB_ADF_SET4_DATA12_OFFSET							    : std_logic_vector(15 downto 0) :=  x"58fc";
    constant C_LSB_ADF_SET4_DATA13_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5900";
    constant C_LSB_ADF_SET4_DATA14_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5904";
    constant C_LSB_ADF_SET4_DATA15_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5908";
    constant C_LSB_ADF_SET5_DATA0_OFFSET							    : std_logic_vector(15 downto 0) :=  x"590c";
    constant C_LSB_ADF_SET5_DATA1_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5910";
    constant C_LSB_ADF_SET5_DATA2_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5914";
    constant C_LSB_ADF_SET5_DATA3_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5918";
    constant C_LSB_ADF_SET5_DATA4_OFFSET							    : std_logic_vector(15 downto 0) :=  x"591c";
    constant C_LSB_ADF_SET5_DATA5_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5920";
    constant C_LSB_ADF_SET5_DATA6_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5924";
    constant C_LSB_ADF_SET5_DATA7_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5928";
    constant C_LSB_ADF_SET5_DATA8_OFFSET							    : std_logic_vector(15 downto 0) :=  x"592c";
    constant C_LSB_ADF_SET5_DATA9_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5930";
    constant C_LSB_ADF_SET5_DATA10_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5934";
    constant C_LSB_ADF_SET5_DATA11_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5938";
    constant C_LSB_ADF_SET5_DATA12_OFFSET							    : std_logic_vector(15 downto 0) :=  x"593c";
    constant C_LSB_ADF_SET5_DATA13_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5940";
    constant C_LSB_ADF_SET5_DATA14_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5944";
    constant C_LSB_ADF_SET5_DATA15_OFFSET							    : std_logic_vector(15 downto 0) :=  x"5948";
    -- Thsi ADF registers used for reading by RHOST 
    constant C_LSB_RHOST_RD_ADF_DATA0_OFFSET				    : std_logic_vector(15 downto 0) :=  x"410C";
    constant C_LSB_RHOST_RD_ADF_DATA1_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4110";
    constant C_LSB_RHOST_RD_ADF_DATA2_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4114";
    constant C_LSB_RHOST_RD_ADF_DATA3_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4118";
    constant C_LSB_RHOST_RD_ADF_DATA4_OFFSET				    : std_logic_vector(15 downto 0) :=  x"411C";
    constant C_LSB_RHOST_RD_ADF_DATA5_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4120";
    constant C_LSB_RHOST_RD_ADF_DATA6_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4124";
    constant C_LSB_RHOST_RD_ADF_DATA7_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4128";
    constant C_LSB_RHOST_RD_ADF_DATA8_OFFSET				    : std_logic_vector(15 downto 0) :=  x"412C";
    constant C_LSB_RHOST_RD_ADF_DATA9_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4130";
    constant C_LSB_RHOST_RD_ADF_DATA10_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4134";
    constant C_LSB_RHOST_RD_ADF_DATA11_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4138";
    constant C_LSB_RHOST_RD_ADF_DATA12_OFFSET				    : std_logic_vector(15 downto 0) :=  x"413C";
    constant C_LSB_RHOST_RD_ADF_DATA13_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4140";
    constant C_LSB_RHOST_RD_ADF_DATA14_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4144";
    constant C_LSB_RHOST_RD_ADF_DATA15_OFFSET				    : std_logic_vector(15 downto 0) :=  x"4148";

    constant C_MSB_ADDR_SCAN_PARAMS_OFFSET                      : std_logic_vector(15 downto 0):=   x"1000"; --  --64 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian 
	constant C_ADDR_SCAN_PARAMS_DONE_OFFSET                 	: std_logic_vector(15 downto 0):=   x"1040"; --  --64 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian 
    constant C_MSB_ADDR_BLOCK_TRANSFER_TO_DMS_OFFSET            : std_logic_vector(15 downto 0):=   x"2000"; --  --512 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_ADDR_BLOCK_TRANSFER_TO_DMS_DONE_OFFSET       	: std_logic_vector(15 downto 0):=   x"2200"; --  --512 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_MSB_ADDR_PROGRAMMING_BRAM_OFFSET                 : std_logic_vector(15 downto 0):=   x"3000"; --  --512 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_ADDR_PROGRAMMING_BRAM_DONE_OFFSET            	: std_logic_vector(15 downto 0):=   x"3200"; --  --512 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_MSB_ADDR_ADF_OFFSET                              : std_logic_vector(15 downto 0):=   x"4000"; --  --32 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_ADDR_ADF_STATUS_OFFSET                       	: std_logic_vector(15 downto 0):=   x"40FF"; --  --32 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_MSB_ADDR_CDM_REGISTERS_OFFSET            		: std_logic_vector(15 downto 0):=   x"5000"; --  --512 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian

    constant C_END_OF_BLOCK                                 : std_logic_vector(31 downto 0) := x"10000001"; --  --32 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_ZEROS                                 : std_logic_vector(31 downto 0) := x"00000000"; --  --32 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian
    constant C_ONES                                 : std_logic_vector(31 downto 0) := x"11111111"; --  --32 bytes (Byte3, Byte2, Byte1, Byte0) Little Endian

---------------------------------------
    -- Array of registers
    type headers_arr            is array (0 to 63) of std_logic_vector(15 downto 0);
    --------------------------------------------------------------------------------- 
    -- Headers Description:
    --|WORD # | Index | Description|
    --|  1    |  0    | CT Type                                                                                                 
    --|  2    |  1    | DMS Status                                                                                                                                
    --|  3    |  2    | DMS Error                                                                               
    --|  4    |  3    | Integration time 
    --|  5    |  4    | Reference Detector 
    --|  6    |  5    | DMS Temperature 
    --|  7    |  6    | Reserved for DMS 
    --|  8    |  7    | DMS Temperature Control Status                                                              
    --|  9    |  8    | Reading No. Low                                                                         
    --|  10   |  9    | Reading No. High                                                                            
    --|  11   |  10   | Detection Setting 1                                                         
    --|  12   |  11   | Detection Setting 2                                                                             
    --|  13   |  12   | Detection Setting 3                                                 
    --|  14   |  13   | Detection Setting 4 and Temperature Reading Format version 
    --|  15   |  14   | Resend Counter                                                                      
    --|  16   |  15   | Vertical Couch Position                                                         
    --|  17   |  16   | Horizontal Couch Position                                                           
    --|  18   |  17   | Gantry Tilt                                                                         
    --|  19   |  18   | Rotation Angle                                                                  
    --|  20   |  19   | Rotor Angle during Data Sending                                                                         
    --|  21   |  20   | HW lines                                                        
    --|  22   |  21   | HW lines 2 
    --|  23   |  22   | Potential for FREE USE	
    --|  24   |  23   | "Bad Reading" details
    --|  25   |  24   | UID
    --|  26   |  25   | Shot Counter
    --|  27   |  26   | Potential for FREE USE	
    --|  28   |  27   | Angular Denominator
    --|  29   |  28   | Time Stamp Low
    --|  30   |  29   | Time Stamp High
    --|  31   |  30   | Number of Detectors
    --|  32   |  31   | UTC Time [15..00]
    --|  33   |  32   | UTC Time [31..16] 
    --|  34   |  33   | UTC Time [47..32]
    --|  35   |  34   | UTC Time [63..48] 
    --|  36   |  35   | Potential for Ref Det1	
    --|  37   |  36   | Potential for Ref Det2	             
    --|  38   |  37   | DMS Type
    --|  39   |  38   | Capability bits H
    --|  40   |  39   | Tube mA - Command
    --|  41   |  40   | Actual Tube mA
    --|  42   |  41   | Collimator 1 - Rear Blade
    --|  43   |  42   | Grid Voltage 1
    --|  44   |  43   | Grid Voltage 1
    --|  45   |  44   | Collimator 2 - Front Blade
    --|  46   |  45   | Capability bits M
    --|  47   |  46   | DMS Troubleshooting
    --|  48   |  47   | DMS Troubleshooting
    --|  49   |  48   | Filament Current
    --|  50   |  49   | mA (Actual Tube mA)
    --|  51   |  50   | kV (Actual Measured)
    --|  52   |  51   | Potential for FREE USE
    --|  53   |  52   | Capability bits L
    --|  54   |  53   | Potential for FREE USE
    --|  55   |  54   | ECG
    --|  56   |  55   | DOM mA
    --|  57   |  56   | Reading  No.  Low       
    --|  58   |  57   | Reading  No.  High   	  
    --|  59   |  58   | Data Pointer 0 [15..0]    
    --|  60   |  59   | Data Pointer 1 [31..16]    
    --|  61   |  60   | Potential for FREE USE	
    --|  62   |  61   | Potential for FREE USE	
    --|  63   |  62   | Potential for FREE USE	
    --|  64   |  63   | Stamp 
    -------------------------------------------------------------------------------- 
    type registers_ram          is array (0 to 1024) of std_logic_vector(31 downto 0);
    type registers_block        is array (0 to 1024) of std_logic_vector(31 downto 0);
    type header_block           is array (1 to 64) of std_logic_vector(31 downto 0);
    type header_footer_block    is array (1 to 9) of std_logic_vector(31 downto 0);
    type diag_Registers_Type    is array (25 downto 0) of std_logic_vector(15 downto 0);

---------------------------------------
    -- functions --
--    function bitwise_and(
--       in_vector : in std_logic_vector(3 downto 0)
--    )
--    return std_logic; 
 	constant NumOfFooterReg : natural :=16;                                             
    constant NumOfFooterRegBytes : natural :=12; --NumOfReg*2                          
    type t_reg_array is array (0 to NumOfFooterReg-1) of std_logic_vector(31 downto 0);	
    --------------------------------------------------------------------
    type cdc_reg_array is array (0 to 5-1) of std_logic_vector(31 downto 0);	
	------------------CRC8----------------------------------------------
	-- polynomial: x^8 + x^2 + x^1 + 1
	-- data width: 1
	-- convention: the first serial bit is D[N]
	function crc8_func (
		DATA_IN: std_logic_vector(7 DOWNTO 0);
		crc:  std_logic_vector(7 downto 0)
		)
	return std_logic_vector;
	function bin2onehot(Value : std_logic_vector) 
	return std_logic_vector;

--	function swap_bytes(Value : std_logic_vector) 
--	return std_logic_vector;
	
	function mask_32bit(value : std_logic_vector;
					mask : std_logic_vector
	)

	return std_logic_vector;
	function vec2int_div4(value : std_logic_vector
	)
	return integer;
	function log2_unsigned(value : natural
	)
	return natural;
	------------------CRC16----------------------------------------------
	-- polynomial: CCITT-CRC16 == X^16 +X^12 +X^5 +1
	-- data width: 1
	-- convention: the first serial bit is D[N]
	-- FUNCTION crc16_func (
    --     crc_clear :  std_logic;
    --     clk       :  std_logic;
    --     data      :  std_logic_vector(15 downto 0);
    --     ena       :  std_logic
    --     -- crc_out   : out std_logic_vector(15 downto 0)
	-- 	)
	-- RETURN std_logic_vector;
end package cdm_registers_pack;

package body cdm_registers_pack is
--    function bitwise_and(
--        in_vector : in std_logic_vector(3 downto 0)
--    )
--    return std_logic is 
--    begin
--        return (in_vector(0) and in_vector(1) and in_vector(2) and in_vector(3));
--    end;
	-------------------CRC8----------------------------------------------

		-- polynomial: x^8 + x^2 + x^1 + 1
		-- data width: 1
		-- convention: the first serial bit is D[N]
		
-- for debug:
-------------------------------
-- CRC polynomial coefficients: x^8 + x^2 + x + 1
--                              0x7 (hex)
-- CRC width:                   8 bits
-- CRC shift direction:         left (big endian)
-- Input word width:            8 bits

--------------------------------
-- Binary-Code to One-Hot-Code
function bin2onehot(Value : std_logic_vector) return std_logic_vector is
    variable result     : std_logic_vector(2**value'length - 1 downto 0);
begin
    result  := (others => '0');
    result(to_integer(unsigned(Value))) := '1';
    return result;
end function;
function log2_unsigned ( value : natural ) return natural is
    variable temp : natural := value ;
    variable n : natural := 0 ;
begin
    while temp > 1 loop
        temp := temp / 2 ;
        n := n + 1 ;
    end loop ;
    return n ;
end function log2_unsigned ;
--function swap_bytes(Value : std_logic_vector) return std_logic_vector is
--    variable result     : std_logic_vector(value'length - 1 downto 0);
--begin
--    result  := (others => '0');
--    result(value'length - 1 downto 0) := Value((value'length)/2 - 1 downto 0)&Value(value'length -1  downto (value'length)/2);
--    return result;
--end function;
-- div by 4 and convert to int
function vec2int_div4(value : std_logic_vector) return integer is
    variable result     : integer;
begin
    result := to_integer(Unsigned(value(value'length - 1 downto 2)));
    return result;
end function;
--mask 32 bit
function mask_32bit(
	value : std_logic_vector;
	mask : std_logic_vector

) return std_logic_vector is
    variable result     : std_logic_vector(value'length - 1 downto 0);
begin
    result  := (others => '0');
    result := value and (not mask);
    return result;
end function;
FUNCTION crc8_func (
--		            DATA: STD_LOGIC;
--		            CRC:  STD_LOGIC_VECTOR(7 DOWNTO 0)
					DATA_IN: STD_LOGIC_VECTOR(7 DOWNTO 0);
		            CRC:  STD_LOGIC_VECTOR(7 DOWNTO 0)
			)
		RETURN STD_LOGIC_VECTOR IS

--		VARIABLE d:      STD_LOGIC_VECTOR(0 DOWNTO 0);
--		VARIABLE c:      STD_LOGIC_VECTOR(7 DOWNTO 0);
--		VARIABLE newcrc: STD_LOGIC_VECTOR(7 DOWNTO 0);
		VARIABLE data:      STD_LOGIC_VECTOR(7 DOWNTO 0);
		VARIABLE crcIn:      STD_LOGIC_VECTOR(7 DOWNTO 0);
		VARIABLE newcrc: STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
	   data := DATA_IN;
	   crcIn := CRC;
	   newcrc(0) := (crcIn(0) xor crcIn(6) xor crcIn(7) xor data(0) xor data(6) xor data(7));
       newcrc(1) := (crcIn(0) xor crcIn(1) xor crcIn(6) xor data(0) xor data(1) xor data(6));
       newcrc(2) := (crcIn(0) xor crcIn(1) xor crcIn(2) xor crcIn(6) xor data(0) xor data(1) xor data(2) xor data(6));
       newcrc(3) := (crcIn(1) xor crcIn(2) xor crcIn(3) xor crcIn(7) xor data(1) xor data(2) xor data(3) xor data(7));
       newcrc(4) := (crcIn(2) xor crcIn(3) xor crcIn(4) xor data(2) xor data(3) xor data(4));
       newcrc(5) := (crcIn(3) xor crcIn(4) xor crcIn(5) xor data(3) xor data(4) xor data(5));
       newcrc(6) := (crcIn(4) xor crcIn(5) xor crcIn(6) xor data(4) xor data(5) xor data(6));
       newcrc(7) := (crcIn(5) xor crcIn(6) xor crcIn(7) xor data(5) xor data(6) xor data(7));
--		d(0) := DATA;
--		c := CRC;
----- CRC 8 bit MSB first
--		-- newcrc(0) := d(0) xor c(7);
--		-- newcrc(1) :=  c(0) xor c(7);
--		-- newcrc(2) :=  c(1) xor c(7);
--		-- newcrc(3) := c(2);
--		-- newcrc(4) := c(3);
--		-- newcrc(5) := c(4);
--		-- newcrc(6) := c(5);
--		-- newcrc(7) := c(6);

----- CRC 8 bit LSB first		
--		newcrc(0) :=c(1);
--		newcrc(1) := c(2);
--		newcrc(2) :=c(3);
--		newcrc(3) := c(4);
--		newcrc(4) :=c(5);
--		newcrc(5) := c(0) xor c(6) xor d(0);
--		newcrc(6) :=c(0) xor c(7)xor d(0);
--		newcrc(7) := c(0)xor d(0);
		
		RETURN newcrc;
	END crc8_func;
-- FUNCTION crc16_func (
--             crc_clear :  std_logic;
--             clk       :  std_logic;
--             data      :  std_logic_vector(15 downto 0);
--             ena       :  std_logic
--     -- crc_out   : out std_logic_vector(15 downto 0)
-- 			)
-- 		RETURN STD_LOGIC_VECTOR IS

-- 		VARIABLE crc : std_logic_vector(15 downto 0);
-- 		VARIABLE ex  : std_logic_vector(15 downto 0);
-- 		VARIABLE crc_out: STD_LOGIC_VECTOR(15 DOWNTO 0);

-- 	BEGIN
--             ex_g : for i in 0 to 15 generate
--                 ex(i) <= crc(i) xor data(i);
--             end generate;
--             if (crc_clear = '1') then
--                 crc <= (others => '0');
--             end if;   
--             if (ena = '1') then

--                 crc( 0) <= ex( 5) xor ex(12) xor ex( 8) xor ex(4);
--                 crc( 1) <= ex( 6) xor ex(13) xor ex( 9) xor ex(5);
--                 crc( 2) <= ex( 7) xor ex(14) xor ex(10) xor ex(6);
--                 crc( 3) <= ex( 0) xor ex( 8) xor ex(15) xor ex(11) xor ex(7);
--                 crc( 4) <= ex( 4) xor ex( 9) xor ex( 0) xor ex( 5) xor ex(1);
--                 crc( 5) <= ex( 5) xor ex(10) xor ex( 1) xor ex( 6) xor ex(2);
--                 crc( 6) <= ex( 6) xor ex(11) xor ex(0) xor ex( 2) xor ex( 7) xor ex(3);
--                 crc( 7) <= ex( 7) xor ex(12) xor ex(1) xor ex( 3) xor ex( 8) xor ex(4) xor ex(0);
--                 crc( 8) <= ex( 8) xor ex(13) xor ex(2) xor ex( 4) xor ex( 9) xor ex( 0) xor ex(5) xor ex(1);
--                 crc( 9) <= ex( 9) xor ex(14) xor ex(3) xor ex( 5) xor ex(10) xor ex( 1) xor ex(6) xor ex(2);
--                 crc(10) <= ex(10) xor ex(15) xor ex(4) xor ex( 6) xor ex(11) xor ex( 2) xor ex(7) xor ex(3);
--                 crc(11) <= ex(11) xor ex( 0) xor ex( 7) xor ex( 3);
--                 crc(12) <= ex(12) xor ex( 1) xor ex( 8) xor ex( 4) xor ex(0);
--                 crc(13) <= ex(13) xor ex( 2) xor ex( 9) xor ex( 5) xor ex(1);
--                 crc(14) <= ex(14) xor ex( 3) xor ex(10) xor ex( 6) xor ex(2);
--                 crc(15) <= ex(15) xor ex( 4) xor ex(11) xor ex( 7) xor ex(3);

--             end if;
		
-- 		RETURN crc;
-- 	END crc16_func;
end package body cdm_registers_pack;