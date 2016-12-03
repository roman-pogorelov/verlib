onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /freq_estimator/PERIOD
add wave -noupdate -radix unsigned /freq_estimator/FACTOR
add wave -noupdate -divider <NULL>
add wave -noupdate /freq_estimator/refclk
add wave -noupdate /freq_estimator/estclk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /freq_estimator/frequency
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /freq_estimator/ref_tick_cnt
add wave -noupdate /freq_estimator/ref_stb_reg
add wave -noupdate -radix unsigned /freq_estimator/est_tick_cnt
add wave -noupdate -radix unsigned /freq_estimator/est_tick_sync_reg
add wave -noupdate -radix unsigned /freq_estimator/est_tick_curr
add wave -noupdate -radix unsigned /freq_estimator/est_tick_prev_reg
add wave -noupdate -radix unsigned /freq_estimator/freq_est_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {59 ns} 0}
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
