`ifndef SYNC_TXRX_AGENT_SV
`define SYNC_TXRX_AGENT_SV
//----------------------------------------------------------------
class sync_txrx_agent extends uvm_agent;
//----------------------------------------------------------------
    `uvm_component_utils(sync_txrx_agent)

    virtual sync_txrx_agent_if vif;
    sync_txrx_driver drv;
    sync_txrx_sequencer seqr;
    sync_txrx_monitor mon;
    sync_txrx_config cfg;            // Configuration object

    string vif_str="USER DID NOT SET YET";
    string cfg_str="USER DID NOT SET YET";

    function new(string name="m_sync_txrx_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
  function void build_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.build_phase(phase);

        if (!uvm_config_db#(virtual sync_txrx_agent_if)::get(this, "", "sync_txrx_agent_vif", vif)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual sync_txrx_agent_vif interface not found for sync_txrx agent"));
        end
     // Get configuration from config_db
        if (!uvm_config_db#(sync_txrx_config)::get(this, "", "cfg", cfg)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual sync_txrx_config interface not found for TXRX agent"));
        end

      if(is_active == UVM_ACTIVE) begin
        `uvm_info(get_type_name(), "Agent Mode is ACTIVE ", UVM_DEBUG)
        drv  = sync_txrx_driver::type_id::create("sync_txrx_drv", this);
        seqr = sync_txrx_sequencer::type_id::create("sync_txrx_seqr", this);
        drv.vif = vif;
        seqr.cfg = cfg;  // Directly assign config to Sequencer
        drv.cfg  = cfg;   // Pass config to Driver
      end
      else
        `uvm_info(get_type_name(), "Agent Mode is PASSIVE ", UVM_DEBUG)

      mon  = sync_txrx_monitor::type_id::create("sync_txrx_mon", this);
      mon.vif = vif;
      mon.cfg  = cfg;   // Pass config to Monitor
  endfunction

//----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
//----------------------------------------------------------------
      super.connect_phase(phase);
      if (is_active == UVM_ACTIVE && drv != null && seqr != null) 
        this.drv.seq_item_port.connect(this.seqr.seq_item_export);
    endfunction
endclass: sync_txrx_agent
`endif
