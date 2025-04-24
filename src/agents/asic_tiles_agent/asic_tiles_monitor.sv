`ifndef ASIC_TILES_MONITOR_SV
`define ASIC_TILES_MONITOR_SV
//----------------------------------------------------------------
class asic_tiles_monitor extends uvm_monitor;
//----------------------------------------------------------------
    `uvm_component_utils(asic_tiles_monitor)

    virtual asic_tiles_agent_if vif;
    asic_tiles_config cfg;            // Configuration object
    asic_tiles_seq_item item;
    uvm_analysis_port #(asic_tiles_seq_item) analysis_port;

    // Timings in ns (from AS5912 Datasheet)
    localparam real MIN_SCLK_FREQ   = 0.1;  // MHz
    localparam real MAX_SCLK_FREQ   = 15.0; // MHz (14 MHz for daisy-chain)
    localparam int  T_SETUP         = 7;    // vif.SDI[spi_idx] setup time (ns)
    localparam int  T_HOLD          = 10;   // vif.SDI[spi_idx] hold time (ns)
    localparam int  T_DELAY         = 28;   // vif.SDO[spi_idx] delay time (ns)
    localparam int  T_INIT          = 40;   // SPI initialization time (ns)
    localparam int  T_BUSY          = 250;  // SPI busy time (ns)

    function new(string name="m_asic_tiles_monitor", uvm_component parent);
        super.new(name, parent);
        analysis_port = new("asic_tiles_analysis_port", this);
    endfunction

//----------------------------------------------------------------
    task run_phase(uvm_phase phase);
//----------------------------------------------------------------
        super.run_phase(phase);
                  // Loop for each SPI channel (0 to 3) to run in parallel
           
fork
        spi_protocol_checker(0);
        spi_protocol_checker(1);
        spi_protocol_checker(2);
        spi_protocol_checker(3);
join 
 endtask

//----------------------------------------------------------------
    task spi_protocol_checker(int spi_idx);
//----------------------------------------------------------------
        real clk_period, clk_freq, setup_time, hold_time, sdo_delay;
        time clk_rise, clk_fall, sdi_change, sdo_change, start_time, busy_end, init_start;
        int clk_count = 0;
        int cs_counter = 0;
        // Initialize variables to current time
        clk_rise = $time;
        clk_fall = $time;
        sdi_change = $time;
        sdo_change = $time;
        start_time = $time;
        busy_end = $time;
        init_start = $time;

// SPI protocol check for the current channel
forever begin
    @(negedge vif.SCS1[spi_idx]);  // Chip Select active

    init_start = $time;
    cs_counter++;
    // Check SPI busy time (tBUSY)
    busy_end = $time;
    BusyTimeCheck: assert ((busy_end - start_time) > T_BUSY)
        else `uvm_error("SPI_CHECK", $sformatf("SPI busy time violation: %0dns < %0dns", busy_end - start_time, T_BUSY))

    // Inner forever loop for clock frequency and timing checks
    forever begin
        // SPI Clock frequency check
        @(posedge vif.SCLK[spi_idx]);
        // Check SPI Initialization time (tINIT)
        InitTimeCheck: assert ($time - init_start > T_INIT)
            else `uvm_error("SPI_CHECK", $sformatf("SPI Init time violation: %0dns < %0dns", $time - init_start, T_INIT))
        clk_rise = $time / 1000;   // convert from ps to ns
        @(negedge vif.SCLK[spi_idx]);
        clk_fall = $time / 1000;   // convert from ps to ns
        clk_period = (clk_fall - clk_rise) / 1.0;
        clk_freq = 1000.0 / clk_period;
        clk_count++;
        ClockFrequencyCheck: assert (clk_freq > MIN_SCLK_FREQ && clk_freq < MAX_SCLK_FREQ)
            else `uvm_error("SPI_CHECK", $sformatf("SCLK[spi_idx] frequency violation: %0.2f MHz", clk_freq))
        
        // vif.SDI[spi_idx] Timing Checks
        @(vif.SDI[spi_idx]);
        sdi_change = $time;
        setup_time = clk_rise - sdi_change;
        SDISetupTimeCheck: assert (setup_time > T_SETUP)
            else `uvm_error("SPI_CHECK", $sformatf("sdi setup time violation: %0dns < %0dns", setup_time, T_SETUP))
        @(negedge vif.SCLK[spi_idx]);
        hold_time = $time - clk_fall;
        SDIHoldTimeCheck: assert (hold_time > T_HOLD)
            else `uvm_error("SPI_CHECK", $sformatf("sdi hold time violation: %0dns < %0dns", hold_time, T_HOLD))
        
        // vif.SDO[spi_idx] Timing Checks
        @(vif.SDO[spi_idx]);
        sdo_change = $time;
        sdo_delay = sdo_change - clk_fall;
        SDOTimeDelayCheck: assert (sdo_delay < T_DELAY)
            else `uvm_error("SPI_CHECK", $sformatf("sdo delay time violation: %0dns > %0dns", sdo_delay, T_DELAY))
        
        // Stop checking at end of transaction
        if (vif.SCS1[spi_idx] === 1) begin
            // Break only the inner forever loop
            break;
        end
    end // End of inner forever loop
    
    @(posedge vif.SCS1[spi_idx]);  // Chip Select deasserted
    start_time = $time;
end // End of outer forever loop
endtask

endclass: asic_tiles_monitor
`endif
