vlog -work work ../../ps_width_expander.sv
vopt work.ps_width_expander +acc -o ps_width_expander_opt
vsim work.ps_width_expander_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0
force i_eop 0

force o_rdy 1

run 30001ps
