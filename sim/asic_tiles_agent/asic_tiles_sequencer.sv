`ifndef ASIC_TILES_SEQUENCER_SV
`define ASIC_TILES_SEQUENCER_SV
//----------------------------------------------------------------
class asic_tiles_sequencer extends uvm_sequencer #(asic_tiles_seq_item);
//----------------------------------------------------------------
      asic_tiles_config cfg;            // Configuration object

    
      `uvm_component_utils(asic_tiles_sequencer)

    function new(string name = "m_asic_tiles_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
`endif
