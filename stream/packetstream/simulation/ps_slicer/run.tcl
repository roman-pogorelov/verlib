vlog -work work ../../ps_slicer.sv
vopt work.ps_slicer +acc -o ps_slicer_opt
vsim work.ps_slicer_opt

do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0
force i_eop 0

force o_rdy 1

run 30001ps
