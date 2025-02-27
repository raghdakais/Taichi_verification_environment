`ifndef CONTROLLERS_DRIVER_SV
`define CONTROLLERS_DRIVER_SV
//----------------------------------------------------------------
class controllers_driver extends uvm_driver #(controllers_seq_item);
//----------------------------------------------------------------
    `uvm_component_utils(controllers_driver)

    virtual controllers_agent_if vif;
   controllers_config cfg;            // Configuration object

    function new(string name = "m_controllers_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
     super.run_phase(phase);
        // Wait for reset to be deasserted
        wait_for_reset();
        forever begin
            seq_item_port.get_next_item(req);

            // Drive data to the interface
            vif.data    <= req.data;
            vif.address <= req.address;
            vif.valid <= req.valid;
            @( posedge vif.clk);
            
            seq_item_port.item_done(); // Indicate completion of the transaction
        end
    endtask


//----------------------------------------------------------------
   // Task to wait for reset to deassert
  task wait_for_reset();
//----------------------------------------------------------------
    bit reset_deasserted = 0;
    `uvm_info(get_type_name(), "Waiting for reset...", UVM_DEBUG)
    
   // Check if vif is assigned before using it
        if (vif == null) begin
            `uvm_fatal(get_type_name(), "Virtual interface (vif) is NULL! Cannot wait for reset.")
        end

        // Check if cfg is assigned before using timeout_cycles
        if (cfg == null) begin
            `uvm_fatal(get_type_name(), "Configuration object (cfg) is NULL! Cannot proceed with timeout check.")
        end
    

    fork
    // Wait for reset deassertion
    begin
    //  wait (vif.rst == 1'b0);
      @(negedge vif.rst);
      reset_deasserted = 1;
      @(posedge vif.clk);
    end

    // Timeout logic
    begin
      repeat (cfg.timeout_cycles)
          @(posedge vif.clk);
      if (!reset_deasserted) begin
        `uvm_fatal(get_type_name(), $sformatf("Timeout waiting for reset deassertion after %0d cycles!", cfg.timeout_cycles))
      end
    end
  join_any 
    disable fork; // Ensure the other process stops execution
   
   endtask




    
endclass: controllers_driver
`endif
