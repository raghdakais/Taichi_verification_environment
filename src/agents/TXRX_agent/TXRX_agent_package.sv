`ifndef TXRX_AGENT_PACKAGE_SV
`define TXRX_AGENT_PACKAGE_SV


package TXRX_agent_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  typedef enum {IP, STATIC, DYNAMIC} packet_type_t;
  // Enum to represent read and write operations
    typedef enum bit [1:0] {
    READ  = 2'b01,   // Bit 0 is active for READ
    WRITE = 2'b10    // Bit 1 is active for WRITE
    } rw_type_t;


  `include "TXRX_agent_params.svh"

    string cfg_str="USER DID NOT SET YET";
   
  // Include all agent components
  `include "TXRX_config.sv"
  `include "TXRX_seq_item.sv"
  `include "TXRX_sequencer.sv"
  `include "TXRX_sequence.sv"
  `include "TXRX_driver.sv"
  `include "TXRX_monitor.sv"
  `include "TXRX_agent.sv"
endpackage : TXRX_agent_package
`endif
