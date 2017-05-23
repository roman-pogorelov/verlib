onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ps_traffic_generator/reset
add wave -noupdate /ps_traffic_generator/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_traffic_generator/ctrl_addr
add wave -noupdate /ps_traffic_generator/ctrl_wreq
add wave -noupdate -radix hexadecimal /ps_traffic_generator/ctrl_wdat
add wave -noupdate /ps_traffic_generator/ctrl_rreq
add wave -noupdate -radix hexadecimal /ps_traffic_generator/ctrl_rdat
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_traffic_generator/o_dat
add wave -noupdate /ps_traffic_generator/o_val
add wave -noupdate /ps_traffic_generator/o_eop
add wave -noupdate /ps_traffic_generator/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_traffic_generator/data_reg
add wave -noupdate -radix hexadecimal /ps_traffic_generator/incr_reg
add wave -noupdate -radix hexadecimal /ps_traffic_generator/len_reg
add wave -noupdate -radix hexadecimal /ps_traffic_generator/len_cnt
add wave -noupdate -radix hexadecimal /ps_traffic_generator/amount_cnt
add wave -noupdate /ps_traffic_generator/val_reg
add wave -noupdate /ps_traffic_generator/eop_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {26 ns} 0}
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
WaveRestoreZoom {0 ns} {440 ns}
