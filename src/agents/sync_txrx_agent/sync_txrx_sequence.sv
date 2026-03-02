`ifndef SYNC_TXRX_SEQUENCE_SV
`define SYNC_TXRX_SEQUENCE_SV

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"


//----------------------------------------------------------------
class sync_txrx_sequence extends uvm_sequence #(sync_txrx_seq_item);
//----------------------------------------------------------------

  `uvm_object_utils(sync_txrx_sequence)
   `uvm_declare_p_sequencer(sync_txrx_sequencer)
 
   rand sync_txrx_seq_item item;

  // Constructor
  function new(string name = "sync_txrx_sequence");
    super.new(name);
    // Generate item transactions
    item = sync_txrx_seq_item::type_id::create("sync_txrx_item");
  endfunction

//----------------------------------------------------------------
  // Main task
   task body();
//----------------------------------------------------------------
 
  `uvm_info(get_type_name(), "Executing sync_txrx sequence", UVM_DEBUG)
   // Ensure item is valid before running
    if (item == null) begin
      `uvm_error("TXRX_SEQUENCE", "Sequence item is NULL in body()! Skipping execution.")
      return;
    end
 
      start_item(item);
      // printing item fields only in UVM_DEBUG Mode
        if (uvm_top.get_report_verbosity_level() >= UVM_DEBUG)
        begin
           $display("SYNC TXRX Driver Printing Item: ");
           item.print();
        end
      finish_item(item);

  endtask

endclass : sync_txrx_sequence
`endif
