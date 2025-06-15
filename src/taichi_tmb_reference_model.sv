// UVM reference_model for taichi_tmb environment
import uvm_pkg::*; // Import UVM base classes

//// `include "module1_coverage.sv"

// Declare analysis ports for different agents
`uvm_analysis_imp_decl(_taichi_tmb_agent)    
`uvm_analysis_imp_decl(_diag_tx)    
`uvm_analysis_imp_decl(_diag_rx)    
`uvm_analysis_imp_decl(_oper_tx)    
`uvm_analysis_imp_decl(_oper_rx)    
`uvm_analysis_imp_decl(_sync_tx)    
`uvm_analysis_imp_decl(_data_out_rx)    
`uvm_analysis_imp_decl(_buffer_tx)    

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
    uvm_analysis_imp_sync_tx #(sync_txrx_seq_item, taichi_tmb_reference_model) sync_tx_imp;
    uvm_analysis_imp_data_out_rx #(data_out_seq_item, taichi_tmb_reference_model) data_out_rx_imp;
    uvm_analysis_imp_buffer_tx #(buffer_tx_seq_item, taichi_tmb_reference_model) buffer_tx_imp;

int  MAX_CAPACITY = 20;



// Memory storage (70 registers, each 32-bit)
bit [31:0]  EXPECTED_DIAG_OPER_RAM[600];
bit keep_default_diag[600] =  '{default: 1};
bit keep_default_oper[600] =  '{default: 1};
bit oper_wr_rd_en;
 virtual taichi_tmb_agent_if vif;

int diag_fifo_wr_count = 0;
int oper_fifo_wr_count = 0;

bit expected_Mu_activate = 1;
bit expected_module_synth_data = 0;
bit expected_asics_synth_data = 0;
bit expected_data_synth = 0;
bit expected_raw_data_mode = 0;
bit expected_calibrated_data_mode = 0;
byte  expected_sync_header_buffer[$];
bit[15:0] actual_sync_header_buffer[$];
sync_txrx_seq_item sync_tx_items_fifo[$];
bit read_buffer_req = 0;
bit buffer_empty = 0;
bit buffer_full = 0;
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
    covergroup diagnostical_read_only_registers_cg  with function sample (int address); 
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
        }
         
    endgroup


