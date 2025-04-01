## UVM compile File that compile all design files  for taichi_tmb environment

 


vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/Phoebe_files/*.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/AMS_Mu/*.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/f_2020/Asic_data_comp_a1.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/f_2020/slices_sorter.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/f_2020/Tiles_managment.vhd

vcom -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/Liron_tiles_align/*.vhd

vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/ddr3_model_pack.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/tbuf_pack.vhd

vcom -work work $PROJ_PATH/design/sources_1/imports/DALIT_PID/*.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/Tzvika_NVRAM/*.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/TMP112/*.vhd

vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/fs_merge_pack.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/evolving_calc_ams.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/memory_buffer_if_tmp.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/taichi_slice_builder.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/tmb_reg2spictl.vhd

vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/bin2bcd.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/date_in_bcd.vhd





vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/xpm_hand_simple.vhd
vlog  $PROJ_PATH/design/sources_1/ip/axi4_master_vhdl/glbl.v
##  vlog  -sv   -work work $PROJ_PATH/design/sources_1/ip/dcfifo_512x32.v


##vcom  -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/dcfifo_512x32.vhd


####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_tempmon.v
####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_1_memc_ui_top_axi.v
####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_infrastructure.v
####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_clk_ibuf.v
####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_iodelay_ctrl.v
####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF_mig.v
####  later      vlog         -work work $PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF_2/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF.v
####  later      vcom  -2008 -work work $PROJ_PATH/design/sources_1/ip/axi4_master_vhdl_0_1/axi4_master_vhdl_0_1/sim/axi4_master_vhdl_0.vhd
####  later      vcom  -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/read_ddr3_rd.vhd
####  later      vcom  -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/data_sort_ddr3_wr.vhd
####  later      vcom  -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/ddr_driver.vhd

vcom -work work $PROJ_PATH/design/sources_1/imports/remote_config/*.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/liron_sig_2/*.vhd
vcom -2008 -work work $PROJ_PATH/design/sources_1/imports/IP_DATAVAL_HEADER/*.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/buffer_calculator/*.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/liron_txrx/channel_pack.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/liron_txrx/RX_series7.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/liron_txrx/TX_series7.vhd

vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_ENCODER.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Register_Decoder.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_CTRL.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Registers_A_pack.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Registers_B_pack.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_BANK_A.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_BANK_B.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Module_TX_RX_diag_A.vhd
vcom -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Module_TX_RX_Operational_B.vhd


vcom -2008  $PROJ_PATH/design/sources_1/new/*.vhd


vcom  $PROJ_PATH/design/sources_1/ip/*.vhd*



vcom -2008  $PROJ_PATH/design/sources_1/new/Taichi_TMB_top.vhd