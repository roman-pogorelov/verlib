onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /crc_calculator_tb/DATAWIDTH
add wave -noupdate -radix unsigned /crc_calculator_tb/CRCWIDTH
add wave -noupdate -radix hexadecimal /crc_calculator_tb/POLYNOMIAL
add wave -noupdate -radix hexadecimal /crc_calculator_tb/INIT
add wave -noupdate -divider <NULL>
add wave -noupdate /crc_calculator_tb/reset
add wave -noupdate /crc_calculator_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /crc_calculator_tb/data
add wave -noupdate -radix hexadecimal /crc_calculator_tb/data_rev
add wave -noupdate -divider <NULL>
add wave -noupdate /crc_calculator_tb/clkena
add wave -noupdate -radix hexadecimal /crc_calculator_tb/crc_reg
add wave -noupdate -radix hexadecimal /crc_calculator_tb/crc_new
add wave -noupdate -radix hexadecimal /crc_calculator_tb/crc_new_rev
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27935 ps} 0}
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
