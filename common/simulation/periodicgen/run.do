vlog -work work ../../periodicgen.sv
vopt work.periodicgen +acc -o periodicgen_opt
vsim work.periodicgen_opt
do wave.do

force reset 1 0ns, 0 10ns
force clk 1 0ms, 0 5ns -r 10ns
force clkena 1

run 30001ps