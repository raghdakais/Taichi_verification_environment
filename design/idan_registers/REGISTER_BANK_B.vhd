----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 09/12/2022 10:12:23 AM
-- Design Name:
-- Module Name: REGISTER_BANK B - REGISTER_BANK_ARC
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Revision 0.02 - REGISTER_BANK B  18/7/2023
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.Registers_B_pack.ALL;
entity REGISTER_BANK_B is

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
    MU_CTRL                 :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ADD_CONST_OFST_TO_MU    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    CONST_OFST_VAL_TO_MU    :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_TST_CAL_CTRL_TEST  :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    TEST_ERROR              :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    WR_TO_TEST_ERROR        :IN STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    DIAGNSOTICS             :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    GLOBL_IP_COEF           :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ASIC_DATA_ALIGNMENT     :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    MODULE_DATA_OUT_SELCTION:OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    ams_asics_reset         :OUT STD_LOGIC;
    Power_en_mask           :OUT STD_LOGIC_VECTOR(1 downto 0); 
    asic_rdwr_exe           :OUT STD_LOGIC;
    asic_rdwr_ops           :OUT STD_LOGIC_VECTOR (G_DATA_LENGTH-1 DOWNTO 0);
    AMS_DATA2R              :in std_logic_vector (15 downto 0);
    asics_read_sel          :OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    sel_dbg1                :in std_logic -- 25/06/2024
);
end REGISTER_BANK_B;

architecture REGISTER_BANK_ARC of REGISTER_BANK_B is
type ReadWrite_sm_type is (idle, Read_sm, Write_sm);
signal ReadWrite_sm : ReadWrite_sm_type;
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