//----------------------------------------------------------------------------------------
    covergroup operational_read_only_registers_cg  with function sample (int address); 
  //----------------------------------------------------------------------------------------
        coverpoint address {
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

  //----------------------------------------------------------------------------------------
   covergroup read_buffer_req_cg with function sample ();  
  //----------------------------------------------------------------------------------------
    rd_req_while_buffer_empty: coverpoint ( read_buffer_req  &&  buffer_empty);
    no_rd_req_cause_buffer_full: coverpoint ( !read_buffer_req  &&  buffer_full);
  endgroup




// Constructor for the reference model
//----------------------------------------------------------------------------------------
      function new(string name = "taichi_tmb_reference_model", uvm_component parent = null);
//----------------------------------------------------------------------------------------
          super.new(name, parent); // Call the parent constructor
        default_value_diag_reg_cg         = new();
        diagnostical_read_only_registers_cg    = new();
        operational_read_only_registers_cg    = new();
        diagnostic_data_cg                = new();
        diagnostic_address_cg             = new();
        diagnostic_write_read_to_oper_addr_cg = new();
        operational_write_read_to_diag_addr_cg = new();
        operational_data_cg = new();
        operational_address_cg = new();
        default_value_oper_reg_cg = new();
        read_buffer_req_cg = new();
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
        sync_tx_imp = new("sync_tx_imp", this);
        data_out_rx_imp = new("data_out_rx_imp", this);
        buffer_tx_imp = new("buffer_tx_imp", this);
    

  if (!uvm_config_db#(virtual taichi_tmb_agent_if)::get(this, "", "vif", vif)) begin
            uvm_report_fatal (get_type_name (), $sformatf ("[FATAL] Virtual taichi_tmb_agent_vif interface not found for taichi_tmb agent"));
        end


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



   task run_phase(uvm_phase phase);
   

fork
begin
    forever
      begin
        @(posedge read_buffer_req );
        @ (posedge vif.clk);
        read_buffer_req = 0;
      end
end

begin
       forever
           begin
            @ (posedge vif.clk);
             if (sync_tx_items_fifo.size() == 0)
               buffer_empty = 1;
             else
               buffer_empty = 0;
           end
end
join_none
   endtask







//---------------------------------------------------------------------------
    // Function to write data_out rx transactions to the reference model
//---------------------------------------------------------------------------
function void write_buffer_tx(buffer_tx_seq_item item); 
//---------------------------------------------------------------------------

$display(" buffer read requested");
$display(" address :  [0x%h]", item.buf_ptr_address_sig  );

read_buffer_req = 1;
read_buffer_req_cg.sample();

endfunction


//---------------------------------------------------------------------------
    // Function to write data_out rx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_data_out_rx(data_out_seq_item item); 
//---------------------------------------------------------------------------
byte actual_sync_header_word;
byte  expected_sync_header_word;
bit[15:0] expected_header_fifo[$];
int data_out_packet_size;
sync_txrx_seq_item sync_tx_items;

actual_sync_header_buffer = item.header_buffer; 
data_out_packet_size = item.data_out_packet_size;

if (sync_tx_items_fifo.size() == 0) begin
  `uvm_error(get_type_name(), "sync_tx_items_fifo is empty! Cannot pop.")
  return;
end
sync_tx_items = sync_tx_items_fifo.pop_front();

if (sync_tx_items == null) begin
  `uvm_error(get_type_name(), "sync_tx_items is null after pop_front()!")
  return;
end

// Safe to access now
expected_header_fifo = sync_tx_items.expected_data_out_fifo;
//while( sync_tx_items_fifo.size>0  )
while( data_out_packet_size>0  )
begin
  data_out_packet_size--;
  expected_sync_header_word =  expected_header_fifo.pop_front() ;
  actual_sync_header_word   = actual_sync_header_buffer.pop_front();
if(expected_sync_header_word != actual_sync_header_word )
begin
   uvm_report_error (get_type_name (), $sformatf ("[ERROR] [DATA OUT - SYNC HEADER]  DATA IS NOT AS EXPECTED"));
   $display("[EXPECTED] -  0x%h", expected_sync_header_word );
   $display("[ ACTUAL ] -  0x%h", actual_sync_header_word );
   $display("[ SYNC_ITEM_ID ] -  0x%d", sync_tx_items.item_id );
  end
end

////   else
////    begin
////      uvm_report_error (get_type_name (), $sformatf ("[ERROR] [DATA OUT] Recieved without sync request"));
////    end
endfunction



   
//---------------------------------------------------------------------------
    // Function to write sync tx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_sync_tx(sync_txrx_seq_item item); 
//---------------------------------------------------------------------------
  // Sanity check: ensure item is not null
    if (item == null) begin
        `uvm_error(get_type_name(), "Null item received in write_sync_tx. Ignoring push.")
        return;
    end
////   expected_sync_header_buffer = item.header_buffer; 
sync_tx_items_fifo.push_back(item );
if (sync_tx_items_fifo.size() == MAX_CAPACITY)
buffer_full = 1;
endfunction



//---------------------------------------------------------------------------
    // Function to write diag_tx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_diag_tx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------

// Check if the command is a WRITE operation
 if(item.command == "[WRITE]")
 begin   
    diag_fifo_wr_count++;
      // Loop through diagnostic registers to check if the address is writable and update expected regbank
    foreach (DIAG_REGISTERS[i]) begin
        diagnostical_read_only_registers_cg.sample(item.address);
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

if ( EXPECTED_DIAG_OPER_RAM[ASICS_DATA_CRC_ERROR_IDX] !=0)
    EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][9] = 1;


    oper_fifo_wr_count++;
      // Loop through diagnostic registers to check if the address is writable and update expected regbank
    foreach (OPER_REGISTERS[i]) begin
        operational_read_only_registers_cg.sample(item.address);
        operational_data_cg.sample(item.wr_data);
        operational_address_cg.sample(item.address);

        if (item.address == OPER_REGISTERS[i].address && OPER_REGISTERS[i].is_writable) 
        begin
            keep_default_oper[i] = 0;
            if(item.address == 'h406660    ) // TODO : check with Evgenue
            EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4][31:24] = item.wr_data[31:24]; 
            else
                EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] = item.wr_data; 
            break;
        end  

                // Data Processing Mode Selection Based on Register 0xA0X06424:
        // If bit 0 = '0' and bit 5 = '1': 
        //    M – Module Synthetic Data (bypasses ASICs, no Mu processing)
        // Else if bit 0 = '0' and bit 6 = '1': 
        //    A – ASIC Synthetic Data (no Mu processing)
        // Else if bits [2:0] = "X11": 
        //    C – Log2(Calibrated Data/IP) (Mu mode enabled)
        // Else if bits [2:0] = "100": 
        //    R – Raw Data (no Mu processing)
        // Otherwise: 
        //    X – Invalid Mode

        if (item.address == OPER_REGISTERS[i].address == ACTIVE_MU_ADDRESS)
        begin
           expected_Mu_activate =  item.wr_data[0];  
            EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][0] = expected_Mu_activate;
        end
        if( item.address == OPER_REGISTERS[i].address== Miscellaneous_REG_ADDRESS)
        begin
            expected_data_synth = item.wr_data[4];
            EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][5] = expected_data_synth;
        end
        if( EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][5]==1 && EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][0]==0   )  //Module Synthetic Data 
           begin
                expected_module_synth_data = 1 ;  // module Synth data
                expected_asics_synth_data  = 0 ;    
           end
        if( EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][6]==1 && EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][0]==0   )  //Module Synthetic Data 
          begin
            expected_asics_synth_data   = 1 ;  // asics Synth data
             expected_module_synth_data = 0 ;
          end
        if( EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][1:0]== 'b11)
          begin
             expected_calibrated_data_mode   = 1 ;  // asics Synth data
             expected_raw_data_mode = 0 ;
          end
        if( EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][2:0]== 'b100)
          begin
             expected_calibrated_data_mode   = 0 ;  // asics Synth data
             expected_raw_data_mode = 1 ;
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
bit address_found = 0;
// Check if the command is a WRITE operation
 if(item.command == "[READ_BACK_ACK]")
 begin   

        // Loop through diagnostic registers to check if the address is writable
    //-------------------------------------------
    foreach (DIAG_REGISTERS[i]) begin
    //-------------------------------------------
        if (item.address == DIAG_REGISTERS[i].address ) 
        begin
              ///--------update module status register  ------------//
    if ( diag_fifo_wr_count >0 )    // fifo not empty
      begin
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][21] = 1;  // Diagnostic Registers TX FIFO Not empty after send complete
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][22] = 0;  // Diagnostic Registers TX FIFO Empty before end of send
        diag_fifo_wr_count--;
      end
   else if( !keep_default_oper[i])
       begin
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][21] = 0;  // Diagnostic Registers TX FIFO Not empty after send complete
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][22] = 1;  // Diagnostic Registers TX FIFO Empty before end of send
       end

            if(keep_default_diag[i])
              default_value_diag_reg_cg.sample(i);
            address_found = 1;

//----- TODO REMOVE LATER -- THIS IS FOR DEBUG ---------------------------
 if ( item.address == DIAG_REGISTERS[7].address)
      EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX] = item.rd_data; 
//-------------------------------------------------------------------------

           if(item.rd_data !== EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] )
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
                 if(!address_found)
                `uvm_warning(get_type_name(),  $sformatf("[WARNING] [DIAGNOSTICAL] READ ADDRESS IS OUT OF RANGE  - ADDRESS  [0x%h] ",item.address)) ;     
  
 end
  
endfunction



//---------------------------------------------------------------------------
    // Function to write oper_txrx transactions to the reference model
//---------------------------------------------------------------------------
    function void write_oper_rx(TXRX_seq_item item); // The "_rd" suffix is needed due to imp_decl macro
//---------------------------------------------------------------------------
 
 bit address_found = 0;
 string data_error;
 // Check if the command is a WRITE operation
 if(item.command == "[READ_BACK_ACK]")
 begin   

 
      // Loop through diagnostic registers to check if the address is writable
    //-------------------------------------------
    foreach (OPER_REGISTERS[i]) begin
    //-------------------------------------------
        if (item.address == OPER_REGISTERS[i].address ) 
        begin
               ///--------update module status register  ------------//
    if ( oper_fifo_wr_count >0 )    // fifo not empty
      begin
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][19] = 1;  // Operational Registers TX FIFO Not empty after send complete
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][20] = 0;  // Operational Registers TX FIFO Empty before end of send
        oper_fifo_wr_count--;
      end
     else if( keep_default_oper[i])
       begin
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][19] = 0;  // Operational Registers TX FIFO Not empty after send complete
        EXPECTED_DIAG_OPER_RAM[MODULE_STATUS_REG_IDX][20] = 1;  // Operational Registers TX FIFO Empty before end of send
       end

            if(keep_default_oper[i])
              default_value_oper_reg_cg.sample(i);
            address_found = 1;
           if(item.rd_data !== EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] )
              begin  
              uvm_report_error (get_type_name (), $sformatf ("[ERROR] [OPERATIONAL] READ DATA IS NOT AS EXPECTED"));
              $display("[ADDRESS ] -  0x%h", item.address );
              $display("[EXPECTED] -  0x%h", EXPECTED_DIAG_OPER_RAM[(item.address - BASE_REG_ADDRESS)/4] );
              $display("[ ACTUAL ] -  0x%0h", item.rd_data );
       
              end
              else begin
                `uvm_info(get_type_name(),  $sformatf("[PASSED] [OPERATIONAL] READ DATA IS AS EXPECTED - ADDRESS  [0x%h] ",item.address), UVM_DEBUG)      
              end
          break;
        end   
     end   

            if(!address_found)
                `uvm_warning(get_type_name(),  $sformatf("[WARNING] [OPERATIONAL] READ ADDRESS IS OUT OF RANGE  - ADDRESS  [0x%h] ",item.address))      
         

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
