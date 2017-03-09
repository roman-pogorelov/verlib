vlog -work work ../../rgb_led_driver.sv
vopt work.rgb_led_driver +acc -o rgb_led_driver_opt
vsim work.rgb_led_driver_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force ctrl_on 1

force ctrl_r 'h2
force ctrl_g 'h5
force ctrl_b 'h3

run 30001ps
