// UVM test base for taichi_tmb environment

//===============================================================================
class sending_frame_data_Mu_off_test extends taichi_tmb_test_base;
//===============================================================================
    // Testbench configuration and stimulus generation
       `uvm_component_utils(sending_frame_data_Mu_off_test)  // Register with the factory
  
rand int i = 0;
 bit [31:0] wr_data ;
        // This is standard code for all components
    function new (string name = "sending_frame_data_Mu_off_test", uvm_component parent = null);
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

            #500ns;


        active_Mu_functional(0);
#3us;
        send_valid_sync_packet (SYNC_IP); 

        #50us;
        send_valid_sync_packet (SYNC_HEADER); 


   

#80us;

    	phase.drop_objection (this);
   endtask

endclass
