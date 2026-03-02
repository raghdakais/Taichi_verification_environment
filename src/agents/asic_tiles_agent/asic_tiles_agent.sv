`ifndef ASIC_TILES_AGENT_SV
`define ASIC_TILES_AGENT_SV
//----------------------------------------------------------------
class asic_tiles_agent extends uvm_agent;
//----------------------------------------------------------------
    `uvm_component_utils(asic_tiles_agent)

    virtual asic_tiles_agent_if vif;
    asic_tiles_driver drv;
    asic_tiles_sequencer seqr;
    asic_tiles_monitor mon;
    asic_tiles_config cfg;            // Configuration object
    string vif_str="USER DID NOT SET YET";
    function new(string name="m_asic_tiles_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
  function void build_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.build_phase(phase);

        if (!uvm_config_db#(virtual asic_tiles_agent_if)::get(this, "", vif_str, vif)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual asic_tiles_agent_vif interface not found for asic_tiles agent"));
        end
     // Get configuration from config_db
        if (!uvm_config_db#(asic_tiles_config)::get(this, "", "cfg", cfg)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual asic_tiles_config interface not found for TXRX agent"));
        end

      if(is_active == UVM_ACTIVE) begin
        `uvm_info(get_type_name(), "Agent Mode is ACTIVE ", UVM_DEBUG)
        drv  = asic_tiles_driver::type_id::create("asic_tiles_drv", this);
        seqr = asic_tiles_sequencer::type_id::create("asic_tiles_seqr", this);
        drv.vif = vif;
        seqr.cfg = cfg;  // Directly assign config to Sequencer
        drv.cfg  = cfg;   // Pass config to Driver
      end
      else
        `uvm_info(get_type_name(), "Agent Mode is PASSIVE ", UVM_DEBUG)

      mon  = asic_tiles_monitor::type_id::create("asic_tiles_mon", this);
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
endclass: asic_tiles_agent
`endif
