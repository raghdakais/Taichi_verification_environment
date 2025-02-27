// UVM reference_model for taichi_tmb environment
 import uvm_pkg::*; // Import UVM base classes

`uvm_analysis_imp_decl(_taichi_tmb_agent)                
class taichi_tmb_reference_model extends uvm_component;
    `uvm_component_utils(taichi_tmb_reference_model)
    
      uvm_analysis_imp_taichi_tmb_agent #(taichi_tmb_seq_item, taichi_tmb_reference_model) taichi_tmb_agent_imp;

     function new(string name = "taichi_tmb_reference_model", uvm_component parent = null);
		super.new(name, parent);
    endfunction



    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
       taichi_tmb_agent_imp = new("taichi_tmb_imp", this);
    endfunction
    
 function void write_taichi_tmb_agent(taichi_tmb_seq_item tr); //Have to add _rd due to imp_decl macro

    $display(" Transaction arraived to Reference Model" );

  endfunction

endclass
