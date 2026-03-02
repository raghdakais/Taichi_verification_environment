`ifndef TAICHI_TMB_AGENT_PACKAGE_SV
`define TAICHI_TMB_AGENT_PACKAGE_SV


package taichi_tmb_agent_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  `include "taichi_tmb_agent_params.svh"

  // Include all agent components
  `include "taichi_tmb_seq_item.sv"
  `include "taichi_tmb_sequencer.sv"
  `include "taichi_tmb_sequence.sv"
  `include "taichi_tmb_driver.sv"
  `include "taichi_tmb_monitor.sv"
  `include "taichi_tmb_agent.sv"
endpackage : taichi_tmb_agent_package
`endif
