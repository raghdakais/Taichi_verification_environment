`ifndef TXRX_SEQ_ITEM_SV
`define TXRX_SEQ_ITEM_SV

// Packet class representing different types of packets
class TXRX_seq_item extends uvm_sequence_item;

    randc rw_type_t  rw_type;
    randc bit        do_wr_fail;
    randc int times_sent_idle;
    randc bit [7:0] start1;
    randc bit [7:0] start2;
    randc bit [7:0] header[$];
    randc bit [7:0] data[$];
    randc bit [7:0] footer[$];
    randc bit [23:0] address;
    rand bit [31:0] wr_data;
    bit [31:0] rd_data;

    bit [15:0] crc;
    rand bit valid_crc;
    rand bit valid_start1;
    rand bit valid_start2;
    bit active_package;
    // Configuration fields for header, data, and footer sizes
    int HEADER_SIZE = 2;
    int DATA_SIZE   = 4;
    int FOOTER_SIZE = 3; 
    string command;

`uvm_object_utils_begin(TXRX_seq_item)
 	`uvm_field_int (HEADER_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_int (DATA_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_int (FOOTER_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_string (command  ,					UVM_DEFAULT)
 	`uvm_field_int (address  ,					UVM_DEFAULT)
 	`uvm_field_int (wr_data  ,					UVM_DEFAULT)
 	`uvm_field_int (rd_data  ,					UVM_DEFAULT)
 	`uvm_field_int (start1,					UVM_DEFAULT)
 	`uvm_field_int (start2   ,					UVM_DEFAULT)
 	`uvm_field_queue_int (header  ,					UVM_DEFAULT)
 	`uvm_field_queue_int (data  ,					UVM_DEFAULT)
 	`uvm_field_queue_int (footer  ,					UVM_DEFAULT)
 	`uvm_field_int (crc  ,					UVM_DEFAULT)
 	`uvm_field_int (valid_crc  ,					UVM_DEFAULT)
 	`uvm_field_int (valid_start1  ,					UVM_DEFAULT)
 	`uvm_field_int (valid_start2  ,					UVM_DEFAULT)
`uvm_object_utils_end

  //constraint to ensure time_sent_idle has no big values
  constraint times_sent_idle_c {
    times_sent_idle inside {[0:10]};
}
    // Constraint to ensure valid_crc defaults to 1 unless explicitly constrained to 0 in a test
    constraint valid_crc_default_c {
   //     soft valid_crc == 1'b1;  // Default valid_crc is 1 unless overridden in the test
    }
    // Constraint to ensure valid_start1 defaults to 1 unless explicitly constrained to 0 in a test
    constraint valid_start1_default_c {
        soft valid_start1 == 1'b1;  // Default valid_start1 is 1 unless overridden in the test
        soft start1       == 8'h21;  // Default valid_start1 is 1 unless overridden in the test
    }
        // Constraint to ensure valid_start2 defaults to 1 unless explicitly constrained to 0 in a test
    constraint valid_start2_default_c {
        soft valid_start2 == 1'b1;  // Default valid_start2 is 1 unless overridden in the test
        soft start2       == 8'h43;  // Default valid_start1 is 1 unless overridden in the test
    }
        // Constraint to ensure wr_fail defaults to 0 unless explicitly constrained to 0 in a test
    constraint do_wr_fail_default_c {
        soft do_wr_fail == 1'b0;  // Default do_wr_fail is 0 unless overridden in the test
    }


function new(string name = "TXRX_seq_item");
    super.new(name);
     header = new[HEADER_SIZE];  // Resize header to match HEADER_SIZE
     data = new[DATA_SIZE];      // Resize Data to match HEADER_SIZE
     footer = new[FOOTER_SIZE];  // Resize Footer to match HEADER_SIZE
endfunction

    endclass : TXRX_seq_item

`endif





