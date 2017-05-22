onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt__scaler/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt__scaler/reset
add wave -noupdate /pipelined_fixed_isqrt__scaler/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt__scaler/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -color Coral -radix hexadecimal /pipelined_fixed_isqrt__scaler/idata
add wave -noupdate -color Coral -radix hexadecimal /pipelined_fixed_isqrt__scaler/odata
add wave -noupdate -color Coral -radix unsigned /pipelined_fixed_isqrt__scaler/scale
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__scaler/msb_pos_reg
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt__scaler/msb_num
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt__scaler/shift_cnt_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__scaler/data_dly_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__scaler/scaled_data_reg
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt__scaler/scale_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {168 ns} 0}
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
WaveRestoreZoom {0 ns} {446 ns}
