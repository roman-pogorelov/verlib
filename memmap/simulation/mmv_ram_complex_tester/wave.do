onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mmv_ram_complex_tester_tb/MAWIDTH
add wave -noupdate -radix unsigned /mmv_ram_complex_tester_tb/MDWIDTH
add wave -noupdate -radix unsigned /mmv_ram_complex_tester_tb/CDWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_ram_complex_tester_tb/reset
add wave -noupdate /mmv_ram_complex_tester_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_ram_complex_tester_tb/ctl_addr
add wave -noupdate /mmv_ram_complex_tester_tb/ctl_wreq
add wave -noupdate -radix hexadecimal /mmv_ram_complex_tester_tb/ctl_wdat
add wave -noupdate /mmv_ram_complex_tester_tb/ctl_rreq
add wave -noupdate -radix hexadecimal /mmv_ram_complex_tester_tb/ctl_rdat
add wave -noupdate /mmv_ram_complex_tester_tb/ctl_rval
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_ram_complex_tester_tb/m_addr
add wave -noupdate /mmv_ram_complex_tester_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmv_ram_complex_tester_tb/m_wdat
add wave -noupdate /mmv_ram_complex_tester_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmv_ram_complex_tester_tb/m_rdat
add wave -noupdate /mmv_ram_complex_tester_tb/m_rval
add wave -noupdate /mmv_ram_complex_tester_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/state
add wave -noupdate -divider <NULL>
add wave -noupdate -color Gold /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/start_reg
add wave -noupdate -color Gold /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/soft_reset_reg
add wave -noupdate -color Gold /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/fault_reg
add wave -noupdate -divider <NULL>
add wave -noupdate -color Gold -radix unsigned /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/datab_err_cnt
add wave -noupdate -color Gold -radix unsigned /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/addrb_err_cnt
add wave -noupdate -color Gold -radix unsigned /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/march_err_cnt
add wave -noupdate -color Gold -radix unsigned /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/write_req_cnt
add wave -noupdate -color Gold -radix unsigned /mmv_ram_complex_tester_tb/the_mmv_ram_complex_tester/read_req_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {61895 ps} 0}
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
