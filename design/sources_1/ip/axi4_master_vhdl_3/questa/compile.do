vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xpm
vlib questa_lib/msim/xil_defaultlib

vmap xpm questa_lib/msim/xpm
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xpm  -incr -mfcu -sv \
"D:/Program_Files/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Program_Files/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm  -93 \
"D:/Program_Files/Xilinx/Vivado/2021.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib  -93 \
"../../../../project_1.gen/sources_1/ip/axi4_master_vhdl_3/hdl/axi4_master_vhdl_v3_0_M00_AXI.vhd" \
"../../../../project_1.gen/sources_1/ip/axi4_master_vhdl_3/hdl/axi4_master_vhdl_v3_0.vhd" \
"../../../../project_1.gen/sources_1/ip/axi4_master_vhdl_3/sim/axi4_master_vhdl_3.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

