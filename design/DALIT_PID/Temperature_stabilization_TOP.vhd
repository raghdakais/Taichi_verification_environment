
-----------------------------------------------------------
-----------------------------------------------------------
-- Date : 15/05/2023
-----------------------------------------------------------
-- Designer  : Dalit Cohen
----------------------------------------------------------
-- Block Name:Taichi Module - Temperature_Stabilization_TOP
-----------------------------------------------------------
-- simulation tool : ModelSim PE 10.7a
------------------------------------------------------------
-- Versions :
--  --01.01 First version
	--01.02 add "Sensor1_influence" as an output
------------------------------------------------------------
------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Temperature_Stabilization_TOP IS
    GENERIC(
		INPUT_CLK : INTEGER := 50_000_000; --input clock speed from user logic in Hz ---(50MHZ)
		CLK_divider: INTEGER := 10); ----for determine the NUM_CLK_between_pulses => create a pule each xx sec. for example 50M/10 => pulse of one clk every 100ms
	PORT(  
      Clock        				: IN  std_logic;
	  nReset       				: IN  std_logic;
      Kd           				: IN  std_logic_vector (15 DOWNTO 0);	-- PID kD Parameter of Derivative (Quick Input Change identificatio)
      Ki           				: IN  std_logic_vector (15 DOWNTO 0);	-- PID kI Parameter of Integral (Accumulating Error element)
      Kp           				: IN  std_logic_vector (15 DOWNTO 0);	-- PID kP Parameter of Proportional Band (Amplification)
	  Kaw		   				: IN  std_logic_vector (15 DOWNTO 0);
      Sensor_In1   				: IN  std_logic_vector (15 DOWNTO 0);	
	  Sensor_In2   				: IN  std_logic_vector (15 DOWNTO 0);	
      Sensor1_influence			: IN  std_logic_vector(3 DOWNTO 0);
      SetPoint     				: IN  std_logic_vector (15 DOWNTO 0);	-- Required Set Point 
	  Calc_PID_reg 				: IN  std_logic_vector (15 DOWNTO 0); 	--  interval between  PID Calculation cycle. if you want calc PID pulse evrey 1sec write 10 to the reg =>number of 0.1sec*10=1sec 
	  Sample_reg   				: IN  std_logic_vector (15 DOWNTO 0);	-- interval between sample Temperature Sensor into sum block - Temperature Sampling Rate. if you want sample pulse evrey 1sec write 10 to the reg =>number of 0.1sec*10=1sec
      Integrat_update_time 		: IN  std_logic_vector (15 downto 0);
	  HEATER_MODE  				: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);	 --"00"->OFF  , "10" -> AUTO  , "01" -> MANUAL  (from reg)  ---defult eugene off "00"
	  PID_REG_FOR_MANUAL_MODE   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
 --   Max_Out      				: IN  std_logic_vector (7 DOWNTO 0);	-- Defines Max Heater Command (Recommended 0xFF which is 100% PWM for Heater)  
 --   Min_out      				: IN  std_logic_vector (7 DOWNTO 0);	-- Defines Min Heater Command (Recommended 0x00 which is 0% PWM for Heater)
 --   Offset       				: IN  std_logic_vector (7 DOWNTO 0);	-- Defines Heater Command Offset - Adds "Offset" to the command of PID Out(Recommended 0x00)     
	  PID_Out      				: OUT std_logic_vector (7 DOWNTO 0);
	  Sensors_Moving_SUM  		: OUT std_logic_vector (15 DOWNTO 0);
--	  FAN_MODE     				: OUT STD_LOGIC; --'0' -> FIXED speed (NO "help" from PS needed) , '1' -> Dynamic speed - variable acording to actual temp (status- setpoint) ("Help" needed from PS)	  
--	  NOT_STABLE				: OUT std_logic;
	  STABLE					: OUT std_logic;
	  STABLE_DURATION			: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);	  
	  DMSTooCold				: OUT  std_logic;
	  DMSTooHot					: OUT  std_logic;
	  Cannot_Stabilize			: OUT  std_logic;
	  PWM_Duty_Cycle_IN			: OUT std_logic_vector (7 DOWNTO 0);
	  PWM_OUT  	   				: OUT std_logic;          							
      PWM_N_OUT    				: OUT std_logic
   );
