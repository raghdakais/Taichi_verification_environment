onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib DDR3_AXI_IF_opt

do {wave.do}

view wave
view structure
view signals

do {DDR3_AXI_IF.udo}

run -all

quit -force
