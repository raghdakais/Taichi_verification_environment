// UVM test base for taichi_tmb environment

//===============================================================================
class wrap_arround_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(wrap_arround_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "wrap_arround_test", uvm_component parent = null);
      super.new (name, parent);
    endfunction


//===============================================================================
    function void build_phase(uvm_phase phase);
//===============================================================================
        super.build_phase(phase);
    endfunction

    
//===============================================================================
    task run_phase (uvm_phase phase);
//===============================================================================
    	phase.raise_objection (this);
         	super.run_phase(phase);

        active_Mu_functional(0);
        active_synth_data(1);
   
    #1.5us;
    ////  0xB00X6790	Module Data Out Type selection
    send_operation_transaction(TXRX_WRITE, 'h406790, 'h0); 
    ////  0xB00X6750	Miscellaneous
    send_operation_transaction(TXRX_WRITE, 'h406750, 'h00004); 
    ////  0xB00X6790	Module Data Out Type selection
    send_operation_transaction(TXRX_READ, 'h064D0, 'h0); 

send_diagnostical_transaction(TXRX_WRITE, 'h064D0, 'hFFFF_FFFF); 

//------------------------------------------------------
// Sending VALOD 10 SYNCS
//------------------------------------------------------
   repeat (8)
   begin
        send_valid_sync_packet (0); 
        #60us;
        send_valid_sync_packet (1); 
        #60us;
   end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 
//==========================
//       B U F F E R 
//==========================
//------------------------------------------------------
// valid buffer 
//------------------------------------------------------
 `uvm_warning("DEBUG", "START OF BUFFER REQUEST")
repeat(3)
begin
       m_buffer_tx_sequence = buffer_tx_sequence::type_id::create ("m_buffer_tx_sequence");
       if (!this.m_buffer_tx_sequence.randomize() with { 
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 


//------------------------------------------------------
// read from written valid buffer 
//------------------------------------------------------
 `uvm_warning("DEBUG", "START OF BUFFER REQUEST")
repeat(1)
begin
       m_buffer_tx_sequence = buffer_tx_sequence::type_id::create ("m_buffer_tx_sequence");
       if (!this.m_buffer_tx_sequence.randomize() with { 
                m_buffer_tx_sequence.item.random_address_jump ==0;
                m_buffer_tx_sequence.item.allow_random_address ==1;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 

//==========================
//------------------------------------------------------
// valid buffer 
//------------------------------------------------------
 `uvm_warning("DEBUG", "START OF BUFFER REQUEST")
repeat(3)
begin
       m_buffer_tx_sequence = buffer_tx_sequence::type_id::create ("m_buffer_tx_sequence");
       if (!this.m_buffer_tx_sequence.randomize() with { 
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 



        #100us;

    	phase.drop_objection (this);
   endtask

endclass
