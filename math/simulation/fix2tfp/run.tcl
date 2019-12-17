vlog -reportprogress 300 -work work ../../fix2tfp.sv
vopt work.fix2tfp +acc -o fix2tfp_opt
vsim work.fix2tfp_opt
do wave.do

force rst 1 0ns, 0 15 ns
force clk 1 0ns, 0 5ns -r 10ns

force clkena 1
force fix_data 0

run 30001ps
