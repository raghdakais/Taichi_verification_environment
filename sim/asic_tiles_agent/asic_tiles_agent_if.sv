`ifndef ASIC_TILES_AGENT_IF_SV
`define ASIC_TILES_AGENT_IF_SV

`include "asic_tiles_agent_params.svh"

//----------------------------------------------------------------
interface asic_tiles_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
    //[ EXAMPLE: ]
    bit [`ADDR_WIDTH-1:0] address;  // 32-bit address signal
    bit [`DATA_WIDTH-1:0] data;     // 32-bit data signal
    bit valid;           // Valid signal
endinterface
`endif
