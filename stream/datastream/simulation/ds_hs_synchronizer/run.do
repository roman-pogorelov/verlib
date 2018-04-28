vlog -work work ../../ds_hs_synchronizer.sv
vopt work.ds_hs_synchronizer +acc -o ds_hs_synchronizer_opt
vsim work.ds_hs_synchronizer_opt

do wave.do

force i_reset 1 0ns, 0 15ns
force i_clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0

force o_reset 1 0ns, 0 30ns
force o_clk 1 0ns, 0 10ns -r 20ns

force o_rdy 0

run 30001ps