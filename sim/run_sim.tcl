transcript off
##restart -force

set PROJ_PATH "../../taichi_tmb_env"
set LOG_PATH "../log_result"

# Check if LOG_PATH exists, if not, create it
if {![file exists $LOG_PATH]} {
    puts "LOG_PATH does not exist, creating directory: $LOG_PATH"
    file mkdir $LOG_PATH
}

# Get the current date and time in YYYY-MM-DD_HH-MM-SS format
set current_datetime [clock format [clock seconds] -format "%Y_%m_%d_%H_%M_%S"]

# Define the base folder path inside LOG_PATH using the current date and time
set folder_path "${LOG_PATH}/work_${current_datetime}"

# Define the full work library path inside the folder
set work_library_path "${folder_path}/work"

# Create the base directory inside LOG_PATH
file mkdir $folder_path

# Create the "work" library inside the folder
vlib $work_library_path

# Map the "work" library to its path
vmap work $work_library_path

# Map secureip and unisim libraries to their paths
vmap fifo_generator_v13_2_7 C:/questasim64_2024.1/fifo_generator_v13_2_7
vmap secureip C:/questasim64_2024.1/secureip
vmap unisim C:/questasim64_2024.1/unisim
vmap xpm C:/questasim64_2024.1/xpm

 


# Output confirmation
puts "Created and mapped work library at: $work_library_path"

# Compile design
if { ![file exists compile_env.do] || ![file exists compile_design.do] } {
    puts "Error: Missing compile scripts!"
    exit 1
}

do compile_design.do
do compile_env.do

# Verify compiled design
vdir

# Open waveform and add signals (optional)
view wave
#add wave -r /*

# Optimize the design with vopt
vopt +acc work.taichi_tmb_tb -o taichi_tmb_optimized_sim

# Run the optimized simulation, redirecting the log files to the specified log folder
vsim -L unisim  -L secureip   -L fifo_generator_v13_2_7 -L xpm +UVM_VERBOSITY=UVM_DEBUG  -c -l "${LOG_PATH}/transcript" -voptargs="+acc" -warning 3 work.taichi_tmb_optimized_sim +UVM_TESTNAME=taichi_tmb_basic_test -onfinish stop

puts "Running simulation..."

# Save all signals
log -r /*

# Run simulation for a fixed time (e.g., 10,000 time units)
run -all 

# Exit simulation
exit

# Change directory to simulation path (if needed)
cd $PROJ_PATH/sim
