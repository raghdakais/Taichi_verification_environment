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
   int count_bytes_for_size = 0;
   int data_out_packet_size = 0;
byte unsigned byte_collected;
int data_out_packet_size_count=0;
bit size_collected=0;
bit header_package_recieved = 0;
bit data_package_recieved = 0;
bit footer_package_recieved = 0;
bit crc_recieved = 0;
int crc_count = 0;
bit [15:0] expected_crc = 16'hFFFF; 
bit [15:0] actual_crc ;
int data_bytes_count=0;
int collect_addr_count= 0;
           fork
           sync_serial( );
        join
  
    
    item = data_out_seq_item::type_id::create("data_out_item");
            
        forever 
        begin
                byte_collected = 0;
                for (int i = 0 ; i <=7 ; i++) begin
                    if (i==0)
                       vif.collect_en=1;
                    else
                       vif.collect_en=0;
             
                    @(negedge vif.clk);
                    byte_collected[i] = vif.rx[0];  // Correct signal reference
                end
                 vif.data_out_byte = byte_collected;
                 //-----------------------------------------------------------------------
                 // Collecting Start1
                 //-----------------------------------------------------------------------
               if (byte_collected == 8'h21 && !start1_recieved) 
               begin
                crc_recieved = 0;
                expected_crc = 16'hFFFF; 
                    start1_recieved = 1;
                    data_out_packet_size = 0;
                    data_out_packet_size_count=0;
                   expected_crc =  calculate_crc16_byte(expected_crc, byte_collected  );
               end
                 //-----------------------------------------------------------------------
                 // Collecting Start2
                 //-----------------------------------------------------------------------
               else if (byte_collected == 8'hDD && start1_recieved && !start2_recieved) 
               begin
                    start2_recieved = 1; 
                    expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
               end
                 //-----------------------------------------------------------------------
                 // Collecting DATA SIZE FEILD FROM HEADER
                 //-----------------------------------------------------------------------
               else if( start1_recieved && start2_recieved && !size_collected)
                begin
                    expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                    count_bytes_for_size++;
                    if(count_bytes_for_size<=4)
                         //data_out_packet_size = {data_out_packet_size[23:0], byte_collected};  // Shift in from LSB
                         data_out_packet_size = {byte_collected, data_out_packet_size[31:8]};   
                    else
                    begin
                        $display("sents size is [%h] at time %t",data_out_packet_size , $time );
                        item.data_out_packet_size = data_out_packet_size;
                        vif.data_out_packet_size = data_out_packet_size;
                         size_collected = 1;
                    end
                end
                 //-----------------------------------------------------------------------
                 // Collecting HEADER PACKAGE
                 //-----------------------------------------------------------------------
             else  if( start1_recieved && start2_recieved && size_collected && !header_package_recieved )
                begin
                    
                    expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                    
                               if(data_bytes_count%2==0)
                item.actual_header_sync[15:8] = byte_collected;
             else   
                item.actual_header_sync[7 :0] = byte_collected;
                data_bytes_count++;
                if( data_bytes_count%2==0)  begin
//$display(" actual_header_sync is %x", item.actual_header_sync );
  ///   item.actual_header_sync_fifo.push_back(item.actual_header_sync);  
  



                    item.header_buffer.push_back( item.actual_header_sync);  
                     ///   vif.header_buffer = item.header_buffer;
                    // Capture observed values
                end
                    if(item.header_buffer.size() ==`DATA_OUT_HEADER_SIZE - 1)
                    begin
                       // item.data_out_packet_size= data_out_packet_size;
                        header_package_recieved = 1;
                        vif.header_package_recieved = header_package_recieved;
                    end
                end
                 //-----------------------------------------------------------------------
                 // Collecting DATA PACKAGE
                 //-----------------------------------------------------------------------
              else  if( start1_recieved && start2_recieved && size_collected && header_package_recieved && !data_package_recieved)
                begin
                        expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                        vif.start_package = 1;
                        if(data_out_packet_size_count==0)
                        vif.first_data_byte = byte_collected;
                         data_out_packet_size_count++;
                         item.data_buffer.push_back( byte_collected);  
                         vif.data_out_packet_size = data_out_packet_size; 
                         if(item.data_buffer.size() ==data_out_packet_size)
                         begin
                             vif.end_package = 1;
                             data_package_recieved = 1;                         
                         end
                end
                 //-----------------------------------------------------------------------
                 // Collecting FOOTER PACKAGE
                 //-----------------------------------------------------------------------
              else  if( start1_recieved && start2_recieved && size_collected && header_package_recieved && data_package_recieved && !footer_package_recieved )
                begin
                    vif.first_data_byte = byte_collected;
                    expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                            // Storing footer fields

                            if(collect_addr_count<4)
                            begin
                                case (collect_addr_count)
                                0:  vif.buffer_ptr_addr[7:0]   = byte_collected ; // High byte 
                                1:  vif.buffer_ptr_addr[15:8]  = byte_collected ;
                                2:  vif.buffer_ptr_addr[23:16] = byte_collected ;
                                3:  vif.buffer_ptr_addr[31:24] = byte_collected ;   // Low b
                                endcase
                            collect_addr_count++;
                            end
                            else
                            collect_addr_count = 0;
                    item.footer_buffer.push_back( byte_collected);       
                    if(item.footer_buffer.size() ==`DATA_OUT_FOOTER_SIZE )
                    begin
                        footer_package_recieved = 1;
                     
                    end

                end
                //-----------------------------------------------------------------------
                 // Collecting CRC
                 //-----------------------------------------------------------------------
                else if( header_package_recieved && data_package_recieved && footer_package_recieved)
                    begin
                        if (crc_count < 2)
                            begin
                                case (crc_count)
                                  0: actual_crc[15:8] = byte_collected;
                                  1: actual_crc[7:0]  = byte_collected;
                                endcase
                                crc_count++;
                            end
                        else
                            begin
                              if (expected_crc !== actual_crc & !crc_recieved)
                              begin
                                     uvm_report_error (get_type_name (), $sformatf ("[ERROR] [DATA OUT -MONITOR]  DATA OUT CRC is NOT AS EXPECTED"));
                                     $display("[EXPECTED] - DATA OUT CRC  [%h]", expected_crc );
                                     $display("[ACTUAL]   - DATA OUT CRC  [%h]", actual_crc );
                              end
                           analysis_port.write(item);
                           if (get_report_verbosity_level() >= UVM_DEBUG)
                            begin
                                $display("DATA OUT Monitor Printing %s Item: ",this.get_type_name);
                                item.print();
                            end
                            item.header_buffer.delete();
                            item.data_buffer.delete();
                            item.footer_buffer.delete();
                             crc_recieved = 1;
                             // reset all flags 
                             size_collected = 0;
                             start1_recieved = 0 ;
                             start2_recieved = 0 ;
                             header_package_recieved = 0 ;
                             data_package_recieved = 0 ;
                             footer_package_recieved = 0 ;
                             count_bytes_for_size = 0;
                             crc_count = 0;

                         end
                    end
                if (byte_collected != 8'hB5 && crc_recieved)
                begin
                       data_out_packet_size_count++;
                       uvm_report_error (get_type_name (), $sformatf ("[ERROR] [DATA OUT -MONITOR]  Number of bytes is more than the size that was sent"));
                       $display("[EXPECTED] - data_out_packet_size       [%d]", data_out_packet_size );
                       $display("[ACTUAL] - data_out_packet_size_count [%d]", data_out_packet_size_count );
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




  // Function to calculate CRC16
    static function logic [15:0] calculate_crc16_byte(logic [15:0] crc, logic [7:0] data);
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




endclass: data_out_monitor
`endif
