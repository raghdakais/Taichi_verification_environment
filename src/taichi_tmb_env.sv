// UVM environment for taichi_tmb environment
class taichi_tmb_env extends uvm_env;
    // Environment setup here
    `uvm_component_utils(taichi_tmb_env)
    
     TXRX_agent diag_txrx_agent;
     TXRX_agent oper_txrx_agent;
     TXRX_agent buffer_txrx_agent;
     sync_txrx_agent m_sync_txrx_agent;
     controllers_agent m_controllers_agent;
     controllers_config m_controllers_config;    
  // Configuration objects created in the environment
     TXRX_config diag_txrx_config;
     TXRX_config oper_txrx_config;
     sync_txrx_config m_sync_txrx_config;
     TXRX_config buffer_txrx_config;
  
   // diagnostic_reg_block m_diagnostic_reg_block;
    taichi_tmb_reference_model	taichi_tmb_rm; 		// Scoreboard handle

   
	function new(string name = "taichi_tmb_env", uvm_component parent = null);
		super.new(name, parent);
	endfunction

   //-------------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
   //-------------------------------------------------------------------------------
        super.build_phase(phase);
       this.m_controllers_agent = controllers_agent::type_id::create("m_controllers_agent", this);
       set_config_int("m_controllers_agent", "is_active", UVM_ACTIVE);
      // Set configurations for different controllers agent instances
     this.m_controllers_config = controllers_config::type_id::create("m_controllers_config");
     uvm_config_db#(controllers_config)::set(null, "", "cfg", m_controllers_config);

   //-------------------------------------------------------------------------------
   // Creating DIAGNOSTICAL TXRX agent and configuration 
   //-------------------------------------------------------------------------------
    this.diag_txrx_agent = TXRX_agent::type_id::create("diag_txrx_agent", this );
    set_config_int("m_controllers_agent", "is_active", UVM_ACTIVE);
    this.diag_txrx_agent.vif_str = "diag_txrx_agent_vif";
    this.diag_txrx_agent.cfg_str = "cfg";
    this.diag_txrx_config = TXRX_config::type_id::create("diag_txrx_config");
    this.diag_txrx_config.HEADER_SIZE = 1;
    this.diag_txrx_config.DATA_SIZE = 4;
    this.diag_txrx_config.FOOTER_SIZE = 3;
   // Set configurations for different TXRX agent instances
    uvm_config_db#(TXRX_config)::set(null, "", "cfg", diag_txrx_config);
 
   //-------------------------------------------------------------------------------
   // Creating OPERATIONAL TXRX agent and configuration 
   //-------------------------------------------------------------------------------
    this.oper_txrx_config = TXRX_config::type_id::create("oper_txrx_config");
    this.oper_txrx_config.HEADER_SIZE = 1;
    this.oper_txrx_config.DATA_SIZE = 4;
    this.oper_txrx_config.FOOTER_SIZE = 3;
    uvm_config_db#(TXRX_config)::set(null, "", "cfg", oper_txrx_config);
    this.oper_txrx_agent = TXRX_agent::type_id::create("oper_txrx_agent", this);
    this.oper_txrx_agent.vif_str = "oper_txrx_agent_vif";
    this.oper_txrx_agent.cfg_str = "oper_txrx_config";
  //  this.oper_txrx_agent.set_active(); 
  //-------------------------------------------------------------------------------
   // Creating SYNC TXRX [ IP --> HEADER ] agent and configuration 
   //-------------------------------------------------------------------------------
    this.m_sync_txrx_agent = sync_txrx_agent::type_id::create("m_sync_txrx_agent", this );
    this.m_sync_txrx_agent.vif_str = "sync_txrx_agent_vif";
    this.m_sync_txrx_agent.cfg_str = "cfg";
    this.m_sync_txrx_config = sync_txrx_config::type_id::create("m_sync_txrx_config");
   // Set configurations for different TXRX agent instances
    uvm_config_db#(sync_txrx_config)::set(null, "", "cfg", m_sync_txrx_config);

  ////    this.m_diagnostic_reg_block = diagnostic_reg_block::type_id::create("m_diagnostic_reg_block", this);
  ////    m_diagnostic_reg_block.build ();
  ////    m_diagnostic_reg_block.lock_model ();
  ////    uvm_config_db #(diagnostic_reg_block)::set (null, "", "m_diagnostic_reg_block", m_diagnostic_reg_block);


   this.taichi_tmb_rm = taichi_tmb_reference_model::type_id::create("taichi_tmb_rm", this);
 endfunction
    
 function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  ///   m_apb2reg_predictor.map       = m_diagnostic_reg_block.default_map;
      this.diag_txrx_agent.mon.tx_analysis_port.connect(this.taichi_tmb_rm.diag_tx_imp);
      this.diag_txrx_agent.mon.rx_analysis_port.connect(this.taichi_tmb_rm.diag_rx_imp);
      this.oper_txrx_agent.mon.tx_analysis_port.connect(this.taichi_tmb_rm.oper_tx_imp);
      this.oper_txrx_agent.mon.rx_analysis_port.connect(this.taichi_tmb_rm.oper_rx_imp);

  endfunction
endclass
