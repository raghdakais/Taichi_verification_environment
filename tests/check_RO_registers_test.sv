// UVM test base for taichi_tmb environment

//===============================================================================
class check_RO_registers_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(check_RO_registers_test)  // Register with the factory
  

        // This is standard code for all components
    function new (string name = "check_RO_registers_test", uvm_component parent = null);
      super.new (name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    
//===============================================================================
    task run_phase (uvm_phase phase);
//===============================================================================

    	phase.raise_objection (this);
         	super.run_phase(phase);


//------------------------------------------------------
// Check Random READ WRITE - DIAGNOSTICAL
//------------------------------------------------------
foreach(DIAG_REGISTERS[i])
   begin
       m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq_%0d", i));
          if(DIAG_REGISTERS[i].is_writable == 0)
          begin
           if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_diag_txrx_seq.item.address == DIAG_REGISTERS[i].address;    
              m_diag_txrx_seq.item.wr_data == 'h0BAD_0BAD;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);

           //----- READ BACK 
          //  #1us;
           if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_READ;    
              m_diag_txrx_seq.item.address == DIAG_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
          end
   #1.5us;

    end

//------------------------------------------------------
// Check Random READ WRITE - OPERATIONAL 
//------------------------------------------------------
foreach(OPER_REGISTERS[i])
   begin
       m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq%0d", i));
          if(OPER_REGISTERS[i].is_writable == 0)
          begin
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_oper_txrx_seq.item.address == OPER_REGISTERS[i].address;    
              m_oper_txrx_seq.item.wr_data == 'h0BAD_0BAD;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);

           //----- READ BACK 
          //  #1us;
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == TXRX_READ;    
              m_oper_txrx_seq.item.address == OPER_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
          end
   #1.5us;

    end
#1us;
             #100us;
    	phase.drop_objection (this);


   endtask



endclass
