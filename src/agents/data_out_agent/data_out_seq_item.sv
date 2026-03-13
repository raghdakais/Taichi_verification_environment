`ifndef DATA_OUT_SEQ_ITEM_SV
`define DATA_OUT_SEQ_ITEM_SV

//----------------------------------------------------------------
class data_out_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------

bit [7:0]   header_buffer[$];
byte   data_buffer[$];
byte   footer_buffer[$];
int data_out_packet_size;
bit [15:0] actual_header_sync;
       byte start1, start2;
 bit [15:0]  ct_type;  


  // Each variable has to be registered with a macro corresponding to its data
  // type. For example, "int" types use `uvm_field int, "enum" types use
  // `uvm_field_enum, and "string" use `uvm_field_string
`uvm_object_utils_begin(data_out_seq_item)
 	`uvm_field_int (data_out_packet_size,					UVM_DEFAULT)
`uvm_object_utils_end


  // Constructor
  function new(string name = "data_out_seq_item");
    super.new(name);
  endfunction
endclass : data_out_seq_item

`endif
