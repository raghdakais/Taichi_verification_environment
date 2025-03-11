// UVM Driver class to transmit packets bit-by-bit on each clock edge
//----------------------------------------------------------------
class TXRX_driver extends uvm_driver#(TXRX_seq_item);
//----------------------------------------------------------------
    virtual TXRX_agent_if vif;

    `uvm_component_utils(TXRX_driver)

   TXRX_config cfg;            // Configuration object


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
     function void build_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.build_phase(phase);
         endfunction

//----------------------------------------------------------------
     task run_phase(uvm_phase phase);
//----------------------------------------------------------------
            // Declare req variable to store the item
        TXRX_seq_item req;

        // Wait for reset to be deasserted
        wait_for_reset();
     forever begin
        // Try to get a sequence item (non-blocking)
            seq_item_port.try_next_item(req);
        if(req==null) begin
            `uvm_info(get_type_name(), "No Request.. driving idle", UVM_DEBUG)
            send_idle();
        end 
        else begin
            `uvm_info(get_type_name(), $sformatf("Driving packet: %s", req.sprint()), UVM_DEBUG)

            // Drive the received packet
            drive_packet(req);
            
            // Notify sequencer that item has been processed
            seq_item_port.item_done();
        end
    end
    endtask

//----------------------------------------------------------------
   // Task to wait for reset to deassert
  task wait_for_reset();
//----------------------------------------------------------------
    bit reset_deasserted = 0;
    `uvm_info(get_type_name(), "Waiting for reset...", UVM_DEBUG)
    
  
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
 // Function to drive packet bit-by-bit over tx in Big Endian order for whole bytes,
// with FIFO indexes driven from max size to 0
task drive_packet(TXRX_seq_item pkt);
    //----------------------------------------------------------------
    bit [15:0] crc_calc = 16'hFFFF; // Initialize CRC with 0xFFFF
    bit [7:0] serial_byte;
  
   vif.active_package = 1;   // for debug

   vif.valid_crc = pkt.valid_crc;
   vif.valid_start1 = pkt.valid_start1;
   vif.valid_start2 = pkt.valid_start2;
 
    // copy the address to the footer, we copy it byte by byte
    pkt.footer[0] = pkt.address[7:0];   // First 8 bits of address
    pkt.footer[1] = pkt.address[15:8];  // Next 8 bits of address
    pkt.footer[2] = pkt.address[23:16]; // Last 8 bits of address
    // if there was a write operation, copy the random address to the footer, we copy it byte by byte
    if(pkt.rw_type == TXRX_WRITE  )
    begin
        pkt.data[0] = pkt.wr_data[7:0];   // First 8 bits of address
        pkt.data[1] = pkt.wr_data[15:8];  // Next 8 bits of address
        pkt.data[2] = pkt.wr_data[23:16]; // Last 8 bits of address
        pkt.data[3] = pkt.wr_data[31:24]; // Last 8 bits of address
    end

    // Send IDLE sequence (5B in binary: 0101 1011)
    `uvm_info(get_type_name(),  $sformatf("[IDLE was randomized [%d] times] :",pkt.times_sent_idle), UVM_DEBUG)      
    repeat(pkt.times_sent_idle)
       send_idle();

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
    
      // Send Header with read/write bits in the first byte (bit 0 and bit 1)
    // Bit 0 active for read, bit 1 active for write
//    for (int i = pkt.header.size()-1; i >= 0; i--) begin
    for (int i = 0 ; i <= pkt.header.size()-1; i++) begin
        // Set the read/write bits in header byte0 (bit 0 for read, bit 1 for write)
        if (i == 0) begin
            // Set the read/write operation based on randomized enum
            if (pkt.rw_type == TXRX_READ) begin
                pkt.header[0][0] = 1;  // Set bit 0 for read
                pkt.header[0][1] = 0;  // Clear bit 1 for write
                if(pkt.do_wr_fail)  begin
                pkt.header[0][0] = 1;  // Set bit 0 for read
                pkt.header[0][1] = 1;  // No clear for write
                end
            end
             else if (pkt.rw_type == TXRX_WRITE) begin
                pkt.header[0][0] = 0;  // Clear bit 0 for read
                pkt.header[0][1] = 1;  // Set bit 1 for write
                  if(pkt.do_wr_fail)  begin
                pkt.header[0][0] = 1;  // No clear for read
                pkt.header[0][1] = 1;  // Set bit 1 for write
                end
            end
        end
        // Transmit header byte in Big Endian order
   for (int j = 0 ; j <=7 ; j++) begin
            @(posedge vif.clk);
            vif.tx <= pkt.header[i][j];
        end
            crc_calc = calculate_crc16_byte(crc_calc, pkt.header[i]); 
    
    end

    // Send Data (iterate from max index down to 0)
   // for (int i = pkt.data.size()-1; i >= 0; i--) begin
     for (int i = 0  ; i<= pkt.data.size()-1 ; i++) begin
     for (int j = 0 ; j <=7 ; j++) begin
            @(posedge vif.clk);
            vif.tx <= pkt.data[i][j];  // Transmit bits from MSB to LSB in Big Endian
        end
     crc_calc = calculate_crc16_byte(crc_calc, pkt.data[i]); 
    
    end

    // Send Footer (iterate from max index down to 0)
 //    for (int i = pkt.footer.size()-1; i >= 0; i--) begin
    for (int i = 0 ; i <= pkt.footer.size()-1  ; i++) begin
        for (int j = 0 ; j <=7 ; j++) begin
            @(posedge vif.clk);
         vif.tx <= pkt.footer[i][j];  // Transmit bits from MSB to LSB in Big Endian
        end
      crc_calc = calculate_crc16_byte(crc_calc, pkt.footer[i]); 

    end

    // Send CRC (iterate from max index down to 0 - 1 variable for 16 bits)
   for (int j = 0 ; j <=15 ; j++) begin
            @(posedge vif.clk);
            vif.tx <= crc_calc[j];  // Transmit bits from MSB to LSB in Big Endian
   //         vif.tx <= pkt.crc[j];  // Transmit bits from MSB to LSB in Big Endian
        end
          vif.active_package = 0;
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


endclass
