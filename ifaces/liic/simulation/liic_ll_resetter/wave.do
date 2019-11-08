onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /liic_ll_resetter/LENGTH
add wave -noupdate -radix unsigned /liic_ll_resetter/PERIOD
add wave -noupdate -radix unsigned /liic_ll_resetter/MAXTIME
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_ll_resetter/rst
add wave -noupdate /liic_ll_resetter/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_ll_resetter/ll_linkup
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_ll_resetter/ll_reset
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_ll_resetter/reset_reg
add wave -noupdate /liic_ll_resetter/reset_next
add wave -noupdate -radix unsigned /liic_ll_resetter/time_cnt
add wave -noupdate /liic_ll_resetter/time_clr
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /liic_ll_resetter/cstate
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {200 ns} 0} {{Cursor 2} {546 ns} 0}
quietly wave cursor active 2
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
