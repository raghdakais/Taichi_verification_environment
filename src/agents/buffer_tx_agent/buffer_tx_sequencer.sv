`ifndef BUFFER_TX_SEQUENCER_SV
`define BUFFER_TX_SEQUENCER_SV
//----------------------------------------------------------------
class buffer_tx_sequencer extends uvm_sequencer #(buffer_tx_seq_item);
//----------------------------------------------------------------
      buffer_tx_config cfg;            // Configuration object

    
      `uvm_component_utils(buffer_tx_sequencer)

    function new(string name = "m_buffer_tx_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
`endif
