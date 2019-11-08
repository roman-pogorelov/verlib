vlog -work work ../../pss_cutter.sv
vopt work.pss_cutter +acc -o pss_cutter_opt
vsim work.pss_cutter_opt

do wave.do

force rst 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force cut 0

force i_dat 0
force i_val 0
force i_sop 0
force i_eop 0
force o_rdy 1

run 30001ps
