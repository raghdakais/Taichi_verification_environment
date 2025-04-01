`ifndef ASIC_TILES_SEQUENCE_SV
`define ASIC_TILES_SEQUENCE_SV

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"


//----------------------------------------------------------------
class asic_tiles_sequence extends uvm_sequence #(asic_tiles_seq_item);
//----------------------------------------------------------------

  `uvm_object_utils(asic_tiles_sequence)
   `uvm_declare_p_sequencer(asic_tiles_sequencer)
 
   rand asic_tiles_seq_item item;

  // Constructor
  function new(string name = "asic_tiles_sequence");
    super.new(name);
    // Generate item transactions
    item = asic_tiles_seq_item::type_id::create("asic_tiles_item");
  endfunction

//----------------------------------------------------------------
  // Main task
   task body();
//----------------------------------------------------------------
 
 `uvm_info(get_type_name(), "Executing asic_tiles sequence", UVM_LOW)
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

endclass : asic_tiles_sequence
`endif
