`ifndef SYNC_TXRX_AGENT_IF_SV
`define SYNC_TXRX_AGENT_IF_SV

`include "sync_txrx_agent_params.svh"

//----------------------------------------------------------------
interface sync_txrx_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
    bit tx;
    bit rx;
    bit rx_n;
 
    bit ip_valid_crc;
    bit header_valid_crc;

    bit tx_sync_signal;
    bit rx_sync_signal;
    byte slot_pointer_address;
    sync_state_e state;
    byte  byte_collected;
    logic [7:0]   shift_reg ;
endinterface
`endif
