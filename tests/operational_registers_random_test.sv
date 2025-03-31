// UVM test base for taichi_tmb environment

//===============================================================================
class operational_registers_random_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(operational_registers_random_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "operational_registers_random_test", uvm_component parent = null);
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
// WRITE and READ in parallel - TO OPERATIONAL REGISTER 
//------------------------------------------------------
repeat(10)
 begin
          int i = $urandom_range(OPER_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
        m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq_%0d", i));
           if (!this.m_oper_txrx_seq.randomize() with { 
            //  m_oper_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_oper_txrx_seq.item.wr_data == 'h0BAD_0BAD;  
              m_oper_txrx_seq.item.do_wr_fail == 1;   
              m_oper_txrx_seq.item.address == OPER_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq write operational")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
 #1us;

 end


//------------------------------------------------
// Try to write to diagnostics random addresses
//------------------------------------------------
repeat(10)
begin
        // ----   WRITE  -----//
       int i = $urandom_range(DIAG_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
        m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq_%0d", i));
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_oper_txrx_seq.item.wr_data == 'h0BAD_0BAD;     
              m_oper_txrx_seq.item.address == DIAG_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq write operational")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
 #500ns;
        // ----   READ BACK  -----//
        m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq_%0d", i));
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == TXRX_READ;     
              m_oper_txrx_seq.item.address == DIAG_REGISTERS[i].address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq read operational ")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
 #1.5us;
end

//------------------------------------------------------
// Random READ WRITE 
//------------------------------------------------------
repeat(50)
   begin
        i = $urandom_range(OPER_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
   
   /////   send_txrx_sequence(TXRX_WRITE, i);
   /////   send_txrx_sequence(TXRX_READ, i);

              wr_data = get_random_writing_data(); // Get randomized data

          m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq_%0d", i));
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == TXRX_WRITE;     
              m_oper_txrx_seq.item.address == OPER_REGISTERS[i].address; 
         //     m_oper_txrx_seq.item.address == 'h406660; 
              m_oper_txrx_seq.item.wr_data == wr_data; 
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq random registers")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
#1us;
   m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq_%0d", i));
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == TXRX_READ;     
              m_oper_txrx_seq.item.address == OPER_REGISTERS[i].address;    
        //      m_oper_txrx_seq.item.address == 'h406660; 
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq random registers")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
    #1.5us;
     end
  #1us;
    	phase.drop_objection (this);
   endtask

endclass
