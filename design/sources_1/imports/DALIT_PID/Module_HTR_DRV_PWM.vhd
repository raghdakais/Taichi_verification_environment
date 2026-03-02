
-----------------------------------------------------------
-----------------------------------------------------------
-- Date : 07/11/2022
-----------------------------------------------------------
-- Designer  : Dalit Cohen
----------------------------------------------------------
-- Block Name:Taichi Module (TMB) - Heater Driver PWM
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


ENTITY Module_HTR_DRV_PWM IS
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

--------------------------------------------------------------------------------------------------------------------------------
END Module_HTR_DRV_PWM;
--------------------------------------------------------------------------------------------------------------------------------
 
--------------------------------------------------------------------------------------------------------------------------------
ARCHITECTURE BEHAVE OF Module_HTR_DRV_PWM IS
--------------------------------------------------------------------------------------------------------------------------------
CONSTANT  period    	: integer := sys_clk/pwm_freq;                  --number of clocks in one pwm period
CONSTANT  full_scale    : integer := 2**bits_resolution;				---in our case X"FF"  = 255 decimal ->256 stapes
CONSTANT  pwm_bit_length    : integer := period/full_scale;				---pwm_bit_length -- width of each stap of the 256 stapes (256 staps in full scale)

SIGNAL  SCALE_CNT       : integer RANGE 0 TO 2**bits_resolution-1 :=0;             -- period counter
SIGNAL  CLK_CNT  		: integer RANGE 0 TO period/full_scale := 0;           
SIGNAL  end_of_period   : STD_LOGIC:='0';  
SIGNAL  EN_pwm_freq   	: STD_LOGIC:='0';    
SIGNAL  duty_conv    	: integer RANGE 0 TO 2**bits_resolution-1:=0;  
SIGNAL  duty_conv_new    : integer RANGE 0 TO 2**bits_resolution:=0;  
              
--------------------------------------------------------------------------------------------------------------------------------
BEGIN
--------------------------------------------------------------------------------------------------------------------------------
PROCESS(clk, reset_n)
  BEGIN
    
	IF(reset_n = '0') THEN                                                 			
      SCALE_CNT <= 0;   
	  CLK_CNT <= 0;
      EN_pwm_freq <= '0'; 
	  pwm_out <= '0';                                            						
      pwm_n_out <= '0';                                          						
	  end_of_period <= '0';
	  duty_conv <=0;
	  duty_conv_new <=0;
	ELSIF(clk'EVENT AND clk = '1') THEN                                      	
		
		duty_conv<= conv_integer(Duty_Cycle_In);   
		   	
		IF (CLK_CNT = (pwm_bit_length)) THEN  	--create interior  Enable  acording to pwm_freq ------
			CLK_CNT <= 0;
			EN_pwm_freq<='1';					----256 EN in one period
		ELSE
			CLK_CNT <= CLK_CNT +1;
			EN_pwm_freq<='0';
		END IF; 
		
		
		IF EN_pwm_freq ='1' then			--- latch the duty_conv_new for 256 clk (one period) and add the input each period
			IF SCALE_CNT=full_scale-1 then
				SCALE_CNT<=0;
				duty_conv_new<=duty_conv;
				end_of_period <='1';
			Else 
				SCALE_CNT<=SCALE_CNT+1;
				end_of_period <='0';
			END IF;
		END IF;		
		
		IF (SCALE_CNT < duty_conv_new+1 and duty_conv_new/=0) then ---create the PWM signl 
			pwm_out <= '1';                                                    	  
			pwm_n_out <= '0';
		ELSE
			pwm_out <= '0';                                                    	  
			pwm_n_out <= '1';  
		END IF;
			   
	END IF; 
  END PROCESS;
	
--------------------------------------------------------------------------------------------------------------------------------
END ARCHITECTURE BEHAVE;
--------------------------------------------------------------------------------------------------------------------------------

