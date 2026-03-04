// UVM test base for taichi_tmb environment

//===============================================================================
class random_sign2_while_sending_sync_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(random_sign2_while_sending_sync_test)  // Register with the factory
  

rand bit [31:0]  random_data;
rand bit sig2_ch_rdy;
rand bit [3:0]  soft_reset;
rand bit sync_event; 
  // Random delay (10us..60us)
  rand int unsigned ch_rdy0_delay_us;



        // This is standard code for all components
    function new (string name = "random_sign2_while_sending_sync_test", uvm_component parent = null);
      super.new (name, parent);
      // Instantiate the covergroup
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    
//===============================================================================
    task run_phase (uvm_phase phase);
//===============================================================================
  int unsigned drop_after_us;
  int unsigned low_time_us;
event header_sent;

    	phase.raise_objection (this);

    //--------------------------------------------------------
    // Initial: channel_ready = 1
    //--------------------------------------------------------
    sig2_ready(1);
    config_asic();
    #50us;


  repeat (2)
   begin
        send_valid_sync_packet (0); 
        #60us;
        send_valid_sync_packet (1); 
        #60us;
   end
 
  fork
    begin   
    repeat(5)
    begin
          send_valid_sync_packet(0);
          #60us;
          send_valid_sync_packet(1);
         ->header_sent;
     end
    end

    begin
      repeat(10)
      begin
        @(header_sent)
       // Randomize when to drop after the packet (example: 0..60us)
          drop_after_us = $urandom_range(0, 10);
          // Randomize how long to keep it low (example: 1..20us)
          low_time_us   = $urandom_range(0, 1000);
          #(low_time_us * 1us);
          sig2_ready(0);
          #(drop_after_us * 1ns);
          sig2_ready(1);
      
      end

    end
  join
    repeat(4)
        begin
          send_valid_sync_packet(0);
          #60us;
          send_valid_sync_packet(1);
          #60us;
        end

repeat(5)
begin
       m_buffer_tx_sequence = buffer_tx_sequence::type_id::create ("m_buffer_tx_sequence");
       if (!this.m_buffer_tx_sequence.randomize() with {   }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
end

             #100us;
    	phase.drop_objection (this);


   endtask



task sig2_ready(bit rdy);
        m_controllers_seq = controllers_sequence::type_id::create ("m_controllers_seq");
     if (!this.m_controllers_seq.randomize() with {
              m_controllers_seq.item.sig2_ch_rdy == rdy;
            })
          `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq (sig2_ch_rdy=0)")
        this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);
    

endtask


endclass
