onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /alt_rom_sin_two_arg_tb/reset
add wave -noupdate /alt_rom_sin_two_arg_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /alt_rom_sin_two_arg_tb/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate /alt_rom_sin_two_arg_tb/mode0
add wave -noupdate /alt_rom_sin_two_arg_tb/mode1
add wave -noupdate -divider <NULL>
add wave -noupdate -format Analog-Step -height 74 -max 32766.999999999993 -min -32768.0 -radix decimal /alt_rom_sin_two_arg_tb/arg0
add wave -noupdate -format Analog-Step -height 74 -max 32766.999999999993 -min -32768.0 -radix decimal /alt_rom_sin_two_arg_tb/arg1
add wave -noupdate -divider <NULL>
add wave -noupdate -color Gold -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /alt_rom_sin_two_arg_tb/func0
add wave -noupdate -color Red -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /alt_rom_sin_two_arg_tb/func1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {498410000 ps} 0}
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
WaveRestoreZoom {0 ps} {2097152 ns}
