//------------------------------------------------------------
class TXRX_monitor extends uvm_monitor;
    //------------------------------------------------------------
    virtual TXRX_agent_if vif;
    uvm_analysis_port#(TXRX_seq_item) tx_analysis_port;
    uvm_analysis_port#(TXRX_seq_item) rx_analysis_port;
    `uvm_component_utils(TXRX_monitor)

    TXRX_config cfg;  // Configuration object
    TXRX_seq_item item;
     
    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
        tx_analysis_port = new("tx_analysis_port", this);
        rx_analysis_port = new("rx_analysis_port", this);
    endfunction

    //------------------------------------------------------------
     function void build_phase(uvm_phase phase);
    //------------------------------------------------------------
        super.build_phase(phase);
    endfunction

    //------------------------------------------------------------
     task run_phase(uvm_phase phase);
    //------------------------------------------------------------
    super.run_phase(phase);

        @(negedge vif.rst);
        fork
            collect_stream(tx_analysis_port, "TX");
            collect_stream(rx_analysis_port, "RX");
        join_none
    endtask

    //------------------------------------------------------------
    // Generic function to collect stream data (tx or rx) in Big Endian order
    //------------------------------------------------------------
    task collect_stream(uvm_analysis_port#(TXRX_seq_item) analysis_port, string stream_type);
        bit [7:0] byte_collected;
        fork
           sync_serial( stream_type );
        join
  
    forever
     begin
//         @(negedge vif.clk);
         byte_collected = 0;
  //         while (vif.active_package)  
         begin  
            for (int i = 0 ; i <=7 ; i++) begin
                  @(negedge vif.clk);
                byte_collected[i] = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
             end
             // Check if the collected byte is IDLE and not zero
             if (byte_collected != IDLE) begin
             `uvm_info(get_type_name(),  $sformatf("[STEAM TYPE = %s] -  [Collected byte that is not IDLE is %x]:",stream_type,byte_collected), UVM_DEBUG)
                 // Create a new sequence item for this packet (Avoids overwriting)
                item = TXRX_seq_item::type_id::create($sformatf("%s_item created", stream_type));       
                 item.valid_start1 = vif.valid_start1;
                 item.valid_start2 = vif.valid_start2;
                 item.valid_crc    = vif.valid_crc;
                 item.start1       = byte_collected;
                 collect_packet(stream_type, item);
                 analysis_port.write(item);
             end
        end
    end
    endtask

    //------------------------------------------------------------
    // Function to collect the rest of the packet in Big Endian order
    //------------------------------------------------------------
    task collect_packet(string stream_type ,TXRX_seq_item item);
        bit [7:0] temp_byte;

        // Collect Start2 (43)
        for (int i = 0 ; i <=7 ; i++) begin
            @(negedge vif.clk);
            temp_byte[i] = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
        end
        item.start2 = temp_byte;

        // Collect Header
      for (int i = item.header.size()-1; i >= 0; i--) begin    
           for (int j = 0 ; j <=7 ; j++) begin
                @(negedge vif.clk);
                item.header[i][j]  = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
            end
        end
            if (item.header[0][0] == 1 &&   item.header[0][1] == 0  && (stream_type == "TX"))
              item.command = "[READ]";
            else if (item.header[0][0] == 0 &&   item.header[0][1] == 1 && (stream_type == "TX"))
              item.command = "[WRITE]";
            else if(stream_type == "TX")
              item.command = "[INVALID READ/WRITE COMMAND]";
            else if ((stream_type == "RX")) 
              item.command = "[READ_BACK_ACK]";
        // Collect Data
     for (int i = item.data.size()-1; i >= 0; i--) begin    
      for (int j = 0 ; j <=7 ; j++) begin
                @(negedge vif.clk);
             item.data[i][j] = (stream_type == "TX") ? vif.tx : vif.rx; 
            end
        end
           if (item.command == "[READ_BACK_ACK]")
           begin
             item.rd_data[31:24] = item.data[3];
             item.rd_data[23:16] = item.data[2];
             item.rd_data[15:8 ] = item.data[1];
             item.rd_data[7 :0 ] = item.data[0];
           end
  
  
        // Collect Footer
      for (int i = item.footer.size()-1; i >= 0; i--) begin
            for (int j = 0 ; j <=7 ; j++) begin
                @(negedge vif.clk);
                item.footer[i][j] = (stream_type == "TX") ? vif.tx : vif.rx; 
            end
        end

        // Collect CRC (2 bytes, 16 bits total)
     for (int j = 0 ; j <=15 ; j++) begin
            @(negedge vif.clk);
             item.crc[j] = (stream_type == "TX") ? vif.tx : vif.rx; 
        end
    // copy the address to the footer, we copy it byte by byte
    item.address[7:0]   =  item.footer[0] ; // First 8 bits of address
    item.address[15:8]  =  item.footer[1] ; // Next 8 bits of address
    item.address[23:16] =  item.footer[2] ; // Last 8 bits of address

    // if there was a write operation, copy the random address to the footer, we copy it byte by byte
   if(item.command == "WRITE")
    begin
        item.wr_data[7:0]    = item.data[0] ; // First 8 bits of address
        item.wr_data[15:8]   = item.data[1] ; // Next 8 bits of address
        item.wr_data[23:16]  = item.data[2] ; // Last 8 bits of address
        item.wr_data[31:24]  = item.data[3] ; // Last 8 bits of address
    end
        // printing item fields only in UVM_DEBUG Mode
         if (get_report_verbosity_level() >= UVM_DEBUG)
        begin
            $display("[%s] Monitor Printing %s Item: ",stream_type,this.get_type_name());
            item.print();
        end




    endtask



  // Task to sync serial data and find the sync word 0xB5
 //-----------------------------------------------------------------------------
  task sync_serial(string stream_type);
 //-----------------------------------------------------------------------------
    logic [7:0] shift_reg = 8'h00; // Shift register to capture incoming bits
    bit serial_in;
    bit sync; 
    sync  = (stream_type == "TX") ? vif.tx_sync_signal : vif.rx_sync_signal;  // Correct signal reference
while (!sync)
   begin
    @(negedge vif.clk); // Wait for a clock edge
     serial_in  = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
     shift_reg = {serial_in, shift_reg[7:1]}; // Shift bits from LSB to MSB
     if (shift_reg == 8'hB5) begin // Check for sync word
        if (stream_type == "TX"  )
          vif.tx_sync_signal = 1'b1; // Toggle sync signal
        else if (stream_type == "RX") 
          vif.rx_sync_signal = 1'b1; // Toggle sync signal
        sync  = (stream_type == "TX") ? vif.tx_sync_signal : vif.rx_sync_signal;  // Correct signal reference
        $display("Sync %s word 0xB5 detected at time %0t",stream_type,  $time);
        end
    end
  endtask

     

endclass
