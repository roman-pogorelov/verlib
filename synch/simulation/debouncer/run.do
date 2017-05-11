vlog -reportprogress 300 -work work ../../debouncer.sv
vopt work.debouncer +acc -o debouncer_opt
vsim work.debouncer_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns
force bounce 0

run 30001ps