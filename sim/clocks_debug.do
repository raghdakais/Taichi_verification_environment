onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate /taichi_tmb_tb/diag_txrx_vif/clk
add wave -noupdate -color Orange /taichi_tmb_tb/diag_txrx_vif/rx_sync_signal
add wave -noupdate -color Orange /taichi_tmb_tb/DUT/Diag_out_P
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/TX_series7_COMPONENT/DATA_IN
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/TX_series7_COMPONENT/TX_data_byte
add wave -noupdate -divider <NULL>
add wave -noupdate -divider TX
add wave -noupdate -color Yellow /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/sm4sync
add wave -noupdate -radix unsigned /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/delay_cnt_byte
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Bitslip
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/FCLK
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/CLKDIV
add wave -noupdate /taichi_tmb_tb/diag_txrx_vif/rst
add wave -noupdate -color {Dark Orchid} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY
add wave -noupdate /taichi_tmb_tb/diag_txrx_vif/clk
add wave -noupdate /taichi_tmb_tb/diag_txrx_vif/tx_sync_signal
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/sDataIn
add wave -noupdate /taichi_tmb_tb/diag_txrx_vif/byte_collected
add wave -noupdate /taichi_tmb_tb/diag_txrx_vif/active_package
add wave -noupdate -color {Orange Red} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/pDataIn
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/pDataIn_q
add wave -noupdate -color Magenta /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/cnt_idle_byte
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/cnt_num_byte
add wave -noupdate -radix unsigned /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/delay_cnt_byte
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_sm
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/start_valid_int
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Headers_valid_int
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/data_valid_int
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Footers_valid_int
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/CRC_valid_int
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/crc_calc
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/good_packet
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/bad_packet
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -divider {DIAG REG}
add wave -noupdate -color Yellow -itemcolor Firebrick /taichi_tmb_tb/DUT/registers_inst_A/S_WRITE
add wave -noupdate -color Yellow -itemcolor Firebrick /taichi_tmb_tb/DUT/registers_inst_A/S_READ
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/WRITE
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/READ
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/ADDR
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/DATA_IN
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_BANK_A/DATA_OUT
add wave -noupdate -divider ctrl
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_CTRL/WRITE
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_CTRL/EXE
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_CTRL/CMD
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_CTRL/SEND
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_CTRL/delay_sm
add wave -noupdate -divider decoder
add wave -noupdate -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/S_PAYLOAD_WAS_ON
add wave -noupdate -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/S_HEADER_WAS_ON
add wave -noupdate -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/S_FOOTER_WAS_ON
add wave -noupdate -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/S_ALIGNED_APPROVED
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/S_ALIGNED_R1
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/S_ALIGNED_R2
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/REGISTER_DECODER/CLK
add wave -noupdate -divider rx_series
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/IDLE_word
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/StartWord
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Stream_type1
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Stream_type2
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/sDataIn
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_sm
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/good_packet_received
add wave -noupdate -color Cyan /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/Channel_data_locked_int
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_data_locked_vec
add wave -noupdate -color {Dark Orchid} /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_OK
add wave -noupdate /taichi_tmb_tb/DUT/registers_inst_A/RX_series_COMPONENT/channel_RDY_stable
add wave -noupdate /taichi_tmb_tb/DUT/Module_channel_RDY_FORCE
add wave -noupdate /taichi_tmb_tb/DUT/sig_2_channel_RDY
add wave -noupdate /taichi_tmb_tb/DUT/sig_2_packet_received
add wave -noupdate /taichi_tmb_tb/DUT/sig_2_packet_received_50m
add wave -noupdate /taichi_tmb_tb/DUT/sig_2_good_packet
add wave -noupdate /taichi_tmb_tb/DUT/sig_2_data_50m
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {227500 ps} 0}
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
WaveRestoreZoom {204700 ps} {287090 ps}
