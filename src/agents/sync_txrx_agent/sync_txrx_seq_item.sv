`ifndef SYNC_TXRX_SEQ_ITEM_SV
`define SYNC_TXRX_SEQ_ITEM_SV

//----------------------------------------------------------------
class sync_txrx_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------


    rand packet_type_e pkt_type;
     bit [7:0] start1 ='h21 ;
     bit [7:0] start2_ip = 'h1B ;
     bit [7:0] start2_header = 'h43 ;
    rand bit [7:0]  ip_data;
    rand bit [7:0] header[$];
    rand bit [7:0] data[$];
    rand bit [7:0] footer[$];

    bit [15:0] crc;
    rand bit ip_valid_crc;
    rand bit header_valid_crc;
    rand int delay;
    // Configuration fields for header, data, and footer sizes
    int HEADER_SIZE = 2;
    int DATA_SIZE   = 128;
    int FOOTER_SIZE = 12; 
    string command;
    rand bit [15:0] header_data[HEADER_DATA_SIZE];


    

`uvm_object_utils_begin(sync_txrx_seq_item)
 	`uvm_field_int (HEADER_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_int (DATA_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_int (FOOTER_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_string (command  ,					UVM_DEFAULT)
 	`uvm_field_int (start1,					UVM_DEFAULT)
 	`uvm_field_int (start2_ip   ,					UVM_DEFAULT)
 	`uvm_field_int (start2_header   ,					UVM_DEFAULT)
 	`uvm_field_queue_int (header  ,					UVM_DEFAULT)
 	`uvm_field_queue_int (data  ,					UVM_DEFAULT)
 	`uvm_field_queue_int (footer  ,					UVM_DEFAULT)
 	`uvm_field_int (crc  ,					UVM_DEFAULT)
 	`uvm_field_int (ip_valid_crc  ,					UVM_DEFAULT)
 	`uvm_field_int (header_valid_crc  ,					UVM_DEFAULT)
`uvm_object_utils_end


    // Constraint to ensure valid_crc defaults to 1 unless explicitly constrained to 0 in a test
    constraint sync_valid_crc_default_c {
        soft ip_valid_crc == 1'b1;  // Default valid_crc is 1 unless overridden in the test
        soft header_valid_crc == 1'b1;  // Default valid_crc is 1 unless overridden in the test
    }
  // Constructor
  function new(string name = "sync_txrx_seq_item");
    super.new(name);
     header = new[HEADER_SIZE];  // Resize header to match HEADER_SIZE
     data = new[DATA_SIZE];      // Resize Data to match HEADER_SIZE
     footer = new[FOOTER_SIZE];  // Resize Footer to match HEADER_SIZE
  endfunction
endclass : sync_txrx_seq_item



`endif
