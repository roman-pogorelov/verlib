onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rgb_led_driver/reset
add wave -noupdate /rgb_led_driver/clk
add wave -noupdate -divider <NULL>
add wave -noupdate /rgb_led_driver/ctrl_on
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /rgb_led_driver/ctrl_r
add wave -noupdate -radix hexadecimal /rgb_led_driver/ctrl_g
add wave -noupdate -radix hexadecimal /rgb_led_driver/ctrl_b
add wave -noupdate -divider <NULL>
add wave -noupdate /rgb_led_driver/led_r
add wave -noupdate /rgb_led_driver/led_g
add wave -noupdate /rgb_led_driver/led_b
add wave -noupdate -divider <NULL>
add wave -noupdate -radix hexadecimal /rgb_led_driver/ena_cnt
add wave -noupdate /rgb_led_driver/ena_reg
add wave -noupdate -radix hexadecimal /rgb_led_driver/r_reg
add wave -noupdate -radix hexadecimal /rgb_led_driver/g_reg
add wave -noupdate -radix hexadecimal /rgb_led_driver/b_reg
add wave -noupdate -radix hexadecimal /rgb_led_driver/pwm_cnt
add wave -noupdate /rgb_led_driver/led_r_reg
add wave -noupdate /rgb_led_driver/led_g_reg
add wave -noupdate /rgb_led_driver/led_b_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
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
WaveRestoreZoom {0 ns} {1 us}
