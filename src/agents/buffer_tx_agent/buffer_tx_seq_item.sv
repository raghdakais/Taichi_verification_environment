`ifndef BUFFER_TX_SEQ_ITEM_SV
`define BUFFER_TX_SEQ_ITEM_SV

class buffer_tx_seq_item extends uvm_sequence_item;

 // rand packet_sync_type_e pkt_type;

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

    string item_name = "[BUFFER REQUEST]";
    int HEADER_SIZE = 2;
    int DATA_SIZE   = 8;
    int FOOTER_SIZE = 2; 


  // Constants
  const bit [15:0] fixed_header = 16'hba5e;
  const bit [15:0] fixed_footer = 16'hbeef;

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
     header = new[HEADER_SIZE];
      data = new[DATA_SIZE];
      footer = new[FOOTER_SIZE];
  endfunction

  // Constraints
  constraint fixed_values_c {
    header[1] == fixed_header[7:0];
    header[0] == fixed_header[15:8];

    footer[1] == fixed_footer[7:0];
    footer[0] == fixed_footer[15:8];
  }


   constraint sync_header_data_default_c {
        buf_ptr_address_sig == 'h0;  
         ev_stream =='h0; 
         hd_stream == 'h0;
         uid_reg== 'hBEEF; 
    }

  // Build stream_ctrl from individual bits
  function void post_randomize();
    super.post_randomize();
    // Build stream control byte: [spare(6)][hd_stream][ev_stream]
    stream_ctrl = {spare_bits, hd_stream, ev_stream};
    data[0]  = buf_ptr_address_sig[15:8];
    data[1]  = buf_ptr_address_sig[7:0];
    data[2]  = buf_ptr_address_sig[31:24];
    data[3]  = buf_ptr_address_sig[23:16];
    data[4]  = uid_reg[7:0];
    data[5]  = uid_reg[15:8];
    data[6]  = 8'h00;
    data[7]  = stream_ctrl;
  endfunction

endclass : buffer_tx_seq_item

`endif