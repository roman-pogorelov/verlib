onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/DWIDTH
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/AWIDTH
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/BWIDTH
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/IDEPTH
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/ODEPTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_mm_bst_buffer_tb/reset
add wave -noupdate /ds_mm_bst_buffer_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/i_dat
add wave -noupdate /ds_mm_bst_buffer_tb/i_val
add wave -noupdate /ds_mm_bst_buffer_tb/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/o_dat
add wave -noupdate /ds_mm_bst_buffer_tb/o_val
add wave -noupdate /ds_mm_bst_buffer_tb/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/m_addr
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/m_bcnt
add wave -noupdate /ds_mm_bst_buffer_tb/m_wreq
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/m_wdat
add wave -noupdate /ds_mm_bst_buffer_tb/m_rreq
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/m_rdat
add wave -noupdate /ds_mm_bst_buffer_tb/m_rval
add wave -noupdate /ds_mm_bst_buffer_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/i_word_cnt
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/o_word_cnt
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/wreq_word_cnt
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/rreq_word_cnt
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/rack_word_cnt
add wave -noupdate -divider <NULL>
add wave -noupdate -color Salmon /ds_mm_bst_buffer_tb/the_ds_mm_bst_buffer/state
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/the_ds_mm_bst_buffer/ififo_used
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/the_ds_mm_bst_buffer/free_cnt
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/the_ds_mm_bst_buffer/wr_bcnt_max
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/the_ds_mm_bst_buffer/wr_bcnt_reg
add wave -noupdate -radix unsigned /ds_mm_bst_buffer_tb/the_ds_mm_bst_buffer/wr_bcnt_cnt
add wave -noupdate -radix hexadecimal /ds_mm_bst_buffer_tb/the_avl_vlb_memory_model/memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2559493 ps} 0}
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
WaveRestoreZoom {2439507 ps} {2609875 ps}
