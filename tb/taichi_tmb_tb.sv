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
   bit sig_2_clk;
   bit sig_2_rst;
   reg  txrx_clk = 0;
    always #750.75ns clk <= ~clk;
    always #2.5ns mclk <= ~mclk;
    always #20ns sig_2_clk <= ~sig_2_clk;
 ////   always #1.25ns txrx_clk <= ~txrx_clk;

// Generate the derived clock toggling on both edges of clk
  always @(posedge mclk) begin
    txrx_clk = ~txrx_clk;
    #1.25ns;
     txrx_clk <= ~txrx_clk;
      @(negedge mclk)
       txrx_clk <= ~txrx_clk;
        #1.25ns;
     txrx_clk <= ~txrx_clk;
  end

initial begin
  reset = 1;
  #200ns;
  reset = 0;
end

   // Instantiate the Interface and pass it to Design
   taichi_tmb_agent_if           taichi_tmb_vif  (.clk(mclk));
   TXRX_agent_if                 diag_txrx_vif(.clk(txrx_clk),.rst(sig_2_rst)); 
   TXRX_agent_if                 oper_txrx_vif(.clk(txrx_clk),.rst(sig_2_rst)); 
   controllers_agent_if          controllers_vif(.clk(mclk),.rst(reset)); 
   sync_txrx_agent_if            sync_txrx_vif(.clk(txrx_clk),.rst(sig_2_rst)); 
   asic_tiles_agent_if           asic_tiles_vif(.clk(asic_tiles_vif.TILES_CLK),.rst(sig_2_rst)); 
   buffer_tx_agent_if           buffer_tx_vif(.clk(txrx_clk),.rst(sig_2_rst)); 
  
   Taichi_TMB_top DUT  (
   //-------------------------------------------------------
    // Clocks and reset
   //-------------------------------------------------------
    .MCLK   ( {7{mclk}} ),
    .MCLK_N ( {7{~mclk}}),   
    .ACLK_MASTER   ( clk ),
    .ACLK_MASTER_N ( ~clk),
    .RESET         (reset   ),
    //-------------------------------------------------------
    // Diagnostic TXRX
   //-------------------------------------------------------
    .Diag_out_P           (diag_txrx_vif.rx  ),  
    .Diag_out_N           (diag_txrx_vif.rx_n),  
    .Diag_in_P            (diag_txrx_vif.tx  ),  
    .Diag_in_N            (~diag_txrx_vif.tx ),
   //-------------------------------------------------------
    // Operational TXRX
   //-------------------------------------------------------
    .Reg_out_P           (oper_txrx_vif.rx ),  
    .Reg_out_N           (oper_txrx_vif.rx_n),  
    .Reg_in_P            (oper_txrx_vif.tx ),  
    .Reg_in_N            (~oper_txrx_vif.tx), 
   //-------------------------------------------------------
    // SYNC TXRX
   //-------------------------------------------------------
    .Sync_P            (sync_txrx_vif.tx ),  
    .Sync_N            (~sync_txrx_vif.tx),   
   //-------------------------------------------------------
    // SYNC TXRX
   //-------------------------------------------------------
    .Buffer_P            (buffer_tx_vif.tx ),  
    .Buffer_N            (~buffer_tx_vif.tx),   
   //-------------------------------------------------------
    // ASIC TILES
   //-------------------------------------------------------
    .RESETn             ( asic_tiles_vif.RESETn          ),  
    .ACLK               ( asic_tiles_vif.ACLK            ),  
    .SYNC               ( asic_tiles_vif.SYNC            ),  
    .D_START            ( asic_tiles_vif.D_START         ),   
    .DISCARD            ( asic_tiles_vif.DISCARD         ),  
    .TILES_CLK          ( asic_tiles_vif.TILES_CLK       ),  
    .TILES_CLK_N        ( asic_tiles_vif.TILES_CLK_N     ),  
    .SCLK               ( asic_tiles_vif.SCLK            ),  
    .SCS1               ( asic_tiles_vif.SCS1            ),  
    .SCS2               ( asic_tiles_vif.SCS2            ),  
    .SDI                ( asic_tiles_vif.SDI             ),  
    .SDO                ( asic_tiles_vif.SDO             ),  
    .ACO                ( asic_tiles_vif.ACO             ),  
    .ACO_N              ( asic_tiles_vif.ACO_N           ),  
    .DATA1              ( asic_tiles_vif.DATA1           ),  
    .DATA1_N            ( ~asic_tiles_vif.DATA1         ),  
    .DATA2              ( asic_tiles_vif.DATA2           ),  
    .DATA2_N            ( ~asic_tiles_vif.DATA2         ),  
  
  
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
      uvm_config_db #(virtual sync_txrx_agent_if)::set (null, "", "sync_txrx_agent_vif", sync_txrx_vif);
      uvm_config_db #(virtual asic_tiles_agent_if)::set (null, "", "asic_tiles_agent_vif", asic_tiles_vif);
      uvm_config_db #(virtual buffer_tx_agent_if)::set (null, "", "vif", buffer_tx_vif);
      run_test ();
   end



assign sig_2_rst = taichi_tmb_tb.DUT.RX_serial_inst.RESET;
assign diag_txrx_vif.channel_ok = taichi_tmb_tb.DUT.registers_inst_A.RX_series_COMPONENT.channel_RDY; 


endmodule

