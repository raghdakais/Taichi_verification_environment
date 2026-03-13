`ifndef BUFFER_TX_AGENT_IF_SV
`define BUFFER_TX_AGENT_IF_SV

`include "buffer_tx_agent_params.svh"

//----------------------------------------------------------------
interface buffer_tx_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
    bit tx;
        byte unsigned data_out_byte;
        bit [15:0] buffer_address;
        byte stream_ctrl;

            buffer_state_e state = WAIT_BUFFER;
 byte unsigned byte_collected;
bit allow_lost_B5 = 0;

endinterface
`endif
