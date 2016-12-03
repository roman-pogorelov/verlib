onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_head_pass_tb/DWIDTH
add wave -noupdate -radix unsigned /ps_head_pass_tb/LWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_pass_tb/reset
add wave -noupdate /ps_head_pass_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_pass_tb/headon
add wave -noupdate -radix unsigned /ps_head_pass_tb/length
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Medium Violet Red} -radix hexadecimal /ps_head_pass_tb/i_dat
add wave -noupdate -color {Medium Violet Red} /ps_head_pass_tb/i_val
add wave -noupdate -color {Medium Violet Red} /ps_head_pass_tb/i_eop
add wave -noupdate -color {Medium Violet Red} /ps_head_pass_tb/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Steel Blue} -radix hexadecimal /ps_head_pass_tb/o_dat
add wave -noupdate -color {Steel Blue} /ps_head_pass_tb/o_val
add wave -noupdate -color {Steel Blue} /ps_head_pass_tb/o_eop
add wave -noupdate -color {Steel Blue} /ps_head_pass_tb/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_head_pass_tb/h_dat
add wave -noupdate /ps_head_pass_tb/h_val
add wave -noupdate /ps_head_pass_tb/h_eop
add wave -noupdate /ps_head_pass_tb/h_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_head_pass_tb/d_dat
add wave -noupdate /ps_head_pass_tb/d_val
add wave -noupdate /ps_head_pass_tb/d_eop
add wave -noupdate /ps_head_pass_tb/d_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_head_pass_tb/i_counter
add wave -noupdate -radix unsigned /ps_head_pass_tb/o_counter
add wave -noupdate -radix unsigned /ps_head_pass_tb/h_counter
add wave -noupdate -radix unsigned /ps_head_pass_tb/d_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {155624 ps} 0}
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
WaveRestoreZoom {0 ps} {372944 ps}
