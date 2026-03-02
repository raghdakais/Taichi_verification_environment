`ifndef SYNC_TXRX_SEQUENCER_SV
`define SYNC_TXRX_SEQUENCER_SV
//----------------------------------------------------------------
class sync_txrx_sequencer extends uvm_sequencer #(sync_txrx_seq_item);
//----------------------------------------------------------------
      sync_txrx_config cfg;            // Configuration object

    
      `uvm_component_utils(sync_txrx_sequencer)

    function new(string name = "m_sync_txrx_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
`endif
