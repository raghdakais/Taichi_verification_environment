
//----------------------------------------------------------------
class controllers_config extends uvm_object;
//----------------------------------------------------------------
  `uvm_object_utils(controllers_config)

  int DATA_WIDTH;
  int ADDR_WIDTH;
  int timeout_cycles = 1000;
  function new(string name = "m_controllers_config");
    super.new(name);
  endfunction
endclass
