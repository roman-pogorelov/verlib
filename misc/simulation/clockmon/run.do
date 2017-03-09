vlog -work work ../../clockmon.sv
vopt work.clockmon +acc -o clockmon_opt
vsim work.clockmon_opt

do wave.do

force reset 1 0ns, 0 15ns
force monclk 1 0ns, 0 10ns -r 20ns
force refclk 1 0ns, 0 5ns -r 10ns

run 30001ps