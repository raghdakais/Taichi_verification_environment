`ifndef ASIC_TILES_AGENT_PACKAGE_SV
`define ASIC_TILES_AGENT_PACKAGE_SV


package asic_tiles_agent_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"

  `include "asic_tiles_agent_params.svh"

  // Include all agent components
  `include "asic_tiles_config.sv"
  `include "asic_tiles_seq_item.sv"
  `include "asic_tiles_sequencer.sv"
  `include "asic_tiles_sequence.sv"
  `include "asic_tiles_driver.sv"
  `include "asic_tiles_monitor.sv"
  `include "asic_tiles_agent.sv"
endpackage : asic_tiles_agent_package
`endif
