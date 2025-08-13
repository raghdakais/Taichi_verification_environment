puts "================================================="
puts " RUNNING REGRESSION..."
puts "================================================="
# Record regression start time
set regression_start_time [clock seconds]
# Define the list of tests with repeat counts
# command:   vsim -c -do run_regression.tcl
  ##  {send_syncs_for_buffer_full_test}
set tests {
    {sig2_sync_test}
    {check_default_value_for_all_registers_test 2}
    {check_RO_registers_test 1}
    {diagnostic_registers_random_test 5}
    {operational_registers_random_test 5}
    {sending_frame_data_Mu_off_test 1}
    {random_data_path_test}
    {read_from_empty_buffer_test}
}

puts "================================================="
puts " RUNNING REGRESSION..."
puts "================================================="

# Set paths
set PROJ_PATH ".."
set REG_PATH "log_result/regression_results"
set COV_PATH "$REG_PATH/coverage"

# Create REG_PATH and coverage directories if they don’t exist
if {![file exists $REG_PATH]} { file mkdir $REG_PATH }
if {![file exists $COV_PATH]} { file mkdir $COV_PATH }
xml2ucdb -format Excel testplan.xml -ucdbfilename ${COV_PATH}/testplan.ucdb

# Create results log file
set results_file "$REG_PATH/regression_results.log"
file delete -force $results_file
set output [open $results_file w]

# Declare an array to store test results
array set test_results {}

# ==============================================
# Compile the design and environment only once
# ==============================================
puts "Compiling design and environment..."

set work_library_path "${REG_PATH}/work"
set QUESTA_LIBS $PROJ_PATH/src/QUESTA_LIBS
vlib $work_library_path
vmap work $work_library_path
vmap fifo_generator_v13_2_7 $QUESTA_LIBS/fifo_generator_v13_2_7
vmap secureip $QUESTA_LIBS/secureip
vmap unisim $QUESTA_LIBS/unisim
vmap xpm $QUESTA_LIBS/xpm

# Compile the design and environment
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
puts "Design and environment compiled."

set vopt_args "+cover=bsft"
set vsim_args "-coverage"

#-------------------------------
# Optimize the design with vopt
#-------------------------------
puts "Start Optimization.."
vopt work.taichi_tmb_tb work.glbl \
    -L secureip -L fifo_generator_v13_2_7 -L xpm -L unisims_ver -L unisim \
    -o taichi_tmb_optimized_sim \
    +acc \
    {*}$vopt_args

if {![file exists "${work_library_path}/taichi_tmb_optimized_sim"]} {
    puts "Error: Design not found in work library!"
    exit 1
}
puts "Optimization Done!.."

set total_pass  0
set total_fail  0
set total_unknow 0
set summary_report ""

# List to hold all UCDB coverage files
set all_ucdb_files {}

# ==============================================
# Run tests for each specified case
# ==============================================
foreach test_info $tests {
    set test_name [lindex $test_info 0]
    set repeat_count [lindex $test_info 1]

    # Handle default repeat count of 1
    if {$repeat_count eq ""} {
        set repeat_count 1
    }

    for {set i 1} {$i <= $repeat_count} {incr i} {
        puts "Running test: $test_name $i of $repeat_count"

        set test_status "\033\[31mFAILED\033\[0m"

        set LOG_FILE "${REG_PATH}/${test_name}_${i}_transcript.log"
        set error_code [catch {
            vsim -t 1ps +model_data+ddr_tmp work.taichi_tmb_optimized_sim \
                +UVM_VERBOSITY=UVM_LOW +UVM_LOG=wlf -l "$LOG_FILE" \
                +UVM_TESTNAME=$test_name -onfinish stop \
                {*}$vsim_args \
                -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"
        } vsim_output]

        if {$error_code != 0} {
            puts "⚠️ ERROR: Simulation failed for $test_name ($i)"
            puts $output "$test_name ($i): ERROR (Simulation Failed)"
            continue
        }

        puts "Running simulation for $test_name..."
        if {[catch {run -all} err]} {
            puts "Error: $err"
        }

        if {[file exists $LOG_FILE]} {
            set log_data [open $LOG_FILE r]
            while {[gets $log_data line] >= 0} {
                if {[string match -nocase "*TEST PASSED*" $line]} {
                    set test_status "\033\[32mPASSED\033\[0m"
                    break
                }
            }
            close $log_data
        } else {
            puts "⚠️ WARNING: Log file not found for $test_name ($i)"
            set test_status "NO_LOG"
        }

        if { $test_status == "\033\[32mPASSED\033\[0m" } {
            append summary_report "✅ $test_name $i : $test_status\n"
            incr total_pass
        } elseif { $test_status == "\033\[31mFAILED\033\[0m" } {
            append summary_report "❌ $test_name $i : $test_status\n"
            incr total_fail
        } else {
            append summary_report "⚠️ $test_name: Check Log\n"
            incr total_unknow
        }

        puts $output "$test_name ($i): $test_status"
        puts "  → $test_name ($i): $test_status"
        set test_results($test_name,$i) $test_status

        puts "Collecting and Merging Coverage"
        set COVERAGE_DB "${COV_PATH}/functional_coverage_result_${test_name}_${i}.ucdb"
        coverage save $COVERAGE_DB
        vcover merge ${COV_PATH}/final_testplan.ucdb ${COV_PATH}/final_testplan.ucdb ${COV_PATH}/testplan.ucdb $COVERAGE_DB
        puts "All coverage merged into ${COV_PATH}/final_testplan.ucdb"
        lappend all_ucdb_files $COVERAGE_DB
    }
}


puts "================================================="
puts " REGRESSION COMPLETED! SUMMARY BELOW: "
puts "================================================="
puts "$summary_report"

puts "------------------------"
puts "Total Tests Run: [expr {$total_pass + $total_fail + $total_unknow}]"
puts "✅ Passed: $total_pass"
puts "❌ Failed: $total_fail"
puts "⚠️ No Logs: $total_unknow"
puts "-------------------------------------------------"
puts " Check regression_results.log for details."
puts "-------------------------------------------------"



# Record regression end time
set regression_end_time [clock seconds]

# Compute elapsed time in seconds
set elapsed_time [expr {$regression_end_time - $regression_start_time}]

# Convert to hh:mm:ss format
set hours   [expr {$elapsed_time / 3600}]
set minutes [expr {($elapsed_time % 3600) / 60}]
set seconds [expr {$elapsed_time % 60}]

puts "-------------------------------------------------"
puts " Total Regression Time: ${hours}h ${minutes}m ${seconds}s"
puts "-------------------------------------------------"
puts $output "Total Regression Time: ${hours}h ${minutes}m ${seconds}s"


close $output


puts "Generating HTML report for code coverage..."
vcover report ${COV_PATH}/final_testplan.ucdb -html -details -output ${COV_PATH}/html_report
vcover report -html -htmldir HTML_COVERAGE_REPORTS ${COV_PATH}/final_testplan.ucdb  -details -testhitdata
puts "HTML coverage report generated at ${COV_PATH}/html_report/index.html"
vsim -viewcov ${COV_PATH}/final_testplan.ucdb
# Quit simulation
quit -force
