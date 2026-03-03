
// File: sync_txrx_agent_params.sv
`ifndef SYNC_TXRX_AGENT_PARAMS_SV
`define SYNC_TXRX_AGENT_PARAMS_SV

// Parameter definitions
   parameter int  IDLE       ='hB5;
 //  parameter int  HEADER_DATA_SIZE       ='d64;


typedef enum {
    WAIT_SYNC,
    WAIT_START1,
    WAIT_START2,
    COLLECT_PAYLOAD
} sync_state_e;


// Parameter definitions
`define DATA_WIDTH 32
`define ADDR_WIDTH 32




//`define RESET_ACTIVE 1'b1

`endif
