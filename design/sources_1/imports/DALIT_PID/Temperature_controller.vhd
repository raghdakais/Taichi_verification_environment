
-----------------------------------------------------------
-----------------------------------------------------------
-- Date : 7/03/2023
-----------------------------------------------------------
-- Designer  : Dalit Cohen
----------------------------------------------------------
-- Block Name:Taichi Module (TMB) - Temperature_Controller
-----------------------------------------------------------
-- simulation tool : ModelSim PE 10.7a
------------------------------------------------------------
-- Versions :
--  --01.01 First version
------------------------------------------------------------
------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE IEEE.NUMERIC_STD.ALL;


ENTITY Temperature_Controller IS
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
	  HEATER_MODE   			: IN  STD_LOGIC_VECTOR (1 DOWNTO 0);	 --"00"->OFF  , "01" -> AUTO  , "10" -> MANUAL  (from reg) 
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

--------------------------------------------------------------------------------------------------------------------------------
END Temperature_Controller;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF Temperature_Controller IS
--------------------------------------------------------------------------------------------------------------------------------
CONSTANT NUM_CLK_between_pulses : NATURAL RANGE 0 TO 200_000_000  := INPUT_CLK/CLK_divider;--INPUT_CLK/10;   @@@change only for simulation need to be change back to INPUT_CLK/10@@@@@  D
CONSTANT ONE_CELSIUS_DEGREE     : std_logic_vector(15 DOWNTO 0) := x"0010" ;  --- each bit is 1/16  CELSIUS_DEGREE => 16decimal=>10h * 1/16 => 1 degree
CONSTANT HALF_CELSIUS_DEGREE    : std_logic_vector(15 DOWNTO 0) := x"0008" ; 

 CONSTANT NUM_of_pulses_for_DMSTooColD         :integer range 0 to 2000  := 1800; 
 CONSTANT NUM_of_pulses_for_DMSTooHot      	   :integer range 0 to 2000  := 1800; 
 CONSTANT NUM_of_pulses_for_stable       	   :integer range 0 to 2000  := 600; 
 CONSTANT NUM_of_pulses_for_not_stable   	   :integer range 0 to 2000  := 1800; 
 CONSTANT NUM_of_pulses_in_stable_duraion_bit  :integer range 0 to 2000  := 9;  -- count from 0 to 9 -> 10 pulses -> 1sec each LSB
 CONSTANT NUM_of_pulses_for_cannot_stabilize   :integer range 0 to 40_000  := 36_000;
 
 
 signal clk_counter     	      	: NATURAL RANGE 0 TO 100_000_000 := 0; 
 SIGNAL num_of_pulses_in_Sample  	: std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL num_of_pulses_in_Calc_PID   : std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL setpoint_normalization   	: std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL s_sensor_moving_sum   		: std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL s_stable_duration   		: std_logic_vector(31 DOWNTO 0):=(others=>'0');
 SIGNAL PULSE		  				: std_logic:='0'; 
 SIGNAL sample_count     			: std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL calc_pid_count     			: std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL s_sample		  			: std_logic:='0'; 
 SIGNAL s_calc_pid		  			: std_logic:='0'; 
 SIGNAL s_pwm_duty_cycle	  		: std_logic_vector(7 DOWNTO 0):=(others=>'0');
 SIGNAL s_dt	  					: std_logic_vector(15 DOWNTO 0):=(others=>'0');
-- SIGNAL s_dt1	  					: std_logic_vector(15 DOWNTO 0):=(others=>'0');
-- SIGNAL s_dt2	  					: std_logic_vector(15 DOWNTO 0):=(others=>'0');
 SIGNAL DmsTooHot_count     		: INTEGER :=0;
 SIGNAL DmsTooCold_count     		: INTEGER :=0; 
 SIGNAL nstable_time_count     		: INTEGER range 0 to 2000:=0; 
 SIGNAL stable_time_count     		: INTEGER range 0 to 2000:=0; 
  SIGNAL cannot_stable_counter 		:INTEGER range 0 to 40_000:=0; 
 SIGNAL stable_duration_pulse_count : INTEGER range 0 to 100:=0; 
 SIGNAL s_DmsTooHot		  			: std_logic:='0';
 SIGNAL s_DmsTooCold		  		: std_logic:='0';
 SIGNAL s_stable		  			: std_logic:='0';
 SIGNAL s_cannot_satbilize		  	: std_logic:='0';
 SIGNAL cold_time		  			: std_logic:='0'; 
 SIGNAL heat_time		  			: std_logic:='0';
