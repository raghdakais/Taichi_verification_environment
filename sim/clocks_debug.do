onerror {resume}
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
add wave -noupdate -divider <NULL>
add wave -noupdate -group {IP -->  HEADER} -color Magenta /taichi_tmb_tb/DUT/Sync_P
add wave -noupdate -group {IP -->  HEADER} -color Magenta /taichi_tmb_tb/DUT/SYNC
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/sDataIn
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/IP_DATA_OUT
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/HEADER_DATA_OUT
add wave -noupdate -group {IP -->  HEADER} -color Cyan /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_RX_det_o
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_IP_pckt_valid
add wave -noupdate -group {IP -->  HEADER} -color Cyan /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_good_packet_received
add wave -noupdate -group {IP -->  HEADER} -color {Indian Red} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/bad_packet_received
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_data_valid
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_FOOTER_VALID
add wave -noupdate -group {IP -->  HEADER} -color Magenta /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/RX_IP_DATAVAL_HEADER_PINS/good_packet
add wave -noupdate -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/RX_IP_DATAVAL_HEADER_PINS/bad_packet
add wave -noupdate -divider <NULL>
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
add wave -noupdate -divider <NULL>
add wave -noupdate -group {BUFFER REQ } /taichi_tmb_tb/DUT/io_inst_1/RX_series7_1/pDataIn
add wave -noupdate -group {BUFFER REQ } /taichi_tmb_tb/DUT/Buffer_N
add wave -noupdate -group {BUFFER REQ } /taichi_tmb_tb/DUT/Buffer_P
add wave -noupdate -group {DATA OUT } -color {Violet Red} -itemcolor {Violet Red} -subitemconfig {/taichi_tmb_tb/DUT/DATA_OUT(1) {-color {Violet Red} -itemcolor {Violet Red}} /taichi_tmb_tb/DUT/DATA_OUT(0) {-color {Violet Red} -itemcolor {Violet Red}}} /taichi_tmb_tb/DUT/DATA_OUT
add wave -noupdate -group {DATA OUT } -color Turquoise /taichi_tmb_tb/DUT/TX_series7_1/TX_data_byte
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/TX_det_byte
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/DATA_IN
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/TX_ERRs
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/totalnumbytes_cnt
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/TotalNumBytes
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/Stream_type1
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/Stream_type2
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/StartWord
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/RD_REQ
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/IP
add wave -noupdate -group {DATA OUT } /taichi_tmb_tb/DUT/TX_series7_1/IP_word
add wave -noupdate -divider <NULL>
add wave -noupdate /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/FOOTER_CTRL_1/F_DOUT
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/rlt_address_from_sync
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/hd_ptr_address_from_sync
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/slice_merging_factor
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/fs_merging_factor
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/fs_sequence_counter
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/fq_stream_enable
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/temp_Num_of_Slices
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/reading_number_freerun_cnt_o
add wave -noupdate -color Khaki /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/make_data_from_sync
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DIAG REG}
add wave -noupdate -group Operational /taichi_tmb_tb/DUT/registers_inst_B/REGISTER_BANK_B/S_ADDR
add wave -noupdate -group Operational /taichi_tmb_tb/DUT/registers_inst_B/REGISTER_BANK_B/S_DATA_IN
add wave -noupdate -group Operational /taichi_tmb_tb/DUT/registers_inst_B/S_READ
add wave -noupdate -group Operational /taichi_tmb_tb/DUT/registers_inst_B/S_WRITE
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
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/sDataIn
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/RESET
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_data
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_sm
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/good_packet_received
add wave -noupdate -expand -group {CHANNEL OK} -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Channel_data_locked_int
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_locked_vec
add wave -noupdate -expand -group {CHANNEL OK} -color {Dark Orchid} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_OK
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY_stable
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/Module_channel_RDY_FORCE
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_channel_RDY
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_packet_received
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_packet_received_50m
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_good_packet
add wave -noupdate -expand -group {CHANNEL OK} /taichi_tmb_tb/DUT/sig_2_data_50m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {1581216525 ps} 0} {{Cursor 2} {6734811125 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 228
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 ps} {23718247875 ps}
