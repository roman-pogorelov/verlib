vlog -reportprogress 300 -work work ../../max_lfsr.sv
vopt work.max_lfsr +acc -o max_lfsr_opt
vsim work.max_lfsr_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns
force clkena 1

run 30001ps