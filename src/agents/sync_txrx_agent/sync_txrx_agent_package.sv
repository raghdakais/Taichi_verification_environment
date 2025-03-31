`ifndef SYNC_TXRX_AGENT_PACKAGE_SV
`define SYNC_TXRX_AGENT_PACKAGE_SV


package sync_txrx_agent_package;
    typedef enum bit { SYNC_IP=0, SYNC_HEADER=1 } packet_sync_type_e;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  `include "sync_txrx_agent_params.svh"

  // Include all agent components
  `include "sync_txrx_config.sv"
  `include "sync_txrx_seq_item.sv"
  `include "sync_txrx_sequencer.sv"
  `include "sync_txrx_sequence.sv"
  `include "sync_txrx_driver.sv"
  `include "sync_txrx_monitor.sv"
  `include "sync_txrx_agent.sv"
endpackage : sync_txrx_agent_package
`endif
