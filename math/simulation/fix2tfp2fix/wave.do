onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /fix2tfp2fix_tb/TFP_WIDTH
add wave -noupdate -radix unsigned /fix2tfp2fix_tb/EXP_WIDTH
add wave -noupdate -radix unsigned /fix2tfp2fix_tb/FIX_WIDTH
add wave -noupdate -radix ascii /fix2tfp2fix_tb/SIGNREP
add wave -noupdate -radix unsigned /fix2tfp2fix_tb/PIPELINE
add wave -noupdate -divider <NULL>
add wave -noupdate /fix2tfp2fix_tb/rst
add wave -noupdate /fix2tfp2fix_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /fix2tfp2fix_tb/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal /fix2tfp2fix_tb/inp_data
add wave -noupdate -radix decimal /fix2tfp2fix_tb/out_data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /fix2tfp2fix_tb/tfp_data
add wave -noupdate -radix decimal /fix2tfp2fix_tb/the_tfp2fix/emantissa
add wave -noupdate -radix unsigned /fix2tfp2fix_tb/the_tfp2fix/exponent
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21204 ps} 0}
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {512 ns}
