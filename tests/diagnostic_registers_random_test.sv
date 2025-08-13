// UVM test base for taichi_tmb environment

//===============================================================================
class diagnostic_registers_random_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(diagnostic_registers_random_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "diagnostic_registers_random_test", uvm_component parent = null);
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



#500ns;


//------------------------------------------------------
// WRITE and READ in parallel - TO Diagnostical REGISTER 
//------------------------------------------------------
repeat(2)
 begin
          int i = $urandom_range(DIAG_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
        m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq%0d", i));
           if (!this.m_diag_txrx_seq.randomize() with { 
            //  m_diag_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_diag_txrx_seq.item.wr_data == 'h900D_900D;  
              m_diag_txrx_seq.item.do_wr_fail == 1;   
              m_diag_txrx_seq.item.address == DIAG_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq write operational")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
 #500ns;
 end

//------------------------------------------------------
// WRITE to invalid address 
//------------------------------------------------------
repeat(2)
 begin
          int i = $urandom_range(DIAG_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
        m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq%0d", i));
           if (!this.m_diag_txrx_seq.randomize() with { 
            //  m_diag_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_diag_txrx_seq.item.wr_data == 'h900D_900D;  
              m_diag_txrx_seq.item.address >= 'h00FF;    
              m_diag_txrx_seq.item.address <= 'h0FFF;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq write operational")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
 #500ns;
 end



//------------------------------------------------
// Try to write to operational  addresses
//------------------------------------------------
repeat(3)
begin
        // ----   WRITE  -----//
       int i = $urandom_range(OPER_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
        m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq_%0d", i));
           if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_diag_txrx_seq.item.wr_data == 'hBAD0_0BAD;     
              m_diag_txrx_seq.item.address == OPER_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq write operational")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
 #500ns;
        // ----   READ BACK  -----//
        m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq_%0d", i));
           if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_READ;     
              m_diag_txrx_seq.item.address == OPER_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq read operational ")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
 #1.5us;
end


//------------------------------------------------------
// Random READ WRITE to Diagnostical
//------------------------------------------------------
repeat(50)
   begin
        i = $urandom_range(DIAG_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
              wr_data = get_random_writing_data(); // Get randomized data

          m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq_%0d", i));
           if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_diag_txrx_seq.item.address == DIAG_REGISTERS[i].address; 
           //   m_diag_txrx_seq.item.address == 'h406420; 
              m_diag_txrx_seq.item.wr_data == wr_data; 
         //     m_diag_txrx_seq.item.wr_data == 'hFACE_BEEF; 
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq random registers")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
#1us;
   m_diag_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_diag_txrx_seq_%0d", i));
           if (!this.m_diag_txrx_seq.randomize() with { 
              m_diag_txrx_seq.item.rw_type == TXRX_READ;     
              m_diag_txrx_seq.item.address == DIAG_REGISTERS[i].address;    
  //            m_diag_txrx_seq.item.address == 'h406420;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_diag_txrx_seq random registers")
           this.m_diag_txrx_seq.start(this.m_taichi_tmb_env.diag_txrx_agent.seqr);
    #1.5us;
     end

  #1us;
    	phase.drop_objection (this);
   endtask

endclass
