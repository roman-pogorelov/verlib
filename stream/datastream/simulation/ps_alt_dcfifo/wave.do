onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ds_alt_dcfifo/DWIDTH
add wave -noupdate -radix unsigned /ds_alt_dcfifo/DEPTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_alt_dcfifo/reset
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_alt_dcfifo/i_clk
add wave -noupdate -radix hexadecimal /ds_alt_dcfifo/i_dat
add wave -noupdate /ds_alt_dcfifo/i_val
add wave -noupdate /ds_alt_dcfifo/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_alt_dcfifo/o_clk
add wave -noupdate -radix hexadecimal /ds_alt_dcfifo/o_dat
add wave -noupdate /ds_alt_dcfifo/o_val
add wave -noupdate /ds_alt_dcfifo/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ds_alt_dcfifo/the_dcfifo/wrusedw
add wave -noupdate -radix unsigned /ds_alt_dcfifo/the_dcfifo/rdusedw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49138 ps} 0}
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
WaveRestoreZoom {0 ps} {1021952 ps}
