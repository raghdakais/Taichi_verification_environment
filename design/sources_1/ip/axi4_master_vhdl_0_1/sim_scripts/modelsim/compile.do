
vcom -work work -64 -93 \
"../../axi4_master_vhdl_0_1/hdl/axi4_master_vhdl_v1_0_M00_AXI.vhd" \
"../../axi4_master_vhdl_0_1/hdl/axi4_master_vhdl_v1_0.vhd" \
"../../axi4_master_vhdl_0_1/sim/axi4_master_vhdl_0.vhd" \

# was: "../../../ip/axi4_master_vhdl_0_1
# fix: "../../axi4_master_vhdl_0_1...

vlog -work xil_defaultlib \
"glbl.v"

