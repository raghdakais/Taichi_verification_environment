// UVM testbench for taichi_tmb environment
  `timescale 1ns/1ps
  
  import taichi_tmb_tests_package::*; // Import tests package
 module taichi_tmb_tb;
   import uvm_pkg::*;
   // Complex testbenches will have multiple clocks and hence multiple clock
   // generator modules that will be instantiated elsewhere
   // For simple designs, it can be put into testbench top
   bit clk;
   bit mclk;
   bit reset;
   always #750.75ns clk <= ~clk;
    always #2.5ns mclk <= ~mclk;

  ///always #1ns clk <= ~clk;
  ///  always #0.125ns mclk <= ~mclk;


initial begin
  reset = 1;
  #100ns;
  reset = 0;
end

   // Instantiate the Interface and pass it to Design
   taichi_tmb_agent_if           taichi_tmb_vif  (.clk(mclk));
   TXRX_agent_if                 diag_txrx_vif(.clk(mclk),.rst(reset)); 
   TXRX_agent_if                 oper_txrx_vif(.clk(mclk),.rst(reset)); 
   controllers_agent_if          controllers_vif(.clk(mclk),.rst(reset)); 
  
   Taichi_TMB_top DUT  (
   //-------------------------------------------------------
    // Clocks and reset
   //-------------------------------------------------------
    .MCLK   ( {7{~mclk}} ),
    .MCLK_N ( {7{mclk}}),   
    .ACLK_MASTER   ( clk ),
    .ACLK_MASTER_N ( ~clk),
    .RESET         (reset               ),
   //-------------------------------------------------------
    // Diagnostic TXRX
   //-------------------------------------------------------
    .Diag_out_P           (diag_txrx_vif.rx ),  
    .Diag_out_N           (diag_txrx_vif.rx_n),  
    .Diag_in_P            (diag_txrx_vif.tx ),  
    .Diag_in_N            (~diag_txrx_vif.tx),
   //-------------------------------------------------------
    // Operational TXRX
   //-------------------------------------------------------
    .Reg_out_P           (oper_txrx_vif.rx ),  
    .Reg_out_N           (oper_txrx_vif.rx_n),  
    .Reg_in_P            (oper_txrx_vif.tx ),  
    .Reg_in_N            (~oper_txrx_vif.tx), 
   //-------------------------------------------------------
   // Controllers
   //-------------------------------------------------------
     .Sig_2         (controllers_vif.Sig_2             ),   
     .Master_Slave  (controllers_vif.Master_Slave      ), // constant, for Taichi it is Master  == 0
     .HW_REV        (controllers_vif.HW_REV            ),
     .PGOOD_0_75V   (controllers_vif.PGOOD_0_75V       ),
     .PGOOD_1_0V    (controllers_vif.PGOOD_1_0V        ),
     .PGOOD_1_5V    (controllers_vif.PGOOD_1_5V        ),
     .PGOOD_1_8V    (controllers_vif.PGOOD_1_8V        ),
     .PGOOD_P1_5V   (controllers_vif.PGOOD_P1_5V       ),
     .PGOOD_2_5V    (controllers_vif.PGOOD_2_5V        ),
     // outputs
     .DEBUG_TP      (controllers_vif.DEBUG_TP          ),
     .STATUS_LEDS   (controllers_vif.STATUS_LEDS       ),
     .DISABLE_CLK0n (controllers_vif.DISABLE_CLK0n     ),
     .DISABLE_CLK1n (controllers_vif.DISABLE_CLK1n     ),
     .DISABLE_SLAVEn(controllers_vif.DISABLE_SLAVEn    ),
     .DISABLE_APOSn (controllers_vif.DISABLE_APOSn     ),
     .DISABLE_ANEGn (controllers_vif.DISABLE_ANEGn     ),
     .HEATER_1      (controllers_vif.HEATER_1          ),
     .HEATER_2      (controllers_vif.HEATER_2          )
   
   
            );


   // At start of simulation, set the interface handle as a config object in UVM
   // database. This IF handle can be retrieved in the test using the get() method
   // run_test () accepts the test name as argument. In this case, base_test will
   // be run for simulation
   initial begin
      uvm_config_db #(virtual taichi_tmb_agent_if)::set (null, "", "vif", taichi_tmb_vif);
      uvm_config_db #(virtual TXRX_agent_if)::set (null, "", "diag_txrx_agent_vif", diag_txrx_vif);
      uvm_config_db #(virtual TXRX_agent_if)::set (null, "", "oper_txrx_agent_vif", oper_txrx_vif);
      uvm_config_db #(virtual controllers_agent_if)::set (null, "", "vif", controllers_vif);
      run_test ();
   end
endmodule

