`ifndef SYNC_TXRX_MONITOR_SV
`define SYNC_TXRX_MONITOR_SV
//----------------------------------------------------------------
class sync_txrx_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(sync_txrx_monitor)

    virtual sync_txrx_agent_if vif;
    sync_txrx_config cfg;            // Configuration object
    sync_txrx_seq_item item;
    uvm_analysis_port #(sync_txrx_seq_item) analysis_port;

    function new(string name="m_sync_txrx_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("sync_txrx_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
 /*       forever begin
            item = sync_txrx_seq_item::type_id::create("sync_txrx_item");

   
            analysis_port.write(item);
          // printing item fields only in UVM_DEBUG Mode
           if (get_report_verbosity_level() >= UVM_DEBUG)
           begin
              $display("Monitor Printing %s Item: ",this.get_type_name);
              item.print();
           end
           
        end
 */   endtask
endclass: sync_txrx_monitor
`endif
