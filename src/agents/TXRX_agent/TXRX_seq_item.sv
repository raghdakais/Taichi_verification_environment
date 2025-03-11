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
    rand bit [23:0] address;
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

    // CRC calculation function, including start1 till footer
    function void post_randomize();
       bit [15:0] crc_calc = 16'hFFFF; // Initialize CRC with 0xFFFF
    bit [7:0] serial_byte;
    
    // Process each byte in the packet serially (bit by bit)
    crc_calc = nextCRC16_D8(crc_calc, 8'h21); // Start1 (21)
    crc_calc = nextCRC16_D8(crc_calc, 8'h43); // Start2 (43)
    
    foreach (header[i]) begin
        crc_calc = nextCRC16_D8(crc_calc, header[i]); // Header
    end
    
    foreach (data[i]) begin
        crc_calc = nextCRC16_D8(crc_calc, data[i]); // Data
    end
    
    foreach (footer[i]) begin
        crc_calc = nextCRC16_D8(crc_calc, footer[i]); // Footer
    end
    
    if (valid_crc)
        crc = crc_calc; // Store calculated CRC value
    else 
        crc = crc_calc + 1; // Corrupt CRC if valid_crc is false
    endfunction

   // Function to compute next CRC16 value given an 8-bit data and 16-bit current CRC
  static function logic [15:0] nextCRC16_D8(logic [15:0] crc  ,  logic [7:0] data );
    logic [15:0] new_crc;

    new_crc[15] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ 
                  crc[7] ^ crc[6] ^ crc[5] ^ crc[4] ^ crc[3] ^ crc[2] ^ crc[1] ^ crc[0];
    new_crc[14] = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ 
                  crc[6] ^ crc[5] ^ crc[4] ^ crc[3] ^ crc[2] ^ crc[1] ^ crc[0];
    new_crc[13] = data[6] ^ data[7] ^ crc[7] ^ crc[6];
    new_crc[12] = data[5] ^ data[6] ^ crc[6] ^ crc[5];
    new_crc[11] = data[4] ^ data[5] ^ crc[5] ^ crc[4];
    new_crc[10] = data[3] ^ data[4] ^ crc[4] ^ crc[3];
    new_crc[9]  = data[2] ^ data[3] ^ crc[3] ^ crc[2];
    new_crc[8]  = data[1] ^ data[2] ^ crc[2] ^ crc[1];
    new_crc[7]  = data[0] ^ data[1] ^ crc[15] ^ crc[1] ^ crc[0];
    new_crc[6]  = data[0] ^ crc[14] ^ crc[0];
    new_crc[5]  = crc[13];
    new_crc[4]  = crc[12];
    new_crc[3]  = crc[11];
    new_crc[2]  = crc[10];
    new_crc[1]  = crc[9];
    new_crc[0]  = data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5] ^ data[6] ^ data[7] ^ 
                  crc[8] ^ crc[7] ^ crc[6] ^ crc[5] ^ crc[4] ^ crc[3] ^ crc[2] ^ crc[1] ^ crc[0];

    return new_crc;
  endfunction
    endclass : TXRX_seq_item

`endif





