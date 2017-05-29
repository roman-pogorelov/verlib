vlog -reportprogress 300 -work work ../../ps_defragmenter_unpacker.sv
vopt work.ps_defragmenter_unpacker +acc -o ps_defragmenter_unpacker_opt
vsim -fsmdebug work.ps_defragmenter_unpacker_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns

force i_dat 0
force i_val 0
force o_rdy 1

run 30001ps
