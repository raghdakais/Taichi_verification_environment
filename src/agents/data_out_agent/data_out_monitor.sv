`ifndef DATA_OUT_MONITOR_SV
`define DATA_OUT_MONITOR_SV
//----------------------------------------------------------------
class data_out_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(data_out_monitor)

    virtual data_out_agent_if vif;
    data_out_config cfg;            // Configuration object
    data_out_seq_item item;
    uvm_analysis_port #(data_out_seq_item) analysis_port;

    function new(string name="m_data_out_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("data_out_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
   bit start1_recieved=0; 
   bit start2_recieved = 0;
   int header_size=0;
   int count_bytes_for_size = 0;
   int data_out_packet_size = 0;
byte unsigned byte_collected;
int data_out_packet_size_count=0;
bit size_collected=0;
bit header_package_recieved = 0;
bit crc_recieved = 0;
int crc_count = 0;
           fork
           sync_serial( );
        join
  
    
    item = data_out_seq_item::type_id::create("data_out_item");
            
        forever 
        begin
                byte_collected = 0;
                for (int i = 0 ; i <=7 ; i++) begin
                    @(negedge vif.clk);
                    byte_collected[i] = vif.rx[0];  // Correct signal reference
                end
                 vif.data_out_byte = byte_collected;
               if (byte_collected == 8'h21 && !start1_recieved) 
                    start1_recieved = 1;
               else if (byte_collected == 8'hDD && start1_recieved && !start2_recieved) 
                    start2_recieved = 1; 
               else if( start1_recieved && start2_recieved && !size_collected)
                begin
                    count_bytes_for_size++;
                    if(count_bytes_for_size<4)
                         data_out_packet_size = {data_out_packet_size[23:0], byte_collected};  // Shift in from LSB
                    else
                    begin
                        item.data_out_packet_size = data_out_packet_size;
                         size_collected = 1;
                    end

                end
             else  if( start1_recieved && start2_recieved && size_collected && !header_package_recieved && data_out_packet_size_count <data_out_packet_size)
                begin
                    data_out_packet_size_count++;
                    item.header_buffer.push_back( byte_collected);      
                    // Capture observed values
                   
                    if(item.header_buffer.size() ==data_out_packet_size)
                    begin
                        header_package_recieved = 1;
                        analysis_port.write(item);
                        item.header_buffer.delete();
                    end
                // printing item fields only in UVM_DEBUG Mode
                if (get_report_verbosity_level() >= UVM_DEBUG)
                begin
                    $display("Monitor Printing %s Item: ",this.get_type_name);
                    item.print();
                end
                end
                else  if (byte_collected != 8'hB5 && crc_recieved  && data_out_packet_size_count>= data_out_packet_size)
                begin
                       uvm_report_error (get_type_name (), $sformatf ("[ERROR] [DATA OUT -MONITOR]  Number of bytes is more than the size that was sent"));
                       $display("[EXPECTED] - data_out_packet_size       [%d]", data_out_packet_size );
                       $display("[ACTUAL] - data_out_packet_size_count [%d]", data_out_packet_size_count );
                end

                                //---- COllecting crc -- 
                else if( header_package_recieved  )
                    begin
                        // TODO add CRC CHECK 
                        if (crc_count < 2)
                            crc_count++;
                            else
                            begin
                                crc_recieved = 1;
                                // reset all flags 
                                size_collected = 0;
                                start1_recieved = 0 ;
                                start2_recieved = 0 ;
                                header_package_recieved = 0 ;
                                data_out_packet_size_count=0;
                            end
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
     shift_reg = {vif.rx[0], shift_reg[7:1]}; // Shift bits from LSB to MSB
     if (shift_reg == 8'hB5) begin // Check for sync word
        sync  =1;  // Correct signal reference
        $display("[SYNC DATA_OUT monitor] Sync word 0xB5 detected at time %0t",  $time);
        end
    end
  endtask
endclass: data_out_monitor
`endif
