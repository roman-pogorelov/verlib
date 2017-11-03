onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mmv_ram_ab_tester_tb/AWIDTH
add wave -noupdate -radix unsigned /mmv_ram_ab_tester_tb/DWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_ram_ab_tester_tb/reset
add wave -noupdate /mmv_ram_ab_tester_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_ram_ab_tester_tb/clear
add wave -noupdate /mmv_ram_ab_tester_tb/start
add wave -noupdate /mmv_ram_ab_tester_tb/ready
add wave -noupdate /mmv_ram_ab_tester_tb/fault
add wave -noupdate /mmv_ram_ab_tester_tb/done
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_ram_ab_tester_tb/m_addr
add wave -noupdate /mmv_ram_ab_tester_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmv_ram_ab_tester_tb/m_wdat
add wave -noupdate /mmv_ram_ab_tester_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmv_ram_ab_tester_tb/m_rdat
add wave -noupdate /mmv_ram_ab_tester_tb/m_rval
add wave -noupdate /mmv_ram_ab_tester_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /mmv_ram_ab_tester_tb/the_mmv_ram_ab_tester/req_state
add wave -noupdate -color {Dark Orchid} /mmv_ram_ab_tester_tb/the_mmv_ram_ab_tester/ack_state
add wave -noupdate -divider <NULL>
add wave -noupdate -color Gold -radix unsigned /mmv_ram_ab_tester_tb/the_mmv_ram_ab_tester/ack0_cnt
add wave -noupdate -color Gold -radix unsigned /mmv_ram_ab_tester_tb/the_mmv_ram_ab_tester/ack1_cnt
add wave -noupdate -color Gold /mmv_ram_ab_tester_tb/the_mmv_ram_ab_tester/rd_inv_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1840000 ps} 0}
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
WaveRestoreZoom {0 ps} {8192 ns}
