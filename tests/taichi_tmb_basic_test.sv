// UVM test base for taichi_tmb environment

class taichi_tmb_basic_test extends taichi_tmb_test_base;
    // Testbench configuration and stimulus generation
       `uvm_component_utils(taichi_tmb_basic_test)  // Register with the factory
  

        // This is standard code for all components
    function new (string name = "taichi_tmb_basic_test", uvm_component parent = null);
      super.new (name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    
    task run_phase (uvm_phase phase);

   	super.run_phase(phase);

    	phase.raise_objection (this);

       
     

      repeat (3)
      begin
        
            if (!m_controllers_seq.randomize() with { 
       }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_taichi_tmb_seq")
              m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);      
      end


         repeat (2)
      begin
        if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.start1 == 'h21;
              m_diag_txrx_seq.item.start2 == 'h43;
              m_diag_txrx_seq.item.times_sent_idle == 3;
              m_diag_txrx_seq.item.valid_crc == 1;
              
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);

      end

              #10us;
    	phase.drop_objection (this);
   endtask

endclass
