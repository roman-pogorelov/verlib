vlog -reportprogress 300 -work work ../../ps_head_inserter.sv
vopt work.ps_head_inserter +acc -o ps_head_inserter_opt
vsim work.ps_head_inserter_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force insert 0

force i_dat 0
force i_val 0
force i_eop 0

force h_dat 0
force h_val 0
force h_eop 0

force o_rdy 0

run 30001ps
