`ifndef TXRX_AGENT_IF_SV
`define TXRX_AGENT_IF_SV

`include "TXRX_agent_params.svh"

interface TXRX_agent_if(input logic clk,input logic rst );
    bit tx;
    bit rx;
    bit rx_n;
    bit active_package;

    bit valid_crc;
    bit valid_start1;
    bit valid_start2;

    bit byte_collected;
    bit channel_ok;
endinterface
`endif
