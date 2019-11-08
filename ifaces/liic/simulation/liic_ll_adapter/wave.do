onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /liic_ll_adapter/rst
add wave -noupdate /liic_ll_adapter/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_ll_adapter/ll_linkup
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_ll_adapter/ll_i_lost
add wave -noupdate /liic_ll_adapter/ll_o_lost
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_ll_adapter/ll_i_dat
add wave -noupdate /liic_ll_adapter/ll_i_val
add wave -noupdate /liic_ll_adapter/ll_i_sop
add wave -noupdate /liic_ll_adapter/ll_i_eop
add wave -noupdate /liic_ll_adapter/ll_i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_ll_adapter/ll_o_dat
add wave -noupdate /liic_ll_adapter/ll_o_val
add wave -noupdate /liic_ll_adapter/ll_o_sop
add wave -noupdate /liic_ll_adapter/ll_o_eop
add wave -noupdate /liic_ll_adapter/ll_o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_ll_adapter/usr_i_dat
add wave -noupdate /liic_ll_adapter/usr_i_val
add wave -noupdate /liic_ll_adapter/usr_i_eop
add wave -noupdate /liic_ll_adapter/usr_i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_ll_adapter/usr_o_dat
add wave -noupdate /liic_ll_adapter/usr_o_val
add wave -noupdate /liic_ll_adapter/usr_o_eop
add wave -noupdate /liic_ll_adapter/usr_o_rdy
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
