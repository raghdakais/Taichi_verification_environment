// UVM environment for taichi_tmb environment

package taichi_tmb_tests_package;

  import uvm_pkg::*; // Import UVM base classes
  `include "uvm_macros.svh"
  import taichi_tmb_env_package::*; // Import ENV components
  import taichi_tmb_agent_package::*; // Import agent components
  import TXRX_agent_package::*; // Import agent package that includes classes
  import controllers_agent_package::*; // Import agent package that includes classes
 
  // Include all env components
  
  `include "taichi_tmb_test_base.sv"
  `include "taichi_tmb_basic_test.sv"
  `include "diagnostic_registers_random_test.sv"
endpackage : taichi_tmb_tests_package

