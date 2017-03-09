onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /add_tree/WIDTH
add wave -noupdate -radix unsigned /add_tree/INPUTS
add wave -noupdate -divider <NULL>
add wave -noupdate /add_tree/reset
add wave -noupdate /add_tree/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /add_tree/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /add_tree/i_signed
add wave -noupdate -radix unsigned -expand /add_tree/i_data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /add_tree/o_signed
add wave -noupdate -radix unsigned /add_tree/o_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {62 ns} 0}
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
WaveRestoreZoom {0 ns} {898 ns}
