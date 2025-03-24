// UVM reference_model for taichi_tmb environment
import uvm_pkg::*; // Import UVM base classes

//// `include "module1_coverage.sv"

// Declare analysis ports for different agents
`uvm_analysis_imp_decl(_taichi_tmb_agent)    
`uvm_analysis_imp_decl(_diag_tx)    
`uvm_analysis_imp_decl(_diag_rx)    
`uvm_analysis_imp_decl(_oper_tx)    
`uvm_analysis_imp_decl(_oper_rx)    

//---------------------------------------------------------------------------
class taichi_tmb_reference_model extends uvm_component;
//---------------------------------------------------------------------------
    // UVM macro to register the component with UVM factory
    `uvm_component_utils(taichi_tmb_reference_model)

    // Declare the analysis ports for the different agents
    uvm_analysis_imp_taichi_tmb_agent #(taichi_tmb_seq_item, taichi_tmb_reference_model) taichi_tmb_agent_imp;
    uvm_analysis_imp_diag_tx #(TXRX_seq_item, taichi_tmb_reference_model) diag_tx_imp;
    uvm_analysis_imp_diag_rx #(TXRX_seq_item, taichi_tmb_reference_model) diag_rx_imp;
    uvm_analysis_imp_oper_tx #(TXRX_seq_item, taichi_tmb_reference_model) oper_tx_imp;
    uvm_analysis_imp_oper_rx #(TXRX_seq_item, taichi_tmb_reference_model) oper_rx_imp;

// Memory storage (70 registers, each 32-bit)
bit [31:0]  EXPECTED_DIAG_OPER_RAM[600];
bit keep_default_diag[600] =  '{default: 1};
bit keep_default_oper[600] =  '{default: 1};
bit oper_wr_rd_en;

int counter=0;

  //----------------------------------------------------------------------------------------
   covergroup default_value_diag_reg_cg with function sample (int address);  
  //----------------------------------------------------------------------------------------
    coverpoint address {
                            bins default_checked[] = {[0  : DIAG_REGISTERS.size()-1]};
    }    
  endgroup

  //----------------------------------------------------------------------------------------
