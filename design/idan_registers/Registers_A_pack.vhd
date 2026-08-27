
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
----------------------------------------------------------------------------

package Registers_A_pack is

------------------------------- REGISTER MAP ----------------------------------
CONSTANT REGISTER_0  			: std_logic_vector(15 downto 0):= X"64C0";  -- timestamp
CONSTANT REGISTER_1				: std_logic_vector(15 downto 0):= X"64A0";  --  AMS packet CRC error counter (8x 4bits counters)
--CONSTANT REGISTER_2				: std_logic_vector(15 downto 0):= X"64B0";  -- temporary reg2 11/05/2023 AMS channel align status [7..0]
-- Registers area 0x7X
CONSTANT REGISTER_3  			: std_logic_vector(15 downto 0):= X"67A0";--R/W - Bad Pixels High limit
CONSTANT REGISTER_4  			: std_logic_vector(15 downto 0):= X"67B0";--R/W - Bad Pixels Low limit
CONSTANT REGISTER_5 			: std_logic_vector(15 downto 0):= X"67C0";--R/W - Bad Pixels per Tile limit
-- Registers area 0x4X
CONSTANT REGISTER_6  			: std_logic_vector(15 downto 0):= X"6400";--R - Firmware Version
CONSTANT REGISTER_7  			: std_logic_vector(15 downto 0):= X"6410";--R - Hardware Board Revision
CONSTANT REGISTER_8  			: std_logic_vector(15 downto 0):= X"6414"; -- 04/09/2023 R/W sorter DPR1 ready timeout
CONSTANT REGISTER_9 			: std_logic_vector(15 downto 0):= X"6440";  -- R - Number of Slices
CONSTANT REGISTER_10  			: std_logic_vector(15 downto 0):= X"6450";  -- R - IP Calculated
-- Registers area 0x8X
CONSTANT REGISTER_11  			: std_logic_vector(15 downto 0):= X"6800";--R/W control register LSB
CONSTANT REGISTER_12  			: std_logic_vector(15 downto 0):= X"6820";--R/W FIFO reset
CONSTANT REGISTER_13  			: std_logic_vector(15 downto 0):= X"6830";--R   Configuration status
CONSTANT REGISTER_14  			: std_logic_vector(15 downto 0):= X"6840";--R   Configuration FIFO RD count
CONSTANT REGISTER_15  			: std_logic_vector(15 downto 0):= X"6850";--R/W remote configuration Data in to page buffer
CONSTANT REGISTER_16  			: std_logic_vector(15 downto 0):= X"6860";--R   remote configuration Data out from page buffer
-- Registers area 0x5X
CONSTANT REGISTER_17  			: std_logic_vector(15 downto 0):= X"6500";        -- Tile1 Temperature (R)
CONSTANT REGISTER_18			: std_logic_vector(15 downto 0):= X"6504";	  -- Tile2 Temperature (R)
CONSTANT REGISTER_19			: std_logic_vector(15 downto 0):= X"6508";	  -- Tile3 Temperature (R)
CONSTANT REGISTER_20			: std_logic_vector(15 downto 0):= X"650C";	  -- Tile4 Temperature (R)
CONSTANT REGISTER_21			: std_logic_vector(15 downto 0):= X"6510";	  -- Module Outlet Temperature (R) & Module Inlet Temperature (R)
CONSTANT REGISTER_22			: std_logic_vector(15 downto 0):= X"6518";	  -- Module's Weighted Moving Average Temperature (R)
CONSTANT REGISTER_23			: std_logic_vector(15 downto 0):= X"651C";	  -- Selector for Diag. registers. bits(31..16): N/A; bits(15..8) Diag 8; bits(7..0) Diag 7; (R/W)
CONSTANT REGISTER_24			: std_logic_vector(15 downto 0):= X"6520";	  -- PID Coefficient - kP (R/W)
CONSTANT REGISTER_25			: std_logic_vector(15 downto 0):= X"6524";	  -- PID Coefficient - kI (R/W)
CONSTANT REGISTER_26			: std_logic_vector(15 downto 0):= X"6528";	  -- PID Coefficient - kD (R/W)
CONSTANT REGISTER_27			: std_logic_vector(15 downto 0):= X"652C";	  -- PID Coefficient - kAW (R/W)
CONSTANT REGISTER_28			: std_logic_vector(15 downto 0):= X"6530";	  -- Heater Control (R/W)
CONSTANT REGISTER_29			: std_logic_vector(15 downto 0):= X"6534";	  -- PID Set Point  (R/W)
CONSTANT REGISTER_30			: std_logic_vector(15 downto 0):= X"6538";	  -- Temperature Sensors Weighted Average CFG (R/W)
CONSTANT REGISTER_31			: std_logic_vector(15 downto 0):= X"6540";	  -- PID Stable_Tolerance (R/W)
CONSTANT REGISTER_32			: std_logic_vector(15 downto 0):= X"6544";	  -- Calc_PID_reg & Sample_reg (R/W)
CONSTANT REGISTER_33			: std_logic_vector(15 downto 0):= X"6548";	  -- Set Integral and Derivative Updating rates (R/W)
CONSTANT REGISTER_34  			: std_logic_vector(15 downto 0):= X"6550";    -- Status and Errors (R/W)
CONSTANT REGISTER_35			: std_logic_vector(15 downto 0):= X"6554";    -- (R) PWM Duty Cycle status
CONSTANT REGISTER_36  			: std_logic_vector(15 downto 0):= X"6900";    -- NVRAM Address (R/W)
CONSTANT REGISTER_37  			: std_logic_vector(15 downto 0):= X"6910";    -- NVRAM Write Data & Operation (R/W)
CONSTANT REGISTER_38  			: std_logic_vector(15 downto 0):= X"6920";    -- NVRAM Read Data (R)
CONSTANT REGISTER_39  			: std_logic_vector(15 downto 0):= X"6930";    -- NVRAM Status (R)
-- Registers area 0x4X continue
CONSTANT REGISTER_40  			: std_logic_vector(15 downto 0):= X"6420"; --R - Voltage OK feedback from LDOs
CONSTANT REGISTER_41  			: std_logic_vector(15 downto 0):= X"6424"; --R - Module Status/Errors register
CONSTANT REGISTER_42  			: std_logic_vector(15 downto 0):= X"6428"; --R - Asics to FPGA SPI Errors
CONSTANT REGISTER_43  			: std_logic_vector(15 downto 0):= X"642C"; --R - Asics Data CRC Error
CONSTANT REGISTER_44  			: std_logic_vector(15 downto 0):= X"64B0"; --R - AMS Asic Data Align Status [7..0] (one OK bit per Asic)
CONSTANT REGISTER_45  			: std_logic_vector(15 downto 0):= X"64B4"; --R - AMS Asic Data Align Error [7..0] (one OK bit per Asic)
CONSTANT REGISTER_46  			: std_logic_vector(15 downto 0):= X"64B8"; --R - Asics to FPGA SPI is working Correctly
CONSTANT REGISTER_47  			: std_logic_vector(15 downto 0):= X"64BC"; --R - Asics Data CRC is Correct
-- Registers area 0x7X continue
CONSTANT REGISTER_48  			: std_logic_vector(15 downto 0):= X"67D0"; --R/W Miscellaneous – LED On/Off
CONSTANT REGISTER_49			: std_logic_vector(15 downto 0):= X"67E0"; --R/W Asics Alignment

