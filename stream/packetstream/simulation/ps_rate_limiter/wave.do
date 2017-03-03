onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_rate_limiter/DWIDTH
add wave -noupdate -radix unsigned /ps_rate_limiter/CWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_rate_limiter/reset
add wave -noupdate /ps_rate_limiter/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_rate_limiter/delay
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_rate_limiter/i_dat
add wave -noupdate /ps_rate_limiter/i_val
add wave -noupdate /ps_rate_limiter/i_eop
add wave -noupdate /ps_rate_limiter/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_rate_limiter/o_dat
add wave -noupdate /ps_rate_limiter/o_val
add wave -noupdate /ps_rate_limiter/o_eop
add wave -noupdate /ps_rate_limiter/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_rate_limiter/del_cnt
add wave -noupdate /ps_rate_limiter/ena_reg
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
