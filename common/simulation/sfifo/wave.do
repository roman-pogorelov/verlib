onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /sfifo/WIDTH
add wave -noupdate -radix unsigned /sfifo/DEPTH
add wave -noupdate -divider <NULL>
add wave -noupdate /sfifo/reset
add wave -noupdate /sfifo/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /sfifo/clear
add wave -noupdate -radix unsigned /sfifo/used
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /sfifo/wr_data
add wave -noupdate /sfifo/wr_req
add wave -noupdate /sfifo/wr_full
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /sfifo/rd_data
add wave -noupdate /sfifo/rd_ack
add wave -noupdate /sfifo/rd_empty
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /sfifo/buffer
add wave -noupdate /sfifo/wr_ena
add wave -noupdate /sfifo/rd_ena
add wave -noupdate -radix unsigned /sfifo/wr_cnt
add wave -noupdate -radix unsigned /sfifo/rd_cnt
add wave -noupdate -radix unsigned /sfifo/used_cnt
add wave -noupdate /sfifo/full_reg
add wave -noupdate /sfifo/empty_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {77 ns} 0}
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
