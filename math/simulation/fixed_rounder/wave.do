onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /fixed_rounder_tb/IWIDTH
add wave -noupdate -radix unsigned /fixed_rounder_tb/OWIDTH
add wave -noupdate -radix unsigned /fixed_rounder_tb/PIPELINE
add wave -noupdate -divider <NULL>
add wave -noupdate /fixed_rounder_tb/rst
add wave -noupdate /fixed_rounder_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /fixed_rounder_tb/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned -childformat {{{/fixed_rounder_tb/i_data[5]} -radix unsigned} {{/fixed_rounder_tb/i_data[4]} -radix unsigned} {{/fixed_rounder_tb/i_data[3]} -radix unsigned} {{/fixed_rounder_tb/i_data[2]} -radix unsigned} {{/fixed_rounder_tb/i_data[1]} -radix unsigned} {{/fixed_rounder_tb/i_data[0]} -radix unsigned}} -subitemconfig {{/fixed_rounder_tb/i_data[5]} {-height 15 -radix unsigned} {/fixed_rounder_tb/i_data[4]} {-height 15 -radix unsigned} {/fixed_rounder_tb/i_data[3]} {-height 15 -radix unsigned} {/fixed_rounder_tb/i_data[2]} {-height 15 -radix unsigned} {/fixed_rounder_tb/i_data[1]} {-height 15 -radix unsigned} {/fixed_rounder_tb/i_data[0]} {-height 15 -radix unsigned}} /fixed_rounder_tb/i_data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal -childformat {{{/fixed_rounder_tb/o_data[2]} -radix unsigned} {{/fixed_rounder_tb/o_data[1]} -radix unsigned} {{/fixed_rounder_tb/o_data[0]} -radix unsigned}} -subitemconfig {{/fixed_rounder_tb/o_data[2]} {-height 15 -radix unsigned} {/fixed_rounder_tb/o_data[1]} {-height 15 -radix unsigned} {/fixed_rounder_tb/o_data[0]} {-height 15 -radix unsigned}} /fixed_rounder_tb/o_data
add wave -noupdate -radix decimal /fixed_rounder_tb/r_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {660906 ps} 0} {{Cursor 2} {76258 ps} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ps} {1402912 ps}