-- !debug: 20/02/2023
--SIGNAL config_wr_en_i : STD_LOGIC;
SIGNAL asic_rdwr_exe_i : STD_LOGIC;
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
        S_REGISTER_0<= X"000BF173"; -- X"F" & X"17" & X"3"
        S_REGISTER_1<= X"00000000";
        S_REGISTER_2<= X"00000040";
        S_REGISTER_3<= X"00000000";
        S_REGISTER_4<= X"00000000";
        S_REGISTER_5<= X"00000000";
        S_REGISTER_6<= X"0000007D";
        S_REGISTER_7<= X"0000000A";
        S_REGISTER_8<= X"00000001";
        S_REGISTER_9<=x"00000000"; --Dalit 22/01/2024 change default value 
        S_REGISTER_10<=x"00000000";
        S_REGISTER_11<=x"00000000";
        S_REGISTER_12<=x"00000000";
        S_REGISTER_13<=x"00000000";
        S_REGISTER_14<=x"00000003";     -- power en mask
        S_REGISTER_15<=x"00000000"; --Evolving Control
        --spare
        S_REGISTER_16<=x"00000010";
        S_REGISTER_17<=x"00000011";
        S_REGISTER_18<=x"00000012";
        S_REGISTER_19<=x"00000013";
        S_REGISTER_20<=x"00000014";
        S_REGISTER_21<=x"00000015";
        S_REGISTER_22<=x"00000016";
        S_REGISTER_23<=x"00000017";
        S_REGISTER_24<=x"00000018";
        S_REGISTER_25<=x"00000019";
        S_REGISTER_26<=x"0000001A";
        S_REGISTER_27<=x"0000001B";
        S_REGISTER_28<=x"0000001C";    
        S_REGISTER_29<=x"0000001D";
        S_REGISTER_30<=x"0000001E";
        S_REGISTER_31<=x"0000001F";
        S_REGISTER_32<=x"00000020";
        S_REGISTER_33<=x"00000021";
        S_REGISTER_34<=x"00000022";
        S_REGISTER_35<=x"00000023";
        S_REGISTER_36<=x"00000024";
        S_REGISTER_37<=x"00000025";
        S_REGISTER_38<=x"00000026";
        S_REGISTER_39<=x"00000027";
        S_REGISTER_40<=x"00000028";
        S_REGISTER_41<=x"00000029";
        S_REGISTER_42<=x"0000002A";
        S_REGISTER_43<=x"0000002B";
        S_REGISTER_44<=x"0000002C";
        S_REGISTER_45<=x"0000002D";
        S_REGISTER_46<=x"0000002E";
        S_REGISTER_47<=x"0000002F";
        S_REGISTER_48<=x"00000030";
        S_REGISTER_49<=x"00000001";     -- Start Asics Data Alignment
        S_REGISTER_50<=x"00000032";
        S_REGISTER_51<=x"00000033";
        S_REGISTER_52<=x"00000034";
        S_REGISTER_53<=x"00000035";
        S_REGISTER_54<=x"00000036";
        S_REGISTER_55<=x"00000037";
        S_REGISTER_56<=x"00000038";
        S_REGISTER_57<=x"00000039";
        S_REGISTER_58<=x"0000003A";
        S_REGISTER_59<=x"0000003B";
        S_REGISTER_60<=x"0000003C";     
        S_REGISTER_61<=x"0000003D";
        S_REGISTER_62<=x"0000003E";     
        S_REGISTER_63<=x"0000003F";     
             
        asic_rdwr_exe_i <= '0';
     
     ELSIF RISING_EDGE(CLK) THEN
       
        S_DATA_IN<=DATA_IN;
        S_ADDR<=ADDR;
        MU_CTRL                      <=S_REGISTER_0         ;
        ADD_CONST_OFST_TO_MU         <=S_REGISTER_1         ;
        CONST_OFST_VAL_TO_MU         <=S_REGISTER_2         ;
        ASIC_TST_CAL_CTRL_TEST       <=S_REGISTER_3         ;
        TEST_ERROR                   <=WR_TO_TEST_ERROR     ;-- read only from CDM, Can be writen only from module
        DIAGNSOTICS                  <=S_REGISTER_5         ;
        GLOBL_IP_COEF                <=S_REGISTER_6         ;
        if (sel_dbg1 = '1') then
          ASIC_DATA_ALIGNMENT          <=S_REGISTER_7         ;
        else
          ASIC_DATA_ALIGNMENT <= S_REGISTER_7(31 downto 3) & S_REGISTER_49(2) & S_REGISTER_7(1) & S_REGISTER_49(0); -- 25/06/2024
        end if;
        
        MODULE_DATA_OUT_SELCTION     <=S_REGISTER_8         ;
        asic_rdwr_ops               <= S_REGISTER_11; -- 03/04/2023
        asics_read_sel              <= S_REGISTER_12(31 downto 24);
        
        asic_rdwr_exe_i <= '0';
        
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

            CASE S_ADDR IS

             WHEN REGISTER_0=>
        			             DATA_OUT<=S_REGISTER_0;
             WHEN REGISTER_1=>
                    			DATA_OUT<=S_REGISTER_1;
             WHEN REGISTER_2=>
                    			DATA_OUT<=S_REGISTER_2;
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
             WHEN REGISTER_8=>
                    			DATA_OUT<=S_REGISTER_8;
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
             --spare
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
             WHEN REGISTER_41=>
                    			 DATA_OUT<=S_REGISTER_41;
             WHEN REGISTER_42=>
                    			 DATA_OUT<=S_REGISTER_42;
             WHEN REGISTER_43=>
                    			 DATA_OUT<=S_REGISTER_43;
             WHEN REGISTER_44=>
                    			 DATA_OUT<=S_REGISTER_44;
             WHEN REGISTER_45=>
                    			 DATA_OUT<=S_REGISTER_45;
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
             WHEN REGISTER_51=>
                    			 DATA_OUT<=S_REGISTER_51;
             WHEN REGISTER_52=>
                    			 DATA_OUT<=S_REGISTER_52;
             WHEN REGISTER_53=>
                    			 DATA_OUT<=S_REGISTER_53;
             WHEN REGISTER_54=>
                    			 DATA_OUT<=S_REGISTER_54;
             WHEN REGISTER_55=>
                    			 DATA_OUT<=S_REGISTER_55;
             WHEN REGISTER_56=>
                    			 DATA_OUT<=S_REGISTER_56;
             WHEN REGISTER_57=>
                    			 DATA_OUT<=S_REGISTER_57;
             WHEN REGISTER_58=>
                    			 DATA_OUT<=S_REGISTER_58;
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
        			             S_REGISTER_0<=S_DATA_IN;
        	WHEN REGISTER_1=>
        			            S_REGISTER_1<=S_DATA_IN;
        	WHEN REGISTER_2=>
        			             S_REGISTER_2<=S_DATA_IN;
            WHEN REGISTER_3=>
                    			 S_REGISTER_3<=S_DATA_IN;
            WHEN REGISTER_4=>
                    		--	S_REGISTER_4<=S_DATA_IN;
            WHEN REGISTER_5=>
                    			S_REGISTER_5<=S_DATA_IN;
            WHEN REGISTER_6=>
                    			S_REGISTER_6<=S_DATA_IN;
            WHEN REGISTER_7=>
                    			S_REGISTER_7<=S_DATA_IN;
            WHEN REGISTER_8=>                  
                    			S_REGISTER_8<=S_DATA_IN;
            WHEN REGISTER_9=>
                    		--	S_REGISTER_9<=S_DATA_IN;
            WHEN REGISTER_10=>
                    			S_REGISTER_10<=S_DATA_IN;
            WHEN REGISTER_11=>
                    			S_REGISTER_11<=S_DATA_IN;
                    			asic_rdwr_exe_i <= '1'; -- 03/04/2023
            WHEN REGISTER_12=>
                    			S_REGISTER_12(31 downto 24)<=S_DATA_IN(31 downto 24);
            WHEN REGISTER_13=>
                    			S_REGISTER_13<=S_DATA_IN;
             WHEN REGISTER_14=>
                    			 S_REGISTER_14<=S_DATA_IN;
             WHEN REGISTER_15=>
                    			 S_REGISTER_15<=S_DATA_IN;
             --spare
             WHEN REGISTER_16=>
                    			 S_REGISTER_16<=S_DATA_IN;
             WHEN REGISTER_17=>
                   		    	 S_REGISTER_17<=S_DATA_IN;
             WHEN REGISTER_18=>
                   		         S_REGISTER_18<=S_DATA_IN;
             WHEN REGISTER_19=>
                    			S_REGISTER_19<=S_DATA_IN;
             WHEN REGISTER_20=>
                      			S_REGISTER_20<=S_DATA_IN;
             WHEN REGISTER_21=>
                    			S_REGISTER_21<=S_DATA_IN;
             WHEN REGISTER_22=>
                     			S_REGISTER_22<=S_DATA_IN;
             WHEN REGISTER_23=>
                    			S_REGISTER_23<=S_DATA_IN;
             WHEN REGISTER_24=>
                    			S_REGISTER_24<=S_DATA_IN;
             WHEN REGISTER_25=>
                    			S_REGISTER_25<=S_DATA_IN;                               
             WHEN REGISTER_26=>
                    			S_REGISTER_26 <=S_DATA_IN;
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
                    			 S_REGISTER_34<=S_DATA_IN;
             WHEN REGISTER_35=>
                    			S_REGISTER_35<=S_DATA_IN;
             WHEN REGISTER_36=>
                    			S_REGISTER_36<=S_DATA_IN;
             WHEN REGISTER_37=>
                    			 S_REGISTER_37<=S_DATA_IN;
             WHEN REGISTER_38=>
                    			S_REGISTER_38<=S_DATA_IN;
             WHEN REGISTER_39=>
                    			S_REGISTER_39<=S_DATA_IN;
             WHEN REGISTER_40=>
                    			S_REGISTER_40<=S_DATA_IN;
             WHEN REGISTER_41=>
                    			 S_REGISTER_41<=S_DATA_IN;
             WHEN REGISTER_42=>
                    			 S_REGISTER_42<=S_DATA_IN;
             WHEN REGISTER_43=>
                    			 S_REGISTER_43<=S_DATA_IN;
             WHEN REGISTER_44=>
                    			 S_REGISTER_44<=S_DATA_IN;
             WHEN REGISTER_45=>
                    			 S_REGISTER_45<=S_DATA_IN;
             WHEN REGISTER_46=>
                    			 S_REGISTER_46<=S_DATA_IN;
             WHEN REGISTER_47=>
                    			 S_REGISTER_47<=S_DATA_IN;
             WHEN REGISTER_48=>
                    			S_REGISTER_48<=S_DATA_IN;
             WHEN REGISTER_49=>
                    			S_REGISTER_49<=S_DATA_IN;
             WHEN REGISTER_50=>
                    			S_REGISTER_50<=S_DATA_IN;
             WHEN REGISTER_51=>
                    			S_REGISTER_51<=S_DATA_IN;
             WHEN REGISTER_52=>
                    			S_REGISTER_52<=S_DATA_IN;
             WHEN REGISTER_53=>
                    			S_REGISTER_53<=S_DATA_IN;
             WHEN REGISTER_54=>
                    			S_REGISTER_54<=S_DATA_IN;
             WHEN REGISTER_55=>
                    			 S_REGISTER_55<=S_DATA_IN;
             WHEN REGISTER_56=>
                    			 S_REGISTER_56<=S_DATA_IN;
             WHEN REGISTER_57=>
                    			 S_REGISTER_57<=S_DATA_IN;
             WHEN REGISTER_58=>
                    			 S_REGISTER_58<=S_DATA_IN;
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
       S_REGISTER_4 <= WR_TO_TEST_ERROR;
       S_REGISTER_9 <= (others => '0'); -- !TODO: 23/04/2023 SoftReset_ResetSticky
       S_REGISTER_12(15 downto 0) <= AMS_DATA2R;
    
       asic_rdwr_exe <= asic_rdwr_exe_i;
       ams_asics_reset <= S_REGISTER_10(8);
       Power_en_mask <= S_REGISTER_14(1 downto 0);
       
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
