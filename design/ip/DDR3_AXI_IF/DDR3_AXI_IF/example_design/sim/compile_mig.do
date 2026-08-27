
# Example: Modelsim simulation environment for Xilinx
#
# from Xilinx: The 'sim.do' file has commands to compile and simulate design and run the simulation for specified period of time.
#  1. vlib/vmap
#  2. $XILINX_VIVADO environment variable must be set in order to compile glbl.v
#  3. vsim -t fs -novopt +notimingchecks -L unisims_ver -L secureip work.<testbench> glbl

proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib; vmap [file tail $lib] $lib } }

# Path: MY_SIMDIR - project, IP_SOURCE - this IP
set MY_SIMDIR "D:/Users/EugeneS/MODEL/Taichi_TMB"
set IP_SOURCE "../../../.."

# create libraries
ensure_lib $MY_SIMDIR/work     

#Map the required libraries here#
#vmap unisims_ver <unisims_ver lib path>
#vmap unisim <unisim lib path>
#vmap secureip <secureip lib path>

# compile sources, IP
# !debug: option ?  vlog  -incr mig_7series*.v
vlog  $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF.v
vlog  $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/DDR3_AXI_IF_mig_sim.v
vlog  -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/clocking/*.v
vlog  -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/controller/*.v
vlog  -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ecc/*.v
vlog  -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ip_top/*.v
vlog  -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/phy/*.v
vlog  -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/ui/*.v
vlog -incr $IP_SOURCE/DDR3_AXI_IF/DDR3_AXI_IF/user_design/rtl/axi/*

#Compile files in sim folder (excluding model parameter file)#
#$XILINX variable must be set
# !TODO: see XILINX_VIVADO variable, then copy glbl.v to same dir as script
#vlog  -incr $env(XILINX_VIVADO)/data/verilog/src/glbl.v
vlog  -incr glbl.v

# !TODO: copy ddr3_model.sv, ddr3_model_parameters.vh
# Pass the parameters for memory model parameter file#
#vlog -sv  +define+MAX_MEM +define+x4Gb +define+sg107E +define+x8 ddr3_model.sv

