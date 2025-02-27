`ifndef TXRX_SEQ_ITEM_SV
`define TXRX_SEQ_ITEM_SV

// Packet class representing different types of packets
class TXRX_seq_item extends uvm_sequence_item;

    packet_type_t   pkt_type;
    rand rw_type_t  rw_type;
    rand bit        do_wr_fail;
    rand int times_sent_idle;
    rand bit [7:0] start1;
    rand bit [7:0] start2;
    rand bit [7:0] header[$];
    rand bit [7:0] data[$];
    rand bit [7:0] footer[$];
    bit [15:0] crc;
    rand bit valid_crc;
    rand bit valid_start1;
    rand bit valid_start2;
    bit active_package;
    // Configuration fields for header, data, and footer sizes
    int HEADER_SIZE = 1;
    int DATA_SIZE   = 1;
    int FOOTER_SIZE = 1; 

`uvm_object_utils_begin(TXRX_seq_item)
 	`uvm_field_int (HEADER_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_int (DATA_SIZE  ,					UVM_DEFAULT)
 	`uvm_field_int (FOOTER_SIZE  ,					UVM_DEFAULT)
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
    times_sent_idle inside {[1:10]};
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

    // CRC calculation function, including start1 till footer
    function void post_randomize();
        bit [15:0] crc_calc = 0;
        crc_calc = crc_xor(8'h21, crc_calc); // Include Start1 (21)
        crc_calc = crc_xor(8'h43, crc_calc); // Include Start2 (43)
        foreach (header[i]) crc_calc = crc_xor(header[i], crc_calc); // Include Header
        foreach (data[i]) crc_calc = crc_xor(data[i], crc_calc); // Include Data
        foreach (footer[i]) crc_calc = crc_xor(footer[i], crc_calc); // Include Footer
        if(valid_crc)
        crc = crc_calc; // Store calculated CRC value
        else crc = crc_calc+1;
    endfunction

    // XOR-based CRC calculation helper function
    function bit [15:0] crc_xor(bit [7:0] val, bit [15:0] crc);
        return {crc[7:0], val} ^ crc;
    endfunction

    endclass : TXRX_seq_item

`endif





