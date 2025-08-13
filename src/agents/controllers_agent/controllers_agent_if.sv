`ifndef CONTROLLERS_AGENT_IF_SV
`define CONTROLLERS_AGENT_IF_SV

`include "controllers_agent_params.svh"

//----------------------------------------------------------------
interface controllers_agent_if(input logic clk, input logic rst);
//----------------------------------------------------------------
    //[ EXAMPLE: ]
    bit [`ADDR_WIDTH-1:0] address;  // 32-bit address signal
    bit [`DATA_WIDTH-1:0] data;     // 32-bit data signal
    bit valid;           // Valid signal

   // inputs
   bit       Sig_2         ; 
   bit       Master_Slave  ;  // const - must be 0 - master mode
   bit [3:0] HW_REV        ;
   bit       PGOOD_0_75V   ; 
   bit       PGOOD_1_0V    ;
   bit       PGOOD_1_5V    ;
   bit       PGOOD_1_8V    ;
   bit       PGOOD_P1_5V   ; 
   bit       PGOOD_2_5V    ; 
   // outputs
   bit [7:0] DEBUG_TP      ;
   bit [1:0] STATUS_LEDS   ; 
   bit       DISABLE_CLK0n ;
   bit       DISABLE_CLK1n ;
   bit       DISABLE_SLAVEn; 
   bit       DISABLE_APOSn ; 
   bit       DISABLE_ANEGn ; 
   bit       HEATER_1      ; 
   bit       HEATER_2      ; 
   bit       SO_FLASH      ;
   bit       SI_FLASH      ;
   bit       CS_FLASH      ;
bit start_sig2;
bit sig2_clk = 1;
endinterface
`endif
