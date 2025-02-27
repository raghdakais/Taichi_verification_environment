---------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/12/2022 10:12:23 AM
-- Design Name:
-- Module Name: REGISTER_BANK A - REGISTER_BANK_ARC
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - REGISTER_BANK A  18/7/2023
-- Revision 0.03 - REGISTER_BANK A with Diagnostic 15/10/2023
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.Registers_A_pack.ALL;
use work.phoebe.all;
use work.tbuf_pack.all;

entity REGISTER_BANK_A is

GENERIC(
         G_Module_ADDR_LENGTH   : INTEGER     := 16;
         G_DATA_LENGTH          : INTEGER     := 32
         );

Port (
    CLK                     :IN STD_LOGIC;
    RST                     :IN STD_LOGIC;
    WRITE                   :IN STD_LOGIC;--ACTIVE AT '1';
    READ                    :IN STD_LOGIC;--ACTIVE AT '1';
    ADDR                    :IN STD_LOGIC_VECTOR (G_Module_ADDR_LENGTH-1 DOWNTO 0);
    DATA_IN                 :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    REG_ADDR_NOT_VALID      :OUT STD_LOGIC;--VALID AT '0';
    DATA_OUT                :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_HL              :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_LL              :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    BAD_PIX_PER_TILE        :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONTROL_REGISTER_LSB    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    FIFO_RESET              :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONFIGURATION_STATUS    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_CONFIGURATION_STATUS                              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONFIGURATION_FIFO_RD_CNT                               :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_CONFIGURATION_FIFO_RD_CNT                         :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER             :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONFIG_WR_EN                                            : OUT STD_LOGIC;
    REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER          :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER    :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_NVRAM_STATUS                                     :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile1_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile2_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile3_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Tile4_Temperature                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Module_Inlet_Temperature                                :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Module_Outlet_Temperature                               :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Module_Average_Temperature                              :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    diag_7_8_sel_reg                                        :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 06/06/2024
    Asics_Aligned_4B0                                       :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 06/06/2024
    kP_reg                                                  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    kI_reg                                                  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    kD_reg                                                  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    kAW_reg                                                 :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Heater_Control                                          :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    SetPoint                                                :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Temperature_Weighted_Average_CFG                        :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    PID_Stable_Tolerance                                    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Temperature_Sample_and_rates                            :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Integral_and_Derivative_rates                           :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Status_and_Errors                                       :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    PWM_Duty_Cycle_IN			                            :IN std_logic_vector (7 DOWNTO 0);
 --   temporary_reg1                                        :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- removed  by Dalit 10/10/2023
    temporary_reg2                                          :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    timestamp                                               :In STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    fw_ver                                                  :In STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    board_ver                                               :In STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    Num_of_Slices                                           :In STD_LOGIC_VECTOR(6 downto 0);
    Module_Status_Errors_reg                                :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 04/12/2023
	    --added by tzvika sweetkin 26/07/2023
    NVRAM_ADDR_REG                                          :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NVRAM_DATA_REG                                          :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NVRAM_READ_DATA_REG                                     :in STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    NVRAM_STATUS_REG                                        :in STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    tile_packet_ok_timeout                                  :out STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);

    --added by Dalit 12/10/2023
    Diag_RX_ERRs                 : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
	Diag_TX_ERRs                 : IN	std_logic_vector (1 downto 0);    -- add by Dalit 10/10/2023
    Operational_RX_ERRs          : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
    Operational_TX_ERRs          : IN	std_logic_vector (1 downto 0);    -- add by Dalit 10/10/2023
    IP_HEADER_RX_ERRs            : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023
    Buffer_Control_RX_ERRs       : IN	std_logic_vector (3 downto 0);    -- add by Dalit 10/10/2023 --RX_ERR(0) '1' if not locked ,RX_ERR(1) '1' if no Idle word detected after sync, RX_ERR(2) '1' if crc ERROR ,RX_ERR(3) '1' general st_error
    Data_TX_ERRs                 : IN	std_logic_vector (1 downto 0);    -- add by Dalit 10/10/2023 --TX_ERR(0) '1'  if empty when RD_REQ  ,RX_ERR(1) '1' if fifo not empty after packet transaction
    AMS_CRC_ERRs_Counter         : IN  std_logic_vector(2*4*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
    AMS_CrcError                 : IN  std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
    AMS_CrcOk                    : IN  std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 19/9/2023
    Tile_data_align_o            : IN std_logic_vector(2*NumOfTiles-1 downto 0); ---add by Dalit 19/9/2023
    SPI_Errs                     : IN std_logic_vector(3*2*NumOfTiles-1 downto 0); ---add by Dalit 19/9/2023
    HD_Buffer_Overrun            : IN std_logic; -- add by Dalit 10/10/2023
    RTL_Buffer_Overrun           : IN std_logic; -- add by Dalit 10/10/2023
    PGOOD_0_75V                  : IN std_logic; --add by Dalit 12/10/2023-- 0.75v Good indication, VTT_PGOOD
    PGOOD_1_0V                   : IN std_logic; --add by Dalit 12/10/2023
    PGOOD_1_5V                   : IN std_logic; --add by Dalit 12/10/2023
    PGOOD_1_8V                   : IN std_logic; --add by Dalit 12/10/2023
    PGOOD_P1_5V                  : IN std_logic; --add by Dalit 12/10/2023-- analog voltage
    PGOOD_2_5V                   : IN std_logic; --add by Dalit 12/10/2023-- analog voltage
    Tile_power_monitor_footer    : IN std_logic_vector(2*(NumOfTiles*12)-1 downto 0); --add by Dalit 12/10/2023
    Operational_DIAGNSOTICS      : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); --add by Dalit 12/10/2023
    IP_too_short                 : IN std_logic; --add by Dalit 12/10/2023
    IP_too_long                  : IN std_logic; --add by Dalit 12/10/2023
    ddr_driver_errors            : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0); -- 06/06/2024
	MU_CTRL                      : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);  --add by Dalit 16/10/2023
	MODULE_DATA_OUT_SELCTION     : IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);  --add by Dalit 18/10/2023
	Remote_Programing_SM_Bits    : IN STD_LOGIC_VECTOR (1 DOWNTO 0); --add by Dalit 18/10/2023
	Asic_mode_Calibrated_or_Raw  : IN std_logic_vector(2*NumOfTiles-1 downto 0); --add by Dalit 18/10/2023
	footer_send					 : IN std_logic; --add by Dalit 15/10/2023
	OverRun_RTL_reset_flag       : OUT std_logic;  --add by Dalit 17/12/2023
    OverRun_HD_reset_flag        : OUT std_logic;  --add by Dalit 17/12/2023
    DMS_Coverage                 : OUT std_logic;  -- 24/07/2024
    synthetic_data_from_asic     : in std_logic   -- 25/06/2024    
  --  Min_reading_gap_reg          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  --add by Dalit 18/12/2023
 --   Min_reading_pointer_gap_reg  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  --add by  Dalit 18/12/2023
 --   RTL_buffer_deep	             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); --add by  Dalit 19/12/2023
 --   HD_buffer_deep	             : IN  STD_LOGIC_VECTOR(31 DOWNTO 0) --add by  Dalit 19/12/2023
);
end REGISTER_BANK_A;

architecture REGISTER_BANK_ARC of REGISTER_BANK_A is
type ReadWrite_sm_type is (idle, Read_sm, Write_sm);
signal ReadWrite_sm : ReadWrite_sm_type;
--signal go2read :STD_LOGIC;
SIGNAL S_REGISTER_0 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_1 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_2 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_3 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_4 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_5 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_6 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_7 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_8 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_9 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_10 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_11 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_12 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_13 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_14 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_15 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_16 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_17 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_18 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_19 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_20 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_21 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_22 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_23 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_24 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_25 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_26 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_27 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_28 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_29 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_30 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_31 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_32 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_33 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_34 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_35 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_36 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_37 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_38 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_39 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_40 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_41 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_42 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_43 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_44 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_45 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_46 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_47 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_48 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_49 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_50 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_51 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_52 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_53 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_54 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_55 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_56 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_57 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_58 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_59 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_60 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_61 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_62 :std_logic_vector(31 downto 0):=(OTHERS=>'0');
SIGNAL S_REGISTER_63 :std_logic_vector(31 downto 0):=(OTHERS=>'0');


SIGNAL S_DATA_IN :std_logic_vector(31 DOWNTO 0):=(OTHERS=>'0');
SIGNAL S_ADDR :std_logic_vector(15 DOWNTO 0):=(OTHERS=>'0');--(23 DOWNTO 0):=(OTHERS=>'0');

    --added by tzvika sweetkin 26/07/2023
SIGNAL S_REGISTER_100 :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by tzvika sweetkin 26/07/2023
SIGNAL S_REGISTER_101 :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by tzvika sweetkin 26/07/2023
SIGNAL S_REGISTER_102 :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by tzvika sweetkin 26/07/2023
SIGNAL S_REGISTER_103 :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by tzvika sweetkin 26/07/2023

