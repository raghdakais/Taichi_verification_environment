`ifndef SYNC_TXRX_MONITOR_SV
`define SYNC_TXRX_MONITOR_SV
//----------------------------------------------------------------
class sync_txrx_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(sync_txrx_monitor)

    virtual sync_txrx_agent_if vif;
    sync_txrx_config cfg;            // Configuration object
    sync_txrx_seq_item item;
    uvm_analysis_port #(sync_txrx_seq_item) analysis_port;
        bit [7:0] byte_collected;





    function new(string name="m_sync_txrx_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("sync_txrx_analysis_port", this);
    endfunction

    // -----------------------------
    // MAIN RUN PHASE
    // -----------------------------
    task run_phase(uvm_phase phase);

        sync_state_e state = WAIT_SYNC;

        sync_txrx_seq_item item;

        byte payload[$];
        byte start1, start2;

        // Local SYNC detection
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
                WAIT_SYNC: begin
                // ----------------------------------------------------
                  begin
                   ///   shift_reg = {vif.tx, shift_reg[7:1]};
                    if ( byte_collected == 8'hB5) begin
                        state = WAIT_START1;
                        payload.delete();
                        `uvm_info("MON","SYNC 0xB5 detected",UVM_LOW)
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
                    if (byte_collected == 8'h1B || byte_collected == 8'h43) begin
                        start2 = byte_collected;
                        item = sync_txrx_seq_item::type_id::create("item", this);
                        item.start1 = start1;
                        item.start2_ip = (byte_collected == 8'h1B);
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

                          if (start2 == 8'h1B) begin
                                    // IP PACKET = 1 data + 2 CRC bytes
                                    if(payload.size() != 3)
                                     `uvm_error(get_type_name(), "INVALID IP PLAYLOAD SIZE!!");
                                end


                      if (start2 == 8'h43) begin
                            // HEADER packet:
                            //    BA 5E + 128 data + 12 footer = 142 bytes
                           $display("  SIZE HEADER %d  ",payload.size()  );
                            if (payload.size()  != 142)
                             `uvm_error(get_type_name(), "INVALID HEADER PLAYLOAD SIZE!! " );
                           $display("   HEADER Sign %h  ",{payload[0],payload[1]}  );
                            if ({payload[0],payload[1]} != 16'hBA5E)
                             `uvm_error(get_type_name(), "INVALID HEADER SIGNATURE!!");
                            // total = 2 + 128 + 12 = 142

                      end
                        fill_item(item, start2, payload);

                        analysis_port.write(item);

                        `uvm_info("MON","Packet completed and sent",UVM_LOW)

         if (get_report_verbosity_level() >= UVM_DEBUG)
         begin
           $display("[SYNC TXRX] Monitor Printing %s Item: ", this.get_type_name());
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

        if (start2 == 8'h1B) begin
            // IP PACKET = 1 data + 2 CRC bytes
//// maybe e no neeed               if(payload.size() != 3)
//// maybe e no neeed                `uvm_error(get_type_name(), "INVALID IP PLAYLOAD SIZE!!");
            
            return (payload.size() == 3);
        end

        if (start2 == 8'h43) begin
            // HEADER packet:
   ///// maybe no need          //    BA 5E + 128 data + 12 footer = 142 bytes
   ///// maybe no need          $display("  SIZE HEADER %d  ",payload.size()  );
   ///// maybe no need          if (payload.size()  != 142)
   ///// maybe no need           `uvm_error(get_type_name(), "INVALID HEADER PLAYLOAD SIZE!!");
   ///// maybe no need          if ({payload[1],payload[0]} != 16'hBA5E)
   ///// maybe no need           `uvm_error(get_type_name(), "INVALID HEADER SIGNATURE!!");
   ///// maybe no need          // total = 2 + 128 + 12 = 142
            return (payload.size() == 142);
        end

        return 0;
    endfunction


    // -------------------------------
    // Helper: Move collected bytes into item
    // -------------------------------
    function void fill_item(
        ref sync_txrx_seq_item item,
        byte start2,
        ref byte payload[$]
    );

        if (start2 == 8'h1B) begin
            // IP PACKET
            item.pkt_type = SYNC_IP;
            item.ip_data = payload[0];
            item.crc     = {payload[2], payload[1]};
        end

        else if (start2 == 8'h43) begin
            // HEADER PACKET
            item.pkt_type = SYNC_HEADER;

            // BA 5E already checked
            item.header_header = {payload[0], payload[1]};

            // DATA (128 bytes)
            for (int i=0; i<128; i++)
                item.header_data[i] = payload[i+2];

            // FOOTER (12 bytes)
            item.footer = new[12];
            for (int i=0; i<12; i++)
                item.footer[i] = payload[130 + i];
     
item.slot_pointer_address[7:0]   = item.footer[0];
item.slot_pointer_address[15:8]  = item.footer[1];
item.slot_pointer_address[23:16] = item.footer[2];
item.slot_pointer_address[31:24] = item.footer[3];
item.hd_pointer_address[7:0]     = item.footer[4];
item.hd_pointer_address[15:8]    = item.footer[5];
item.hd_pointer_address[23:16]   = item.footer[6];
item.hd_pointer_address[31:24]   = item.footer[7];
            
item.merging_factor              = item.footer[8];
item.focal_spot_merging_factor   = item.footer[9];
item.fq_stream_enable            = item.footer[11][0];


vif.slot_pointer_address = item.slot_pointer_address;
        end
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
     shift_reg = {vif.tx, shift_reg[7:1]}; // Shift bits from LSB to MSB
     vif.shift_reg = shift_reg;
     if (shift_reg == 8'hB5) begin // Check for sync word
        sync  =1;  // Correct signal reference
        $display("[SYNC sync_tx monitor] Sync word 0xB5 detected at time %0t",  $time);
        end
    end
  endtask








endclass: sync_txrx_monitor
`endif
