onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /debouncer/STABLE_TIME
add wave -noupdate -radix unsigned /debouncer/EXTRA_STAGES
add wave -noupdate -radix binary /debouncer/RESET_VALUE
add wave -noupdate -radix unsigned /debouncer/CWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /debouncer/reset
add wave -noupdate /debouncer/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /debouncer/bounce
add wave -noupdate /debouncer/stable
add wave -noupdate -divider <NULL>
add wave -noupdate /debouncer/bounce_sync
add wave -noupdate -radix unsigned /debouncer/stable_cnt
add wave -noupdate /debouncer/stable_reg
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
