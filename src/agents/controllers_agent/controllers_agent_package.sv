`ifndef CONTROLLERS_AGENT_PACKAGE_SV
`define CONTROLLERS_AGENT_PACKAGE_SV


package controllers_agent_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  `include "controllers_agent_params.svh"

  // Include all agent components
  `include "controllers_config.sv"
  `include "controllers_seq_item.sv"
  `include "controllers_sequencer.sv"
  `include "controllers_sequence.sv"
  `include "controllers_driver.sv"
  `include "controllers_monitor.sv"
  `include "controllers_agent.sv"
endpackage : controllers_agent_package
`endif
