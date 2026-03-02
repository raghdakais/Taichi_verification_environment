// UVM environment for taichi_tmb environment

package taichi_tmb_env_package;

  import uvm_pkg::*; // Import UVM base classes
  import taichi_tmb_agent_package::*; // Import agent package that includes classes
  import TXRX_agent_package::*; // Import agent package that includes classes
  import controllers_agent_package::*; // Import agent package that includes classes
  import sync_txrx_agent_package::*; // Import agent package that includes classes
  import asic_tiles_agent_package::*; // Import agent package that includes classes
  import buffer_tx_agent_package::*; // Import agent package that includes classes
  import data_out_agent_package::*; // Import agent package that includes classes
   `include "uvm_macros.svh"

 /// `include "diagnostic_reg_block.sv"
  `include "taichi_env_params.svh"

  // Include all env components
  `include "taichi_tmb_reference_model.sv"
  `include "taichi_tmb_env.sv"

endpackage : taichi_tmb_env_package

