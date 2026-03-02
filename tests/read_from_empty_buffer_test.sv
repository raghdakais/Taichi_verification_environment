// UVM test base for taichi_tmb environment

//===============================================================================
class read_from_empty_buffer_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(read_from_empty_buffer_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "read_from_empty_buffer_test", uvm_component parent = null);
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
int hd_pointer_address = 'h06D7B504;
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
    send_operation_transaction(TXRX_READ, 'h06424, 'h0); 

   ////  0xB00X6790	Module Data Out Type selection
    send_operation_transaction(TXRX_READ, 'h06424, 'h0); 

//`uvm_info("RUN_PHASE", "START SENDING BUFFER TX")
 `uvm_warning("DEBUG", "START OF BUFFER REQUEST")
repeat(2)
begin
       if (!this.m_buffer_tx_sequence.randomize() with { 
        m_buffer_tx_sequence.item.buf_ptr_address_sig == hd_pointer_address;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);

        #60us;

end
 `uvm_warning("DEBUG", "END OF BUFFER REQUEST")



   repeat (2)
   begin
        send_valid_sync_packet (SYNC_IP); 
        #50us;
      
        if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==SYNC_HEADER;
              m_sync_txrx_seq.item.slices_num =='h2;
              m_sync_txrx_seq.item.hd_pointer_address ==hd_pointer_address;

                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
        hd_pointer_address = hd_pointer_address +4;
        #50us;
   end
   
        #100us;
 
repeat(3)
begin
       if (!this.m_buffer_tx_sequence.randomize() with { 
        m_buffer_tx_sequence.item.buf_ptr_address_sig == hd_pointer_address;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);

        #60us;

end




        #100us;

    	phase.drop_objection (this);
   endtask

endclass
