
-----------------------------------------------------------
-----------------------------------------------------------
-- Date : 01/10/2023
-----------------------------------------------------------
-- Designer  : Dalit Cohen
----------------------------------------------------------
-- Block Name:Taichi Module (TMB) - Heater Driver sensor_union
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


ENTITY sensor_union IS

  PORT(
      clk        			: IN  STD_LOGIC;                                    
      reset_n   			: IN  STD_LOGIC;                                    
      sensor_in1 			: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);                                    
      sensor_in2 			: IN  STD_LOGIC_VECTOR(15 DOWNTO 0); 
	  sensor1_influence 	: IN  STD_LOGIC_VECTOR(3 DOWNTO 0); 
      Sample       			: IN   std_logic;
	  Mov_avg_Ready			: OUT   std_logic;
	  Sensors_Moving_SUM  	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)        							
    );         							

--------------------------------------------------------------------------------------------------------------------------------
END sensor_union;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF sensor_union IS
--------------------------------------------------------------------------------------------------------------------------------
 TYPE SENSOR_AVRG_ARRAY IS ARRAY (15 downto 0) OF STD_LOGIC_VECTOR(15 downto 0);
 
 SIGNAL S_SENSOR_AVRG_ARRAY				: SENSOR_AVRG_ARRAY;
 SIGNAL S_Sensor_SUM					: std_logic_vector(19 DOWNTO 0):=(others=>'0'); 
 SIGNAL s_sensor_in						: std_logic_vector(19 DOWNTO 0):=(others=>'0'); 
 SIGNAL s_first_sensor_value_in_array	: std_logic_vector(19 DOWNTO 0):=(others=>'0'); 
 SIGNAL S_Sensors_Moving_SUM				: std_logic_vector(15 DOWNTO 0):=(others=>'0'); 
 SIGNAL S_Sample						: std_logic_vector(2 DOWNTO 0):=(others=>'0'); 
 SIGNAL S_Sensor_avrg   				: std_logic_vector(15 DOWNTO 0):=(others=>'0');  
 signal Sensor_SUM  				 	: STD_LOGIC_VECTOR(19 DOWNTO 0):=(others=>'0'); 
 signal s_sensor1_influence 		 	: STD_LOGIC_VECTOR(3 DOWNTO 0):=(others=>'0');  
 signal cnt 						 	: INTEGER RANGE 17 DOWNTO 0:=16;
 signal clk_cnt 					 	: INTEGER RANGE 17 DOWNTO 0:=0;
 signal i 							 	: INTEGER RANGE 17 DOWNTO 0:=15;
 signal sum_ready  						: STD_LOGIC:='0';
 signal s_mov_avg_Ready  				: STD_LOGIC:='0';
 signal s_sensor1_influence_change   	: STD_LOGIC:='0';
 signal sample_time  					: STD_LOGIC:='0';
 signal Sensor_avrg  					: STD_LOGIC_VECTOR(15 DOWNTO 0):=(others=>'0'); 
