# Define the list of tests with repeat counts
set tests {
   
 {check_default_value_for_all_registers_test 2}
 {taichi_tmb_test_base 1}
 {check_RO_registers_test 1}
 {diagnostic_registers_random_test 10}
 {operational_registers_random_test 10}
}



puts "================================================="
puts " RUNNING REGRESSION..."
puts "================================================="

# Set paths
set PROJ_PATH "../"
set REG_PATH "log_result/regression_results"
set COV_PATH "$REG_PATH/coverage"

# Create lREG_PATH and coverage directories if they don’t exist
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

# Define the log file name using the test name
set work_library_path "${REG_PATH}/work"
vlib $work_library_path
vmap work $work_library_path
vmap fifo_generator_v13_2_7 C:/questasim64_2024.1/fifo_generator_v13_2_7
vmap secureip C:/questasim64_2024.1/secureip
vmap unisim C:/questasim64_2024.1/unisim
vmap xpm C:/questasim64_2024.1/xpm

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

set vopt_args "+cover=bcesft"
set vsim_args "-coverage"
vopt +acc  work.taichi_tmb_tb -o taichi_tmb_optimized_sim $vopt_args

if {![file exists "${work_library_path}/taichi_tmb_optimized_sim"]} {
    puts "Error: Design not found in work library!"
    exit 1
}

 puts "Optimization Done!.."


    set total_pass  0
    set total_fail  0
    set total_unknow 0
    set summary_report ""
# ==============================================
# Run tests for each specified case
# ==============================================
foreach test_info $tests {
    set test_name [lindex $test_info 0]
    set repeat_count [lindex $test_info 1]

    for {set i 1} {$i <= $repeat_count} {incr i} {
        puts "Running test: $test_name $i of $repeat_count"
        
        # Default status is FAILED (use plain text for tracking)
        set test_status  "\033\[31mFAILED\033\[0m"  ; # 31 is for red color

        # Define the log file name using the test name and instance number
        set LOG_FILE "${REG_PATH}/${test_name}_${i}_transcript.log"
        # Run vsim command per test with the exact command from run_sim.tcl
        set error_code [catch { vsim -L unisim -L secureip -L fifo_generator_v13_2_7 -L xpm  \
        +UVM_VERBOSITY=UVM_LOW -c -l "$LOG_FILE"  \
         -cvgperinstance -vopt -voptargs=+acc -coverage -sva -c work.taichi_tmb_optimized_sim  \
          +UVM_TESTNAME=$test_name -onfinish stop \
           -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"} vsim_output]

        if {$error_code != 0} {
            puts "⚠️ ERROR: Simulation failed for $test_name ($i)"
            puts $output "$test_name ($i): ERROR (Simulation Failed)"
            continue
        }

        puts "Running simulation for $test_name..."
        # Run simulation for a fixed time (e.g., 10,000 time units)
        if {[catch {run -all} err]} {
            puts "Error: $err"
        }

        # Create a unique log file for each repetition
        if { [file exists $LOG_FILE] } {
            set log_data [open $LOG_FILE r]
            while {[gets $log_data line] >= 0} {
                if {[string match -nocase "*TEST PASSED*" $line]} {
                    set test_status "\033\[32mPASSED\033\[0m"  ; # 32 is for green color
                    break
                }
            }
            close $log_data
        } else {
            puts "⚠️ WARNING: Log file not found for $test_name ($i)"
            set test_status "NO_LOG"
        }

        # Store result in log file
        # Store result in log file
        if { $test_status == "\033\[32mPASSED\033\[0m" } {
            append  summary_report "✅ $test_name $i : $test_status\n"
            incr total_pass
        } elseif { $test_status == "\033\[31mFAILED\033\[0m" } {
            append  summary_report "❌ $test_name $i : $test_status\n"
            incr total_fail
        } else {
            append  summary_report "⚠️ $test_name: Check Log\n"
            incr total_unknow
        }

        # Store result in log file
        puts $output "$test_name ($i): $test_status"
        puts "  → $test_name ($i): $test_status"
        # Store in test results array
        set test_results($test_name,$i) $test_status
 
      puts "Collecting and Merging Coverage"
      set COVERAGE_DB "${COV_PATH}/functional_coverage_result_${test_name}_${i}.ucdb"
      coverage save $COVERAGE_DB
      vcover merge final_testplan.ucdb final_testplan.ucdb ${COV_PATH}/testplan.ucdb $COVERAGE_DB  
    }
}
      close $output
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
 
# Quit simulation
quit -force
