`ifndef SYNC_TXRX_SEQ_ITEM_SV
`define SYNC_TXRX_SEQ_ITEM_SV

//----------------------------------------------------------------
class sync_txrx_seq_item extends uvm_sequence_item;
//----------------------------------------------------------------


    rand packet_sync_type_e pkt_type;
     bit [7:0] start1 ='h21 ;
     bit [7:0] start2_ip = 'h1B ;
     bit [7:0] start2_header = 'h43 ;
    rand bit [7:0]  ip_data;
    rand bit [7:0] header_header[$];
    bit [7:0] header_data[$];
    rand bit [7:0] footer[$];

    bit [15:0] crc;
    rand bit ip_valid_crc;
    rand bit header_valid_crc;
    rand int delay;
    // Configuration fields for header, data, and footer sizes

    string command;
    int HEADER_SIZE = 2;
    int IP_DATA_SIZE   = 1;
    int HEADER_DATA_SIZE   = 128;
    int FOOTER_SIZE = 12; 

    byte  header_buffer[$];
    int item_id=0;
    bit [15:0] expected_data_out_fifo[$];
    bit [15:0] expected_data_out;
// Making HEADER key values random for control in driver
    rand bit [15:0] CT_TYPE;
    rand bit [7:0] slices_num;
    rand bit [15:0] dms_status_i;
    rand bit [15:0] INTEGRATION_TIME_IN_REG;
    rand bit [15:0] REFERENCE_DETECTOR;
    rand bit [15:0] READING_NUMBER_REG;
    rand bit [3:0] DFS; // Single-bit value at position 3
    rand bit [31:0] TIME_STAMP_LOW;
    string pkt_type_= "SYNC -  NO TYPE";

    // New Footer Fields
    rand bit [31:0] slot_pointer_address;  // Bytes 0..3
    rand bit [31:0] hd_pointer_address;  // Bytes 0..3
    rand bit [7:0] merging_factor;            // Bytes 4..5
    rand bit [7:0] focal_spot_merging_factor;
    rand bit [7:0] stream_type;            // Byte 6 (Bits 49 - HD, 48 - RLT)
    rand bit fq_stream_enable;
    rand bit [7:0] fs_sequence_counter;            // Byte 6 (Bits 49 - HD, 48 - RLT)
   static logic [31:0] slot_addr_tracker = 'h0;
   rand int random_address_jump = 'h0;
rand bit   allow_random_address;
static bit dummy_passed = 0;
rand bit request_last_address = 0;
rand bit allow_lost_B5;

