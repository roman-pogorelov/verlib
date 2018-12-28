vlog -reportprogress 300 -work work ../../ds_alt_dcfifo.sv
vopt work.ds_alt_dcfifo +acc -o ds_alt_dcfifo_opt -L altera_mf_ver
vsim work.ds_alt_dcfifo_opt
do wave.do

force reset 1 0ns, 0 15ns
force i_clk 1 0ns, 0 5ns -r 10ns
force i_dat 0
force i_val 0
force o_clk 1 0ns, 0 10ns -r 20ns
force o_rdy 0

run 50001ps