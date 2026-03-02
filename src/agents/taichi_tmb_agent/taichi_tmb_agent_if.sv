`ifndef TAICHI_TMB_AGENT_IF_SV
`define TAICHI_TMB_AGENT_IF_SV

`include "taichi_tmb_agent_params.svh"

interface taichi_tmb_agent_if(input logic clk);
    //[ EXAMPLE: ]
    logic [`ADDR_WIDTH-1:0] address;  // 32-bit address signal
    logic [`DATA_WIDTH-1:0] data;     // 32-bit data signal
    logic valid;           // Valid signal
endinterface
`endif
