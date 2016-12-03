vlog -work work ../../ds_scfifo_buffer.sv
vopt work.ds_scfifo_buffer +acc -o ds_scfifo_buffer_opt
vsim work.ds_scfifo_buffer_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force clear 0
force i_dat 0
force i_val 0
force o_rdy 0

run 30001ps
