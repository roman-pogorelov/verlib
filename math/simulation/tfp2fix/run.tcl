vlog -reportprogress 300 -work work ../../tfp2fix.sv
vopt work.tfp2fix +acc -o tfp2fix_opt
vsim work.tfp2fix_opt
do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force clkena 1
force tfp_data 'h87

run 30001ps
