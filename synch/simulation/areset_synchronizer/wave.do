onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /areset_synchronizer/EXTRA_STAGES
add wave -noupdate -format Literal -radix unsigned /areset_synchronizer/ACTIVE_LEVEL
add wave -noupdate -radix unsigned /areset_synchronizer/STAGES
add wave -noupdate -divider <NULL>
add wave -noupdate /areset_synchronizer/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /areset_synchronizer/areset
add wave -noupdate /areset_synchronizer/sreset
add wave -noupdate -divider <NULL>
add wave -noupdate -radix binary /areset_synchronizer/stage0
add wave -noupdate -radix binary /areset_synchronizer/stage_chain
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {311 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
