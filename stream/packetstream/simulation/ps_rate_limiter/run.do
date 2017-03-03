vlog -reportprogress 300 -work work ../../ps_rate_limiter.sv
vopt work.ps_rate_limiter +acc -o ps_rate_limiter_opt
vsim work.ps_rate_limiter_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force delay 0

force i_dat 0
force i_val 0
force i_eop 0

force o_rdy 1

run 30001ps