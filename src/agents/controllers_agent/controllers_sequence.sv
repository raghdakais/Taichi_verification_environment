`ifndef CONTROLLERS_SEQUENCE_SV
`define CONTROLLERS_SEQUENCE_SV

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"


//----------------------------------------------------------------
class controllers_sequence extends uvm_sequence #(controllers_seq_item);
//----------------------------------------------------------------

  `uvm_object_utils(controllers_sequence)
   `uvm_declare_p_sequencer(controllers_sequencer)
 
   rand controllers_seq_item item;

  // Constructor
  function new(string name = "controllers_sequence");
    super.new(name);
    // Generate item transactions
    item = controllers_seq_item::type_id::create("controllers_item");
  endfunction

//----------------------------------------------------------------
  // Main task
   task body();
//----------------------------------------------------------------
   // Raise an objection to keep the test running
 `uvm_info(get_type_name(), "Executing controllers sequence", UVM_LOW)
  
      start_item(item);
      // printing item fields only in UVM_DEBUG Mode
    /////    if (uvm_top.get_report_verbosity_level() >= UVM_DEBUG)
    /////    begin
    /////       $display("Printing Item: ");
    /////       item.print();
    /////    end


      finish_item(item);

  endtask

endclass : controllers_sequence
`endif
