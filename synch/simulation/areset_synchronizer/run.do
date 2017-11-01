vlog -work work ../../areset_synchronizer.sv
vopt work.areset_synchronizer +acc -o areset_synchronizer_opt
vsim work.areset_synchronizer_opt

do wave.do

force clk 1 0ms, 0 5ns -r 10ns
force areset 0

run 30001ps