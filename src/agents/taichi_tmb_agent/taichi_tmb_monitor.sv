`ifndef TAICHI_TMB_MONITOR_SV
`define TAICHI_TMB_MONITOR_SV
class taichi_tmb_monitor extends uvm_monitor;
    `uvm_component_utils(taichi_tmb_monitor)

    virtual taichi_tmb_agent_if vif;
    uvm_analysis_port #(taichi_tmb_seq_item) analysis_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_port = new("taichi_tmb_analysis_port", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            taichi_tmb_seq_item item = taichi_tmb_seq_item::type_id::create("taichi_tmb_item");
            wait(vif.valid);

            // Capture observed values
            @( posedge vif.valid);
            item.data = vif.data;
            item.address = vif.address;
            
            analysis_port.write(item);
        end
    endtask
endclass: taichi_tmb_monitor
`endif
