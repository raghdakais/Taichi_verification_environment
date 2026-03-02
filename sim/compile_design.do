## UVM compile File that compile all design files  for taichi_tmb environment

 


vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/Phoebe_files/*.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/AMS_Mu/*.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/f_2020/Asic_data_comp_a1.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/f_2020/slices_sorter.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/f_2020/Tiles_managment.vhd

vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/ams_tiles_rx/Liron_tiles_align/*.vhd

vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/ddr3_model_pack.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/ddr_driver/tbuf_pack.vhd

vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/DALIT_PID/*.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/Tzvika_NVRAM/*.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/TMP112/*.vhd

vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/fs_merge_pack.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/evolving_calc_ams.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/memory_buffer_if_tmp.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/taichi_slice_builder.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/tmb_reg2spictl.vhd

vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/bin2bcd.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/date_in_bcd.vhd





vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/taichi_lite_src/xpm_hand_simple.vhd
vlog -cover bcst -sv -work work $PROJ_PATH/design/sources_1/ip/axi4_master_vhdl/glbl.v

vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/remote_config/*.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/liron_sig_2/*.vhd
vcom -cover bcts  -2008 -work work $PROJ_PATH/design/sources_1/imports/IP_DATAVAL_HEADER/*.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/buffer_calculator/*.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/liron_txrx/channel_pack.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/liron_txrx/RX_series7.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/liron_txrx/TX_series7.vhd

vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_ENCODER.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Register_Decoder.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_CTRL.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Registers_A_pack.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Registers_B_pack.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_BANK_A.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/REGISTER_BANK_B.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Module_TX_RX_diag_A.vhd
vcom -cover bcts  -work work $PROJ_PATH/design/sources_1/imports/idan_registers/Module_TX_RX_Operational_B.vhd
vcom -cover bcts   -work work -2008 $PROJ_PATH/design/sources_1/new/*.vhd
vcom -cover bcts   $PROJ_PATH/design/sources_1/ip/*.vhdl

##------------------------------------------
## Compiling DDR3 
##------------------------------------------
  
vlog  -sv -work work  -incr -mfcu  -L secureip  -L unisims_ver -L xpm  -L fifo_generator_v13_2_7 \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_addr_decode.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_read.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg_bank.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_top.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_write.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_ar_channel.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_aw_channel.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_b_channel.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_arbiter.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_fsm.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_translator.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_fifo.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_incr_cmd.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_r_channel.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_simple_fifo.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wrap_cmd.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wr_cmd_fsm.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_w_channel.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_axic_register_slice.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_register_slice.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_upsizer.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_a_upsizer.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_and.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_and.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_or.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_or.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_command_fifo.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel_static.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_r_upsizer.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_w_upsizer.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_axi.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_skip_calib_tap.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF_mig_sim.v" \
"$PROJ_PATH/design/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF.v" \

vlog -cover bcst -sv -sv -work work +define+MAX_MEM +define+x4Gb +define+sg107E +define+x8 $PROJ_PATH/src/ddr3_model.sv
vlog -cover bcst -sv -work work $PROJ_PATH/design/sources_1/ip/dcfifo_512x32.v
vcom -cover bcts  -work work -2008  $PROJ_PATH/design/sources_1/imports/ddr_driver/evolving_ddr3_wr.vhd
vcom -cover bcts  -work work -2008   $PROJ_PATH/design/sources_1/ip/axi4_master_vhdl_0_1/axi4_master_vhdl_0_1/sim/axi4_master_vhdl_0.vhd
vcom -cover bcts  -work work -2008   $PROJ_PATH/design/sources_1/ip/axi4_master_vhdl_0_1/axi4_master_vhdl_0_1/hdl/axi4_master_vhdl_v1_0.vhd
vcom -cover bcts  -work work -2008  $PROJ_PATH/design/sources_1/imports/ddr_driver/data_sort_ddr3_wr.vhd   
vcom -cover bcts  -work work -2008  $PROJ_PATH/design/sources_1/imports/ddr_driver/read_ddr3_rd.vhd
vcom -cover bcts  -work work -2008  $PROJ_PATH/design/sources_1/ip/axi4_master_vhdl_0_1/axi4_master_vhdl_0_1/hdl/axi4_master_vhdl_v1_0_M00_AXI.vhd


vcom -cover bcts  -work work -2008   $PROJ_PATH/design/sources_1/imports/ddr_driver/ddr_driver.vhd   

vcom -cover bcts  -work work  -2008  $PROJ_PATH/design/sources_1/new/Taichi_TMB_top.vhd