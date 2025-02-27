onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib DDR3_AXI_IF_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {DDR3_AXI_IF.udo}

run 1000ns

quit -force
