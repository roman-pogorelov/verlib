onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ds2ps_doser/DWIDTH
add wave -noupdate -radix unsigned /ds2ps_doser/CWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ds2ps_doser/reset
add wave -noupdate /ds2ps_doser/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ds2ps_doser/ctrl_amount
add wave -noupdate /ds2ps_doser/ctrl_run
add wave -noupdate /ds2ps_doser/ctrl_abort
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ds2ps_doser/stat_left
add wave -noupdate /ds2ps_doser/stat_busy
add wave -noupdate /ds2ps_doser/stat_done
add wave -noupdate -divider <NULL>
add wave -noupdate -color Maroon -radix hexadecimal /ds2ps_doser/i_dat
add wave -noupdate -color Maroon /ds2ps_doser/i_val
add wave -noupdate -color Maroon /ds2ps_doser/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color Orange -radix hexadecimal /ds2ps_doser/o_dat
add wave -noupdate -color Orange /ds2ps_doser/o_val
add wave -noupdate -color Orange /ds2ps_doser/o_eop
add wave -noupdate -color Orange /ds2ps_doser/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -color {Cornflower Blue} /ds2ps_doser/state
add wave -noupdate -radix unsigned -childformat {{{/ds2ps_doser/amount_cnt[7]} -radix unsigned} {{/ds2ps_doser/amount_cnt[6]} -radix unsigned} {{/ds2ps_doser/amount_cnt[5]} -radix unsigned} {{/ds2ps_doser/amount_cnt[4]} -radix unsigned} {{/ds2ps_doser/amount_cnt[3]} -radix unsigned} {{/ds2ps_doser/amount_cnt[2]} -radix unsigned} {{/ds2ps_doser/amount_cnt[1]} -radix unsigned} {{/ds2ps_doser/amount_cnt[0]} -radix unsigned}} -subitemconfig {{/ds2ps_doser/amount_cnt[7]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[6]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[5]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[4]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[3]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[2]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[1]} {-height 15 -radix unsigned} {/ds2ps_doser/amount_cnt[0]} {-height 15 -radix unsigned}} /ds2ps_doser/amount_cnt
add wave -noupdate -radix hexadecimal /ds2ps_doser/dat_reg
add wave -noupdate /ds2ps_doser/fsm_busy
add wave -noupdate /ds2ps_doser/fsm_rcvena
add wave -noupdate /ds2ps_doser/fsm_tsmena
add wave -noupdate /ds2ps_doser/fsm_last
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {50 ns} 0}
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
WaveRestoreZoom {0 ns} {928 ns}
