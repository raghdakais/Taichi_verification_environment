// UVM test base for taichi_tmb environment

//===============================================================================
class sig2_sync_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(sig2_sync_test)  // Register with the factory
  

rand bit [31:0]  random_data;
rand bit sig2_ch_rdy;
rand bit [3:0]  soft_reset;
rand bit sync_event; 
covergroup cg_protocol  with function sample ();  

  // Assuming sig_2 is an 8-bit signal
  coverpoint random_data {
    bins all_low         = {8'h00};                 // All bits low
  }

  coverpoint sig2_ch_rdy {
    bins rdy_disabled = {0};
    bins rdy_enabled  = {1};
  }

  coverpoint soft_reset {
    bins soft_reset_enable = {4'hC};
    bins soft_reset_random  = {[4'hD:4'hF]}; 
  }

  coverpoint sync_event {
    // Assume sync_event encodes synchronization state
    // 0: invalid sync, 1: valid sync
    bins invalid_sync = {0};
    bins valid_sync   = {1};
    bins invalid_to_valid = (0 => 1);
    bins valid_to_rdy_off = (1 => 0); // Use cross for disabling rdy after valid sync
  }



endgroup




        // This is standard code for all components
    function new (string name = "sig2_sync_test", uvm_component parent = null);
      super.new (name, parent);
      // Instantiate the covergroup
cg_protocol  = new();
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    
//===============================================================================
    task run_phase (uvm_phase phase);
//===============================================================================

    	phase.raise_objection (this);
     ///    	super.run_phase(phase);


//--------------------------------------------------------
// sending a syncronization sequence for sig 2 signal - value 0 
//--------------------------------------------------------
random_data ='h0;
sig2_ch_rdy = 0;
sync_event = 0;
         if (!this.m_controllers_seq.randomize() with { 
               m_controllers_seq.item.data =='h0;
               m_controllers_seq.item.sig2_ch_rdy ==sig2_ch_rdy;

               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq")
           this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);

cg_protocol.sample();
#1us;


//--------------------------------------------------------
// sending a syncronization sequence for sig 2 signal - channel_ready = 1
//--------------------------------------------------------
sig2_ch_rdy ='h1;
random_data = $random;
soft_reset = 'hD;
         if (!this.m_controllers_seq.randomize() with { 
               m_controllers_seq.item.sig2_ch_rdy ==sig2_ch_rdy;

               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq")
           this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);
#1us;

cg_protocol.sample();


//--------------------------------------------------------
// sending a syncronization sequence for sig 2 signal - soft reset = 1
//--------------------------------------------------------
sig2_ch_rdy ='h1;
random_data = $random;
soft_reset = 'hC;
sync_event = 1;
         if (!this.m_controllers_seq.randomize() with { 
               m_controllers_seq.item.sig2_soft_reset ==1;

               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq")
           this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);
#1us;

cg_protocol.sample();

//--------------------------------------------------------
// sending a syncronization sequence for sig 2 signal - value 0 
//--------------------------------------------------------
random_data ='h0;
sig2_ch_rdy = 0;
sync_event = 0;
         if (!this.m_controllers_seq.randomize() with { 
               m_controllers_seq.item.data =='h0;
               m_controllers_seq.item.sig2_ch_rdy ==sig2_ch_rdy;

               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq")
           this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);

cg_protocol.sample();
#1us;


             #100us;
    	phase.drop_objection (this);


   endtask



endclass
