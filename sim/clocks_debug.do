onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider <NULL>
add wave -noupdate -color Magenta -itemcolor Magenta /taichi_tmb_tb/DUT/io_inst_1/lock2aclk_stop
add wave -noupdate /taichi_tmb_tb/DUT/io_inst_1/incr_RDY_delay_cnt
add wave -noupdate -radix unsigned /taichi_tmb_tb/DUT/io_inst_1/aclk_filter_cnt
add wave -noupdate /taichi_tmb_tb/DUT/io_inst_1/aclk_rise_detect
add wave -noupdate /taichi_tmb_tb/DUT/io_inst_1/aclk_period_saved
add wave -noupdate /taichi_tmb_tb/DUT/Diag_in_P
add wave -noupdate /taichi_tmb_tb/DUT/Diag_in_N
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/S_TX_IN
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/S_IDLY_CNT
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/S_EN
add wave -noupdate -divider <NULL>
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/TX_series7_COMPONENT/DATA_IN
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/TX_series7_COMPONENT/TX_data_byte
add wave -noupdate -divider {IP - HEADER}
add wave -noupdate -expand -group {IP -->  HEADER} -color Magenta /taichi_tmb_tb/DUT/Sync_P
add wave -noupdate -expand -group {IP -->  HEADER} -color Magenta /taichi_tmb_tb/DUT/SYNC
add wave -noupdate -expand -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/sDataIn
add wave -noupdate -expand -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/IP_DATA_OUT
add wave -noupdate -expand -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/HEADER_DATA_OUT
add wave -noupdate -expand -group {IP -->  HEADER} -color Cyan /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_RX_det_o
add wave -noupdate -expand -group {IP -->  HEADER} /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_IP_pckt_valid
add wave -noupdate -expand -group {IP -->  HEADER} -color Cyan /taichi_tmb_tb/DUT/IP_DATAVAL_HEADER_TOP_1/S_good_packet_received
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DIAG REG}
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
add wave -noupdate -group {DIAG read - write} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/CRC_valid_int
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
WaveRestoreCursors {{Cursor 3} {84651387 ps} 0}
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
WaveRestoreZoom {0 ps} {150160500 ps}
