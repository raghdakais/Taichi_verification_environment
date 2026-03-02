`ifndef CONTROLLERS_MONITOR_SV
`define CONTROLLERS_MONITOR_SV
//----------------------------------------------------------------
class controllers_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(controllers_monitor)

    virtual controllers_agent_if vif;
    controllers_config cfg;            // Configuration object

    uvm_analysis_port #(controllers_seq_item) analysis_port;

    function new(string name="m_controllers_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("controllers_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
        forever begin
            controllers_seq_item item = controllers_seq_item::type_id::create("controllers_item");
            wait(vif.valid);

            // Capture observed values
            @( posedge vif.valid);
            item.data = vif.data;
            item.address = vif.address;
            
            analysis_port.write(item);
        end
    endtask
endclass: controllers_monitor
`endif
