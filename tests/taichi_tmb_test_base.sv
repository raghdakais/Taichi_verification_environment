// UVM test base for taichi_tmb environment

class taichi_tmb_test_base extends uvm_test;
    // Testbench configuration and stimulus generation
    taichi_tmb_env m_taichi_tmb_env;
    
   	TXRX_sequence m_diag_txrx_seq;
   	TXRX_sequence m_oper_txrx_seq;
    controllers_sequence m_controllers_seq;
     sync_txrx_sequence m_sync_txrx_seq;
     buffer_tx_sequence m_buffer_tx_sequence;
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
        m_buffer_tx_sequence = buffer_tx_sequence::type_id::create ("m_buffer_tx_sequence");
 
 
    endfunction

 //  [Recommended] start a sequence for this particular test
    task run_phase (uvm_phase phase);    
   	super.run_phase(phase);


//--------------------------------------------------------
// sending a syncronization sequence for sig 2 signal
//--------------------------------------------------------
         if (!this.m_controllers_seq.randomize() with { 
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_controllers_seq")
           this.m_controllers_seq.start(this.m_taichi_tmb_env.m_controllers_agent.seqr);

#5us;


config_asic();

   endtask







    //=====================================================================================
      task send_valid_sync_packet (packet_sync_type_e pkt_type);    
    //=====================================================================================
           if (!this.m_sync_txrx_seq.randomize() with { 
              m_sync_txrx_seq.item.pkt_type ==pkt_type;
                 }) 
              `uvm_fatal("RUN_PHASE", "Randomization failed for m_sync_txrx_seq")
             this.m_sync_txrx_seq.start(this.m_taichi_tmb_env.m_sync_txrx_agent.seqr);
  
      endtask
 
    //=====================================================================================
    virtual task active_Mu_functional(bit on );
    //=====================================================================================
        m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq"));
        if (m_oper_txrx_seq == null)
            `uvm_fatal("RUN_PHASE", "Failed to create TXRX_sequence instance");
    
        if (!this.m_oper_txrx_seq.randomize() with {
            m_oper_txrx_seq.item.rw_type == TXRX_WRITE;
            m_oper_txrx_seq.item.address == OPER_REGISTERS[5].address;    // h406700  -- Mu ON/OFF
            m_oper_txrx_seq.item.wr_data[0] == on;
        })
            `uvm_fatal("RUN_PHASE", "Randomization failed for TXRX_sequence");
    
        this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
    endtask



 //=====================================================================================
  // Function to generate values to hit coverage bins
       function bit [31:0] get_random_writing_data();
//=====================================================================================
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
  // Function to generate values to hit coverage bins
       task send_operation_transaction(rw_type_t  rw_type, bit[23:0] address, bit [31:0]  data );
//=====================================================================================
          //    int i = $urandom_range(OPER_REGISTERS.size() - 1, 0); // Generate a random index between 0 and size-1
        m_oper_txrx_seq = TXRX_sequence::type_id::create($sformatf("m_oper_txrx_seq"));
           if (!this.m_oper_txrx_seq.randomize() with { 
              m_oper_txrx_seq.item.rw_type == rw_type;     
              m_oper_txrx_seq.item.wr_data == data;  
              m_oper_txrx_seq.item.address == address;    
               }) 
            `uvm_fatal("RUN_PHASE", "Randomization failed for m_oper_txrx_seq write operational")
           this.m_oper_txrx_seq.start(this.m_taichi_tmb_env.oper_txrx_agent.seqr);
 #1.5us;

       endtask

 //=====================================================================================
 task config_asic();
 //=====================================================================================
        send_operation_transaction(TXRX_WRITE, 'h015040, 'h40); // Select 64 Slices
        send_operation_transaction(TXRX_WRITE, 'h046700, 'hBF173); // Data Format: Mu - No Offset Adding
        send_operation_transaction(TXRX_WRITE, 'h046780, 'hA); // Enable Broadcast write Mode to Asics
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80100003); // Asic: Clock Div = 3 (CLK=160Mhz/(3+1)=40Mhz) // TODO : check with Miki randomization
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80122D60); // Asic: 40bit per word  // TODO : check with Miki randomization
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h801F0355); // Asic: Pads Configuration Register 2 - consider reviewing
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80132211); // Asic: LVDS Start Word 0
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80140866); // Asic: LVDS Start Word 1
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80150155); // Asic: LVDS Start Word 2
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80160098); // Asic: LVDS Configuration Register 2 (start_delay)
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80170000); // Asic: LVDS Configuration Register 3 (Start Delay, Scrambler, RAW DATA, Footer)
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80202200); // Asic: Test Pattern Register 0
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80210866); // Asic: Test Pattern Register 1
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80220011); // Asic: Test Pattern Register 2
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h80531000); // Asic: Calibration Configuration Register 0 (Single capacitor array sampling)
        send_operation_transaction(TXRX_WRITE, 'h046750, 'h4); // Turn Module LEDs OFF
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h801A000E); // Asic: Footer 3 Contents 1 (Power Monitor Register)
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h801B0017); // Asic: Footer 4 Contents 2 (LVDS Configuration Register 3) - can be changed
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h801C0058); // Asic: Footer 5 Contents 3 (Calibration Monitor Register)
        send_operation_transaction(TXRX_WRITE, 'h046650, 'h801D0022); // Asic: Footer 6 Contents 4 (Test Pattern 2 register)
        send_operation_transaction(TXRX_WRITE, 'h0467E0, 'h4); // Disable Asics Data Aligning
        send_operation_transaction(TXRX_WRITE, 'h0467E0, 'h5); // Enable Asics Data Aligning
        send_operation_transaction(TXRX_WRITE, 'h046790, 'h3); // Clear CRC Errors, Non-Mu Data Output bits[16..1]
        send_operation_transaction(TXRX_WRITE, 'h046790, 'h1); // Stop Clear CRC Errors, Non-Mu Data Output bits[16..1]
        send_operation_transaction(TXRX_WRITE, 'h046730, 'h0); // Clear Calibration Status
        send_operation_transaction(TXRX_WRITE, 'h046730, 'h8007); // Start automatic Calibrations sequence for Offset Current, Offset Voltage, Linearity
     ///----------------------- Wait    3 Sec     ---------------------------------
     ///----------------------- STOP IP	 60ms     ---------------------------------
     ///   send_operation_transaction(TXRX_WRITE, 'h015204, 'h2); // Reset Transceiver
     ///   send_operation_transaction(TXRX_WRITE, 'h015204, 'h0); // Stop Reset Transceiver
     ///   send_operation_transaction(TXRX_WRITE, 'h015204, 'h1); // Request Resetting Communication FIFOs
     ///   send_operation_transaction(TXRX_WRITE, 'h015204, 'h0); // Stop Requesting Resetting Communication FIFOs
#60us;
 endtask

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
