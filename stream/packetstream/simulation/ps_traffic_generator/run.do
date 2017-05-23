vlog -reportprogress 300 -work work ../../ps_traffic_generator.sv
vopt work.ps_traffic_generator +acc -o ps_traffic_generator_opt
vsim work.ps_traffic_generator_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force ctrl_addr 0
force ctrl_wreq 0
force ctrl_wdat 0
force ctrl_rreq 0

force o_rdy 0

run 30001ps