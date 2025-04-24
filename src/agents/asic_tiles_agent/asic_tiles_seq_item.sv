`ifndef ASIC_TILES_SEQ_ITEM_SV
`define ASIC_TILES_SEQ_ITEM_SV

//----------------------------------------------------------------
class asic_tiles_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------

    logic TILES_CLK;
    logic TILES_CLK_N;
    logic [3:0] SCLK;
    logic [3:0] SCS1;
    logic [3:0] SCS2;
    logic [3:0] SDI;
    rand logic [3:0] SDO;
    rand logic [3:0] ACO;
    rand logic [3:0] ACO_N;
    rand logic [3:0] DATA1;
    rand logic [3:0] DATA1_N;
    rand logic [3:0] DATA2;
    rand logic [3:0] DATA2_N;
  // Each variable has to be registered with a macro corresponding to its data
  // type. For example, "int" types use `uvm_field int, "enum" types use
  // `uvm_field_enum, and "string" use `uvm_field_string
`uvm_object_utils_begin(asic_tiles_seq_item)
 ////    TODO add later 	`uvm_field_int (address,					UVM_DEFAULT)
 ////    TODO add later 	`uvm_field_int (data   ,					UVM_DEFAULT)
 ////    TODO add later 	`uvm_field_int (valid  ,					UVM_DEFAULT)
`uvm_object_utils_end


  // Constructor
  function new(string name = "asic_tiles_seq_item");
    super.new(name);
  endfunction
endclass : asic_tiles_seq_item

`endif
