
// File: TXRX_agent_params.sv
`ifndef TXRX_AGENT_PARAMS_SV
`define TXRX_AGENT_PARAMS_SV

// Parameter definitions
   parameter int  IDLE       ='hAA;
// Configurable packet structure sizes
  int HEADER_SIZE  = 2;
  int DATA_SIZE    = 2;
  int FOOTER_SIZE  = 2; 

`endif
