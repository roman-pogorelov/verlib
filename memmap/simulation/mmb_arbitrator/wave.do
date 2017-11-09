onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mmb_arbitrator_tb/reset
add wave -noupdate /mmb_arbitrator_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_addr[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_addr[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_addr[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_addr[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_addr
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_bcnt[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_bcnt[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_bcnt[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_bcnt[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_bcnt
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_wreq[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_wreq[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_wreq[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_wreq[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_wreq
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_wdat[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_wdat[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_wdat[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_wdat[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_wdat
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_rreq[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_rreq[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_rreq[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_rreq[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_rreq
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_rdat[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_rdat[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_rdat[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_rdat[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_rdat
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_rval[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_rval[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_rval[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_rval[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_rval
add wave -noupdate -radix hexadecimal -childformat {{{/mmb_arbitrator_tb/s_busy[1]} -radix hexadecimal} {{/mmb_arbitrator_tb/s_busy[0]} -radix hexadecimal}} -expand -subitemconfig {{/mmb_arbitrator_tb/s_busy[1]} {-color {Cornflower Blue} -height 15 -radix hexadecimal} {/mmb_arbitrator_tb/s_busy[0]} {-color Gold -height 15 -radix hexadecimal}} /mmb_arbitrator_tb/s_busy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /mmb_arbitrator_tb/m_addr
add wave -noupdate -radix hexadecimal /mmb_arbitrator_tb/m_bcnt
add wave -noupdate /mmb_arbitrator_tb/m_wreq
add wave -noupdate -radix hexadecimal /mmb_arbitrator_tb/m_wdat
add wave -noupdate /mmb_arbitrator_tb/m_rreq
add wave -noupdate -radix hexadecimal /mmb_arbitrator_tb/m_rdat
add wave -noupdate /mmb_arbitrator_tb/m_rval
add wave -noupdate /mmb_arbitrator_tb/m_busy
add wave -noupdate -radix hexadecimal {/mmb_arbitrator_tb/the_mmb_master_model[1]/wburstcnt}
add wave -noupdate -radix hexadecimal {/mmb_arbitrator_tb/the_mmb_master_model[1]/wrdata}
add wave -noupdate -radix hexadecimal {/mmb_arbitrator_tb/the_mmb_master_model[1]/wrenable}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {903480 ps} 0}
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
WaveRestoreZoom {426811 ps} {1509133 ps}
