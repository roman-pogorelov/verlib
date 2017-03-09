onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /iterated_signed_divider_tb/NWIDTH
add wave -noupdate -radix unsigned /iterated_signed_divider_tb/DWIDTH
add wave -noupdate -divider <NULL>
add wave -noupdate /iterated_signed_divider_tb/reset
add wave -noupdate /iterated_signed_divider_tb/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /iterated_signed_divider_tb/start
add wave -noupdate /iterated_signed_divider_tb/ready
add wave -noupdate /iterated_signed_divider_tb/done
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal /iterated_signed_divider_tb/numerator
add wave -noupdate -radix decimal /iterated_signed_divider_tb/denominator
add wave -noupdate -divider <NULL>
add wave -noupdate -radix decimal /iterated_signed_divider_tb/quotient
add wave -noupdate -radix decimal /iterated_signed_divider_tb/remainder
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 ps} {1 us}
