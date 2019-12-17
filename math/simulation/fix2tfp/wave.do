onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /fix2tfp/TFP_WIDTH
add wave -noupdate -radix unsigned /fix2tfp/EXP_WIDTH
add wave -noupdate -radix unsigned /fix2tfp/FIX_WIDTH
add wave -noupdate -radix unsigned /fix2tfp/PIPELINE
add wave -noupdate -divider <NULL>
add wave -noupdate /fix2tfp/rst
add wave -noupdate /fix2tfp/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /fix2tfp/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal /fix2tfp/fix_data
add wave -noupdate -radix hexadecimal /fix2tfp/tfp_data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /fix2tfp/off
add wave -noupdate -radix unsigned /fix2tfp/exp
add wave -noupdate -radix unsigned /fix2tfp/offset_to_round
add wave -noupdate -radix unsigned /fix2tfp/data_to_round
add wave -noupdate -radix decimal /fix2tfp/mantissa
add wave -noupdate -radix unsigned /fix2tfp/exponent
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
