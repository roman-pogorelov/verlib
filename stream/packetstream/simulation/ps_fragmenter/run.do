vlog -reportprogress 300 -work work ../../ps_fragmenter.sv
vopt work.ps_fragmenter +acc -o ps_fragmenter_opt -L altera_mf_ver
vsim work.ps_fragmenter_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0
force i_eop 0

force o_rdy 0

run 30001ps
