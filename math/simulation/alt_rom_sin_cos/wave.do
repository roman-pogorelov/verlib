onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /alt_rom_sin_cos_tb/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /alt_rom_sin_cos_tb/reset
add wave -noupdate /alt_rom_sin_cos_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /alt_rom_sin_cos_tb/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -format Analog-Step -height 74 -max 65534.999999999993 -radix unsigned /alt_rom_sin_cos_tb/arg
add wave -noupdate -divider <NULL>
add wave -noupdate -color Red -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /alt_rom_sin_cos_tb/sin
add wave -noupdate -color Gold -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /alt_rom_sin_cos_tb/cos
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {707580000 ps} 0}
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
WaveRestoreZoom {445117676 ps} {2081835912 ps}
