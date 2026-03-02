
# Example: Modelsim simulation environment for Xilinx
#
# from Xilinx: The 'sim.do' file has commands to compile and simulate design and run the simulation for specified period of time.
#  1. vlib/vmap
#  2. $XILINX_VIVADO environment variable must be set in order to compile glbl.v
# !TODO: try complile axi4_master_vhdl, glbl to work

#proc ensure_lib { lib } { if ![file isdirectory {$lib}] { vlib {$lib}; vmap [file tail {$lib}] {$lib} } }
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib; vmap [file tail $lib] $lib } }

set MY_SIMDIR "D:/PR/MODEL/Taichi_TMB"
set work $MY_SIMDIR/work
puts $work

# create libraries
ensure_lib $MY_SIMDIR/work
#ensure_lib $MY_SIMDIR/work/xil_defaultlib

# !debug: try to use xpm from XILINX_LIBS
#ensure_lib $MY_SIMDIR/work/xpm
## compile simulation environment
#vlog -work xil_defaultlib -64 -incr -sv \
#"../../xpm/xpm_cdc/hdl/xpm_cdc.sv" \
#
#vcom -work xpm -64 -93 \
#"./xpm/xpm_VCOMP.vhd" \

# compile sources, IP
vcom -work $work -93 \
"../../axi4_master_vhdl_0_1/hdl/axi4_master_vhdl_v1_0_M00_AXI.vhd" \
"../../axi4_master_vhdl_0_1/hdl/axi4_master_vhdl_v1_0.vhd" \
"../../axi4_master_vhdl_0_1/sim/axi4_master_vhdl_0.vhd"

#vlog -work $work \
#"glbl.v"
