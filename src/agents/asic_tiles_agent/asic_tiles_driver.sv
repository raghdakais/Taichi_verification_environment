`ifndef ASIC_TILES_DRIVER_SV
`define ASIC_TILES_DRIVER_SV
//----------------------------------------------------------------
class asic_tiles_driver extends uvm_driver #(asic_tiles_seq_item);
//----------------------------------------------------------------
    `uvm_component_utils(asic_tiles_driver)

    virtual asic_tiles_agent_if vif;
    asic_tiles_config cfg;  // Configuration object
    bit  rx_in_vals[$];      // Queue to store the serial rx_in values

    function new(string name = "m_asic_tiles_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
     bit data_file;
     bit [7:0] data_to_if;
        super.run_phase(phase);

        // Wait for reset to be deasserted
        wait_for_reset();

        // Ensure that the CSV file is read before proceeding
        read_rx_in_csv("C:/scripts/TAICHI_Repo/Taichi_verification_environment/src/agents/asic_tiles_agent/iladata_packet_40bit_dw.csv");

        fork
            begin
                @(posedge vif.SYNC);
                forever begin
                    if (rx_in_vals.size() > 0)         
                     for (int i = 0 ; i <=7 ; i++)     
                      data_to_if[i] = rx_in_vals.pop_front(); 
                     for (int i = 0 ; i <=7 ; i++) begin
                         @(posedge vif.clk);
                         vif.DATA1 = {4{data_to_if[i]}};  // Replicates the bit across all 4 bits
                         vif.DATA2 = vif.DATA1;              // Assign DATA1 to DATA2
                     end
                //     $display("data to if is %b ",data_to_if );
                 //    $stop;
                end
            end

            begin
                forever begin
                    seq_item_port.get_next_item(req);

                    // Assign values to output signals
                    vif.SDO   <= req.SDO;
                    vif.ACO   <= req.ACO;
                    vif.ACO_N <= req.ACO_N;

                    @(posedge vif.clk);

                    seq_item_port.item_done(); // Indicate completion of the transaction
                end
            end
        join
    endtask

//----------------------------------------------------------------
    // Task to read rx_in values from a CSV file and store them serially
    task read_rx_in_csv(input string file_name);
//----------------------------------------------------------------
        string line;
         string tokens[$]; // dynamic array of string tokens
        int cols[5];
        int FILE;

        // Open the CSV file
        FILE = $fopen(file_name, "r");
        if (FILE == 0) begin
            `uvm_fatal(get_type_name(), $sformatf("Failed to open CSV file: %s", file_name));
        end

        // Read each line from the CSV file
        while ($fgets(line, FILE)) begin
            // Parse the line into columns (assuming 5 columns in CSV)
            $sscanf(line, "%d,%d,%d,%d,%d", cols[0], cols[1], cols[2], cols[3], cols[4]);
            rx_in_vals.push_back(cols[3]);  // Store the rx_in[2:2] value
        end      
        $fclose(FILE);
    endtask

//----------------------------------------------------------------
    // Task to wait for reset deassertion
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
                @(negedge vif.rst);
                reset_deasserted = 1;
                @(posedge vif.clk);
            end

            // Timeout logic
            begin
                repeat (cfg.timeout_cycles) @(posedge vif.clk);
                if (!reset_deasserted) begin
                    `uvm_fatal(get_type_name(), $sformatf("Timeout waiting for reset deassertion after %0d cycles!", cfg.timeout_cycles))
                end
            end
        join_any
        disable fork; // Ensure the other process stops execution
    endtask
endclass: asic_tiles_driver
`endif