SIGNAL S_Error_inject :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 15/10/2023
SIGNAL S_Error_inject_2 :std_logic_vector(31 downto 0):=(OTHERS=>'1'); --added by Dalit 15/10/2023
SIGNAL REGISTER_40_Error_inject :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 18/10/2023
SIGNAL REGISTER_42_Error_inject :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 15/10/2023
SIGNAL REGISTER_43_Error_inject :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 15/10/2023
SIGNAL REGISTER_45_Error_inject :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 15/10/2023
SIGNAL REGISTER_50_Error_inject :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 18/10/2023
SIGNAL Clear_after_read :std_logic_vector(31 downto 0):=(OTHERS=>'0'); --added by Dalit 15/10/2023
SIGNAL Module_Status_Errors_reg_read :std_logic:='0'; --add by Dalit 15/10/2023
SIGNAL Asic_mode_Calibrated_or_Raw_reg_read :std_logic:='0'; --add by Dalit 18/10/2023
SIGNAL AMS_SPI_Errors_reg_read :std_logic:='0'; --add by Dalit 15/10/2023
SIGNAL AMS_CRC_Errors_reg_read :std_logic:='0'; --add by Dalit 15/10/2023
SIGNAL AMS_Data_not_Aligned_reg_read :std_logic:='0'; --add by Dalit 15/10/2023
SIGNAL POWER_Errors_reg_read :std_logic:='0'; --add by Dalit 15/10/2023
SIGNAL module_mode_Calibrated_or_Raw :std_logic:='0'; --add by Dalit 18/10/2023
SIGNAL s_footer_send :std_logic; --add by Dalit 15/10/2023
SIGNAL power_monitor_footer_Asic_error :std_logic_vector(10 downto 0):=(OTHERS=>'0'); --added by Dalit 15/10/2023
TYPE ASICS_power_monitor_array is array (0 to 10) of std_logic_vector(7 downto 0); --add by Dalit 18/10/2023
SIGNAL power_monitor_footer_Asic:ASICS_power_monitor_array:=(OTHERS=>(OTHERS=>'0')); --add by Dalit 18/10/2023
--SIGNAL power_monitor_footer_Asic:std_logic_vector(10 downto 0):=(OTHERS=>'0'); --add by Dalit 19/12/2023
SIGNAL footer_w1_sent :std_logic:='0'; --add by Dalit 18/10/2023
SIGNAL footer_send_counter :integer range 0 to 5 :=0; --add by Dalit 18/10/2023
SIGNAL Asic_at_same_mode :std_logic:='0'; --add by Dalit 18/10/2023
SIGNAL S_READ :std_logic:='0'; --add by Dalit 18/10/2023
SIGNAL S2_READ :std_logic:='0'; --add by Dalit 18/10/2023
SIGNAL power_monitor_footer_Asic_check :std_logic_vector(10 downto 0):=(OTHERS=>'0'); --added by Dalit 15/11/2023

-- !debug: 20/02/2023
SIGNAL config_wr_en_i : STD_LOGIC;
--SIGNAL  asic_rdwr_exe_i : STD_LOGIC;
-- !debug: 08/05/2023
  signal test_reg_wrreq : std_logic;
  signal test_reg_seq_cnt : natural range 0 to 255;
  attribute DONT_TOUCH                    : string;
  attribute DONT_TOUCH of test_reg_wrreq, test_reg_seq_cnt, S_ADDR, S_DATA_IN : signal is "true";
  attribute mark_debug                    : string;
  attribute mark_debug of test_reg_wrreq, test_reg_seq_cnt, S_ADDR, S_DATA_IN : signal is "true";

begin
process (CLK, RST)

