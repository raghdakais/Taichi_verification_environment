class TXRX_sequencer extends uvm_sequencer #(TXRX_seq_item);
    `uvm_component_utils(TXRX_sequencer)
   TXRX_config cfg;            // Configuration object

    function new(string name, uvm_component parent);
        super.new(name, parent);
            cfg = TXRX_config::type_id::create("TXRX_cfg");
 
    endfunction
endclass
