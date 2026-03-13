// UVM test base for taichi_tmb environment

//===============================================================================
class send_syncs_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(send_syncs_test)  // Register with the factory
  int random_address_jump = 1;
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "send_syncs_test", uvm_component parent = null);
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
    event initial_write_done;
    
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
    send_operation_transaction(TXRX_READ, 'h064D0, 'h0); 

send_diagnostical_transaction(TXRX_WRITE, 'h064D0, 'hFFFF_FFFF); 

    //------------------------------------------------------
    // Sending VALID SYNCS
    //------------------------------------------------------
send_sync_burst(4);

#200us;

    	phase.drop_objection (this);
   endtask



endclass
