vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm -64 -incr -mfcu  -sv \
"/opt/APPS/FPGA/XILINX/Vivado/2022.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/APPS/FPGA/XILINX/Vivado/2022.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -64 -93  \
"/opt/APPS/FPGA/XILINX/Vivado/2022.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -64 -incr -mfcu  \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl_off_delay.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_lim.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_calib_top.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy_wrapper.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrlvl.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_skip_calib_tap.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_top.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_wrcal.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_samp.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_edge.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_mux.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_tempmon.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_prbs_rdlvl.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_pd.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_cntlr.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_top.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_4lanes.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_cc.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_if_post_fifo.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_edge_store.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_init.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_group_io.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_dqs_found_cal_hr.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_byte_lane.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_rdlvl.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_oclkdelay_cal.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_tap_base.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_of_pre_fifo.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_mc_phy.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_data.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_prbs_gen.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_poc_meta.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/mig_7series_v4_2_ddr_phy_ocd_po_cntlr.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_round_robin_arb.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_rank_cntrl.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_compare.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_mach.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_state.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_col_mach.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_common.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_arb_row_col.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_rank_common.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_mc.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_queue.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_bank_cntrl.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_arb_select.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_arb_mux.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/mig_7series_v4_2_rank_mach.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_tempmon.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_infrastructure.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_clk_ibuf.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/mig_7series_v4_2_iodelay_ctrl.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_2_memc_ui_top_axi.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/mig_7series_v4_2_mem_intfc.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_top.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_cmd.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_rd_data.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/mig_7series_v4_2_ui_wr_data.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_fi_xor.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_gen.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_merge_enc.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_dec_fix.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/mig_7series_v4_2_ecc_buf.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_incr_cmd.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_top.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_translator.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_a_upsizer.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_arbiter.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_read.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_r_upsizer.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel_static.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_w_upsizer.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_simple_fifo.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_or.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_comparator_sel.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wrap_cmd.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_ar_channel.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_command_fifo.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_cmd_fsm.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_or.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_and.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_upsizer.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_reg_bank.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_write.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_fifo.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_w_channel.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_axic_register_slice.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_carry_latch_and.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_wr_cmd_fsm.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_r_channel.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_aw_channel.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_ctrl_addr_decode.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_ddr_axi_register_slice.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/mig_7series_v4_2_axi_mc_b_channel.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF_mig_sim.v" \
"../../../../Taichi_TMB.gen/sources_1/ip/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF.v" \

vlog -work xil_defaultlib \
"glbl.v"