BEGIN


     IF RST='1' THEN --Active @ '1'

        ReadWrite_sm <=idle;
        S_DATA_IN<=(OTHERS=>'0');
        S_ADDR<=(OTHERS=>'0');
        REG_ADDR_NOT_VALID<='0';
        --OUTPUTS
        DATA_OUT<=(OTHERS=>'0');
        --Reset all registers
        S_REGISTER_0<=x"00000000";
        S_REGISTER_1<=x"20202020";
        S_REGISTER_2<=x"30303030";
        S_REGISTER_3<= X"000000FA";
        S_REGISTER_4<= X"00000002";
        S_REGISTER_5<=x"00000010";
        S_REGISTER_6<=x"00000000";--Dalit 22/01/2024 change default value
        S_REGISTER_7<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_8<=x"00000047"; -- !TODO: 05/09/2023 set default for 0x42  72uS   sim 0x4C
        S_REGISTER_9<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_10<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_11<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_12<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_13<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_14<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_15<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_16<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_17<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_18<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_19<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_20<=x"00000000"; --Dalit 22/01/2024 change default value
        S_REGISTER_21<=x"01A00190";     -- 15/08/2023 defaults: Module Outlet Temperature - 26DegC & Inlet Temperature - 25DegC
        S_REGISTER_22<=x"00000000";     -- (R)
        S_REGISTER_23<=x"00000000";   --Dalit 22/01/2024 change default value
        S_REGISTER_24<=x"00000020";     -- 15/08/2023 kP
        S_REGISTER_25<=x"00000005";     -- 15/08/2023 kI
        S_REGISTER_26<=x"00000004";     -- 15/08/2023 Kd
        S_REGISTER_27<=x"00000080";     -- 15/08/2023 kAW
        S_REGISTER_28<=x"00000000";     -- Heater Control (R/W) [9..8] 0=OFF, 1=Manual, 2=Auto, [7..0] 0% Heater, defaults: 0x0
        S_REGISTER_29<=x"00002100";     -- 15/08/2023 SetPoint, defaults: 0x2100 33DegC
        S_REGISTER_30<=x"00000004";     -- 15/08/2023 Sensor1_influence, defaults: 0x4	50%
        S_REGISTER_31<=X"70251008";     -- PID Stable_Tolerance (R/W)
        S_REGISTER_32<=x"000A0005";     -- 15/08/2023 defaults: Calc_PID_reg, defaults: 0x000A	Every 1 Sec &  Sample_reg 0x0005	Every 0.5 Sec
        S_REGISTER_33<=x"00000B00";     -- 15/08/2023 Integrat_update_time, defaults: 0x0B00	Every 11 Calc_PID pulses
        S_REGISTER_34<=x"00000000";     -- (R)
        S_REGISTER_35<=x"00000000";     -- (R)
        S_REGISTER_36<=x"00000000";
        S_REGISTER_37<=x"00000000";
        S_REGISTER_38<=x"00000000";
        S_REGISTER_39<=x"00000000";
        S_REGISTER_40<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_41<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_42<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_43<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_44<=x"30303030"; -- dalit 15/10/2023
        S_REGISTER_45<=x"30303030"; -- dalit 15/10/2023
        S_REGISTER_46<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_47<=x"00000000"; -- dalit 15/10/2023
		S_REGISTER_48<=x"00000001"; --Dalit 22/01/2024 change default value
        S_REGISTER_49<=x"00000001"; --Dalit 22/01/2024 change default value
		S_REGISTER_50<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_51<=x"00000000"; -- dalit 15/10/2023
        S_REGISTER_52<=x"FFFFFFFF"; --Dalit 22/01/2024 change default value
        S_REGISTER_53<=x"00000000"; -- dalit 15/10/2023
		S_REGISTER_54<=x"FFFFFFFF"; -- dalit 13/11/2023
        S_REGISTER_55<=x"00000005"; -- dalit 17/12/2023 Min_reading_gap_reg for RLT buffer calculator
        S_REGISTER_56<=x"00000005"; -- dalit 17/12/2023 Min_reading_pointer_gap_reg for HD buffer calculator
        S_REGISTER_57<=x"00420000"; --Dalit 22/01/2024 change default value  RTL_buffer_deep
        S_REGISTER_58<=x"1F43CCF7"; --Dalit 22/01/2024 change default value  HD_buffer_deep
        S_REGISTER_59<=x"00000000";
        --spare
        S_REGISTER_60<=x"0000003C";
        S_REGISTER_61<=x"0000003D";
        S_REGISTER_62<=x"0000003E";
        S_REGISTER_63<=x"0000003F";

        config_wr_en_i<='0';
        CONFIG_WR_EN<='0';

        --add by dalit 5/11/2023
		S_Error_inject <= (OTHERS=>'0');
		S_Error_inject_2 <= (OTHERS=>'1');
		REGISTER_40_Error_inject <= (OTHERS=>'0');
		REGISTER_42_Error_inject <= (OTHERS=>'0');
		REGISTER_43_Error_inject <= (OTHERS=>'0');
		REGISTER_45_Error_inject <= (OTHERS=>'0');
		REGISTER_50_Error_inject <= (OTHERS=>'0');
		Clear_after_read <= (OTHERS=>'0');
		Module_Status_Errors_reg_read <='0';
		Asic_mode_Calibrated_or_Raw_reg_read <='0';
		AMS_SPI_Errors_reg_read <='0';
		AMS_CRC_Errors_reg_read <='0';
		AMS_Data_not_Aligned_reg_read <='0';
		module_mode_Calibrated_or_Raw <='0';
		POWER_Errors_reg_read <='0';
		s_footer_send <='0';
		power_monitor_footer_Asic<=(OTHERS=>(OTHERS=>'0'));
		footer_w1_sent <='0';
		footer_send_counter <=0;
		Asic_at_same_mode <='0';
		S_READ<='0';   --dalit 12/11/2023
        S2_READ<='0'; --dalit 12/11/2023
    --    Min_reading_gap_reg<=x"00000005"; ---add by Dalit 18/12/2023
    --    Min_reading_pointer_gap_reg<=x"00000005"; ---add by Dalit 18/12/2023
        diag_7_8_sel_reg <= (others => '0');
        Asics_Aligned_4B0 <= (others => '0');
        DMS_Coverage <= '0';
     ELSIF RISING_EDGE(CLK) THEN

        S_READ<=READ;   --dalit 12/11/2023
        S2_READ<=S_READ; --dalit 12/11/2023
        S_DATA_IN<=DATA_IN;
        S_ADDR<=ADDR;
        BAD_PIX_HL                   <=S_REGISTER_3         ;
        BAD_PIX_LL                   <=S_REGISTER_4         ;
        BAD_PIX_PER_TILE             <=S_REGISTER_5         ;
        CONTROL_REGISTER_LSB         <=S_REGISTER_11         ;
        FIFO_RESET                   <=S_REGISTER_12         ;
        CONFIGURATION_STATUS                            <=WR_TO_CONFIGURATION_STATUS         ;-- read only from CDM, Can be writen only from module
        CONFIGURATION_FIFO_RD_CNT                       <=WR_TO_CONFIGURATION_FIFO_RD_CNT    ;-- read only from CDM, Can be writen only from module
        REMOTE_CONFIGURATION_DATA_IN_TO_PAGE_BUFFER     <=S_REGISTER_15         ;
        REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER  <=WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER         ;  -- read only from CDM, Can be writen only from module

        tile_packet_ok_timeout <= S_REGISTER_8;

        diag_7_8_sel_reg <= S_REGISTER_23; -- 06/06/2024 0xA0X0651C

        kP_reg <= S_REGISTER_24;
        kI_reg <= S_REGISTER_25;
        kD_reg <= S_REGISTER_26;
        kAW_reg <= S_REGISTER_27;
        Heater_Control <= S_REGISTER_28;
        SetPoint <= S_REGISTER_29;
        Temperature_Weighted_Average_CFG <= S_REGISTER_30;
        PID_Stable_Tolerance <= S_REGISTER_31;
        Temperature_Sample_and_rates <= S_REGISTER_32;
        Integral_and_Derivative_rates <= S_REGISTER_33;

		-- added by tzvika sweetkin 26/07/2023
        NVRAM_ADDR_REG <= S_REGISTER_36;
        NVRAM_DATA_REG <= S_REGISTER_37;

        Asics_Aligned_4B0 <= S_REGISTER_44; -- 06/06/2024

    --    Min_reading_gap_reg <= S_REGISTER_55; ---add by Dalit 18/12/2023
    --    Min_reading_pointer_gap_reg<= S_REGISTER_56; ---add by Dalit 18/12/2023

        config_wr_en_i<='0';

        IF ADDR(15 DOWNTO 12) = X"6" THEN
            REG_ADDR_NOT_VALID<='0';
        ELSE
            REG_ADDR_NOT_VALID<='1'; --NOT VALID
        END IF;
        CASE ReadWrite_sm IS

       WHEN IDLE=>
                IF READ='1' THEN
                     ReadWrite_sm<=READ_sm;
                ELSIF WRITE='1' THEN --and go2read='0' and READ='0' THEN --AFTER WRITE, MAKE READ
                    ReadWrite_sm<=WRITE_sm;

                END IF;
       WHEN READ_sm=>
                 ReadWrite_sm<=IDLE;
                 S_REGISTER_11(31) <= '0'; -- 16/08/2023 Execute auto-clear
                 S_REGISTER_12(1) <= '0'; -- Fifo reset and error reset auto-clear

            CASE S_ADDR IS

             WHEN REGISTER_0=>
        			             DATA_OUT<=S_REGISTER_0;
             WHEN REGISTER_1=>
                    			DATA_OUT<=S_REGISTER_1;
        --     WHEN REGISTER_2=>						--remove by Dalit 15/10/2023
         --           			DATA_OUT<=S_REGISTER_2;
             WHEN REGISTER_3=>
                    			DATA_OUT<=S_REGISTER_3;
             WHEN REGISTER_4=>
                    			 DATA_OUT<=S_REGISTER_4;
             WHEN REGISTER_5=>
                    			 DATA_OUT<=S_REGISTER_5;
             WHEN REGISTER_6=>
                    			 DATA_OUT<=S_REGISTER_6;
             WHEN REGISTER_7=>
                    			 DATA_OUT<=S_REGISTER_7;
         --    WHEN REGISTER_8=>
         --           			 DATA_OUT<=S_REGISTER_8;  --remove by Dalit 15/10/2023
             WHEN REGISTER_9=>
                    			 DATA_OUT<=S_REGISTER_9;
             WHEN REGISTER_10=>
                    			 DATA_OUT<=S_REGISTER_10;
             WHEN REGISTER_11=>
                    			 DATA_OUT<=S_REGISTER_11;
             WHEN REGISTER_12=>
                    			 DATA_OUT<=S_REGISTER_12;
             WHEN REGISTER_13=>
                    			 DATA_OUT<=S_REGISTER_13;
             WHEN REGISTER_14=>
                    			DATA_OUT<=S_REGISTER_14;
             WHEN REGISTER_15=>
                    			DATA_OUT<=S_REGISTER_15;
             WHEN REGISTER_16=>
                    			DATA_OUT<=S_REGISTER_16;
             WHEN REGISTER_17=>
                    			DATA_OUT<=S_REGISTER_17;
             WHEN REGISTER_18=>
                    			DATA_OUT<=S_REGISTER_18;
             WHEN REGISTER_19=>
                    			DATA_OUT<=S_REGISTER_19;
             WHEN REGISTER_20=>
                    			DATA_OUT<=S_REGISTER_20;
             WHEN REGISTER_21=>
                    			DATA_OUT<=S_REGISTER_21;
             WHEN REGISTER_22=>
                    			DATA_OUT<=S_REGISTER_22;
             WHEN REGISTER_23=>
                    			DATA_OUT<=S_REGISTER_23;
             WHEN REGISTER_24=>
                    			 DATA_OUT<=S_REGISTER_24;
             WHEN REGISTER_25=>
                    			 DATA_OUT<=S_REGISTER_25;
             WHEN REGISTER_26=>
                    			 DATA_OUT<=S_REGISTER_26;
             WHEN REGISTER_27=>
                    			 DATA_OUT<=S_REGISTER_27;
             WHEN REGISTER_28=>
                    			 DATA_OUT<=S_REGISTER_28;
             WHEN REGISTER_29=>
                    			 DATA_OUT<=S_REGISTER_29;
             WHEN REGISTER_30=>
                    			 DATA_OUT<=S_REGISTER_30;
             WHEN REGISTER_31=>
                    			 DATA_OUT<=S_REGISTER_31;
             WHEN REGISTER_32=>
                    			DATA_OUT<=S_REGISTER_32;
             WHEN REGISTER_33=>
                    			DATA_OUT<=S_REGISTER_33;
             WHEN REGISTER_34=>
                    			DATA_OUT<=S_REGISTER_34;
             WHEN REGISTER_35=>
                    			DATA_OUT<=S_REGISTER_35;
             WHEN REGISTER_36=>
                    			DATA_OUT<=S_REGISTER_36;
             WHEN REGISTER_37=>
                    			DATA_OUT<=S_REGISTER_37;
             WHEN REGISTER_38=>
                    			DATA_OUT<=S_REGISTER_38;
             WHEN REGISTER_39=>
                    			DATA_OUT<=S_REGISTER_39;
			WHEN REGISTER_40=>
                    			 DATA_OUT<=S_REGISTER_40;
                    			 POWER_Errors_reg_read<='1';
             WHEN REGISTER_41=>							 --register X"6424" - Module Status/Errors register
                    			 DATA_OUT<=S_REGISTER_41;
								 Module_Status_Errors_reg_read<='1'; --add by Dalit 15/10/2023
             WHEN REGISTER_42=>
                    			 DATA_OUT<=S_REGISTER_42;
								 AMS_SPI_Errors_reg_read<='1'; --add by Dalit 15/10/2023
             WHEN REGISTER_43=>
                    			 DATA_OUT<=S_REGISTER_43;
								 AMS_CRC_Errors_reg_read<='1'; --add by Dalit 15/10/2023
             WHEN REGISTER_44=>
                    			 DATA_OUT<=S_REGISTER_44;
             WHEN REGISTER_45=>
                    			 DATA_OUT<=S_REGISTER_45;
								 AMS_Data_not_Aligned_reg_read<='1'; --add by Dalit 15/10/2023
             WHEN REGISTER_46=>
                    			 DATA_OUT<=S_REGISTER_46;
             WHEN REGISTER_47=>
                    			 DATA_OUT<=S_REGISTER_47;
             WHEN REGISTER_48=>
                    			DATA_OUT<=S_REGISTER_48;
             WHEN REGISTER_49=>
                    			DATA_OUT<=S_REGISTER_49;
			 WHEN REGISTER_50=>
                    			DATA_OUT<=S_REGISTER_50;
                    			Asic_mode_Calibrated_or_Raw_reg_read<='1'; --add by Dalit 18/10/2023
             WHEN REGISTER_51=>
                    			DATA_OUT<=S_REGISTER_51;
             WHEN REGISTER_52=>
                    			DATA_OUT<=S_REGISTER_52; --X"64D0"; --  Clear after Read for register X"6424"
             WHEN REGISTER_53=>
                    			DATA_OUT<=S_REGISTER_53; -- Error inject1 (or gate defult x"00000000")for Clear after Read bits at register X"6424"
			 WHEN REGISTER_54=>
                    			DATA_OUT<=S_REGISTER_54; -- Error inject2 (and gate defult x"11111111") for Clear after Read bits at register X"6424"
             WHEN REGISTER_55=>
                    			DATA_OUT<=S_REGISTER_55;
             WHEN REGISTER_56=>
                    			DATA_OUT<=S_REGISTER_56;
             WHEN REGISTER_57=>
                    			DATA_OUT<=S_REGISTER_57;
             WHEN REGISTER_58=>
                    			DATA_OUT<=S_REGISTER_58;
              --spare
             WHEN REGISTER_59=>
                    			DATA_OUT<=S_REGISTER_59;
             WHEN REGISTER_60=>
                    			DATA_OUT<=S_REGISTER_60;
             WHEN REGISTER_61=>
                    			DATA_OUT<=S_REGISTER_61;
             WHEN REGISTER_62=>
                    			DATA_OUT<=S_REGISTER_62;
             WHEN REGISTER_63=>
                    			DATA_OUT<=S_REGISTER_63;

            WHEN OTHERS => NULL;
            END CASE;


     WHEN WRITE_sm=>

            ReadWrite_sm<=READ_sm;

            CASE S_ADDR IS

            WHEN REGISTER_0=>
        			            -- S_REGISTER_0<=S_DATA_IN;
        	WHEN REGISTER_1=>
        			           -- S_REGISTER_1<=S_DATA_IN;
        --	WHEN REGISTER_2=>								--remove by Dalit 15/10/2023
        			            -- S_REGISTER_2<=S_DATA_IN;
            WHEN REGISTER_3=>
                    			 S_REGISTER_3<=S_DATA_IN;
            WHEN REGISTER_4=>
                    			 S_REGISTER_4<=S_DATA_IN;
            WHEN REGISTER_5=>
                    			 S_REGISTER_5<=S_DATA_IN;
            WHEN REGISTER_6=>
                    			 S_REGISTER_6<=S_DATA_IN;
            WHEN REGISTER_7=>
                    			-- S_REGISTER_7<=S_DATA_IN;
            WHEN REGISTER_8=>
                    		 	S_REGISTER_8<=S_DATA_IN;   --remove by Dalit 15/10/2023
            WHEN REGISTER_9=>
                    		--	 S_REGISTER_9<=S_DATA_IN;
            WHEN REGISTER_10=>
                    		--	 S_REGISTER_10<=S_DATA_IN;
            WHEN REGISTER_11=>
                    			 S_REGISTER_11<=S_DATA_IN;
            WHEN REGISTER_12=>
                    			 S_REGISTER_12<=S_DATA_IN;
            WHEN REGISTER_13=>
                    		--Configuration status 6830 CAN BE READ ONLY FROM CDM
                    		--	 S_REGISTER_13<=S_DATA_IN;
            WHEN REGISTER_14=>
                    		--Configuration FIFO RD count 6840 CAN BE READ ONLY FROM idle
                    		--	S_REGISTER_14<=S_DATA_IN;
            WHEN REGISTER_15=>
                    			S_REGISTER_15<=S_DATA_IN;
                    			config_wr_en_i<='1';--CREATE PULSE FOR 1 CLK
            WHEN REGISTER_16=>
                    		--remote configuration Data out from page buffer 6860 CAN BE READ ONLY FROM idle
                    		--	S_REGISTER_16<=S_DATA_IN;
            WHEN REGISTER_17=>
                   		--	     S_REGISTER_17<=S_DATA_IN;
            WHEN REGISTER_18=>
                   		--	     S_REGISTER_18<=S_DATA_IN;
            WHEN REGISTER_19=>
            --        			S_REGISTER_19<=S_DATA_IN;
            WHEN REGISTER_20=>
            --        			S_REGISTER_20<=S_DATA_IN;
            WHEN REGISTER_21=>
            --        			S_REGISTER_21<=S_DATA_IN;
            WHEN REGISTER_22=>
            --        			S_REGISTER_22<=S_DATA_IN;
            WHEN REGISTER_23=>
                    			S_REGISTER_23<=S_DATA_IN;
            WHEN REGISTER_24=>
                    			 S_REGISTER_24<=S_DATA_IN;
            WHEN REGISTER_25=>
                    			 S_REGISTER_25<=S_DATA_IN;
            WHEN REGISTER_26=>
                    			 S_REGISTER_26<=S_DATA_IN;
            WHEN REGISTER_27=>
                    			 S_REGISTER_27<=S_DATA_IN;
            WHEN REGISTER_28=>
                    			 S_REGISTER_28<=S_DATA_IN;
            WHEN REGISTER_29=>
                    			 S_REGISTER_29<=S_DATA_IN;
            WHEN REGISTER_30=>
                    			 S_REGISTER_30<=S_DATA_IN;
            WHEN REGISTER_31=>
                    			 S_REGISTER_31<=S_DATA_IN;
            WHEN REGISTER_32=>
                    			S_REGISTER_32<=S_DATA_IN;
            WHEN REGISTER_33=>
                    			S_REGISTER_33<=S_DATA_IN;
            WHEN REGISTER_34=>
                    		--	S_REGISTER_34<=S_DATA_IN;
            WHEN REGISTER_35=>
                    	--		S_REGISTER_35<=S_DATA_IN;
            WHEN REGISTER_36=>
                    			S_REGISTER_36<=S_DATA_IN;
            WHEN REGISTER_37=>
                    			S_REGISTER_37<=S_DATA_IN;
            WHEN REGISTER_38=>
                    		--NVRAM read data- read only reg
                    		--	S_REGISTER_38<=S_DATA_IN;
            WHEN REGISTER_39=>
                    		--NVRAM status read only reg
							--	S_REGISTER_39<=S_DATA_IN;

		    WHEN REGISTER_40=>
                    		--	 S_REGISTER_40<=S_DATA_IN;
                    		      REGISTER_40_Error_inject<=S_DATA_IN;	--add by Dalit 15/10/2023
            WHEN REGISTER_41=>
                    		--	 S_REGISTER_41<=S_DATA_IN;
            WHEN REGISTER_42=>
                    	--		 S_REGISTER_42<=S_DATA_IN;
								 REGISTER_42_Error_inject<=S_DATA_IN;	--add by Dalit 15/10/2023
            WHEN REGISTER_43=>
                    	--		 S_REGISTER_43<=S_DATA_IN;
								 REGISTER_43_Error_inject<=S_DATA_IN;	--add by Dalit 15/10/2023
            WHEN REGISTER_44=>
                    	--		 S_REGISTER_44<=S_DATA_IN;
            WHEN REGISTER_45=>
                    	--		 S_REGISTER_45<=S_DATA_IN;
								 REGISTER_45_Error_inject<=S_DATA_IN;	--add by Dalit 15/10/2023
            WHEN REGISTER_46=>
                    	--		 S_REGISTER_46<=S_DATA_IN;
            WHEN REGISTER_47=>
                    	--		 S_REGISTER_47<=S_DATA_IN;
            WHEN REGISTER_48=>
                    			S_REGISTER_48<=S_DATA_IN;
            WHEN REGISTER_49=>
                    			S_REGISTER_49<=S_DATA_IN;
            WHEN REGISTER_50=>
                    		--	S_REGISTER_50<=S_DATA_IN;
                    		    REGISTER_50_Error_inject<=S_DATA_IN; --add by Dalit 18/10/2023
            WHEN REGISTER_51=>
                    			-- S_REGISTER_51<=S_DATA_IN;
            WHEN REGISTER_52=>
                    			S_REGISTER_52<=S_DATA_IN;
                    			Clear_after_read<=S_DATA_IN;  --add by Dalit 15/10/2023
            WHEN REGISTER_53=>
                    		    S_REGISTER_53<=S_DATA_IN;   -- Error inject (or gate defult x"00000000")for Clear after Read bits at register X"6424"
								S_Error_inject<=S_DATA_IN;

			WHEN REGISTER_54=>
                    			S_REGISTER_54<=S_DATA_IN; -- Error inject (and gate defult x"FFFFFFFF")for Clear after Read bits at register X"6424"
                    			S_Error_inject_2<=S_DATA_IN;
            WHEN REGISTER_55=>
                    			S_REGISTER_55<=S_DATA_IN;
            WHEN REGISTER_56=>
                    			S_REGISTER_56<=S_DATA_IN;
            WHEN REGISTER_57=>
                    		--	S_REGISTER_57<=S_DATA_IN; --RTL_buffer_deep -read only register
            WHEN REGISTER_58=>
                    		--	S_REGISTER_58<=S_DATA_IN; --HD_buffer_deep -read only register
              --spare
            WHEN REGISTER_59=>
                    			S_REGISTER_59<=S_DATA_IN;
            WHEN REGISTER_60=>
                    			S_REGISTER_60<=S_DATA_IN;
            WHEN REGISTER_61=>
                    			S_REGISTER_61<=S_DATA_IN;
            WHEN REGISTER_62=>
                    			S_REGISTER_62<=S_DATA_IN;
            WHEN REGISTER_63=>
                    			S_REGISTER_63<=S_DATA_IN;

            WHEN OTHERS=>NULL;
            END CASE;

  WHEN OTHERS=>
       END CASE;

       -- !debug: 21/02/2023 registers, driven from FPGA
       S_REGISTER_0 <= timestamp; -- 0x4C timestamp address
       S_REGISTER_1 <= AMS_CRC_ERRs_Counter;  -- temporary_reg1 --changed by Dalit 10/10/2023
       S_REGISTER_2 <= temporary_reg2;
       S_REGISTER_6 <= fw_ver;      -- 0x40 Firmware Version address
       S_REGISTER_7 <= board_ver;      -- 0x41 Hardware Board Revision address
       S_REGISTER_9 <= X"000000" & '0' & Num_of_Slices;
       S_REGISTER_10 <= (others => '0'); -- !TODO: 23/04/2023 IP Calculated
       S_REGISTER_13 <= WR_TO_CONFIGURATION_STATUS;
       S_REGISTER_14 <= WR_TO_CONFIGURATION_FIFO_RD_CNT;
       S_REGISTER_16 <= WR_TO_REMOTE_CONFIGURATION_DATA_OUT_FROM_PAGE_BUFFER;
       S_REGISTER_17 <= Tile1_Temperature;
       S_REGISTER_18 <= Tile2_Temperature;
       S_REGISTER_19 <= Tile3_Temperature;
       S_REGISTER_20 <= Tile4_Temperature;
       S_REGISTER_21 <= Module_Outlet_Temperature(15 downto 0) & Module_Inlet_Temperature(15 downto 0);
       S_REGISTER_22 <= Module_Average_Temperature;
       S_REGISTER_34 <= Status_and_Errors;
       S_REGISTER_35 <= X"000000" & PWM_Duty_Cycle_IN;
       S_REGISTER_51 <= ddr_driver_errors; -- 06/06/2024
	   S_REGISTER_57 <= std_logic_vector(resize(RTL_buffer_deep,32)) ;  --add by Dalit 20/12/2023
	   S_REGISTER_58 <= std_logic_vector(resize(HD_buffer_deep,32)) ;  --add by Dalit 20/12/2023
	   CONFIG_WR_EN<=config_wr_en_i;    -- !debug: 20/02/2023 ES: delay by 1 clk

	  -- added by tzvika sweetkin 26/07/2023
	   S_REGISTER_38 <= NVRAM_READ_DATA_REG;
       S_REGISTER_39 <= NVRAM_STATUS_REG;
	   if (S_REGISTER_36(31) = '1') then --reset enable after 1 clk
            S_REGISTER_36(31) <= '0';
       end if;
       if (S_REGISTER_37(31) = '1') then --reset enable after 1 clk
            S_REGISTER_37(31) <= '0';
       end if;

	  --added by Dalit 15/10/2023
	-------------------------------------------------------------------------------------------------------------------------------------------------------------
	   ---change by Dalit 4/12/2023
