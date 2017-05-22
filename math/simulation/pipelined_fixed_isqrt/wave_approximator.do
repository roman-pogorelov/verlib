onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt__approximator/WIDTH
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt__approximator/EWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt__approximator/reset
add wave -noupdate /pipelined_fixed_isqrt__approximator/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt__approximator/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/idata
add wave -noupdate -radix hexadecimal -childformat {{{/pipelined_fixed_isqrt__approximator/odata[31]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[30]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[29]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[28]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[27]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[26]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[25]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[24]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[23]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[22]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[21]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[20]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[19]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[18]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[17]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[16]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[15]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[14]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[13]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[12]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[11]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[10]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[9]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[8]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[7]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[6]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[5]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[4]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[3]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[2]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[1]} -radix hexadecimal} {{/pipelined_fixed_isqrt__approximator/odata[0]} -radix hexadecimal}} -subitemconfig {{/pipelined_fixed_isqrt__approximator/odata[31]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[30]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[29]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[28]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[27]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[26]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[25]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[24]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[23]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[22]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[21]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[20]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[19]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[18]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[17]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[16]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[15]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[14]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[13]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[12]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[11]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[10]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[9]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[8]} {-radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[7]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[6]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[5]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[4]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[3]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[2]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[1]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt__approximator/odata[0]} {-height 15 -radix hexadecimal}} /pipelined_fixed_isqrt__approximator/odata
add wave -noupdate -divider <NULL>
add wave -noupdate -color Salmon /pipelined_fixed_isqrt__approximator/idata_real
add wave -noupdate -color Salmon /pipelined_fixed_isqrt__approximator/odata_real
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt__approximator/P0
add wave -noupdate /pipelined_fixed_isqrt__approximator/P1
add wave -noupdate /pipelined_fixed_isqrt__approximator/P2
add wave -noupdate /pipelined_fixed_isqrt__approximator/P3
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p0
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p1
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p2
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p3
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/x2
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/x3
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p1x1
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p2x2
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p3x3
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/x1_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/x2_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/x3_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p1x1_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p2x2_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p3x3_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p1x1_p0_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p2x2_p1x1_p0_reg
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt__approximator/p3x3_p2x2_p1x1_p0_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {113 ns} 0}
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
WaveRestoreZoom {0 ns} {446 ns}
