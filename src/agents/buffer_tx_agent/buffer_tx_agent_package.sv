`ifndef BUFFER_TX_AGENT_PACKAGE_SV
`define BUFFER_TX_AGENT_PACKAGE_SV


package buffer_tx_agent_package;
    typedef enum bit { BUFFER  } packet_buffer_type_e;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  `include "buffer_tx_agent_params.svh"

  // Include all agent components
  `include "buffer_tx_config.sv"
  `include "buffer_tx_seq_item.sv"
  `include "buffer_tx_sequencer.sv"
  `include "buffer_tx_sequence.sv"
  `include "buffer_tx_driver.sv"
  `include "buffer_tx_monitor.sv"
  `include "buffer_tx_agent.sv"
endpackage : buffer_tx_agent_package
`endif
