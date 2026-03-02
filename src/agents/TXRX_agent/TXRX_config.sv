class TXRX_config extends uvm_object;
  `uvm_object_utils(TXRX_config)

  int HEADER_SIZE;
  int DATA_SIZE;
  int FOOTER_SIZE; 
  int timeout_cycles = 100000;
  function new(string name = "");
    super.new(name);
  endfunction
endclass