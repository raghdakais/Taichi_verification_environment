`ifndef TXRX_SEQUENCE_SV
`define TXRX_SEQUENCE_SV

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  //--------------------------------------------------------
class TXRX_sequence extends uvm_sequence #(TXRX_seq_item);
  //--------------------------------------------------------

  `uvm_object_utils(TXRX_sequence)
  `uvm_declare_p_sequencer(TXRX_sequencer)
   rand TXRX_seq_item item;
   TXRX_config cfg;            // Configuration object

  // Constructor
  function new(string name = "TXRX_sequence");
    super.new(name);
     item = TXRX_seq_item::type_id::create("TXRX_item");


   ///////      // Get configuration from config_db
   ///////       if (!uvm_config_db#(TXRX_config)::get("", "", "cfg", cfg)) begin
   ///////           uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual TXRX_agent_cfg interface not found for TXRX agent"));
   ///////       end
   ///////         item.HEADER_SIZE = cfg.HEADER_SIZE;
   ///////         item.DATA_SIZE   = cfg.DATA_SIZE;
   ///////         item.FOOTER_SIZE = cfg.FOOTER_SIZE;
   ///////       `uvm_info("TXRX_SEQUENCE", $sformatf("Pre-start: Assigned HEADER_SIZE=%0d, DATA_SIZE=%0d, FOOTER_SIZE=%0d",
   ///////                                             item.HEADER_SIZE, item.DATA_SIZE, item.FOOTER_SIZE), UVM_LOW)
   ///////   $stop;
    endfunction


 extern virtual  task  body();

endclass : TXRX_sequence


  //--------------------------------------------------------
   task TXRX_sequence::body();
 //------------------------------------------------------------
 `uvm_info(get_type_name(), "Executing TXRS sequence", UVM_LOW)

   // Ensure item is valid before running
    if (item == null) begin
      `uvm_error("TXRX_SEQUENCE", "Sequence item is NULL in body()! Skipping execution.")
      return;
    end
      start_item(item);
        // printing item fields only in UVM_DEBUG Mode
        if (uvm_top.get_report_verbosity_level() >= UVM_DEBUG)
        begin
           $display("Driver Printing %s Item: ",this.get_type_name);
           item.print();
        end

      finish_item(item);
  endtask



`endif
