onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_head_extractor/DWIDTH
add wave -noupdate -radix unsigned /ps_head_extractor/LWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_extractor/reset
add wave -noupdate /ps_head_extractor/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_extractor/extract
add wave -noupdate -radix unsigned /ps_head_extractor/length
add wave -noupdate -divider <NULL>
add wave -noupdate -color Maroon -radix hexadecimal /ps_head_extractor/h_dat
add wave -noupdate -color Maroon /ps_head_extractor/h_val
add wave -noupdate -color Maroon /ps_head_extractor/h_eop
add wave -noupdate -color Maroon /ps_head_extractor/h_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_head_extractor/i_dat
add wave -noupdate /ps_head_extractor/i_val
add wave -noupdate /ps_head_extractor/i_eop
add wave -noupdate /ps_head_extractor/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Steel Blue} -radix hexadecimal /ps_head_extractor/o_dat
add wave -noupdate -color {Steel Blue} /ps_head_extractor/o_val
add wave -noupdate -color {Steel Blue} /ps_head_extractor/o_eop
add wave -noupdate -color {Steel Blue} /ps_head_extractor/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_head_extractor/sop_reg
add wave -noupdate -radix unsigned /ps_head_extractor/len_cnt
add wave -noupdate /ps_head_extractor/count_h_eop_reg
add wave -noupdate /ps_head_extractor/count_h_eop
add wave -noupdate /ps_head_extractor/hdr_done_reg
add wave -noupdate /ps_head_extractor/hdr_done
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {147 ns} 0}
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
WaveRestoreZoom {0 ns} {486 ns}
