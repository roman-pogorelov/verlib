onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mmv_dcfifo_synchronizer/AWIDTH
add wave -noupdate -radix unsigned /mmv_dcfifo_synchronizer/DWIDTH
add wave -noupdate -radix unsigned /mmv_dcfifo_synchronizer/CMDLEN
add wave -noupdate -radix unsigned /mmv_dcfifo_synchronizer/READLEN
add wave -noupdate -radix unsigned /mmv_dcfifo_synchronizer/CWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_dcfifo_synchronizer/s_reset
add wave -noupdate /mmv_dcfifo_synchronizer/s_clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_dcfifo_synchronizer/s_addr
add wave -noupdate /mmv_dcfifo_synchronizer/s_wreq
add wave -noupdate -radix hexadecimal /mmv_dcfifo_synchronizer/s_wdat
add wave -noupdate /mmv_dcfifo_synchronizer/s_rreq
add wave -noupdate -radix hexadecimal /mmv_dcfifo_synchronizer/s_rdat
add wave -noupdate /mmv_dcfifo_synchronizer/s_rval
add wave -noupdate /mmv_dcfifo_synchronizer/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_dcfifo_synchronizer/m_reset
add wave -noupdate /mmv_dcfifo_synchronizer/m_clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_dcfifo_synchronizer/m_addr
add wave -noupdate /mmv_dcfifo_synchronizer/m_wreq
add wave -noupdate -radix hexadecimal /mmv_dcfifo_synchronizer/m_wdat
add wave -noupdate /mmv_dcfifo_synchronizer/m_rreq
add wave -noupdate -radix hexadecimal /mmv_dcfifo_synchronizer/m_rdat
add wave -noupdate /mmv_dcfifo_synchronizer/m_rval
add wave -noupdate /mmv_dcfifo_synchronizer/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /mmv_dcfifo_synchronizer/s_rd_pend_cnt
add wave -noupdate /mmv_dcfifo_synchronizer/s_rd_disable_reg
add wave -noupdate /mmv_dcfifo_synchronizer/s_cmd_fifo_rdy
add wave -noupdate /mmv_dcfifo_synchronizer/m_areq
add wave -noupdate /mmv_dcfifo_synchronizer/m_type
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {101053 ps} 0}
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
WaveRestoreZoom {0 ps} {512 ns}
