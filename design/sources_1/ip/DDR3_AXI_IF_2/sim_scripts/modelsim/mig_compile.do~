vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib
vlib modelsim_lib/msim/xpm

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib
vmap xpm modelsim_lib/msim/xpm

vlog -work xil_defaultlib -64 -incr -sv \
"C:/APPS/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/APPS/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93 \
"C:/APPS/Xilinx/Vivado/2018.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_ctrl_addr_decode.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_ctrl_read.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_ctrl_reg.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_ctrl_reg_bank.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_ctrl_top.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_ctrl_write.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_ar_channel.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_aw_channel.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_b_channel.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_cmd_arbiter.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_cmd_fsm.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_cmd_translator.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_fifo.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_incr_cmd.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_r_channel.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_simple_fifo.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_wrap_cmd.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_wr_cmd_fsm.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_axi_mc_w_channel.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_axic_register_slice.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_axi_register_slice.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_axi_upsizer.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_a_upsizer.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_carry_and.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_carry_latch_and.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_carry_latch_or.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_carry_or.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_command_fifo.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_comparator.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_comparator_sel.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_comparator_sel_static.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_r_upsizer.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_1_ddr_w_upsizer.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_clk_ibuf.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_infrastructure.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_iodelay_ctrl.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_1_tempmon.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_arb_mux.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_arb_row_col.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_arb_select.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_bank_cntrl.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_bank_common.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_bank_compare.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_bank_mach.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_bank_queue.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_bank_state.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_col_mach.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_mc.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_rank_cntrl.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_rank_common.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_rank_mach.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_1_round_robin_arb.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_1_ecc_buf.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_1_ecc_dec_fix.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_1_ecc_gen.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_1_ecc_merge_enc.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_1_fi_xor.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_1_memc_ui_top_axi.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_1_mem_intfc.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_byte_group_io.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_byte_lane.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_calib_top.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_if_post_fifo.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_mc_phy.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_mc_phy_wrapper.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_of_pre_fifo.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_4lanes.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_dqs_found_cal.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_dqs_found_cal_hr.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_init.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_cntlr.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_data.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_edge.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_lim.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_mux.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_po_cntlr.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_ocd_samp.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_oclkdelay_cal.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_prbs_rdlvl.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_rdlvl.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_tempmon.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_top.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_wrcal.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_wrlvl.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_phy_wrlvl_off_delay.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_prbs_gen.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_ddr_skip_calib_tap.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_poc_cc.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_poc_edge_store.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_poc_meta.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_poc_pd.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_poc_tap_base.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_1_poc_top.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_1_ui_cmd.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_1_ui_rd_data.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_1_ui_top.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_1_ui_wr_data.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF_mig_sim.v" \
"../../../../Spartan7_tmc.srcs/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF.v" \

vlog -work xil_defaultlib \
"glbl.v"

