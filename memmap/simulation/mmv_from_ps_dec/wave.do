onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mmv_from_ps_dec/rst
add wave -noupdate /mmv_from_ps_dec/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/m_addr
add wave -noupdate /mmv_from_ps_dec/m_wreq
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/m_wdat
add wave -noupdate /mmv_from_ps_dec/m_rreq
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/m_rdat
add wave -noupdate /mmv_from_ps_dec/m_rval
add wave -noupdate /mmv_from_ps_dec/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/i_dat
add wave -noupdate /mmv_from_ps_dec/i_val
add wave -noupdate /mmv_from_ps_dec/i_eop
add wave -noupdate /mmv_from_ps_dec/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/o_dat
add wave -noupdate /mmv_from_ps_dec/o_val
add wave -noupdate /mmv_from_ps_dec/o_eop
add wave -noupdate /mmv_from_ps_dec/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /mmv_from_ps_dec/cstate
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/enc_dat
add wave -noupdate /mmv_from_ps_dec/enc_val
add wave -noupdate /mmv_from_ps_dec/enc_eop
add wave -noupdate /mmv_from_ps_dec/enc_rdy
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/dec_addr
add wave -noupdate /mmv_from_ps_dec/dec_wreq
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/dec_wdat
add wave -noupdate /mmv_from_ps_dec/dec_rreq
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/dec_rdat
add wave -noupdate /mmv_from_ps_dec/dec_rval
add wave -noupdate /mmv_from_ps_dec/dec_busy
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/rdlim_cnt
add wave -noupdate /mmv_from_ps_dec/stop_reading
add wave -noupdate /mmv_from_ps_dec/wreq_reg
add wave -noupdate /mmv_from_ps_dec/rreq_reg
add wave -noupdate /mmv_from_ps_dec/request_set
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/address_reg
add wave -noupdate /mmv_from_ps_dec/address_set
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/fifo_rddata
add wave -noupdate /mmv_from_ps_dec/fifo_rdreq
add wave -noupdate /mmv_from_ps_dec/fifo_empty
add wave -noupdate /mmv_from_ps_dec/fifo_full
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/fifo_usedw
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/fifo_used
add wave -noupdate -radix hexadecimal /mmv_from_ps_dec/resp_pack_header
add wave -noupdate /mmv_from_ps_dec/resp_payload_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36666 ps} 0}
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
