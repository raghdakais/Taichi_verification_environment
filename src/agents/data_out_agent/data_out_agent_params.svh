
// File: data_out_agent_params.sv
`ifndef DATA_OUT_AGENT_PARAMS_SV
`define DATA_OUT_AGENT_PARAMS_SV

    `define DATA_OUT_HEADER_SIZE  128
    `define DATA_OUT_DATA_SIZE    8
    `define DATA_OUT_FOOTER_SIZE  64 

typedef enum {
    WAIT_DATA_OUT,
    WAIT_START1,
    WAIT_START2,
    COLLECT_PACKET_SIZE,
    COLLECT_HEADER,
    COLLECT_DATA,
    COLLECT_FOOTER,
    COLLECT_CRC
} data_out_state_e;

`endif
