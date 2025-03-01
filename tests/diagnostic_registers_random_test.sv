// UVM test base for taichi_tmb environment

class diagnostic_registers_random_test extends taichi_tmb_test_base;
    // Testbench configuration and stimulus generation
       `uvm_component_utils(diagnostic_registers_random_test)  // Register with the factory
  

        // This is standard code for all components
    function new (string name = "diagnostic_registers_random_test", uvm_component parent = null);
      super.new (name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    
    task run_phase (uvm_phase phase);

   	super.run_phase(phase);

    	phase.raise_objection (this);
         #200ns;

   repeat (1)
      begin
        if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_READ;    
              m_diag_txrx_seq.item.address == 'h406380;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);

      end

              #50ns;
    	phase.drop_objection (this);
   endtask

endclass
