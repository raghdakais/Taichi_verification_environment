-----------------------------------------------------------
-----------------------------------------------------------
-- Date : 7/03/2023
-----------------------------------------------------------
-- Block Name:PID
-----------------------------------------------------------
-- simulation tool : ModelSim PE 10.7a
------------------------------------------------------------
-- Versions :
--   --01.01 First version
------------------------------------------------------------
------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all;

ENTITY PID_Formula IS
   PORT( 
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

END PID_Formula ;

------------------------------------------------------------------
ARCHITECTURE PID_Formula OF PID_Formula IS
-------------------------------------------------------------------
	CONSTANT Max_Out        :std_logic_vector (7 DOWNTO 0)  := x"FF"; 
	CONSTANT Min_out        :std_logic_vector (7 DOWNTO 0)  := x"00"; 	
	CONSTANT Offset         :std_logic_vector (7 DOWNTO 0)  := x"00"; 
	
	SIGNAL S_Err, S_Last_Err						: signed(15 DOWNTO 0);
	SIGNAL S_PID									: std_logic_vector(7 DOWNTO 0);
	SIGNAL S_PD_Full_Range							: std_logic_vector(15 DOWNTO 0);
	SIGNAL Reranged_PID								: std_logic_vector(15 DOWNTO 0);
	SIGNAL Seq_num									: INTEGER range 0 to 127;
	SIGNAL Stage									: std_logic_vector(3 DOWNTO 0);
	SIGNAL Virtual_PID								: std_logic_vector(31 DOWNTO 0);
	SIGNAL s_Sensors_Moving_SUM								: std_logic_vector(15 DOWNTO 0);
	SIGNAL S_Calc_PID								: std_logic_vector(2 DOWNTO 0);
	SIGNAL Integral_Timer							: std_logic_vector(15 DOWNTO 0);        
   	SIGNAL Integral,Derivative,Proportional			: std_logic_vector(31 DOWNTO 0);	
   	SIGNAL Integral_V,AntiWindup_V, PID_Combined	: std_logic_vector(31 DOWNTO 0);	 	
	SIGNAL Prev_Err_1								: signed(15 DOWNTO 0);                      

    attribute DONT_TOUCH                    : string;
    attribute DONT_TOUCH of Stage, S_Err, Integral,Integral_V, AntiWindup_V, Proportional, Derivative,
      PID_Combined, S_PD_Full_Range, Reranged_PID, Virtual_PID, Seq_num, Integral_Timer, S_Calc_PID : signal is "true";
    attribute mark_debug                    : string;
    attribute mark_debug of Stage, S_Err, Integral,Integral_V, AntiWindup_V, Proportional, Derivative,
      PID_Combined, S_PD_Full_Range, Reranged_PID, Virtual_PID, Seq_num, Integral_Timer, S_Calc_PID : signal is "true";
    
	
BEGIN

	PROCESS (nReset, Clock)

	BEGIN

		IF (nReset = '0') THEN

		 S_Err					<= (others=>'0');
		 S_Last_Err				<= (others=>'0');
		 Mult_Data				<= (others=>'0');
		 Mult_By				<= (others=>'0');
         PID_Out				<= (others=>'0');
         S_PID					<= (others=>'0');
         S_PD_Full_Range		<= (others=>'0');
         Reranged_PID			<= (others=>'0');
         Seq_num				<= (0);
         Stage					<= (others=>'0');
         Virtual_PID			<= (others=>'0');
         s_Sensors_Moving_SUM	<= (others=>'0');
         S_Calc_PID				<= (others=>'0');
         Integral_Timer			<= (others=>'0');
         Prev_Err_1				<= (others=>'0');
         Integral               <= (others=>'0');
         Derivative             <= (others=>'0');
         Proportional           <= (others=>'0');
         Integral_V             <= (others=>'0');
         AntiWindup_V           <= (others=>'0');
         PID_Combined           <= (others=>'0');
         
		ELSIF rising_edge(Clock) THEN

		
		if (Sample_Ready='1') then					
			s_Sensors_Moving_SUM<=Sensors_Moving_SUM;
		end if;
		
		
------------------------------------------------------------------------------------------------------------		 
------------------------------------------ PID Calculation Block ------------------------------------------- 		     
------------------------------------------------------------------------------------------------------------
		 
		 S_Calc_PID(2 DOWNTO 0) 	<= S_Calc_PID(1 DOWNTO 0) & Calc_PID; -- Sampling the Command (Pulse) to start PID Calculation Cycle 
		 		 
		 Stage				<=	X"0";

		 If (Seq_num<(70)) then
		 	Seq_num <= Seq_num + 1;
		 Else
		 	If (S_Calc_PID(2 DOWNTO 1)="01") then	-- Identified Start PID Calculation request from Temperature Stabilization Manager
		 		Seq_num	<= 0;
		 		
		 		If Unsigned(Integral_Timer) > X"0000" then 
		 			Integral_Timer <= Integral_Timer - 1;
		 		ElsIf Integral_Timer = X"0000" then
		 			Integral_Timer <= X"00" & Integrat_update_time(15 downto 8); --X"A0"; Integral_Cycle_Time;
		 		Else
		 			Integral_Timer <= Integral_Timer;
		 		End If;		 		
		 	Else
		 		Seq_num <= Seq_num;
		 	End If;
		 End If;
		
	
		 
-------------------------------------------------------------------------------------------------------------		 	
--		PSEUDO-PID-CODE
--		previous_error = 0
--		integral = 0 
--		start:
--		  error = setpoint - measured_value
--		  integral = integral + error*dt
--		  derivative = (error - previous_error)/dt
--		  output = Kp*error + Ki*integral + Kd*derivative
--		  previous_error = error
--		  wait(dt)
--		  goto start

		 Case Seq_num is
		 	
		 When 0 to 9 =>		
		 	Stage				<=	X"1";
	--		S_Err 				<= (signed(SetPoint(15 DOWNTO 0)) - signed(s_Sensors_Moving_SUM(15 DOWNTO 0)));
			S_Err 				<= (signed(SetPoint(11 DOWNTO 0)& "0000") - signed(s_Sensors_Moving_SUM(15 DOWNTO 0)));  

						
		 When 10 to 18 =>	
		 	Stage				<=	X"2";
			Mult_Data			<=	std_logic_vector(signed(S_Err) + signed(S_Last_Err));
			Mult_By				<=	Ki;

		 When 19 =>	
		 	Stage				<=	X"3";
			Integral_V			<=	std_logic_vector(signed(Mult_out(31 DOWNTO 0))); 	-- Introducing Anti-Windup

				
		 When 20 to 26 =>	
 		 	Stage				<=	X"4";		 
			Mult_Data			<=	std_logic_vector(signed(S_PD_Full_Range) - signed(PID_Combined(23 downto 8)));
			Mult_By				<=	Kaw;--X"0100";

					    
		 When 27 =>	
		 	Stage				<=	X"5";
			AntiWindup_V		<=	std_logic_vector(signed(Mult_out(31 DOWNTO 0))); 	--  Introducing Anti-Windup		 

						
		 When 28 =>	
		 	Stage				<=	X"6";
			If (Integral_Timer=X"0000") then  
				Integral	<= Integral + Integral_V + AntiWindup_V;
		 		S_Last_Err	<=  S_Err;				
			Else
				Integral	<=  Integral;
			End If;
		 
		 		 
		 When 29 =>	
		 	Stage				<=	X"7";
 			If (Kp=X"0000") or (Ki=X"0000") then 
 			 Integral		<=  X"00000000";
 			Elsif signed(Integral) > 65535 then
 			 Integral		<=  X"0000FFFF";
          	Elsif signed(Integral) < -65535 then
 			 Integral		<=  X"FFFF0001";  			
 			else
 			 Integral <= Integral;
 			End If; 
		 
		 		 		 		    			 	
		 When 30 to 38 =>
		 	Stage				<=	X"8";	
			Mult_Data			<=	std_logic_vector(signed(S_Err) - signed(S_Last_Err));		--std_logic_vector(S_Err-Prev_Err_1);
			Mult_By				<=	Kd;
		
				
		 When 39 =>
		 	Stage				<=	X"9";
		 	Derivative 			<= 	std_logic_vector(signed(Mult_out(31 DOWNTO 0))); 	-- Introducing Anti-Windup		 
		 	
		 When 40 to 48 =>
		 	Stage				<=	X"A";
			Mult_Data			<=	std_logic_vector(S_Err);
			Mult_By				<=	Kp;


		 When 49 =>
		 	Stage				<=	X"B";
		 	Proportional		<=  std_logic_vector(signed(Mult_out(31 DOWNTO 0)));			

						 		 	
		 When 50 =>	
		 	Stage				<=	X"C";
		 	PID_Combined		<= X"00007FFF" + Proportional + Integral + Derivative;
		 	
		
 		 When 51 =>			 	
		 	Stage				<=	X"D";		
			If (signed(PID_Combined)>X"0000FFFF") then
				S_PD_Full_Range <= X"00FF";
			Elsif (signed(PID_Combined)<X"00000000") then
				S_PD_Full_Range <= X"0000";
			Else
			    S_PD_Full_Range <= PID_Combined(23 downto 8); 
			End If; 

 					 
		 When 52 to 61 =>				 	 
		 	Stage				<=	X"E";		 
		 	Mult_Data			<=	S_PD_Full_Range;
		 	Mult_By				<=	std_logic_vector((X"00" & std_logic_vector(unsigned(Max_Out) - unsigned(Min_Out))) + X"0001");
		 	
			 If Mult_out(7)='1' then
		 	 	Reranged_PID	<= 	std_logic_vector(signed(Mult_out(23 DOWNTO 8)) + 1 + signed(Offset));
		 	 Else
		 	 	Reranged_PID	<= 	std_logic_vector(signed(Mult_out(23 DOWNTO 8)) + signed(Offset));
		 	 End If;
		 	 
		 	Virtual_PID <=  std_logic_vector(unsigned(Mult_out(31 DOWNTO 0)));
		 	 
		 	
		 When 62 to 69 =>	
		 	Stage				<=	X"F";

		 	If (Reranged_PID(15)='0') and (Reranged_PID(15 DOWNTO 0) >= (X"00" & Max_Out)) then
		 		S_PID	<=	Max_Out;
		 	ElsIf (Reranged_PID(15)='1') or (Reranged_PID(15 DOWNTO 0) <= (X"00" & Min_Out)) then
		 		S_PID	<=	Min_Out;
		 	Else
		 		S_PID	<=   Reranged_PID(7 DOWNTO 0);
		 	End If;
		 			 	
		 When OTHERS =>
		 
			PID_Out	<=	S_PID;
		   		 	 
		 End Case;
    
	
       
		  PID_Out	<=	S_PID;
		 
		
	 END IF;	
	END PROCESS;


END PID_Formula;

