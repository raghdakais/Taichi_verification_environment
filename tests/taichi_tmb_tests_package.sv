// UVM environment for taichi_tmb environment

package taichi_tmb_tests_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"
  import taichi_tmb_env_package::*; // Import ENV components
  import taichi_tmb_agent_package::*; // Import agent components
  import TXRX_agent_package::*; // Import agent package that includes classes
  import controllers_agent_package::*; // Import agent package that includes classes
  import sync_txrx_agent_package::*; // Import agent package that includes classes
  import asic_tiles_agent_package::*; // Import agent package that includes classes
 import buffer_tx_agent_package::*; // Import agent package that includes classes
 
  // Include all env components
  
  `include "taichi_tmb_test_base.sv"
  `include "taichi_tmb_basic_test.sv"
  `include "diagnostic_registers_random_test.sv"
  `include "check_default_value_for_all_registers_test.sv"
  `include "check_RO_registers_test.sv"
  `include "operational_registers_random_test.sv"
  `include "sending_frame_data_Mu_off_test.sv"
  `include "read_from_empty_buffer_test.sv"
  `include "random_data_path_test.sv"
  `include "send_syncs_for_buffer_full_test.sv"
  `include "sig2_sync_test.sv"

endpackage : taichi_tmb_tests_package

