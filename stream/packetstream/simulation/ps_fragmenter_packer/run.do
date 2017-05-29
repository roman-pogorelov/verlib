vlog -reportprogress 300 -work work ../../ps_fragmenter_packer.sv
vopt work.ps_fragmenter_packer +acc -o ps_fragmenter_packer_opt -L altera_mf_ver
vsim work.ps_fragmenter_packer_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0
force i_eop 0
force o_rdy 1

run 30001ps