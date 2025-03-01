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
        int byte_number = 0;

    forever
     begin
          @(negedge vif.clk);
        // Wait for 1 byte (8 bits) in Big Endian order
         byte_collected = 0;
         while(  vif.active_package)
         begin        
             for (int i = 7; i >= 0; i--) begin  // Collect MSB first
                 byte_collected[i] = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
                  @(negedge vif.clk);
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
        for (int i = 7; i >= 0; i--) begin
            temp_byte[i] = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
            @(negedge vif.clk);
        end
        item.start2 = temp_byte;

        // Collect Header
        for (int i = item.header.size()-1; i >= 0; i--) begin    
            for (int j = 7; j >= 0; j--) begin
                item.header[i][j]  = (stream_type == "TX") ? vif.tx : vif.rx;  // Correct signal reference
                @(negedge vif.clk);
            end
        end
            if (item.header[0][0] == 1 &&   item.header[0][1] == 0)
              item.command = "[READ]";
            else if (item.header[0][0] == 0 &&   item.header[0][1] == 1)
              item.command = "[WRITE]";
            else 
              item.command = "[INVALID READ/WRITE COMMAND]";
        // Collect Data
        for (int i = item.data.size()-1; i >= 0; i--) begin    
             for (int j = 7; j >= 0; j--) begin
                item.data[i][j] = (stream_type == "TX") ? vif.tx : vif.rx; 
                @(negedge vif.clk);
            end
        end

        // Collect Footer
           for (int i = item.footer.size()-1; i >= 0; i--) begin
            for (int j = 7; j >= 0; j--) begin
                item.footer[i][j] = (stream_type == "TX") ? vif.tx : vif.rx; 
                @(negedge vif.clk);
            end
        end

        // Collect CRC (2 bytes, 16 bits total)
        for (int j = 15; j >= 0; j--) begin
            item.crc[j] = (stream_type == "TX") ? vif.tx : vif.rx; 
            @(negedge vif.clk);
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
    // if there was a write operation, copy the random address to the footer, we copy it byte by byte
 //   else if(item.op_type == "READ")
////    begin
////        item.rd_data[7:0]    = item.data[0] ; // First 8 bits of address
////        item.rd_data[15:8]   = item.data[1] ; // Next 8 bits of address
////        item.rd_data[23:16]  = item.data[2] ; // Last 8 bits of address
////        item.rd_data[31:24]  = item.data[3] ; // Last 8 bits of address
////    end
////





        // printing item fields only in UVM_DEBUG Mode
         if (get_report_verbosity_level() >= UVM_DEBUG)
        begin
            $display("[%s] Monitor Printing %s Item: ",stream_type,this.get_type_name());
            item.print();
        end




    endtask
endclass