END Temperature_Stabilization_TOP ;

----------------------------------------------------------------------
ARCHITECTURE struct OF Temperature_Stabilization_TOP IS
-------------------------------------------------------------------

   SIGNAL s_pid_out        		: std_logic_vector(7 DOWNTO 0);
   SIGNAL s_pwm_duty_cycle 		: std_logic_vector(7 DOWNTO 0);
   SIGNAL s_Sensors_Moving_SUM  : std_logic_vector(15 DOWNTO 0);
   SIGNAL s_sample         		: std_logic;
   SIGNAL s_calc_pid       		: std_logic;

   COMPONENT PID_TOP
   PORT (   
      Clock       		  : IN  std_logic ;
	  nReset     		  : IN  std_logic ; 
      Kd          		  : IN  std_logic_vector (15 DOWNTO 0);
      Ki          		  : IN  std_logic_vector (15 DOWNTO 0);
      Kp          		  : IN  std_logic_vector (15 DOWNTO 0);
      Kaw		  		  : IN  std_logic_vector (15 DOWNTO 0);	     
      Sensor_In1  		  : IN  std_logic_vector (15 DOWNTO 0);
	  Sensor_In2  		  : IN  std_logic_vector (15 DOWNTO 0);
      Sensor1_influence	  : IN  std_logic_vector(3 DOWNTO 0);
      SetPoint    		  : IN  std_logic_vector (15 DOWNTO 0);	  
	  Sample      		  : IN  std_logic ;
	  Calc_PID    		  : IN  std_logic ;
	  Integrat_update_time: IN  std_logic_vector (15 downto 0);
  --  Max_Out     		  : IN  std_logic_vector (7 DOWNTO 0);
  --  Min_out     		  : IN  std_logic_vector (7 DOWNTO 0);
  --  Offset      		  : IN  std_logic_vector (7 DOWNTO 0);
      
	  PID_Out     		  : OUT  std_logic_vector (7 DOWNTO 0);
      Sensors_Moving_SUM  : OUT  std_logic_vector (15 DOWNTO 0)
   );
   END COMPONENT;
   
   COMPONENT Module_HTR_DRV_PWM
    GENERIC(
      sys_clk         : INTEGER := 50_000_000; 			--system clock frequency in Hz --- (50MHZ)
      pwm_freq        : INTEGER := 5;    			    --PWM switching frequency in Hz --- (5HZ)
      bits_resolution : INTEGER := 8);          	    --bits of resolution setting the duty cycle        
   PORT(
      clk       		: IN  STD_LOGIC;                                    
      reset_n   		: IN  STD_LOGIC;                                                                      
      Duty_Cycle_In     : IN  STD_LOGIC_VECTOR(bits_resolution-1 DOWNTO 0); 
      pwm_out  			: OUT STD_LOGIC;          							
      pwm_n_out 		: OUT STD_LOGIC
   );
   END COMPONENT;

  COMPONENT Temperature_Controller 
	 GENERIC(
		INPUT_CLK : INTEGER := 50_000_000; --input clock speed from user logic in Hz ---(50MHZ)
		CLK_divider: INTEGER := 10); ----for determine the NUM_CLK_between_pulses => create a pule each xx sec. for example 50M/10 => pulse of one clk every 100ms
	PORT(
      clk        				: IN  STD_LOGIC;                                    
      reset_n   				: IN  STD_LOGIC;                                    
      Calc_PID_reg	   			: IN  std_logic_vector (15 DOWNTO 0); 		--  Command (Pulse) requesting PID Controller to start a PID Calculation cycle (Expected to arrive every 10sec)
	  Sample_reg	  			: IN  std_logic_vector (15 DOWNTO 0);
	  Sensors_Moving_SUM		: IN  std_logic_vector (15 DOWNTO 0);
	  SetPoint    				: IN  std_logic_vector (15 DOWNTO 0);	  
	  HEATER_MODE   			: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);	 --"00"->OFF  , "10" -> AUTO  , "01" -> MANUAL  (from reg)
	  PID_REG_FOR_MANUAL_MODE   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);		  
	  Calculated_PID			: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);	
	    
	  Calc_PID	   				: OUT  std_logic; 					--  Command (Pulse) requesting PID Controller to start a PID Calculation cycle (Expected to arrive every 10sec)
	  Sample	  			    : OUT  std_logic;
	  PWM_Duty_Cycle			: OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
	--  FAN_MODE     			: OUT  STD_LOGIC; --'0' -> FIXED speed (NO "help" from PS needed) , '1' -> Dynamic speed - variable acording to actual temp (status- setpoint) ("Help" needed from PS)	  
	--  NOT_STABLE				: OUT  std_logic;
	  STABLE					: OUT  std_logic;
	  STABLE_DURATION			: OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
	  
	  DMSTooCold				: OUT  std_logic;
	  DMSTooHot					: OUT  std_logic;
	  Cannot_Stabilize			: OUT  std_logic
	                                                                    
    );
	END COMPONENT;

