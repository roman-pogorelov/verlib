vlog -reportprogress 300 -work work ../../initialpulse.sv
vopt work.initialpulse +acc -o initialpulse_opt
vsim work.initialpulse_opt
do wave.do
force clk 0 0ns, 1 5ns -r 10ns
run 10001ps