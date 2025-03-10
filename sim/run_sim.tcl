transcript off
set NumericStdNoWarnings 1

set PROJ_PATH "../"
set LOG_PATH "../log_result"
set COV_PATH "../coverage"

# Default coverage flag (0 = disabled)
if {![info exists enable_cov]} {
    set enable_cov 0
}


# Check if LOG_PATH exists, if not, create it
if {![file exists $LOG_PATH]} {
    puts "LOG_PATH does not exist, creating directory: $LOG_PATH"
    file mkdir $LOG_PATH
}

# Check if COV_PATH exists, if not, create it
if {![file exists $COV_PATH]} {
    puts "COV_PATH does not exist, creating directory: $COV_PATH"
    file mkdir $COV_PATH
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

puts "Compiling Design..."
do compile_design.do
puts "Compiling Environment..."
do compile_env.do

# Verify compiled design
vdir

# Open waveform and add signals (optional)
view wave
#add wave -r /*



# Enable coverage if the flag is set
if {$enable_cov} {
    puts "Coverage collection enabled."
    set COVERAGE_DB "${COV_PATH}/functional_coverage.ucdb"
    xml2ucdb -format Excel testplan.xml ${COV_PATH}/testplan.ucdb
    set vopt_args "+cover=bcesft"
    set vsim_args "-coverage"
} else {
    puts "Coverage collection disabled."
    set vopt_args ""
    set vsim_args ""
}


# Optimize the design with vopt
# +cover=bcst  -- to enable coverage
 puts "Start Optimization.."
vopt +acc  work.taichi_tmb_tb -o taichi_tmb_optimized_sim +cover=bcesft


# Run the optimized simulation
 puts "Start VSIM command.."
vsim -L unisim -L secureip -L fifo_generator_v13_2_7 -L xpm \
     +UVM_VERBOSITY=UVM_DEBUG -c -l "${LOG_PATH}/transcript" \
     -voptargs="+acc" work.taichi_tmb_optimized_sim \
     +UVM_TESTNAME=diagnostic_registers_random_test -onfinish stop $vsim_args


puts "Running simulation..."

# Save all signals
log -r /*


# Run simulation for a fixed time (e.g., 10,000 time units)
run -all 



# Exit simulation
quit -force



# Enable coverage logging if -cov is passed
if {$enable_cov} {
    # Enable coverage collection in QuestaSim
    xml2ucdb -format Excel testplan.xml ${COV_PATH}/testplan.ucdb
    # Enable coverage logging
    coverage save ${COV_PATH}/testplan.ucdb
    coverage open ${COV_PATH}/testplan.ucdb
    vcover report ${COV_PATH}/testplan.ucdb -details -output ${COV_PATH}/coverage_report.txt
}
# Change directory to simulation path (if needed)
cd $PROJ_PATH/sim
