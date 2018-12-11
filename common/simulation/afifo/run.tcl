vlog -reportprogress 300 -work work ../../afifo.sv
vopt work.afifo +acc -o afifo_opt
vsim work.afifo_opt
do wave.do

force rst 1 0ns, 0 15ns
force wr_clk 1 0ns, 0 5ns -r 10ns
force wr_data 0
force wr_req 0
force rd_clk 1 0ns, 0 10ns -r 20ns
force rd_req 0

run 50001ps