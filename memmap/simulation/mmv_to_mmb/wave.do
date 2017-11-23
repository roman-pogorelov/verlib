onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mmv_to_mmb_tb/AWIDTH
add wave -noupdate -radix unsigned /mmv_to_mmb_tb/DWIDTH
add wave -noupdate -radix unsigned /mmv_to_mmb_tb/BWIDTH
add wave -noupdate -radix unsigned /mmv_to_mmb_tb/RDPENDS
add wave -noupdate -radix unsigned /mmv_to_mmb_tb/RDDELAY
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_to_mmb_tb/reset
add wave -noupdate /mmv_to_mmb_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/s_addr
add wave -noupdate /mmv_to_mmb_tb/s_wreq
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/s_wdat
add wave -noupdate /mmv_to_mmb_tb/s_rreq
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/s_rdat
add wave -noupdate /mmv_to_mmb_tb/s_rval
add wave -noupdate /mmv_to_mmb_tb/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/m_addr
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/m_bcnt
add wave -noupdate /mmv_to_mmb_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/m_wdat
add wave -noupdate /mmv_to_mmb_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmv_to_mmb_tb/m_rdat
add wave -noupdate /mmv_to_mmb_tb/m_rval
add wave -noupdate /mmv_to_mmb_tb/m_busy
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {96217 ps} 0}
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
WaveRestoreZoom {0 ps} {1 us}
