vlog -work work ../../lfsr_generator.sv
vopt work.lfsr_generator +acc -o lfsr_generator_opt
vsim work.lfsr_generator_opt
do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force clkena 0
force init 0

run 30001ps