`uvm_object_utils_begin(sync_txrx_seq_item)
 	`uvm_field_string (pkt_type_  ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
      	`uvm_field_int (HEADER_SIZE  ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
      	`uvm_field_int (HEADER_DATA_SIZE  ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
      	`uvm_field_int (FOOTER_SIZE  ,					UVM_DEFAULT)
 	  `uvm_field_int (start1,					UVM_DEFAULT)
    if (pkt_type == SYNC_IP)
    	`uvm_field_int (start2_ip   ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
 	`uvm_field_int (start2_header   ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
 	`uvm_field_queue_int (header_header  ,					UVM_DEFAULT)
    if (pkt_type == SYNC_IP)
    	`uvm_field_int (ip_data  ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
  	`uvm_field_queue_int (header_data  ,					UVM_DEFAULT)
     if (pkt_type == SYNC_HEADER)
 	`uvm_field_queue_int (footer  ,					UVM_DEFAULT)
 	`uvm_field_int (crc  ,					UVM_DEFAULT)
 	`uvm_field_int (ip_valid_crc  ,					UVM_DEFAULT)
 	`uvm_field_int (header_valid_crc  ,					UVM_DEFAULT)

      // Adding randomized fields
      if (pkt_type == SYNC_HEADER)begin
  //      `uvm_field_string ("-------- HEADER FIELDS --------", UVM_DEFAULT)
         `uvm_field_int (CT_TYPE, UVM_DEFAULT)
        `uvm_field_int (dms_status_i, UVM_DEFAULT)
        `uvm_field_int (INTEGRATION_TIME_IN_REG, UVM_DEFAULT)
        `uvm_field_int (REFERENCE_DETECTOR, UVM_DEFAULT)
        `uvm_field_int (READING_NUMBER_REG, UVM_DEFAULT)
        `uvm_field_int (DFS, UVM_DEFAULT)
        `uvm_field_int (TIME_STAMP_LOW, UVM_DEFAULT)
   //     `uvm_field_string ("-------- FOOTER FIELDS--------", UVM_DEFAULT)
        `uvm_field_int (slot_pointer_address, UVM_DEFAULT)
        `uvm_field_int (stream_type, UVM_DEFAULT)
      end
`uvm_object_utils_end

  // Function to initialize Footer Data
    function void init_footer();
        footer = new[FOOTER_SIZE];

        // Storing footer fields
        footer[0] = slot_pointer_address[7:0]; // High byte
        footer[1] = slot_pointer_address[15:8];
        footer[2] = slot_pointer_address[23:16];
        footer[3] = slot_pointer_address[31:24];   // Low byte
        // Storing footer fields
        footer[4] = hd_pointer_address[7:0]; // High byte
        footer[5] = hd_pointer_address[15:8];
        footer[6] = hd_pointer_address[23:16];
        footer[7] = hd_pointer_address[31:24];   // Low byte
      
        footer[8]  = merging_factor;
        footer[9]  = focal_spot_merging_factor;
        footer[10][0]  = fq_stream_enable;
        footer[11][0]  =  fs_sequence_counter;

        // TODO REMOVE LATER footer[11]  =  fs_sequence_counter;

//        footer[6] = stream_type;  // Stream type field

    endfunction

 // Function to initialize data values
    function void init_data_header();
        // Storing 16-bit values as two bytes each
        store_word(0,  CT_TYPE);
        store_word(2,  dms_status_i);
        store_word(4,  0);  // TODO - add dms error
        store_word(6,  INTEGRATION_TIME_IN_REG);
        store_word(8,  REFERENCE_DETECTOR);
        store_word(16, READING_NUMBER_REG);  
        store_word(40, {5'b00000, DFS}); // Bit [3] set to DFS
        store_word(48, 16'hBEEF); // UID
        store_word(56, TIME_STAMP_LOW[31:16]);
        store_word(58, TIME_STAMP_LOW[15:0]);
        store_word(60, 16'h04A0); // Number of Detectors
        store_word(74, 16'h0302); // DMS Type
        //    for (int i = 76; i <112 ; i=i+2 )
        //        store_word(i,  'h0);
        store_word(112, READING_NUMBER_REG);
          //          for (int i = 114; i <124 ; i=i+2 )
          //      store_word(i,  'h0);
        store_word(122, 16'h06d7); 
        store_word(124, 16'hb500); 

        store_word(126, 16'hFACE); // Final Stamp

        // Fill uninitialized slots with zero
        foreach (header_data[i]) begin
            if (header_data[i] === 'x) header_data[i] = 8'h00;
        end
    endfunction

function void store_word(int index, bit [15:0] value);
    if ((index >= 0) && (index + 1 < header_data.size())) begin
        header_data[index]   = value[7:0];
        header_data[index+1] = value[15:8];
    end
    else begin
        `uvm_fatal("STORE_WORD",
          $sformatf("Out-of-range write in store_word: index=%0d size=%0d",
                    index, header_data.size()))
    end
endfunction

    // Ensure pkt_type_ is set correctly based on pkt_type
    function void post_randomize();
     if (pkt_type == SYNC_IP) begin
         pkt_type_ = "[SYNC - IP_PACKET]";
    end
    else if (pkt_type == SYNC_HEADER) begin
        pkt_type_ = "[SYNC - HEADER_PACKET]";

    end
          
    endfunction

     // Constraint to ensure valid_crc defaults to 1 unless explicitly constrained to 0 in a test
    constraint sync_header_data_default_c {
     soft    slices_num == 'h2;   
     soft    CT_TYPE[7:0] == slices_num;  //[7-0]:   Number of Slices   |  [15-8]: 0x10 (Taichi DMS)
     soft    CT_TYPE[15:8] == 'h10;  //[7-0]:   Number of Slices   |  [15-8]: 0x10 (Taichi DMS)
     soft    header_header[1] == 'hBA;
     soft    header_header[0] == 'h5E;
     soft    fq_stream_enable ==1'b0; 
     soft    focal_spot_merging_factor == 'h0;
     soft    merging_factor == 'h00;
     soft    dms_status_i  ==  'h4200;
     soft    DFS =='h0;
     soft    READING_NUMBER_REG =='h0;
     soft    INTEGRATION_TIME_IN_REG== 'h0410; 
     soft    REFERENCE_DETECTOR == 'hFBAD;
     soft TIME_STAMP_LOW == 'h00010000;
    }
   // Constraint to ensure valid_crc defaults to 1 unless explicitly constrained to 0 in a test
    constraint sync_header_footer_default_c {
       soft  hd_pointer_address == 'h06D7B500;
       soft  fs_sequence_counter == 'h00;
       soft allow_random_address == 0;
       soft request_last_address == 0;
       soft allow_lost_B5 == 0;
       soft random_address_jump == 0;
    }


    // Constraint to ensure valid_crc defaults to 1 unless explicitly constrained to 0 in a test
    constraint sync_valid_crc_default_c {
        soft ip_valid_crc == 1'b1;  // Default valid_crc is 1 unless overridden in the test
        soft header_valid_crc == 1'b1;  // Default valid_crc is 1 unless overridden in the test
    }


  // Constructor
  function new(string name = "sync_txrx_seq_item");
    super.new(name);
     header_header = new[HEADER_SIZE];  // Resize header to match HEADER_SIZE
     header_data = new[HEADER_DATA_SIZE];      // Resize Data to match HEADER_SIZE
     footer = new[FOOTER_SIZE];  // Resize Footer to match HEADER_SIZE

  endfunction
endclass : sync_txrx_seq_item



`endif
