`ifndef DATA_OUT_SEQ_ITEM_SV
`define DATA_OUT_SEQ_ITEM_SV

//----------------------------------------------------------------
class data_out_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------

byte   header_buffer[$];
int data_out_packet_size;
  // Each variable has to be registered with a macro corresponding to its data
  // type. For example, "int" types use `uvm_field int, "enum" types use
  // `uvm_field_enum, and "string" use `uvm_field_string
`uvm_object_utils_begin(data_out_seq_item)
/// 	`uvm_field_int (header_buffer,					UVM_DEFAULT)
`uvm_object_utils_end


  // Constructor
  function new(string name = "data_out_seq_item");
    super.new(name);
  endfunction
endclass : data_out_seq_item

`endif
