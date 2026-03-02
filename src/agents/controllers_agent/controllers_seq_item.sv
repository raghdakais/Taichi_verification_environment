`ifndef CONTROLLERS_SEQ_ITEM_SV
`define CONTROLLERS_SEQ_ITEM_SV

//----------------------------------------------------------------
class controllers_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------

// [EXAMPLE:]
  rand bit [`ADDR_WIDTH - 1 :0] address; // Address
  rand bit [`DATA_WIDTH - 1 :0] data; // Data
  rand bit valid;       // Write flag

 // inputs
   rand bit       Sig_2         ; 
   bit            Master_Slave  ;  // const - must be 0 - master mode
   rand bit [3:0] HW_REV        ;
   rand bit       PGOOD_0_75V   ; 
   rand bit       PGOOD_1_0V    ;
   rand bit       PGOOD_1_5V    ;
   rand bit       PGOOD_1_8V    ;
   rand bit       PGOOD_P1_5V   ; 
   rand bit       PGOOD_2_5V    ; 
   // outputs
   bit [7:0] DEBUG_TP      ;
   bit [1:0] STATUS_LEDS   ; 
   bit       DISABLE_CLK0n ;
   bit       DISABLE_CLK1n ;
   bit       DISABLE_SLAVEn; 
   bit       DISABLE_APOSn ; 
   bit       DISABLE_ANEGn ; 
   bit       HEATER_1      ; 
   bit       HEATER_2      ; 


 rand bit sig2_soft_reset; // Reconstructed 8-bit byte
 rand bit sig2_ch_rdy; // Reconstructed 8-bit byte

    // Constraint to ensure valid_start1 defaults to 1 unless explicitly constrained to 0 in a test
    constraint valid_start1_default_c {
        soft sig2_soft_reset == 0;  // Default valid_start1 is 1 unless overridden in the test
        soft sig2_ch_rdy       == 1;  // Default valid_start1 is 1 unless overridden in the test
    }

  // Each variable has to be registered with a macro corresponding to its data
  // type. For example, "int" types use `uvm_field int, "enum" types use
  // `uvm_field_enum, and "string" use `uvm_field_string
`uvm_object_utils_begin(controllers_seq_item)
 	`uvm_field_int (address,					UVM_DEFAULT)
 	`uvm_field_int (data   ,					UVM_DEFAULT)
 	`uvm_field_int (valid  ,					UVM_DEFAULT)
`uvm_object_utils_end


  // Constructor
  function new(string name = "controllers_seq_item");
    super.new(name);
  endfunction
endclass : controllers_seq_item

`endif
