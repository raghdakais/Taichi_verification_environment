// UVM test base for taichi_tmb environment

//===============================================================================
class sync_invalid_crc_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(sync_invalid_crc_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "sync_invalid_crc_test", uvm_component parent = null);
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

send_diagnostical_transaction(TXRX_READ, 'h064D0, 'h0); 

//------------------------------------------------------
// Sending VALOD 10 SYNCS
//------------------------------------------------------
   repeat (3)
   begin
        send_valid_sync_packet (0); 
        #60us;
        send_valid_sync_packet (1); 
        #60us;
        send_diagnostical_transaction(TXRX_READ, 'h064D0, 'h0); 

   end

//------------------------------------------------------
// Sending INVALID CRC SYNC
//------------------------------------------------------
   
   repeat(1)
   begin
            m_sync_txrx_seq = sync_txrx_sequence::type_id::create ("m_sync_txrx_seq");

      send_valid_sync_packet (0); 
        #60us;
   if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==1;
              m_sync_txrx_seq.item.header_valid_crc == 0;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
  send_diagnostical_transaction(TXRX_READ, 'h064D0, 'h0); 
 #80us;
   end
//------------------------------------------------------
// Sending VALID  SYNC
//------------------------------------------------------
   repeat(4)
   begin
        send_valid_sync_packet (0); 
        #60us;
        send_valid_sync_packet (1); 
        #60us;
   end
//==========================
//       B U F F E R 
//==========================
//------------------------------------------------------
// valid buffer 
//------------------------------------------------------
 `uvm_warning("DEBUG", "START OF BUFFER REQUEST")
repeat(5)
begin
                m_buffer_tx_sequence = buffer_tx_sequence::type_id::create ("m_buffer_tx_sequence");

       if (!this.m_buffer_tx_sequence.randomize() with { 
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
send_diagnostical_transaction(TXRX_READ, 'h064D0, 'h0); 

end

        #100us;

    	phase.drop_objection (this);
   endtask

endclass
