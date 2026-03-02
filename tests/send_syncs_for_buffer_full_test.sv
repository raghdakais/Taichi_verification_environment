// UVM test base for taichi_tmb environment

//===============================================================================
class send_syncs_for_buffer_full_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(send_syncs_for_buffer_full_test)  // Register with the factory
  rand bit random_package; 
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "send_syncs_for_buffer_full_test", uvm_component parent = null);
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
   
//-------------------------------------------------------


   repeat (2048)
   begin
    random_package = $random;
        send_valid_sync_packet (0); 
        #50us;
        send_valid_sync_packet (1); 
        #50us;
   end

  

        #100us;

    	phase.drop_objection (this);
   endtask

endclass
