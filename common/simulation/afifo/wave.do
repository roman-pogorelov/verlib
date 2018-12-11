onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /afifo/WIDTH
add wave -noupdate -radix unsigned /afifo/DEPTH
add wave -noupdate -radix unsigned /afifo/PROGFULL
add wave -noupdate -radix unsigned /afifo/PROGEMPTY
add wave -noupdate -divider <NULL>
add wave -noupdate /afifo/rst
add wave -noupdate -divider <NULL>
add wave -noupdate /afifo/wr_clk
add wave -noupdate -radix hexadecimal /afifo/wr_data
add wave -noupdate /afifo/wr_req
add wave -noupdate /afifo/wr_full
add wave -noupdate /afifo/wr_progfull
add wave -noupdate -radix hexadecimal /afifo/wr_used
add wave -noupdate -divider <NULL>
add wave -noupdate /afifo/rd_clk
add wave -noupdate -radix hexadecimal /afifo/rd_data
add wave -noupdate /afifo/rd_req
add wave -noupdate /afifo/rd_empty
add wave -noupdate /afifo/rd_progempty
add wave -noupdate -radix hexadecimal /afifo/rd_used
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /afifo/buffer
add wave -noupdate /afifo/wr_rst
add wave -noupdate /afifo/rd_rst
add wave -noupdate /afifo/wr_ena
add wave -noupdate /afifo/rd_ena
add wave -noupdate -radix hexadecimal /afifo/wr_cnt
add wave -noupdate -radix hexadecimal /afifo/wr_cnt_next
add wave -noupdate -radix hexadecimal /afifo/wr_addr
add wave -noupdate -radix hexadecimal /afifo/wr_gray_cnt
add wave -noupdate -radix hexadecimal /afifo/wr_gray_cnt_next
add wave -noupdate -radix hexadecimal /afifo/wr_gray_ptr
add wave -noupdate -radix hexadecimal /afifo/rd_cnt
add wave -noupdate -radix hexadecimal /afifo/rd_cnt_next
add wave -noupdate -radix hexadecimal /afifo/rd_addr
add wave -noupdate -radix hexadecimal /afifo/rd_gray_cnt
add wave -noupdate -radix hexadecimal /afifo/rd_gray_cnt_next
add wave -noupdate -radix hexadecimal /afifo/rd_gray_ptr
add wave -noupdate -radix hexadecimal /afifo/wr_full_reg
add wave -noupdate -radix hexadecimal /afifo/rd_empty_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {265 ns} 0}
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
