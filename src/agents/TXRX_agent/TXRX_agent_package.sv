`ifndef TXRX_AGENT_PACKAGE_SV
`define TXRX_AGENT_PACKAGE_SV


package TXRX_agent_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  typedef enum {IP, STATIC, DYNAMIC} packet_type_t;
  // Enum to represent read and write operations
    typedef enum bit {
    TXRX_READ ,   
    TXRX_WRITE    
    } rw_type_t;


  `include "TXRX_agent_params.svh"

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
