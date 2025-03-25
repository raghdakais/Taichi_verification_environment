transcript off
set NumericStdNoWarnings 1

set PROJ_PATH "../"
set LOG_PATH "log_result"
set COV_PATH "log_result/coverage"

# Default coverage flag (0 = disabled)
if {![info exists enable_cov]} {
    set enable_cov 0
}

#### maybe later  # Get test name from command line argument
#### maybe later  if { $argc < 1 } {
#### maybe later      puts "Error: No test name provided!"
#### maybe later      exit 1
#### maybe later  }
#### maybe later  
#### maybe later  set test_name [lindex $argv 0]
#### maybe later  puts "Running test: $test_name"

# Ensure that the test_name is set
if {![info exists test_name]} {
    puts "Error: No test name provided!"
    exit 1
}

# Print the test name to confirm it's captured
puts "Running test: $test_name"




# Create log and coverage directories if they don’t exist
if {![file exists $LOG_PATH]} { file mkdir $LOG_PATH }
if {![file exists $COV_PATH]} { file mkdir $COV_PATH }

# Define the log file name using the test name
set LOG_FILE "${LOG_PATH}/transcript.log"


# Get the current date and time in YYYY-MM-DD_HH-MM-SS format
set current_datetime [clock format [clock seconds] -format "%Y_%m_%d_%H_%M_%S"]

# Define the base folder path inside LOG_PATH using the current date and time
# Define work library path
set folder_path "${LOG_PATH}/."
####set folder_path "${LOG_PATH}/work_${current_datetime}"
set work_library_path "${folder_path}/work"

# Create the base directory inside LOG_PATH
## maybe no need  file mkdir $folder_path

# Create the "work" library inside the folder
vlib $work_library_path

# Map the "work" library to its path
vmap work $work_library_path

# Map secureip and unisim libraries to their paths
vmap fifo_generator_v13_2_7 C:/questasim64_2024.1/fifo_generator_v13_2_7
vmap secureip C:/questasim64_2024.1/secureip
vmap unisim C:/questasim64_2024.1/unisim
vmap xpm C:/questasim64_2024.1/xpm

 
puts "Log path: $LOG_PATH"
puts "Coverage path: $COV_PATH"
puts "Test name: $test_name"

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
# Uncomment the line below to add all signals to the waveform
#add wave -r /*



# Enable coverage if the flag is set
if {$enable_cov} {
    puts "Coverage collection enabled."
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
vopt +acc  work.taichi_tmb_tb -o taichi_tmb_optimized_sim $vopt_args


# Run the optimized simulation
vsim -L unisim -L secureip -L fifo_generator_v13_2_7 -L xpm \
     +UVM_VERBOSITY=UVM_DEBUG -c -l "$LOG_FILE" \
     -cvgperinstance -vopt -voptargs=+acc -coverage -sva -c work.taichi_tmb_optimized_sim \
     +UVM_TESTNAME=$test_name -onfinish stop  -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"


puts "Running simulation..."

# Save all signals
log -r /*

# Run simulation for a fixed time (e.g., 10,000 time units)
if {[catch {run -all} err]} {
    puts "Error: $err"
}



# Save coverage results if enabled
if {$enable_cov} {
set COVERAGE_DB "${COV_PATH}/functional_coverage_result_${test_name}.ucdb"
coverage save $COVERAGE_DB
##coverage save  ${COV_PATH}/functional_coverage_result_$test_name.ucdb
xml2ucdb -format Excel testplan.xml -ucdbfilename ${COV_PATH}/testplan.ucdb
vcover merge testplan.ucdb ${COV_PATH}/testplan.ucdb $COVERAGE_DB 
vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html -htmldir ${COV_PATH}/htmlcoverreport testplan.ucdb -details -testhitdata
}

# Stop the simulation after it completes
##stop
##quit -force