--	   power_monitor_footer_Asic(10 downto 0)<= Tile_power_monitor_footer(10 downo 0)
--	                               or Tile_power_monitor_footer(22 downo 12)
--	                               or Tile_power_monitor_footer(34 downo 24)
--	                               or Tile_power_monitor_footer(46 downo 36)
--	                               or Tile_power_monitor_footer(58 downo 48)
--	                               or Tile_power_monitor_footer(70 downo 60)
--	                               or Tile_power_monitor_footer(82 downo 72)
--	                               or Tile_power_monitor_footer(94 downo 84) ;

	   power_monitor_footer_Asic(0) <=Tile_power_monitor_footer(0+12*7)& Tile_power_monitor_footer(0+12*6)& Tile_power_monitor_footer(0+12*5)& Tile_power_monitor_footer(0+12*4)& Tile_power_monitor_footer(0+12*3)& Tile_power_monitor_footer(0+12*2)& Tile_power_monitor_footer(0+12*1)& Tile_power_monitor_footer(0);
	   power_monitor_footer_Asic(1) <=Tile_power_monitor_footer(1+12*7)& Tile_power_monitor_footer(1+12*6)& Tile_power_monitor_footer(1+12*5)& Tile_power_monitor_footer(1+12*4)& Tile_power_monitor_footer(1+12*3)& Tile_power_monitor_footer(1+12*2)& Tile_power_monitor_footer(1+12*1)& Tile_power_monitor_footer(1);
	   power_monitor_footer_Asic(2) <=Tile_power_monitor_footer(2+12*7)& Tile_power_monitor_footer(2+12*6)& Tile_power_monitor_footer(2+12*5)& Tile_power_monitor_footer(2+12*4)& Tile_power_monitor_footer(2+12*3)& Tile_power_monitor_footer(2+12*2)& Tile_power_monitor_footer(2+12*1)& Tile_power_monitor_footer(2);
	   power_monitor_footer_Asic(3) <=Tile_power_monitor_footer(3+12*7)& Tile_power_monitor_footer(3+12*6)& Tile_power_monitor_footer(3+12*5)& Tile_power_monitor_footer(3+12*4)& Tile_power_monitor_footer(3+12*3)& Tile_power_monitor_footer(3+12*2)& Tile_power_monitor_footer(3+12*1)& Tile_power_monitor_footer(3);
	   power_monitor_footer_Asic(4) <=Tile_power_monitor_footer(4+12*7)& Tile_power_monitor_footer(4+12*6)& Tile_power_monitor_footer(4+12*5)& Tile_power_monitor_footer(4+12*4)& Tile_power_monitor_footer(4+12*3)& Tile_power_monitor_footer(4+12*2)& Tile_power_monitor_footer(4+12*1)& Tile_power_monitor_footer(4);
	   power_monitor_footer_Asic(5) <=Tile_power_monitor_footer(5+12*7)& Tile_power_monitor_footer(5+12*6)& Tile_power_monitor_footer(5+12*5)& Tile_power_monitor_footer(5+12*4)& Tile_power_monitor_footer(5+12*3)& Tile_power_monitor_footer(5+12*2)& Tile_power_monitor_footer(5+12*1)& Tile_power_monitor_footer(5);
	   power_monitor_footer_Asic(6) <=Tile_power_monitor_footer(6+12*7)& Tile_power_monitor_footer(6+12*6)& Tile_power_monitor_footer(6+12*5)& Tile_power_monitor_footer(6+12*4)& Tile_power_monitor_footer(6+12*3)& Tile_power_monitor_footer(6+12*2)& Tile_power_monitor_footer(6+12*1)& Tile_power_monitor_footer(6);
	   power_monitor_footer_Asic(7) <=Tile_power_monitor_footer(7+12*7)& Tile_power_monitor_footer(7+12*6)& Tile_power_monitor_footer(7+12*5)& Tile_power_monitor_footer(7+12*4)& Tile_power_monitor_footer(7+12*3)& Tile_power_monitor_footer(7+12*2)& Tile_power_monitor_footer(7+12*1)& Tile_power_monitor_footer(7);
	   power_monitor_footer_Asic(8) <=Tile_power_monitor_footer(8+12*7)& Tile_power_monitor_footer(8+12*6)& Tile_power_monitor_footer(8+12*5)& Tile_power_monitor_footer(8+12*4)& Tile_power_monitor_footer(8+12*3)& Tile_power_monitor_footer(8+12*2)& Tile_power_monitor_footer(8+12*1)& Tile_power_monitor_footer(8);
	   power_monitor_footer_Asic(9) <=Tile_power_monitor_footer(9+12*7)& Tile_power_monitor_footer(9+12*6)& Tile_power_monitor_footer(9+12*5)& Tile_power_monitor_footer(9+12*4)& Tile_power_monitor_footer(9+12*3)& Tile_power_monitor_footer(9+12*2)& Tile_power_monitor_footer(9+12*1)& Tile_power_monitor_footer(9);
	   power_monitor_footer_Asic(10)<=Tile_power_monitor_footer(10+12*7)& Tile_power_monitor_footer(10+12*6)& Tile_power_monitor_footer(10+12*5)& Tile_power_monitor_footer(10+12*4)& Tile_power_monitor_footer(10+12*3)& Tile_power_monitor_footer(10+12*2)& Tile_power_monitor_footer(10+12*1)& Tile_power_monitor_footer(10);
	  ------------------------------------
	   for i in 0 to 10 loop
	     if power_monitor_footer_Asic(i)=x"00" then
			power_monitor_footer_Asic_check(i)<= '0';
		 else
		    power_monitor_footer_Asic_check(i)<= '1';
	      end if;
	    end loop;

	    if (S_REGISTER_40=x"00000000") then   -- one or more Module and Asics power error
	       S_REGISTER_41(30) <= '0';
	    else
	       S_REGISTER_41(30) <= '1';
	    end if;
	--  if (POWER_Errors_reg_read='1' and Clear_after_read(30)='1') THEN
	   if (S2_READ='1' and S_ADDR=REGISTER_40 and Clear_after_read(30)='1') THEN
				S_REGISTER_40<=x"00000000";
				POWER_Errors_reg_read<='0';
	  else
	   S_REGISTER_40(31 downto 22)<= "0000000000"; --spare
	   S_REGISTER_40(21)<=REGISTER_40_Error_inject(21) or S_REGISTER_40(21) or (not(PGOOD_1_8V));
	   S_REGISTER_40(20)<=REGISTER_40_Error_inject(20) or S_REGISTER_40(20) or (not(PGOOD_2_5V));
	   S_REGISTER_40(19)<=REGISTER_40_Error_inject(19) or S_REGISTER_40(19) or (not(PGOOD_P1_5V));
	   S_REGISTER_40(18)<=REGISTER_40_Error_inject(18) or S_REGISTER_40(18) or (not(PGOOD_1_0V));
	   S_REGISTER_40(17)<=REGISTER_40_Error_inject(17) or S_REGISTER_40(17) or (not(PGOOD_1_5V));
	   S_REGISTER_40(16)<=REGISTER_40_Error_inject(16) or S_REGISTER_40(16) or (not(PGOOD_0_75V));
	   S_REGISTER_40(15 downto 11)<="00000"; -- spare
	   S_REGISTER_40(10)<=REGISTER_40_Error_inject(10) or S_REGISTER_40(10) or power_monitor_footer_Asic_check(10);
	   S_REGISTER_40(9)<=REGISTER_40_Error_inject(9) or S_REGISTER_40(9) or power_monitor_footer_Asic_check(9);
	   S_REGISTER_40(8)<=REGISTER_40_Error_inject(8) or S_REGISTER_40(8) or power_monitor_footer_Asic_check(8);
	   S_REGISTER_40(7)<=REGISTER_40_Error_inject(7) or S_REGISTER_40(7) or power_monitor_footer_Asic_check(7);
	   S_REGISTER_40(6)<=REGISTER_40_Error_inject(6) or S_REGISTER_40(6) or power_monitor_footer_Asic_check(6);
	   S_REGISTER_40(5)<=REGISTER_40_Error_inject(5) or S_REGISTER_40(5) or power_monitor_footer_Asic_check(5);
	   S_REGISTER_40(4)<=REGISTER_40_Error_inject(4) or S_REGISTER_40(4) or power_monitor_footer_Asic_check(4);
	   S_REGISTER_40(3)<=REGISTER_40_Error_inject(3) or S_REGISTER_40(3) or power_monitor_footer_Asic_check(3);
	   S_REGISTER_40(2)<=REGISTER_40_Error_inject(2) or S_REGISTER_40(2) or power_monitor_footer_Asic_check(2);
	   S_REGISTER_40(1)<=REGISTER_40_Error_inject(1) or S_REGISTER_40(1) or power_monitor_footer_Asic_check(1);
	   S_REGISTER_40(0)<=REGISTER_40_Error_inject(0) or S_REGISTER_40(0) or power_monitor_footer_Asic_check(0);
