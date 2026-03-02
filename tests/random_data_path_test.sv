// UVM test base for taichi_tmb environment

//===============================================================================
class random_data_path_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(random_data_path_test)  // Register with the factory
  rand bit random_package; 
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "random_data_path_test", uvm_component parent = null);
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
int hd_pointer_address = 'h06D7B500;
 

    	phase.raise_objection (this);
         	super.run_phase(phase);

        active_Mu_functional(0);
        active_synth_data(1);
   
  send_valid_sync_packet (0); 
        #50us;
        send_valid_sync_packet (1); 
 #50us;
//---------------------------------------------------------------------
// SEND IP DATA 'B5' VALUE SAME AS IDLE
//---------------------------------------------------------------------
  if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==SYNC_IP;
              m_sync_txrx_seq.item.ip_data == 'hB5;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
    #50us;
  if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==SYNC_HEADER;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
    #50us;
//---------------------------------------------------------------------


   repeat (2)
   begin
    random_package = $random;
        send_valid_sync_packet (0); 
        #50us;
        send_valid_sync_packet (1); 
        #50us;
        send_valid_sync_packet (1); 
        #50us;
   end

#600us;
   repeat(5)
   begin
  if (!this.m_buffer_tx_sequence.randomize() with { 
                 }) 

               

              `uvm_fatal("RUN_PHASE", "Randomization failed for m_buffer_tx_sequence")
             this.m_buffer_tx_sequence.start(this.m_taichi_tmb_env.m_buffer_tx_agent.seqr);

        #60us;


   end
   
   

        #100us;

    	phase.drop_objection (this);
   endtask

endclass
