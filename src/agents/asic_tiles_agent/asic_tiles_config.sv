
//----------------------------------------------------------------
class asic_tiles_config extends uvm_object;
//----------------------------------------------------------------
  `uvm_object_utils(asic_tiles_config)

  int DATA_WIDTH;
  int ADDR_WIDTH;
  int timeout_cycles = 100000;
  function new(string name = "m_asic_tiles_config");
    super.new(name);
  endfunction
endclass
