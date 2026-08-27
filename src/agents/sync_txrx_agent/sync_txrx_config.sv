
//----------------------------------------------------------------
class sync_txrx_config extends uvm_object;
//----------------------------------------------------------------
  `uvm_object_utils(sync_txrx_config)

  int DATA_WIDTH;
  int ADDR_WIDTH;
  int timeout_cycles = 1000000000;
  function new(string name = "m_sync_txrx_config");
    super.new(name);
  endfunction
endclass
