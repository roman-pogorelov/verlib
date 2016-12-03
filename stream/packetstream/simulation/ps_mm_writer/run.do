vlog -work work ../../ps_mm_writer.sv
vopt work.ps_mm_writer +acc -o ps_mm_writer_opt
vsim work.ps_mm_writer_opt

do wave.do

force reset 1 0ns, 0 15ns
force clk 1 0ns, 0 5ns -r 10ns


force address 0

force i_dat 0
force i_mty 0
force i_val 0
force i_eop 0

force avm_waitrequest 0

run 30001ps
