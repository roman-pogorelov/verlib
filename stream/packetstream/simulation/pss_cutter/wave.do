onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /pss_cutter/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /pss_cutter/rst
add wave -noupdate /pss_cutter/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /pss_cutter/cut
add wave -noupdate -divider <NULL>
add wave -noupdate /pss_cutter/lost
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /pss_cutter/i_dat
add wave -noupdate /pss_cutter/i_val
add wave -noupdate /pss_cutter/i_sop
add wave -noupdate /pss_cutter/i_eop
add wave -noupdate /pss_cutter/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /pss_cutter/o_dat
add wave -noupdate /pss_cutter/o_val
add wave -noupdate /pss_cutter/o_sop
add wave -noupdate /pss_cutter/o_eop
add wave -noupdate /pss_cutter/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /pss_cutter/cut_reg
add wave -noupdate /pss_cutter/cutting
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
