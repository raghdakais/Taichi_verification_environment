# Begin_DVE_Session_Save_Info
# DVE view(Wave.1 ) session
# Saved on Tue Feb 12 13:35:01 2013
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Wave.1: 33 signals
# End_DVE_Session_Save_Info

# DVE version: F-2011.12_Full64
# DVE build date: Nov 22 2011 20:55:00


#<Session mode="View" path="/nfs/fm/disks/fm_fpg_n7006/global_work/p72/evillega/DS4/bfm/N25Q/256Mb/N25Q256A13E/sim/session.inter.vpd.tcl" type="Debug">

#<Database>

#</Database>

# DVE View/pane content session: 

# Begin_DVE_Session_Save_Info (Wave.1)
# DVE wave signals session
# Saved on Tue Feb 12 13:35:01 2013
# 33 signals
# End_DVE_Session_Save_Info

# DVE version: F-2011.12_Full64
# DVE build date: Nov 22 2011 20:55:00


#Add ncecessay scopes
gui_load_child_values {Testbench.DUT.singleIO_output}

gui_set_time_units 1ps
set Group1 Group1
if {[gui_sg_is_group -name Group1]} {
    set Group1 [gui_sg_generate_new_name]
}

gui_sg_addsignal -group "$Group1" { {Sim:Testbench.DUT.C} {Sim:Testbench.DUT.DQ0} {Sim:Testbench.DUT.DQ1} {Sim:Testbench.DUT.HOLD_DQ3} {Sim:Testbench.DUT.S} {Sim:Testbench.DUT.Vcc} {Sim:Testbench.DUT.Vpp_W_DQ2} {Sim:Testbench.DUT.read_enable} {Sim:Testbench.DUT.dataOut} {Sim:Testbench.DUT.cmdLatched} {Sim:Testbench.DUT.addrLatched} {Sim:Testbench.DUT.iCmd} {Sim:Testbench.DUT.iData} {Sim:Testbench.DUT.iDummy} {Sim:Testbench.DUT.iAddr} {Sim:Testbench.DUT.cmdRecName} {Sim:Testbench.DUT.cmd} {Sim:Testbench.DUT.sendToBus} {Sim:Testbench.DUT.dataLatched} {Sim:Testbench.DUT.dummyLatched} {Sim:Testbench.DUT.read.enable_ID} {Sim:Testbench.DUT.read.enable_rsfdp} {Sim:Testbench.DUT.read.ID_index} {Sim:Testbench.DUT.singleIO_output.bit_count} {Sim:Testbench.DUT.goReadId} {Sim:Testbench.DUT.addrLatch} {Sim:Testbench.DUT.prog.enable_4Byte_address} {Sim:Testbench.DUT.addr} {Sim:Testbench.DUT.readAddr} {Sim:Testbench.DUT.latchingMode} {Sim:Testbench.DUT.Debug.x1} {Sim:Testbench.DUT.Debug.x2} {Sim:Testbench.DUT.Debug.x3} }
gui_set_radix -radix {decimal} -signals {Sim:Testbench.DUT.iCmd}
gui_set_radix -radix {twosComplement} -signals {Sim:Testbench.DUT.iCmd}
gui_set_radix -radix {decimal} -signals {Sim:Testbench.DUT.iData}
gui_set_radix -radix {twosComplement} -signals {Sim:Testbench.DUT.iData}
gui_set_radix -radix {decimal} -signals {Sim:Testbench.DUT.iDummy}
gui_set_radix -radix {twosComplement} -signals {Sim:Testbench.DUT.iDummy}
gui_set_radix -radix {decimal} -signals {Sim:Testbench.DUT.iAddr}
gui_set_radix -radix {twosComplement} -signals {Sim:Testbench.DUT.iAddr}
gui_set_radix -radix {ascii} -signals {Sim:Testbench.DUT.cmdRecName}
gui_set_radix -radix {unsigned} -signals {Sim:Testbench.DUT.cmdRecName}
gui_set_radix -radix {ascii} -signals {Sim:Testbench.DUT.latchingMode}
gui_set_radix -radix {unsigned} -signals {Sim:Testbench.DUT.latchingMode}
if {![info exists useOldWindow]} { 
	set useOldWindow true
}
if {$useOldWindow && [string first "Wave" [gui_get_current_window -view]]==0} { 
	set Wave.1 [gui_get_current_window -view] 
} else {
	gui_open_window Wave
set Wave.1 [ gui_get_current_window -view ]
}
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_create -id ${Wave.1} C2 10667584
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 5002240918 5018522081
gui_list_add_group -id ${Wave.1} -after {New Group} [list $Group1]
gui_list_select -id ${Wave.1} {Testbench.DUT.latchingMode }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group $Group1  -item Testbench.DUT.Debug.x3 -position below

gui_marker_move -id ${Wave.1} {C1} 10000000000
gui_view_scroll -id ${Wave.1} -vertical -set 125
gui_show_grid -id ${Wave.1} -enable false
#</Session>

