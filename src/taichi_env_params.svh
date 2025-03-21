
// File: TXRX_agent_params.sv
`ifndef TXRX_AGENT_PARAMS_SV
`define TXRX_AGENT_PARAMS_SV

// Parameter definitions
// Configurable packet structure sizes of diagnostic txrx agent
`define   DIAG_HEADER_SIZE  2
`define   DIAG_DATA_SIZE    2
`define   DIAG_FOOTER_SIZE  2
// Configurable packet structure sizes of operational txrx agent
`define   OPER_HEADER_SIZE  2
`define   OPER_DATA_SIZE    2
`define   OPER_FOOTER_SIZE  2

parameter BASE_REG_ADDRESS   = 'h406300;
parameter END_REG_ADDRESS    = 'h406930;

// Define address ranges and their access types with default value for data
typedef struct {
    logic [31:0] address;    // Base address of the register
    bit is_writable;              // 1 for R/W, 0 for Read-Only (R)
    bit [31:0] default_value = 32'h00000000; // Default value for the register data
} diag_reg_t;

// Create an array of diagnostic register ranges
diag_reg_t DIAG_REGISTERS [] = '{
    '{32'h406300, 1, 32'h00000000},  // Error Injection Register (R/W)
    '{32'h406350, 1, 32'hFFFFFFFF},  // Status MASK Register (R/W)
    '{32'h406380, 0, 32'h00420000},  // RLT Buffer Size (R)
    '{32'h406390, 0, 32'h1F43CCF7},  // HD Buffer Size (R)
    '{32'h406400, 0, 32'h00401b00},  // Firmware Version (R)
    '{32'h406410, 0, 32'h00000000},  // Hardware Board Revision (R)
    '{32'h406420, 0, 32'h00000000},  // Voltage OK feedback from LDOs (R)
    '{32'h406424, 0, 32'h00000000},  // Module Status/Errors register (R)
    '{32'h406428, 0, 32'h00000000},  // Asics to FPGA SPI Errors (R)
    '{32'h40642C, 0, 32'h00000000},  // Asics Data CRC Error (R)
    '{32'h406440, 0, 32'h00000000},  // Read current HD Number of Slices (R)
    '{32'h406450, 0, 32'h00000000},  // IP Measured at Module (R)
    '{32'h4064A0, 0, 32'h20202020},  // AMS Asic packet CRC error counter (R)
    '{32'h4064B0, 0, 32'h30303030},  // AMS Asic Data Align Status (R)
    '{32'h4064B4, 0, 32'h30303030},  // AMS Asic Data Align Error (R)
    '{32'h4064B8, 0, 32'h00000000},  // Asics to FPGA SPI is working Correctly (R)
    '{32'h4064BC, 0, 32'h00000000},  // Asics Data CRC is Correct (R)
    '{32'h4064C0, 0, 32'h00000000},  // Compilation Date from Vivado (R)
    '{32'h4064C4, 0, 32'h00000000},  // Asics Raw Data Bypass Mode (R)
    '{32'h4064C8, 0, 32'h00000000},  // DDR3 related Errors (R)
    '{32'h4064D0, 1, 32'hFFFFFFFF},  // Clear Status/Errors register after read (R/W)
    '{32'h406500, 0, 32'h00000000},  // Tile1 Temperature (R)
    '{32'h406504, 0, 32'h00000000},  // Tile2 Temperature (R)
    '{32'h406508, 0, 32'h00000000},  // Tile3 Temperature (R)
    '{32'h40650C, 0, 32'h00000000},  // Tile4 Temperature (R)
    '{32'h406510, 0, 32'h01A00190},  // Module Temperature (Outlet/Inlet) (R)
    '{32'h406518, 0, 32'h00000000},  // Modules Weighted Moving Average Temperature (R)
    '{32'h40651C, 1, 32'h00000000},  // Selector for Diag. registers (R/W)
    '{32'h406520, 1, 32'h00000020},  // PID Coefficient – kP (R/W)
    '{32'h406524, 1, 32'h00000005},  // PID Coefficient – kI (R/W)
    '{32'h406528, 1, 32'h00000004},  // PID Coefficient – kD (R/W)
    '{32'h40652C, 1, 32'h00000080},  // PID Coefficient - kAW (R/W)
    '{32'h406530, 1, 32'h00000000},  // Heater Control (R/W)
    '{32'h406534, 1, 32'h00002100},  // PID Set Point (R/W)
    '{32'h406538, 1, 32'h00000004},  // Temperature Sensors Weighted Average CFG (R/W)
    '{32'h406540, 1, 32'h70251008},  // PID Stable_Tolerance (R/W)
    '{32'h406544, 1, 32'h000A0005},  // Set Temperature Sample and PID calc rates (R/W)
    '{32'h406548, 1, 32'h00000B00},  // Set Integral and Derivative Updating rates (R/W)
    '{32'h406550, 1, 32'h00000000},  // Temperature Stabilization Status and Errors (R/W)
    '{32'h406554, 0, 32'h00000000},  // Actual PWM Duty Cycle status (R)
    '{32'h4067A0, 1, 32'h000000FA},  // Bad Pixels High limit (R/W)
    '{32'h4067B0, 1, 32'h00000002},  // Bad Pixels Low limit (R/W)
    '{32'h4067C0, 1, 32'h00000010},  // Bad Pixels per Tile limit (R/W)
    '{32'h4067D0, 1, 32'h00000001},  // Miscellaneous – LED On/nOff (R/W)
    '{32'h406800, 1, 32'h00000000},  // Remote Programming - Address and Control register (R/W)
    '{32'h406820, 1, 32'h00000000},  // Reset Data FIFO and Errors (R/W)
    '{32'h406830, 0, 32'h00000000},  // Remote Programming Status (R)
    '{32'h406840, 0, 32'h00000000},  // Remote Programming FIFO Fill count (R)
    '{32'h406850, 1, 32'h00000000},  // Remote Programming Data Write into page buffer (R/W)
    '{32'h406860, 0, 32'h00000000},  // Remote Programming Data Read into page buffer (R)
    '{32'h406900, 1, 32'h00000000},  // NVRAM Address (R/W)
    '{32'h406910, 1, 32'h00000000},  // NVRAM Write Data & Operation (R/W)
    '{32'h406920, 0, 32'h00000000},  // NVRAM Read Data (R)
    '{32'h406930, 0, 32'h00000000}   // NVRAM Status (R)
};
`endif
