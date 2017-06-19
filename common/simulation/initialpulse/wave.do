onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /initialpulse/LEN
add wave -noupdate -radix unsigned /initialpulse/POL
add wave -noupdate -divider <NULL>
add wave -noupdate /initialpulse/clk
add wave -noupdate /initialpulse/pulse
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /initialpulse/delay_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5 ns} 0} {{Cursor 2} {105 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {408 ns}
