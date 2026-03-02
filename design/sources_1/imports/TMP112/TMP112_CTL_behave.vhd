
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.all;

ENTITY TMP112_CTL IS
   PORT( 
      RESET         : IN     std_logic;
	  reset_64M     : IN     std_logic;
      clk           : IN     std_logic;
	  clk_64M       : IN     std_logic;
      Sda           : INOUT  std_logic;
      Scl           : INOUT  std_logic;    
      data2read_out_Sensor_1 : Buffer    std_logic_vector (15 DOWNTO 0); -- 08/03/2023
      data2read_out_Sensor_2 : Buffer    std_logic_vector (15 DOWNTO 0)  -- 08/03/2023
   );

-- Declarations

END TMP112_CTL ;

--
ARCHITECTURE behave OF TMP112_CTL IS

component SMBUS_IF_tmp IS
   PORT(       
      address       : IN     std_logic_vector (7 DOWNTO 0);
      clk           : IN     std_logic;
      data2write    : IN     std_logic_vector (15 DOWNTO 0);
      ena           : IN     std_logic;
      RESET         : IN     std_logic;
      rw            : IN     std_logic;  
      Sda           : INOUT  std_logic;
      Scl           : INOUT std_logic;
      data2read_out : OUT    std_logic_vector (15 DOWNTO 0);
      busy          : OUT    std_logic;
      read_valid    : OUT    std_logic;
      Sensor_1      : IN     std_logic; -- 08/03/2023
      next_sensor   : OUT    std_logic; -- 08/03/2023
      scl_aux_rise  : OUT    std_logic -- 08/03/2023
   );

END component ;

component ini_SM_TMP IS
   PORT( 
      RESET         : IN    std_logic;
      clk           : IN    std_logic;    
      data2write    : OUT   std_logic_vector (15 DOWNTO 0);
      ena           : buffer   std_logic;
      rw            : OUT   std_logic;
      address       : OUT   std_logic_vector (7 DOWNTO 0);
      busy          : IN    std_logic;
      ini_sm_done   : OUT   std_logic   -- 08/03/2023
   );

-- Declarations

END component ;

component data_sync2 IS
   PORT( 
      CLK_A   : IN     std_logic;
      CLK_B   : IN     STD_LOGIC;
      D_in    : IN     std_logic_vector (15 DOWNTO 0);
      RESET_a : IN     std_logic;
      RESET_b : IN     std_logic;
      ena_sel : IN     std_logic;
      D_out   : BUFFER std_logic_vector (15 DOWNTO 0)
   );

-- Declarations

END component ;




signal address      :  std_logic_vector (7 DOWNTO 0);
signal data2write   :  std_logic_vector (15 DOWNTO 0);
signal ena          :  std_logic;
signal rw           :  std_logic;  
signal busy         :  std_logic;
signal data2read    :  std_logic_vector (15 DOWNTO 0);
signal read_valid   :  std_logic;


-- 08/03/2023 Eugene Shinderman
type SENSORS_SEL_FSM_TYP is (RESET_ST, INIT1_ST, INIT2_ST, WAIT4INIT_ST, IDLE_RD_ST, RD_SENSOR1_ST, RD_SENSOR2_ST);
signal sensors_sel_ps : SENSORS_SEL_FSM_TYP;
signal Sensor_1, init_sm_reset :  std_logic;
signal ini_sm_done, scl_aux_rise :  std_logic;
signal next_sensor, next_sensor_r :  std_logic;
signal data2read_out : std_logic_vector (15 DOWNTO 0); -- 08/03/2023


begin

label_ini_SM_TMP: ini_SM_TMP port map (RESET      => init_sm_reset, -- !debug: 08/03/2023  was  RESET,     
                                       clk        => clk,       
                                       data2write => data2write,
                                       ena        => ena,       
                                       rw         => rw,       
                                       address    => address,   
                                       busy       => busy,
                                       ini_sm_done => ini_sm_done -- 08/03/2023
                                       );
                                       
-----------------------------------------------------------------------------------------------                                       
                                       
label_SMBUS_IF_tmp : SMBUS_IF_tmp port map ( address       => address,                                      
                                clk           => clk,          
                                data2write    => data2write,   
                                ena           => ena,          
                                RESET         => RESET,        
                                rw            => rw,          
                                Sda           => Sda,          
                                Scl           => Scl,      
                                data2read_out => data2read,                                
                                busy          => busy,
                                read_valid    => read_valid,
                                Sensor_1      => Sensor_1, -- 08/03/2023
                                next_sensor => next_sensor, -- 08/03/2023
                                scl_aux_rise  => scl_aux_rise -- 08/03/2023
                               );
								
								
data_sync_inst : data_sync2 port map (
   
      CLK_A   => clk              ,
      CLK_B   => clk_64M          ,
      D_in    => data2read        ,
      RESET_a => RESET            ,
      RESET_b => reset_64M        ,
      ena_sel => read_valid       ,
      D_out   => data2read_out                 
   );                             


-- 08/03/2023 Eugene Shinderman
sensors_1_2_sel_pr: process (clk, reset) is
begin  -- process sensors_1_2_sel_pr
  if (reset = '0') then                 -- asynchronous reset (active low)
    sensors_sel_ps <= RESET_ST;
    Sensor_1 <= '0';
    init_sm_reset <= '0';
    -- init_done_r <= '0';
    next_sensor_r <= '0';
  elsif (clk'event and clk = '1') then  -- rising clock edge

    if (sensors_sel_ps = INIT1_ST or sensors_sel_ps = INIT2_ST) then
      init_sm_reset <= '0';
    else
      init_sm_reset <= '1';
    end if;


    -- init_done_r <= init_done;
    
    case sensors_sel_ps is

      when RESET_ST =>
        sensors_sel_ps <= INIT1_ST;
        Sensor_1 <= '1';
        
      when INIT1_ST => 
        sensors_sel_ps <= WAIT4INIT_ST;

      when WAIT4INIT_ST =>
        if (ini_sm_done = '1' and scl_aux_rise = '1') then
          if (Sensor_1 = '1') then
            sensors_sel_ps <= INIT2_ST;
            Sensor_1 <= '0';    
          else
            sensors_sel_ps <= IDLE_RD_ST;
          end if;
        end if;
        
      when INIT2_ST => 
        sensors_sel_ps <= WAIT4INIT_ST;

      when IDLE_RD_ST =>
        sensors_sel_ps <= RD_SENSOR1_ST;
        Sensor_1 <= '1';
        
      when RD_SENSOR1_ST =>
        if (next_sensor_r = '0' and next_sensor = '1') then
          sensors_sel_ps <= RD_SENSOR2_ST;
          Sensor_1 <= '0';    
        end if;

      when RD_SENSOR2_ST =>
        if (next_sensor_r = '0' and next_sensor = '1') then
          sensors_sel_ps <= RD_SENSOR1_ST;
          Sensor_1 <= '1';
        end if;
        
    end case;

    next_sensor_r <= next_sensor;

    if (read_valid = '1') then
      if (Sensor_1 = '1') then
        data2read_out_Sensor_1 <= data2read_out;
      else
        data2read_out_Sensor_2 <= data2read_out;
      end if;
    end if;

  end if;
end process sensors_1_2_sel_pr;
							

end behave;                                         
