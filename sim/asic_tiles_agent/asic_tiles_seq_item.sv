`ifndef ASIC_TILES_SEQ_ITEM_SV
`define ASIC_TILES_SEQ_ITEM_SV

//----------------------------------------------------------------
class asic_tiles_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------

// [EXAMPLE:]
  rand bit [`ADDR_WIDTH - 1 :0] address; // Address
  rand bit [`DATA_WIDTH - 1 :0] data; // Data
  rand bit valid;       // Write flag

  // Each variable has to be registered with a macro corresponding to its data
  // type. For example, "int" types use `uvm_field int, "enum" types use
  // `uvm_field_enum, and "string" use `uvm_field_string
`uvm_object_utils_begin(asic_tiles_seq_item)
 	`uvm_field_int (address,					UVM_DEFAULT)
 	`uvm_field_int (data   ,					UVM_DEFAULT)
 	`uvm_field_int (valid  ,					UVM_DEFAULT)
`uvm_object_utils_end


  // Constructor
  function new(string name = "asic_tiles_seq_item");
    super.new(name);
  endfunction
endclass : asic_tiles_seq_item

`endif
