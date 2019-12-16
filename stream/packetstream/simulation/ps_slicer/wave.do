onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_slicer/LENGTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_slicer/rst
add wave -noupdate /ps_slicer/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_slicer/i_dat
add wave -noupdate /ps_slicer/i_val
add wave -noupdate /ps_slicer/i_eop
add wave -noupdate /ps_slicer/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_slicer/o_dat
add wave -noupdate /ps_slicer/o_val
add wave -noupdate /ps_slicer/o_eop
add wave -noupdate /ps_slicer/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_slicer/slice_eop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {101 ns} 0}
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
WaveRestoreZoom {0 ns} {678 ns}
