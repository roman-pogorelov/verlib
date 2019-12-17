vlog -reportprogress 300 -work work fix2tfp2fix_tb.sv
vlog -reportprogress 300 -work work ../../fix2tfp.sv
vlog -reportprogress 300 -work work ../../tfp2fix.sv
vopt work.fix2tfp2fix_tb +acc -o fix2tfp2fix_tb_opt
vsim work.fix2tfp2fix_tb_opt
do wave.do
run 30001ps
