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
  static bit [31:0] next_slot_addr = 32'h0;

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
 
      if (!item.allow_random_address)
          item.buf_ptr_address_sig = next_slot_addr;
      else 
         item.buf_ptr_address_sig = 32'h00001080*item.random_address_jump;


    // Build stream control byte: [spare(6)][hd_stream][ev_stream]
    item.stream_ctrl = {'hD,2'h3 , item.hd_stream, item.ev_stream};
  //  stream_ctrl = 'h02;
    item.data[0]  = item.buf_ptr_address_sig[7:0];
    item.data[1]  = item.buf_ptr_address_sig[15:8];
    item.data[2]  = item.buf_ptr_address_sig[23:16];
    item.data[3]  = item.buf_ptr_address_sig[31:24];
    item.data[4]  = item.uid_reg[7:0];
    item.data[5]  = item.uid_reg[15:8];
    item.data[6]  = item.stream_ctrl;
    item.data[7]  = 8'h00;

      start_item(item);
      // printing item fields only in UVM_DEBUG Mode
        if (uvm_top.get_report_verbosity_level() >= UVM_DEBUG)
        begin
           $display("Driver Printing Item: ");
           item.print();
        end
      finish_item(item);
      next_slot_addr += 32'h00001080;
  endtask

endclass : buffer_tx_sequence
`endif
