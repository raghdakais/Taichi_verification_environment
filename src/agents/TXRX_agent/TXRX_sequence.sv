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
   
endfunction


 extern virtual  task  body();

endclass : TXRX_sequence


  //--------------------------------------------------------
   task TXRX_sequence::body();
 //------------------------------------------------------------
 `uvm_info(get_type_name(), "Executing TXRS sequence", UVM_DEBUG)

   // Ensure item is valid before running
    if (item == null) begin
      `uvm_error("TXRX_SEQUENCE", "Sequence item is NULL in body()! Skipping execution.")
      return;
    end
    
      start_item(item);
      finish_item(item);
  endtask



`endif
