onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_mm_writer/DWIDTH
add wave -noupdate -radix unsigned /ps_mm_writer/AWIDTH
add wave -noupdate -radix unsigned /ps_mm_writer/SYMBOLS
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_mm_writer/reset
add wave -noupdate /ps_mm_writer/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_writer/address
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_writer/i_dat
add wave -noupdate -radix unsigned /ps_mm_writer/i_mty
add wave -noupdate /ps_mm_writer/i_val
add wave -noupdate /ps_mm_writer/i_eop
add wave -noupdate /ps_mm_writer/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_writer/avm_address
add wave -noupdate -radix hexadecimal /ps_mm_writer/avm_byteenable
add wave -noupdate /ps_mm_writer/avm_write
add wave -noupdate -radix hexadecimal /ps_mm_writer/avm_writedata
add wave -noupdate /ps_mm_writer/avm_waitrequest
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_mm_writer/s_dat
add wave -noupdate /ps_mm_writer/s_val
add wave -noupdate /ps_mm_writer/s_sop
add wave -noupdate /ps_mm_writer/s_eop
add wave -noupdate /ps_mm_writer/s_rdy
add wave -noupdate -radix unsigned /ps_mm_writer/addr_cnt
add wave -noupdate -radix binary /ps_mm_writer/mty_one_hote
add wave -noupdate -radix binary /ps_mm_writer/be_reversed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {111 ns} 0}
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
WaveRestoreZoom {0 ns} {610 ns}