-- SIGNAL s_not_stable		  		: std_logic:='0';

    attribute DONT_TOUCH                    : string;
    attribute DONT_TOUCH of s_sample : signal is "true";
    attribute mark_debug                    : string;
    attribute mark_debug of s_sample : signal is "true";

--------------------------------------------------------------------------------------------------------------------------------
BEGIN
--------------------------------------------------------------------------------------------------------------------------------

PROCESS(clk, reset_n)
  BEGIN
    
	IF(reset_n = '0') THEN                                                 			
     clk_counter <= 0;
	 s_pwm_duty_cycle <= (others=>'0'); 
	 PULSE <= '0';
 
	 num_of_pulses_in_Sample <= (others=>'0'); 
	 num_of_pulses_in_Calc_PID <= (others=>'0'); 
	 sample_count <= (others=>'0'); 
	 calc_pid_count <= (others=>'0'); 
	 s_dt <= (others=>'0'); 
	-- s_dt1 <= (others=>'0'); 
	-- s_dt2 <= (others=>'0'); 
	 s_stable_duration<= (others=>'0');
	 cold_time <='0';
     heat_time <='0';	 
	 s_sample <='0';
	 s_calc_pid <='0';
	 DmsTooHot_count <= 0;
	 DmsTooCold_count <= 0;
	 nstable_time_count <= 0;
	 stable_time_count <= 0;
	 cannot_stable_counter <=0;
	 stable_duration_pulse_count <=0;
	 s_DmsTooHot <='0';
	 s_DmsTooCold <='0';
	 s_cannot_satbilize <='0';
	 s_stable <='0';
	-- s_not_stable <='0';
	 
	ELSIF(clk'EVENT AND clk = '1') THEN                                      	
			

	---counter of Nms (foe example: 100ms = 0.1 seconed)----
	IF clk_counter/= (NUM_CLK_between_pulses-1) THEN 
		clk_counter   <=clk_counter + 1;
		PULSE <= '0';	---pulse each 100ms
	ELSE							
		clk_counter	<=0;
		PULSE <= '1';			
	END IF;
	------------------------------------
	
	
	---SAMPLE PULSE CREATE------
	if Sample_reg=x"00" then
		num_of_pulses_in_Sample <= x"0005";
	else
		num_of_pulses_in_Sample<= Sample_reg;
	end if;
		
	if PULSE='1'then
		if sample_count< num_of_pulses_in_Sample-1 then
			sample_count<=sample_count+x"0001";
			s_sample<='0';
		elsif sample_count=num_of_pulses_in_Sample-1 then
			s_sample<='1';
			sample_count<=x"0000";
		end if;
	else
	   s_sample<='0';             --s_sample will be pulse of one clock
	   sample_count <=sample_count;
	end if;	
	----------------------------------
	
	---CALC PID PULSE CREATE------
	if Calc_PID_reg=x"00" then
		num_of_pulses_in_Calc_PID <= x"000A";
	else
		num_of_pulses_in_Calc_PID<= Calc_PID_reg;
	end if;
	
	if PULSE='1'then
		if calc_pid_count< num_of_pulses_in_Calc_PID-1 then
			calc_pid_count<=calc_pid_count+x"0001";
			s_calc_pid<='0';
		elsif calc_pid_count=num_of_pulses_in_Calc_PID-1 then
			s_calc_pid<='1';
			calc_pid_count<=x"0000";
		end if;
	else
	   s_calc_pid<='0';         --s_calc_pid will be pulse of one clock
		calc_pid_count<=calc_pid_count;
	end if;	
	----------------------------------
	
	---HEATER MODES-----------
	 case HEATER_MODE is
			when "00" => 	s_pwm_duty_cycle<=x"00"; --HEATER OFF mode
			when "10" => 	s_pwm_duty_cycle<=Calculated_PID; --AUTO mode  !debug: 10/05/2023 Eugene Shinderman was "01"
			when "01" => 	s_pwm_duty_cycle<=PID_REG_FOR_MANUAL_MODE; --MANUAL HEATER mode (from reg)
			when others =>null;
	 end case;
	--------------------------
	
	----abs of dt -> |sum of 16 samples of temperature - set point *16| ----  set point input from registers need to be for example 36 celsius= one celsius (x"0010"*36decimal) = x"0240" 
	setpoint_normalization <= SetPoint(11 downto 0) & x"0";  --move 4 bit left equal to multipul by 16 = 2^4 for example x"0240" *16 decimal => x"2400"
	s_sensor_moving_sum <=Sensors_Moving_SUM;
	if s_sensor_moving_sum>setpoint_normalization then
		s_dt<= s_sensor_moving_sum-setpoint_normalization;
		heat_time <='1';
		cold_time <='0';
	else
		s_dt<= setpoint_normalization-s_sensor_moving_sum;
		cold_time <='1';
		heat_time <='0';
	end if;
	
	----abs of dt -> | temperature - set point| ----
	-- if Sensors_Moving_SUM>SetPoint then
		-- s_dt<= Sensors_Moving_SUM-SetPoint;
	-- else
		-- s_dt<= SetPoint-Sensors_Moving_SUM;
	-- end if;
	
	--------------------------------------------------------------------------

	
	---DmsTooHot Errors output-----------
--	s_dt1 <= s_sensor_moving_sum-setpoint_normalization; ---TempIn-SP for DmsTooHot		
	if PULSE='1' then
		if (s_pwm_duty_cycle = x"00" and s_dt > ONE_CELSIUS_DEGREE and heat_time ='1') then  
			if DmsTooHot_count< NUM_of_pulses_for_DMSTooHot then ---for prevent the stable_time_count to get to the possible edge
				DmsTooHot_count<=DmsTooHot_count+1;
			end if;				
		elsif(s_pwm_duty_cycle /= x"00"  or (s_dt < ONE_CELSIUS_DEGREE and heat_time ='1') ) then  				
			DmsTooHot_count<=0;
		end if;
	end if;
	
	if DmsTooHot_count = NUM_of_pulses_for_DMSTooHot then  -- heater_off_for_3minute (when Heater @ 0% for 3 minute and also temp - setpoint >1 celsius degress)
		s_DmsTooHot<='1';	
	else
		s_DmsTooHot<='0';   
	end if;		
	---------------------------------
	
	---DmsTooCold Errors output-----------
	-- s_dt2 <= setpoint_normalization-s_sensor_moving_sum; ---SP-TempIn for DmsTooCold	 
	 if PULSE='1' then
		 if ( s_pwm_duty_cycle = x"FF" and s_dt > ONE_CELSIUS_DEGREE and cold_time ='1' ) then  
			if DmsTooCold_count< NUM_of_pulses_for_DMSTooCold then ---for prevent the stable_time_count to get to the possible edge
				DmsTooCold_count<=DmsTooCold_count+1;
			end if;				
		 elsif	( s_pwm_duty_cycle /= x"FF" or (s_dt < ONE_CELSIUS_DEGREE and cold_time ='1') ) then  				
			DmsTooCold_count<=0;
		 end if;
	 end if;
	
	if DmsTooCold_count = NUM_of_pulses_for_DMSTooCold then  -- heater_on_edge_for_1minute (when Heater @ either 0% or 100% for 1 minute and also |actual temp - setpoint| >1 celsius degress)
		s_DmsTooCold<='1';	
	else
		s_DmsTooCold<='0';    
	end if;	
	-------------------------------------
	
	--Cannot Stabilize Errors output-------------
	if s_dt< ONE_CELSIUS_DEGREE and PULSE='1' then
		if cannot_stable_counter< NUM_of_pulses_for_cannot_stabilize then  ---for prevent the stable_time_count to get to the possible edge
			cannot_stable_counter<=cannot_stable_counter+1;
		end if;
	elsif s_dt > ONE_CELSIUS_DEGREE and PULSE='1' then
		cannot_stable_counter<= 0;	
	end if;
	
	if cannot_stable_counter= NUM_of_pulses_for_cannot_stabilize then
		s_cannot_satbilize <='1';
	else
		s_cannot_satbilize <='0';
	end if;
	-------------------------------------------------
	
	
	--- Temp stable----status output------------------------
	if s_dt< HALF_CELSIUS_DEGREE and PULSE='1' then
		if stable_time_count< NUM_of_pulses_for_stable then  ---for prevent the stable_time_count to get to the possible edge
			stable_time_count<=stable_time_count+1;
		end if;
	elsif s_dt > HALF_CELSIUS_DEGREE and PULSE='1' then
		stable_time_count<= 0;
	end if;
	
	if s_dt>ONE_CELSIUS_DEGREE and PULSE='1' then
		if nstable_time_count< NUM_of_pulses_for_not_stable then ---for prevent the stable_time_count to get to the possible edge
			nstable_time_count<=nstable_time_count+1;
		end if;		
	elsif s_dt<ONE_CELSIUS_DEGREE and PULSE='1' then
		nstable_time_count<= 0;
	end if;
	
	if stable_time_count = NUM_of_pulses_for_stable then
		s_stable<='1';
	elsif s_dt > ONE_CELSIUS_DEGREE and nstable_time_count = NUM_of_pulses_for_not_stable then	   
	   s_stable<='0';
	end if;
	--------------------------------
	
	---stable duration--status output-------------
	if  PULSE='1' then
		if stable_duration_pulse_count < NUM_of_pulses_in_stable_duraion_bit then
			stable_duration_pulse_count <=stable_duration_pulse_count+1;
		elsif stable_duration_pulse_count= NUM_of_pulses_in_stable_duraion_bit then
			stable_duration_pulse_count<=0;
			s_stable_duration<=s_stable_duration+x"00000001";
		end if;
	end if;
	-----------------------------------------------------

		



	
  END IF;
 END PROCESS;		
-----------------------------------------------------------------------------------------
--NOT_STABLE <= s_not_stable;
STABLE <= s_stable;
STABLE_DURATION <=s_stable_duration; 
Cannot_Stabilize <= s_cannot_satbilize;
SAMPLE <= s_sample;
Calc_PID <= s_calc_pid; 
DmsTooHot <= s_DmsTooHot;
DmsTooCold <= s_DmsTooCOld;
PWM_Duty_Cycle <=	s_pwm_duty_cycle;
--------------------------------------------------------------------------------------------------------------------------------
END ARCHITECTURE BEHAVE;
--------------------------------------------------------------------------------------------------------------------------------






	----FAN MODES-----------
	 -- if ((s_pwm_duty_cycle = x"00" or s_pwm_duty_cycle = x"FF") and s_dt > ONE_CELSIUS_DEGREE  and PULSE='1') then  
		-- if fan_time_count< NUM_of_pulses_for_fan_mode then ---for prevent the stable_time_count to get to the possible edge
			-- fan_time_count<=fan_time_count+1;
		-- end if;				
	 -- elsif	(((s_pwm_duty_cycle /= x"00" and s_pwm_duty_cycle /= x"FF") or s_dt < ONE_CELSIUS_DEGREE ) and PULSE='1') then  				
		-- fan_time_count<=0;
	 -- end if;
	
	-- if fan_time_count = NUM_of_pulses_for_fan_mode then  -- heater_on_edge_for_1minute (when Heater @ either 0% or 100% for 1 minute and also |actual temp - setpoint| >1 celsius degress)
		-- s_fan_mode<='1';	--Dynamic speed	(need help from PS)	
	-- else
		-- s_fan_mode<='0';    --FIXED speed (no help from PS)
	-- end if;
	-----------------------
	
	--- Temp not stable----------	
	-- if s_dt>ONE_CELSIUS_DEGREE and PULSE='1' then
		-- if nstable_time_count< NUM_of_pulses_for_not_stable then ---for prevent the stable_time_count to get to the possible edge
			-- nstable_time_count<=nstable_time_count+1;
		-- end if;		
	-- elsif s_dt<ONE_CELSIUS_DEGREE and PULSE='1' then
		-- nstable_time_count<= 0;
	-- end if;
	
	-- if nstable_time_count = NUM_of_pulses_for_not_stable then
		-- s_not_stable<='1';
	-- else
	   -- s_not_stable<='0';
	-- end if;
	--------------------------------
	
