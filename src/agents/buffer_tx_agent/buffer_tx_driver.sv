`ifndef BUFFER_TX_DRIVER_SV
`define BUFFER_TX_DRIVER_SV
//----------------------------------------------------------------
class buffer_tx_driver extends uvm_driver #(buffer_tx_seq_item);
//----------------------------------------------------------------
    `uvm_component_utils(buffer_tx_driver)

    virtual buffer_tx_agent_if vif;
   buffer_tx_config cfg;            // Configuration object

    function new(string name = "m_buffer_tx_driver", uvm_component parent);
        super.new(name, parent);
    endfunction
//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
     super.run_phase(phase);
        // Wait for reset to be deasserted
        wait_for_reset();
      forever begin
        // Try to get a sequence item (non-blocking)
            seq_item_port.try_next_item(req);
        if(req==null) begin
          //  `uvm_info(get_type_name(), "No Request.. driving idle", UVM_DEBUG)
            send_idle();
        end 
        else begin
              drive_packet(req);
            seq_item_port.item_done();
        end
    end
    endtask


//----------------------------------------------------------------
// Function to send IDLE byte (3B) bit-by-bit in Big Endian order
task send_idle();
    //----------------------------------------------------------------
    bit [7:0] idle = IDLE; // IDLE byte value (0x3B = 0011 1011)
    //----------------------------------------------------------------
   
    // Loop over bits from MSB to LSB (Big Endian order)
   for (int i = 0 ; i <=7 ; i++) begin
        @(posedge vif.clk); // Wait for the next clock cycle
        vif.tx <= idle[i]; // Send each bit one-by-one
    end
endtask


//----------------------------------------------------------------
task drive_packet(buffer_tx_seq_item pkt);
//----------------------------------------------------------------
    bit [15:0] crc_calc = 16'hFFFF; // Initialize CRC with 0xFFFF
    bit [7:0] serial_byte;
 /// pkt.pkt_type_ = "[SYNC - HEADER_PACKET]";
  //------------------------------------------------------------ 
  //  IDLE |  START1  | START2  |  Data  |  CRC         |
  //  1byte    1byte     1byte     1byte    2byte 
  //------------------------------------------------------------ 
   // vif.ip_valid_crc = pkt.ip_valid_crc;
   // vif.header_valid_crc = pkt.header_valid_crc;

      // Send Start1 (21)
        for (int i = 0 ; i <=7 ; i++) begin
              @(posedge vif.clk);
               vif.tx <= pkt.start1[i];  // Send the bits of start1 in Big Endian order
          end

          // Process each byte in the packet serially (bit by bit)
          crc_calc = calculate_crc16_byte(crc_calc, pkt.start1); // Start1 (21)

          // Send Start2 (43)
         for (int i = 0 ; i <=7 ; i++) begin
              @(posedge vif.clk);
              vif.tx <= pkt.start2[i];  // Send the bits of start2 in Big Endian order
          end
          crc_calc = calculate_crc16_byte(crc_calc, pkt.start2); // Start2 (43)
        // Transmit header byte in Big Endian order

     for (int i = pkt.header.size()-1; i >= 0; i--) begin
       for (int j = 0 ; j <=7 ; j++) begin
            @(posedge vif.clk);
            vif.tx <= pkt.header[i][j];
           end
            crc_calc = calculate_crc16_byte(crc_calc, pkt.header[i]); 
    end
        // Send 64 random data words 
        // Drive the ff_headers_sig signals based on the item values
        ////TODO  for (int i = pkt.data.size() -1 ; i >= 0  ; i--) begin
         for (int i = 0 ; i <= pkt.data.size() -1  ; i++) begin
               for (int j = 0 ; j <=7 ; j++) begin
                 @(posedge vif.clk);
                 vif.tx <= pkt.data[i][j];  // Send the bits of start2 in Big Endian order
          //       vif.tx <= tmp_data[j];  // Send the bits of start2 in Big Endian order
            end
          crc_calc = calculate_crc16_byte(crc_calc, pkt.data[i]); // Start1 (21)
         end

        // Send 12 random data byte - footer
        // Drive the ff_headers_sig signals based on the item values
     ///       for (int i = pkt.footer.size() - 1 ; i >= 0  ; i--) begin
            for (int i = 0 ; i <= pkt.footer.size() - 1  ; i++) begin
               for (int j = 0 ; j <=7 ; j++) begin
                 @(posedge vif.clk);
                 vif.tx <= pkt.footer[i][j];  // Send the bits of start2 in Big Endian order
          end
                 crc_calc = calculate_crc16_byte(crc_calc, pkt.footer[i]); // Start1 (21)
         end
     
     if(pkt.valid_crc == 0)
     crc_calc = crc_calc+'hAA;
         // Send CRC (iterate from max index down to 0 - 1 variable for 16 bits)
         for (int j = 0 ; j <=15 ; j++) begin
                  @(posedge vif.clk);
                  vif.tx <= crc_calc[j];  // Transmit bits from MSB to LSB in Big Endian
              end
endtask


   // Function to compute next CRC16 value given an 8-bit data and 16-bit current CRC
  static function logic [15:0] calculate_crc16_byte(logic [15:0] crc  ,  logic [7:0] data );
    logic [15:0] new_crc;

    new_crc[15] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ 
                  crc[7] ^ crc[6] ^ crc[5] ^ crc[4] ^ crc[3] ^ crc[2] ^ crc[1] ^ crc[0];
    new_crc[14] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ 
                  crc[6] ^ crc[5] ^ crc[4] ^ crc[3] ^ crc[2] ^ crc[1] ^ crc[0];
    new_crc[13] = data[6] ^ data[7] ^ crc[7] ^ crc[6];
    new_crc[12] = data[5] ^ data[6] ^ crc[6] ^ crc[5];
    new_crc[11] = data[4] ^ data[5] ^ crc[5] ^ crc[4];
    new_crc[10] = data[3] ^ data[4] ^ crc[4] ^ crc[3];
    new_crc[9]  = data[2] ^ data[3] ^ crc[3] ^ crc[2];
    new_crc[8]  = data[1] ^ data[2] ^ crc[2] ^ crc[1];
    new_crc[7]  = data[0] ^ data[1] ^ crc[15] ^ crc[1] ^ crc[0];
    new_crc[6]  = data[0] ^ crc[14] ^ crc[0];
    new_crc[5]  = crc[13];
    new_crc[4]  = crc[12];
    new_crc[3]  = crc[11];
    new_crc[2]  = crc[10];
    new_crc[1]  = crc[9];
    new_crc[0]  = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ 
                  crc[8] ^ crc[7] ^ crc[6] ^ crc[5] ^ crc[4] ^ crc[3] ^ crc[2] ^ crc[1] ^ crc[0];

    return new_crc;
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
   
   endtask




    
endclass: buffer_tx_driver
`endif
