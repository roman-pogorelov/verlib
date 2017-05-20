vlog -reportprogress 300 -work work ../../ps_sop_protector.sv
vopt work.ps_sop_protector +acc -o ps_sop_protector_opt
vsim -fsmdebug work.ps_sop_protector_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0
force i_sop 0
force i_eop 0
force o_rdy 0

run 30001ps