`ifndef DATA_OUT_MONITOR_SV
`define DATA_OUT_MONITOR_SV
//----------------------------------------------------------------
class data_out_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(data_out_monitor)

    virtual data_out_agent_if vif;
    data_out_config cfg;            // Configuration object
    data_out_seq_item item;
 byte unsigned byte_collected;

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
 int size_bytes_count = 0;
 int ct_type_count = 0;  
 bit [15:0]  ct_type;  
 int data_collected_count = 0;  
 int footer_collected_count = 0;  
       byte start1, start2;
    data_out_state_e state = WAIT_DATA_OUT;

           fork
           sync_serial( );
        join
  
    
            
     forever 
        begin
            // Collect raw byte
            collect_byte();
            case (state)
                // ----------------------------------------------------
                WAIT_DATA_OUT: begin
                // ----------------------------------------------------
                  begin
                    if ( byte_collected == 8'hB5) begin
                        state = WAIT_START1;
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
                        expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                    end
                        vif.state = state;
                 end
                // ----------------------------------------------------
                WAIT_START2:
                // ----------------------------------------------------
                 begin
                    if (byte_collected == 8'hDD) begin
                        start2 = byte_collected;
                        item = data_out_seq_item::type_id::create("data_out_item");
                        item.start1 = start1;
                        item.start2 = byte_collected;
                        state = COLLECT_HEADER;
                         vif.state = state;
                         expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                    end
                 end            
                // ----------------------------------------------------
                COLLECT_PACKET_SIZE:
                // ----------------------------------------------------
                begin
                    expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                    size_bytes_count++;
                    if (size_bytes_count <= 4) 
                      data_out_packet_size = {byte_collected, data_out_packet_size[31:8]};

                    if (size_bytes_count == 4)
                     begin
                          $display("sent size is [%h] at time %t", data_out_packet_size, $time);
                          item.data_out_packet_size = data_out_packet_size;
                          vif.data_out_packet_size  = data_out_packet_size;
                          size_bytes_count = 0;
                          state = COLLECT_HEADER;
                          vif.state = state;
                      end
                end

                // ----------------------------------------------------
                COLLECT_HEADER:
                // ----------------------------------------------------
                begin
                   expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                  item.header_buffer.push_back(byte_collected);
                    ct_type_count++;
                    if(ct_type_count<=2)
                      ct_type = {byte_collected, ct_type[15:8]};
                      if(ct_type_count==4 )
                        begin
                          vif.ct_type = ct_type;
                          item.ct_type = ct_type;
                       ///   ct_type_count = 0;
                        end

                   // Your original condition: size() == `DATA_OUT_HEADER_SIZE - 1
                   // Keeping the same behavior:
                   if (item.header_buffer.size() == (`DATA_OUT_HEADER_SIZE - 1)) begin
                     state = COLLECT_DATA;
                     vif.state = state;
                     ct_type_count=0 ;
                   end
                 end
        // ----------------------------------------------------
        COLLECT_DATA:
       // ----------------------------------------------------         
                 begin
                     expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
                     if(data_collected_count< data_out_packet_size )
                         begin
                         item.data_buffer.push_back(byte_collected);
                         data_collected_count++;
                         end
                     if (item.data_buffer.size() == (data_out_packet_size - 1)) begin
                         state = COLLECT_FOOTER;
                         vif.state = state;
                         data_collected_count = 0;
                   end
             
                 end
        // ----------------------------------------------------
        COLLECT_FOOTER:
       // ----------------------------------------------------         
        begin
            expected_crc = calculate_crc16_byte(expected_crc, byte_collected  );
            if(footer_collected_count< `DATA_OUT_FOOTER_SIZE )
                begin
                footer_collected_count++;
                end
                else
                begin
                   state = COLLECT_FOOTER;
                   vif.state = state;
                   footer_collected_count = 0;
                end
        end

        COLLECT_CRC:
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
                    if (expected_crc !== actual_crc & !expected_crc)
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
                   // reset all flags 
                   crc_count = 0;
                   state = WAIT_START1;
                   vif.state = state;
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
           
            byte_collected[i] = vif.rx;
                 @(negedge vif.clk);
        end
         vif.byte_collected = byte_collected;
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
