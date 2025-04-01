`ifndef ASIC_TILES_MONITOR_SV
`define ASIC_TILES_MONITOR_SV
//----------------------------------------------------------------
class asic_tiles_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(asic_tiles_monitor)

    virtual asic_tiles_agent_if vif;
    asic_tiles_config cfg;            // Configuration object
    asic_tiles_seq_item item;
    uvm_analysis_port #(asic_tiles_seq_item) analysis_port;

    function new(string name="m_asic_tiles_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("asic_tiles_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
        forever begin
            item = asic_tiles_seq_item::type_id::create("asic_tiles_item");
            wait(vif.valid);

            // Capture observed values
            @( posedge vif.valid);
            item.data = vif.data;
            item.address = vif.address;
            
            analysis_port.write(item);
          // printing item fields only in UVM_DEBUG Mode
           if (get_report_verbosity_level() >= UVM_DEBUG)
           begin
              $display("Monitor Printing %s Item: ",this.get_type_name);
              item.print();
           end
            
        end
    endtask
endclass: asic_tiles_monitor
`endif
