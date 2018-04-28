onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ds_hs_synchronizer/WIDTH
add wave -noupdate -radix unsigned /ds_hs_synchronizer/ESTAGES
add wave -noupdate -radix unsigned /ds_hs_synchronizer/HSTYPE
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_hs_synchronizer/i_reset
add wave -noupdate /ds_hs_synchronizer/i_clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_hs_synchronizer/i_dat
add wave -noupdate /ds_hs_synchronizer/i_val
add wave -noupdate /ds_hs_synchronizer/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_hs_synchronizer/o_reset
add wave -noupdate /ds_hs_synchronizer/o_clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_hs_synchronizer/o_dat
add wave -noupdate /ds_hs_synchronizer/o_val
add wave -noupdate /ds_hs_synchronizer/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_hs_synchronizer/i2o_data_hold_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12 ns} 0}
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
WaveRestoreZoom {0 ns} {454 ns}
