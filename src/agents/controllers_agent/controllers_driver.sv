`ifndef CONTROLLERS_DRIVER_SV
`define CONTROLLERS_DRIVER_SV
//----------------------------------------------------------------
class controllers_driver extends uvm_driver #(controllers_seq_item);
//----------------------------------------------------------------
    `uvm_component_utils(controllers_driver)

    virtual controllers_agent_if vif;
   controllers_config cfg;            // Configuration object
controllers_seq_item req;
  

  bit [3:0] HW_REV;
  bit       PGOOD_0_75V; 
  bit       PGOOD_1_0V;
  bit       PGOOD_1_5V;
  bit       PGOOD_1_8V;
  bit       PGOOD_P1_5V;
  bit       PGOOD_2_5V;

  bit [7:0] DEBUG_TP;
  bit [1:0] STATUS_LEDS;
  bit       DISABLE_CLK0n;
  bit       DISABLE_CLK1n;
  bit       DISABLE_SLAVEn;
  bit       DISABLE_APOSn;
  bit       DISABLE_ANEGn;
  bit       HEATER_1;
  bit       HEATER_2;

  // Covergroup declaration
  covergroup signal_toggles;
    coverpoint HW_REV { bins all_vals[] = {[0:15]}; }

    coverpoint PGOOD_0_75V { bins toggle[] = {0,1}; }
    coverpoint PGOOD_1_0V  { bins toggle[] = {0,1}; }
    coverpoint PGOOD_1_5V  { bins toggle[] = {0,1}; }
    coverpoint PGOOD_1_8V  { bins toggle[] = {0,1}; }
    coverpoint PGOOD_P1_5V { bins toggle[] = {0,1}; }
    coverpoint PGOOD_2_5V  { bins toggle[] = {0,1}; }

    coverpoint DEBUG_TP    { bins all_vals[] = {[0:255]}; }
    coverpoint STATUS_LEDS { bins all_vals[] = {[0:3]}; }

    coverpoint DISABLE_CLK0n { bins toggle[] = {0,1}; }
    coverpoint DISABLE_CLK1n { bins toggle[] = {0,1}; }
    coverpoint DISABLE_SLAVEn{ bins toggle[] = {0,1}; }
    coverpoint DISABLE_APOSn { bins toggle[] = {0,1}; }
    coverpoint DISABLE_ANEGn { bins toggle[] = {0,1}; }

    coverpoint HEATER_1 { bins toggle[] = {0,1}; }
    coverpoint HEATER_2 { bins toggle[] = {0,1}; }
  endgroup
  
  
  
  
  
    function new(string name = "m_controllers_driver", uvm_component parent);
        super.new(name, parent);

        signal_toggles = new();
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
     super.run_phase(phase);
        // Wait for reset to be deasserted
        wait_for_reset();
      fork
        begin
        forever begin
          
            seq_item_port.get_next_item(req);
            drive_sig_2( req);    
            // Drive data to the interface
            @(posedge vif.sig2_clk); // Wait for clock edge

vif.HW_REV               =   req.HW_REV                    ;
vif.PGOOD_0_75V          =   req.PGOOD_0_75V               ;
vif.PGOOD_1_0V           =   req.PGOOD_1_0V                ;
vif.PGOOD_1_5V           =   req.PGOOD_1_5V                ;
vif.PGOOD_1_8V           =   req.PGOOD_1_8V                ;
vif.PGOOD_P1_5V          =   req.PGOOD_P1_5V               ;
vif.PGOOD_2_5V           =   req.PGOOD_2_5V                ;


  HW_REV        =      vif.HW_REV;
  PGOOD_0_75V        =      vif.PGOOD_0_75V; 
  PGOOD_1_0V        =      vif.PGOOD_1_0V;
  PGOOD_1_5V        =      vif.PGOOD_1_5V;
  PGOOD_1_8V        =      vif.PGOOD_1_8V;
  PGOOD_P1_5V        =      vif.PGOOD_P1_5V;
  PGOOD_2_5V        =      vif.PGOOD_2_5V;
  DEBUG_TP        =      vif.DEBUG_TP;
  STATUS_LEDS        =      vif.STATUS_LEDS;
  DISABLE_CLK0n        =      vif.DISABLE_CLK0n;
  DISABLE_CLK1n        =      vif.DISABLE_CLK1n;
  DISABLE_SLAVEn        =      vif.DISABLE_SLAVEn;
  DISABLE_APOSn        =      vif.DISABLE_APOSn;
  DISABLE_ANEGn        =      vif.DISABLE_ANEGn;
  HEATER_1        =      vif.HEATER_1;
  HEATER_2        =      vif.HEATER_2;



    signal_toggles.sample();
 






            seq_item_port.item_done(); // Indicate completion of the transaction
        end
       end


      join_none
    endtask

//----------------------------------------------------------------
   // Task to wait for reset to deassert
  task drive_sig_2(controllers_seq_item req);
//----------------------------------------------------------------
      bit start = 1;
      bit [31:0] data;  // 4 data bytes
      bit [7:0]  crc;
 
      data[31:24] = $urandom; // Byte 3
      data[23:16] = $urandom; // Byte 2
      data[15:8]  = $urandom; // Byte 1
  ////     data[31:30] = 'b01; // Byte 3
  ////     data[29:24] = 'h00; // Byte 3
  ////     data[23:16] = 'h00; // Byte 2
  ////     data[15:8]  = 'h00; // Byte 1
      // Generate Byte 0 (Important Control Byte)
      data[7:4]   = (req.sig2_soft_reset==1) ? 4'hC : 0;
      data[3:1]   =  $urandom;
      data[0]     = (req.sig2_ch_rdy==1) ? 1 : 0;
      // Calculate CRC-8 using bit-wise function
      crc = calculate_crc(data);

      `uvm_info("SIG2_DRIVER", $sformatf("Sending Data (Little Endian): %h | CRC: %h", data, crc), UVM_MEDIUM)

      // Transmit all 4 bytes in Little Endian order (Byte 3 → Byte 2 → Byte 1 → Byte 0)
           vif.start_sig2 =1;
          @(posedge vif.clk); // Wait for clock edge
            vif.Sig_2 = start; // Send MSB first within each byte


