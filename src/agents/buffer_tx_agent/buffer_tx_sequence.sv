`ifndef BUFFER_TX_SEQUENCE_SV
`define BUFFER_TX_SEQUENCE_SV

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"


//----------------------------------------------------------------
class buffer_tx_sequence extends uvm_sequence #(buffer_tx_seq_item);
//----------------------------------------------------------------

  `uvm_object_utils(buffer_tx_sequence)
   `uvm_declare_p_sequencer(buffer_tx_sequencer)
 
   rand buffer_tx_seq_item item;

  // Constructor
  function new(string name = "buffer_tx_sequence");
    super.new(name);
    // Generate item transactions
    item = buffer_tx_seq_item::type_id::create("buffer_tx_item");
  endfunction

//----------------------------------------------------------------
  // Main task
   task body();
//----------------------------------------------------------------
 
 `uvm_info(get_type_name(), "Executing buffer_tx sequence", UVM_LOW)
   // Ensure item is valid before running
    if (item == null) begin
      `uvm_error("TXRX_SEQUENCE", "Sequence item is NULL in body()! Skipping execution.")
      return;
    end
 
      start_item(item);
      // printing item fields only in UVM_DEBUG Mode
        if (uvm_top.get_report_verbosity_level() >= UVM_DEBUG)
        begin
           $display("Driver Printing Item: ");
           item.print();
        end
      finish_item(item);
  endtask

endclass : buffer_tx_sequence
`endif
