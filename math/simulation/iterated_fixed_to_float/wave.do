onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /iterated_fixed_to_float_tb/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /iterated_fixed_to_float_tb/reset
add wave -noupdate /iterated_fixed_to_float_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /iterated_fixed_to_float_tb/start
add wave -noupdate /iterated_fixed_to_float_tb/ready
add wave -noupdate /iterated_fixed_to_float_tb/done
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal -childformat {{{/iterated_fixed_to_float_tb/fixed[31]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[30]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[29]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[28]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[27]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[26]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[25]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[24]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[23]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[22]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[21]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[20]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[19]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[18]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[17]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[16]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[15]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[14]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[13]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[12]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[11]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[10]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[9]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[8]} -radix unsigned} {{/iterated_fixed_to_float_tb/fixed[7]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[6]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[5]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[4]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[3]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[2]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[1]} -radix hexadecimal} {{/iterated_fixed_to_float_tb/fixed[0]} -radix hexadecimal}} -subitemconfig {{/iterated_fixed_to_float_tb/fixed[31]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[30]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[29]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[28]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[27]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[26]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[25]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[24]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[23]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[22]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[21]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[20]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[19]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[18]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[17]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[16]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[15]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[14]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[13]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[12]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[11]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[10]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[9]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[8]} {-radix unsigned} {/iterated_fixed_to_float_tb/fixed[7]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[6]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[5]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[4]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[3]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[2]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[1]} {-height 15 -radix hexadecimal} {/iterated_fixed_to_float_tb/fixed[0]} {-height 15 -radix hexadecimal}} /iterated_fixed_to_float_tb/fixed
add wave -noupdate -radix hexadecimal /iterated_fixed_to_float_tb/float
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Orange Red} /iterated_fixed_to_float_tb/res
add wave -noupdate -divider <NULL>
add wave -noupdate /iterated_fixed_to_float_tb/the_iterated_fixed_to_float/state_reg
add wave -noupdate /iterated_fixed_to_float_tb/the_iterated_fixed_to_float/sign_bit_reg
add wave -noupdate -radix hexadecimal /iterated_fixed_to_float_tb/the_iterated_fixed_to_float/significand_reg
add wave -noupdate -radix hexadecimal /iterated_fixed_to_float_tb/the_iterated_fixed_to_float/exponent_reg
add wave -noupdate /iterated_fixed_to_float_tb/the_iterated_fixed_to_float/done_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {322 ns} 0}
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
