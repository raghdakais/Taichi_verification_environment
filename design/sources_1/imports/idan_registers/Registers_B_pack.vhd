
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
----------------------------------------------------------------------------

package Registers_B_pack is

------------------------------- REGISTER MAP ----------------------------------

-- Registers area 0x7X
CONSTANT REGISTER_0  			: std_logic_vector(15 downto 0):= X"6700";--R/W - Mu control
CONSTANT REGISTER_1  			: std_logic_vector(15 downto 0):= X"6710";--R/W - Add constant offset to charge input - in Mu calculation
CONSTANT REGISTER_2  			: std_logic_vector(15 downto 0):= X"6720";--R/W - Constant offset value to add to charge input - in Mu calculation
CONSTANT REGISTER_3  			: std_logic_vector(15 downto 0):= X"6730";--R/W - Asics Test/Calibration control
CONSTANT REGISTER_4  			: std_logic_vector(15 downto 0):= X"6740";--R - Test Errors
CONSTANT REGISTER_5  			: std_logic_vector(15 downto 0):= X"6750";--R/W - Diagnostics
CONSTANT REGISTER_6  			: std_logic_vector(15 downto 0):= X"6760";--R/W - Global IP coefficient for added Offset normalization
CONSTANT REGISTER_7  			: std_logic_vector(15 downto 0):= X"6780";--R/W - Asics Data Alignment #1
CONSTANT REGISTER_8  			: std_logic_vector(15 downto 0):= X"6790";--R/W - Module Data Out Type selection
-- Registers area 0x4X
CONSTANT REGISTER_9  			: std_logic_vector(15 downto 0):= X"6430";--R - SoftReset_ResetSticky
-- Registers area 0x6X
CONSTANT REGISTER_10  			: std_logic_vector(15 downto 0):= X"6620"; -- R   0x62	Asics Reset
CONSTANT REGISTER_11  			: std_logic_vector(15 downto 0):= X"6650"; -- R/W 0x65	Asics Read/Write operations
CONSTANT REGISTER_12  			: std_logic_vector(15 downto 0):= X"6660"; -- R/W 0x66  Asics Read Select
CONSTANT REGISTER_13  			: std_logic_vector(15 downto 0):= X"6670"; -- R/W 0x67	Asics Write Select
CONSTANT REGISTER_14  			: std_logic_vector(15 downto 0):= X"66B0"; -- R	  0x6B	Module Power Enable/Disable
-- Registers area 0xAX
CONSTANT REGISTER_15  			: std_logic_vector(15 downto 0):= X"6A00";-- R/W Evolving Control

--spare
CONSTANT REGISTER_16  			: std_logic_vector(15 downto 0):= X"0010";
CONSTANT REGISTER_17  			: std_logic_vector(15 downto 0):= X"0011";
CONSTANT REGISTER_18  			: std_logic_vector(15 downto 0):= X"0012";
CONSTANT REGISTER_19  			: std_logic_vector(15 downto 0):= X"0013";
CONSTANT REGISTER_20  			: std_logic_vector(15 downto 0):= X"0014";  
CONSTANT REGISTER_21  			: std_logic_vector(15 downto 0):= X"0015";  
CONSTANT REGISTER_22  			: std_logic_vector(15 downto 0):= X"0016"; 
CONSTANT REGISTER_23  			: std_logic_vector(15 downto 0):= X"0017"; 
CONSTANT REGISTER_24  			: std_logic_vector(15 downto 0):= X"0018";
CONSTANT REGISTER_25  			: std_logic_vector(15 downto 0):= X"0019";
CONSTANT REGISTER_26  			: std_logic_vector(15 downto 0):= X"001A";  
CONSTANT REGISTER_27  			: std_logic_vector(15 downto 0):= X"001B"; 
CONSTANT REGISTER_28  			: std_logic_vector(15 downto 0):= X"001C"; 
CONSTANT REGISTER_29  			: std_logic_vector(15 downto 0):= X"001D";
CONSTANT REGISTER_30  			: std_logic_vector(15 downto 0):= X"001E";
CONSTANT REGISTER_31  			: std_logic_vector(15 downto 0):= X"001F";
CONSTANT REGISTER_32  			: std_logic_vector(15 downto 0):= X"0020";
CONSTANT REGISTER_33  			: std_logic_vector(15 downto 0):= X"0021";
CONSTANT REGISTER_34  			: std_logic_vector(15 downto 0):= X"0022";
CONSTANT REGISTER_35  			: std_logic_vector(15 downto 0):= X"0023";
CONSTANT REGISTER_36  			: std_logic_vector(15 downto 0):= X"0024";
CONSTANT REGISTER_37  			: std_logic_vector(15 downto 0):= X"0025";
CONSTANT REGISTER_38  			: std_logic_vector(15 downto 0):= X"0026";
CONSTANT REGISTER_39  			: std_logic_vector(15 downto 0):= X"0027";
CONSTANT REGISTER_40  			: std_logic_vector(15 downto 0):= X"0028";
CONSTANT REGISTER_41  			: std_logic_vector(15 downto 0):= X"0029";        
CONSTANT REGISTER_42  			: std_logic_vector(15 downto 0):= X"002A";        
CONSTANT REGISTER_43  			: std_logic_vector(15 downto 0):= X"002B";        
CONSTANT REGISTER_44  			: std_logic_vector(15 downto 0):= X"002C";        
CONSTANT REGISTER_45  			: std_logic_vector(15 downto 0):= X"002D";        
CONSTANT REGISTER_46  			: std_logic_vector(15 downto 0):= X"002E";        
CONSTANT REGISTER_47  			: std_logic_vector(15 downto 0):= X"002F";        
CONSTANT REGISTER_48  			: std_logic_vector(15 downto 0):= X"0030";   
-- CONSTANT REGISTER_49			: std_logic_vector(15 downto 0):= X"0031";	 
CONSTANT REGISTER_49			: std_logic_vector(15 downto 0):= X"67E0"; --R/W Asics Alignment #2
CONSTANT REGISTER_50			: std_logic_vector(15 downto 0):= X"0032";	 
CONSTANT REGISTER_51			: std_logic_vector(15 downto 0):= X"0033";	 
CONSTANT REGISTER_52			: std_logic_vector(15 downto 0):= X"0034";	 
CONSTANT REGISTER_53			: std_logic_vector(15 downto 0):= X"0035";	 
CONSTANT REGISTER_54			: std_logic_vector(15 downto 0):= X"0036";	 
CONSTANT REGISTER_55			: std_logic_vector(15 downto 0):= X"0037";	 
CONSTANT REGISTER_56			: std_logic_vector(15 downto 0):= X"0038";	 
CONSTANT REGISTER_57			: std_logic_vector(15 downto 0):= X"0039";	 
CONSTANT REGISTER_58			: std_logic_vector(15 downto 0):= X"003A";	 
CONSTANT REGISTER_59			: std_logic_vector(15 downto 0):= X"003B";	 
CONSTANT REGISTER_60			: std_logic_vector(15 downto 0):= X"003C";	 
CONSTANT REGISTER_61			: std_logic_vector(15 downto 0):= X"003D";	 
CONSTANT REGISTER_62			: std_logic_vector(15 downto 0):= X"003E";	 
CONSTANT REGISTER_63			: std_logic_vector(15 downto 0):= X"003F";	 

end Registers_B_pack;
