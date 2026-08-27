onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib axi4_master_vhdl_0_opt

do {wave.do}

view wave
view structure
view signals

do {axi4_master_vhdl_0.udo}

run -all

quit -force
