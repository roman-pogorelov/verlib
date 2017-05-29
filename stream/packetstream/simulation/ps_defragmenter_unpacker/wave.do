onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_defragmenter_unpacker/WIDTH
add wave -noupdate -radix unsigned /ps_defragmenter_unpacker/ALIGN
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_defragmenter_unpacker/reset
add wave -noupdate /ps_defragmenter_unpacker/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_defragmenter_unpacker/i_dat
add wave -noupdate /ps_defragmenter_unpacker/i_val
add wave -noupdate /ps_defragmenter_unpacker/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_defragmenter_unpacker/o_dat
add wave -noupdate /ps_defragmenter_unpacker/o_val
add wave -noupdate /ps_defragmenter_unpacker/o_eop
add wave -noupdate /ps_defragmenter_unpacker/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color Salmon /ps_defragmenter_unpacker/state
add wave -noupdate -radix unsigned /ps_defragmenter_unpacker/len_cnt
add wave -noupdate -radix unsigned /ps_defragmenter_unpacker/align_cnt
add wave -noupdate /ps_defragmenter_unpacker/fin_reg
add wave -noupdate /ps_defragmenter_unpacker/eop_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {54 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {544 ns}
