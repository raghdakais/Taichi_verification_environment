`ifndef BUFFER_TX_AGENT_SV
`define BUFFER_TX_AGENT_SV
//----------------------------------------------------------------
class buffer_tx_agent extends uvm_agent;
//----------------------------------------------------------------
    `uvm_component_utils(buffer_tx_agent)

    virtual buffer_tx_agent_if vif;
    buffer_tx_driver drv;
    buffer_tx_sequencer seqr;
    buffer_tx_monitor mon;
    buffer_tx_config cfg;            // Configuration object

    string vif_str="USER DID NOT SET YET";
    string cfg_str="USER DID NOT SET YET";

    function new(string name="m_buffer_tx_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
  function void build_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.build_phase(phase);

        if (!uvm_config_db#(virtual buffer_tx_agent_if)::get(this, "", "vif", vif)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual buffer_tx_agent_vif interface not found for buffer_tx agent"));
        end
     // Get configuration from config_db
        if (!uvm_config_db#(buffer_tx_config)::get(this, "", "cfg", cfg)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual buffer_tx_config interface not found for TXRX agent"));
        end

      if(is_active == UVM_ACTIVE) begin
        `uvm_info(get_type_name(), "Agent Mode is ACTIVE ", UVM_DEBUG)
        drv  = buffer_tx_driver::type_id::create("buffer_tx_drv", this);
        seqr = buffer_tx_sequencer::type_id::create("buffer_tx_seqr", this);
        drv.vif = vif;
        seqr.cfg = cfg;  // Directly assign config to Sequencer
        drv.cfg  = cfg;   // Pass config to Driver
      end
      else
        `uvm_info(get_type_name(), "Agent Mode is PASSIVE ", UVM_DEBUG)

      mon  = buffer_tx_monitor::type_id::create("buffer_tx_mon", this);
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
endclass: buffer_tx_agent
`endif