--	   for i in 0 to 10 loop
--	    if power_monitor_footer_Asic(i)=x"00" then
--			S_REGISTER_40(i)<=REGISTER_40_Error_inject(i) or S_REGISTER_40(i) or '0';
--		else
--		    S_REGISTER_40(i)<=REGISTER_40_Error_inject(i) or S_REGISTER_40(i) or '1';
--	    end if;
--	   end loop;
	  end if;
--	   for j in 0 to 10 loop
--		power_monitor_footer_Asic(j) <=Tile_power_monitor_footer(((j+1)*8-1) downto j*8);
--		if power_monitor_footer_Asic(j)=x"00000000000" then
--			S_REGISTER_40(j)<=REGISTER_40_Error_inject(j) or S_REGISTER_40(j) or '0';
--		--	power_monitor_footer_Asic_error(j)<='0';
--		else
--		--	power_monitor_footer_Asic_error(j)<='1';
--		    S_REGISTER_40(j)<=REGISTER_40_Error_inject(j) or S_REGISTER_40(j) or '1';
--	    end if;
--	   end loop;



	--  if (Module_Status_Errors_reg_read='1') then
	  if (S2_READ='1' and S_ADDR=REGISTER_41 ) THEN
        --	if Clear_after_read(29)='1' then  S_REGISTER_41(29)<='0';  end if;
            if Clear_after_read(28)='1' then  S_REGISTER_41(28)<='0'; OverRun_HD_reset_flag<='1';  end if; --add by dalit 17/12/2023
            if Clear_after_read(27)='1' then  S_REGISTER_41(27)<='0'; OverRun_RTL_reset_flag<='1'; end if; --add by dalit 17/12/2023
            if Clear_after_read(26)='1' then  S_REGISTER_41(26)<='0';  end if;
            if Clear_after_read(25)='1' then  S_REGISTER_41(25)<='0';  end if;
            if Clear_after_read(24)='1' then  S_REGISTER_41(24)<='0';  end if;
            if Clear_after_read(23)='1' then  S_REGISTER_41(23)<='0';  end if;
            if Clear_after_read(22)='1' then  S_REGISTER_41(22)<='0';  end if;
            if Clear_after_read(21)='1' then  S_REGISTER_41(21)<='0';  end if;
            if Clear_after_read(20)='1' then  S_REGISTER_41(20)<='0';  end if;
            if Clear_after_read(19)='1' then  S_REGISTER_41(19)<='0';  end if;
            if Clear_after_read(18)='1' then  S_REGISTER_41(18)<='0';  end if;
            if Clear_after_read(17)='1' then  S_REGISTER_41(17)<='0';  end if;
            if Clear_after_read(16)='1' then  S_REGISTER_41(16)<='0';  end if;
            if Clear_after_read(15)='1' then  S_REGISTER_41(15)<='0';  end if;
            if Clear_after_read(14)='1' then  S_REGISTER_41(14)<='0';  end if;
            if Clear_after_read(13)='1' then  S_REGISTER_41(13)<='0';  end if;
            if Clear_after_read(12)='1' then  S_REGISTER_41(12)<='0';  end if;
            if Clear_after_read(11)='1' then  S_REGISTER_41(11)<='0';  end if;
            if Clear_after_read(31)='1' then  S_REGISTER_41(31)<='0';  end if; -- 10/06/2024
	   else
	       Module_Status_Errors_reg_read<='0';
	       OverRun_HD_reset_flag<='0'; --add by dalit 17/12/2023
	       OverRun_RTL_reset_flag<='0'; --add by dalit 17/12/2023
	    --  S_REGISTER_41(29)<=
          S_REGISTER_41(28)<=  S_Error_inject(28) or S_REGISTER_41(28) or HD_Buffer_Overrun  ;
          S_REGISTER_41(27)<=  S_Error_inject(27) or S_REGISTER_41(27) or RTL_Buffer_Overrun ;
          S_REGISTER_41(26)<=  S_Error_inject(26) or S_REGISTER_41(26) or IP_too_long;
          S_REGISTER_41(25)<=  S_Error_inject(25) or S_REGISTER_41(25) or IP_too_short;
          S_REGISTER_41(24)<=  S_Error_inject(24) or S_REGISTER_41(24) or Data_TX_ERRs(0);
          S_REGISTER_41(23)<=  S_Error_inject(23) or S_REGISTER_41(23) or Data_TX_ERRs(1);
          S_REGISTER_41(22)<=  S_Error_inject(22) or S_REGISTER_41(22) or Diag_TX_ERRs(0);
          S_REGISTER_41(21)<=  S_Error_inject(21) or S_REGISTER_41(21) or Diag_TX_ERRs(1);
          S_REGISTER_41(20)<=  S_Error_inject(20) or S_REGISTER_41(20) or Operational_TX_ERRs(0);
          S_REGISTER_41(19)<=  S_Error_inject(19) or S_REGISTER_41(19) or Operational_TX_ERRs(1);
          S_REGISTER_41(18)<=  S_Error_inject(18) or S_REGISTER_41(18) or Buffer_Control_RX_ERRs(2);
          S_REGISTER_41(17)<=  S_Error_inject(17) or S_REGISTER_41(17) or IP_HEADER_RX_ERRs(2);
          S_REGISTER_41(16)<=  S_Error_inject(16) or S_REGISTER_41(16) or Diag_RX_ERRs(2);
          S_REGISTER_41(15)<=  S_Error_inject(15) or S_REGISTER_41(15) or Operational_RX_ERRs(2);
          S_REGISTER_41(14)<=  S_Error_inject(14) or S_REGISTER_41(14) or Buffer_Control_RX_ERRs(1) or Buffer_Control_RX_ERRs(0);
          S_REGISTER_41(13)<=  S_Error_inject(13) or S_REGISTER_41(13) or IP_HEADER_RX_ERRs(1) or IP_HEADER_RX_ERRs(0);
          S_REGISTER_41(12)<=  S_Error_inject(12) or S_REGISTER_41(12) or Diag_RX_ERRs(1) or Diag_RX_ERRs(0);
          S_REGISTER_41(11)<=  S_Error_inject(11) or S_REGISTER_41(11) or Operational_RX_ERRs(1) or Operational_RX_ERRs(0);
        --  S_REGISTER_41(12)<=  S_Error_inject(12)  or Diag_RX_ERRs(0) or Diag_RX_ERRs(1);
           --  S_REGISTER_41(11)<=  S_Error_inject(11)  or Operational_RX_ERRs(0) or Operational_RX_ERRs(1);
           if (S_REGISTER_51=x"00000000") then -- 06/06/2024 one or more DDR3 related errors
             S_REGISTER_41(31) <= S_Error_inject(31) or S_REGISTER_41(31);
           else
             S_REGISTER_41(31) <= '1';
           end if;
        end if;

          Module_Status_Errors_reg <= S_REGISTER_41; -- 04/12/2023

		if (S_REGISTER_42=x"00000000") then   -- one or more asic has an SPI Error
	       S_REGISTER_41(10) <= '0';
	   else
	       S_REGISTER_41(10) <= '1';
	   end if;
	--   if (AMS_SPI_Errors_reg_read='1' and Clear_after_read(10)='1') THEN
		 if (S2_READ='1' and S_ADDR=REGISTER_42 and Clear_after_read(10)='1') THEN
				S_REGISTER_42<=x"00000000";
				AMS_SPI_Errors_reg_read<='0';
		else
           -- S_REGISTER_42(0) <= REGISTER_42_Error_inject(0) or S_REGISTER_42(0) or SPI_Errs(0);  --spi error
           -- S_REGISTER_42(1) <= REGISTER_42_Error_inject(1) or S_REGISTER_42(1) or SPI_Errs(3);
           -- S_REGISTER_42(2) <= REGISTER_42_Error_inject(2) or S_REGISTER_42(2) or SPI_Errs(6);
           -- S_REGISTER_42(3) <= REGISTER_42_Error_inject(3) or S_REGISTER_42(3) or SPI_Errs(9);
           -- S_REGISTER_42(4) <= REGISTER_42_Error_inject(4) or S_REGISTER_42(4) or SPI_Errs(12);
           -- S_REGISTER_42(5) <= REGISTER_42_Error_inject(5) or S_REGISTER_42(5) or SPI_Errs(15);
           -- S_REGISTER_42(6) <= REGISTER_42_Error_inject(6) or S_REGISTER_42(6) or SPI_Errs(18);
           -- S_REGISTER_42(7) <= REGISTER_42_Error_inject(7) or S_REGISTER_42(7) or SPI_Errs(21);
           S_REGISTER_42(0) <= (REGISTER_42_Error_inject(0) or S_REGISTER_42(0) or SPI_Errs(0)) and not S_REGISTER_59(0);  --spi error
           S_REGISTER_42(1) <= (REGISTER_42_Error_inject(1) or S_REGISTER_42(1) or SPI_Errs(12)) and not S_REGISTER_59(0);
           S_REGISTER_42(2) <= REGISTER_42_Error_inject(2) or S_REGISTER_42(2) or SPI_Errs(3);
           S_REGISTER_42(3) <= REGISTER_42_Error_inject(3) or S_REGISTER_42(3) or SPI_Errs(15);
           S_REGISTER_42(4) <= REGISTER_42_Error_inject(4) or S_REGISTER_42(4) or SPI_Errs(6);
           S_REGISTER_42(5) <= REGISTER_42_Error_inject(5) or S_REGISTER_42(5) or SPI_Errs(18);
	   S_REGISTER_42(6) <= (REGISTER_42_Error_inject(6) or S_REGISTER_42(6) or SPI_Errs(9)) and not S_REGISTER_59(0);
	   S_REGISTER_42(7) <= (REGISTER_42_Error_inject(7) or S_REGISTER_42(7) or SPI_Errs(21)) and not S_REGISTER_59(0); -- 28/02/2024
	       S_REGISTER_42(31 downto 8)<=x"000000";
	   end if;

	   S_REGISTER_46(0) <= not(SPI_Errs(0));   --spi ok
	   S_REGISTER_46(1) <= not(SPI_Errs(3));
       S_REGISTER_46(2) <= not(SPI_Errs(6));
	   S_REGISTER_46(3) <= not(SPI_Errs(9));
	   S_REGISTER_46(4) <= not(SPI_Errs(12));
	   S_REGISTER_46(5) <= not(SPI_Errs(15));
       S_REGISTER_46(6) <= not(SPI_Errs(18));
	   S_REGISTER_46(7) <= not(SPI_Errs(21));
	   S_REGISTER_46(31 downto 8)<=x"000000";

	   if (S_REGISTER_43=x"00000000") then   -- one or more AMS_CrcError
	       S_REGISTER_41(9) <= '0';
	   else
	       S_REGISTER_41(9) <= '1';
	   end if;
	--   if (AMS_CRC_Errors_reg_read='1' and Clear_after_read(9)='1') THEN
	     if (S2_READ='1' and S_ADDR=REGISTER_43 and Clear_after_read(9)='1') THEN
				S_REGISTER_43<=x"00000000";
				AMS_CRC_Errors_reg_read<='0';
		else
           S_REGISTER_43(0) <= (REGISTER_43_Error_inject(0) or S_REGISTER_43(0) or AMS_CrcError(0)) and not S_REGISTER_59(0);
           S_REGISTER_43(1) <= (REGISTER_43_Error_inject(1) or S_REGISTER_43(1) or AMS_CrcError(4)) and not S_REGISTER_59(0);
           S_REGISTER_43(2) <= REGISTER_43_Error_inject(2) or S_REGISTER_43(2) or AMS_CrcError(1);
           S_REGISTER_43(3) <= REGISTER_43_Error_inject(3) or S_REGISTER_43(3) or AMS_CrcError(5);
           S_REGISTER_43(4) <= REGISTER_43_Error_inject(4) or S_REGISTER_43(4) or AMS_CrcError(2);
           S_REGISTER_43(5) <= REGISTER_43_Error_inject(5) or S_REGISTER_43(5) or AMS_CrcError(6);
           S_REGISTER_43(6) <= (REGISTER_43_Error_inject(6) or S_REGISTER_43(6) or AMS_CrcError(3)) and not S_REGISTER_59(0);
           S_REGISTER_43(7) <= (REGISTER_43_Error_inject(7) or S_REGISTER_43(7) or AMS_CrcError(7)) and not S_REGISTER_59(0);
           S_REGISTER_43(31 downto 8)<=x"000000";
	   end if;


	   S_REGISTER_47(0) <= (S_REGISTER_47(0)or AMS_CrcOk(0))and (not AMS_CrcError(0));
	   S_REGISTER_47(1) <= (S_REGISTER_47(1)or AMS_CrcOk(4))and (not AMS_CrcError(4));
       S_REGISTER_47(2) <= (S_REGISTER_47(2)or AMS_CrcOk(1))and (not AMS_CrcError(1));
	   S_REGISTER_47(3) <= (S_REGISTER_47(3)or AMS_CrcOk(5))and (not AMS_CrcError(5));
	   S_REGISTER_47(4) <= (S_REGISTER_47(4)or AMS_CrcOk(2))and (not AMS_CrcError(2));
	   S_REGISTER_47(5) <= (S_REGISTER_47(5)or AMS_CrcOk(6))and (not AMS_CrcError(6));
       S_REGISTER_47(6) <= (S_REGISTER_47(6)or AMS_CrcOk(3))and (not AMS_CrcError(3));
	   S_REGISTER_47(7) <= (S_REGISTER_47(7)or AMS_CrcOk(7))and (not AMS_CrcError(7));
	   S_REGISTER_47(31 downto 8)<=x"000000";


	   -- S_REGISTER_44(0) <= Tile_data_align_o(0);
	   -- S_REGISTER_44(1) <= Tile_data_align_o(2);
       -- S_REGISTER_44(2) <= Tile_data_align_o(1);
	   -- S_REGISTER_44(3) <= Tile_data_align_o(3);
	   -- S_REGISTER_44(4) <= Tile_data_align_o(4);
	   -- S_REGISTER_44(5) <= Tile_data_align_o(7);
       -- S_REGISTER_44(6) <= Tile_data_align_o(5);
	   -- S_REGISTER_44(7) <= Tile_data_align_o(6);
   	   S_REGISTER_44(0) <= Tile_data_align_o(0);
	   S_REGISTER_44(1) <= Tile_data_align_o(4);
       S_REGISTER_44(2) <= Tile_data_align_o(1);
	   S_REGISTER_44(3) <= Tile_data_align_o(5);
	   S_REGISTER_44(4) <= Tile_data_align_o(2);
	   S_REGISTER_44(5) <= Tile_data_align_o(6);
       S_REGISTER_44(6) <= Tile_data_align_o(3);
	   S_REGISTER_44(7) <= Tile_data_align_o(7); -- 13/02/2024
	   S_REGISTER_44(31 downto 8)<=x"000000";


	    if (S_REGISTER_45=x"00000000") then   -- one or more Asic Data is not aligned
	       S_REGISTER_41(8) <= '0';
	   else
	       S_REGISTER_41(8) <= '1';
	   end if;
       S_REGISTER_41(6) <= synthetic_data_from_asic; -- 25/06/2024
	 --  if (AMS_Data_not_Aligned_reg_read='1' and Clear_after_read(8)='1') THEN
	    if (S2_READ='1' and S_ADDR=REGISTER_45 and Clear_after_read(8)='1') THEN
				S_REGISTER_45<=x"00000000";
				AMS_Data_not_Aligned_reg_read<='0';
		else
           -- S_REGISTER_45(0) <= REGISTER_45_Error_inject(0) or S_REGISTER_45(0) or (not Tile_data_align_o(0));
           -- S_REGISTER_45(1) <= REGISTER_45_Error_inject(1) or S_REGISTER_45(1) or (not Tile_data_align_o(2));
           -- S_REGISTER_45(2) <= REGISTER_45_Error_inject(2) or S_REGISTER_45(2) or (not Tile_data_align_o(1));
           -- S_REGISTER_45(3) <= REGISTER_45_Error_inject(3) or S_REGISTER_45(3) or (not Tile_data_align_o(3));
           -- S_REGISTER_45(4) <= REGISTER_45_Error_inject(4) or S_REGISTER_45(4) or (not Tile_data_align_o(4));
           -- S_REGISTER_45(5) <= REGISTER_45_Error_inject(5) or S_REGISTER_45(5) or (not Tile_data_align_o(7));
           -- S_REGISTER_45(6) <= REGISTER_45_Error_inject(6) or S_REGISTER_45(6) or (not Tile_data_align_o(5));
           -- S_REGISTER_45(7) <= REGISTER_45_Error_inject(7) or S_REGISTER_45(7) or (not Tile_data_align_o(6));
           S_REGISTER_45(0) <= (REGISTER_45_Error_inject(0) or S_REGISTER_45(0) or (not Tile_data_align_o(0))) and not S_REGISTER_59(0);
           S_REGISTER_45(1) <= (REGISTER_45_Error_inject(1) or S_REGISTER_45(1) or (not Tile_data_align_o(4))) and not S_REGISTER_59(0);
           S_REGISTER_45(2) <= REGISTER_45_Error_inject(2) or S_REGISTER_45(2) or (not Tile_data_align_o(1));
           S_REGISTER_45(3) <= REGISTER_45_Error_inject(3) or S_REGISTER_45(3) or (not Tile_data_align_o(5));
           S_REGISTER_45(4) <= REGISTER_45_Error_inject(4) or S_REGISTER_45(4) or (not Tile_data_align_o(2));
           S_REGISTER_45(5) <= REGISTER_45_Error_inject(5) or S_REGISTER_45(5) or (not Tile_data_align_o(6));
           S_REGISTER_45(6) <= (REGISTER_45_Error_inject(6) or S_REGISTER_45(6) or (not Tile_data_align_o(3))) and not S_REGISTER_59(0);
           S_REGISTER_45(7) <= (REGISTER_45_Error_inject(7) or S_REGISTER_45(7) or (not Tile_data_align_o(7))) and not S_REGISTER_59(0); -- 13/02/2024

           S_REGISTER_45(31 downto 8)<=x"000000";
	   end if;

	   s_footer_send<=footer_send;
	   if (s_footer_send='0' and footer_send='1' ) THEN
		     footer_send_counter<=footer_send_counter+1;
		     footer_w1_sent<='0';
	   elsif (footer_send_counter>0 and footer_send_counter<3) then
	   	     footer_send_counter<=footer_send_counter+1;
	   elsif (footer_send_counter=3) then
	         footer_w1_sent<='1';
	         footer_send_counter<=footer_send_counter+1;
	    elsif (footer_send_counter=4) then
	         footer_send_counter<=0;
	         footer_w1_sent<='0';
	   end if;

	    if (footer_w1_sent='1' ) THEN
			S_REGISTER_41(0)<='0';
			S_REGISTER_41(2)<='0';
			S_REGISTER_41(3)<='0';
			S_REGISTER_41(4)<='0';
			S_REGISTER_41(5)<='0';
			S_REGISTER_41(7)<='0';
		else
			S_REGISTER_41(0)<= S_Error_inject(0) or (S_Error_inject_2(0) and (S_REGISTER_41(0) or MU_CTRL(0)));
			S_REGISTER_41(2)<= S_Error_inject(2) or (S_Error_inject_2(2) and (S_REGISTER_41(2) or MODULE_DATA_OUT_SELCTION(0)));
			S_REGISTER_41(3)<= S_Error_inject(3) or (S_Error_inject_2(3) and (S_REGISTER_41(3) or Remote_Programing_SM_Bits(0)));
			S_REGISTER_41(4)<= S_Error_inject(4) or (S_Error_inject_2(4) and (S_REGISTER_41(4) or Remote_Programing_SM_Bits(1)));
			S_REGISTER_41(5)<= S_Error_inject(5) or (S_Error_inject_2(5) and (S_REGISTER_41(5) or Operational_DIAGNSOTICS(4)));
			S_REGISTER_41(7)<= S_Error_inject(7) or (S_Error_inject_2(7) and (S_REGISTER_41(7) or Asic_at_same_mode));	   --all asics at the same data mode (raw or calib)
	   end if;


	    if (S_REGISTER_50(7 downto 0)="00000000" or S_REGISTER_50(7 downto 0)="11111111"  ) then
	       Asic_at_same_mode<='1';
	     else
	        Asic_at_same_mode<='0';
	     end if;

	    if (footer_w1_sent='1' ) THEN
			 S_REGISTER_41(1) <= '0';
	    else
		  -- if (S_REGISTER_50=x"00000000") then   -- if '0' all asic at raw mode if '1' at least one asic at calibrated mode(raw-0 calibrated-1)
          -- Not(OR(Footer4(12)Asic1..n)), '0' Asic in Calibrated Data mode Data -> if not all '0' -> raw
          if (S_REGISTER_50(7 downto 0) /= X"00") then -- 07/08/2024
			   S_REGISTER_41(1) <= '0'; -- RAW 
		   else
			   S_REGISTER_41(1) <= '1'; -- Calibrated 
		   end if;
	    end if;
	--   if (Asic_mode_Calibrated_or_Raw_reg_read='1' and Clear_after_read(1)='1') THEN
	     if (S2_READ='1' and S_ADDR=REGISTER_50 and Clear_after_read(1)='1') THEN
				S_REGISTER_50<=x"00000000";
				Asic_mode_Calibrated_or_Raw_reg_read<='0';
		else
           S_REGISTER_50(0) <= REGISTER_50_Error_inject(0) or S_REGISTER_50(0) or Asic_mode_Calibrated_or_Raw(0);
           S_REGISTER_50(1) <= REGISTER_50_Error_inject(1) or S_REGISTER_50(1) or Asic_mode_Calibrated_or_Raw(4);
           S_REGISTER_50(2) <= REGISTER_50_Error_inject(2) or S_REGISTER_50(2) or Asic_mode_Calibrated_or_Raw(1);
           S_REGISTER_50(3) <= REGISTER_50_Error_inject(3) or S_REGISTER_50(3) or Asic_mode_Calibrated_or_Raw(5);
           S_REGISTER_50(4) <= REGISTER_50_Error_inject(4) or S_REGISTER_50(4) or Asic_mode_Calibrated_or_Raw(2);
           S_REGISTER_50(5) <= REGISTER_50_Error_inject(5) or S_REGISTER_50(5) or Asic_mode_Calibrated_or_Raw(6);
           S_REGISTER_50(6) <= REGISTER_50_Error_inject(6) or S_REGISTER_50(6) or Asic_mode_Calibrated_or_Raw(3);
           S_REGISTER_50(7) <= REGISTER_50_Error_inject(7) or S_REGISTER_50(7) or Asic_mode_Calibrated_or_Raw(7);
           S_REGISTER_50(31 downto 8)<=x"000000";
	   end if;


	  -- added by tzvika sweetkin 26/07/2023
	   S_REGISTER_38 <= NVRAM_READ_DATA_REG;
       S_REGISTER_39 <= NVRAM_STATUS_REG;
	   if (S_REGISTER_36(31) = '1') then --reset enable after 1 clk
            S_REGISTER_36(31) <= '0';
       end if;
       if (S_REGISTER_37(31) = '1') then --reset enable after 1 clk
            S_REGISTER_37(31) <= '0';
       end if;

        DMS_Coverage <= S_REGISTER_59(0); -- [0]- '1' 2cm DMS / '0' 4cm DMS 

     END IF;

END PROCESS;


-- !debug: 08/05/2023 only for test, remove
-- to LA: test_reg_wrreq, test_reg_seq_cnt, S_ADDR, S_DATA_IN
test_pr: process (clk, rst) is
begin  -- process test_pr
  if (rst = '1') then                   -- asynchronous reset (active high)
    test_reg_wrreq <= '0';
    test_reg_seq_cnt <= 0;
  elsif (clk'event and clk = '1') then  -- rising clock edge

    if (ReadWrite_sm = WRITE_sm) then
      test_reg_wrreq <= '1';
      test_reg_seq_cnt <= test_reg_seq_cnt + 1; -- write sequence num
    else
      test_reg_wrreq <= '0';
    end if;

  end if;
end process test_pr;


end REGISTER_BANK_ARC;
