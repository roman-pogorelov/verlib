onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_width_divider/WIDTH
add wave -noupdate -radix unsigned /ps_width_divider/COUNT
add wave -noupdate -radix unsigned /ps_width_divider/MAX_MTY
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_width_divider/reset
add wave -noupdate /ps_width_divider/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal -childformat {{{/ps_width_divider/i_dat[31]} -radix hexadecimal} {{/ps_width_divider/i_dat[30]} -radix hexadecimal} {{/ps_width_divider/i_dat[29]} -radix hexadecimal} {{/ps_width_divider/i_dat[28]} -radix hexadecimal} {{/ps_width_divider/i_dat[27]} -radix hexadecimal} {{/ps_width_divider/i_dat[26]} -radix hexadecimal} {{/ps_width_divider/i_dat[25]} -radix hexadecimal} {{/ps_width_divider/i_dat[24]} -radix hexadecimal} {{/ps_width_divider/i_dat[23]} -radix hexadecimal} {{/ps_width_divider/i_dat[22]} -radix hexadecimal} {{/ps_width_divider/i_dat[21]} -radix hexadecimal} {{/ps_width_divider/i_dat[20]} -radix hexadecimal} {{/ps_width_divider/i_dat[19]} -radix hexadecimal} {{/ps_width_divider/i_dat[18]} -radix hexadecimal} {{/ps_width_divider/i_dat[17]} -radix hexadecimal} {{/ps_width_divider/i_dat[16]} -radix hexadecimal} {{/ps_width_divider/i_dat[15]} -radix unsigned} {{/ps_width_divider/i_dat[14]} -radix unsigned} {{/ps_width_divider/i_dat[13]} -radix unsigned} {{/ps_width_divider/i_dat[12]} -radix unsigned} {{/ps_width_divider/i_dat[11]} -radix unsigned} {{/ps_width_divider/i_dat[10]} -radix unsigned} {{/ps_width_divider/i_dat[9]} -radix unsigned} {{/ps_width_divider/i_dat[8]} -radix unsigned} {{/ps_width_divider/i_dat[7]} -radix unsigned} {{/ps_width_divider/i_dat[6]} -radix unsigned} {{/ps_width_divider/i_dat[5]} -radix unsigned} {{/ps_width_divider/i_dat[4]} -radix unsigned} {{/ps_width_divider/i_dat[3]} -radix unsigned} {{/ps_width_divider/i_dat[2]} -radix unsigned} {{/ps_width_divider/i_dat[1]} -radix unsigned} {{/ps_width_divider/i_dat[0]} -radix unsigned}} -subitemconfig {{/ps_width_divider/i_dat[31]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[30]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[29]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[28]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[27]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[26]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[25]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[24]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[23]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[22]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[21]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[20]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[19]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[18]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[17]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[16]} {-height 15 -radix hexadecimal} {/ps_width_divider/i_dat[15]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[14]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[13]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[12]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[11]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[10]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[9]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[8]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[7]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[6]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[5]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[4]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[3]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[2]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[1]} {-height 15 -radix unsigned} {/ps_width_divider/i_dat[0]} {-height 15 -radix unsigned}} /ps_width_divider/i_dat
add wave -noupdate -radix unsigned /ps_width_divider/i_mty
add wave -noupdate /ps_width_divider/i_val
add wave -noupdate /ps_width_divider/i_eop
add wave -noupdate /ps_width_divider/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Orange Red} -radix hexadecimal /ps_width_divider/o_dat
add wave -noupdate -color {Orange Red} /ps_width_divider/o_val
add wave -noupdate -color {Orange Red} /ps_width_divider/o_eop
add wave -noupdate -color {Orange Red} /ps_width_divider/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_width_divider/wodr_cnt
add wave -noupdate /ps_width_divider/shift_done_reg
add wave -noupdate -radix hexadecimal /ps_width_divider/shift_data_reg
add wave -noupdate /ps_width_divider/eop_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24 ns} 0}
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
WaveRestoreZoom {0 ns} {460 ns}
