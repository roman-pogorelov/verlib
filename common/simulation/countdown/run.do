vlog -work work ../../countdown.sv
vopt work.countdown +acc -o countdown_opt
vsim work.countdown_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force clkena 1
force ctrl_time 0
force ctrl_run 0
#force ctrl_rerun 0
force ctrl_abort 0

run 30001ps
