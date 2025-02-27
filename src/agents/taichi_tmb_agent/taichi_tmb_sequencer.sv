`ifndef TAICHI_TMB_SEQUENCER_SV
`define TAICHI_TMB_SEQUENCER_SV
class taichi_tmb_sequencer  extends uvm_sequencer #(taichi_tmb_seq_item);
    `uvm_component_utils(taichi_tmb_sequencer)

    function new(string name="m_taichi_tmb_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
`endif
