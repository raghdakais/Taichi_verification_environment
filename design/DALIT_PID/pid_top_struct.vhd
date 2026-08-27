-----------------------------------------------------------
-----------------------------------------------------------
-- Date : 15/05/2023
-----------------------------------------------------------
-- Block Name:Pulse_create
-----------------------------------------------------------
-- simulation tool : ModelSim PE 10.7a
------------------------------------------------------------
-- Versions :
--   --01.01 First version
	 --01.02 add "Sensor1_influence" as an output
------------------------------------------------------------
------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all;

ENTITY PID_TOP IS
   PORT( 
      Clock       		  : IN     std_logic ;
	  nReset      		  : IN     std_logic ; 
      Kd          		  : IN     std_logic_vector (15 DOWNTO 0);
      Ki         		  : IN     std_logic_vector (15 DOWNTO 0);
      Kp          		  : IN     std_logic_vector (15 DOWNTO 0);
      Kaw		  		  : IN     std_logic_vector (15 DOWNTO 0);	     
      Sensor_In1  		  : IN     std_logic_vector (15 DOWNTO 0);
	  Sensor_In2  		  : IN     std_logic_vector (15 DOWNTO 0);
      Sensor1_influence	  : IN     std_logic_vector(3 DOWNTO 0);
	  SetPoint    		  : IN     std_logic_vector (15 DOWNTO 0);	  
	  Sample      		  : IN     std_logic ;
	  Calc_PID    		  : IN     std_logic ;
	  Integrat_update_time 		  : IN		std_logic_vector (15 downto 0);
  --  Max_Out     		  : IN     std_logic_vector (7 DOWNTO 0);
  --  Min_out     		  : IN     std_logic_vector (7 DOWNTO 0);
  --  Offset      		  : IN     std_logic_vector (7 DOWNTO 0);
     
	  PID_Out     		  : OUT    std_logic_vector (7 DOWNTO 0);
      Sensors_Moving_SUM  : OUT    std_logic_vector (15 DOWNTO 0)
   );

END PID_TOP ;

----------------------------------------------------------------------
ARCHITECTURE struct OF PID_TOP IS
-------------------------------------------------------------------

   SIGNAL Mult_By      			: std_logic_vector(15 DOWNTO 0);
   SIGNAL Mult_Data    			: std_logic_vector(15 DOWNTO 0);
   SIGNAL Mult_out     			: std_logic_vector(31 DOWNTO 0);
   SIGNAL s_mov_avg_Ready       : std_logic;
   SIGNAL S_Sensors_Moving_SUM  : std_logic_vector(15 DOWNTO 0);


   -- Component Declarations
   COMPONENT PID_Formula
   PORT (
      Clock        		: IN  std_logic;
	  nReset       		: IN  std_logic;
      Kd          		: IN  std_logic_vector (15 DOWNTO 0);
      Ki           		: IN  std_logic_vector (15 DOWNTO 0);
      Kp           		: IN  std_logic_vector (15 DOWNTO 0);
      Kaw		   		: IN  std_logic_vector (15 DOWNTO 0);	  
      Mult_out			: IN  std_logic_vector (31 DOWNTO 0);   
      Calc_PID     		: IN  std_logic;
	  Sample_Ready      : IN  std_logic;						
	  Sensors_Moving_SUM : IN  std_logic_vector(15 downto 0);
      SetPoint     		: IN  std_logic_vector (15 DOWNTO 0);  
	  Integrat_update_time  		: IN  std_logic_vector (15 downto 0);
 --   Max_Out      		: IN  std_logic_vector (7 DOWNTO 0);
 --   Min_out      		: IN  std_logic_vector (7 DOWNTO 0);     
 --   Offset       		: IN  std_logic_vector (7 DOWNTO 0);
	  Mult_By      		: OUT std_logic_vector (15 DOWNTO 0);
      Mult_Data    		: OUT std_logic_vector (15 DOWNTO 0);
      PID_Out      		: OUT std_logic_vector (7 DOWNTO 0)		  
   );
   END COMPONENT;
   COMPONENT sensor_union
   PORT (
        clk        			: IN  STD_LOGIC;                                    
		reset_n   			: IN  STD_LOGIC;                                    
		sensor_in1 			: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);                                    
		sensor_in2 			: IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
		sensor1_influence 	: IN  STD_LOGIC_VECTOR(3 DOWNTO 0); 
		Sample       		: IN  std_logic;
		Mov_avg_Ready		: OUT std_logic;
		Sensors_Moving_SUM  	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
   END COMPONENT;

   COMPONENT mult_gen_0
   PORT (
        CLK : IN STD_LOGIC;
        A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        P : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
   );
   END COMPONENT;


-----------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------

   -- Instance port mappings.
   PID_inst : PID_Formula
      PORT MAP (       
         Clock        		  => Clock				,
         nReset      		  => nReset				,
		 Kd           		  => Kd					,
         Ki           		  => Ki					,
         Kp           		  => Kp					,
         Kaw		  		  => Kaw				,
		 Mult_out     		  => Mult_out			,
         Calc_PID     		  => Calc_PID			,
		 Sample_Ready         => s_mov_avg_Ready	,
		 Sensors_Moving_SUM   => S_Sensors_Moving_SUM,---Sensor_In,
         SetPoint             => SetPoint			,       
         Integrat_update_time => Integrat_update_time,
         Mult_By              => Mult_By			,
         Mult_Data            => Mult_Data			,
         PID_Out              => PID_Out
      );
	  
	  Sensors_Moving_SUM <=S_Sensors_Moving_SUM;
	  
  Sensors_Moving_SUM_inst : sensor_union
      PORT MAP (
          clk        		=> Clock				,                                    
		  reset_n   		=> nReset				,	                                  
		  sensor_in1 		=> Sensor_In1			,	                                
		  sensor_in2 		=> Sensor_In2			,	
		  sensor1_influence => Sensor1_influence	,--X"4"					,
		  Sample       		=> Sample				,
		  Mov_avg_Ready		=> s_mov_avg_Ready		,
		  Sensors_Moving_SUM => 	S_Sensors_Moving_SUM
      );
    mult_inst : mult_gen_0
      PORT MAP (
         CLK => Clock		,
         A   => Mult_Data	,
         B   => Mult_By		,
         P   => Mult_out
      );

END struct;
