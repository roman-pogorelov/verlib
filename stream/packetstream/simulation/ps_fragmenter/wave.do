onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_fragmenter/WIDTH
add wave -noupdate -radix unsigned /ps_fragmenter/LENGTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_fragmenter/reset
add wave -noupdate /ps_fragmenter/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_fragmenter/i_dat
add wave -noupdate /ps_fragmenter/i_val
add wave -noupdate /ps_fragmenter/i_eop
add wave -noupdate /ps_fragmenter/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_fragmenter/o_len
add wave -noupdate /ps_fragmenter/o_fin
add wave -noupdate -radix hexadecimal /ps_fragmenter/o_dat
add wave -noupdate /ps_fragmenter/o_val
add wave -noupdate /ps_fragmenter/o_eop
add wave -noupdate /ps_fragmenter/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_fragmenter/len_cnt
add wave -noupdate /ps_fragmenter/i_eof
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24371 ps} 0}
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
WaveRestoreZoom {0 ps} {248832 ps}
