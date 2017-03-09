onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /clockmon/reset
add wave -noupdate -divider <NULL>
add wave -noupdate /clockmon/monclk
add wave -noupdate -divider <NULL>
add wave -noupdate /clockmon/refclk
add wave -noupdate -divider <NULL>
add wave -noupdate /clockmon/detected
add wave -noupdate -divider <NULL>
add wave -noupdate -radix binary /clockmon/mon_reg
add wave -noupdate -radix binary /clockmon/ref_reg
add wave -noupdate /clockmon/pulse_reg
add wave -noupdate -radix unsigned /clockmon/detect_cnt
add wave -noupdate /clockmon/detect_reg
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /clockmon/REQRATIO
add wave -noupdate -radix unsigned /clockmon/CYCLES
add wave -noupdate -radix unsigned /clockmon/ADDCYCLES
add wave -noupdate -radix unsigned /clockmon/COUNT
add wave -noupdate -radix unsigned /clockmon/CWIDTH
add wave -noupdate -radix unsigned /clockmon/CMAX
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {110 ns} 0} {{Cursor 2} {60 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
