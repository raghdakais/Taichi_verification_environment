`ifndef BUFFER_TX_MONITOR_SV
`define BUFFER_TX_MONITOR_SV
//----------------------------------------------------------------
class buffer_tx_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(buffer_tx_monitor)

    virtual buffer_tx_agent_if vif;
    buffer_tx_config cfg;            // Configuration object
    buffer_tx_seq_item item;
    uvm_analysis_port #(buffer_tx_seq_item) analysis_port;
        bit [7:0] byte_collected;

    function new(string name="m_buffer_tx_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("buffer_tx_analysis_port", this);
    endfunction


    task run_phase(uvm_phase phase);


        buffer_tx_seq_item item;

        byte payload[$];
        byte start1, start2;
    buffer_state_e state = WAIT_BUFFER;

        // Local buffer detection
        logic [7:0] shift_reg = 0;
        fork
          sync_serial();
        join

        forever begin
          //  @(negedge vif.clk);

            // Collect raw byte
            collect_byte();

            case (state)

                // ----------------------------------------------------
                WAIT_BUFFER: begin
                // ----------------------------------------------------
                  begin
                   ///   shift_reg = {vif.tx, shift_reg[7:1]};
                    if ( byte_collected == 8'hB5) begin
                        state = WAIT_START1;
                        payload.delete();
                        `uvm_info("MON","buffer 0xB5 detected",UVM_LOW)
                        vif.state = state;
                    end
                end
                end
                // ----------------------------------------------------
                WAIT_START1:
                // ----------------------------------------------------
                 begin
                       if (byte_collected == 8'h21) begin
                        start1 = byte_collected;
                        state  = WAIT_START2;
                    end
                        vif.state = state;
                 end
                // ----------------------------------------------------
                WAIT_START2:
                // ----------------------------------------------------
                 begin
                    if (byte_collected == 8'h43) begin
                        start2 = byte_collected;
                        item = buffer_tx_seq_item::type_id::create("item", this);
                        item.start1 = start1;
                        item.start2 = byte_collected;
                        payload.delete();
                        state = COLLECT_PAYLOAD;
                    end
                        vif.state = state;
                 end
                // ----------------------------------------------------
                COLLECT_PAYLOAD:
                // ----------------------------------------------------
                begin
                        vif.state = state;
                        payload.push_back(byte_collected);

                    if (is_packet_complete(start2, payload)) begin

                      if (start2 == 8'h43) begin
                            // HEADER packet:
                            //    BA 5E + 128 data + 12 footer = 142 bytes
                           $display("  SIZE HEADER %d  ",payload.size()  );
                            if (payload.size()  != 15)
                             `uvm_error(get_type_name(), "INVALID HEADER PLAYLOAD SIZE!! " );
                      end
                        fill_item(item,  payload);

                        analysis_port.write(item);

                        `uvm_info("MON","Packet completed and sent",UVM_LOW)

         if (get_report_verbosity_level() >= UVM_DEBUG)
         begin
           $display("[buffer TXRX] Monitor Printing %s Item: ", this.get_type_name());
           item.print();
         end   
                        state = WAIT_START1; // Ready for next packet
                        payload.delete();
                    end
                end
            endcase
        end


   endtask
 // -------------------------------
    // Helper: Move collected bytes into item
    // -------------------------------
    function void fill_item(
        ref buffer_tx_seq_item item,
        ref byte payload[$]
    );

            // HEADER PACKET
            item.pkt_type = BUFFER;

            // BA 5E already checked
            item.header = {payload[0], payload[1]};

            // DATA (128 bytes)
            for (int i=0; i<8; i++)
                item.data[i] = payload[i+2];

            // FOOTER (12 bytes)
            item.footer = new[2];
            for (int i=0; i<2; i++)
                item.footer[i] = payload[10 + i];
     
item.buf_ptr_address_sig[7:0]   = item.data[0];
item.buf_ptr_address_sig[15:8]  = item.data[1];
item.buf_ptr_address_sig[23:16] = item.data[2];
item.buf_ptr_address_sig[31:24] = item.data[3];
item.uid_reg[7:0]               = item.data[4];
item.uid_reg[15:8]               = item.data[5];
           

    endfunction
    
       // -------------------------------
    // Helper: Collect 8 bits into byte
    // -------------------------------
    task  collect_byte();
        for (int i = 0 ; i <=7 ; i++) begin
           
            byte_collected[i] = vif.tx;
                 @(negedge vif.clk);
        end
         vif.byte_collected = byte_collected;
    endtask

  // -------------------------------
    // Helper: Detect end of packet
    // -------------------------------
    function bit is_packet_complete(byte start2, ref byte payload[$]);

        if (start2 == 8'h43) begin
            return (payload.size() == 15);
        end

        return 0;
    endfunction
    
  // Task to sync serial data and find the sync word 0xB5
 //-----------------------------------------------------------------------------
  task sync_serial();
 //-----------------------------------------------------------------------------
    logic [7:0] shift_reg = 8'h00; // Shift register to capture incoming bits
    bit sync; 
while (!sync)
   begin
    @(negedge vif.clk); // Wait for a clock edge
     shift_reg = {vif.tx[0], shift_reg[7:1]}; // Shift bits from LSB to MSB
     if (shift_reg == 8'hB5) begin // Check for sync word
        sync  =1;  // Correct signal reference
        $display("[SYNC BUFFER_TX monitor] Sync word 0xB5 detected at time %0t",  $time);
        end
    end
  endtask



endclass: buffer_tx_monitor
`endif
