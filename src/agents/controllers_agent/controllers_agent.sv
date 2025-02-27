`ifndef CONTROLLERS_AGENT_SV
`define CONTROLLERS_AGENT_SV
//----------------------------------------------------------------
class controllers_agent extends uvm_agent;
//----------------------------------------------------------------
    `uvm_component_utils(controllers_agent)

    virtual controllers_agent_if vif;
    controllers_driver drv;
    controllers_sequencer seqr;
    controllers_monitor mon;
    controllers_config cfg;            // Configuration object

    function new(string name="m_controllers_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
  function void build_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.build_phase(phase);

        if (!uvm_config_db#(virtual controllers_agent_if)::get(this, "", "vif", vif)) begin
            $display("interface name is :  vif");
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual controllers_agent_vif interface not found for controllers agent"));
        end
     // Get configuration from config_db
        if (!uvm_config_db#(controllers_config)::get(this, "", "cfg", cfg)) begin
            $display("config string is : cfg" );
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual controllers_config interface not found for TXRX agent"));
        end
      if(is_active == UVM_ACTIVE)
     begin
       `uvm_info(get_type_name(), "Agent Mode is ACTIVE ", UVM_DEBUG)
        drv  = controllers_driver::type_id::create("controllers_drv", this);
        seqr = controllers_sequencer::type_id::create("controllers_seqr", this);
        drv.vif = vif;
        drv.cfg  = cfg;   // Pass config to Driver
        seqr.cfg = cfg;  // Directly assign config to Sequencer
     end
     else
     `uvm_info(get_type_name(), "Agent Mode is PASSIVE ", UVM_DEBUG)
   
      mon  = controllers_monitor::type_id::create("controllers_mon", this);
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
endclass: controllers_agent
`endif
