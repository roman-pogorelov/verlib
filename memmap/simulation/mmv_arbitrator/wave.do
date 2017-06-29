onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /mmv_arbitrator_tb/AWIDTH
add wave -noupdate -radix unsigned /mmv_arbitrator_tb/DWIDTH
add wave -noupdate -radix unsigned /mmv_arbitrator_tb/MASTERS
add wave -noupdate -radix unsigned /mmv_arbitrator_tb/RDPENDS
add wave -noupdate -radix unsigned /mmv_arbitrator_tb/RDDELAY
add wave -noupdate -divider <NULL>
add wave -noupdate /mmv_arbitrator_tb/reset
add wave -noupdate /mmv_arbitrator_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_addr[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_addr[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_addr[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_addr[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_addr[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_addr[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_addr
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_wreq[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_wreq[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_wreq[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_wreq[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_wreq[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_wreq[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_wreq
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_wdat[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_wdat[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_wdat[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_wdat[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_wdat[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_wdat[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_wdat
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_rreq[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_rreq[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_rreq[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_rreq[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_rreq[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_rreq[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_rreq
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_rdat[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_rdat[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_rdat[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_rdat[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_rdat[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_rdat[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_rdat
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_rval[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_rval[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_rval[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_rval[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_rval[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_rval[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_rval
add wave -noupdate -radix hexadecimal -childformat {{{/mmv_arbitrator_tb/s_busy[2]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_busy[1]} -radix hexadecimal} {{/mmv_arbitrator_tb/s_busy[0]} -radix hexadecimal}} -subitemconfig {{/mmv_arbitrator_tb/s_busy[2]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_busy[1]} {-height 15 -radix hexadecimal} {/mmv_arbitrator_tb/s_busy[0]} {-height 15 -radix hexadecimal}} /mmv_arbitrator_tb/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_arbitrator_tb/m_addr
add wave -noupdate /mmv_arbitrator_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmv_arbitrator_tb/m_wdat
add wave -noupdate /mmv_arbitrator_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmv_arbitrator_tb/m_rdat
add wave -noupdate /mmv_arbitrator_tb/m_rval
add wave -noupdate /mmv_arbitrator_tb/m_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmv_arbitrator_tb/the_mmv_slave_model/rdat_delayline
add wave -noupdate -radix hexadecimal /mmv_arbitrator_tb/the_mmv_slave_model/rval_delayline
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {105379 ps} 0}
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
