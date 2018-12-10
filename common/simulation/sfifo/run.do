vlog -work work ../../sfifo.sv
vopt work.sfifo +acc -o sfifo_opt
vsim work.sfifo_opt

do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force clear 0
force wr_data 0
force wr_req 0

force rd_req 0

run 30001ps