CONSTANT REGISTER_50			: std_logic_vector(15 downto 0):= X"64C4"; -- Asics Calibrated or Raw mode
CONSTANT REGISTER_51			: std_logic_vector(15 downto 0):= X"64C8"; -- R/W Data Buffer
CONSTANT REGISTER_52			: std_logic_vector(15 downto 0):= X"64D0"; -- R/W Clear after Read for register X"6424"

CONSTANT REGISTER_53			: std_logic_vector(15 downto 0):= X"6300"; -- Error inject1 (or gate defult x"00000000") for Clear after Read bits at register X"6424"
CONSTANT REGISTER_54			: std_logic_vector(15 downto 0):= X"6350";	-- Error inject2 (and gate defult x"FFFFFFFF")  for Clear after Read bits at register X"6424"

CONSTANT REGISTER_55			: std_logic_vector(15 downto 0):= X"6360"; --R/W Min_reading_gap_reg for RLT buffer calculator defult value x"00000005"
CONSTANT REGISTER_56			: std_logic_vector(15 downto 0):= X"6370"; --R/W Min_reading_pointer_gap_reg for HD buffer calculator defult value x"00000005"

CONSTANT REGISTER_57			: std_logic_vector(15 downto 0):= X"6380";	--R RTL_buffer_deep
CONSTANT REGISTER_58			: std_logic_vector(15 downto 0):= X"6390";	--R HD_buffer_deep
CONSTANT REGISTER_59			: std_logic_vector(15 downto 0):= X"6418"; -- 24/07/2024 R/W Module diagnostic control
CONSTANT REGISTER_60			: std_logic_vector(15 downto 0):= X"6384"; -- R RTL free space
CONSTANT REGISTER_61			: std_logic_vector(15 downto 0):= X"6394"; -- R HD free space
CONSTANT REGISTER_62			: std_logic_vector(15 downto 0):= X"63A0"; -- 03/03/2026 RX_ERR_INJECT_CTL_REG
CONSTANT REGISTER_63			: std_logic_vector(15 downto 0):= X"63A4"; -- 03/03/2026 SYNTH_BUF_PTR_ADDRESS_REG
CONSTANT REGISTER_64			: std_logic_vector(15 downto 0):= X"63A8"; -- 03/03/2026 SYNTH_RLT_PTR_ADDRESS_REG
CONSTANT REGISTER_65			: std_logic_vector(15 downto 0):= X"63AC"; -- 03/03/2026 SYNTH_HD_PTR_ADDRESS_REG
CONSTANT REGISTER_66			: std_logic_vector(15 downto 0):= X"63B0"; -- 03/03/2026 BUF_CRC_INJ_CNT
CONSTANT REGISTER_67			: std_logic_vector(15 downto 0):= X"63B4"; -- 03/03/2026 SYNC_CRC_INJ_CNT
CONSTANT REGISTER_68			: std_logic_vector(15 downto 0):= X"63B8"; -- 09/03/2026 ip_pkt_cnt
CONSTANT REGISTER_69			: std_logic_vector(15 downto 0):= X"63BC"; -- 09/03/2026 headers_pkt_cnt
CONSTANT REGISTER_70			: std_logic_vector(15 downto 0):= X"6304"; -- 23/03/2026 AMS_Time_test_reg
CONSTANT REGISTER_71			: std_logic_vector(15 downto 0):= X"6308"; -- 29/03/2026 BUFFER_PKT_CNT
CONSTANT REGISTER_72			: std_logic_vector(15 downto 0):= X"630C"; -- 29/03/2026 reading_number_from_scan_header

--spare
-- CONSTANT REGISTER_62			: std_logic_vector(15 downto 0):= X"003E";
-- CONSTANT REGISTER_63			: std_logic_vector(15 downto 0):= X"003F";
end Registers_A_pack;
