onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_head_inserter/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_inserter/reset
add wave -noupdate /ps_head_inserter/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_inserter/insert
add wave -noupdate -divider <NULL>
add wave -noupdate -color Maroon -radix hexadecimal /ps_head_inserter/h_dat
add wave -noupdate -color Maroon /ps_head_inserter/h_val
add wave -noupdate -color Maroon /ps_head_inserter/h_eop
add wave -noupdate -color Maroon /ps_head_inserter/h_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_head_inserter/i_dat
add wave -noupdate /ps_head_inserter/i_val
add wave -noupdate /ps_head_inserter/i_eop
add wave -noupdate /ps_head_inserter/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Steel Blue} -radix hexadecimal /ps_head_inserter/o_dat
add wave -noupdate -color {Steel Blue} /ps_head_inserter/o_val
add wave -noupdate -color {Steel Blue} /ps_head_inserter/o_eop
add wave -noupdate -color {Steel Blue} /ps_head_inserter/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_inserter/sop_reg
add wave -noupdate /ps_head_inserter/head_inserted_reg
add wave -noupdate /ps_head_inserter/head_inserted
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30 ns} 0}
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
WaveRestoreZoom {0 ns} {376 ns}