//        for (int bit_idx = 0; bit_idx <=31; bit_idx++) begin
        for (int bit_idx = 31; bit_idx >=0 ; bit_idx--) begin
          @(posedge vif.sig2_clk); // Wait for clock edge
          vif.Sig_2 = data[bit_idx]; // Send MSB first within each byte
        end
  
      // Transmit CRC Byte (MSB First)
  //    for (int bit_idx = 0; bit_idx <=7; bit_idx++) begin
        for (int bit_idx = 7; bit_idx >=0 ; bit_idx--) begin
        @(posedge vif.sig2_clk); // Wait for clock edge
        vif.Sig_2 = crc[bit_idx];
      end
vif.start_sig2 = 0;
   endtask

 // Compute full CRC-8 for a 4-byte data stream
//----------------------------------------------------------------
  function bit [7:0] calculate_crc(bit [31:0] data);
//----------------------------------------------------------------
    bit [7:0] crc = 8'hFF;
    for (int i = 31; i >= 0; i--) begin
      crc = nextCRC8_D1(data[i], crc); // Apply bit-wise CRC update
    end
    return crc;
  endfunction

//----------------------------------------------------------------
  // Function to compute CRC-8 one bit at a time
  function bit [7:0] nextCRC8_D1(bit d, bit [7:0] c);
//----------------------------------------------------------------
     bit [7:0] crcOut;
    
    crcOut[0] = c[7] ^ d;
    crcOut[1] = c[0] ^ c[7] ^ d;
    crcOut[2] = c[1] ^ c[7] ^ d;
    crcOut[3] = c[2];
    crcOut[4] = c[3];
    crcOut[5] = c[4];
    crcOut[6] = c[5];
    crcOut[7] = c[6];

    return crcOut;
  endfunction


//----------------------------------------------------------------
   // Task to wait for reset to deassert
  task wait_for_reset();
//----------------------------------------------------------------
    bit reset_deasserted = 0;
    `uvm_info(get_type_name(), "Waiting for reset...", UVM_DEBUG)
    
   // Check if vif is assigned before using it
        if (vif == null) begin
            `uvm_fatal(get_type_name(), "Virtual interface (vif) is NULL! Cannot wait for reset.")
        end

        // Check if cfg is assigned before using timeout_cycles
        if (cfg == null) begin
            `uvm_fatal(get_type_name(), "Configuration object (cfg) is NULL! Cannot proceed with timeout check.")
        end
    

    fork
    // Wait for reset deassertion
    begin
    //  wait (vif.rst == 1'b0);
      @(negedge vif.rst);
      reset_deasserted = 1;
      @(posedge vif.clk);
    end

    // Timeout logic
    begin
      repeat (cfg.timeout_cycles)
          @(posedge vif.clk);
      if (!reset_deasserted) begin
        `uvm_fatal(get_type_name(), $sformatf("Timeout waiting for reset deassertion after %0d cycles!", cfg.timeout_cycles))
      end
    end
  join_any 
    disable fork; // Ensure the other process stops execution
  
  fork
    begin
  forever
  begin
  repeat(4)
   @(posedge vif.clk);
   if(reset_deasserted)
    vif.sig2_clk = ~vif.sig2_clk;
  end
    end

  join_none
  
   #10us;
   endtask   
endclass: controllers_driver
`endif