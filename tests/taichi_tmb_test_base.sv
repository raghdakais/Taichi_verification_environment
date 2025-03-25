// UVM test base for taichi_tmb environment

class taichi_tmb_test_base extends uvm_test;
    // Testbench configuration and stimulus generation
    taichi_tmb_env m_taichi_tmb_env;
    
   	TXRX_sequence m_diag_txrx_seq;
   	TXRX_sequence m_oper_txrx_seq;
    controllers_sequence m_controllers_seq;
     sync_txrx_sequence m_sync_txrx_seq;
     bit test_failed = 0;       

        // This is standard code for all components
    function new (string name = "taichi_tmb_test_base", uvm_component parent = null);
      super.new (name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        this.m_taichi_tmb_env  = taichi_tmb_env::type_id::create("m_taichi_tmb_env", this);
       // creating sequences
        m_controllers_seq = controllers_sequence::type_id::create ("m_controllers_seq");
        m_diag_txrx_seq = TXRX_sequence::type_id::create ("m_diag_txrx_seq");
        m_oper_txrx_seq = TXRX_sequence::type_id::create ("m_oper_txrx_seq");
        m_sync_txrx_seq = sync_txrx_sequence::type_id::create ("m_sync_txrx_seq");
 
 
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

#5us;
   endtask


      task send_valid_ip_sync ();    
           if (!this.m_sync_txrx_seq.randomize() with { 
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
  
      endtask
 

////    //=====================================================================================
////    virtual function void send_txrx_sequence(bit rw, int index, bit [31:0] data = 'h0BAD_0BAD);
////    //=====================================================================================
////        m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq_%0d", index));
////        if (m_oper_txrx_seq == null)
////            `uvm_fatal("RUN_PHASE", "Failed to create TXRX_sequence instance");
////    
////        if (!this.m_oper_txrx_seq.randomize() with {
////            m_oper_txrx_seq.item.rw_type -> rw;
////            m_oper_txrx_seq.item.address -> OPER_REGISTERS[index].address;
////      //      if (rw == TXRX_WRITE)
////      //           m_oper_txrx_seq.item.wr_data -> data;
////        })
////            `uvm_fatal("RUN_PHASE", "Randomization failed for TXRX_sequence");
////    
////        this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
////    endfunction



  // Function to generate values to hit coverage bins
    function bit [31:0] get_random_writing_data();
        case ($urandom_range(0, 6))
            0: return 32'h0000_0000; // all_zeros
            1: return 32'hFFFF_FFFF; // all_ones
            2: return 32'hAAAA_AAAA; // alt_bits
            3: return 32'h5555_5555; // alt_bits
            4: return (1 << $urandom_range(0, 31)); // one_bit_hit
            5: return ~(1 << $urandom_range(0, 31)); // one_bit_cold
            default: return $urandom(); // random_data
        endcase
    endfunction


//=====================================================================================
	function void report_phase(uvm_phase phase);
//=====================================================================================
   		uvm_report_server svr;
   		super.report_phase(phase);
    		svr = uvm_report_server::get_server();
 
	if(svr.get_severity_count(UVM_FATAL)+svr.get_severity_count(UVM_ERROR)>0) 
		begin
     			$display("\033[31m-----------------------------------------\033[0m");
     			$display("\033[41m----          [TEST FAILED]          ----\033[0m");
     			$display("\033[31m-----------------------------------------\033[0m");
    		end
   else 
		begin
     			 $display("\033[32m---------------------------------------\033[0m");
     			 $display("\033[42m----         [TEST PASSED]         ----\033[0m");
     			 $display("\033[32m---------------------------------------\033[0m");
    		end
  	endfunction 


endclass
