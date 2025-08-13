transcript off

# ---------- Basic setup ----------
set NumericStdNoWarnings 1
set UVM_NO_RELNOTES 1
set UVM_MAX_QUIT_COUNT 10
set UVM_REPORT_SEVERITY UVM_FATAL,UVM_ERROR,UVM_WARNING,UVM_INFO

# Project & output dirs
set PROJ_PATH ".."
set LOG_PATH  "log_result"
set COV_PATH  [file join $LOG_PATH "coverage"]

# Flags / inputs
if {![info exists enable_cov]} { set enable_cov 0 }
if {![info exists test_name]} {
    puts "Error: No test name provided!"
    exit 1
}
puts "Running test: $test_name"

# ---------- Paths & per-run names ----------
# Timestamp for uniqueness
set ts [clock format [clock seconds] -format "%Y_%m_%d_%H_%M_%S"]

# Logs & libs
file mkdir $LOG_PATH
file mkdir $COV_PATH

# Per-test/per-run log file
## for regression mode  set LOG_FILE [file join $LOG_PATH "transcript_${test_name}_${ts}.log"]
set LOG_FILE [file join $LOG_PATH "transcript_${test_name}.log"]

# Work library under logs to avoid polluting repo
## for regression mode   set work_library_path [file join $LOG_PATH "work_${test_name}_${ts}"]
set work_library_path [file join $LOG_PATH "work_${test_name}"]
set QUESTA_LIBS [file join $PROJ_PATH "src" "QUESTA_LIBS"]

# ---------- Libraries ----------
vlib $work_library_path
vmap work $work_library_path
vmap fifo_generator_v13_2_7 [file join $QUESTA_LIBS fifo_generator_v13_2_7]
vmap secureip                 [file join $QUESTA_LIBS secureip]
vmap unisim                   [file join $QUESTA_LIBS unisim]
vmap xpm                      [file join $QUESTA_LIBS xpm]
vmap unisims_ver              [file join $QUESTA_LIBS unisims_ver]

puts "Log dir     : $LOG_PATH"
puts "Coverage dir: $COV_PATH"
puts "Work lib    : $work_library_path"

# ---------- Compile ----------
if { ![file exists compile_env.do] || ![file exists compile_design.do] } {
    puts "Error: Missing compile scripts (compile_env.do / compile_design.do)!"
    exit 1
}
puts "Compiling design..."
do compile_design.do
puts "Compiling environment..."
do compile_env.do

# Optional: list compiled units
vdir

# ---------- Args for vopt/vsim ----------
if {$enable_cov} {
    puts "Coverage: ENABLED"
    # vopt: +cover; vsim: coverage + log-to-wlf to keep console cleaner
    set vopt_args {+cover=bcesft}
    set vsim_args {-coverage -msgmode wlf -displaymsgmode wlf -c}
} else {
    puts "Coverage: DISABLED"
    set vopt_args {}
    set vsim_args {-msgmode both -c}
}

# ---------- Optimize ----------
puts "Optimizing with vopt..."
vopt work.taichi_tmb_tb work.glbl \
    -L secureip -L fifo_generator_v13_2_7 -L xpm -L unisims_ver -L unisim \
    -o taichi_tmb_optimized_sim \
    +acc \
    {*}$vopt_args

# ---------- Run ----------
puts "Launching vsim..."
vsim -t 1ps +model_data+ddr_tmp work.taichi_tmb_optimized_sim \
     +UVM_VERBOSITY=UVM_DEBUG +UVM_LOG=wlf \
     +UVM_TESTNAME=$test_name \
     -onfinish stop \
     -l "$LOG_FILE" \
     {*}$vsim_args \
     -do "set StdArithNoWarnings 1 ; set NumericStdNoWarnings 1"

# Log everything to WLF
log -r /*

puts "Running simulation..."
if {[catch {run -all} err]} {
    puts "Error during run: $err"
}

# ---------- Coverage post-processing ----------
if {$enable_cov} {
    set run_ucdb     [file join $COV_PATH "functional_coverage_${test_name}_${ts}.ucdb"]
    set plan_ucdb_in [file join $COV_PATH "testplan_${ts}.ucdb"]
    set merged_ucdb  [file join $COV_PATH "merged_${test_name}_${ts}.ucdb"]
    set html_dir     [file join $COV_PATH "html_${test_name}_${ts}"]

    coverage save $run_ucdb
    # Convert testplan to UCDB (kept alongside other coverage files)
    xml2ucdb -format Excel testplan.xml -ucdbfilename $plan_ucdb_in

    # Merge plan & run coverage into a single UCDB in COV_PATH
    vcover merge $merged_ucdb $plan_ucdb_in $run_ucdb

    # Generate detailed HTML report in COV_PATH
    vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive \
                  -html -htmldir $html_dir \
                  $merged_ucdb -details -testhitdata
}

# End (no quit so interactive users can inspect if not -c)
