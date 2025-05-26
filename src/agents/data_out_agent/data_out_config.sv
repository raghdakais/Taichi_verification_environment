
//----------------------------------------------------------------
class data_out_config extends uvm_object;
//----------------------------------------------------------------
  `uvm_object_utils(data_out_config)

  int DATA_WIDTH;
  int ADDR_WIDTH;
  int timeout_cycles = 100;
  function new(string name = "m_data_out_config");
    super.new(name);
  endfunction
endclass
