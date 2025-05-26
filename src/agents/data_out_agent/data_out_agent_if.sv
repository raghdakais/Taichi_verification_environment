`ifndef DATA_OUT_AGENT_IF_SV
`define DATA_OUT_AGENT_IF_SV

`include "data_out_agent_params.svh"

//----------------------------------------------------------------
interface data_out_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
bit [1:0] rx;
byte data_out_byte;
byte   header_buffer[$];

endinterface
`endif
