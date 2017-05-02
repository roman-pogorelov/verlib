onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /handshake_synchronizer/EXTRA_STAGES
add wave -noupdate -radix unsigned /handshake_synchronizer/HANDSHAKE_TYPE
add wave -noupdate -divider <NULL>
add wave -noupdate /handshake_synchronizer/src_reset
add wave -noupdate /handshake_synchronizer/src_clk
add wave -noupdate -divider <NULL>
add wave -noupdate /handshake_synchronizer/dst_reset
add wave -noupdate /handshake_synchronizer/dst_clk
add wave -noupdate -divider <NULL>
add wave -noupdate /handshake_synchronizer/src_req
add wave -noupdate /handshake_synchronizer/src_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /handshake_synchronizer/dst_req
add wave -noupdate /handshake_synchronizer/dst_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25 ns} 0}
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
WaveRestoreZoom {0 ns} {1208 ns}
