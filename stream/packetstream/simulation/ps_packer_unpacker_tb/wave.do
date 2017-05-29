onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ps_packer_unpacker_tb/reset
add wave -noupdate /ps_packer_unpacker_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_packer_unpacker_tb/i_dat
add wave -noupdate /ps_packer_unpacker_tb/i_val
add wave -noupdate /ps_packer_unpacker_tb/i_eop
add wave -noupdate /ps_packer_unpacker_tb/i_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_packer_unpacker_tb/width_expansion/the_ps_width_expander/o_dat
add wave -noupdate -radix hexadecimal /ps_packer_unpacker_tb/width_expansion/the_ps_width_expander/o_mty
add wave -noupdate /ps_packer_unpacker_tb/width_expansion/the_ps_width_expander/o_val
add wave -noupdate /ps_packer_unpacker_tb/width_expansion/the_ps_width_expander/o_eop
add wave -noupdate /ps_packer_unpacker_tb/width_expansion/the_ps_width_expander/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /ps_packer_unpacker_tb/ds_dat
add wave -noupdate /ps_packer_unpacker_tb/ds_val
add wave -noupdate /ps_packer_unpacker_tb/ds_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal -childformat {{{/ps_packer_unpacker_tb/o_dat[7]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[6]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[5]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[4]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[3]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[2]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[1]} -radix hexadecimal} {{/ps_packer_unpacker_tb/o_dat[0]} -radix hexadecimal}} -subitemconfig {{/ps_packer_unpacker_tb/o_dat[7]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[6]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[5]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[4]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[3]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[2]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[1]} {-radix hexadecimal} {/ps_packer_unpacker_tb/o_dat[0]} {-radix hexadecimal}} /ps_packer_unpacker_tb/o_dat
add wave -noupdate /ps_packer_unpacker_tb/o_val
add wave -noupdate /ps_packer_unpacker_tb/o_eop
add wave -noupdate /ps_packer_unpacker_tb/o_rdy
add wave -noupdate -divider <NULL>
add wave -noupdate -radix unsigned /ps_packer_unpacker_tb/i_word_cnt
add wave -noupdate -radix unsigned /ps_packer_unpacker_tb/o_word_cnt
add wave -noupdate -radix unsigned /ps_packer_unpacker_tb/i_pack_cnt
add wave -noupdate -radix unsigned /ps_packer_unpacker_tb/o_pack_cnt
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1011358 ps} 0}
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
WaveRestoreZoom {0 ps} {16384 ns}
