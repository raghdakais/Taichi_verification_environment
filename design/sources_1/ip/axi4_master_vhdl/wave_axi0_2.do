onerror {resume}
virtual type { \
{0xf DES}\
{0xe DES}\
{0xd DES}\
{0xc DES}\
{0xb DES}\
{0xa DES}\
{0x9 DES}\
{0x8 DES}\
{0x7 NOP}\
{0x6 ZQC}\
{0x5 RD}\
{0x4 WR}\
{0x3 ACT}\
{0x2 PRE}\
{0x1 REF}\
{0x0 MRS}\
{default RD}\
} DDR3_CMD
virtual type { \
{0xf NOP}\
{0xe NOP}\
{0xd NOP}\
{0xc NOP}\
{0xb NOP}\
{0xa NOP}\
{0x9 NOP}\
{0x8 NOP}\
{0x7 NOP}\
{0x6 ZQC}\
{0x5 RD}\
{0x4 WR}\
{0x3 ACT}\
{0x2 PRE}\
{0x1 REF}\
{0x0 MRS}\
{default RD}\
} SDR_CMD
quietly WaveActivateNextPane {} 0
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awaddr
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awlen
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awsize
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awburst
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awlock
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awcache
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awprot
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awqos
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awuser
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awvalid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_awready
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_wdata
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_wstrb
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_wlast
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_wuser
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_wvalid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_wready
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_bid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_bresp
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_buser
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_bvalid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_bready
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_araddr
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arlen
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arsize
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arburst
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arlock
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arcache
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arprot
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arqos
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_aruser
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arvalid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_arready
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_rid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_rdata
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_rresp
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_rlast
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_ruser
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_rvalid
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_rready
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_aclk
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_aresetn
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_init_axi_txn
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_txn_done
add wave -noupdate -group m00_top /axi4_master_vhdl_0_tb/DUT/m00_axi_error
add wave -noupdate -itemcolor {Sky Blue} /axi4_master_vhdl_0_tb/m00_axi_init_axi_txn
add wave -noupdate -itemcolor {Sky Blue} /axi4_master_vhdl_0_tb/m00_axi_aresetn
add wave -noupdate -itemcolor {Sky Blue} /axi4_master_vhdl_0_tb/m00_axi_aclk
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_TARGET_SLAVE_BASE_ADDR
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_ADDR_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_ARUSER_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_AWUSER_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_BURST_LEN
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_BUSER_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_DATA_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_ID_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_RUSER_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_M_AXI_WUSER_WIDTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_MASTER_LENGTH
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_NO_BURSTS_REQ
add wave -noupdate -expand -group AXI_params /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/C_TRANSACTIONS_NUM
add wave -noupdate -expand -group errors /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/ERROR
add wave -noupdate -expand -group errors /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/error_reg
add wave -noupdate -expand -group errors /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_resp_error
add wave -noupdate -expand -group errors /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_resp_error
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/init_txn_pulse
add wave -noupdate -itemcolor Aquamarine /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/mst_exec_state
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/compare_done
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/start_single_burst_write
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/start_single_burst_read
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/burst_write_active
add wave -noupdate -itemcolor Gold /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/writes_done
add wave -noupdate -itemcolor Gold /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/reads_done
add wave -noupdate -itemcolor Blue -radix unsigned /axi4_master_vhdl_0_tb/burst_len_cnt
add wave -noupdate -itemcolor Yellow -radix unsigned -childformat {{/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(4) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(3) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(2) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(1) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(0) -radix unsigned}} -subitemconfig {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(4) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(3) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(2) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(1) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter(0) {-height 15 -itemcolor Yellow -radix unsigned}} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_burst_counter
add wave -noupdate -itemcolor Yellow -radix unsigned -childformat {{/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(4) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(3) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(2) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(1) -radix unsigned} {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(0) -radix unsigned}} -subitemconfig {/axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(4) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(3) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(2) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(1) {-height 15 -itemcolor Yellow -radix unsigned} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter(0) {-height 15 -itemcolor Yellow -radix unsigned}} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_burst_counter
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/write_index
add wave -noupdate /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_index
add wave -noupdate -itemcolor Turquoise -radix unsigned /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/burst_size_bytes
add wave -noupdate -expand -group AXI_IF /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ACLK
add wave -noupdate -expand -group AXI_IF -divider {Write address channel}
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWADDR
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWVALID
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWREADY
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWLEN
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWSIZE
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWBURST
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWID
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWCACHE
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWLOCK
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWPROT
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWQOS
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_AWUSER
add wave -noupdate -expand -group AXI_IF -divider {Write data channel}
add wave -noupdate -expand -group AXI_IF -itemcolor {Spring Green} -radix unsigned /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_WDATA
add wave -noupdate -expand -group AXI_IF -itemcolor {Spring Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_WVALID
add wave -noupdate -expand -group AXI_IF -itemcolor {Spring Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_WREADY
add wave -noupdate -expand -group AXI_IF -itemcolor {Spring Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_WLAST
add wave -noupdate -expand -group AXI_IF -itemcolor {Spring Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_WSTRB
add wave -noupdate -expand -group AXI_IF -itemcolor {Spring Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_WUSER
add wave -noupdate -expand -group AXI_IF -divider {Write response channel}
add wave -noupdate -expand -group AXI_IF -itemcolor {Lime Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_BVALID
add wave -noupdate -expand -group AXI_IF -itemcolor {Lime Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_BREADY
add wave -noupdate -expand -group AXI_IF -itemcolor {Lime Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_BRESP
add wave -noupdate -expand -group AXI_IF -itemcolor {Lime Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_BID
add wave -noupdate -expand -group AXI_IF -itemcolor {Lime Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_BUSER
add wave -noupdate -expand -group AXI_IF -divider {Read Address channel}
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARADDR
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARBURST
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARCACHE
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARESETN
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARID
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARLEN
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARLOCK
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARPROT
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARQOS
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARREADY
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARSIZE
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARUSER
add wave -noupdate -expand -group AXI_IF -itemcolor {Green Yellow} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_ARVALID
add wave -noupdate -expand -group AXI_IF -divider {Read data channel}
add wave -noupdate -expand -group AXI_IF /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/read_index
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RDATA
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RVALID
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RREADY
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RLAST
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RID
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RRESP
add wave -noupdate -expand -group AXI_IF -itemcolor {Yellow Green} /axi4_master_vhdl_0_tb/DUT/U0/axi4_master_vhdl_v1_0_M00_AXI_inst/M_AXI_RUSER
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10110000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 329
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2007170 ps} {84258178 ps}
bookmark add wave bookmark0 {{32762 ns} {33190 ns}} 0
