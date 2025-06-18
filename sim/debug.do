onerror {resume}
quietly virtual signal -install /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1 { /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_HEADER_DATA_OUT(6 downto 0)} temp_num_from_ct_type
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider <NULL>
add wave -noupdate -group {Sig2 Sync} -color Magenta -itemcolor Magenta /taichi_tmb_tb/DUT/io_inst_1/lock2aclk_stop
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/io_inst_1/CLK50
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/io_inst_1/incr_RDY_delay_cnt
add wave -noupdate -group {Sig2 Sync} -radix unsigned /taichi_tmb_tb/DUT/io_inst_1/aclk_filter_cnt
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/io_inst_1/aclk_rise_detect
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/io_inst_1/aclk_master_i_int
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/io_inst_1/aclk_50m_rr
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/io_inst_1/aclk_period_saved
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/Diag_in_P
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/Diag_in_N
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/registers_inst_A/S_IDLY_CNT
add wave -noupdate -group {Sig2 Sync} /taichi_tmb_tb/DUT/registers_inst_A/S_EN
add wave -noupdate -divider <NULL>
add wave -noupdate -color Salmon -label Mu_activation /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/MU_CTRL(0)
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/MU_CTRL
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/Operational_DIAGNSOTICS
add wave -noupdate -divider <NULL>
add wave -noupdate -expand -group {IP --> HEADER} -color Magenta /taichi_tmb_tb/DUT/Sync_P
add wave -noupdate -expand -group {IP --> HEADER} -color Magenta /taichi_tmb_tb/DUT/SYNC
add wave -noupdate -expand -group {IP --> HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/sDataIn
add wave -noupdate -expand -group {IP --> HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/IP_DATA_OUT
add wave -noupdate -expand -group {IP --> HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/HEADER_DATA_OUT
add wave -noupdate -expand -group {IP --> HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_IP_pckt_valid
add wave -noupdate -expand -group {IP --> HEADER} -color Magenta /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/RX_IP_DATAVAL_HEADER_PINS/good_packet
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/params_ready
add wave -noupdate -color {Spring Green} /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_header_ready
add wave -noupdate -color {Spring Green} /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_stream_enable
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/HEADER_DATA_OUT
add wave -noupdate -expand -group SYNC_HEADER -color Cyan /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_RX_det_o
add wave -noupdate -expand -group SYNC_HEADER -color {Orange Red} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/F_ADDRA_R
add wave -noupdate -expand -group SYNC_HEADER -color {Orange Red} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/F_DOUT
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/fq_stream_enable
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/fs_merging_factor
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/fs_sequence_counter
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/GOOD_PACKET_RECEIVED
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/hd_ptr_address_from_sync
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/rlt_address_from_sync
add wave -noupdate -expand -group SYNC_HEADER /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/slice_merging_factor
add wave -noupdate -expand -group SYNC_HEADER -color Khaki -radix hexadecimal /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/temp_Num_of_Slices
add wave -noupdate /taichi_tmb_tb/DUT/taichi_slice_builder_1/reading_type
add wave -noupdate -divider <NULL>
add wave -noupdate /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/temp_num_from_ct_type
add wave -noupdate /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/read_seq_cnt
add wave -noupdate /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_HEADER_DATA_OUT
add wave -noupdate -divider <NULL>
add wave -noupdate -group {ASIC SPI } /taichi_tmb_tb/DUT/SCLK
add wave -noupdate -group {ASIC SPI } /taichi_tmb_tb/DUT/SCS1
add wave -noupdate -group {ASIC SPI } /taichi_tmb_tb/DUT/SCS2
add wave -noupdate -group {ASIC SPI } /taichi_tmb_tb/DUT/SDI
add wave -noupdate -group {ASIC SPI } /taichi_tmb_tb/DUT/SDO
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/tiles_if_g(0)/dummy_tile_for_pins_1/SCS1n_i
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_m/SCSn
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_s/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(3)/phoebe_controller_inst/configuring_sm_power
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_s/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(3)/phoebe_controller_inst/configuring_sm_regs
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_s/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(3)/phoebe_controller_inst/fifo_status_s
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_s/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(3)/phoebe_controller_inst/fifo_status
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_m/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(0)/phoebe_controller_inst/configuring_sm_regs
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_m/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(0)/phoebe_controller_inst/configuring_sm_power
add wave -noupdate -group {oper asic write} /taichi_tmb_tb/DUT/Tiles_managment_m/Phoebe_CntrlSpiSplitMem_inst/phoebe_cntrlspisplit_inst/spi_ams_gen(0)/SPI_AMS_CORE_inst/sm_spi
add wave -noupdate /taichi_tmb_tb/asic_tiles_vif/clk
add wave -noupdate /taichi_tmb_tb/DUT/Tiles_managment_m/Asic_data_gen(0)/Asic_data_inst/Phoebe_dat_IF_inst/InDatPhoebe_inst/pDataIn
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/SYNC
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/TILES_CLK
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/TILES_CLK_N
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/ACLK
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/SCLK
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/SCS1
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/SCS2
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/SDI
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/SDO
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/ACO
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/ACO_N
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/DATA1
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/DATA1_N
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/DATA2
add wave -noupdate -group ASIC_TILES /taichi_tmb_tb/DUT/DATA2_N
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/din
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/dout
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/empty
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/full
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/overflow
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/rd_clk
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/rd_data_count
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/rd_en
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/rst
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/underflow
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/valid
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/wr_clk
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/wr_data_count
add wave -noupdate -expand -group {write fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/data_sort_ddr3_wr_1/dcfifo_a/wr_en
add wave -noupdate -divider <NULL>
add wave -noupdate -group {BUFFER REQ } /taichi_tmb_tb/DUT/io_inst_1/RX_series7_1/pDataIn
add wave -noupdate -group {BUFFER REQ } /taichi_tmb_tb/DUT/Buffer_N
add wave -noupdate -group {BUFFER REQ } /taichi_tmb_tb/DUT/Buffer_P
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/clk
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/srst
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/din
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/wr_en
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/rd_en
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/dout
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/full
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/empty
add wave -noupdate -group fq_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_fifo2048x32_1/data_count
add wave -noupdate -group ev_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x32_1/clk
add wave -noupdate -group ev_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x32_1/data_count
add wave -noupdate -group ev_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x32_1/din
add wave -noupdate -group ev_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x32_1/dout
add wave -noupdate -group ev_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x32_1/empty
add wave -noupdate -group ev_ddr3_fifo /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x32_1/full
add wave -noupdate -group DDR3 /taichi_tmb_tb/DUT/ddr3_dq
add wave -noupdate -group DDR3 /taichi_tmb_tb/DUT/ddr3_dqs_n
add wave -noupdate -group DDR3 /taichi_tmb_tb/DUT/ddr3_dqs_p
add wave -noupdate -group DDR3 -color Gold /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/init_calib_complete
add wave -noupdate -group DDR3 -color Gold /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/INIT_DONE_A_O
add wave -noupdate /taichi_tmb_tb/DUT/slices_sorter_1/tile_sim_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/ACLK
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/ARESETN
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWADDR
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWLEN
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWSIZE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWBURST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWLOCK
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWCACHE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWPROT
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWREGION
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWQOS
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_AWREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WDATA
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WSTRB
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WLAST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_WREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_BID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_BRESP
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_BUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_BVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_BREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARADDR
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARLEN
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARSIZE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARBURST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARLOCK
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARCACHE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARPROT
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARREGION
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARQOS
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_ARREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RDATA
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RRESP
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RLAST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/S_AXI_RREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWADDR
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWLEN
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWSIZE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWBURST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWLOCK
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWCACHE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWPROT
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWREGION
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWQOS
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_AWREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WDATA
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WSTRB
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WLAST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_WREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_BID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_BRESP
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_BUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_BVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_BREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARADDR
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARLEN
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARSIZE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARBURST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARLOCK
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARCACHE
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARPROT
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARREGION
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARQOS
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_ARREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RDATA
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RRESP
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RLAST
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RUSER
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RVALID
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/M_AXI_RREADY
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/reset
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/s_aw_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/m_aw_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/s_w_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/m_w_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/s_b_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/m_b_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/s_ar_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/m_ar_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/s_r_data
add wave -noupdate -group {DDR - AXI} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/ddr3_axi_if_inst/u_DDR3_AXI_IF_mig/u_memc_ui_top_axi/u_axi_mc/axi_register_slice_d1/m_r_data
add wave -noupdate -group debug /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/m00_axi_awvalid
add wave -noupdate -group debug /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/m00_axi_awready
add wave -noupdate -group debug /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/test_waddr_offset
add wave -noupdate -group debug /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/m00_axi_wdata
add wave -noupdate -group debug /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/m00_axi_awaddr
add wave -noupdate -group debug /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/test_write_burst_len
add wave -noupdate -divider <NULL>
add wave -noupdate -expand -group {DATA OUT } -color {Violet Red} -itemcolor {Violet Red} -expand -subitemconfig {/taichi_tmb_tb/DUT/DATA_OUT(1) {-color {Violet Red} -height 15 -itemcolor {Violet Red}} /taichi_tmb_tb/DUT/DATA_OUT(0) {-color {Violet Red} -height 15 -itemcolor {Violet Red}}} /taichi_tmb_tb/DUT/DATA_OUT
add wave -noupdate -expand -group {DATA OUT } -color Turquoise /taichi_tmb_tb/DUT/TX_series7_1/TX_data_byte
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/data_out_tx_vif/start_package
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/TX_det_byte
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/data_out_tx_vif/end_package
add wave -noupdate -expand -group {DATA OUT } -color Yellow /taichi_tmb_tb/DUT/TX_series7_1/channel_data_sm_d
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/DATA_IN
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/read_fsm_error_128m
add wave -noupdate -expand -group {DATA OUT } -divider <NULL>
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/ecc_double_error
add wave -noupdate -expand -group {DATA OUT } -color {Orange Red} /taichi_tmb_tb/DUT/taichi_slice_builder_1/wr_cnt_saved
add wave -noupdate -expand -group {DATA OUT } -color {Orange Red} /taichi_tmb_tb/DUT/taichi_slice_builder_1/new_packet2tx_shr
add wave -noupdate -expand -group {DATA OUT } -color {Orange Red} /taichi_tmb_tb/DUT/taichi_slice_builder_1/mem_buf_packet_size_saved
add wave -noupdate -expand -group {DATA OUT } -color White /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/slices_num_valid
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/slices_num_temp
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/module_raw_header
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/q_128to40m_r
add wave -noupdate -expand -group {DATA OUT } -color White /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/FIFO_SEL_FSM_PS
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/h_a_received_40m
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/header_received_40m
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/rdempty_h_a_fifo
add wave -noupdate -expand -group {DATA OUT } /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/axi_rdata
add wave -noupdate -expand -group {DATA OUT } -divider <NULL>
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/dout
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/empty
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/full
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/rd_clk
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} -radix unsigned /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/rd_data_count
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/rd_en
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/rd_rst
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/valid
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/wr_clk
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/wr_en
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/din
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} -radix unsigned /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/wr_data_count
add wave -noupdate -expand -group {DATA OUT } -expand -group {ddr fifo} /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/read_ddr3_rd_1/fifo_dc_2k_32_1/wr_rst
add wave -noupdate -color Magenta /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/DATA_SORT_DOUT
add wave -noupdate -color Magenta /taichi_tmb_tb/DUT/use_ddr3_phy_g/ddr_driver_1/EVOLVING_DOUT
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/params_ready
add wave -noupdate -color Yellow /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_header_ready
add wave -noupdate -color Yellow /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_stream_enable
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_data_seq_ps
add wave -noupdate -color {Spring Green} /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_header_ready
add wave -noupdate -color {Spring Green} /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_stream_enable
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/fq_data_seq_ps
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/sys_clk
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/IP50
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/IP50_r
add wave -noupdate /taichi_tmb_tb/DUT/Tiles_managment_s/IP
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_header_fifo_data_count
add wave -noupdate /taichi_tmb_tb/DUT/memory_buffer_if_1/ev_fifo2048x16_data_count
add wave -noupdate -divider {DIAG REG}
add wave -noupdate -expand -group Operational /taichi_tmb_tb/DUT/registers_inst_B/REGISTER_BANK_B/S_ADDR
add wave -noupdate -expand -group Operational /taichi_tmb_tb/DUT/registers_inst_B/REGISTER_BANK_B/S_DATA_IN
add wave -noupdate -expand -group Operational /taichi_tmb_tb/DUT/registers_inst_B/S_READ
add wave -noupdate -expand -group Operational /taichi_tmb_tb/DUT/registers_inst_B/S_WRITE
add wave -noupdate -group {DIAG read - write} -color Yellow -itemcolor Firebrick /taichi_tmb_tb/DUT/registers_inst_A/S_WRITE
add wave -noupdate -group {DIAG read - write} -color Yellow -itemcolor Firebrick /taichi_tmb_tb/DUT/registers_inst_A/S_READ
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/WRITE
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/READ
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/ADDR
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/DATA_IN
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/DATA_OUT
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_sm
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/start_valid_int
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Headers_valid_int
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/data_valid_int
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Footers_valid_int
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/crc_calc
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/good_packet
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/bad_packet
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/diag_txrx_vif/clk
add wave -noupdate -group {DIAG read - write} -color Orange /taichi_tmb_tb/diag_txrx_vif/rx_sync_signal
add wave -noupdate -group {DIAG read - write} -color Orange /taichi_tmb_tb/DUT/Diag_out_P
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/TX_series7_COMPONENT/DATA_IN
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/TX_series7_COMPONENT/TX_data_byte
add wave -noupdate -divider {Channel OK}
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/sDataIn
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/RESET
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_data
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_sm
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/good_packet_received
add wave -noupdate -group {CHANNEL OK} -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Channel_data_locked_int
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_locked_vec
add wave -noupdate -group {CHANNEL OK} -color {Dark Orchid} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_OK
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY_stable
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/Module_channel_RDY_FORCE
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_channel_RDY
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_packet_received
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_packet_received_50m
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_good_packet
add wave -noupdate -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_data_50m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {982956627 ps} 0} {{Cursor 2} {13088959013 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 187
configure wave -valuecolwidth 93
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1114225875 ps}
