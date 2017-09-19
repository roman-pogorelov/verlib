onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/WIDTH
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/INITVAL
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/MAXITER
add wave -noupdate -divider <NULL>
add wave -noupdate /cordic_sin_cos_iterated/reset
add wave -noupdate /cordic_sin_cos_iterated/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /cordic_sin_cos_iterated/start
add wave -noupdate /cordic_sin_cos_iterated/ready
add wave -noupdate /cordic_sin_cos_iterated/done
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal /cordic_sin_cos_iterated/arg
add wave -noupdate -radix decimal /cordic_sin_cos_iterated/sin
add wave -noupdate -radix decimal /cordic_sin_cos_iterated/cos
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/lookup_table
add wave -noupdate /cordic_sin_cos_iterated/state_reg
add wave -noupdate /cordic_sin_cos_iterated/done_reg
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/iteration_cnt
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/init_x
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/init_y
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/init_z
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/alpha
add wave -noupdate /cordic_sin_cos_iterated/clkena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107 ns} 0}
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
WaveRestoreZoom {0 ns} {436 ns}
