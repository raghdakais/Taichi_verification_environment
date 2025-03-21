// UVM reference_model for taichi_tmb environment
import uvm_pkg::*; // Import UVM base classes

//// `include "module1_coverage.sv"

// Declare analysis ports for different agents
`uvm_analysis_imp_decl(_taichi_tmb_agent)    
`uvm_analysis_imp_decl(_diag_tx)    
`uvm_analysis_imp_decl(_diag_rx)    
`uvm_analysis_imp_decl(_oper_txrx)    

//---------------------------------------------------------------------------
class taichi_tmb_reference_model extends uvm_component;
//---------------------------------------------------------------------------
    // UVM macro to register the component with UVM factory
    `uvm_component_utils(taichi_tmb_reference_model)

    // Declare the analysis ports for the different agents
    uvm_analysis_imp_taichi_tmb_agent #(taichi_tmb_seq_item, taichi_tmb_reference_model) taichi_tmb_agent_imp;
    uvm_analysis_imp_diag_tx #(TXRX_seq_item, taichi_tmb_reference_model) diag_tx_imp;
    uvm_analysis_imp_diag_rx #(TXRX_seq_item, taichi_tmb_reference_model) diag_rx_imp;
    uvm_analysis_imp_oper_txrx #(TXRX_seq_item, taichi_tmb_reference_model) oper_txrx_imp;

// Memory storage (70 registers, each 32-bit)
bit [31:0]  EXPECTED_DIAG_OPER_RAM[600];
bit keep_default_diag[600] =  '{default: 1};
bit oper_wr_rd_en;

int counter=0;
// Define coverage points for registers
/////    covergroup diag_reg_cg with function sample (int index);
/////        // Coverage for R/W registers
/////        foreach (DIAG_REGISTERS[i]) begin
/////            if (DIAG_REGISTERS[i].keep_default_diag) begin
/////                coverpoint DIAG_REGISTERS[i].address: bins base_addr[] = {DIAG_REGISTERS[i].address};
/////            end
/////        end
/////    endgroup




covergroup default_value_diag_reg_cg with function sample (int address);
    
    all_diagnostics_registers :  coverpoint address {
                            bins default_checked[] = {[0  : DIAG_REGISTERS.size()-1]};
    } 

    
  endgroup



    // Constructor for the reference model
    function new(string name = "taichi_tmb_reference_model", uvm_component parent = null);
        super.new(name, parent); // Call the parent constructor
        default_value_diag_reg_cg = new();
    endfunction

//---------------------------------------------------------------------------
    // Build phase: initialize analysis ports
//---------------------------------------------------------------------------
    function void build_phase(uvm_phase phase);
//---------------------------------------------------------------------------
        super.build_phase(phase); // Call build phase of parent
        // Instantiate the analysis ports with proper names
        taichi_tmb_agent_imp = new("taichi_tmb_imp", this);
        diag_tx_imp = new("diag_tx_imp", this);
        diag_rx_imp = new("diag_rx_imp", this);
        oper_txrx_imp = new("oper_txrx_imp", this);




// Update EXPECTED_DIAG_OPER_RAM with default values from DIAG_REGISTERS
foreach (DIAG_REGISTERS[i]) begin
    int ram_index = (DIAG_REGISTERS[i].address - BASE_REG_ADDRESS)/4 ;
    // Assign the default value from DIAG_REGISTERS to EXPECTED_DIAG_OPER_RAM at the calculated index
    EXPECTED_DIAG_OPER_RAM[ram_index] = DIAG_REGISTERS[i].default_value;
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
      // Loop through diagnostic registers to check if the address is writable
    foreach (DIAG_REGISTERS[i]) begin
        if (item.address >= DIAG_REGISTERS[i].address && 
            DIAG_REGISTERS[i].is_writable) 
        begin
            keep_default_diag[i] = 0;
            EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] = item.wr_data; 
            break;
        end   
     end   
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
    foreach (DIAG_REGISTERS[i]) begin

        //----if register is wr mode , read from expected value ----------------
        if (item.address == DIAG_REGISTERS[i].address ) 
        begin
                if(keep_default_diag[i])
                     default_value_diag_reg_cg.sample(i);
       
           if(item.rd_data != EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] )
              begin  
              uvm_report_error (get_type_name (), $sformatf ("[ERROR] READ DATA IS NOT AS EXPECTED"));
              $display("[ADDRESS ] -  %h", item.address );
              $display("[EXPECTED] -  %h", EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] );
              $display("[ ACTUAL ] -  %h", item.rd_data );
              end
              else begin
                `uvm_info(get_type_name(),  $sformatf("[PASSED] READ DATA IS AS EXPECTED - ADDRESS  [0x%h] ",item.address), UVM_DEBUG)      
              end
          break;
        end   
     end   
 end
  
endfunction


















//---------------------------------------------------------------------------
    // Function to write oper_txrx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_oper_txrx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------
        $display(" write_oper_txrx Transaction arrived to Reference Model"); // Display message indicating transaction arrival
    endfunction

//---------------------------------------------------------------------------
    // Function to write taichi_tmb_agent transactions to the reference model
//---------------------------------------------------------------------------
    function void write_taichi_tmb_agent(taichi_tmb_seq_item tr); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------
        $display(" Transaction arrived to Reference Model"); // Display message indicating transaction arrival
    endfunction

endclass
