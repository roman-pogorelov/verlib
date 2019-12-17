onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tfp2fix/TFP_WIDTH
add wave -noupdate -radix unsigned /tfp2fix/EXP_WIDTH
add wave -noupdate -radix unsigned /tfp2fix/FIX_WIDTH
add wave -noupdate -radix unsigned /tfp2fix/PIPELINE
add wave -noupdate -divider <NULL>
add wave -noupdate /tfp2fix/rst
add wave -noupdate /tfp2fix/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /tfp2fix/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /tfp2fix/tfp_data
add wave -noupdate -radix decimal -childformat {{{/tfp2fix/fix_data[11]} -radix decimal} {{/tfp2fix/fix_data[10]} -radix decimal} {{/tfp2fix/fix_data[9]} -radix decimal} {{/tfp2fix/fix_data[8]} -radix decimal} {{/tfp2fix/fix_data[7]} -radix decimal} {{/tfp2fix/fix_data[6]} -radix decimal} {{/tfp2fix/fix_data[5]} -radix decimal} {{/tfp2fix/fix_data[4]} -radix decimal} {{/tfp2fix/fix_data[3]} -radix decimal} {{/tfp2fix/fix_data[2]} -radix decimal} {{/tfp2fix/fix_data[1]} -radix decimal} {{/tfp2fix/fix_data[0]} -radix decimal}} -subitemconfig {{/tfp2fix/fix_data[11]} {-radix decimal} {/tfp2fix/fix_data[10]} {-radix decimal} {/tfp2fix/fix_data[9]} {-radix decimal} {/tfp2fix/fix_data[8]} {-radix decimal} {/tfp2fix/fix_data[7]} {-radix decimal} {/tfp2fix/fix_data[6]} {-radix decimal} {/tfp2fix/fix_data[5]} {-radix decimal} {/tfp2fix/fix_data[4]} {-radix decimal} {/tfp2fix/fix_data[3]} {-radix decimal} {/tfp2fix/fix_data[2]} {-radix decimal} {/tfp2fix/fix_data[1]} {-radix decimal} {/tfp2fix/fix_data[0]} {-radix decimal}} /tfp2fix/fix_data
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /tfp2fix/emantissa
add wave -noupdate -radix hexadecimal /tfp2fix/exponent
add wave -noupdate -radix hexadecimal /tfp2fix/fixvalue
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {255 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
