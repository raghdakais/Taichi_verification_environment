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

    function new(string name="m_sync_txrx_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("sync_txrx_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
    bit start_ip_found = 0;
    bit start_header_found = 0;
    int item_id = 0;
    bit ip_start2_found = 0;
    bit header_start2_found = 0;
    byte  buffer[$];
    int ip_package_count = 0;
    int header_package_count = 0;
    int ip_bytes_count = 0;
    int data_bytes_count=0;
    bit ip_package_found=0;
    bit header_package_found=0;
    byte  byte_collected;
    bit [15:0] header;
    int header_bytes_count = 1;
    bit base_found = 0;
          int bit_index;
        fork
           sync_serial( );
        join
     item = sync_txrx_seq_item::type_id::create("sync_item");
        

 forever
     begin
         byte_collected = 0;
         for (int i = 0 ; i <=7 ; i++) begin
               @(negedge vif.clk);
             byte_collected[i] = vif.tx;  // Correct signal reference
          end
             // Check if the collected byte is IDLE and not zero
////         if (byte_collected != 8'hB5) begin
         if (!header_package_found) begin
         
        //---------------------------------------
        //  check if its start1 - 'h21
        //----------------------------------------
         if (byte_collected == 8'h21 && !start_ip_found && !ip_start2_found && !header_start2_found) begin // Detected start1
                    `uvm_info("MON", "Detected START1 (0x21)", UVM_LOW)
                    start_ip_found = 1;
                end       
        else if (byte_collected == 8'h1B && start_ip_found  && !ip_start2_found && !header_start2_found) begin // Detected start2 - header packge 
                    `uvm_info("MON", "Detected IP PACKAGE (0x1B)", UVM_LOW)
                      ip_start2_found=1;
                end     
           else   if (ip_start2_found & start_ip_found)
            begin
                 `uvm_info("MON", "Detected IP DATA", UVM_LOW)
                 
                    ip_bytes_count++;  // DATA 1 byte + 2 bytes crc
                    if(ip_bytes_count==3) 
                    ip_package_found=1;
            end 
   ////     else if (!ip_package_found)
   ////       $display(" INVALID PACKAGE - no collection");
        
  
         if( ip_package_found )
        begin
            ip_package_count++;
            ip_bytes_count=0;
            start_ip_found = 0;
            ip_start2_found = 0;
        end
        

        // must wait for header
   if( ip_package_found && !header_package_found )
        begin
           if ( byte_collected == 8'h21 && !start_header_found  && !header_start2_found) begin // Detected start1
           `uvm_info("MON", "Detected START1 for HEADER PACKAGE (0x21)", UVM_LOW)
           start_header_found = 1;
       end       
        else if (byte_collected == 8'h43 && start_header_found   && !header_start2_found) begin // Detected start2 - header packge 
                    `uvm_info("MON", "Detected HEADER PACKAGE (0x43)", UVM_LOW)
                      header_start2_found=1;
                     
                end 

          else   if (!base_found &&header_start2_found & start_header_found  )
            begin
                bit_index = 8 * header_bytes_count ;

                header[bit_index +: 8] = byte_collected; // This works in most simulation environments
             //   header[15-7*header_bytes_count -1 :87*header_bytes_count -1] = byte_collected;
                header_bytes_count--;
                if(header == 'hBA5E )
                begin
                base_found = 1;
                 buffer.delete();
                end
           end
                
        else   if (header_start2_found & start_header_found && base_found)
            begin
             data_bytes_count++;
             if(data_bytes_count%2==0)
                item.expected_data_out[15:8] = byte_collected;
             else   
                item.expected_data_out[7 :0] = byte_collected;
                if( data_bytes_count%2==0)  begin
//$display(" expected_data_out is %x", item.expected_data_out );
     item.expected_data_out_fifo.push_back(item.expected_data_out);  
               
     end       
                 if (data_bytes_count <= 72) begin   // data+footer
                  //  buffer.push_back(byte_collected);  
                  //  item.expected_data_out_fifo.push_back(item.expected_data_out);  
                 end  
                 else
                 begin
                    header_package_found=1;
                    
                    header_package_count++;
                    ip_package_found=0;
                    data_bytes_count=0;
                    start_header_found=0;
                    header_start2_found=0;
                    base_found=0;
                    header_bytes_count=1;
                    item.header_buffer = buffer;
                    item_id++;
                    item.item_id = item_id;
                    bit_index=1;
                    header='h0;
                     header_package_found=0;
                      analysis_port.write(item);
                end

            end 
     
  
        end

      
                 // Create a new sequence item for this packet (Avoids overwriting)
     //////            item = sync_txrx_seq_item::type_id::create($sformatf("sync_txrx_seq_item created"));       
     //////             item.valid_start1 = vif.valid_start1;
     //////             item.valid_start2 = vif.valid_start2;
     //////             item.valid_crc    = vif.valid_crc;
     //////             item.start1       = byte_collected;
     //////             analysis_port.write(item);
             end
        end


   endtask





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
     if (shift_reg == 8'hB5) begin // Check for sync word
        sync  =1;  // Correct signal reference
        $display("[SYNC sync_tx monitor] Sync word 0xB5 detected at time %0t",  $time);
        end
    end
  endtask








endclass: sync_txrx_monitor
`endif
