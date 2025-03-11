// UVM test base for taichi_tmb environment

class taichi_tmb_test_base extends uvm_test;
    // Testbench configuration and stimulus generation
    taichi_tmb_env m_taichi_tmb_env;
    
   	TXRX_sequence m_diag_txrx_seq;
   	TXRX_sequence m_oper_txrx_seq;
    taichi_tmb_sequence m_taichi_tmb_seq;
    controllers_sequence m_controllers_seq;
        

        // This is standard code for all components
    function new (string name = "taichi_tmb_test_base", uvm_component parent = null);
      super.new (name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        this.m_taichi_tmb_env  = taichi_tmb_env::type_id::create("m_taichi_tmb_env", this);
       // creating sequences
        m_taichi_tmb_seq = taichi_tmb_sequence::type_id::create ("m_taichi_tmb_seq");
        m_controllers_seq = controllers_sequence::type_id::create ("m_controllers_seq");
        m_diag_txrx_seq = TXRX_sequence::type_id::create ("m_diag_txrx_seq");
        m_oper_txrx_seq = TXRX_sequence::type_id::create ("m_oper_txrx_seq");
 
    endfunction

 //  [Recommended] start a sequence for this particular test
    task run_phase (uvm_phase phase);    
   	super.run_phase(phase);


//--------------------------------------------------------
// sending a syncronization sequence for sig 2 signal
//--------------------------------------------------------
   #30us;
        if (!this.m_controllers_seq.randomize() with { 
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq")
           this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);

#10us;
   endtask




endclass
