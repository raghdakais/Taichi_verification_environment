`ifndef CONTROLLERS_SEQUENCER_SV
`define CONTROLLERS_SEQUENCER_SV
//----------------------------------------------------------------
class controllers_sequencer extends uvm_sequencer #(controllers_seq_item);
//----------------------------------------------------------------
      controllers_config cfg;            // Configuration object

    
      `uvm_component_utils(controllers_sequencer)

    function new(string name = "m_controllers_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
`endif
