onerror {resume}
quietly virtual function -install /lfsr_generator -env /lfsr_generator { &{/lfsr_generator/data[16], /lfsr_generator/data[17], /lfsr_generator/data[18], /lfsr_generator/data[19], /lfsr_generator/data[20], /lfsr_generator/data[21], /lfsr_generator/data[22], /lfsr_generator/data[23], /lfsr_generator/data[24], /lfsr_generator/data[25], /lfsr_generator/data[26], /lfsr_generator/data[27], /lfsr_generator/data[28], /lfsr_generator/data[29], /lfsr_generator/data[30], /lfsr_generator/data[31], /lfsr_generator/data[32], /lfsr_generator/data[33], /lfsr_generator/data[34], /lfsr_generator/data[35], /lfsr_generator/data[36], /lfsr_generator/data[37], /lfsr_generator/data[38], /lfsr_generator/data[39], /lfsr_generator/data[40], /lfsr_generator/data[41], /lfsr_generator/data[42], /lfsr_generator/data[43], /lfsr_generator/data[44], /lfsr_generator/data[45], /lfsr_generator/data[46], /lfsr_generator/data[47] }} seed
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /lfsr_generator/POLYDEGREE
add wave -noupdate -radix hexadecimal /lfsr_generator/POLYNOMIAL
add wave -noupdate -radix unsigned /lfsr_generator/REGWIDTH
add wave -noupdate -radix unsigned /lfsr_generator/STEPSIZE
add wave -noupdate -radix hexadecimal /lfsr_generator/REGINITIAL
add wave -noupdate -divider <NULL>
add wave -noupdate /lfsr_generator/reset
add wave -noupdate /lfsr_generator/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /lfsr_generator/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate /lfsr_generator/init
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal -childformat {{{/lfsr_generator/data[47]} -radix hexadecimal} {{/lfsr_generator/data[46]} -radix hexadecimal} {{/lfsr_generator/data[45]} -radix hexadecimal} {{/lfsr_generator/data[44]} -radix hexadecimal} {{/lfsr_generator/data[43]} -radix hexadecimal} {{/lfsr_generator/data[42]} -radix hexadecimal} {{/lfsr_generator/data[41]} -radix hexadecimal} {{/lfsr_generator/data[40]} -radix hexadecimal} {{/lfsr_generator/data[39]} -radix hexadecimal} {{/lfsr_generator/data[38]} -radix hexadecimal} {{/lfsr_generator/data[37]} -radix hexadecimal} {{/lfsr_generator/data[36]} -radix hexadecimal} {{/lfsr_generator/data[35]} -radix hexadecimal} {{/lfsr_generator/data[34]} -radix hexadecimal} {{/lfsr_generator/data[33]} -radix hexadecimal} {{/lfsr_generator/data[32]} -radix hexadecimal} {{/lfsr_generator/data[31]} -radix hexadecimal} {{/lfsr_generator/data[30]} -radix hexadecimal} {{/lfsr_generator/data[29]} -radix hexadecimal} {{/lfsr_generator/data[28]} -radix hexadecimal} {{/lfsr_generator/data[27]} -radix hexadecimal} {{/lfsr_generator/data[26]} -radix hexadecimal} {{/lfsr_generator/data[25]} -radix hexadecimal} {{/lfsr_generator/data[24]} -radix hexadecimal} {{/lfsr_generator/data[23]} -radix hexadecimal} {{/lfsr_generator/data[22]} -radix hexadecimal} {{/lfsr_generator/data[21]} -radix hexadecimal} {{/lfsr_generator/data[20]} -radix hexadecimal} {{/lfsr_generator/data[19]} -radix hexadecimal} {{/lfsr_generator/data[18]} -radix hexadecimal} {{/lfsr_generator/data[17]} -radix hexadecimal} {{/lfsr_generator/data[16]} -radix hexadecimal} {{/lfsr_generator/data[15]} -radix hexadecimal} {{/lfsr_generator/data[14]} -radix hexadecimal} {{/lfsr_generator/data[13]} -radix hexadecimal} {{/lfsr_generator/data[12]} -radix hexadecimal} {{/lfsr_generator/data[11]} -radix hexadecimal} {{/lfsr_generator/data[10]} -radix hexadecimal} {{/lfsr_generator/data[9]} -radix hexadecimal} {{/lfsr_generator/data[8]} -radix hexadecimal} {{/lfsr_generator/data[7]} -radix hexadecimal} {{/lfsr_generator/data[6]} -radix hexadecimal} {{/lfsr_generator/data[5]} -radix hexadecimal} {{/lfsr_generator/data[4]} -radix hexadecimal} {{/lfsr_generator/data[3]} -radix hexadecimal} {{/lfsr_generator/data[2]} -radix hexadecimal} {{/lfsr_generator/data[1]} -radix hexadecimal} {{/lfsr_generator/data[0]} -radix hexadecimal}} -subitemconfig {{/lfsr_generator/data[47]} {-radix hexadecimal} {/lfsr_generator/data[46]} {-radix hexadecimal} {/lfsr_generator/data[45]} {-radix hexadecimal} {/lfsr_generator/data[44]} {-radix hexadecimal} {/lfsr_generator/data[43]} {-radix hexadecimal} {/lfsr_generator/data[42]} {-radix hexadecimal} {/lfsr_generator/data[41]} {-radix hexadecimal} {/lfsr_generator/data[40]} {-radix hexadecimal} {/lfsr_generator/data[39]} {-radix hexadecimal} {/lfsr_generator/data[38]} {-radix hexadecimal} {/lfsr_generator/data[37]} {-radix hexadecimal} {/lfsr_generator/data[36]} {-radix hexadecimal} {/lfsr_generator/data[35]} {-radix hexadecimal} {/lfsr_generator/data[34]} {-radix hexadecimal} {/lfsr_generator/data[33]} {-radix hexadecimal} {/lfsr_generator/data[32]} {-radix hexadecimal} {/lfsr_generator/data[31]} {-radix hexadecimal} {/lfsr_generator/data[30]} {-radix hexadecimal} {/lfsr_generator/data[29]} {-radix hexadecimal} {/lfsr_generator/data[28]} {-radix hexadecimal} {/lfsr_generator/data[27]} {-radix hexadecimal} {/lfsr_generator/data[26]} {-radix hexadecimal} {/lfsr_generator/data[25]} {-radix hexadecimal} {/lfsr_generator/data[24]} {-radix hexadecimal} {/lfsr_generator/data[23]} {-radix hexadecimal} {/lfsr_generator/data[22]} {-radix hexadecimal} {/lfsr_generator/data[21]} {-radix hexadecimal} {/lfsr_generator/data[20]} {-radix hexadecimal} {/lfsr_generator/data[19]} {-radix hexadecimal} {/lfsr_generator/data[18]} {-radix hexadecimal} {/lfsr_generator/data[17]} {-radix hexadecimal} {/lfsr_generator/data[16]} {-radix hexadecimal} {/lfsr_generator/data[15]} {-radix hexadecimal} {/lfsr_generator/data[14]} {-radix hexadecimal} {/lfsr_generator/data[13]} {-radix hexadecimal} {/lfsr_generator/data[12]} {-radix hexadecimal} {/lfsr_generator/data[11]} {-radix hexadecimal} {/lfsr_generator/data[10]} {-radix hexadecimal} {/lfsr_generator/data[9]} {-radix hexadecimal} {/lfsr_generator/data[8]} {-radix hexadecimal} {/lfsr_generator/data[7]} {-radix hexadecimal} {/lfsr_generator/data[6]} {-radix hexadecimal} {/lfsr_generator/data[5]} {-radix hexadecimal} {/lfsr_generator/data[4]} {-radix hexadecimal} {/lfsr_generator/data[3]} {-radix hexadecimal} {/lfsr_generator/data[2]} {-radix hexadecimal} {/lfsr_generator/data[1]} {-radix hexadecimal} {/lfsr_generator/data[0]} {-radix hexadecimal}} /lfsr_generator/data
add wave -noupdate -radix hexadecimal /lfsr_generator/seed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {163 ns} 0}
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
WaveRestoreZoom {70 ns} {250 ns}
