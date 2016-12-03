onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ds_scfifo_buffer/WIDTH
add wave -noupdate -radix unsigned /ds_scfifo_buffer/DEPTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_scfifo_buffer/reset
add wave -noupdate /ds_scfifo_buffer/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /ds_scfifo_buffer/clear
add wave -noupdate -radix unsigned /ds_scfifo_buffer/used
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_scfifo_buffer/i_dat
add wave -noupdate /ds_scfifo_buffer/i_val
add wave -noupdate /ds_scfifo_buffer/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ds_scfifo_buffer/o_dat
add wave -noupdate /ds_scfifo_buffer/o_val
add wave -noupdate /ds_scfifo_buffer/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned -childformat {{{/ds_scfifo_buffer/buffer[7]} -radix unsigned} {{/ds_scfifo_buffer/buffer[6]} -radix unsigned} {{/ds_scfifo_buffer/buffer[5]} -radix unsigned} {{/ds_scfifo_buffer/buffer[4]} -radix unsigned} {{/ds_scfifo_buffer/buffer[3]} -radix unsigned} {{/ds_scfifo_buffer/buffer[2]} -radix unsigned} {{/ds_scfifo_buffer/buffer[1]} -radix unsigned} {{/ds_scfifo_buffer/buffer[0]} -radix unsigned}} -expand -subitemconfig {{/ds_scfifo_buffer/buffer[7]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[6]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[5]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[4]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[3]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[2]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[1]} {-height 15 -radix unsigned} {/ds_scfifo_buffer/buffer[0]} {-height 15 -radix unsigned}} /ds_scfifo_buffer/buffer
add wave -noupdate /ds_scfifo_buffer/wr_ena
add wave -noupdate /ds_scfifo_buffer/rd_ena
add wave -noupdate -radix unsigned /ds_scfifo_buffer/wr_cnt
add wave -noupdate -radix unsigned /ds_scfifo_buffer/rd_cnt
add wave -noupdate -radix unsigned /ds_scfifo_buffer/used_cnt
add wave -noupdate /ds_scfifo_buffer/wr_rdy_reg
add wave -noupdate /ds_scfifo_buffer/rd_val_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {107 ns} 0}
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
WaveRestoreZoom {0 ns} {630 ns}
