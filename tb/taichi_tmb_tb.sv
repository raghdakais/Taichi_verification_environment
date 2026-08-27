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


// DDR3 interface stub signals
tri [7:0] ddr3_dq;             // inout bus — use 'tri' to allow multiple drivers
tri ddr3_dqs_n;                // inout
tri ddr3_dqs_p;                // inout


bit [15:0] ddr3_addr   ;
bit [2:0] ddr3_ba     ;
bit ddr3_ras_n  ;
bit ddr3_cas_n  ;
bit ddr3_we_n   ;
bit ddr3_reset_n;
bit ddr3_ck_p   ;
bit ddr3_ck_n   ;
bit ddr3_cke    ;
bit ddr3_cs_n   ;
wire ddr3_dm     ;
bit ddr3_odt    ;



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
  #250us;
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
   data_out_agent_if           data_out_tx_vif(.clk(txrx_clk),.rst(sig_2_rst)); 
  
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
    // BUFFER TXRX
   //-------------------------------------------------------
    .Buffer_P            (buffer_tx_vif.tx ),  
    .Buffer_N            (~buffer_tx_vif.tx),   
   //-------------------------------------------------------
    // DATAOUT TXRX
   //-------------------------------------------------------
    .DATA_OUT            (data_out_tx_vif.rx ),  
    .DATA_OUT_N            (),   
 
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
    // DDR PORTS
   //-------------------------------------------------------
    .Aux_Reg_in_P     ( 1'h0 ) ,  
    .Aux_Reg_in_N     ( 1'h0 ) , 
    .AUX_DATA_IN      ( 2'h0 ) , 
    .AUX_DATA_IN_N    ( 2'h0 ) , 
    .Aux_Diag_in_P    ( 1'h0 ) ,  
    .Aux_Diag_in_N    ( 1'h0 ) ,  
    //-------------------------------------------------------
    // DDR PORTS
   //-------------------------------------------------------  
   .SO_FLASH (1'h0), 
  .ddr3_dq      (ddr3_dq         ),  // High-Z
  .ddr3_dqs_n   (ddr3_dqs_n      ),
  .ddr3_dqs_p   (ddr3_dqs_p      ),
  .ddr3_addr         ( ddr3_addr        ),   ///           : out   std_logic_vector(15 downto 0);
  .ddr3_ba           ( ddr3_ba          ),   ///           : out   std_logic_vector(2 downto 0);
  .ddr3_ras_n        ( ddr3_ras_n       ),   ///           : out   std_logic;
  .ddr3_cas_n        ( ddr3_cas_n       ),   ///           : out   std_logic;
  .ddr3_we_n         ( ddr3_we_n        ),   ///           : out   std_logic;
  .ddr3_reset_n      ( ddr3_reset_n     ),   ///           : out   std_logic;
  .ddr3_ck_p         ( ddr3_ck_p        ),   ///           : out   std_logic_vector(0 downto 0);
  .ddr3_ck_n         ( ddr3_ck_n        ),   ///           : out   std_logic_vector(0 downto 0);
  .ddr3_cke          ( ddr3_cke         ),   ///           : out   std_logic_vector(0 downto 0);
  .ddr3_cs_n         ( ddr3_cs_n        ),   ///           : out   std_logic_vector(0 downto 0);
  .ddr3_dm           ( ddr3_dm          ),   ///           : out   std_logic_vector(0 downto 0);
  .ddr3_odt          ( ddr3_odt         ),   ///           : out   std_logic_vector(0 downto 0)




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



  ddr3_model DDR3   (

      .rst_n      ( ddr3_reset_n      ),    ////     : in    std_logic;
      .ck         (   ddr3_ck_p    ),    ////     : in    std_logic;
      .ck_n       ( ddr3_ck_n      ),    ////     : in    std_logic;
      .cke        (  ddr3_cke     ),    ////     : in    std_logic;
      .cs_n       (   ddr3_cs_n    ),    ////     : in    std_logic;
      .ras_n      (   ddr3_ras_n    ),    ////     : in    std_logic;
      .cas_n      (   ddr3_cas_n    ),    ////     : in    std_logic;
      .we_n       (    ddr3_we_n   ),    ////     : in    std_logic;
      .dm_tdqs    (   ddr3_dm    ),    ////     : inout std_logic_vector(DM_BITS-1 downto 0);
      .ba         (   ddr3_ba    ),    ////     : in    std_logic_vector(BA_BITS-1 downto 0);
      .addr       (   ddr3_addr    ),    ////     : in    std_logic_vector(ADDR_BITS-1 downto 0);
      .dq         (    ddr3_dq   ),    ////     : inout std_logic_vector(DQ_BITS-1 downto 0);
      .dqs        (  ddr3_dqs_p     ),    ////     : inout std_logic_vector(DQS_BITS-1 downto 0);
      .dqs_n      ( ddr3_dqs_n      ),    ////     : inout std_logic_vector(DQS_BITS-1 downto 0);
      .tdqs_n     (       ),    ////     : out   std_logic_vector(DQS_BITS-1 downto 0);
      .odt        (  ddr3_odt     )    ////     : in    std_logic

  );


 initial begin
    // Time 0 us
    force DUT.Tiles_managment_m.calib_ctl_reg = 16'h0000;

    // At 260 us
    #260us;
    force DUT.Tiles_managment_m.calib_ctl_reg = 16'h8810;

    // At 600 us (340us after previous)
    #340us;
    force DUT.Tiles_managment_m.calib_ctl_reg = 16'h0000;

    // At 780 us (180us after previous)
    #180us;
    force DUT.Tiles_managment_m.calib_ctl_reg = 16'h8004;

    // Optionally release the force if needed
    // #some_time;
    // release DUT.Tiles_managment_m.calib_ctl_reg;
  end




initial begin
  // Set diag_reg to 16'h18 at time 0
  force DUT.diag_reg = 16'h18;
  // Wait until 350us and maintain the same value (simulate freeze)
  #350us;
  force DUT.diag_reg = 16'h18;
  // You can optionally release after some time if needed
  // #100us;
  // release DUT.diag_reg;
end


//////   initial begin
//////     // 0 us
//////     force DUT.tiles_gen[0].AMS_V6Tile_inst.U1_Register_IF.U2_R_W_Bank_Reg.CALIB_MONITOR_CONST = 16'h0000;
//////   
//////     // At 961 us
//////     #961us;
//////     force DUT.tiles_gen[0].AMS_V6Tile_inst.U1_Register_IF.U2_R_W_Bank_Reg.CALIB_MONITOR_CONST = 16'h102D;
//////   
//////     // At 1870 us (909 us after previous)
//////     #909us;
//////     force DUT.tiles_gen[0].AMS_V6Tile_inst.U1_Register_IF.U2_R_W_Bank_Reg.CALIB_MONITOR_CONST = 16'h002D;
//////   
//////     // At 2870 us (1000 us after previous)
//////     #1000us;
//////     force DUT.tiles_gen[0].AMS_V6Tile_inst.U1_Register_IF.U2_R_W_Bank_Reg.CALIB_MONITOR_CONST = 16'h5000;
//////   
//////     // Optional: release later
//////     // #500us;
//////     // release top.tiles_gen[0].AMS_V6Tile_inst.U1_Register_IF.U2_R_W_Bank_Reg.CALIB_MONITOR_CONST;
//////   end
//////   


   // At start of simulation, set the interface handle as a config object in UVM
   // database. This IF handle can be retrieved in the test using the get() method
   // run_test () accepts the test name as argument. In this case, base_test will
   // be run for simulation
   initial begin
      $dumpvars(0, taichi_tmb_tb);
      uvm_config_db #(virtual taichi_tmb_agent_if)::set (null, "", "vif", taichi_tmb_vif);
      uvm_config_db #(virtual TXRX_agent_if)::set (null, "", "diag_txrx_agent_vif", diag_txrx_vif);
      uvm_config_db #(virtual TXRX_agent_if)::set (null, "", "oper_txrx_agent_vif", oper_txrx_vif);
      uvm_config_db #(virtual controllers_agent_if)::set (null, "", "vif", controllers_vif);
      uvm_config_db #(virtual sync_txrx_agent_if)::set (null, "", "sync_txrx_agent_vif", sync_txrx_vif);
      uvm_config_db #(virtual asic_tiles_agent_if)::set (null, "", "asic_tiles_agent_vif", asic_tiles_vif);
      uvm_config_db #(virtual buffer_tx_agent_if)::set (null, "", "vif", buffer_tx_vif);
      uvm_config_db #(virtual data_out_agent_if)::set (null, "", "vif", data_out_tx_vif);
      run_test ();
      
   end



assign sig_2_rst = taichi_tmb_tb.DUT.RX_serial_inst.RESET;
assign diag_txrx_vif.channel_ok = taichi_tmb_tb.DUT.registers_inst_A.RX_series_COMPONENT.channel_RDY; 


////assign ddr3_dq    = 8'bz;  // High-Z
////assign ddr3_dqs_n = 1'bz;
////assign ddr3_dqs_p = 1'bz;


endmodule

