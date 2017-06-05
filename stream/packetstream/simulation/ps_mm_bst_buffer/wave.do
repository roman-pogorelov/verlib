onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_mm_bst_buffer_tb/DWIDTH
add wave -noupdate -radix unsigned /ps_mm_bst_buffer_tb/AWIDTH
add wave -noupdate -radix unsigned /ps_mm_bst_buffer_tb/BWIDTH
add wave -noupdate -radix unsigned /ps_mm_bst_buffer_tb/SEGLEN
add wave -noupdate -radix unsigned /ps_mm_bst_buffer_tb/ERATIO
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_mm_bst_buffer_tb/reset
add wave -noupdate /ps_mm_bst_buffer_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_bst_buffer_tb/i_dat
add wave -noupdate /ps_mm_bst_buffer_tb/i_val
add wave -noupdate /ps_mm_bst_buffer_tb/i_eop
add wave -noupdate /ps_mm_bst_buffer_tb/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_bst_buffer_tb/o_dat
add wave -noupdate /ps_mm_bst_buffer_tb/o_val
add wave -noupdate /ps_mm_bst_buffer_tb/o_eop
add wave -noupdate /ps_mm_bst_buffer_tb/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_bst_buffer_tb/m_addr
add wave -noupdate -radix hexadecimal /ps_mm_bst_buffer_tb/m_bcnt
add wave -noupdate /ps_mm_bst_buffer_tb/m_wreq
add wave -noupdate -radix hexadecimal /ps_mm_bst_buffer_tb/m_wdat
add wave -noupdate /ps_mm_bst_buffer_tb/m_rreq
add wave -noupdate -radix hexadecimal /ps_mm_bst_buffer_tb/m_rdat
add wave -noupdate /ps_mm_bst_buffer_tb/m_rval
add wave -noupdate /ps_mm_bst_buffer_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/i_word_cnt
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/o_word_cnt
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/i_pack_cnt
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/o_pack_cnt
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/wreq_word_cnt
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/rreq_word_cnt
add wave -noupdate -color Magenta -radix unsigned /ps_mm_bst_buffer_tb/rack_word_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {798348 ps} 0}
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
WaveRestoreZoom {0 ps} {16384 ns}
