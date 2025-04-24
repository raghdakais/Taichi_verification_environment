`ifndef BUFFER_TX_MONITOR_SV
`define BUFFER_TX_MONITOR_SV
//----------------------------------------------------------------
class buffer_tx_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(buffer_tx_monitor)

    virtual buffer_tx_agent_if vif;
    buffer_tx_config cfg;            // Configuration object
    buffer_tx_seq_item item;
    uvm_analysis_port #(buffer_tx_seq_item) analysis_port;

    function new(string name="m_buffer_tx_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("buffer_tx_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
 ///////           forever begin
 ///////               item = buffer_tx_seq_item::type_id::create("buffer_tx_item");
 ///////               wait(vif.valid);
///////    
 ///////               // Capture observed values
 ///////               @( posedge vif.valid);
 ///////               item.data = vif.data;
 ///////               item.address = vif.address;
 ///////               
 ///////               analysis_port.write(item);
 ///////             // printing item fields only in UVM_DEBUG Mode
 ///////              if (get_report_verbosity_level() >= UVM_DEBUG)
 ///////              begin
 ///////                 $display("Monitor Printing %s Item: ",this.get_type_name);
 ///////                 item.print();
 ///////              end
 ///////               
 ///////           end
    endtask
endclass: buffer_tx_monitor
`endif
