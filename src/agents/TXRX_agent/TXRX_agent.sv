`ifndef TXRX_AGENT_SV
`define TXRX_AGENT_SV


class TXRX_agent extends uvm_agent;
    `uvm_component_utils(TXRX_agent)

    virtual TXRX_agent_if vif;
    TXRX_driver drv;
    TXRX_sequencer seqr;
    TXRX_monitor mon;
    TXRX_config cfg;            // Configuration object

    string vif_str="USER DID NOT SET YET";
    string cfg_str="USER DID NOT SET YET";

    function new(string name, uvm_component parent);
            super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual TXRX_agent_if)::get(this, "", vif_str, vif)) begin
            $display("interface string is :  %s",vif_str );
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual TXRX_agent_vif interface not found for TXRX agent"));
        end

        // Get configuration from config_db
        if (!uvm_config_db#(TXRX_config)::get(this, "", "cfg", cfg)) begin
            $display("config string is :  %s",cfg_str );
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual TXRX_agent_cfg interface not found for TXRX agent"));
        end
        
      if(is_active == UVM_ACTIVE) 
      begin
        drv  = TXRX_driver::type_id::create("TXRX_drv", this);
        // Create and set sequencer
        seqr = TXRX_sequencer::type_id::create("TXRX_seqr", this);
        drv.vif = vif;
        seqr.cfg = cfg;  // Directly assign config to Sequencer
        drv.cfg  = cfg;   // Pass config to Driver
      end
      mon  = TXRX_monitor::type_id::create("TXRX_mon", this);
      mon.vif = vif;
      mon.cfg  = cfg;   // Pass config to Monitor
  

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
       if (is_active == UVM_ACTIVE && drv != null && seqr != null) 
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass: TXRX_agent
`endif
