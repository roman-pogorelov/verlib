vlog -reportprogress 300 -work work ../../ps_head_extractor.sv
vopt work.ps_head_extractor +acc -o ps_head_extractor_opt
vsim work.ps_head_extractor_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force extract 0
force length 0

force i_dat 0
force i_val 0
force i_eop 0

force h_rdy 1

force o_rdy 1

run 30001ps
