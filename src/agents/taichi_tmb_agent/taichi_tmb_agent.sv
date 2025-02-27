`ifndef TAICHI_TMB_AGENT_SV
`define TAICHI_TMB_AGENT_SV
class taichi_tmb_agent extends uvm_agent;
    `uvm_component_utils(taichi_tmb_agent)

    virtual taichi_tmb_agent_if vif;
    taichi_tmb_driver drv;
    taichi_tmb_sequencer seqr;
    taichi_tmb_monitor mon;

    function new(string name="m_taichi_tmb_agent" , uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual taichi_tmb_agent_if)::get(this, "", "vif", vif)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual taichi_tmb_agent_vif interface not found for taichi_tmb agent"));
        end

    //  if(is_active == UVM_ACTIVE)
     begin
        drv  = taichi_tmb_driver::type_id::create("taichi_tmb_drv", this);
        seqr = taichi_tmb_sequencer::type_id::create("taichi_tmb_seqr", this);
        drv.vif = vif;
      end
      mon  = taichi_tmb_monitor::type_id::create("taichi_tmb_mon", this);
      mon.vif = vif;
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        this.drv.seq_item_port.connect(this.seqr.seq_item_export);
    endfunction


   function void report_phase(uvm_phase phase);
         super.report_phase(phase);
        `uvm_info("AGENT", $sformatf("Agent Type: %s", get_type_name()), UVM_DEBUG)
        `uvm_info("AGENT", $sformatf("Sequencer Type: %s", seqr.get_type_name()), UVM_DEBUG)
        `uvm_info("AGENT", $sformatf("Driver Type: %s", drv.get_type_name()), UVM_DEBUG)
        `uvm_info("AGENT", $sformatf("Monitor Type: %s", mon.get_type_name()), UVM_DEBUG)
    endfunction


endclass: taichi_tmb_agent
`endif