covergroup default_value_oper_reg_cg with function sample (int address);  
  //----------------------------------------------------------------------------------------
    coverpoint address {
                            bins default_checked[] = {[0  : OPER_REGISTERS.size()-1]};}    
  endgroup



  //----------------------------------------------------------------------------------------
    covergroup read_only_registers_cg  with function sample (int address); 
  //----------------------------------------------------------------------------------------
        coverpoint address {
            bins diagnostical_address[] = { 
                32'h406380, 32'h406390, 32'h406400, 32'h406410, 32'h406420, 
                32'h406424, 32'h406428, 32'h40642C, 32'h406440, 32'h406450, 
                32'h4064A0, 32'h4064B0, 32'h4064B4, 32'h4064B8, 32'h4064BC, 
                32'h4064C0, 32'h4064C4, 32'h4064C8, 32'h406500, 32'h406504, 
                32'h406508, 32'h40650C, 32'h406510, 32'h406518, 32'h406554, 
                32'h406830, 32'h406840, 32'h406860, 32'h406920, 32'h406930 
            };
             bins operational_address[] = { 32'h406740 };
        }
         
    endgroup

  //----------------------------------------------------------------------------------------
covergroup diagnostic_data_cg with function sample (bit[31:0] writing_data); 
  //----------------------------------------------------------------------------------------
  coverpoint writing_data {
    bins all_zeros   = {32'h0000_0000};
    bins all_ones    = {32'hFFFF_FFFF};
   bins one_bit_hit  = {
        32'h0000_0001, 32'h0000_0002, 32'h0000_0004, 32'h0000_0008,
        32'h0000_0010, 32'h0000_0020, 32'h0000_0040, 32'h0000_0080,
        32'h0000_0100, 32'h0000_0200, 32'h0000_0400, 32'h0000_0800,
        32'h0000_1000, 32'h0000_2000, 32'h0000_4000, 32'h0000_8000,
        32'h0001_0000, 32'h0002_0000, 32'h0004_0000, 32'h0008_0000,
        32'h0010_0000, 32'h0020_0000, 32'h0040_0000, 32'h0080_0000,
        32'h0100_0000, 32'h0200_0000, 32'h0400_0000, 32'h0800_0000,
        32'h1000_0000, 32'h2000_0000, 32'h4000_0000, 32'h8000_0000 };
    bins one_bit_cold = {
        32'hFFFE_FFFF, 32'hFFFD_FFFF, 32'hFFFB_FFFF, 32'hFFF7_FFFF,
        32'hFFEF_FFFF, 32'hFFDF_FFFF, 32'hFFBF_FFFF, 32'hFF7F_FFFF,
        32'hFEFF_FFFF, 32'hFDFF_FFFF, 32'hFBFF_FFFF, 32'hF7FF_FFFF,
        32'hEFFF_FFFF, 32'hDFFF_FFFF, 32'hBFFF_FFFF, 32'h7FFF_FFFF };
    bins alt_bits    = {32'hAAAA_AAAA, 32'h5555_5555};
    bins random_data = default;
  }
endgroup


  //----------------------------------------------------------------------------------------
covergroup operational_data_cg with function sample (bit[31:0] writing_data); 
  //----------------------------------------------------------------------------------------
  coverpoint writing_data {
    bins all_zeros   = {32'h0000_0000};
    bins all_ones    = {32'hFFFF_FFFF};
   bins one_bit_hit  = {
        32'h0000_0001, 32'h0000_0002, 32'h0000_0004, 32'h0000_0008,
        32'h0000_0010, 32'h0000_0020, 32'h0000_0040, 32'h0000_0080,
        32'h0000_0100, 32'h0000_0200, 32'h0000_0400, 32'h0000_0800,
        32'h0000_1000, 32'h0000_2000, 32'h0000_4000, 32'h0000_8000,
        32'h0001_0000, 32'h0002_0000, 32'h0004_0000, 32'h0008_0000,
        32'h0010_0000, 32'h0020_0000, 32'h0040_0000, 32'h0080_0000,
        32'h0100_0000, 32'h0200_0000, 32'h0400_0000, 32'h0800_0000,
        32'h1000_0000, 32'h2000_0000, 32'h4000_0000, 32'h8000_0000 };
    bins one_bit_cold = {
        32'hFFFE_FFFF, 32'hFFFD_FFFF, 32'hFFFB_FFFF, 32'hFFF7_FFFF,
        32'hFFEF_FFFF, 32'hFFDF_FFFF, 32'hFFBF_FFFF, 32'hFF7F_FFFF,
        32'hFEFF_FFFF, 32'hFDFF_FFFF, 32'hFBFF_FFFF, 32'hF7FF_FFFF,
        32'hEFFF_FFFF, 32'hDFFF_FFFF, 32'hBFFF_FFFF, 32'h7FFF_FFFF };
    bins alt_bits    = {32'hAAAA_AAAA, 32'h5555_5555};
    bins random_data = default;
  }
endgroup


 //----------------------------------------------------------------------------------------
 covergroup diagnostic_address_cg with function sample (bit[31:0] address); 
  //----------------------------------------------------------------------------------------
  coverpoint address {
    bins first_addr   = {32'h406300};  // First register
    bins last_addr    = {32'h406930};  // Last register (adjust range as needed)
    bins middle_addr  = {[32'h406300 : 32'h406930]}; // Middle registers
    bins invalid_addr = {32'h0000_00FF, 32'h0000_0FFF}; // Example reserved addresses
  }
endgroup
 //----------------------------------------------------------------------------------------
 covergroup operational_address_cg with function sample (bit[31:0] address); 
  //----------------------------------------------------------------------------------------
  coverpoint address {
    bins first_addr   = {32'h406300};  // First register
    bins last_addr    = {32'h4067E0};  // Last register (adjust range as needed)
    bins middle_addr  = {[32'h406300 : 32'h4067E0]}; // Middle registers
    bins invalid_addr = {32'h0000_00FF, 32'h0000_0FFF}; // Example reserved addresses
  }
endgroup
 //----------------------------------------------------------------------------------------
 covergroup diagnostic_write_read_to_oper_addr_cg with function sample (bit wr); 
  //----------------------------------------------------------------------------------------
  coverpoint wr {
    bins D_WRITE   = {1};  // First register
    bins D_READ    = {0};  // Last register (adjust range as needed)
  }
endgroup

 //----------------------------------------------------------------------------------------
 covergroup operational_write_read_to_diag_addr_cg with function sample (bit wr); 
  //----------------------------------------------------------------------------------------
  coverpoint wr {
    bins D_WRITE   = {1};  // First register
    bins D_READ    = {0};  // Last register (adjust range as needed)
  }
endgroup
// Constructor for the reference model
//----------------------------------------------------------------------------------------
      function new(string name = "taichi_tmb_reference_model", uvm_component parent = null);
//----------------------------------------------------------------------------------------
          super.new(name, parent); // Call the parent constructor
        default_value_diag_reg_cg         = new();
        read_only_registers_cg    = new();
        diagnostic_data_cg                = new();
        diagnostic_address_cg             = new();
        diagnostic_write_read_to_oper_addr_cg = new();
        operational_write_read_to_diag_addr_cg = new();
        operational_data_cg = new();
        operational_address_cg = new();
        default_value_oper_reg_cg = new();
    endfunction

//---------------------------------------------------------------------------
    // Build phase: initialize analysis ports
//---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
//---------------------------------------------------------------------------
     int ram_index=0;
        super.build_phase(phase); // Call build phase of parent
        // Instantiate the analysis ports with proper names
        taichi_tmb_agent_imp = new("taichi_tmb_imp", this);
        diag_tx_imp = new("diag_tx_imp", this);
        diag_rx_imp = new("diag_rx_imp", this);
        oper_tx_imp = new("oper_tx_imp", this);
        oper_rx_imp = new("oper_rx_imp", this);
    



// Update EXPECTED_DIAG_OPER_RAM with default values from DIAG_REGISTERS
foreach (DIAG_REGISTERS[i]) begin
     ram_index = (DIAG_REGISTERS[i].address - BASE_REG_ADDRESS)/4 ;
    EXPECTED_DIAG_OPER_RAM[ram_index] = DIAG_REGISTERS[i].default_value;
end

// Update EXPECTED_DIAG_OPER_RAM with default values from DIAG_REGISTERS
foreach (OPER_REGISTERS[j]) begin
     ram_index = (OPER_REGISTERS[j].address - BASE_REG_ADDRESS)/4 ;
    EXPECTED_DIAG_OPER_RAM[ram_index] = OPER_REGISTERS[j].default_value;
end
endfunction
    
//---------------------------------------------------------------------------
    // Function to write diag_tx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_diag_tx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------

// Check if the command is a WRITE operation
 if(item.command == "[WRITE]")
 begin   
      // Loop through diagnostic registers to check if the address is writable and update expected regbank
    foreach (DIAG_REGISTERS[i]) begin
        read_only_registers_cg.sample(item.address);
        diagnostic_data_cg.sample(item.wr_data);
        diagnostic_address_cg.sample(item.address);
        if (item.address == DIAG_REGISTERS[i].address && DIAG_REGISTERS[i].is_writable) 
        begin
            keep_default_diag[i] = 0;
            EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] = item.wr_data; 
            break;
        end   
     end  

     // Loop to check if diag interface is trying to access to opererational registers
    foreach (OPER_REGISTERS[i]) 
        if (OPER_REGISTERS[i].address == item.address) 
             diagnostic_write_read_to_oper_addr_cg.sample(1); 
 end

   if(item.command == "[READ]");
 begin  
     // Loop through the operational register array and compare the address
      foreach (OPER_REGISTERS[i]) 
        if (OPER_REGISTERS[i].address == item.address) 
             diagnostic_write_read_to_oper_addr_cg.sample(0); 
 end
   endfunction

//---------------------------------------------------------------------------
    // Function to write diag_tx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_oper_tx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------

// Check if the command is a WRITE operation
 if(item.command == "[WRITE]")
 begin   
      // Loop through diagnostic registers to check if the address is writable and update expected regbank
    foreach (OPER_REGISTERS[i]) begin
        read_only_registers_cg.sample(item.address);
        operational_data_cg.sample(item.wr_data);
        operational_address_cg.sample(item.address);
        if (item.address == OPER_REGISTERS[i].address && OPER_REGISTERS[i].is_writable) 
        begin
            keep_default_oper[i] = 0;
            EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] = item.wr_data; 
            break;
        end   
     end  

     // Loop to check if oper interface is trying to access to diagnostical registers
    foreach (DIAG_REGISTERS[i]) 
        if (DIAG_REGISTERS[i].address == item.address) 
           operational_write_read_to_diag_addr_cg.sample(1); 
 end


   if(item.command == "[READ]");
 begin  
     // Loop through the operational register array and compare the address
      foreach (DIAG_REGISTERS[i]) 
        if (DIAG_REGISTERS[i].address == item.address) 
           operational_write_read_to_diag_addr_cg.sample(0); 
 end

   endfunction

//---------------------------------------------------------------------------
    // Function to write diag_tx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_diag_rx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------

// Check if the command is a WRITE operation
 if(item.command == "[READ_BACK_ACK]")
 begin   
      // Loop through diagnostic registers to check if the address is writable
    //-------------------------------------------
    foreach (DIAG_REGISTERS[i]) begin
    //-------------------------------------------
        if (item.address == DIAG_REGISTERS[i].address ) 
        begin
            if(keep_default_diag[i])
              default_value_diag_reg_cg.sample(i);
       
           if(item.rd_data != EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] )
              begin  
              uvm_report_error (get_type_name (), $sformatf ("[ERROR] [DIAGNOSTICAL] READ DATA IS NOT AS EXPECTED"));
              $display("[ADDRESS ] -  0x%h", item.address );
              $display("[EXPECTED] -  0x%h", EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] );
              $display("[ ACTUAL ] -  0x%h", item.rd_data );
              end
              else begin
                `uvm_info(get_type_name(),  $sformatf("[PASSED] [DIAGNOSTICAL] READ DATA IS AS EXPECTED - ADDRESS  [0x%h] ",item.address), UVM_DEBUG)      
              end
          break;
        end   
     end   
 end
  
endfunction



//---------------------------------------------------------------------------
    // Function to write oper_txrx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_oper_rx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------
 
 // Check if the command is a WRITE operation
 if(item.command == "[READ_BACK_ACK]")
 begin   
      // Loop through diagnostic registers to check if the address is writable
    //-------------------------------------------
    foreach (OPER_REGISTERS[i]) begin
    //-------------------------------------------
        if (item.address == OPER_REGISTERS[i].address ) 
        begin
            if(keep_default_oper[i])
              default_value_oper_reg_cg.sample(i);
       
           if(item.rd_data != EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] )
              begin  
              uvm_report_error (get_type_name (), $sformatf ("[ERROR] [OPERATIONAL] READ DATA IS NOT AS EXPECTED"));
              $display("[ADDRESS ] -  0x%h", item.address );
              $display("[EXPECTED] -  0x%h", EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] );
              $display("[ ACTUAL ] -  0x%h", item.rd_data );
              end
              else begin
                `uvm_info(get_type_name(),  $sformatf("[PASSED] [OPERATIONAL] READ DATA IS AS EXPECTED - ADDRESS  [0x%h] ",item.address), UVM_DEBUG)      
              end
          break;
        end   
     end   
 end
  endfunction

//---------------------------------------------------------------------------
    // Function to write taichi_tmb_agent transactions to the reference model
//---------------------------------------------------------------------------
    function void write_taichi_tmb_agent(taichi_tmb_seq_item tr); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------
        $display(" Transaction arrived to Reference Model"); // Display message indicating transaction arrival
    endfunction

endclass
