`ifndef ASIC_TILES_AGENT_IF_SV
`define ASIC_TILES_AGENT_IF_SV

`include "asic_tiles_agent_params.svh"

//----------------------------------------------------------------
interface asic_tiles_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
   //-- outputs --//
    bit TILES_CLK;
    bit TILES_CLK_N;
    bit [3:0] RESETn;
    bit [3:0] ACLK;
    bit [3:0] SYNC;
    bit [3:0] D_START;
    bit [3:0] DISCARD;
    bit [3:0] SCLK;
    bit [3:0] SCS1;
    bit [3:0] SCS2;
    bit [3:0] SDI;
   //-- outputs --//
    bit [3:0] SDO;
    bit [3:0] ACO;
    bit [3:0] ACO_N;
    bit [3:0] DATA1;
    bit [3:0] DATA1_N;
    bit [3:0] DATA2;
    bit [3:0] DATA2_N;
endinterface
`endif
