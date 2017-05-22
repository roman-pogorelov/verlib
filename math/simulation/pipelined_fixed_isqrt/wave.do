onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt/WIDTH
add wave -noupdate -radix unsigned /pipelined_fixed_isqrt/ITERATIONS
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt/reset
add wave -noupdate /pipelined_fixed_isqrt/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /pipelined_fixed_isqrt/clkena
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt/radical
add wave -noupdate -radix hexadecimal -childformat {{{/pipelined_fixed_isqrt/invsqrt[15]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[14]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[13]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[12]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[11]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[10]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[9]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[8]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[7]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[6]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[5]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[4]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[3]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[2]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[1]} -radix hexadecimal} {{/pipelined_fixed_isqrt/invsqrt[0]} -radix hexadecimal}} -subitemconfig {{/pipelined_fixed_isqrt/invsqrt[15]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[14]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[13]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[12]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[11]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[10]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[9]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[8]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[7]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[6]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[5]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[4]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[3]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[2]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[1]} {-height 15 -radix hexadecimal} {/pipelined_fixed_isqrt/invsqrt[0]} {-height 15 -radix hexadecimal}} /pipelined_fixed_isqrt/invsqrt
add wave -noupdate -radix unsigned -childformat {{{/pipelined_fixed_isqrt/exponent[2]} -radix unsigned} {{/pipelined_fixed_isqrt/exponent[1]} -radix unsigned} {{/pipelined_fixed_isqrt/exponent[0]} -radix unsigned}} -subitemconfig {{/pipelined_fixed_isqrt/exponent[2]} {-height 15 -radix unsigned} {/pipelined_fixed_isqrt/exponent[1]} {-height 15 -radix unsigned} {/pipelined_fixed_isqrt/exponent[0]} {-height 15 -radix unsigned}} /pipelined_fixed_isqrt/exponent
add wave -noupdate /pipelined_fixed_isqrt/overflow
add wave -noupdate -color Goldenrod /pipelined_fixed_isqrt/isqrt_real
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt/radical_scaled
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt/radical_scale
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt/poly_approx
add wave -noupdate -radix hexadecimal /pipelined_fixed_isqrt/newton_approx
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {303 ns} 0}
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
WaveRestoreZoom {0 ns} {446 ns}
