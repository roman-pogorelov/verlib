onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /single_pulse_synchronizer/EXTRA_STAGES
add wave -noupdate -divider <NULL>
add wave -noupdate /single_pulse_synchronizer/src_reset
add wave -noupdate /single_pulse_synchronizer/src_clk
add wave -noupdate -divider <NULL>
add wave -noupdate /single_pulse_synchronizer/dst_reset
add wave -noupdate /single_pulse_synchronizer/dst_clk
add wave -noupdate -divider <NULL>
add wave -noupdate /single_pulse_synchronizer/src_pulse
add wave -noupdate /single_pulse_synchronizer/dst_pulse
add wave -noupdate -divider <NULL>
add wave -noupdate /single_pulse_synchronizer/src_tick_reg
add wave -noupdate /single_pulse_synchronizer/dst_tick
add wave -noupdate /single_pulse_synchronizer/dst_tick_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
