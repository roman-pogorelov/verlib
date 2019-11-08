onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /liic_links_connection_tb/rst
add wave -noupdate /liic_links_connection_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dcs_addr
add wave -noupdate /liic_links_connection_tb/dcs_wreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dcs_wdat
add wave -noupdate /liic_links_connection_tb/dcs_rreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dcs_rdat
add wave -noupdate /liic_links_connection_tb/dcs_rval
add wave -noupdate /liic_links_connection_tb/dcs_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/ucs_addr
add wave -noupdate /liic_links_connection_tb/ucs_wreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/ucs_wdat
add wave -noupdate /liic_links_connection_tb/ucs_rreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/ucs_rdat
add wave -noupdate /liic_links_connection_tb/ucs_rval
add wave -noupdate /liic_links_connection_tb/ucs_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dmm_addr
add wave -noupdate /liic_links_connection_tb/dmm_wreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dmm_wdat
add wave -noupdate /liic_links_connection_tb/dmm_rreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dmm_rdat
add wave -noupdate /liic_links_connection_tb/dmm_rval
add wave -noupdate /liic_links_connection_tb/dmm_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/umm_addr
add wave -noupdate /liic_links_connection_tb/umm_wreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/umm_wdat
add wave -noupdate /liic_links_connection_tb/umm_rreq
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/umm_rdat
add wave -noupdate /liic_links_connection_tb/umm_rval
add wave -noupdate /liic_links_connection_tb/umm_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dst_i_dat
add wave -noupdate /liic_links_connection_tb/dst_i_val
add wave -noupdate /liic_links_connection_tb/dst_i_eop
add wave -noupdate /liic_links_connection_tb/dst_i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/dst_o_dat
add wave -noupdate /liic_links_connection_tb/dst_o_val
add wave -noupdate /liic_links_connection_tb/dst_o_eop
add wave -noupdate /liic_links_connection_tb/dst_o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/ust_i_dat
add wave -noupdate /liic_links_connection_tb/ust_i_val
add wave -noupdate /liic_links_connection_tb/ust_i_eop
add wave -noupdate /liic_links_connection_tb/ust_i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/ust_o_dat
add wave -noupdate /liic_links_connection_tb/ust_o_val
add wave -noupdate /liic_links_connection_tb/ust_o_eop
add wave -noupdate /liic_links_connection_tb/ust_o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_links_connection_tb/ll_d_linkup
add wave -noupdate /liic_links_connection_tb/ll_u_linkup
add wave -noupdate -divider <NULL>
add wave -noupdate /liic_links_connection_tb/ll_d_reset
add wave -noupdate /liic_links_connection_tb/ll_u_reset
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/llhp_d2u_dat
add wave -noupdate /liic_links_connection_tb/llhp_d2u_val
add wave -noupdate /liic_links_connection_tb/llhp_d2u_sop
add wave -noupdate /liic_links_connection_tb/llhp_d2u_eop
add wave -noupdate /liic_links_connection_tb/llhp_d2u_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/llhp_u2d_dat
add wave -noupdate /liic_links_connection_tb/llhp_u2d_val
add wave -noupdate /liic_links_connection_tb/llhp_u2d_sop
add wave -noupdate /liic_links_connection_tb/llhp_u2d_eop
add wave -noupdate /liic_links_connection_tb/llhp_u2d_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/lllp_d2u_dat
add wave -noupdate /liic_links_connection_tb/lllp_d2u_val
add wave -noupdate /liic_links_connection_tb/lllp_d2u_sop
add wave -noupdate /liic_links_connection_tb/lllp_d2u_eop
add wave -noupdate /liic_links_connection_tb/lllp_d2u_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /liic_links_connection_tb/lllp_u2d_dat
add wave -noupdate /liic_links_connection_tb/lllp_u2d_val
add wave -noupdate /liic_links_connection_tb/lllp_u2d_sop
add wave -noupdate /liic_links_connection_tb/lllp_u2d_eop
add wave -noupdate /liic_links_connection_tb/lllp_u2d_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29444 ps} 0}
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
