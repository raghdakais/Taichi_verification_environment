onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Testbench/DUT/Vcc
add wave -noupdate /Testbench/DUT/S
add wave -noupdate /Testbench/DUT/C
add wave -noupdate /Testbench/DUT/DQ0
add wave -noupdate /Testbench/DUT/DQ1
add wave -noupdate /Testbench/DUT/Vpp_W_DQ2
add wave -noupdate /Testbench/DUT/RESET_DQ3
add wave -noupdate -radix ascii /Testbench/DUT/cmdRecName
add wave -noupdate -radix hexadecimal /Testbench/DUT/cmd
add wave -noupdate -radix hexadecimal /Testbench/DUT/VolatileReg/VCR
add wave -noupdate /Testbench/DUT/DoubleTransferRate
add wave -noupdate /Testbench/DUT/int_reset
add wave -noupdate /Testbench/DUT/iAddr
add wave -noupdate /Testbench/DUT/iCmd
add wave -noupdate /Testbench/DUT/iData
add wave -noupdate /Testbench/DUT/iDummy
add wave -noupdate /Testbench/DUT/cmdLatched
add wave -noupdate /Testbench/DUT/addrLatched
add wave -noupdate /Testbench/DUT/dataLatched
add wave -noupdate /Testbench/DUT/dummyLatched
add wave -noupdate /Testbench/DUT/codeRecognized
add wave -noupdate /Testbench/DUT/seqRecognized
add wave -noupdate /Testbench/tasks/clock_active
add wave -noupdate /Testbench/DUT/logicOn
add wave -noupdate /Testbench/DUT/int_reset
add wave -noupdate /Testbench/DUT/reset_by_powerOn
add wave -noupdate -radix ascii /Testbench/DUT/protocol
add wave -noupdate /Testbench/DUT/RESET
add wave -noupdate /Testbench/DUT/XIP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21837732634 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 270
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 3
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 fs} {19446 ns}