-----------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------
	
    PID_TOP_inst : PID_TOP
      PORT MAP (       
         Clock       		 => Clock			,
		 nReset      		 => nReset			,    
         Kd          		 => Kd				,
         Ki          		 => Ki				,
         Kp          		 => Kp				,
         Kaw		 		 => Kaw,--"0100"	,	         
         Sensor_In1  		 => Sensor_In1		,
		 Sensor_In2  		 => Sensor_In2		,
         Sensor1_influence	 => Sensor1_influence,
         SetPoint    		 => SetPoint		,		 
		 Sample      		 => s_sample		,
		 Calc_PID    		 => s_calc_pid		,
		 Integrat_update_time => Integrat_update_time,--x"A003",
	--	 Max_Out    		 => Max_Out			,
    --   Min_out    		 => Min_out			,
    --   Offset     		 => Offset			,
         
		 PID_Out     		 => s_pid_out		,
         Sensors_Moving_SUM  => s_Sensors_Moving_SUM
      );
	  
  PWM_inst: Module_HTR_DRV_PWM
  GENERIC MAP (
		sys_clk => INPUT_CLK			, 
		pwm_freq => 5, -- !debug: 10/05/2023 Eugene Shinderman was 5, for simulationuse high freq, ex. 20e3
		bits_resolution => 8)
	PORT MAP (			
			clk => Clock						,
			reset_n => nReset					,
			Duty_Cycle_In => s_pwm_duty_cycle	,
			pwm_out => PWM_OUT					,
			pwm_n_out => PWM_N_OUT			
					
		  );
		  
PWM_Duty_Cycle_IN <=s_pwm_duty_cycle;

 TEMP_CONTROL_inst: Temperature_Controller
  GENERIC MAP (
		INPUT_CLK => INPUT_CLK,
		CLK_divider => CLK_divider)					
	PORT MAP (			
			clk 					=> Clock				 	,
			reset_n 				=> nReset			 		,
			Calc_PID_reg 			=> Calc_PID_reg 			,
			Sample_reg 				=> Sample_reg				,
			Sensors_Moving_SUM 		=> s_Sensors_Moving_SUM	 	,
			SetPoint 				=> SetPoint		 			,
			HEATER_MODE 			=> HEATER_MODE	       	   	,
			PID_REG_FOR_MANUAL_MODE => PID_REG_FOR_MANUAL_MODE 	,
			Calculated_PID 			=> s_pid_out				,			
			Calc_PID 				=> s_calc_pid				,
			Sample 					=> s_sample					,
			PWM_Duty_Cycle 			=> s_pwm_duty_cycle			,
		--	FAN_MODE 				=> FAN_MODE					,
		--	NOT_STABLE 				=> NOT_STABLE				,
			STABLE 					=> STABLE					,
			STABLE_DURATION			=> STABLE_DURATION			,
			DMSTooCold				=> DMSTooCold				,
			DMSTooHot				=> DMSTooHot				,
			Cannot_Stabilize		=> Cannot_Stabilize	
		  );

 

Sensors_Moving_SUM <= s_Sensors_Moving_SUM;	  
PID_Out <=s_pid_out;
-------------------------------------------------------------------------
END struct;
--------------------------------------------------------------------------
