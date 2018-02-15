onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_head_separator_tb/WIDTH
add wave -noupdate -radix unsigned /ps_head_separator_tb/LENGTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_separator_tb/reset
add wave -noupdate /ps_head_separator_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_head_separator_tb/i_dat
add wave -noupdate /ps_head_separator_tb/i_val
add wave -noupdate /ps_head_separator_tb/i_eop
add wave -noupdate /ps_head_separator_tb/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_head_separator_tb/o_hdr
add wave -noupdate -radix unsigned /ps_head_separator_tb/o_len
add wave -noupdate -radix unsigned /ps_head_separator_tb/o_dat
add wave -noupdate /ps_head_separator_tb/o_val
add wave -noupdate /ps_head_separator_tb/o_eop
add wave -noupdate /ps_head_separator_tb/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_head_separator_tb/DUT/header_cnt
add wave -noupdate /ps_head_separator_tb/DUT/header_end_reg
add wave -noupdate /ps_head_separator_tb/DUT/header_early_end_reg
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_head_separator_tb/i_counter
add wave -noupdate -radix unsigned /ps_head_separator_tb/o_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2089318 ps} 0}
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
WaveRestoreZoom {2017583 ps} {2430655 ps}
