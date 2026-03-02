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

    function new(string name="m_buffer_tx_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("buffer_tx_analysis_port", this);
    endfunction


    task run_phase(uvm_phase phase);
byte unsigned byte_collected;
int byte_num = 0;
bit start1_recieved;
bit start2_recieved;


        super.run_phase(phase);

   fork
           sync_serial( );
        join
  
    
    item = buffer_tx_seq_item::type_id::create("buffer_tx_seq_item");
       

       forever 
        begin
                byte_collected = 0;
                for (int i = 0 ; i <=7 ; i++) begin
                    @(negedge vif.clk);
                    byte_collected[i] = vif.tx[0];  // Correct signal reference
                end
                 vif.data_out_byte = byte_collected;
               if (byte_collected == 8'h21 && !start1_recieved) 
                 start1_recieved = 1;
               else if (byte_collected == 8'h43 && start1_recieved && !start2_recieved) 
                    start2_recieved = 1; 
               else if( start1_recieved && start2_recieved)
                begin
                    if(byte_num < `BUFFER_HEADER_SIZE +`BUFFER_DATA_SIZE +`BUFFER_FOOTER_SIZE )
                        begin
                            byte_num++;
                            if(byte_num == 2) ;  // HEADER - BA5E
                         //   item.stream_ctrl = byte_collected;                            
                          if (byte_num >= 3 && byte_num <= 6) begin
                                case (byte_num)
                                    6: item.buf_ptr_address_sig[31:24] = byte_collected;
                                    5: item.buf_ptr_address_sig[23:16] = byte_collected;
                                    4: item.buf_ptr_address_sig[15:8]  = byte_collected;
                                    3: item.buf_ptr_address_sig[7:0]   = byte_collected;
                                endcase
                            end
                         if (byte_num==9)
                               item.stream_ctrl = byte_collected;                            
                         


                        end

                end
                 if (byte_num==10)
                 begin   
                  analysis_port.write(item);
                // printing item fields only in UVM_DEBUG Mode
                if (get_report_verbosity_level() >= UVM_DEBUG)
                    begin
                        $display("DATA OUT Monitor Printing %s Item: ",this.get_type_name);
                        item.print();
                    end
                    // reset all flags 
                    start1_recieved = 0 ;
                    start2_recieved = 0 ;
                    byte_num=0;
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
     shift_reg = {vif.tx[0], shift_reg[7:1]}; // Shift bits from LSB to MSB
     if (shift_reg == 8'hB5) begin // Check for sync word
        sync  =1;  // Correct signal reference
        $display("[SYNC BUFFER_TX monitor] Sync word 0xB5 detected at time %0t",  $time);
        end
    end
  endtask



endclass: buffer_tx_monitor
`endif
