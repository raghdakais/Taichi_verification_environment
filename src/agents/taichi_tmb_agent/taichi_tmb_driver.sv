`ifndef TAICHI_TMB_DRIVER_SV
`define TAICHI_TMB_DRIVER_SV
class taichi_tmb_driver extends uvm_driver #(taichi_tmb_seq_item);
    `uvm_component_utils(taichi_tmb_driver)

    virtual taichi_tmb_agent_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
    super.run_phase(phase);
        forever begin
            seq_item_port.get_next_item(req);
            // Drive data to the interface
            vif.data    <= req.data;
            vif.address <= req.address;
            vif.valid <= req.valid;
            @( posedge vif.clk);
            
            seq_item_port.item_done(); // Indicate completion of the transaction
        end
    endtask
endclass: taichi_tmb_driver
`endif
