onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/WIDTH
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/INITVAL
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/MAXITER
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/ADDWIDTH
add wave -noupdate -radix unsigned /cordic_sin_cos_iterated/COREWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /cordic_sin_cos_iterated/reset
add wave -noupdate /cordic_sin_cos_iterated/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /cordic_sin_cos_iterated/start
add wave -noupdate /cordic_sin_cos_iterated/ready
add wave -noupdate /cordic_sin_cos_iterated/done
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal -childformat {{{/cordic_sin_cos_iterated/arg[15]} -radix decimal} {{/cordic_sin_cos_iterated/arg[14]} -radix decimal} {{/cordic_sin_cos_iterated/arg[13]} -radix decimal} {{/cordic_sin_cos_iterated/arg[12]} -radix decimal} {{/cordic_sin_cos_iterated/arg[11]} -radix decimal} {{/cordic_sin_cos_iterated/arg[10]} -radix decimal} {{/cordic_sin_cos_iterated/arg[9]} -radix decimal} {{/cordic_sin_cos_iterated/arg[8]} -radix decimal} {{/cordic_sin_cos_iterated/arg[7]} -radix decimal} {{/cordic_sin_cos_iterated/arg[6]} -radix decimal} {{/cordic_sin_cos_iterated/arg[5]} -radix decimal} {{/cordic_sin_cos_iterated/arg[4]} -radix decimal} {{/cordic_sin_cos_iterated/arg[3]} -radix decimal} {{/cordic_sin_cos_iterated/arg[2]} -radix decimal} {{/cordic_sin_cos_iterated/arg[1]} -radix decimal} {{/cordic_sin_cos_iterated/arg[0]} -radix decimal}} -subitemconfig {{/cordic_sin_cos_iterated/arg[15]} {-radix decimal} {/cordic_sin_cos_iterated/arg[14]} {-radix decimal} {/cordic_sin_cos_iterated/arg[13]} {-radix decimal} {/cordic_sin_cos_iterated/arg[12]} {-radix decimal} {/cordic_sin_cos_iterated/arg[11]} {-radix decimal} {/cordic_sin_cos_iterated/arg[10]} {-radix decimal} {/cordic_sin_cos_iterated/arg[9]} {-radix decimal} {/cordic_sin_cos_iterated/arg[8]} {-radix decimal} {/cordic_sin_cos_iterated/arg[7]} {-radix decimal} {/cordic_sin_cos_iterated/arg[6]} {-radix decimal} {/cordic_sin_cos_iterated/arg[5]} {-radix decimal} {/cordic_sin_cos_iterated/arg[4]} {-radix decimal} {/cordic_sin_cos_iterated/arg[3]} {-radix decimal} {/cordic_sin_cos_iterated/arg[2]} {-radix decimal} {/cordic_sin_cos_iterated/arg[1]} {-radix decimal} {/cordic_sin_cos_iterated/arg[0]} {-radix decimal}} /cordic_sin_cos_iterated/arg
add wave -noupdate -color {Orange Red} -radix hexadecimal /cordic_sin_cos_iterated/core_y
add wave -noupdate -color {Orange Red} -radix decimal /cordic_sin_cos_iterated/sin
add wave -noupdate -color Gold -radix hexadecimal /cordic_sin_cos_iterated/core_x
add wave -noupdate -color Gold -radix decimal /cordic_sin_cos_iterated/cos
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/lookup_table
add wave -noupdate /cordic_sin_cos_iterated/state_reg
add wave -noupdate /cordic_sin_cos_iterated/done_reg
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/iteration_cnt
add wave -noupdate -radix hexadecimal -childformat {{{/cordic_sin_cos_iterated/init_x[21]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[20]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[19]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[18]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[17]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[16]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[15]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[14]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[13]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[12]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[11]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[10]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[9]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[8]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[7]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[6]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[5]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[4]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[3]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[2]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[1]} -radix hexadecimal} {{/cordic_sin_cos_iterated/init_x[0]} -radix hexadecimal}} -subitemconfig {{/cordic_sin_cos_iterated/init_x[21]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[20]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[19]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[18]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[17]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[16]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[15]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[14]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[13]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[12]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[11]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[10]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[9]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[8]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[7]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[6]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[5]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[4]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[3]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[2]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[1]} {-radix hexadecimal} {/cordic_sin_cos_iterated/init_x[0]} {-radix hexadecimal}} /cordic_sin_cos_iterated/init_x
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/init_y
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/init_z
add wave -noupdate -radix hexadecimal /cordic_sin_cos_iterated/alpha
add wave -noupdate /cordic_sin_cos_iterated/clkena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1560 ns} 0}
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
WaveRestoreZoom {1351 ns} {1803 ns}
