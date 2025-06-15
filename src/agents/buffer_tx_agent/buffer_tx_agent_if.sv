`ifndef BUFFER_TX_AGENT_IF_SV
`define BUFFER_TX_AGENT_IF_SV

`include "buffer_tx_agent_params.svh"

//----------------------------------------------------------------
interface buffer_tx_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
    bit tx;
        byte unsigned data_out_byte;
endinterface
`endif
