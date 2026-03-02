// UVM environment for taichi_tmb environment
class taichi_tmb_env extends uvm_env;
    // Environment setup here
    `uvm_component_utils(taichi_tmb_env)
    
     TXRX_agent diag_txrx_agent;
     TXRX_agent oper_txrx_agent;
     TXRX_agent buffer_txrx_agent;
     sync_txrx_agent m_sync_txrx_agent;
     controllers_agent m_controllers_agent;
     asic_tiles_agent m_asic_tiles_agent;
     buffer_tx_agent m_buffer_tx_agent;
     data_out_agent m_data_out_agent;
  // Configuration objects created in the environment
     TXRX_config diag_txrx_config;
     TXRX_config oper_txrx_config;
     sync_txrx_config m_sync_txrx_config;
     TXRX_config buffer_txrx_config;
     controllers_config m_controllers_config;    
     asic_tiles_config m_asic_tiles_config;
     buffer_tx_config m_buffer_tx_config;
     data_out_config m_data_out_config;

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
  //-------------------------------------------------------------------------------
   // Creating ASIC TILES AGENT AND CONFIGURATION 
   //-------------------------------------------------------------------------------
    this.m_asic_tiles_agent = asic_tiles_agent::type_id::create("m_asic_tiles_agent", this );
    this.m_asic_tiles_agent.vif_str = "asic_tiles_agent_vif";
    this.m_asic_tiles_config = asic_tiles_config::type_id::create("m_asic_tiles_config");
   // Set configurations for different TXRX agent instances
    uvm_config_db#(asic_tiles_config)::set(null, "", "cfg", m_asic_tiles_config);
  //-------------------------------------------------------------------------------
   // Creating BUFFER TX  AGENT AND CONFIGURATION 
   //-------------------------------------------------------------------------------
    this.m_buffer_tx_agent = buffer_tx_agent::type_id::create("m_buffer_tx_agent", this );
    this.m_buffer_tx_agent.vif_str = "buffer_tx_agent_vif";
    this.m_buffer_tx_config = buffer_tx_config::type_id::create("m_buffer_tx_config");
   // Set configurations for different TXRX agent instances
    uvm_config_db#(buffer_tx_config)::set(null, "", "cfg", m_buffer_tx_config);
 //-------------------------------------------------------------------------------
   // Creating DATA OUT  TX  AGENT AND CONFIGURATION 
   //-------------------------------------------------------------------------------
    this.m_data_out_agent = data_out_agent::type_id::create("m_data_out_agent", this );
    this.m_data_out_agent.vif_str = "data_out_agent_vif";
    this.m_data_out_config = data_out_config::type_id::create("m_data_out_config");
   // Set configurations for different TXRX agent instances
    uvm_config_db#(data_out_config)::set(null, "", "cfg", m_data_out_config);


   this.taichi_tmb_rm = taichi_tmb_reference_model::type_id::create("taichi_tmb_rm", this);
 endfunction
    
 function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  ///   m_apb2reg_predictor.map       = m_diagnostic_reg_block.default_map;
      this.diag_txrx_agent.mon.tx_analysis_port.connect(this.taichi_tmb_rm.diag_tx_imp);
      this.diag_txrx_agent.mon.rx_analysis_port.connect(this.taichi_tmb_rm.diag_rx_imp);
      this.oper_txrx_agent.mon.tx_analysis_port.connect(this.taichi_tmb_rm.oper_tx_imp);
      this.oper_txrx_agent.mon.rx_analysis_port.connect(this.taichi_tmb_rm.oper_rx_imp);
      this.m_sync_txrx_agent.mon.analysis_port.connect(this.taichi_tmb_rm.sync_tx_imp);
      this.m_data_out_agent.mon.analysis_port.connect(this.taichi_tmb_rm.data_out_rx_imp);
      this.m_buffer_tx_agent.mon.analysis_port.connect(this.taichi_tmb_rm.buffer_tx_imp);

  endfunction
endclass
