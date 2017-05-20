onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_sop_protector/WIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_sop_protector/reset
add wave -noupdate /ps_sop_protector/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_sop_protector/i_dat
add wave -noupdate /ps_sop_protector/i_val
add wave -noupdate /ps_sop_protector/i_sop
add wave -noupdate /ps_sop_protector/i_eop
add wave -noupdate /ps_sop_protector/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_sop_protector/o_dat
add wave -noupdate /ps_sop_protector/o_val
add wave -noupdate /ps_sop_protector/o_sop
add wave -noupdate /ps_sop_protector/o_eop
add wave -noupdate /ps_sop_protector/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_sop_protector/pass_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {148 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
