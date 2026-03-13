`ifndef BUFFER_TX_SEQ_ITEM_SV
`define BUFFER_TX_SEQ_ITEM_SV

class buffer_tx_seq_item extends uvm_sequence_item;

 // rand packet_sync_type_e pkt_type;
  rand packet_buffer_type_e pkt_type;

  bit [7:0] start1 = 8'h21;
  bit [7:0] start2 = 8'h43;

  rand bit [7:0] header[$];
  rand bit [7:0]  data[$];
  rand bit [7:0]  footer[$];

  // Structured fields
  rand bit [31:0] buf_ptr_address_sig;
  rand bit [15:0] uid_reg;

  // New additions
  rand bit ev_stream;               // bit 0
  rand bit hd_stream;               // bit 1
  rand bit [5:0] spare_bits;        // bits 7:2
  bit [7:0] stream_ctrl;            // full control byte, built manually
   static logic [31:0] slot_addr_tracker = 'h0;
   rand logic [31:0] random_address_jump = 'h0;
rand bit   allow_random_address = 0;
rand bit valid_crc =1;
    string item_name = "[BUFFER REQUEST]";
static bit dummy_passed = 0;


  // Constants
  const bit [15:0] fixed_header = 16'hba5e;
  const bit [15:0] fixed_footer = 16'hBEEF;

  // UVM Registration
  `uvm_object_utils_begin(buffer_tx_seq_item)
    `uvm_field_string(item_name, UVM_DEFAULT)
    `uvm_field_int(start1, UVM_DEFAULT)
    `uvm_field_int(start2, UVM_DEFAULT)
    `uvm_field_queue_int(header, UVM_DEFAULT)
    `uvm_field_queue_int(data, UVM_DEFAULT)
    `uvm_field_queue_int(footer, UVM_DEFAULT)
    `uvm_field_int(buf_ptr_address_sig, UVM_DEFAULT)
    `uvm_field_int(uid_reg, UVM_DEFAULT)
    `uvm_field_int(ev_stream, UVM_DEFAULT)
    `uvm_field_int(hd_stream, UVM_DEFAULT)
    `uvm_field_int(spare_bits, UVM_DEFAULT)
    `uvm_field_int(stream_ctrl, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "buffer_tx_seq_item");
    super.new(name);
     header = new[`BUFFER_HEADER_SIZE];
      data = new[`BUFFER_DATA_SIZE];
      footer = new[`BUFFER_FOOTER_SIZE];
  endfunction

  // Constraints
  constraint fixed_values_c {
    header[0] == fixed_header[7:0];
    header[1] == fixed_header[15:8];

    footer[1] == fixed_footer[7:0];
    footer[0] == fixed_footer[15:8];
  }


   constraint sync_header_data_default_c {
      soft   ev_stream =='h1; 
      soft   hd_stream == 'h0;
      soft   uid_reg== 'h0000; 
      soft allow_random_address == 0;
      soft valid_crc == 1'b1;  // Default valid_crc is 1 unless overridden in the test
      soft random_address_jump ==0;

    }

  // Build stream_ctrl from individual bits
  function void post_randomize();
    super.post_randomize();



  endfunction

endclass : buffer_tx_seq_item

`endif