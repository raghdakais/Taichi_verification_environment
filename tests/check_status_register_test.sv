// UVM test base for taichi_tmb environment

//===============================================================================
class check_status_register_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(check_status_register_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "check_status_register_test", uvm_component parent = null);
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
    send_operation_transaction(TXRX_READ, 'h06424, 'h0); 

   ////  0xB00X6790	Module Data Out Type selection
    send_operation_transaction(TXRX_READ, 'h06424, 'h0); 

//`uvm_info("RUN_PHASE", "START SENDING BUFFER TX")

send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 

//------------------------------------------------------
// Sending VALOD 10 SYNCS
//------------------------------------------------------
   repeat (3)
   begin
        send_valid_sync_packet (0); 
        #60us;
        send_valid_sync_packet (1); 
        #60us;
   end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 
//------------------------------------------------------
// Sending INVALID CRC SYNC
//------------------------------------------------------
   
   repeat(1)
   begin
      send_valid_sync_packet (0); 
        #60us;
   if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==1;
              m_sync_txrx_seq.item.header_valid_crc == 0;
              m_sync_txrx_seq.item.random_slot_address ==0;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
  send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 
 #60us;

   end
   
//------------------------------------------------------
// Sending Random address for SYNCS 
//------------------------------------------------------
  repeat(1)
  begin
      send_valid_sync_packet (0); 
        #60us;
   if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==1;
          //    m_sync_txrx_seq.item.slot_addr_random =='h1000;
              m_sync_txrx_seq.item.random_slot_address ==1;


                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
  send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 
 #60us;
  end


repeat(1)
  begin
      send_valid_sync_packet (0); 
        #60us;
   if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==1;
              m_sync_txrx_seq.item.random_slot_address ==0;
              m_sync_txrx_seq.item.header_valid_crc == 1;



                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
  send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 
 #60us;

  end




//------------------------------------------------------
// valid buffer 
//------------------------------------------------------
 `uvm_warning("DEBUG", "START OF BUFFER REQUEST")
repeat(2)
begin
       if (!this.m_buffer_tx_sequence.randomize() with { 
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 


//------------------------------------------------------
// random buffer 
//------------------------------------------------------
repeat(1)
begin
       if (!this.m_buffer_tx_sequence.randomize() with { 
                m_buffer_tx_sequence.item.valid_crc ==0;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;


       if (!this.m_buffer_tx_sequence.randomize() with { 
                m_buffer_tx_sequence.item.valid_crc ==1;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);
        #60us;
end
send_diagnostical_transaction(TXRX_READ, 'h06424, 'h0); 


//------------------------------------------------------
// random buffer 
//------------------------------------------------------
repeat(1)
begin
       if (!this.m_buffer_tx_sequence.randomize() with { 
                m_buffer_tx_sequence.item.slot_addr_random =='h2000;
                m_buffer_tx_sequence.item.random_slot_address ==1;
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
