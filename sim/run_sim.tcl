transcript off
set NumericStdNoWarnings 1
set UVM_NO_RELNOTES 1  ;# Suppress irrelevant QuestaSim UVM release notes
set UVM_MAX_QUIT_COUNT 10
set UVM_REPORT_SEVERITY UVM_FATAL,UVM_ERROR,UVM_WARNING,UVM_INFO

set PROJ_PATH ".."
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
set QUESTA_LIBS $PROJ_PATH/src/QUESTA_LIBS
# Create the base directory inside LOG_PATH
## maybe no need  file mkdir $folder_path

# Create the "work" library inside the folder
vlib $work_library_path

# Map the "work" library to its path
vmap work $work_library_path

# Map secureip and unisim libraries to their paths
vmap fifo_generator_v13_2_7 $QUESTA_LIBS/fifo_generator_v13_2_7
vmap secureip $QUESTA_LIBS/secureip
vmap unisim $QUESTA_LIBS/unisim
vmap xpm $QUESTA_LIBS/xpm
vmap unisims_ver $QUESTA_LIBS/unisims_ver

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
 ###do "C:/scripts/TAICHI_Repo/Taichi_verification_environment/design/sources_1/ip/DDR3_AXI_IF_202301/sim_scripts/questa/compile.do"
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
 #   set vopt_args "-vopt -voptargs=+acc +cover=bcesft"
     set vopt_args [list +cover=bcesft]
   # set vsim_args "-coverage -msgmode both -displaymsgmode both -c"
     set vsim_args [list -coverage -msgmode wlf -displaymsgmode wlf -c]
} else {
    puts "Coverage collection disabled."
   set vopt_args [list ]
   #   set vsim_args "-msgmode both -displaymsgmode both -c"
    set vsim_args [list -msgmode both   -c]
}


#-------------------------------
# Optimize the design with vopt
#-------------------------------
## for debug   puts "Start Optimization.."
## for debug  vopt work.taichi_tmb_tb work.glbl  -L secureip -L fifo_generator_v13_2_7 -L xpm -L unisims_ver -L unisim  -o taichi_tmb_optimized_sim {*}$vopt_args
puts "Start Optimization.."
vopt work.taichi_tmb_tb work.glbl \
    -L secureip -L fifo_generator_v13_2_7 -L xpm -L unisims_ver -L unisim \
    -o taichi_tmb_optimized_sim \
    +acc \
    {*}$vopt_args

##----------------------
##  NOVOPT
##----------------------
# Skipping vopt for -novopt mode
##puts "Skipping vopt: running simulation with -novopt..."

##----------------------
## Run the optimized simulation
##----------------------
###     vsim -t 1ps   -novopt work.taichi_tmb_tb\
###          +UVM_VERBOSITY=UVM_DEBUG +UVM_LOG=wlf -l "$LOG_FILE" \
###          -cvgperinstance -vopt -voptargs=+acc  {*}$vsim_args  -msgmode both \
###          +UVM_TESTNAME=$test_name -onfinish stop  -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"
vsim -t 1ps +model_data+ddr_tmp work.taichi_tmb_optimized_sim \
     +UVM_VERBOSITY=UVM_DEBUG +UVM_LOG=wlf -l "$LOG_FILE" \
     +UVM_TESTNAME=$test_name -onfinish stop \
     {*}$vsim_args \
     -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"
##----------------------
##  NOVOPT
##----------------------
# Run the simulation without optimization
#####    vsim -novopt -t 1ps work.taichi_tmb_tb \
#####         +UVM_VERBOSITY=UVM_DEBUG +UVM_LOG=wlf -l "$LOG_FILE" \
#####         +UVM_TESTNAME=$test_name -onfinish stop \
#####         {*}$vsim_args \
#####         -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"



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