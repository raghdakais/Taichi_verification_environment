`ifndef DATA_OUT_AGENT_IF_SV
`define DATA_OUT_AGENT_IF_SV

`include "data_out_agent_params.svh"

//----------------------------------------------------------------
interface data_out_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
bit [1:0] rx;
byte data_out_byte;
byte unsigned  header_buffer[$];
bit collect_en;
bit end_package;
bit start_package;
byte first_data_byte;
bit header_package_recieved;
int data_out_packet_size;
bit [31:0] buffer_ptr_addr;
 bit [15:0]  ct_type;  
    data_out_state_e state = WAIT_DATA_OUT;
 byte unsigned byte_collected;

endinterface
`endif
