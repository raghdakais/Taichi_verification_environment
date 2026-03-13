
// File: buffer_tx_agent_params.sv
`ifndef BUFFER_TX_AGENT_PARAMS_SV
`define BUFFER_TX_AGENT_PARAMS_SV
// Parameter definitions
   parameter int  IDLE       ='hB5;
//`define RESET_ACTIVE 1'b1
    `define BUFFER_HEADER_SIZE  2
    `define BUFFER_DATA_SIZE    8
    `define BUFFER_FOOTER_SIZE  2 

typedef enum {
    WAIT_BUFFER,
    WAIT_START1,
    WAIT_START2,
    COLLECT_PAYLOAD
} buffer_state_e;
`endif
