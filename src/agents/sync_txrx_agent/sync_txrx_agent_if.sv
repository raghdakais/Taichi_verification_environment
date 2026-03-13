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
    bit [15:0] slot_pointer_address;
    sync_state_e state;
    byte  byte_collected;
    logic [7:0]   shift_reg ;

bit [15:0]    ct_type;
bit allow_lost_B5 ; 
endinterface
`endif
