onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /fixed_rounder_tb/IWIDTH
add wave -noupdate -radix unsigned /fixed_rounder_tb/OWIDTH
add wave -noupdate -radix unsigned /fixed_rounder_tb/PIPELINE
add wave -noupdate -divider <NULL>
add wave -noupdate /fixed_rounder_tb/reset
add wave -noupdate /fixed_rounder_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /fixed_rounder_tb/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate /fixed_rounder_tb/i_signed
add wave -noupdate -radix unsigned /fixed_rounder_tb/i_data
add wave -noupdate -divider <NULL>
add wave -noupdate /fixed_rounder_tb/o_signed
add wave -noupdate -radix unsigned /fixed_rounder_tb/o_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135384 ps} 0} {{Cursor 2} {23093 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {1402912 ps}
