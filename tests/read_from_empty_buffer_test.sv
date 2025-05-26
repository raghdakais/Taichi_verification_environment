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

    	phase.raise_objection (this);
         	super.run_phase(phase);

        active_Mu_functional(0);
        active_synth_data(1);
   

   
        #600us;

repeat(2)
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
