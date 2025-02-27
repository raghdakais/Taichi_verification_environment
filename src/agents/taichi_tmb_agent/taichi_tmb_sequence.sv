`ifndef TAICHI_TMB_SEQUENCE_SV
`define TAICHI_TMB_SEQUENCE_SV

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"


class taichi_tmb_sequence extends uvm_sequence #(taichi_tmb_seq_item);

  `uvm_object_utils(taichi_tmb_sequence)
  `uvm_declare_p_sequencer (taichi_tmb_sequencer)

   rand taichi_tmb_seq_item item;

  // Constructor
  function new(string name = "m_taichi_tmb_sequence");
    super.new(name);
        item = taichi_tmb_seq_item::type_id::create("m_taichi_tmb_seq_item");

 endfunction

 
 extern virtual  task  body();
 

endclass : taichi_tmb_sequence

 // Main task
   task taichi_tmb_sequence::body();

 `uvm_info(get_type_name(), "Executing TXRS sequence", UVM_LOW)
   // Ensure item is valid before running
    if (item == null) begin
      `uvm_error("TXRX_SEQUENCE", "Sequence item is NULL in body()! Skipping execution.")
      return;
    end
      start_item(item);
      // printing item fields
        if (uvm_top.get_report_verbosity_level() >= UVM_DEBUG)
        begin
           $display("Printing Item: ");
           item.print();
        end
      finish_item(item);
  endtask



`endif
