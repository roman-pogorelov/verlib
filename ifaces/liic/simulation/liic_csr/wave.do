onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /liic_csr/rst
add wave -noupdate /liic_csr/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_csr/ll_linkup
add wave -noupdate /liic_csr/ll_hpi_rcvd
add wave -noupdate /liic_csr/ll_hpi_lost
add wave -noupdate /liic_csr/ll_hpo_sent
add wave -noupdate /liic_csr/ll_hpo_lost
add wave -noupdate /liic_csr/ll_lpi_rcvd
add wave -noupdate /liic_csr/ll_lpi_lost
add wave -noupdate /liic_csr/ll_lpo_sent
add wave -noupdate /liic_csr/ll_lpo_lost
add wave -noupdate /liic_csr/mm_busy_timeout
add wave -noupdate /liic_csr/mm_rval_timeout
add wave -noupdate /liic_csr/mm_rval_is_odd
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_csr/cs_addr
add wave -noupdate /liic_csr/cs_wreq
add wave -noupdate -radix hexadecimal /liic_csr/cs_wdat
add wave -noupdate /liic_csr/cs_rreq
add wave -noupdate -radix hexadecimal /liic_csr/cs_rdat
add wave -noupdate /liic_csr/cs_rval
add wave -noupdate /liic_csr/cs_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /liic_csr/link_establish_cnt
add wave -noupdate -radix unsigned /liic_csr/link_duration_cnt
add wave -noupdate -radix unsigned /liic_csr/hpi_rcvd_cnt
add wave -noupdate -radix unsigned /liic_csr/hpi_lost_cnt
add wave -noupdate -radix unsigned /liic_csr/hpo_sent_cnt
add wave -noupdate -radix unsigned /liic_csr/hpo_lost_cnt
add wave -noupdate -radix unsigned /liic_csr/lpi_rcvd_cnt
add wave -noupdate -radix unsigned /liic_csr/lpi_lost_cnt
add wave -noupdate -radix unsigned /liic_csr/lpo_sent_cnt
add wave -noupdate -radix unsigned /liic_csr/lpo_lost_cnt
add wave -noupdate -radix unsigned /liic_csr/mm_busytimeout_cnt
add wave -noupdate -radix unsigned /liic_csr/mm_rvaltimeout_cnt
add wave -noupdate -radix unsigned /liic_csr/mm_oddrval_cnt
add wave -noupdate /liic_csr/mm_busytimeout_reg
add wave -noupdate /liic_csr/mm_rvaltimeout_reg
add wave -noupdate /liic_csr/mm_oddrval_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {122 ns} 0}
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
