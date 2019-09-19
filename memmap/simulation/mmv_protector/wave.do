onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mmv_protector/MAXPENDRD
add wave -noupdate -radix unsigned /mmv_protector/BUSYTIMEOUT
add wave -noupdate -radix unsigned /mmv_protector/RVALTIMEOUT
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_protector/rst
add wave -noupdate /mmv_protector/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_protector/s_addr
add wave -noupdate /mmv_protector/s_wreq
add wave -noupdate -radix hexadecimal /mmv_protector/s_wdat
add wave -noupdate /mmv_protector/s_rreq
add wave -noupdate -radix hexadecimal /mmv_protector/s_rdat
add wave -noupdate /mmv_protector/s_rval
add wave -noupdate /mmv_protector/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_protector/m_addr
add wave -noupdate /mmv_protector/m_wreq
add wave -noupdate -radix hexadecimal /mmv_protector/m_wdat
add wave -noupdate /mmv_protector/m_rreq
add wave -noupdate -radix hexadecimal /mmv_protector/m_rdat
add wave -noupdate /mmv_protector/m_rval
add wave -noupdate /mmv_protector/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_protector/busy_timeout
add wave -noupdate /mmv_protector/rval_timeout
add wave -noupdate /mmv_protector/rval_is_odd
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /mmv_protector/busy_timeout_cnt
add wave -noupdate /mmv_protector/busy_interrupt_reg
add wave -noupdate -radix unsigned /mmv_protector/timestamp_cnt
add wave -noupdate -radix unsigned /mmv_protector/rreq_timestamp
add wave -noupdate /mmv_protector/rreq_fifo_empty
add wave -noupdate /mmv_protector/rreq_fifo_full
add wave -noupdate /mmv_protector/forced_rval
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_protector/rreq_fifo/wrreq
add wave -noupdate -radix hexadecimal /mmv_protector/rreq_fifo/data
add wave -noupdate /mmv_protector/rreq_fifo/rdreq
add wave -noupdate -radix hexadecimal /mmv_protector/rreq_fifo/q
add wave -noupdate /mmv_protector/rreq_fifo/full
add wave -noupdate /mmv_protector/rreq_fifo/empty
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {15619 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
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
WaveRestoreZoom {0 ps} {337920 ps}
