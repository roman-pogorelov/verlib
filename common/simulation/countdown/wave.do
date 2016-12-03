onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /countdown/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /countdown/reset
add wave -noupdate /countdown/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /countdown/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /countdown/ctrl_time
add wave -noupdate /countdown/ctrl_run
add wave -noupdate /countdown/ctrl_abort
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /countdown/stat_timeleft
add wave -noupdate /countdown/stat_finish
add wave -noupdate /countdown/stat_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /countdown/time_cnt
add wave -noupdate /countdown/busy_reg
add wave -noupdate /countdown/done_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {61 ns} 0}
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
