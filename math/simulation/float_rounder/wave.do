onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /float_rounder_tb/IWIDTH
add wave -noupdate -radix unsigned /float_rounder_tb/OWIDTH
add wave -noupdate -radix ascii /float_rounder_tb/SIGNREP
add wave -noupdate -radix unsigned /float_rounder_tb/PIPELINE
add wave -noupdate -divider <NULL>
add wave -noupdate /float_rounder_tb/rst
add wave -noupdate /float_rounder_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /float_rounder_tb/clkena
add wave -noupdate -radix unsigned /float_rounder_tb/offset
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /float_rounder_tb/i_data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /float_rounder_tb/o_data
add wave -noupdate -radix unsigned /float_rounder_tb/r_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {81726 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {512 ns}