--------------------------------------------------------------------------------------------------------------------------------
BEGIN
--------------------------------------------------------------------------------------------------------------------------------
PROCESS(clk, reset_n)
  BEGIN
    
	IF(reset_n = '0') THEN                                                 			
     
	 Sensor_avrg <= (others=>'0');                                        		 			
	 Sensor_SUM <=(others=>'0');
	 cnt <=16;
	 sum_ready<='0';
	 sample_time<='0';
	 s_mov_avg_Ready<='0';
	 s_sensor1_influence<=(others=>'0');
	 s_sensor1_influence_change<='0';
	 s_Sensor_avrg <= (others=>'0');
	 clk_cnt<=0;
	 i<=15;
	 Mov_avg_Ready<='0';
	 S_Sensor_SUM <= (others=>'0');
	 S_Sample <= (others=>'0');
	 S_SENSOR_AVRG_ARRAY <= (others=> (others=>'0'));
	 S_Sensors_Moving_SUM <= (others=>'0');
	 Sensors_Moving_SUM <= (others=>'0');
	 s_sensor_in <= (others=>'0');
	 s_first_sensor_value_in_array <= (others=>'0');
	 
	ELSIF(clk'EVENT AND clk = '1') THEN                                      	

--------------------averaging of sensor1 and sensor2---------------------------

			if (sum_ready='1' and s_sensor1_influence_change='0') then     --if finish calculate the averge sum and no change in sensor_influence was seen latch it to sensor_avrg
				sensor_avrg <=s_Sensor_avrg;
				Sensor_SUM<= (others=>'0');
				sum_ready<='0';
				cnt<=0;
			elsif (sum_ready='1' and s_sensor1_influence_change='1') then
				s_sensor1_influence_change<='0';
				Sensor_SUM<= (others=>'0');
				sum_ready<='0';
				cnt<=0;
			end if;
		
			if  (s_sensor1_influence/=sensor1_influence and cnt=16 )then  --if s_sensor1_influence change latch it only after finish calculate the previous sensor_sum
				s_sensor1_influence_change<='1';
			    s_sensor1_influence<=sensor1_influence;
			elsif (s_sensor1_influence/=sensor1_influence and cnt/=16 ) then
				s_sensor1_influence_change<='1';
			end if;
						
			Case s_sensor1_influence is
				When X"0" =>	if (cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2; 		--- 0(0%) sensor1 , 16 (100%) sensor2	
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
									s_Sensor_avrg<=Sensor_SUM (15 downto 0);
								end if;											
				When X"1" =>	if (cnt<2) then
									Sensor_SUM <=Sensor_SUM + Sensor_In1;		--- 2(12.5%) sensor1 , 14 (87.5%) sensor2
									cnt<=cnt+1;
								elsif (cnt>1 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;							
				When X"2" =>	if (cnt<4) then 								 --- 4(25%) sensor1 , 12 (75%) sensor2						
									Sensor_SUM <=Sensor_SUM + Sensor_In1;
									cnt<=cnt+1;
							   elsif (cnt>3 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;
				When X"3" =>	if (cnt<6) then 							   --- 6(37.5%) sensor1 , 10 (62.5%) sensor2					
									Sensor_SUM <=Sensor_SUM + Sensor_In1;
									cnt<=cnt+1;
								elsif (cnt>5 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;
				When X"4" =>	if (cnt<8) then 							    --- 8(50%) sensor1 , 8 (50%) sensor2
									Sensor_SUM <=Sensor_SUM + Sensor_In1;
									cnt<=cnt+1;
								elsif (cnt>7 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;			
				When X"5" =>	if (cnt<10) then 							   --- 10(62.5%) sensor1 , 6 (37.5%) sensor2
									Sensor_SUM <=Sensor_SUM + Sensor_In1;
									cnt<=cnt+1;
								elsif (cnt>9 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;
				When X"6" =>	if (cnt<12) then 							   --- 12(75%) sensor1 , 4 (25%) sensor2
									Sensor_SUM <=Sensor_SUM + Sensor_In1;
									cnt<=cnt+1;
								elsif (cnt>11 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;
				When X"7" =>	if (cnt<14) then 							   --- 14(87.5%) sensor1 , 2 (12.5%) sensor2
									Sensor_SUM <=Sensor_SUM + Sensor_In1;
									cnt<=cnt+1;
								elsif (cnt>13 and cnt<16) then
									Sensor_SUM <=Sensor_SUM + Sensor_In2;
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;
				When X"8" =>	if (cnt<16) then							   --- 16(100%) sensor1 , 0 (0%) sensor2
									Sensor_SUM <=Sensor_SUM + Sensor_In1; 
									cnt<=cnt+1;
								elsif (cnt=16) then
									sum_ready<='1';
									s_Sensor_avrg<=Sensor_SUM (19 downto 4);
								end if;										
				when others =>null;
			End Case;
		
		
-------------------------------------------------------------------------------------------		
	
-----------------------moving average of sensor1 and sensor 2 averaging -----------------------		
		S_Sample(2 DOWNTO 0) <= S_Sample(1 DOWNTO 0) & Sample;		
		IF S_Sample(1)='1' and S_Sample(2)='0' then
			sample_time<='1';
		END IF;
		
		IF (sample_time='1') THEN --- the sample signal need to be as long as i want to continue calculated the moving averge
			sample_time<='0';
			if (clk_cnt<16 ) then 		--- first enter the first 16 values
				S_SENSOR_AVRG_ARRAY(i)<= sensor_avrg;
				S_Sensor_SUM<=S_Sensor_SUM+ ("0000"& sensor_avrg);
				s_sensor_in <= "0000"& sensor_avrg;
				s_first_sensor_value_in_array <="0000"& S_SENSOR_AVRG_ARRAY(15);
				if i/=0 then				
					i<=i-1;
				end if;
				clk_cnt<=clk_cnt+1;
			elsif clk_cnt=16 then   ---calculate the moving averge each time the sample signal is high when the ARRAY is full with 16 data values
				s_mov_avg_Ready<='1';
				s_sensor_in <= "0000"& sensor_avrg;
				s_first_sensor_value_in_array <="0000"& S_SENSOR_AVRG_ARRAY(15);
				S_SENSOR_AVRG_ARRAY<= S_SENSOR_AVRG_ARRAY(14 downto 0) & sensor_avrg;
				S_Sensor_SUM<=S_Sensor_SUM + s_sensor_in - s_first_sensor_value_in_array;
			end if;
		END IF;
			
		IF s_mov_avg_Ready ='1' THEN
		--	S_Sensor_Moving_AVG<=S_Sensor_SUM(19 downto 4);
			S_Sensors_Moving_SUM<=S_Sensor_SUM(15 downto 0);
			s_mov_avg_Ready<='0';
		END IF;
	END IF;
				 		
		Mov_avg_Ready <= s_mov_avg_Ready;
		Sensors_Moving_SUM	<= S_Sensors_Moving_SUM;
		
		
-----------------------------------------------------------------------------------------
  
  END PROCESS;
	
--------------------------------------------------------------------------------------------------------------------------------
END ARCHITECTURE BEHAVE;
--------------------------------------------------------------------------------------------------------------------------------

