# UVM compile environment and all agents components  for taichi_tmb environment

    # Set the UVM library path (assuming $UVM_HOME is defined in your environment)
   # set UVM_HOME [getenv UVM_HOME]

# Compiling all interfaces
     vlog -sv  +incdir+../src/agents/              ../src/agents/taichi_tmb_agent/taichi_tmb_agent_if.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/TXRX_agent/TXRX_agent_if.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/controllers_agent/controllers_agent_if.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/asic_tiles_agent/asic_tiles_agent_if.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/sync_txrx_agent/sync_txrx_agent_if.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/buffer_tx_agent/buffer_tx_agent_if.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/data_out_agent/data_out_agent_if.sv

# Compiling all src(env and agents ) in the environment
     vlog -sv  +incdir+../src/agents/              ../src/agents/taichi_tmb_agent/taichi_tmb_agent_package.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/TXRX_agent/TXRX_agent_package.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/controllers_agent/controllers_agent_package.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/asic_tiles_agent/asic_tiles_agent_package.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/sync_txrx_agent/sync_txrx_agent_package.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/buffer_tx_agent/buffer_tx_agent_package.sv
     vlog -sv  +incdir+../src/agents/              ../src/agents/data_out_agent/data_out_agent_package.sv

# Compiling  test folder in the environment
     vlog -sv  +incdir+../src/                ../src/taichi_tmb_env_package.sv
     vlog -sv  +incdir+../tests/\
               +incdir+../src/agents/\
            ../tests/taichi_tmb_tests_package.sv

# Compiling tb in the environment
    vlog -sv +incdir+../tb/             ../tb/taichi_tmb_tb.sv



