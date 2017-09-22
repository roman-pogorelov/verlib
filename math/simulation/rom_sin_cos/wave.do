onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /rom_sin_cos_tb/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /rom_sin_cos_tb/reset
add wave -noupdate /rom_sin_cos_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /rom_sin_cos_tb/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -format Analog-Step -height 74 -max 49994.0 -radix unsigned -childformat {{{/rom_sin_cos_tb/arg[15]} -radix unsigned} {{/rom_sin_cos_tb/arg[14]} -radix unsigned} {{/rom_sin_cos_tb/arg[13]} -radix unsigned} {{/rom_sin_cos_tb/arg[12]} -radix unsigned} {{/rom_sin_cos_tb/arg[11]} -radix unsigned} {{/rom_sin_cos_tb/arg[10]} -radix unsigned} {{/rom_sin_cos_tb/arg[9]} -radix unsigned} {{/rom_sin_cos_tb/arg[8]} -radix unsigned} {{/rom_sin_cos_tb/arg[7]} -radix unsigned} {{/rom_sin_cos_tb/arg[6]} -radix unsigned} {{/rom_sin_cos_tb/arg[5]} -radix unsigned} {{/rom_sin_cos_tb/arg[4]} -radix unsigned} {{/rom_sin_cos_tb/arg[3]} -radix unsigned} {{/rom_sin_cos_tb/arg[2]} -radix unsigned} {{/rom_sin_cos_tb/arg[1]} -radix unsigned} {{/rom_sin_cos_tb/arg[0]} -radix unsigned}} -subitemconfig {{/rom_sin_cos_tb/arg[15]} {-radix unsigned} {/rom_sin_cos_tb/arg[14]} {-radix unsigned} {/rom_sin_cos_tb/arg[13]} {-radix unsigned} {/rom_sin_cos_tb/arg[12]} {-radix unsigned} {/rom_sin_cos_tb/arg[11]} {-radix unsigned} {/rom_sin_cos_tb/arg[10]} {-radix unsigned} {/rom_sin_cos_tb/arg[9]} {-radix unsigned} {/rom_sin_cos_tb/arg[8]} {-radix unsigned} {/rom_sin_cos_tb/arg[7]} {-radix unsigned} {/rom_sin_cos_tb/arg[6]} {-radix unsigned} {/rom_sin_cos_tb/arg[5]} {-radix unsigned} {/rom_sin_cos_tb/arg[4]} {-radix unsigned} {/rom_sin_cos_tb/arg[3]} {-radix unsigned} {/rom_sin_cos_tb/arg[2]} {-radix unsigned} {/rom_sin_cos_tb/arg[1]} {-radix unsigned} {/rom_sin_cos_tb/arg[0]} {-radix unsigned}} /rom_sin_cos_tb/arg
add wave -noupdate -divider <NULL>
add wave -noupdate -color Red -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /rom_sin_cos_tb/sin
add wave -noupdate -color Gold -format Analog-Step -height 74 -max 32767.0 -min -32767.0 -radix decimal /rom_sin_cos_tb/cos
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {805400000 ps} 0}
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
WaveRestoreZoom {0 ps} {3723827524 ps}
