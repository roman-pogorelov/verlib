onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mmv_ram_march_c_tester_tb/reset
add wave -noupdate /mmv_ram_march_c_tester_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_ram_march_c_tester_tb/clear
add wave -noupdate /mmv_ram_march_c_tester_tb/start
add wave -noupdate /mmv_ram_march_c_tester_tb/ready
add wave -noupdate /mmv_ram_march_c_tester_tb/fault
add wave -noupdate /mmv_ram_march_c_tester_tb/done
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_ram_march_c_tester_tb/m_addr
add wave -noupdate /mmv_ram_march_c_tester_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmv_ram_march_c_tester_tb/m_wdat
add wave -noupdate /mmv_ram_march_c_tester_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmv_ram_march_c_tester_tb/m_rdat
add wave -noupdate /mmv_ram_march_c_tester_tb/m_rval
add wave -noupdate /mmv_ram_march_c_tester_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Slate Blue} /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/req_state
add wave -noupdate -color Magenta /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/ack_state
add wave -noupdate -divider <NULL>
add wave -noupdate -color Gold -radix hexadecimal /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/addr_inc_cnt
add wave -noupdate -color Gold -radix hexadecimal /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/addr_dec_cnt
add wave -noupdate -color Cyan -radix unsigned /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/wpass_cnt
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/wpat_upd_ena
add wave -noupdate /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/wpat_inv_ena
add wave -noupdate /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/addr_cnt_ena
add wave -noupdate /mmv_ram_march_c_tester_tb/the_mmv_ram_march_c_tester/addr_swp_ena
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6720000 ps} 0}
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
WaveRestoreZoom {0 ps} {16831672 ps}
