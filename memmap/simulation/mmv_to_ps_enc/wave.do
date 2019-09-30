onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mmv_to_ps_enc/rst
add wave -noupdate /mmv_to_ps_enc/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/s_addr
add wave -noupdate /mmv_to_ps_enc/s_wreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/s_wdat
add wave -noupdate /mmv_to_ps_enc/s_rreq
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/s_rdat
add wave -noupdate /mmv_to_ps_enc/s_rval
add wave -noupdate /mmv_to_ps_enc/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/i_dat
add wave -noupdate /mmv_to_ps_enc/i_val
add wave -noupdate /mmv_to_ps_enc/i_eop
add wave -noupdate /mmv_to_ps_enc/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/o_dat
add wave -noupdate /mmv_to_ps_enc/o_val
add wave -noupdate /mmv_to_ps_enc/o_eop
add wave -noupdate /mmv_to_ps_enc/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /mmv_to_ps_enc/cstate
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/pack_header
add wave -noupdate -radix hexadecimal /mmv_to_ps_enc/enc_dat
add wave -noupdate /mmv_to_ps_enc/enc_val
add wave -noupdate /mmv_to_ps_enc/enc_eop
add wave -noupdate /mmv_to_ps_enc/enc_rdy
add wave -noupdate /mmv_to_ps_enc/busy
add wave -noupdate /mmv_to_ps_enc/busy_next
add wave -noupdate /mmv_to_ps_enc/i_sop
add wave -noupdate /mmv_to_ps_enc/res_val
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {230 ns} 0}
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
