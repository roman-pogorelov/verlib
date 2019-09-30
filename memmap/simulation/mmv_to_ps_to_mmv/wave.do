onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mmv_to_ps_to_mmv_tb/rst
add wave -noupdate /mmv_to_ps_to_mmv_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/m_addr
add wave -noupdate /mmv_to_ps_to_mmv_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/m_wdat
add wave -noupdate /mmv_to_ps_to_mmv_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/m_rdat
add wave -noupdate /mmv_to_ps_to_mmv_tb/m_rval
add wave -noupdate /mmv_to_ps_to_mmv_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/s_addr
add wave -noupdate /mmv_to_ps_to_mmv_tb/s_wreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/s_wdat
add wave -noupdate /mmv_to_ps_to_mmv_tb/s_rreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/s_rdat
add wave -noupdate /mmv_to_ps_to_mmv_tb/s_rval
add wave -noupdate /mmv_to_ps_to_mmv_tb/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/req_dat
add wave -noupdate /mmv_to_ps_to_mmv_tb/req_val
add wave -noupdate /mmv_to_ps_to_mmv_tb/req_eop
add wave -noupdate /mmv_to_ps_to_mmv_tb/req_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/ack_dat
add wave -noupdate /mmv_to_ps_to_mmv_tb/ack_val
add wave -noupdate /mmv_to_ps_to_mmv_tb/ack_eop
add wave -noupdate /mmv_to_ps_to_mmv_tb/ack_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /mmv_to_ps_to_mmv_tb/the_mmv_to_ps_enc/cstate
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Dark Orchid} /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/cstate
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_addr
add wave -noupdate /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_wreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_wdat
add wave -noupdate /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_rreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_rdat
add wave -noupdate /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_rval
add wave -noupdate /mmv_to_ps_to_mmv_tb/the_mmv_from_ps_dec/dec_busy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68083 ps} 0}
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
WaveRestoreZoom {0 ps} {512388 ps}
