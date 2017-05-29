onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /ps_fragmenter_packer/WIDTH
add wave -noupdate -radix unsigned /ps_fragmenter_packer/LENGTH
add wave -noupdate -divider <NULL>
add wave -noupdate /ps_fragmenter_packer/reset
add wave -noupdate /ps_fragmenter_packer/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_fragmenter_packer/i_dat
add wave -noupdate /ps_fragmenter_packer/i_val
add wave -noupdate /ps_fragmenter_packer/i_eop
add wave -noupdate /ps_fragmenter_packer/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal -childformat {{{/ps_fragmenter_packer/o_dat[7]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[6]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[5]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[4]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[3]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[2]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[1]} -radix hexadecimal} {{/ps_fragmenter_packer/o_dat[0]} -radix hexadecimal}} -subitemconfig {{/ps_fragmenter_packer/o_dat[7]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[6]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[5]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[4]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[3]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[2]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[1]} {-radix hexadecimal} {/ps_fragmenter_packer/o_dat[0]} {-radix hexadecimal}} /ps_fragmenter_packer/o_dat
add wave -noupdate /ps_fragmenter_packer/o_val
add wave -noupdate /ps_fragmenter_packer/o_eop
add wave -noupdate /ps_fragmenter_packer/o_rdy
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {56467 ps} 0}
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
WaveRestoreZoom {0 ps} {472084 ps}
