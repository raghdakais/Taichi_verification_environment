# Disable transcript output to clean the console
transcript off

# Set warning for numeric standard no warnings
set NumericStdNoWarnings 1

# Set project, log, and coverage paths
set PROJ_PATH "../"         # Path to the project directory
set LOG_PATH "../log_result" # Path to store log results
set COV_PATH "../coverage"  # Path to store coverage results

# Default coverage flag (0 = disabled)
if {![info exists enable_cov]} {
    set enable_cov 0   # Set coverage flag to 0 if not already set
}

# Default test name (can be overridden by input argument)
set test_name "diagnostic_registers_random_test"

# Check if a test name argument is provided from the command line
if {[llength $argv] > 0} {
    set test_name [lindex $argv 0]  # Override the default test name with the first argument
}

puts "Running test: $test_name"

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
set folder_path "${LOG_PATH}/."

# Define the full work library path inside the folder
set work_library_path "${folder_path}/work"

# Create the base directory inside LOG_PATH
file mkdir $folder_path

# Create the "work" library inside the folder
vlib $work_library_path

# Map the "work" library to its path
vmap work $work_library_path

# Map secureip and unisim libraries to their paths (for simulation)
vmap fifo_generator_v13_2_7 C:/questasim64_2024.1/fifo_generator_v13_2_7
vmap secureip C:/questasim64_2024.1/secureip
vmap unisim C:/questasim64_2024.1/unisim
vmap xpm C:/questasim64_2024.1/xpm

# Output confirmation of library creation
puts "Created and mapped work library at: $work_library_path"

# Check if compile environment scripts exist
if { ![file exists compile_env.do] || ![file exists compile_design.do] } {
    puts "Error: Missing compile scripts!"
    exit 1  # Exit if compile scripts are missing
}

# Compile the design and environment
puts "Compiling Design..."
do compile_design.do
puts "Compiling Environment..."
do compile_env.do

# Verify compiled design
vdir

# Open waveform and add signals (optional)
view wave
# Uncomment the line below to add all signals to the waveform
# add wave -r /*

# Enable coverage collection if the flag is set
if {$enable_cov} {
    puts "Coverage collection enabled."
    set COVERAGE_DB "${COV_PATH}/functional_coverage.ucdb"
    set vopt_args "+cover=bcesft"   # Set coverage options
    set vsim_args "-coverage"       # Set simulation arguments for coverage
} else {
    puts "Coverage collection disabled."
    set vopt_args ""    # No coverage arguments if disabled
    set vsim_args ""    # No coverage in simulation if disabled
}

# Optimize the design with vopt
puts "Start Optimization.."
vopt +acc work.taichi_tmb_tb -o taichi_tmb_optimized_sim $vopt_args

# Run the optimized simulation
puts "Start VSIM command.."
vsim -L unisim -L secureip -L fifo_generator_v13_2_7 -L xpm \
     +UVM_VERBOSITY=UVM_LOW -c -l "${LOG_PATH}/transcript" \
     -cvgperinstance -vopt -voptargs=+acc -coverage -sva -c work.taichi_tmb_optimized_sim \
     +UVM_TESTNAME=$test_name -onfinish stop  -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"

# Output simulation running status
puts "Running simulation..."

# Save all signals to a log
log -r /*

# Run simulation for a fixed time (e.g., 10,000 time units)
if {[catch {run -all} err]} {
    puts "Error: $err"
}

# Save coverage results if enabled
if {$enable_cov} {
    coverage save ${COV_PATH}/functional_coverage_result.ucdb
    xml2ucdb -format Excel testplan.xml -ucdbfilename ${COV_PATH}/testplan.ucdb
    vcover merge testplan.ucdb ${COV_PATH}/testplan.ucdb ${COV_PATH}/functional_coverage_result.ucdb 
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html -htmldir ${COV_PATH}/htmlcoverreport testplan.ucdb -details -testhitdata
}
