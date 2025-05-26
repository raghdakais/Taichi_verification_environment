`ifndef DATA_OUT_AGENT_SV
`define DATA_OUT_AGENT_SV
//----------------------------------------------------------------
class data_out_agent extends uvm_agent;
//----------------------------------------------------------------
    `uvm_component_utils(data_out_agent)

    virtual data_out_agent_if vif;
    data_out_monitor mon;
    data_out_config cfg;            // Configuration object

    string vif_str="USER DID NOT SET YET";
    string cfg_str="USER DID NOT SET YET";

    function new(string name="m_data_out_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
  function void build_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.build_phase(phase);

        if (!uvm_config_db#(virtual data_out_agent_if)::get(this, "", "vif", vif)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual data_out_agent_vif interface not found for data_out agent"));
        end
     // Get configuration from config_db
        if (!uvm_config_db#(data_out_config)::get(this, "", "cfg", cfg)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual data_out_config interface not found for TXRX agent"));
        end

      mon  = data_out_monitor::type_id::create("data_out_mon", this);
      mon.vif = vif;
      mon.cfg  = cfg;   // Pass config to Monitor
  endfunction

//----------------------------------------------------------------
    function void connect_phase(uvm_phase phase);
//----------------------------------------------------------------
      super.connect_phase(phase);
    endfunction
endclass: data_out_agent
`endif
